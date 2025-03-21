
MYNTTREE=$(_NTTREE:\.=)
MYNTTREE_ESC=$(MYNTTREE:\=\\)
MYALTNTTREE_ESC=$(_ALT_NTTREE:\=\\)

BINPLACE_PLACEFILE=$(O)\placefil.txt

IMAGEROOT=$(DXROOT)\DeliveryImages
IMAGEINCROOT=$(IMAGEROOT)\inc
CABROOT=$(IMAGEROOT)\CabPacks
CABROOT_TARGET=$(CABROOT)\Whistler

#Change the line below to determine where the cabs pull their files from
CABCACHEROOT=$(CABROOT)\CabinetFileCache
CABCACHEROOT_ESC=$(CABCACHEROOT:\=\\)

CACHEMGR_SCR=$(CABROOT_TARGET)\CabCacheMgr.pl
DEPENDENCYPATHS_SCR=$(CABROOT_TARGET)\MakeDepPathVar.pl
SEDGEN_SCR=$(CABROOT_TARGET)\MakeSedScr.pl
DEPGEN_SCR=$(CABROOT_TARGET)\MakeDepList.pl
CDFGEN_SCR=$(CABROOT_TARGET)\MakeCDF.pl
CORRECTVER_SCR=$(CABROOT_TARGET)\CorrectVer.pl

DEPENDENCYPATHS_FILE=$(O)\DepPaths.txt

#needs to be the same rvalue in this configuration
DEPENDENCYLIST=$O\DependencyList.txt
DEPENDENCYLIST_FILE=$O\DependencyList.txt

CATNAME=$O\DX8NT51
CATFILE=$(CATNAME).CAT
CDFFILE=$(CATNAME).CDF
CHKCAT=$(CATFILE).Succeeded

PRODUCTTD_FILE=$(IMAGEINCROOT)\ProductTimeDate.txt
BUILDGENMSG=@echo Build_Status Generating  -  
#PERLLOC=$(BASEDIR)\public\tools\perl.exe
PERLLOC=$(CABROOT)\tools\perl.exe
SEDLOC=$(CABROOT)\tools\sed.exe
IEXPRESSDIR=$(DXROOT)\setup\iexpress

REDISTFILELIST=$(IMAGEINCROOT)\nt51redist.dat

MASTERSEDFILE=$O\$(CABTYPE).sed
VERSIONINFO=$O\version.txt

RSPFILE=$O\Version.rsp
DEFAULTLANGUAGE=eng

!if ("$(PRODUCT)" == "")
PRODUCT=$(__PRODUCT)0
!endif

EXTRATEXT=.\$(LANGUAGE).txt
SETUPAPP=DXSetup.exe
LOCALIZEDROOT=localized

CABCACHEFLAGS_FILE=$(O)\CabCacheFlags.txt

IEXPRESS_CMD=if exist $(MAKEDIR)\$@ del /q $(MAKEDIR)\$@  & 
IEXPRESS_CMD=$(BUILDGENMSG)  $(MAKEDIR)\$@
!if [dir $(IEXPRESSDIR)\$(LANGUAGE)\iexpress.exe 1>nul 2>&1]
IEXPRESS_CMD=$(IEXPRESS_CMD) & $(IEXPRESSDIR)\iexpress.exe /Q /N /M $?
!else
IEXPRESS_CMD=$(IEXPRESS_CMD) & $(IEXPRESSDIR)\$(LANGUAGE)\iexpress.exe /Q /N /M $?
!endif
IEXPRESS_CMD=$(IEXPRESS_CMD) & if not exist $@ @echo nmake : error IEXPRESS : $@ not generated; find problem run the iexpress cmd line without /Q

!if ([dir $(PRODUCTTD_FILE) 1>nul 2>&1])
THINGSTODO=$(THINGSTODO) GetCurrentTimeDate
!else
!include $(PRODUCTTD_FILE)
!endif

!if  (("$(PRODUCTTDSTAMP)"!="$(PRODUCTTD)") && ("$(PRODUCTTD)"!=""))
THINGSTODO=$(THINGSTODO) GetCurrentTimeDate
!endif

!if [dir $(DEPENDENCYLIST) 1>nul 2>&1]
THINGSTODO=$(THINGSTODO) BuildDependencyList
!else
!include $(DEPENDENCYLIST)
!endif 

!if [dir $(VERSIONINFO) 1>nul 2>&1]
THINGSTODO=$(THINGSTODO) GetVersionInfo
!else
!include $(VERSIONINFO)
!endif

