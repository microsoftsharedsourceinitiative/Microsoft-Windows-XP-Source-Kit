// Copyright (c) 1998 - 1999 Microsoft Corporation

#include <windows.h>
#include <winbase.h>

/* -------------------------------------------------------------
   Note that the ValidateProductSuite() and IsTerminalServices()
   APIs use ANSI versions of functions in order to maintain
   compatibility with Win9X platforms.
   ------------------------------------------------------------- */

#ifndef UNREFERENCED_PARAMETER
#define UNREFERENCED_PARAMETER(P)          (P)
#endif

#define OLD_VER_SET_CONDITION(_m_,_t_,_c_)  _m_=(_m_|(_c_<<(1<<_t_)))

BOOL ValidateProductSuite (LPSTR SuiteName)
{
    BOOL rVal = FALSE;
    LONG Rslt;
    HKEY hKey = NULL;
    DWORD Type = 0;
    DWORD Size = 0;
    LPSTR ProductSuite = NULL;
    LPSTR p;

    Rslt = RegOpenKeyA(
        HKEY_LOCAL_MACHINE,
        "System\\CurrentControlSet\\Control\\ProductOptions",
        &hKey
        );

    if (Rslt != ERROR_SUCCESS)
        goto exit;

    Rslt = RegQueryValueExA( hKey, "ProductSuite", NULL, &Type, NULL, &Size );
    if (Rslt != ERROR_SUCCESS || !Size)
        goto exit;

    ProductSuite = (LPSTR) LocalAlloc( LPTR, Size );
    if (!ProductSuite)
        goto exit;

    Rslt = RegQueryValueExA( hKey, "ProductSuite", NULL, &Type,
        (LPBYTE) ProductSuite, &Size );
     if (Rslt != ERROR_SUCCESS || Type != REG_MULTI_SZ)
        goto exit;

    p = ProductSuite;
    while (*p)
    {
        if (lstrcmpA( p, SuiteName ) == 0)
        {
            rVal = TRUE;
            break;
        }
        p += (lstrlenA( p ) + 1);
    }

exit:
    if (ProductSuite)
        LocalFree( ProductSuite );

    if (hKey)
        RegCloseKey( hKey );

    return rVal;
}


BOOL IsTerminalServicesEnabled( VOID )
{
    BOOL    bResult = FALSE;
    DWORD   dwVersion;
    OSVERSIONINFOEXA osVersionInfo;
    DWORDLONG dwlConditionMask = 0;
    HMODULE hmodK32 = NULL;
    typedef ULONGLONG (*PFnVerSetConditionMask) ( ULONGLONG, ULONG, UCHAR );
    typedef BOOL      (*PFnVerifyVersionInfoA) (POSVERSIONINFOEXA, DWORD, DWORDLONG);
    PFnVerSetConditionMask pfnVerSetConditionMask;
    PFnVerifyVersionInfoA pfnVerifyVersionInfoA;


    dwVersion = GetVersion();

    /* are we running NT ? */
    if (!(dwVersion & 0x80000000))
    {
        // Is it NT 50 or greater ?
        if (LOBYTE(LOWORD(dwVersion)) > 4)
        {
            /* In NT5 we need to use the Product Suite APIs
             Don't static link because it won't load on non-NT5 systems */

            hmodK32 = GetModuleHandleA( "KERNEL32.DLL" );
            if (hmodK32)
            {
                pfnVerSetConditionMask = (PFnVerSetConditionMask )GetProcAddress( hmodK32, "VerSetConditionMask");

                if (pfnVerSetConditionMask)
                {
                    /* get the condition mask. */
                    dwlConditionMask = (*pfnVerSetConditionMask)(dwlConditionMask, VER_SUITENAME, VER_AND);

                    pfnVerifyVersionInfoA = (PFnVerifyVersionInfoA)GetProcAddress( hmodK32, "VerifyVersionInfoA") ;

                    if (pfnVerifyVersionInfoA != NULL)
                    {

                        ZeroMemory(&osVersionInfo, sizeof(osVersionInfo));
                        osVersionInfo.dwOSVersionInfoSize = sizeof(osVersionInfo);
                        osVersionInfo.wSuiteMask = VER_SUITE_TERMINAL;
                        bResult = (*pfnVerifyVersionInfoA)(
                                          &osVersionInfo,
                                          VER_SUITENAME,
                                          dwlConditionMask);
                    }
                }
            }
        }
        else
        {
            /* This is NT 40 */
            bResult = ValidateProductSuite( "Terminal Server" );
        }
    }

    return bResult;
}


int WINAPI WinMain(
  HINSTANCE  hInstance,
  HINSTANCE  hPrevInstance,
  LPSTR      lpCmdLine,
  int        nCmdShow
  )
{
    BOOL bIsTerminalServer;

    UNREFERENCED_PARAMETER (hInstance);
    UNREFERENCED_PARAMETER (hPrevInstance);
    UNREFERENCED_PARAMETER (lpCmdLine);
    UNREFERENCED_PARAMETER (nCmdShow);

    bIsTerminalServer = IsTerminalServicesEnabled();

    if (bIsTerminalServer)
        MessageBoxA( NULL, "Terminal Services is running.", "Status", MB_OK );
    else
        MessageBoxA( NULL, "Not a Terminal Services box.", "Status", MB_OK );

    return 0;
}
