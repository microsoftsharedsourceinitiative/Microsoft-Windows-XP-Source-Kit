!IF 0

Copyright (c) 1989  Microsoft Corporation

Module Name:

    sources.

Abstract:

    This file specifies the target component being built and the list of
    sources files needed to build that component.  Also specifies optional
    compiler switches and libraries that are unique for the component being
    built.


Author:

    Steve Wood (stevewo) 12-Apr-1990

NOTE:   Commented description of this file is in \nt\bak\bin\sources.tpl

!ENDIF

MAJORCOMP=user
MINORCOMP=kbdfe_common
TARGETPATH=$(ALT_PROJECT_TARGET)\$(_OBJ_DIR)

C_DEFINES=$(C_DEFINES) $(USER_C_DEFINES)

TARGETNAME=fekbdcom
TARGETTYPE=LIBRARY

#INCLUDES=..\inc;..\..\..\inc;..\..\..\..\inc;..\$(BASE_KEYBOARD_LAYOUT)


SOURCES=..\fekbdcom.c

SYNCHRONIZE_BLOCK=1
