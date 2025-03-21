/******************************Module*Header*******************************\
* Module Name: bitblt.c
*
* Contains the high-level DrvBitBlt and DrvCopyBits functions.  The low-
* level stuff lives in the 'blt??.c' files.
*
* Note: Since we've implemented device-bitmaps, any surface that GDI passes
*       to us can have 3 values for its 'iType': STYPE_BITMAP, STYPE_DEVICE
*       or STYPE_DEVBITMAP.  We filter device-bitmaps that we've stored
*       as DIBs fairly high in the code, so after we adjust its 'pptlSrc',
*       we can treat STYPE_DEVBITMAP surfaces the same as STYPE_DEVICE
*       surfaces (e.g., a blt from an off-screen device bitmap to the screen
*       gets treated as a normal screen-to-screen blt).
*
*       Unfortunately, if we've created our primary surface as a device-
*       managed surface, it has an 'iType' of STYPE_BITMAP and not
*       STYPE_DEVICE.  So throughout this code, we will determine if a
*       surface is one of ours by checking 'dhsurf' -- a NULL value means
*       that it's a GDI-created DIB, otherwise it's one of our surfaces and
*       'dhsurf' points to our DSURF structure.
*
* Copyright (c) 1992-1996 Microsoft Corporation
\**************************************************************************/

#include "precomp.h"

#if 0

    BOOL gbPuntBitBlt       = FALSE;
    BOOL gbPuntCopyBits     = FALSE;

#else

    #define gbPuntBitBlt    FALSE
    #define gbPuntCopyBits  FALSE

#endif


/******************************Public*Data*********************************\
* MIX translation table
*
* Translates a mix 1-16, into an old style Rop 0-255.
*
\**************************************************************************/

BYTE gaRop3FromMix[] =
{
    0xFF,  // R2_WHITE          - Allow rop = gaRop3FromMix[mix & 0x0F]
    0x00,  // R2_BLACK
    0x05,  // R2_NOTMERGEPEN
    0x0A,  // R2_MASKNOTPEN
    0x0F,  // R2_NOTCOPYPEN
    0x50,  // R2_MASKPENNOT
    0x55,  // R2_NOT
    0x5A,  // R2_XORPEN
    0x5F,  // R2_NOTMASKPEN
    0xA0,  // R2_MASKPEN
    0xA5,  // R2_NOTXORPEN
    0xAA,  // R2_NOP
    0xAF,  // R2_MERGENOTPEN
    0xF0,  // R2_COPYPEN
    0xF5,  // R2_MERGEPENNOT
    0xFA,  // R2_MERGEPEN
    0xFF   // R2_WHITE          - Allow rop = gaRop3FromMix[mix & 0xFF]
};

/******************************Public*Table********************************\
* BYTE gajLeftMask[] and BYTE gajRightMask[]
*
* Edge tables for vXferScreenTo1bpp.
\**************************************************************************/

BYTE gajLeftMask[]  = { 0xff, 0x7f, 0x3f, 0x1f, 0x0f, 0x07, 0x03, 0x01 };
BYTE gajRightMask[] = { 0xff, 0x80, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc, 0xfe };

/******************************Public*Routine******************************\
* VOID vXferScreenTo1bpp
*
* Performs a SRCCOPY transfer from the screen (when it's 8bpp) to a 1bpp
* bitmap.
*
\**************************************************************************/

#if defined(i386)

