!IF 0

Copyright (c) 1990  Microsoft Corporation

Module Name:

    sources.

Abstract:

    This file specifies the target component being built and the list of
    sources files needed to build that component.  Also specifies optional
    compiler switches and libraries that are unique for the component being
    built.


Author:

    Therese Stowell (thereses) 11-Nov-1990

NOTE:   Commented description of this file is in \nt\bak\bin\sources.tpl

!ENDIF

MAJORCOMP=windows
MINORCOMP=consrvl

CAIRO=1

TARGETNAME=consrvl
TARGETTYPE=LIBRARY

TARGETPATH=$(ALT_PROJECT_TARGET)\$(_OBJ_DIR)

C_DEFINES=$(C_DEFINES) -DUNICODE -DNEW_MINLOOK -D_NTDRIVER_

!IFNDEF MSC_WARNING_LEVEL
MSC_WARNING_LEVEL=/W3
!ENDIF
MSC_WARNING_LEVEL=$(MSC_WARNING_LEVEL) /WX

NTTARGETFILES=

INCLUDES=                                        \
        ..\;                                     \
        ..\..\inc;                               \
        $(WINCORE_PATH)\w32inc;                  \
        $(WINCORE_PATH)\w32inc\$(O);             \
        $(NTGDI_PATH)\inc;                       \
        $(NTUSER_PATH)\inc;                      \
        $(NTUSER_PATH)\inc\$(ALT_PROJECT)\$(O);  \
        $(NTUSER_PATH)\server;                   \
        $(NTUSER_PATH)\server\daytona\$(O);      \
        $(SHELL_INC_PATH);                       \
        $(BASE_INC_PATH)

SOURCES=..\bitmap.c    \
        ..\clipbrd.c   \
        ..\cmdline.c   \
        ..\constubs.c  \
        ..\cursor.c    \
        ..\directio.c  \
        ..\find.c      \
        ..\getset.c    \
        ..\handle.c    \
        ..\input.c     \
        ..\link.c      \
        ..\menu.c      \
        ..\misc.c      \
        ..\output.c    \
        ..\private.c   \
        ..\resize.c    \
        ..\share.c     \
        ..\srvinit.c   \
        ..\srvvdm.c    \
        ..\stream.c    \
        ..\dispatch.c  \
        ..\dbcs.c      \
        ..\convarea.c  \
        ..\eudc.c      \
        ..\foncache.c  \
        ..\hard.c

PRECOMPILED_INCLUDE=..\precomp.h
PRECOMPILED_PCH=precomp.pch
PRECOMPILED_OBJ=precomp.obj

SOURCES_USED=..\sources.inc