THINGSTODO=$(THINGSTODO) TouchedTargetSupport

!if ("$(KEEP_CAT)"=="")
THINGSTODO=$(THINGSTODO) $(CHKCAT)
!endif

!if ("$(SEDFILE)"!="")
!include $(CABCACHEFLAGS_FILE)
!include $(DEPENDENCYPATHS_FILE)
!endif

SEDGEN_CMD=$(BUILDGENMSG)  $(MAKEDIR)\$@
SEDGEN_CMD=$(SEDGEN_CMD) & $(PERLLOC) $(SEDGEN_SCR) $(LANGUAGE) $(MASTERSEDFILE) $(CATFILE) $O $(DEFAULTLANGUAGE) $(@B) $(LOCALIZEDROOT) $(CABTYPE) 
SEDGEN_CMD=$(SEDGEN_CMD) & @if not exist $@ @echo nmake : error GENSED : failed to make $@

DEPGEN_CMD=$(BUILDGENMSG)  $(MAKEDIR)\$@
DEPGEN_CMD=$(DEPGEN_CMD) & $(PERLLOC) $(DEPGEN_SCR) $(_NTTREE:\.=) $(LANGUAGE) $(DEPENDENCYLIST) $(LOCALIZEDROOT) $(CABTYPE)
DEPGEN_CMD=$(DEPGEN_CMD) & @if not exist $(DEPENDENCYLIST) @echo nmake : error GENDEP : failed to make $(DEPENDENCYLIST)
                   
CDF_CMD=$(BUILDGENMSG)  $(MAKEDIR)\$@
CDF_CMD=$(CDF_CMD) & $(PERLLOC) $(CDFGEN_SCR) $(_NTTREE:\.=) $(LANGUAGE) $(CDFFILE) $(*F) $(@D) $(LOCALIZEDROOT) $(CABTYPE)
CDF_CMD=$(CDF_CMD) & @if not exist $(CDFFILE) @echo nmake : error GENSRC : failed to make $(CDFFILE)

CORRECTVER_CMD=$(BUILDGENMSG)  $(MAKEDIR)\$(CDFFILE)
CORRECTVER_CMD=$(CORRECTVER_CMD) & $(PERLLOC) $(CORRECTVER_SCR) $(O)\$(@B).CDF $(VERSIONINFO) $(CDFFILE)
CORRECTVER_CMD=$(CORRECTVER_CMD) & @if not exist $(CDFFILE) @echo nmake : error CORRECTVER : failed to make $(CDFFILE)

!if ("$(SEDFILE)"!="")
!if [dir $(EXTRATEXT) 1>nul 2>&1]
!include $(CABROOT_TARGET)\$(DEFAULTLANGUAGE)\$(DEFAULTLANGUAGE).txt
!else
!include $(EXTRATEXT)
!endif  

DisplayLicense=.\web$(LANGUAGE).txt
!if [dir $(DisplayLicense) 1>nul 2>&1]
DisplayLicense=$(CABROOT_TARGET)\$(DEFAULTLANGUAGE)\web$(DEFAULTLANGUAGE).txt
!endif 

!if ("$(CABTYPE)" == "wu")
CABNAME=$(PRODUCT)$(CABTYPE)$(LANGUAGE).exe
AppLaunched=$(SETUPAPP) /windowsupdate
FRIENDLYDESCRIPTION=for Windows Update

!else if ("$(CABTYPE)" == "exe")
CABNAME=$(PRODUCT)$(LANGUAGE).exe
AppLaunched=$(SETUPAPP) /packageinstall
FRIENDLYDESCRIPTION=runtime

!else if ("$(CABTYPE)" == "opk")
CABNAME=$(PRODUCT)$(CABTYPE).exe
AppLaunched=$(SETUPAPP) /silent
FRIENDLYDESCRIPTION=OPK

!else if ("$(CABTYPE)" == "core")
CABNAME=dxnt51.cab
!else
!error nmake : error CABTYPE : unknown cabtype $(CABTYPE)
!endif //CABTYPE

TargetName=$O\$(CABNAME)
FileVersion=$(ProductVersion)
CompanyName=Microsoft Corporation
FileDescription=DirectX cabpack for $(LANGUAGE)
InternalName=$(SETUPAPP)
OriginalFilename=$(InternalName)

SourceFiles0=$(CABCACHEROOT)

!endif //SEDFILE

