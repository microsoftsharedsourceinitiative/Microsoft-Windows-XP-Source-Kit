#include "precomp.h"
#include <oprahcom.h>
#include <regentry.h>
#include "mperror.h"
#include <sehcall.h>
#define LEGACY_DIVISOR	8

extern "C" WORD _cdecl is_cyrix(void);
extern "C" DWORD _cdecl get_nxcpu_type(void);


#ifndef _M_IX86
DWORD WINAPI CallWithSEH(EXCEPTPROC pfn, void *pv, INEXCEPTION InException)
{
	// we don't have a native version of SEH for the alpha,
	// use __try and __except
	pfn(pv);
    return 0;
}
#endif



#ifdef _M_IX86

DWORD NMINTERNAL FindTSC (LPVOID pvRefData)
{
	   _asm
	   {
		   mov     eax,1
		   _emit   00Fh     ;; CPUID
		   _emit   0A2h

    // The ref data is 2 DWORDS, the first is the flags,
    // the second the family
		   mov     ecx,pvRefData
		   mov     [ecx],edx
		   mov	   [ecx][4],eax
	   }

	   return 1;
}

DWORD NMINTERNAL NoCPUID (LPEXCEPTION_RECORD per,PCONTEXT pctx)
{
    return 0;
}
//
//  GetProcessorSpeed(dwFamily)
//
//  get the processor speed in MHz, only works on Pentium or better
//  machines.
//
//  Will put 3, or 4 in dwFamily for 386/486, but no speed.
//  returns speed and family for 586+
//
//  - thanks to toddla, modified by mikeg
//

int NMINTERNAL GetProcessorSpeed(int *pdwFamily)
{
    SYSTEM_INFO si;
    __int64	start, end, freq;
    int 	flags,family;
    int 	time;
    int 	clocks;
    DWORD	oldclass;
    HANDLE      hprocess;
    int     pRef[2];

    ZeroMemory(&si, sizeof(si));
    GetSystemInfo(&si);

    //Set the family. If wProcessorLevel is not specified, dig it out of dwProcessorType
    //Because wProcessor level is not implemented on Win95
    if (si.wProcessorLevel) {
	*pdwFamily=si.wProcessorLevel;
    }else {
    	//Ok, we're on Win95
    	switch (si.dwProcessorType) {
    	       case PROCESSOR_INTEL_386:
    		   *pdwFamily=3;
    		   break;

    	       case PROCESSOR_INTEL_486:
    		   *pdwFamily=4;
    		   break;
    	       default:
    		   *pdwFamily=0;
    		   break;
    	}
    		
    }

    //
    // make sure this is a INTEL Pentium (or clone) or higher.
    //
    if (si.wProcessorArchitecture != PROCESSOR_ARCHITECTURE_INTEL)
        return 0;

    if (si.dwProcessorType < PROCESSOR_INTEL_PENTIUM)
        return 0;

    //
    // see if this chip supports rdtsc before using it.
    //
    if (!CallWithSEH (FindTSC,&pRef,NoCPUID))     {
        flags=0;
    } else {
    // The ref data is 2 DWORDS, the first is the flags,
    // the second the family. Pull them out and use them
        flags=pRef[0];
        family=pRef[1];
    }

    if (!(flags & 0x10))
        return 0;


    //If we don't have a family, set it now
    //Family is bits 11:8 of eax from CPU, with eax=1
    if (!(*pdwFamily)) {
       *pdwFamily=(family& 0x0F00) >> 8;
    }


    hprocess = GetCurrentProcess();
    oldclass = GetPriorityClass(hprocess);
    SetPriorityClass(hprocess, REALTIME_PRIORITY_CLASS);
    Sleep(10);

    QueryPerformanceFrequency((LARGE_INTEGER*)&freq);
    QueryPerformanceCounter((LARGE_INTEGER*)&start);
    _asm
    {
        _emit   0Fh     ;; RDTSC
        _emit   31h
        mov     ecx,100000
x:      dec     ecx
        jnz     x
        mov     ebx,eax
        _emit   0Fh     ;; RDTSC
        _emit   31h
        sub     eax,ebx
        mov     dword ptr clocks[0],eax
    }
    QueryPerformanceCounter((LARGE_INTEGER*)&end);
    SetPriorityClass(hprocess, oldclass);

    time = MulDiv((int)(end-start),1000000,(int)freq);

    return (clocks + time/2) / time;
}



HRESULT NMINTERNAL GetNormalizedCPUSpeed (int *pdwNormalizedSpeed, int *dwFamily)
{
   int dwProcessorSpeed;

   dwProcessorSpeed=GetProcessorSpeed (dwFamily);

   *pdwNormalizedSpeed=dwProcessorSpeed;

   if (*dwFamily > 5) {
       //Ok, TWO things.
       // ONE DO NOT DO FP!
       // Two for the same Mhz assume a 686 is 1.3 times as fast as a 586 and a 786 is 1.6 times, etc.
       *pdwNormalizedSpeed=(ULONG) (((10+3*(*dwFamily-5))*dwProcessorSpeed)/10);
   }

   if (*dwFamily < 5) {
	  //bugbug until we have 386/486 timing code, assume
	  //486=50,386=37
      if (*dwFamily > 3) {
           //Cyrix, (5x86)? check before making default assignment
           if (is_cyrix()) {
               if (*pdwNormalizedSpeed==0) {
                   *dwFamily=5;
                   *pdwNormalizedSpeed=100;
                   return hrSuccess;
               }
           }
      }

	  *pdwNormalizedSpeed= (*dwFamily*100)/LEGACY_DIVISOR;

      if (get_nxcpu_type ()) {
        //Double the perceived value on a NexGen
        *pdwNormalizedSpeed *=2;
      }


   }



   return hrSuccess;
}
#endif //_M_IX86





BOOL WINAPI IsFloatingPointEmulated(void)
{
	long lRegValue;
	SYSTEM_INFO si;
	OSVERSIONINFO osi;
	BOOL fEmulation, bNT;
	

	// are we a Pentium
	ZeroMemory(&si, sizeof(si));
	GetSystemInfo(&si);
	if (si.dwProcessorType != PROCESSOR_INTEL_PENTIUM) 
	{
		return FALSE;
	}

	// Which OS: NT or 95 ?
	ZeroMemory(&osi, sizeof(osi));
	osi.dwOSVersionInfoSize = sizeof(osi);
	GetVersionEx(&osi);
	bNT = (osi.dwPlatformId == VER_PLATFORM_WIN32_NT);

	// Windows NT
	if (bNT)
	{
		RegEntry re(TEXT("System\\CurrentControlSet\\Control\\Session Manager"),
		            HKEY_LOCAL_MACHINE, FALSE);

		// try to get a definitive answer from the registry
		lRegValue = re.GetNumber(TEXT("ForceNpxEmulation"), -1);

		// registry: 0: no 
		//           1: conditional (not definitive!)
		//           2: yes

		if (lRegValue == 2)
		{
			return TRUE;
		}

		// we could load "IsProcessorFeaturePresent from kernel32.dll,
		// but the version that shipped with NT 4 has a bug in it that
		// returns the exact opposite of what it should be.  It was
		// fixed in NT 5. Since this API isn't the same across platforms,
		// we won't use it.

		return FALSE;
	}

	// Windows 95 - to be added later
	return FALSE;

}


