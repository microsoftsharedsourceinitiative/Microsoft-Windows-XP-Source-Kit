/*++

Copyright (c) 1994  Microsoft Corporation

Module Name:

    wininetp.h

Abstract:

    Includes all headers for precompiled header to build Windows Internet
    client DLL

Author:

    Richard L Firth (rfirth) 26-Oct-1994

Revision History:

    26-Oct-1994 rfirth
        Created

--*/

#ifndef __WININETP_H__
#define __WININETP_H__ 1

#if defined(_WIN64)
#pragma warning(disable:4267) // conversion from 'size_t' to 'DWORD'
#endif

//
// Checked builds get INET_DEBUG set by default; retail builds get no debugging
// by default
//

// #define STRESS_BUG_DEBUG // for stress debugging

#if DBG

#define STRESS_BUG_DEBUG // for stress debugging

#if !defined(INET_DEBUG)

#define INET_DEBUG          1

#endif // INET_DEBUG

#else

#if !defined(INET_DEBUG)

#define INET_DEBUG          0

#endif // INET_DEBUG

#endif // DBG

//
// common include files
//


//
// CRT includes
//

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stddef.h> // Pull in the 'offsetof' macro.
#include <string.h>
#include <memory.h>
#include <ctype.h>
#include <excpt.h>
#include <limits.h>
#include <fcntl.h>
#include <io.h>
#include <time.h>

//
// OS includes
//

#if defined(__cplusplus)
extern "C" {
#endif

#include <nt.h>
#include <ntrtl.h>
#include <nturtl.h>
#include <ntexapi.h>
#include <windows.h>

#if defined(__cplusplus)
}
#endif

//#include <fastcrit.h>

//
// SSL/PCT Security includes
//

#if defined(__cplusplus)
extern "C" {
#endif

#define SECURITY_WIN32
#include <sspi.h>    // standard SSPI interface
#include <issperr.h> // SSPI errors.
#include <spseal.h>  // Private SSPI Seal/UnSeal functions.
#include <schnlsp.h> // shared private schannel/wininet interfaces.
#include <wintrust.h> // various CAPI stuff for cert management
#include <wincrypt.h>
#if defined(__cplusplus)
}
#endif


#define WININET_SERVER_CORE     1

//
// WININET includes
//

#include <iwinsock.h>
#include <winhttp.h>
#include <winhttpi.h>
#include <private.h>
#include <ansi.h>
#include <wininetd.h>
#include <resinfo.h>
#include <syncobj.hxx>
#include <serialst.h>
#include <chunkflt.hxx>
#include <inetdbg.h>
#include <tracer.h>
#ifdef WINHTTP_FOR_MSXML
#  include <msxmlmem.h>
#else
#  include <debugmem.h>
#endif
#include <shlwapi.h>
#define NO_SHLWAPI_MLUI
#include <shlwapip.h>
#include <malloc.h>
#include <crtsubst.h>
#include <handle.h>
#include <constant.h>
#include <macros.h>
#include <inetp.h>
#include <util.h>
#include <proxreg.h>
#include <icstring.hxx>
#include <cliauth.hxx>
#include <certcach.hxx>
#include <buffer.hxx>
#include <thrdinfo.h>
#include <defaults.h>
#include <passport.h>
#include <spluginx.hxx>
#include <splugin.hxx>
#include <secinit.h>
#include <inetsspi.h>
#include <tstr.h>
#include <registry.h>
#include <parseurl.h>
#include <globals.h>
#include <reslock.hxx>
#include <autoprox.hxx>
#include <proxysup.hxx>
#include <hinet.hxx>
#include <priolist.hxx>
#include <icasync.hxx>
#include <caddrlst.hxx>
#include <icsocket.hxx>
#include <ssocket.hxx>
#include <servinfo.hxx>
#include <connect.hxx>
#include <http.hxx>
#include <cookie.h>
#include <rescache.h>
#include <parsers.h>
#include <fsm.hxx>
#include <mpacket.hxx>
#include <inetchar.h>
#include <bgtask.hxx>
#include <dlole.h>

#if defined(__cplusplus)
extern "C" {
#endif


//
//  Various protocol package initializers.
//

BOOL
WINAPI
WinInetDllEntryPoint(
    IN HINSTANCE DllHandle,
    IN DWORD Reason,
    IN LPVOID Reserved
    );

#if defined(__cplusplus)
}
#endif

//
// Need version 0x400 for ras defines for this to work on win95 gold.
//
#if defined(__cplusplus)
extern "C" {
#endif

#undef WINVER
#define WINVER 0x400

#include <ras.h>
#include <raserror.h>

#ifdef ICECAP
extern "C" void _stdcall StartCAP(void);
extern "C" void _stdcall StopCAP(void);
extern "C" void _stdcall SuspendCAP(void);
extern "C" void _stdcall ResumeCAP(void);
extern "C" void _stdcall MarkCAP(long lMark);  // write mark to MEA
extern "C" void _stdcall AllowCAP(void);  // Allow profiling when 'profile=almostnever'
#else
#define StartCAP()
#define StopCAP()
#define SuspendCAP()
#define ResumeCAP()
#define MarkCAP(n)
#define AllowCAP()
#endif

#if defined(__cplusplus)
}
#endif


/* X-Platform stuff */
#include <xpltfrm.h>

#endif /* __WININETP_H__ */