DESCRIPTION=DirectX $(PRODUCT) $(FRIENDLYDESCRIPTION)
LISTTXT=$O\list.txt.$(CABTYPE)

#PRIVATEKEY=$(BASEDIR)\public\tools\driver.pvk
#CERTIFICATE=$(BASEDIR)\public\tools\driver.spc
PRIVATEKEY=$(BASEDIR)\tools\driver.pvk
CERTIFICATE=$(BASEDIR)\tools\driver.spc
DXWEBPAGE=http://www.microsoft.com/DirectX

SIGNIT_CMD=@echo Build_Status Test Signing  -  $@
SIGNIT_CMD=$(SIGNIT_CMD) & signcode -sha1 $(NT_CERTHASH) -n "$(DESCRIPTION)" -i "$(DXWEBPAGE)" $@

wu:  $(THINGSTODO) 
        -$(MAKE) SEDFILE=$O\$(PRODUCT)$@$(LANGUAGE).sed CABTYPE=$@ PRODUCTTD="$(PRODUCTTDSTAMP)" ALT_PROJECT_TARGET=. $O\$(PRODUCT)$@$(LANGUAGE).exe

exe: $(THINGSTODO)        
         -$(MAKE) SEDFILE=$O\$(PRODUCT)$(LANGUAGE).sed CABTYPE=$@ PRODUCTTD="$(PRODUCTTDSTAMP)"  ALT_PROJECT_TARGET=. $O\$(PRODUCT)$(LANGUAGE).exe

opk: $(THINGSTODO) 
        -$(MAKE) SEDFILE=$O\$(PRODUCT)$@.sed CABTYPE=$@ PRODUCTTD="$(PRODUCTTDSTAMP)"  ALT_PROJECT_TARGET=. $O\$(PRODUCT)$@.exe

core: $(THINGSTODO)
        -$(MAKE) SEDFILE=$O\dxnt51.sed CABTYPE=$@  PRODUCTTD="$(PRODUCTTDSTAMP)" ALT_PROJECT_TARGET=. $O\dxnt51.cab 

cat: $(CATFILE)

.SUFFIXES: .sed .ddf 

{$O}.sed{$O}.exe:
#	this set is to support multi-proc machines diamond doesn't do the right thing
	set TMP=$O
	$(IEXPRESS_CMD)
        $(SIGNIT_CMD)
	$(BINPLACE_CMD)

{$O}.sed{$O}.cab:
#	this set is to support multi-proc machines diamond doesn't do the right thing
	set TMP=$O
        $(IEXPRESS_CMD)
        $(BINPLACE_CMD)

!if ("$(SEDFILE)"!="")
$(CABCACHEFLAGS):{$(DEPENDENCY_PATHS)}$(@F:.flg=) $(PRODUCTTD_FILE)
        set DXROOT=$(DXROOT)
        $(PERLLOC) $(CACHEMGR_SCR) $(REDISTFILELIST) $(@:.flg=) $@ "$(PRODUCTTDSTAMP)" $(MYNTTREE) $(LANGUAGE) $(LOCALIZEDROOT)
            
$(SEDFILE) :  $(MASTERSEDFILE) $(SEDGEN_SCR) $(LISTTXT) $(CABCACHEFLAGS)
        set DXROOT=$(DXROOT)
        $(SEDGEN_CMD)
!endif

TouchedTargetSupport: $(DEPENDENCYPATHS_FILE) $(CABCACHEFLAGS_FILE)
        if not exist $(CABCACHEROOT) md $(CABCACHEROOT) 1>nul
        @for /f "tokens=1 skip=1" %a in ($(CABCACHEFLAGS_FILE)) do @if not exist %~dpa md %~dpa 1>nul 

$(DEPENDENCYPATHS_FILE):$(DEPENDENCYLIST_FILE) $(DEPENDENCYPATHS_SCR) 
        $(PERLLOC) $(DEPENDENCYPATHS_SCR) $(DEPENDENCYLIST_FILE) $(DEPENDENCYPATHS_FILE)

$(CABCACHEFLAGS_FILE):$(DEPENDENCYLIST_FILE)
        @prompt $$S
        set DXROOT=$(DXROOT)
        echo CABCACHEFLAGS=\>$(CABCACHEFLAGS_FILE)
        echo s/$(MYNTTREE_ESC)/$(CABCACHEROOT_ESC)/> $(O)\chnttree.sed
        echo s/$(MYALTNTTREE_ESC)/$(CABCACHEROOT_ESC)/>> $(O)\chnttree.sed