VOID vXferScreenTo1bpp(         // Type FNXFER
PDEV*       ppdev,
LONG        c,                  // Count of rectangles, can't be zero
RECTL*      prcl,               // List of destination rectangles, in relative
                                //   coordinates
ULONG       ulHwMix,            // Not used
SURFOBJ*    psoDst,             // Destination surface
POINTL*     pptlSrc,            // Original unclipped source point
RECTL*      prclDst,            // Original unclipped destination rectangle
XLATEOBJ*   pxlo)               // Provides colour-compressions information
{
    LONG    cjPelSize;
    VOID*   pfnCompute;
    SURFOBJ soTmp;
    ULONG*  pulXlate;
    ULONG   ulForeColor;
    POINTL  ptlSrc;
    RECTL   rclTmp;
    BYTE*   pjDst;
    BYTE    jLeftMask;
    BYTE    jRightMask;
    BYTE    jNotLeftMask;
    BYTE    jNotRightMask;
    LONG    cjMiddle;
    LONG    lDstDelta;
    LONG    lSrcDelta;
    LONG    cyTmpScans;
    LONG    cyThis;
    LONG    cyToGo;

    ASSERTDD(c > 0, "Can't handle zero rectangles");
    ASSERTDD(psoDst->iBitmapFormat == BMF_1BPP, "Only 1bpp destinations");
    ASSERTDD(TMP_BUFFER_SIZE >= (ppdev->cxMemory * ppdev->cjPelSize),
                "Temp buffer has to be larger than widest possible scan");

    // When the destination is a 1bpp bitmap, the foreground colour
    // maps to '1', and any other colour maps to '0'.

    if (ppdev->iBitmapFormat == BMF_8BPP)
    {
        // When the source is 8bpp or less, we find the forground colour
        // by searching the translate table for the only '1':

        pulXlate = pxlo->pulXlate;
        while (*pulXlate != 1)
            pulXlate++;

        ulForeColor = pulXlate - pxlo->pulXlate;
    }
    else
    {
        ASSERTDD((ppdev->iBitmapFormat == BMF_16BPP) ||
                 (ppdev->iBitmapFormat == BMF_32BPP),
                 "This routine only supports 8, 16 or 32bpp");

        // When the source has a depth greater than 8bpp, the foreground
        // colour will be the first entry in the translate table we get
        // from calling 'piVector':

        pulXlate = XLATEOBJ_piVector(pxlo);

        ulForeColor = 0;
        if (pulXlate != NULL)           // This check isn't really needed...
            ulForeColor = pulXlate[0];
    }

    // We use the temporary buffer to keep a copy of the source
    // rectangle:

    soTmp.pvScan0 = ppdev->pvTmpBuffer;

    do {
        // ptlSrc points to the upper-left corner of the screen rectangle
        // for the current batch:

        ptlSrc.x = prcl->left + (pptlSrc->x - prclDst->left);
        ptlSrc.y = prcl->top  + (pptlSrc->y - prclDst->top);

        // vGetBits takes absolute coordinates for the source point:

        ptlSrc.x += ppdev->xOffset;
        ptlSrc.y += ppdev->yOffset;

        pjDst = (BYTE*) psoDst->pvScan0 + (prcl->top * psoDst->lDelta)
                                        + (prcl->left >> 3);

        cjPelSize = ppdev->cjPelSize;

        soTmp.lDelta = (((prcl->right + 7L) & ~7L) - (prcl->left & ~7L))
                       * cjPelSize;

        // Our temporary buffer, into which we read a copy of the source,
        // may be smaller than the source rectangle.  In that case, we
        // process the source rectangle in batches.
        //
        // cyTmpScans is the number of scans we can do in each batch.
        // cyToGo is the total number of scans we have to do for this
        // rectangle.
        //
        // We take the buffer size less four so that the right edge case
        // can safely read one dword past the end:

        cyTmpScans = (TMP_BUFFER_SIZE - 4) / soTmp.lDelta;
        cyToGo     = prcl->bottom - prcl->top;

        ASSERTDD(cyTmpScans > 0, "Buffer too small for largest possible scan");

        // Initialize variables that don't change within the batch loop:

        rclTmp.top    = 0;
        rclTmp.left   = prcl->left & 7L;
        rclTmp.right  = (prcl->right - prcl->left) + rclTmp.left;

        // Note that we have to be careful with the right mask so that it
        // isn't zero.  A right mask of zero would mean that we'd always be
        // touching one byte past the end of the scan (even though we
        // wouldn't actually be modifying that byte), and we must never
        // access memory past the end of the bitmap (because we can access
        // violate if the bitmap end is exactly page-aligned).

        jLeftMask     = gajLeftMask[rclTmp.left & 7];
        jRightMask    = gajRightMask[rclTmp.right & 7];
        cjMiddle      = ((rclTmp.right - 1) >> 3) - (rclTmp.left >> 3) - 1;

        if (cjMiddle < 0)
        {
            // The blt starts and ends in the same byte:

            jLeftMask &= jRightMask;
            jRightMask = 0;
            cjMiddle   = 0;
        }

        jNotLeftMask  = ~jLeftMask;
        jNotRightMask = ~jRightMask;
        lDstDelta     = psoDst->lDelta - cjMiddle - 2;
                                // Delta from the end of the destination
                                //  to the start on the next scan, accounting
                                //  for 'left' and 'right' bytes

        lSrcDelta     = soTmp.lDelta - ((8 * (cjMiddle + 2)) * cjPelSize);
                                // Compute source delta for special cases
                                //  like when cjMiddle gets bumped up to '0',
                                //  and to correct aligned cases

        do {
            // This is the loop that breaks the source rectangle into
            // manageable batches.

            cyThis  = cyTmpScans;
            cyToGo -= cyThis;
            if (cyToGo < 0)
                cyThis += cyToGo;

            rclTmp.bottom = cyThis;

            vGetBits(ppdev, &soTmp, &rclTmp, &ptlSrc);

            ptlSrc.y += cyThis;         // Get ready for next batch loop

            _asm {
                mov     eax,ulForeColor     ;eax = foreground colour
                                            ;ebx = temporary storage
                                            ;ecx = count of middle dst bytes
                                            ;dl  = destination byte accumulator
                                            ;dh  = temporary storage
                mov     esi,soTmp.pvScan0   ;esi = source pointer
                mov     edi,pjDst           ;edi = destination pointer

                ; Figure out the appropriate compute routine:

                mov     ebx,cjPelSize
                mov     pfnCompute,offset Compute_Destination_Byte_From_8bpp
                dec     ebx
                jz      short Do_Left_Byte
                mov     pfnCompute,offset Compute_Destination_Byte_From_16bpp
                dec     ebx
                jz      short Do_Left_Byte
                mov     pfnCompute,offset Compute_Destination_Byte_From_32bpp

            Do_Left_Byte:
                call    pfnCompute
                and     dl,jLeftMask
                mov     dh,jNotLeftMask
                and     dh,[edi]
                or      dh,dl
                mov     [edi],dh
                inc     edi
                mov     ecx,cjMiddle
                dec     ecx
                jl      short Do_Right_Byte

            Do_Middle_Bytes:
                call    pfnCompute
                mov     [edi],dl
                inc     edi
                dec     ecx
                jge     short Do_Middle_Bytes

            Do_Right_Byte:
                call    pfnCompute
                and     dl,jRightMask
                mov     dh,jNotRightMask
                and     dh,[edi]
                or      dh,dl
                mov     [edi],dh
                inc     edi

                add     edi,lDstDelta
                add     esi,lSrcDelta
                dec     cyThis
                jnz     short Do_Left_Byte

                mov     pjDst,edi               ;save for next batch

                jmp     All_Done

            Compute_Destination_Byte_From_8bpp:
                mov     bl,[esi]
                sub     bl,al
                cmp     bl,1
                adc     dl,dl                   ;bit 0

                mov     bl,[esi+1]
                sub     bl,al
                cmp     bl,1
                adc     dl,dl                   ;bit 1

                mov     bl,[esi+2]
                sub     bl,al
                cmp     bl,1
                adc     dl,dl                   ;bit 2

                mov     bl,[esi+3]
                sub     bl,al
                cmp     bl,1
                adc     dl,dl                   ;bit 3

                mov     bl,[esi+4]
                sub     bl,al
                cmp     bl,1
                adc     dl,dl                   ;bit 4

                mov     bl,[esi+5]
                sub     bl,al
                cmp     bl,1
                adc     dl,dl                   ;bit 5

                mov     bl,[esi+6]
                sub     bl,al
                cmp     bl,1
                adc     dl,dl                   ;bit 6

                mov     bl,[esi+7]
                sub     bl,al
                cmp     bl,1
                adc     dl,dl                   ;bit 7

                add     esi,8                   ;advance the source
                ret

            Compute_Destination_Byte_From_16bpp:
                mov     bx,[esi]
                sub     bx,ax
                cmp     bx,1
                adc     dl,dl                   ;bit 0

                mov     bx,[esi+2]
                sub     bx,ax
                cmp     bx,1
                adc     dl,dl                   ;bit 1

                mov     bx,[esi+4]
                sub     bx,ax
                cmp     bx,1
                adc     dl,dl                   ;bit 2

                mov     bx,[esi+6]
                sub     bx,ax
                cmp     bx,1
                adc     dl,dl                   ;bit 3

                mov     bx,[esi+8]
                sub     bx,ax
                cmp     bx,1
                adc     dl,dl                   ;bit 4

                mov     bx,[esi+10]
                sub     bx,ax
                cmp     bx,1
                adc     dl,dl                   ;bit 5

                mov     bx,[esi+12]
                sub     bx,ax
                cmp     bx,1
                adc     dl,dl                   ;bit 6

                mov     bx,[esi+14]
                sub     bx,ax
                cmp     bx,1
                adc     dl,dl                   ;bit 7

                add     esi,16                  ;advance the source
                ret

            Compute_Destination_Byte_From_32bpp:
                mov     ebx,[esi]
                sub     ebx,eax
                cmp     ebx,1
                adc     dl,dl                   ;bit 0

                mov     ebx,[esi+4]
                sub     ebx,eax
                cmp     ebx,1
                adc     dl,dl                   ;bit 1

                mov     ebx,[esi+8]
                sub     ebx,eax
                cmp     ebx,1
                adc     dl,dl                   ;bit 2

                mov     ebx,[esi+12]
                sub     ebx,eax
                cmp     ebx,1
                adc     dl,dl                   ;bit 3

                mov     ebx,[esi+16]
                sub     ebx,eax
                cmp     ebx,1
                adc     dl,dl                   ;bit 4

                mov     ebx,[esi+20]
                sub     ebx,eax
                cmp     ebx,1
                adc     dl,dl                   ;bit 5

                mov     ebx,[esi+24]
                sub     ebx,eax
                cmp     ebx,1
                adc     dl,dl                   ;bit 6

                mov     ebx,[esi+28]
                sub     ebx,eax
                cmp     ebx,1
                adc     dl,dl                   ;bit 7

                add     esi,32                  ;advance the source
                ret

            All_Done:
            }
        } while (cyToGo > 0);

        prcl++;
    } while (--c != 0);
}

#endif // i386

/******************************Public*Routine******************************\
* BOOL bMilPuntBlt
*
* Has GDI do any drawing operations that we don't specifically handle
* in the driver.
*
\**************************************************************************/

