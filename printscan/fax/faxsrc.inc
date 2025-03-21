#
# All binaries will end up in the fax directory
#
#ALT_PROJECT_TARGET=fax

!if !$(FREEBUILD)
C_DEFINES=$(C_DEFINES) -DDEBUG -DFAX_HEAP_DEBUG
!endif

!ifndef NOUNICODE
C_DEFINES=$(C_DEFINES) -DUNICODE -D_UNICODE
LINKLIBS=$(FAXROOT)\util\unicode\$O\faxutil.lib
!else
LINKLIBS=$(FAXROOT)\util\ansii\$O\faxutil.lib
!endif

C_DEFINES=$(C_DEFINES) -DTAPI_CURRENT_VERSION=0x00020000

FAXLIB=$(FAXROOT)\lib

INCLUDES=$(FAXROOT)\inc;$(WINDOWS_INC_PATH);

MSC_WARNING_LEVEL=/W3 /WX

PROJECT_COMPILER_WARNINGS=-FI$(FAXROOT)\inc\warning.h