#       @for /f "skip=1" %a in ($(DEPENDENCYLIST_FILE)) do echo %a.flg \|$(SEDLOC) -e "s/$(MYNTTREE_ESC)/$(CABCACHEROOT_ESC)/">>$(CABCACHEFLAGS_FILE)
        @for /f "skip=1" %a in ($(DEPENDENCYLIST_FILE)) do echo %a.flg \|$(SEDLOC) -f $(O)\chnttree.sed >>$(CABCACHEFLAGS_FILE)

GetCurrentTimeDate:
!if ("$(PRODUCTTD)"=="")
	for /f "tokens=2-8 delims=/:. " %a in ("%DATE% %TIME%") do echo PRODUCTTDSTAMP=%c %a %b %d %e %f>$(PRODUCTTD_FILE)
!else
	echo PRODUCTTDSTAMP=$(PRODUCTTD)>$(PRODUCTTD_FILE)
!endif
	

BuildDependencyList: 
	set DXROOT=$(DXROOT)
	$(DEPGEN_CMD)	

$(CDFFILE): $(REDISTFILELIST)
	set DXROOT=$(DXROOT)
	$(CDF_CMD)

$(CATFILE): $(CDFFILE)
	makecat -n -v $(CDFFILE)
	copy $@ $@.unsigned
	setreg -q 1 TRUE
!MESSAGE  WARNING This is a test signature... Real signature required before release...
	signcode -sha1 $(NT_CERTHASH) -n "$(DESCRIPTION)" -i "$(DXWEBPAGE)" -t http://timestamp.verisign.com/scripts/timstamp.dll $@
	chktrust -q $@ | ..\..\tools\sed -e "/Succeeded/!d" -e "s/\(.*\): \(.*\)/\.\.\\\.\.\\tools\\touch -c \1.\2/" > $(O)\chkcat.cmd
	-del $@.Succeeded > NUL 2>&1
	call $(O)\chkcat.cmd
	if not exist $@.Succeeded echo nmake : CATALOG SINING ERROR! : failed to sign $@
	@echo $(@F) DXCAT>$(O)\placefil.txt
	$(BINPLACE_CMD)

DelChkCat:
	-del $(CHKCAT) > NUL 2>&1

GetVersionInfo: $(VERSIONINFO)

$(LISTTXT): $(CABROOT_TARGET)\makefile.inc
	$(BUILDGENMSG)  $(MAKEDIR)\$@
	echo $(CABNAME), $(DESCRIPTION), $(DXWEBPAGE)>$@

$(MASTERSEDFILE): $(CABROOT_TARGET)\makefile.inc $(VERSIONINFO)
	$(BUILDGENMSG)  $(MAKEDIR)\$@
!include $(CABROOT_TARGET)\master.sed
	@if not exist $@ @echo nmake : error GENSED : failed to make $@s

$(VERSIONINFO): $(DXROOT)\inc\verinfo.h
	$(BUILDGENMSG) $(MAKEDIR)\$@
	type <<$(O)\version.rc
#define RC_INVOKED 

#ifdef WINNT

#include <windows.h>
#include <ntverp.h>

#define VER_FILETYPE                VFT_DLL
#define VER_FILESUBTYPE             VFT2_UNKNOWN
#define VER_FILEDESCRIPTION_STR     "Garbage"
#define VER_INTERNALNAME_STR        VER_FILEDESCRIPTION_STR
#define VER_ORIGINALFILENAME_STR    "Garbage"

#include "common.ver"

#else	// win95

#include "verinfo.h"

#define VERSIONNAME               "Garbage\0"
#define VERSIONDESCRIPTION        "Garbage\0"
#define VERSIONTYPE               VFT_DLL
#define VERSIONSUBTYPE            VFT2_UNKNOWN

#include "verinfo.ver"

#endif
<<KEEP
	type <<$(RSPFILE)
/nologo /DWINNT /I$(DXROOT)\inc /I$(BASEDIR)\public\sdk\inc /E /Fc /Tc$(O)\version.rc
<<KEEP
	-for /f "tokens=2* delims== " %a in ('cl @$(RSPFILE) ^| findstr "ProductVersion LegalCopyright ProductName" ^|$(SEDLOC) -e "s/\"[ ][ ]*\"//g" -e "s/,[ ][ ]*/=/" -e ') do echo %~a=%~b>>$@
                	