BOOL bMilPuntBlt(
SURFOBJ*    psoDst,
SURFOBJ*    psoSrc,
SURFOBJ*    psoMsk,
CLIPOBJ*    pco,
XLATEOBJ*   pxlo,
RECTL*      prclDst,
POINTL*     pptlSrc,
POINTL*     pptlMsk,
BRUSHOBJ*   pbo,
POINTL*     pptlBrush,
ROP4        rop4)
{
    PDEV*    ppdev;
    BOOL    b = FALSE;

    if (psoDst->dhpdev != NULL)
        ppdev = (PDEV*) psoDst->dhpdev;
    else
        ppdev = (PDEV*) psoSrc->dhpdev;

    #if DBG
    {
        //////////////////////////////////////////////////////////////////////
        // Diagnostics
        //
        // Since calling the engine to do any drawing can be rather painful,
        // particularly when the source is an off-screen DFB (since GDI will
        // have to allocate a DIB and call us to make a temporary copy before
        // it can even start drawing), we'll try to avoid it as much as
        // possible.
        //
        // Here we simply spew out information describing the blt whenever
        // this routine gets called (checked builds only, of course):

        ULONG ulClip;
        PDEV* ppdev;

        if (psoDst->dhpdev != NULL)
            ppdev = (PDEV*) psoDst->dhpdev;
        else
            ppdev = (PDEV*) psoSrc->dhpdev;

        ulClip = (pco == NULL) ? DC_TRIVIAL : pco->iDComplexity;

        DISPDBG((2, ">> Punt << Dst format: %li Dst type: %li Clip: %li Rop: %lx",
            psoDst->iBitmapFormat, psoDst->iType, ulClip, rop4));

        if (psoSrc != NULL)
        {
            DISPDBG((2, "        << Src format: %li Src type: %li",
                psoSrc->iBitmapFormat, psoSrc->iType));

            if (psoSrc->iBitmapFormat == BMF_1BPP)
            {
                DISPDBG((2, "        << Foreground: %lx  Background: %lx",
                    pxlo->pulXlate[1], pxlo->pulXlate[0]));
            }
        }

        if ((pxlo != NULL) && !(pxlo->flXlate & XO_TRIVIAL) && (psoSrc != NULL))
        {
            if (((psoSrc->dhsurf == NULL) &&
                 (psoSrc->iBitmapFormat != ppdev->iBitmapFormat)) ||
                ((psoDst->dhsurf == NULL) &&
                 (psoDst->iBitmapFormat != ppdev->iBitmapFormat)))
            {
                // Don't bother printing the 'xlate' message when the source
                // is a different bitmap format from the destination -- in
                // those cases we know there always has to be a translate.
            }
            else
            {
                DISPDBG((2, "        << With xlate"));
            }
        }

        // If the rop4 requires a pattern, and it's a non-solid brush...

        if (((((rop4 >> 4) ^ (rop4)) & 0x0f0f) != 0) &&
            (pbo->iSolidColor == -1))
        {
            if (pbo->pvRbrush == NULL)
                DISPDBG((2, "        << With brush -- Not created"));
            else
                DISPDBG((2, "        << With brush -- Created Ok"));
        }
    }
    #endif

    {
        //////////////////////////////////////////////////////////////////////
        // Linear Framebuffer punt
        //
        // This section of code handles a PuntBlt when GDI can directly draw
        // on the framebuffer.

        POINTL  ptlSrc;
        DSURF*  pdsurfDst;
        DSURF*  pdsurfSrc;
        OH*     pohSrc;
        OH*     pohDst;

        if (psoDst->dhsurf != NULL)
        {
            pdsurfDst       = (DSURF*) psoDst->dhsurf;
            psoDst          = ppdev->psoPunt;
            psoDst->pvScan0 = pdsurfDst->poh->pvScan0;
            psoDst->lDelta  = ppdev->lDelta;

            if (psoSrc != NULL)
            {
                pdsurfSrc = (DSURF*) psoSrc->dhsurf;
                if ((pdsurfSrc != NULL) &&
                    (pdsurfSrc != pdsurfDst))
                {
                    // If we're doing a BitBlt between different off-screen
                    // surfaces, we have to be sure to give GDI different
                    // surfaces, otherwise it may get confused when it has
                    // to do screen-to-screen blts with a translate...

                    pohSrc = pdsurfSrc->poh;
                    pohDst = pdsurfDst->poh;

                    psoSrc          = ppdev->psoPunt2;
                    psoSrc->pvScan0 = pohSrc->pvScan0;
                    psoSrc->lDelta  = ppdev->lDelta;

                    // Undo the source pointer adjustment we did earlier:

                    ptlSrc.x = pptlSrc->x + (pohDst->x - pohSrc->x);
                    ptlSrc.y = pptlSrc->y + (pohDst->y - pohSrc->y);
                    pptlSrc  = &ptlSrc;
                }
            }
        }
        else
        {
            ppdev           = (PDEV*)  psoSrc->dhpdev;
            pdsurfSrc       = (DSURF*) psoSrc->dhsurf;
            psoSrc          = ppdev->psoPunt;
            psoSrc->pvScan0 = pdsurfSrc->poh->pvScan0;
            psoSrc->lDelta  = ppdev->lDelta;
        }

        START_DIRECT_ACCESS_STORM_FOR_READ(ppdev, ppdev->pjBase);

        b = EngBitBlt(psoDst, psoSrc, psoMsk, pco, pxlo, prclDst, pptlSrc,
                         pptlMsk, pbo, pptlBrush, rop4);

        END_DIRECT_ACCESS_STORM(ppdev, ppdev->pjBase);
        return b;
    }
}

/******************************Public*Routine******************************\
* BOOL bMgaPuntBlt
*
* Has GDI do any drawing operations that we don't specifically handle
* in the driver.
*
\**************************************************************************/

