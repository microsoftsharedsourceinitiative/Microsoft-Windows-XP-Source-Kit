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

    Wesley Witt (wesw) 10-Jan-96

NOTE:   Commented description of this file is in \nt\bak\bin\sources.tpl

!ENDIF

!include ..\..\..\..\faxsrc.inc

TARGETPATH=obj
TARGETTYPE=NOTARGET

IDL_TYPE=RPC

MIDL_FLAGS=$(MIDL_FLAGS) -oldnames -out $(PASS0_HEADERDIR) -I$(PASS0_HEADERDIR) -I$(FAXROOT)\service\rpc\faxcli

SOURCES= ..\faxcli.idl

SYNCHRONIZE_BLOCK=1
