!IF 0

Copyright (c) 1989-2000  Microsoft Corporation

Module Name:

    sources.

Abstract:

    This file specifies the target component being built and the list of
    sources files needed to build that component.  Also specifies optional
    compiler switches and libraries that are unique for the component being
    built.


!ENDIF

MINORCOMP=f3ahvoas

!include ..\..\japan.inc

SOURCES_USED=..\sources.inc

LINKLIBS=$(WINDOWS_LIB_PATH)\w32umode.lib