BOOL bMgaPuntBlt(
SURFOBJ*    psoDst,
SURFOBJ*    psoSrc,
SURFOBJ*    psoMsk,
CLIPOBJ*    pco,
XLATEOBJ*   pxlo,
RECTL*      prclDst,
POINTL*     pptlSrc,
POINTL*     pptlMsk,
BRUSHOBJ*   pbo,
POINTL*     pptlBrush,
ROP4        rop4)
{
    PDEV*    ppdev;
    BOOL    b = FALSE;

    if (psoDst->dhpdev != NULL)
        ppdev = (PDEV*) psoDst->dhpdev;
    else
        ppdev = (PDEV*) psoSrc->dhpdev;

    #if DBG
    {
        //////////////////////////////////////////////////////////////////////
        // Diagnostics
        //
        // Since calling the engine to do any drawing can be rather painful,
        // particularly when the source is an off-screen DFB (since GDI will
        // have to allocate a DIB and call us to make a temporary copy before
        // it can even start drawing), we'll try to avoid it as much as
        // possible.
        //
        // Here we simply spew out information describing the blt whenever
        // this routine gets called (checked builds only, of course):

        ULONG ulClip;
        PDEV* ppdev;

        if (psoDst->dhpdev != NULL)
            ppdev = (PDEV*) psoDst->dhpdev;
        else
            ppdev = (PDEV*) psoSrc->dhpdev;

        ulClip = (pco == NULL) ? DC_TRIVIAL : pco->iDComplexity;

        DISPDBG((2, ">> Punt << Dst format: %li Dst type: %li Clip: %li Rop: %lx",
            psoDst->iBitmapFormat, psoDst->iType, ulClip, rop4));

        if (psoSrc != NULL)
        {
            DISPDBG((2, "        << Src format: %li Src type: %li",
                psoSrc->iBitmapFormat, psoSrc->iType));

            if (psoSrc->iBitmapFormat == BMF_1BPP)
            {
                DISPDBG((2, "        << Foreground: %lx  Background: %lx",
                    pxlo->pulXlate[1], pxlo->pulXlate[0]));
            }
        }

        if ((pxlo != NULL) && !(pxlo->flXlate & XO_TRIVIAL) && (psoSrc != NULL))
        {
            if (((psoSrc->dhsurf == NULL) &&
                 (psoSrc->iBitmapFormat != ppdev->iBitmapFormat)) ||
                ((psoDst->dhsurf == NULL) &&
                 (psoDst->iBitmapFormat != ppdev->iBitmapFormat)))
            {
                // Don't bother printing the 'xlate' message when the source
                // is a different bitmap format from the destination -- in
                // those cases we know there always has to be a translate.
            }
            else
            {
                DISPDBG((2, "        << With xlate"));
            }
        }

        // If the rop4 requires a pattern, and it's a non-solid brush...

        if (((((rop4 >> 4) ^ (rop4)) & 0x0f0f) != 0) &&
            (pbo->iSolidColor == -1))
        {
            if (pbo->pvRbrush == NULL)
                DISPDBG((2, "        << With brush -- Not created"));
            else
                DISPDBG((2, "        << With brush -- Created Ok"));
        }
    }
    #endif

    {
        //////////////////////////////////////////////////////////////////////
        // Really slow punt
        //
        // Here we handle a PuntBlt when GDI can't draw directly on the
        // framebuffer (as on the Alpha, which can't do it because of its
        // 32 bit bus).  If you thought the banked version was slow, just
        // look at this one.  Guaranteed, there will be at least one bitmap
        // allocation and extra copy involved; there could be two if it's a
        // screen-to-screen operation.

        POINTL  ptlSrc;
        RECTL   rclDst;
        SIZEL   sizl;
        BOOL    bSrcIsScreen;
        HSURF   hsurfSrc;
        RECTL   rclTmp;
        LONG    lDelta;
        BYTE*   pjBits;
        BYTE*   pjScan0;
        HSURF   hsurfDst;
        RECTL   rclScreen;

        rclDst = *prclDst;
        if (pptlSrc != NULL)
            ptlSrc = *pptlSrc;

        if ((pco != NULL) && (pco->iDComplexity != DC_TRIVIAL))
        {
            // We have to intersect the destination rectangle with
            // the clip bounds if there is one (consider the case
            // where the app asked to blt a really, really big
            // rectangle from the screen -- prclDst would be really,
            // really big but pco->rclBounds would be the actual
            // area of interest):

            rclDst.left   = max(rclDst.left,   pco->rclBounds.left);
            rclDst.top    = max(rclDst.top,    pco->rclBounds.top);
            rclDst.right  = min(rclDst.right,  pco->rclBounds.right);
            rclDst.bottom = min(rclDst.bottom, pco->rclBounds.bottom);

            if ((rclDst.left >= rclDst.right) ||
                (rclDst.top  >= rclDst.bottom))
            {
                // The entire draw operation was trivially rejected:

                return(TRUE);
            }

            ptlSrc.x += (rclDst.left - prclDst->left);
            ptlSrc.y += (rclDst.top  - prclDst->top);
        }

        sizl.cx = rclDst.right  - rclDst.left;
        sizl.cy = rclDst.bottom - rclDst.top;

        // We only need to make a copy from the screen if the source is
        // the screen, and the source is involved in the rop.  Note that
        // we have to check the rop before dereferencing 'psoSrc'
        // (because 'psoSrc' may be NULL if the source isn't involved):

        bSrcIsScreen = (((((rop4 >> 2) ^ (rop4)) & 0x3333) != 0) &&
                        (psoSrc->iType != STYPE_BITMAP));

        if (bSrcIsScreen)
        {
            // We need to create a copy of the source rectangle:

            hsurfSrc = (HSURF) EngCreateBitmap(sizl, 0, ppdev->iBitmapFormat,
                                               0, NULL);
            if (hsurfSrc == 0)
                goto Error_0;

            psoSrc = EngLockSurface(hsurfSrc);
            if (psoSrc == NULL)
                goto Error_1;

            rclTmp.left   = 0;
            rclTmp.top    = 0;
            rclTmp.right  = sizl.cx;
            rclTmp.bottom = sizl.cy;

            // vGetBits takes absolute coordinates for the source point:

            ptlSrc.x += ppdev->xOffset;
            ptlSrc.y += ppdev->yOffset;

            vGetBits(ppdev, psoSrc, &rclTmp, &ptlSrc);

            // The source will now come from (0, 0) of our temporary source
            // surface:

            ptlSrc.x = 0;
            ptlSrc.y = 0;
        }

        if (psoDst->iType == STYPE_BITMAP)
        {
            b = EngBitBlt(psoDst, psoSrc, psoMsk, pco, pxlo, &rclDst, &ptlSrc,
                          pptlMsk, pbo, pptlBrush, rop4);
        }
        else
        {
            // We need to create a temporary work buffer.  We have to do
            // some fudging with the offsets so that the upper-left corner
            // of the (relative coordinates) clip object bounds passed to
            // GDI will be transformed to the upper-left corner of our
            // temporary bitmap.

            // The alignment doesn't have to be as tight as this at 16bpp
            // and 32bpp, but it won't hurt:

            lDelta = (((rclDst.right + 3) & ~3L) - (rclDst.left & ~3L))
                   * ppdev->cjPelSize;

            // We're actually only allocating a bitmap that is 'sizl.cx' x
            // 'sizl.cy' in size:

            pjBits = EngAllocMem(0, lDelta * sizl.cy, ALLOC_TAG);
            if (pjBits == NULL)
                goto Error_2;

            // We now adjust the surface's 'pvScan0' so that when GDI thinks
            // it's writing to pixel (rclDst.top, rclDst.left), it will
            // actually be writing to the upper-left pixel of our temporary
            // bitmap:

            pjScan0 = pjBits - (rclDst.top * lDelta)
                             - ((rclDst.left & ~3L) * ppdev->cjPelSize);

            ASSERTDD((((ULONG_PTR) pjScan0) & 3) == 0,
                    "pvScan0 must be dword aligned!");

            // The checked build of GDI sometimes checks on blts that
            // prclDst->right <= pso->sizl.cx, so we lie to it about
            // the size of our bitmap:

            sizl.cx = rclDst.right;
            sizl.cy = rclDst.bottom;

            hsurfDst = (HSURF) EngCreateBitmap(
                        sizl,                   // Bitmap covers rectangle
                        lDelta,                 // Use this delta
                        ppdev->iBitmapFormat,   // Same colour depth
                        BMF_TOPDOWN,            // Must have a positive delta
                        pjScan0);               // Where (0, 0) would be

            if ((hsurfDst == 0) ||
                (!EngAssociateSurface(hsurfDst, ppdev->hdevEng, 0)))
                goto Error_3;

            psoDst = EngLockSurface(hsurfDst);
            if (psoDst == NULL)
                goto Error_4;

            // Make sure that the rectangle we Get/Put from/to the screen
            // is in absolute coordinates:

            rclScreen.left   = rclDst.left   + ppdev->xOffset;
            rclScreen.right  = rclDst.right  + ppdev->xOffset;
            rclScreen.top    = rclDst.top    + ppdev->yOffset;
            rclScreen.bottom = rclDst.bottom + ppdev->yOffset;

            // It would be nice to get a copy of the destination rectangle
            // only when the ROP involves the destination (or when the source
            // is an RLE), but we can't do that.  If the brush is truly NULL,
            // GDI will immediately return TRUE from EngBitBlt, without
            // modifying the temporary bitmap -- and we would proceed to
            // copy the uninitialized temporary bitmap back to the screen.
            //
            // So SRCCOPY is one of the few things we don't read the screen
            // for, and even then only if there's not complex clipping
            // (because complex clipping would leave some parts of the
            // temporary bitmap as uninitialized pixels, which we would copy
            // back to the screen):

            if ((rop4 != 0xcccc) ||
                (psoSrc->iBitmapFormat > BMF_32BPP) ||
                ((pco != NULL) && (pco->iDComplexity == DC_COMPLEX)))
            {
                vGetBits(ppdev, psoDst, &rclDst, (POINTL*) &rclScreen);
            }

            b = EngBitBlt(psoDst, psoSrc, psoMsk, pco, pxlo, &rclDst, &ptlSrc,
                          pptlMsk, pbo, pptlBrush, rop4);

            vPutBits(ppdev, psoDst, &rclScreen, (POINTL*) &rclDst);

            EngUnlockSurface(psoDst);

        Error_4:

            EngDeleteSurface(hsurfDst);

        Error_3:

            EngFreeMem(pjBits);
        }

        Error_2:

        if (bSrcIsScreen)
        {
            EngUnlockSurface(psoSrc);

        Error_1:

            EngDeleteSurface(hsurfSrc);
        }

        Error_0:

        return(b);
    }
}

/******************************Public*Routine******************************\
* VOID vXferNativeSrccopy
*
* Does a SRCCOPY transfer of a bitmap to the screen using the frame
* buffer, because on the Millennium it's faster than using the data transfer
* register.
*
\**************************************************************************/

VOID vXferNativeSrccopy(        // Type FNXFER
PDEV*       ppdev,
LONG        c,                  // Count of rectangles, can't be zero
RECTL*      prcl,               // List of destination rectangles, in relative
                                //   coordinates
ULONG       rop4,               // Not used
SURFOBJ*    psoSrc,             // Source surface
POINTL*     pptlSrc,            // Original unclipped source point
RECTL*      prclDst,            // Original unclipped destination rectangle
XLATEOBJ*   pxlo)               // Not used
{
    LONG    xOffset;
    LONG    yOffset;
    LONG    dx;
    LONG    dy;
    RECTL   rclDst;
    POINTL  ptlSrc;

    ASSERTDD((pxlo == NULL) || (pxlo->flXlate & XO_TRIVIAL),
            "Can handle trivial xlate only");
    ASSERTDD(psoSrc->iBitmapFormat == ppdev->iBitmapFormat,
            "Source must be same colour depth as screen");
    ASSERTDD(c > 0, "Can't handle zero rectangles");
    ASSERTDD(rop4 == 0xcccc, "Must be a SRCCOPY rop");

    xOffset = ppdev->xOffset;
    yOffset = ppdev->yOffset;

    dx = pptlSrc->x - prclDst->left;
    dy = pptlSrc->y - prclDst->top;     // Add to destination to get source

    while (TRUE)
    {
        ptlSrc.x      = prcl->left   + dx;
        ptlSrc.y      = prcl->top    + dy;

        // 'vPutBits' takes only absolute coordinates, so add in the
        // off-screen bitmap offset here:

        rclDst.left   = prcl->left   + xOffset;
        rclDst.right  = prcl->right  + xOffset;
        rclDst.top    = prcl->top    + yOffset;
        rclDst.bottom = prcl->bottom + yOffset;

        vPutBits(ppdev, psoSrc, &rclDst, &ptlSrc);

        if (--c == 0)
            return;

        prcl++;
    }
}

/******************************Public*Routine******************************\
* BOOL DrvBitBlt
*
* Implements the workhorse routine of a display driver.
*
\**************************************************************************/

BOOL DrvBitBlt(
SURFOBJ*    psoDst,
SURFOBJ*    psoSrc,
SURFOBJ*    psoMsk,
CLIPOBJ*    pco,
XLATEOBJ*   pxlo,
RECTL*      prclDst,
POINTL*     pptlSrc,
POINTL*     pptlMsk,
BRUSHOBJ*   pbo,
POINTL*     pptlBrush,
ROP4        rop4)
{
    PDEV*           ppdev;
    DSURF*          pdsurfDst;
    DSURF*          pdsurfSrc;
    POINTL          ptlSrc;
    BYTE            jClip;
    OH*             poh;
    BOOL            bMore;
    CLIPENUM        ce;
    LONG            c;
    RECTL           rcl;
    BYTE            rop3;
    FNFILL*         pfnFill;
    RBRUSH_COLOR    rbc;        // Realized brush or solid colour
    FNXFER*         pfnXfer;
    ULONG           iSrcBitmapFormat;
    ULONG           iDir;
    BOOL            bRet;
    XLATEOBJ        xloTmp;
    ULONG           aulTmp[2];

    bRet = TRUE;                // Assume success

    pdsurfDst = (DSURF*) psoDst->dhsurf;    // May be NULL

    if (gbPuntBitBlt)
    {
        goto Setup_Surfaces;
    }

    if (psoSrc == NULL)
    {
        ///////////////////////////////////////////////////////////////////
        // Fills
        ///////////////////////////////////////////////////////////////////

        // Fills are this function's "raison d'etre", so we handle them
        // as quickly as possible:

        ASSERTDD(pdsurfDst != NULL,
                 "Expect only device destinations when no source");

        if (pdsurfDst->dt == DT_SCREEN)
        {
            ppdev = (PDEV*) psoDst->dhpdev;

            poh = pdsurfDst->poh;
            ppdev->xOffset = poh->x;
            ppdev->yOffset = poh->y;

            // Make sure it doesn't involve a mask (i.e., it's really a
            // Rop3):

            rop3 = (BYTE) rop4;

            if ((BYTE) (rop4 >> 8) == rop3)
            {
                // Since 'psoSrc' is NULL, the rop3 had better not indicate
                // that we need a source.

                ASSERTDD((((rop4 >> 2) ^ (rop4)) & 0x33) == 0,
                         "Need source but GDI gave us a NULL 'psoSrc'");

            Fill_It:

                pfnFill = ppdev->pfnFillSolid;   // Default to solid fill

                if ((((rop3 >> 4) ^ (rop3)) & 0xf) != 0)
                {
                    // The rop says that a pattern is truly required
                    // (blackness, for instance, doesn't need one):

                    rbc.iSolidColor = pbo->iSolidColor;
                    if (rbc.iSolidColor == -1)
                    {
                        // Try and realize the pattern brush; by doing
                        // this call-back, GDI will eventually call us
                        // again through DrvRealizeBrush:

                        rbc.prb = pbo->pvRbrush;
                        if (rbc.prb == NULL)
                        {
                            rbc.prb = BRUSHOBJ_pvGetRbrush(pbo);
                            if (rbc.prb == NULL)
                            {
                                // If we couldn't realize the brush, punt
                                // the call (it may have been a non 8x8
                                // brush or something, which we can't be
                                // bothered to handle, so let GDI do the
                                // drawing):

                                goto Punt_It;
                            }
                        }
                        pfnFill = rbc.prb->pfnFillPat;
                    }
                }

                // Note that these 2 'if's are more efficient than
                // a switch statement:

                if ((pco == NULL) || (pco->iDComplexity == DC_TRIVIAL))
                {
                    pfnFill(ppdev, 1, prclDst, rop4, rbc, pptlBrush);
                    goto All_Done;
                }
                else if (pco->iDComplexity == DC_RECT)
                {
                    if (bIntersect(prclDst, &pco->rclBounds, &rcl))
                        pfnFill(ppdev, 1, &rcl, rop4, rbc, pptlBrush);
                    goto All_Done;
                }
                else
                {
                    CLIPOBJ_cEnumStart(pco, FALSE, CT_RECTANGLES, CD_ANY, 0);

                    do {
                        bMore = CLIPOBJ_bEnum(pco, sizeof(ce), (ULONG*) &ce);

                        c = cIntersect(prclDst, ce.arcl, ce.c);

                        if (c != 0)
                            pfnFill(ppdev, c, ce.arcl, rop4, rbc, pptlBrush);

                    } while (bMore);
                    goto All_Done;
                }
            }
        }
    }

Setup_Surfaces:

    jClip = (pco == NULL) ? DC_TRIVIAL : pco->iDComplexity;

    if ((psoSrc != NULL) && (psoSrc->dhsurf != NULL))
    {
        pdsurfSrc = (DSURF*) psoSrc->dhsurf;
        if (pdsurfSrc->dt == DT_DIB)
        {
            // Here we consider putting a DIB DFB back into off-screen
            // memory.  If there's a translate, it's probably not worth
            // moving since we won't be able to use the hardware to do
            // the blt (a similar argument could be made for weird rops
            // and stuff that we'll only end up having GDI simulate, but
            // those should happen infrequently enough that I don't care).

            if ((pxlo == NULL) || (pxlo->flXlate & XO_TRIVIAL))
            {
                ppdev = (PDEV*) psoSrc->dhpdev;

                // See 'DrvCopyBits' for some more comments on how this
                // moving-it-back-into-off-screen-memory thing works:

                if (pdsurfSrc->iUniq == ppdev->iHeapUniq)
                {
                    if (--pdsurfSrc->cBlt == 0)
                    {
                        if (bMoveDibToOffscreenDfbIfRoom(ppdev, pdsurfSrc))
                            goto Continue_It;
                    }
                }
                else
                {
                    // Some space was freed up in off-screen memory,
                    // so reset the counter for this DFB:

                    pdsurfSrc->iUniq = ppdev->iHeapUniq;
                    pdsurfSrc->cBlt  = HEAP_COUNT_DOWN;
                }
            }

            psoSrc = pdsurfSrc->pso;

            // Handle the case where the source is a DIB DFB and the
            // destination is a regular bitmap:

            if (psoDst->dhsurf == NULL)
                goto EngBitBlt_It;

        }
    }

Continue_It:

    if (pdsurfDst != NULL)
    {
        if (pdsurfDst->dt == DT_DIB)
        {
            psoDst = pdsurfDst->pso;

            // If the destination is a DIB, we can only handle this
            // call if the source is not a DIB:

            if ((psoSrc == NULL) || (psoSrc->dhsurf == NULL))
                goto EngBitBlt_It;
        }
    }

    // At this point, we know that either the source or the destination is
    // not a DIB.  Check for a DFB to screen, DFB to DFB, or screen to DFB
    // case:

    if ((psoSrc != NULL) &&
        (psoDst->dhsurf != NULL) &&
        (psoSrc->dhsurf != NULL))
    {
        pdsurfSrc = (DSURF*) psoSrc->dhsurf;
        pdsurfDst = (DSURF*) psoDst->dhsurf;

        ASSERTDD(pdsurfSrc->dt == DT_SCREEN, "Expected screen source");
        ASSERTDD(pdsurfDst->dt == DT_SCREEN, "Expected screen destination");

        ptlSrc.x = pptlSrc->x - (pdsurfDst->poh->x - pdsurfSrc->poh->x);
        ptlSrc.y = pptlSrc->y - (pdsurfDst->poh->y - pdsurfSrc->poh->y);

        pptlSrc  = &ptlSrc;
    }

    if (psoDst->dhsurf != NULL)
    {
        pdsurfDst = (DSURF*) psoDst->dhsurf;
        ppdev     = (PDEV*)  psoDst->dhpdev;

        ppdev->xOffset = pdsurfDst->poh->x;
        ppdev->yOffset = pdsurfDst->poh->y;
    }
    else
    {
        pdsurfSrc = (DSURF*) psoSrc->dhsurf;
        ppdev     = (PDEV*)  psoSrc->dhpdev;

        ppdev->xOffset = pdsurfSrc->poh->x;
        ppdev->yOffset = pdsurfSrc->poh->y;
    }

    if (gbPuntBitBlt)
    {
        goto Punt_It;
    }

    if (((rop4 >> 8) & 0xff) == (rop4 & 0xff))
    {
        // Since we've already handled the cases where the ROP4 is really
        // a ROP3 and no source is required, we can assert...

        ASSERTDD((psoSrc != NULL) && (pptlSrc != NULL),
                 "Expected no-source case to already have been handled");

        ///////////////////////////////////////////////////////////////////
        // Bitmap transfers
        ///////////////////////////////////////////////////////////////////

        // Since the foreground and background ROPs are the same, we
        // don't have to worry about no stinking masks (it's a simple
        // Rop3).

        rop3 = (BYTE) rop4;     // Make it into a Rop3 (we keep the rop4
                                //  around in case we decide to punt)

        if (psoDst->dhsurf != NULL)
        {
            // The destination is the screen:

            if ((rop3 >> 4) == (rop3 & 0xf))
            {
                // The ROP3 doesn't require a pattern:

                if (psoSrc->dhsurf == NULL)
                {
                    //////////////////////////////////////////////////
                    // DIB-to-screen blt

                    iSrcBitmapFormat = psoSrc->iBitmapFormat;
                    if (iSrcBitmapFormat == BMF_1BPP)
                    {
                        pfnXfer = ppdev->pfnXfer1bpp;
                        goto Xfer_It;
                    }
                    else if ((iSrcBitmapFormat == ppdev->iBitmapFormat) &&
                             ((pxlo == NULL) || (pxlo->flXlate & XO_TRIVIAL)))
                    {
                        pfnXfer = (rop4 == 0xcccc) ? vXferNativeSrccopy : vXferNative;
                        goto Xfer_It;
                    }

                    // It's faster to use the frame buffer than the transfer
                    // register when the ROP is SRCCOPY, particularly with
                    // USWC enabled.  So it's faster to call 'bPuntBlt' and
                    // have GDI do the drawing directly to the frame buffer
                    // for those cases:

                    else if ((ppdev->ulBoardId != MGA_STORM) ||
                             (rop3 != 0xCC))
                    {
                        if (iSrcBitmapFormat == BMF_4BPP)
                        {
                            pfnXfer = vXfer4bpp;
                            goto Xfer_It;
                        }
                        else if (iSrcBitmapFormat == BMF_8BPP)
                        {
                            pfnXfer = vXfer8bpp;
                            goto Xfer_It;
                        }
                    }
                }
                else // psoSrc->dhsurf != NULL
                {
                    if ((pxlo == NULL) || (pxlo->flXlate & XO_TRIVIAL))
                    {
                        //////////////////////////////////////////////////
                        // Screen-to-screen blt with no translate

                        if (jClip == DC_TRIVIAL)
                        {
                            ppdev->pfnCopyBlt(ppdev, 1, prclDst, rop4, pptlSrc, prclDst);
                            goto All_Done;
                        }
                        else if (jClip == DC_RECT)
                        {
                            if (bIntersect(prclDst, &pco->rclBounds, &rcl))
                            {
                                ppdev->pfnCopyBlt(ppdev, 1, &rcl, rop4, pptlSrc, prclDst);
                            }
                            goto All_Done;
                        }
                        else
                        {
                            // Don't forget that we'll have to draw the
                            // rectangles in the correct direction:

                            if (pptlSrc->y >= prclDst->top)
                            {
                                if (pptlSrc->x >= prclDst->left)
                                    iDir = CD_RIGHTDOWN;
                                else
                                    iDir = CD_LEFTDOWN;
                            }
                            else
                            {
                                if (pptlSrc->x >= prclDst->left)
                                    iDir = CD_RIGHTUP;
                                else
                                    iDir = CD_LEFTUP;
                            }

                            CLIPOBJ_cEnumStart(pco, FALSE, CT_RECTANGLES,
                                               iDir, 0);

                            do {
                                bMore = CLIPOBJ_bEnum(pco, sizeof(ce),
                                                      (ULONG*) &ce);

                                c = cIntersect(prclDst, ce.arcl, ce.c);

                                if (c != 0)
                                {
                                    ppdev->pfnCopyBlt(ppdev, c, ce.arcl, rop4, pptlSrc,
                                             prclDst);
                                }

                            } while (bMore);
                            goto All_Done;
                        }
                    }
                }
            }
            else if (((rop3 == 0xb8) || (rop3 == 0xe2)) &&
                     (pbo->iSolidColor != (ULONG) -1) &&
                     (psoSrc->iBitmapFormat == BMF_1BPP) &&
                     (pxlo->pulXlate[0] == 0) &&
                     ((pxlo->pulXlate[1] & ppdev->ulWhite) == ppdev->ulWhite))
            {
                // When the background and foreground colors are black and
                // white, respectively, and the ROP is 0xb8 or 0xe2, and
                // the source bitmap is monochrome, the blt is simply a
                // color expanding monochrome blt.

                pfnXfer = ppdev->pfnXfer1bpp;

                // Rather than add another parameter to 'pfnXfer', we simply
                // overload the 'pxlo' pointer.  Note that we still have to
                // special-case 0xb8 and 0xe2 in our 'pfnXfer1bpp' routine
                // to handle this convention:

                pxlo = &xloTmp;
                xloTmp.pulXlate = aulTmp;
                aulTmp[0] = pbo->iSolidColor;
                aulTmp[1] = pbo->iSolidColor;

                goto Xfer_It;
            }
        }
        else
        {
            #if defined(i386)
            {
                // We special case screen to monochrome blts because they
                // happen fairly often.  We only handle SRCCOPY rops and
                // monochrome destinations (to handle a true 1bpp DIB
                // destination, we would have to do near-colour searches
                // on every colour; as it is, the foreground colour gets
                // mapped to '1', and everything else gets mapped to '0'):

                if ((psoDst->iBitmapFormat == BMF_1BPP) &&
                    (rop3 == 0xcc) &&
                    (pxlo->flXlate & XO_TO_MONO) &&
                    (ppdev->iBitmapFormat != BMF_24BPP))
                {
                    pfnXfer = vXferScreenTo1bpp;
                    psoSrc  = psoDst;               // A misnomer, I admit
                    goto Xfer_It;
                }
            }
            #endif // i386
        }
    }

    else if ((psoMsk == NULL) && (rop4 == 0xaacc))
    {
        // The only time GDI will ask us to do a true rop4 using the brush
        // mask is when the brush is 1bpp, and the background rop is AA
        // (meaning it's a NOP):

        rop3 = (BYTE) rop4;

        goto Fill_It;
    }

    // Just fall through to Punt_It...

Punt_It:

    bRet = ppdev->pfnPuntBlt(psoDst,
                             psoSrc,
                             psoMsk,
                             pco,
                             pxlo,
                             prclDst,
                             pptlSrc,
                             pptlMsk,
                             pbo,
                             pptlBrush,
                             rop4);
    goto All_Done;

//////////////////////////////////////////////////////////////////////
// Common bitmap transfer

Xfer_It:
    if (jClip == DC_TRIVIAL)
    {
        pfnXfer(ppdev, 1, prclDst, rop4, psoSrc, pptlSrc, prclDst, pxlo);
        goto All_Done;
    }
    else if (jClip == DC_RECT)
    {
        if (bIntersect(prclDst, &pco->rclBounds, &rcl))
            pfnXfer(ppdev, 1, &rcl, rop4, psoSrc, pptlSrc, prclDst, pxlo);
        goto All_Done;
    }
    else
    {
        CLIPOBJ_cEnumStart(pco, FALSE, CT_RECTANGLES,
                           CD_ANY, 0);

        do {
            bMore = CLIPOBJ_bEnum(pco, sizeof(ce),
                                  (ULONG*) &ce);

            c = cIntersect(prclDst, ce.arcl, ce.c);

            if (c != 0)
            {
                pfnXfer(ppdev, c, ce.arcl, rop4, psoSrc,
                        pptlSrc, prclDst, pxlo);
            }

        } while (bMore);
        goto All_Done;
    }

////////////////////////////////////////////////////////////////////////
// Common DIB blt

EngBitBlt_It:

    // Our driver doesn't handle any blt's between two DIBs.  Normally
    // a driver doesn't have to worry about this, but we do because
    // we have DFBs that may get moved from off-screen memory to a DIB,
    // where we have GDI do all the drawing.  GDI does DIB drawing at
    // a reasonable speed (unless one of the surfaces is a device-
    // managed surface...)
    //
    // If either the source or destination surface in an EngBitBlt
    // call-back is a device-managed surface (meaning it's not a DIB
    // that GDI can draw with), GDI will automatically allocate memory
    // and call the driver's DrvCopyBits routine to create a DIB copy
    // that it can use.  So this means that this could handle all 'punts',
    // and we could conceivably get rid of bPuntBlt.  But this would have
    // a bad performance impact because of the extra memory allocations
    // and bitmap copies -- you really don't want to do this unless you
    // have to (or your surface was created such that GDI can draw
    // directly onto it) -- I've been burned by this because it's not
    // obvious that the performance impact is so bad.
    //
    // That being said, we only call EngBitBlt when all the surfaces
    // are DIBs:

    bRet = EngBitBlt(psoDst, psoSrc, psoMsk, pco, pxlo, prclDst,
                     pptlSrc, pptlMsk, pbo, pptlBrush, rop4);

All_Done:
    return(bRet);
}

/******************************Public*Routine******************************\
* BOOL DrvCopyBits
*
* Do fast bitmap copies.
*
* Note that GDI will (usually) automatically adjust the blt extents to
* adjust for any rectangular clipping, so we'll rarely see DC_RECT
* clipping in this routine (and as such, we don't bother special casing
* it).
*
* I'm not sure if the performance benefit from this routine is actually
* worth the increase in code size, since SRCCOPY BitBlts are hardly the
* most common drawing operation we'll get.  But what the heck.
*
\**************************************************************************/

BOOL DrvCopyBits(
SURFOBJ*  psoDst,
SURFOBJ*  psoSrc,
CLIPOBJ*  pco,
XLATEOBJ* pxlo,
RECTL*    prclDst,
POINTL*   pptlSrc)
{
    PDEV*   ppdev;
    DSURF*  pdsurfSrc;
    DSURF*  pdsurfDst;
    RECTL   rcl;
    POINTL  ptl;
    OH*     pohSrc;
    OH*     pohDst;

    if (gbPuntCopyBits)
    {
        return(DrvBitBlt(psoDst, psoSrc, NULL, pco, pxlo, prclDst, pptlSrc, NULL,
                         NULL, NULL, 0xcccc));
    }

    // DrvCopyBits is a fast-path for SRCCOPY blts.  But it can still be
    // pretty complicated: there can be translates, clipping, RLEs,
    // bitmaps that aren't the same format as the screen, plus
    // screen-to-screen, DIB-to-screen or screen-to-DIB operations,
    // not to mention DFBs (device format bitmaps).
    //
    // Rather than making this routine almost as big as DrvBitBlt, I'll
    // handle here only the speed-critical cases, and punt the rest to
    // our DrvBitBlt routine.
    //
    // We'll try to handle anything that doesn't involve clipping:

    if (((pco  == NULL) || (pco->iDComplexity == DC_TRIVIAL)) &&
        ((pxlo == NULL) || (pxlo->flXlate & XO_TRIVIAL)))
    {
        if (psoDst->dhsurf != NULL)
        {
            // We know the destination is either a DFB or the screen:

            ppdev     = (PDEV*)  psoDst->dhpdev;
            pdsurfDst = (DSURF*) psoDst->dhsurf;

            // See if the source is a plain DIB:

            if (psoSrc->dhsurf != NULL)
            {
                pdsurfSrc = (DSURF*) psoSrc->dhsurf;

                // Make sure the destination is really the screen or an
                // off-screen DFB (i.e., not a DFB that we've converted
                // to a DIB):

                if (pdsurfDst->dt == DT_SCREEN)
                {
                    ASSERTDD(psoSrc->dhsurf != NULL, "Can't be a DIB");

                    if (pdsurfSrc->dt == DT_SCREEN)
                    {

                    Screen_To_Screen:

                        //////////////////////////////////////////////////////
                        // Screen-to-screen

                        ASSERTDD((psoSrc->dhsurf != NULL)        &&
                                 (pdsurfSrc->dt == DT_SCREEN)    &&
                                 (psoDst->dhsurf != NULL)        &&
                                 (pdsurfDst->dt == DT_SCREEN),
                                 "Should be a screen-to-screen case");

                        // vCopyBlt takes relative coordinates (relative
                        // to the destination surface, that is), so we have
                        // to change the start point to be relative to the
                        // destination surface too:

                        pohSrc = pdsurfSrc->poh;
                        pohDst = pdsurfDst->poh;

                        ptl.x = pptlSrc->x - (pohDst->x - pohSrc->x);
                        ptl.y = pptlSrc->y - (pohDst->y - pohSrc->y);

                        ppdev->xOffset = pohDst->x;
                        ppdev->yOffset = pohDst->y;

                        ppdev->pfnCopyBlt(ppdev, 1, prclDst, 0xCCCC, &ptl, prclDst);
                        return(TRUE);
                    }
                    else // (pdsurfSrc->dt != DT_SCREEN)
                    {
                        // Ah ha, the source is a DFB that's really a DIB.

                        ASSERTDD(psoDst->dhsurf != NULL,
                                "Destination can't be a DIB here");

                        /////////////////////////////////////////////////////
                        // Put It Back Into Off-screen?
                        //
                        // We take this opportunity to decide if we want to
                        // put the DIB back into off-screen memory.  This is
                        // a pretty good place to do it because we have to
                        // copy the bits to some portion of the screen,
                        // anyway.  So we would incur only an extra screen-to-
                        // screen blt at this time, much of which will be
                        // over-lapped with the CPU.
                        //
                        // The simple approach we have taken is to move a DIB
                        // back into off-screen memory only if there's already
                        // room -- we won't throw stuff out to make space
                        // (because it's tough to know what ones to throw out,
                        // and it's easy to get into thrashing scenarios).
                        //
                        // Because it takes some time to see if there's room
                        // in off-screen memory, we only check one in
                        // HEAP_COUNT_DOWN times if there's room.  To bias
                        // in favour of bitmaps that are often blt, the
                        // counters are reset every time any space is freed
                        // up in off-screen memory.  We also don't bother
                        // checking if no space has been freed since the
                        // last time we checked for this DIB.

                        if (pdsurfSrc->iUniq == ppdev->iHeapUniq)
                        {
                            if (--pdsurfSrc->cBlt == 0)
                            {
                                if (bMoveDibToOffscreenDfbIfRoom(ppdev,
                                                                 pdsurfSrc))
                                    goto Screen_To_Screen;
                            }
                        }
                        else
                        {
                            // Some space was freed up in off-screen memory,
                            // so reset the counter for this DFB:

                            pdsurfSrc->iUniq = ppdev->iHeapUniq;
                            pdsurfSrc->cBlt  = HEAP_COUNT_DOWN;
                        }

                        // Since the destination is definitely the screen,
                        // we don't have to worry about creating a DIB to
                        // DIB copy case (for which we would have to call
                        // EngCopyBits):

                        psoSrc = pdsurfSrc->pso;

                        goto DIB_To_Screen;
                    }
                }
                else // (pdsurfDst->dt != DT_SCREEN)
                {
                    // Because the source is not a DIB, we don't have to
                    // worry about creating a DIB to DIB case here (although
                    // we'll have to check later to see if the source is
                    // really a DIB that's masquerading as a DFB...)

                    ASSERTDD(psoSrc->dhsurf != NULL,
                             "Source can't be a DIB here");

                    psoDst = pdsurfDst->pso;

                    goto Screen_To_DIB;
                }
            }
            else if (psoSrc->iBitmapFormat == ppdev->iBitmapFormat)
            {
                // Make sure the destination is really the screen:

                if (pdsurfDst->dt == DT_SCREEN)
                {

                DIB_To_Screen:

                    //////////////////////////////////////////////////////
                    // DIB-to-screen

                    ASSERTDD((psoDst->dhsurf != NULL)        &&
                             (pdsurfDst->dt == DT_SCREEN)    &&
                             (psoSrc->dhsurf == NULL)        &&
                             (psoSrc->iBitmapFormat == ppdev->iBitmapFormat),
                             "Should be a DIB-to-screen case");

                    pohDst = pdsurfDst->poh;

                    // vPutBits takes absolute screen coordinates, so we have
                    // to muck with the destination rectangle:

                    rcl.left    = prclDst->left + pohDst->x;
                    rcl.top     = prclDst->top + pohDst->y;
                    rcl.right   = prclDst->right + pohDst->x;
                    rcl.bottom  = prclDst->bottom + pohDst->y;

                    vPutBits(ppdev, psoSrc, &rcl, pptlSrc);

                    return(TRUE);
                }
            }
        }
        else // (psoDst->dhsurf == NULL)
        {

        Screen_To_DIB:

            pdsurfSrc = (DSURF*) psoSrc->dhsurf;
            ppdev     = (PDEV*)  psoSrc->dhpdev;

            if (psoDst->iBitmapFormat == ppdev->iBitmapFormat)
            {
                if (pdsurfSrc->dt == DT_SCREEN)
                {
                    //////////////////////////////////////////////////////
                    // Screen-to-DIB

                    ASSERTDD((psoSrc->dhsurf != NULL)        &&
                             (pdsurfSrc->dt == DT_SCREEN)    &&
                             (psoDst->dhsurf == NULL)        &&
                             (psoDst->iBitmapFormat == ppdev->iBitmapFormat),
                             "Should be a screen-to-DIB case");

                    // vGetBits takes absolute screen coordinates, so we have
                    // to muck with the source point:

                    pohSrc = pdsurfSrc->poh;

                    ptl.x = pptlSrc->x + pohSrc->x;
                    ptl.y = pptlSrc->y + pohSrc->y;

                    vGetBits(ppdev, psoDst, prclDst, &ptl);
                    return(TRUE);
                }
                else
                {
                    // The source is a DFB that's really a DIB.  Since we
                    // know that the destination is a DIB, we've got a DIB
                    // to DIB operation, and should call EngCopyBits:

                    psoSrc = pdsurfSrc->pso;
                    goto EngCopyBits_It;
                }
            }
        }
    }

    // We can't call DrvBitBlt if we've accidentally converted both
    // surfaces to DIBs, because it isn't equipped to handle it:

    ASSERTDD((psoSrc->dhsurf != NULL) ||
             (psoDst->dhsurf != NULL),
             "Accidentally converted both surfaces to DIBs");

    /////////////////////////////////////////////////////////////////
    // A DrvCopyBits is after all just a simplified DrvBitBlt:

    return(DrvBitBlt(psoDst, psoSrc, NULL, pco, pxlo, prclDst, pptlSrc, NULL,
                     NULL, NULL, 0x0000CCCC));

EngCopyBits_It:

    ASSERTDD((psoDst->dhsurf == NULL) &&
             (psoSrc->dhsurf == NULL),
             "Both surfaces should be DIBs to call EngCopyBits");

    return(EngCopyBits(psoDst, psoSrc, pco, pxlo, prclDst, pptlSrc));
}
