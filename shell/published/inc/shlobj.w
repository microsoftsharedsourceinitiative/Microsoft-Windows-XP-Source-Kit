//===========================================================================
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// File: shlobj.h
//
//===========================================================================
;begin_internal
//***************************************************************************
//  --- SHELLAPI.W SHSEMIP.H SHLOBJ.W SHOBJIDL.IDL SHLDISP.IDL SHPRIV.IDL ---
//                Which header is best for my new API?
//
//  SHLOBJ      - *AVOID NEW USAGE*, PREFER OTHER HEADERS
//              used primarily for legacy compatibility
//
//  SHELLAPI    - ALL NEW SHELL32 EXPORTS public and private
//              used for both public and private exports from shell32
//
//  SHSEMIP     - *AVOID _ALL_ USAGE*, NO EXPORTS, SUPER PRIVATE
//              used for very private shell defines.
//
//  SHOBJIDL    - ALL NEW SHELL PUBLIC INTERFACES
//              primary file for public shell (shell32+) interfaces
//
//  SHLDISP     - ALL NEW SHELL AUTOMATION INTERFACES
//              automation interfaces are always public
//
//  SHPRIV      - ALL NEW SHELL PRIVATE INTERFACES
//              private interfaces used anywhere in the shell
//
//
//  SHLOBJ was originally the file that defined all of shell32's interfaces.
//  it devolved into a dumping ground of public and private APIs and
//  interfaces.  in the effort to better support COM and better API management
//  we are attempting to avoid using shlobj
//***************************************************************************
;end_internal

#ifndef _SHLOBJ_H_
#define _SHLOBJ_H_
#ifndef _SHLOBJP_H_             ;Internal
#define _SHLOBJP_H_             ;Internal

#ifndef _WINRESRC_
#ifndef _WIN32_IE
#define _WIN32_IE 0x0501
#else
#if (_WIN32_IE < 0x0400) && defined(_WIN32_WINNT) && (_WIN32_WINNT >= 0x0500)
#error _WIN32_IE setting conflicts with _WIN32_WINNT setting
#endif
#endif
#endif

#ifndef SNDMSG
#ifdef __cplusplus
#define SNDMSG ::SendMessage
#else
#define SNDMSG SendMessage
#endif
#endif // ifndef SNDMSG

//
// Define API decoration for direct importing of DLL references.
//
#ifndef WINSHELLAPI
#if defined(_SHELL32_)
#define WINSHELLAPI
#else
#define WINSHELLAPI       DECLSPEC_IMPORT
#endif
#endif // WINSHELLAPI

#ifndef SHSTDAPI
#if defined(_SHELL32_)
#define SHSTDAPI          STDAPI
#define SHSTDAPI_(type)   STDAPI_(type)
#else
#define SHSTDAPI          EXTERN_C DECLSPEC_IMPORT HRESULT STDAPICALLTYPE
#define SHSTDAPI_(type)   EXTERN_C DECLSPEC_IMPORT type STDAPICALLTYPE
#endif
#endif // SHSTDAPI

#ifndef SHDOCAPI
#if defined(_SHDOCVW_)
#define SHDOCAPI          STDAPI
#define SHDOCAPI_(type)   STDAPI_(type)
#else
#define SHDOCAPI          EXTERN_C DECLSPEC_IMPORT HRESULT STDAPICALLTYPE
#define SHDOCAPI_(type)   EXTERN_C DECLSPEC_IMPORT type STDAPICALLTYPE
#endif
#endif // SHDOCAPI

// shell32 APIs that are also exported from shdocvw
#ifndef SHSTDDOCAPI
#if defined(_SHDOCVW_) || defined(_SHELL32_)
#define SHSTDDOCAPI          STDAPI
#define SHSTDDOCAPI_(type)   STDAPI_(type)
#else
#define SHSTDDOCAPI          EXTERN_C DECLSPEC_IMPORT HRESULT STDAPICALLTYPE
#define SHSTDDOCAPI_(type)   EXTERN_C DECLSPEC_IMPORT type STDAPICALLTYPE
#endif
#endif // SHSTDDOCAPI

#ifndef BROWSEUIAPI
#if defined(_BROWSEUI_)
#define BROWSEUIAPI           STDAPI
#define BROWSEUIAPI_(type)    STDAPI_(type)
#else
#define BROWSEUIAPI           EXTERN_C DECLSPEC_IMPORT HRESULT STDAPICALLTYPE
#define BROWSEUIAPI_(type)    EXTERN_C DECLSPEC_IMPORT type STDAPICALLTYPE
#endif // defined(_BROWSEUI_)
#endif // BROWSEUIAPI

// shell32 APIs that are also exported from shfolder
#ifndef SHFOLDERAPI
#if defined(_SHFOLDER_) || defined(_SHELL32_)
#define SHFOLDERAPI           STDAPI
#else
#define SHFOLDERAPI           EXTERN_C DECLSPEC_IMPORT HRESULT STDAPICALLTYPE
#endif
#endif


#define NO_MONIKER      ;Internal

#include <ole2.h>
#ifndef _PRSHT_H_
#include <prsht.h>
#endif
#ifndef _INC_COMMCTRL
#include <commctrl.h>   // for LPTBBUTTON
#endif

#ifndef INITGUID
#include <shlguid.h>
#endif /* !INITGUID */

#include <docobj.h>  ;Internal

#include <shldisp.h> ;Internal

;begin_both
#include <pshpack1.h>   /* Assume byte packing throughout */

#ifdef __cplusplus
extern "C" {            /* Assume C declarations for C++ */
#endif /* __cplusplus */

#include <shtypes.h>

;end_both

#include <shobjidl.h>
#include <shpriv.h>  ;Internal
#include <iepriv.h>  ;Internal

;begin_internal
// HMONITOR is already declared in NT 5's windef.h.
#if !defined(HMONITOR_DECLARED) && (WINVER < 0x0500)
DECLARE_HANDLE(HMONITOR);
#define HMONITOR_DECLARED
#endif

#include <tlog.h>

;end_internal

//===========================================================================
//
// Task allocator API
//
//  All the shell extensions MUST use the task allocator (see OLE 2.0
// programming guild for its definition) when they allocate or free
// memory objects (mostly ITEMIDLIST) that are returned across any
// shell interfaces. There are two ways to access the task allocator
// from a shell extension depending on whether or not it is linked with
// OLE32.DLL or not (purely for efficiency).
//
// (1) A shell extension which calls any OLE API (i.e., linked with
//  OLE32.DLL) should call OLE's task allocator (by retrieving
//  the task allocator by calling CoGetMalloc API).
//
// (2) A shell extension which does not call any OLE API (i.e., not linked
//  with OLE32.DLL) should call the shell task allocator API (defined
//  below), so that the shell can quickly loads it when OLE32.DLL is not
//  loaded by any application at that point.
//
// Notes:
//  In next version of Windowso release, SHGetMalloc will be replaced by
// the following macro.
//
// #define SHGetMalloc(ppmem)   CoGetMalloc(MEMCTX_TASK, ppmem)
//
//===========================================================================

SHSTDAPI SHGetMalloc(LPMALLOC * ppMalloc);

;begin_internal
// DOC'ed for DOJ compliance
;end_internal
SHSTDAPI_(void *) SHAlloc(SIZE_T cb);

SHSTDAPI_(void *) SHRealloc(void * pv, SIZE_T cbNew);       ;Internal
SHSTDAPI_(SIZE_T) SHGetSize(void * pv);                     ;Internal

;begin_internal
// DOC'ed for DOJ compliance
;end_internal
SHSTDAPI_(void)   SHFree(void * pv);


//===========================================================================
//
// IContextMenu interface
//
// [OverView]
//
//  The shell uses the IContextMenu interface in following three cases.
//
// case-1: The shell is loading context menu extensions.
//
//   When the user clicks the right mouse button on an item within the shell's
//  name space (i.g., file, directory, server, work-group, etc.), it creates
//  the default context menu for its type, then loads context menu extensions
//  that are registered for that type (and its base type) so that they can
//  add extra menu items. Those context menu extensions are registered at
//  HKCR\{ProgID}\shellex\ContextMenuHandlers.
//
// case-2: The shell is retrieving a context menu of sub-folders in extended
//   name-space.
//
//   When the explorer's name space is extended by name space extensions,
//  the shell calls their IShellFolder::GetUIObjectOf to get the IContextMenu
//  objects when it creates context menus for folders under those extended
//  name spaces.
//
// case-3: The shell is loading non-default drag and drop handler for directories.
//
//   When the user performed a non-default drag and drop onto one of file
//  system folders (i.e., directories), it loads shell extensions that are
//  registered at HKCR\{ProgID}\DragDropHandlers.
//
//
// [Member functions]
//
//
// IContextMenu::QueryContextMenu
//
//   This member function may insert one or more menuitems to the specified
//  menu (hmenu) at the specified location (indexMenu which is never be -1).
//  The IDs of those menuitem must be in the specified range (idCmdFirst and
//  idCmdLast). It returns the maximum menuitem ID offset (ushort) in the
//  'code' field (low word) of the scode.
//
//   The uFlags specify the context. It may have one or more of following
//  flags.
//
//  CMF_DEFAULTONLY: This flag is passed if the user is invoking the default
//   action (typically by double-clicking, case 1 and 2 only). Context menu
//   extensions (case 1) should not add any menu items, and returns NOERROR.
//
//  CMF_VERBSONLY: The explorer passes this flag if it is constructing
//   a context menu for a short-cut object (case 1 and case 2 only). If this
//   flag is passed, it should not add any menu-items that is not appropriate
//   from a short-cut.
//    A good example is the "Delete" menuitem, which confuses the user
//   because it is not clear whether it deletes the link source item or the
//   link itself.
//
//  CMF_EXPLORER: The explorer passes this flag if it has the left-side pane
//   (case 1 and 2 only). Context menu extensions should ignore this flag.
//
//   High word (16-bit) are reserved for context specific communications
//  and the rest of flags (13-bit) are reserved by the system.
//
//
// IContextMenu::InvokeCommand
//
//   This member is called when the user has selected one of menuitems that
//  are inserted by previous QueryContextMenu member. In this case, the
//  LOWORD(lpici->lpVerb) contains the menuitem ID offset (menuitem ID -
//  idCmdFirst).
//
//   This member function may also be called programmatically. In such a case,
//  lpici->lpVerb specifies the canonical name of the command to be invoked,
//  which is typically retrieved by GetCommandString member previously.
//
//  Parameters in lpci:
//    cbSize -- Specifies the size of this structure (sizeof(*lpci))
//    hwnd   -- Specifies the owner window for any message/dialog box.
//    fMask  -- Specifies whether or not dwHotkey/hIcon paramter is valid.
//    lpVerb -- Specifies the command to be invoked.
//    lpParameters -- Parameters (optional)
//    lpDirectory  -- Working directory (optional)
//    nShow -- Specifies the flag to be passed to ShowWindow (SW_*).
//    dwHotKey -- Hot key to be assigned to the app after invoked (optional).
//    hIcon -- Specifies the icon (optional).
//    hMonitor -- Specifies the default monitor (optional).
//
//
// IContextMenu::GetCommandString
//
//   This member function is called by the explorer either to get the
//  canonical (language independent) command name (uFlags == GCS_VERB) or
//  the help text ((uFlags & GCS_HELPTEXT) != 0) for the specified command.
//  The retrieved canonical string may be passed to its InvokeCommand
//  member function to invoke a command programmatically. The explorer
//  displays the help texts in its status bar; therefore, the length of
//  the help text should be reasonably short (<40 characters).
//
//  Parameters:
//   idCmd -- Specifies menuitem ID offset (from idCmdFirst)
//   uFlags -- Either GCS_VERB or GCS_HELPTEXT
//   pwReserved -- Reserved (must pass NULL when calling, must ignore when called)
//   pszName -- Specifies the string buffer.
//   cchMax -- Specifies the size of the string buffer.
//
//===========================================================================

// QueryContextMenu uFlags
#define CMF_NORMAL              0x00000000
#define CMF_DEFAULTONLY         0x00000001
#define CMF_VERBSONLY           0x00000002
#define CMF_EXPLORE             0x00000004
#define CMF_NOVERBS             0x00000008
#define CMF_CANRENAME           0x00000010
#define CMF_NODEFAULT           0x00000020
#define CMF_INCLUDESTATIC       0x00000040
#define CMF_FINDHACK            0x00000080      // This is a hack - we should remove this bit ;Internal
#define CMF_EXTENDEDVERBS       0x00000100      // rarely used verbs
#define CMF_RESERVED            0xffff0000      // View specific

;begin_internal
//
// Private QueryContextMenuFlag passed from DefView
//
#define CMF_DVFILE              0x00010000      // "File" pulldown
#define CMF_ICM3                0x00020000      // QueryContextMenu can assume IContextMenu3 semantics (i.e.,
                                                // will receive WM_INITMENUPOPUP, WM_MEASUREITEM, WM_DRAWITEM,
                                                // and WM_MENUCHAR, via HandleMenuMsg2)
;end_internal


// GetCommandString uFlags
#define GCS_VERBA        0x00000000     // canonical verb
#define GCS_HELPTEXTA    0x00000001     // help text (for status bar)
#define GCS_VALIDATEA    0x00000002     // validate command exists
#define GCS_VERBW        0x00000004     // canonical verb (unicode)
#define GCS_HELPTEXTW    0x00000005     // help text (unicode version)
#define GCS_VALIDATEW    0x00000006     // validate command exists (unicode)
#define GCS_UNICODE      0x00000004     // for bit testing - Unicode string

#ifdef UNICODE
#define GCS_VERB        GCS_VERBW
#define GCS_HELPTEXT    GCS_HELPTEXTW
#define GCS_VALIDATE    GCS_VALIDATEW
#else
#define GCS_VERB        GCS_VERBA
#define GCS_HELPTEXT    GCS_HELPTEXTA
#define GCS_VALIDATE    GCS_VALIDATEA
#endif

#define CMDSTR_NEWFOLDERA   "NewFolder"
#define CMDSTR_VIEWLISTA    "ViewList"
#define CMDSTR_VIEWDETAILSA "ViewDetails"
#define CMDSTR_NEWFOLDERW   L"NewFolder"
#define CMDSTR_VIEWLISTW    L"ViewList"
#define CMDSTR_VIEWDETAILSW L"ViewDetails"

#ifdef UNICODE
#define CMDSTR_NEWFOLDER    CMDSTR_NEWFOLDERW
#define CMDSTR_VIEWLIST     CMDSTR_VIEWLISTW
#define CMDSTR_VIEWDETAILS  CMDSTR_VIEWDETAILSW
#else
#define CMDSTR_NEWFOLDER    CMDSTR_NEWFOLDERA
#define CMDSTR_VIEWLIST     CMDSTR_VIEWLISTA
#define CMDSTR_VIEWDETAILS  CMDSTR_VIEWDETAILSA
#endif

#define CMIC_MASK_HOTKEY        SEE_MASK_HOTKEY
#define CMIC_MASK_ICON          SEE_MASK_ICON
#define CMIC_MASK_FLAG_NO_UI    SEE_MASK_FLAG_NO_UI
#define CMIC_MASK_UNICODE       SEE_MASK_UNICODE
#define CMIC_MASK_NO_CONSOLE    SEE_MASK_NO_CONSOLE
#define CMIC_MASK_HASLINKNAME   SEE_MASK_HASLINKNAME
#define CMIC_MASK_FLAG_SEP_VDM  SEE_MASK_FLAG_SEPVDM
#define CMIC_MASK_HASTITLE      SEE_MASK_HASTITLE
#define CMIC_MASK_ASYNCOK       SEE_MASK_ASYNCOK
#define CMIC_MASK_NOZONECHECKS  SEE_MASK_NOZONECHECKS

#if (_WIN32_IE >= 0x0501)
#define CMIC_MASK_SHIFT_DOWN    0x10000000
#define CMIC_MASK_CONTROL_DOWN  0x40000000
#endif // (_WIN32_IE >= 0x501)
#if (_WIN32_IE >= 0x0560)
#define CMIC_MASK_FLAG_LOG_USAGE SEE_MASK_FLAG_LOG_USAGE
#endif // (_WIN32_IE >= 0x560)


#if (_WIN32_IE >= 0x0400)
#define CMIC_MASK_PTINVOKE      0x20000000
#define CMICEXSIZE_NT4          (SIZEOF(CMINVOKECOMMANDINFOEX) - SIZEOF(POINT))  ;Internal
#endif

#define CMIC_MASK_NO_HOOKS      SEE_MASK_NO_HOOKS                       ;internal_win40
#define CMIC_MASK_DATAOBJECT    0x40000000   // lpPara is IDataObject*  ;Internal
#define CMIC_MASK_MODAL         0x80000000                              ;Internal

#define CMIC_VALID_SEE_FLAGS    SEE_VALID_CMIC_FLAGS                    ;Internal

#include <pshpack8.h>

//NOTE: When SEE_MASK_HMONITOR is set, hIcon is treated as hMonitor
typedef struct _CMINVOKECOMMANDINFO {
    DWORD cbSize;        // sizeof(CMINVOKECOMMANDINFO)
    DWORD fMask;         // any combination of CMIC_MASK_*
    HWND hwnd;           // might be NULL (indicating no owner window)
    LPCSTR lpVerb;       // either a string or MAKEINTRESOURCE(idOffset)
    LPCSTR lpParameters; // might be NULL (indicating no parameter)
    LPCSTR lpDirectory;  // might be NULL (indicating no specific directory)
    int nShow;           // one of SW_ values for ShowWindow() API

    DWORD dwHotKey;
    HANDLE hIcon;
} CMINVOKECOMMANDINFO,  *LPCMINVOKECOMMANDINFO;

typedef struct _CMInvokeCommandInfoEx {
    DWORD cbSize;        // must be sizeof(CMINVOKECOMMANDINFOEX)
    DWORD fMask;         // any combination of CMIC_MASK_*
    HWND hwnd;           // might be NULL (indicating no owner window)
    LPCSTR lpVerb;       // either a string or MAKEINTRESOURCE(idOffset)
    LPCSTR lpParameters; // might be NULL (indicating no parameter)
    LPCSTR lpDirectory;  // might be NULL (indicating no specific directory)
    int nShow;           // one of SW_ values for ShowWindow() API

    DWORD dwHotKey;

    HANDLE hIcon;
    LPCSTR lpTitle;      // For CreateProcess-StartupInfo.lpTitle
    LPCWSTR lpVerbW;        // Unicode verb (for those who can use it)
    LPCWSTR lpParametersW;  // Unicode parameters (for those who can use it)
    LPCWSTR lpDirectoryW;   // Unicode directory (for those who can use it)
    LPCWSTR lpTitleW;       // Unicode title (for those who can use it)
#if (_WIN32_IE >= 0x0400)
    POINT   ptInvoke;       // Point where it's invoked
#endif
} CMINVOKECOMMANDINFOEX,  *LPCMINVOKECOMMANDINFOEX;

#include <poppack.h>        /* Return to byte packing */

;begin_internal
#include <pshpack8.h>
// the struct below is used for cross-process passing of CMINVOKECOMMANDINFOEX structs
// we store offsets for the strings into ourself and we are win64 safe
typedef struct {
    DWORD cbSize;           // size of the struct
    DWORD fMask;            // any combination of CMIC_MASK_*
    DWORD dwHwnd;           // might be NULL (indicating no owner window)
    int nShow;              // one of SW_ values for ShowWindow() API
    DWORD dwHotKey;
    POINT ptInvoke;         // Point where it's invoked
    DWORD dwVerbW;          // offset from struct to lpVerbW
    DWORD dwParametersW;    // offset from struct to lpParametersW - might be NULL (indicating no parameter)
    DWORD dwDirectoryW;     // offset from struct to lpDirectoryW - might be NULL (indicating no specific directory)
    DWORD dwTitleW;         // offset from struct to lpTitleW - might be NULL (indicating no title)
}ICIX_PERSIST;
#include <poppack.h>

;end_internal


#undef  INTERFACE
#define INTERFACE   IContextMenu

DECLARE_INTERFACE_(IContextMenu, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    STDMETHOD(QueryContextMenu)(THIS_
                                HMENU hmenu,
                                UINT indexMenu,
                                UINT idCmdFirst,
                                UINT idCmdLast,
                                UINT uFlags) PURE;

    STDMETHOD(InvokeCommand)(THIS_
                             LPCMINVOKECOMMANDINFO lpici) PURE;

    STDMETHOD(GetCommandString)(THIS_
                                UINT_PTR    idCmd,
                                UINT        uType,
                                UINT      * pwReserved,
                                LPSTR       pszName,
                                UINT        cchMax) PURE;
};

typedef IContextMenu *  LPCONTEXTMENU;

#define CONTEXTMENU_IDCMD_FIRST    1        // minimal QueryContextMenu idCmdFirst value // ;internal
#define CONTEXTMENU_IDCMD_LAST     0x7fff   // maximal QueryContextMenu idCmdLast value  // ;internal


//
// IContextMenu2 (IContextMenu with one new member)
//
// IContextMenu2::HandleMenuMsg
//
//  This function is called, if the client of IContextMenu is aware of
// IContextMenu2 interface and receives one of following messages while
// it is calling TrackPopupMenu (in the window proc of hwnd):
//      WM_INITPOPUP, WM_DRAWITEM and WM_MEASUREITEM
//  The callee may handle these messages to draw owner draw menuitems.
//

#undef  INTERFACE
#define INTERFACE   IContextMenu2

DECLARE_INTERFACE_(IContextMenu2, IContextMenu)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IContextMenu methods ***

    STDMETHOD(QueryContextMenu)(THIS_
                                HMENU hmenu,
                                UINT indexMenu,
                                UINT idCmdFirst,
                                UINT idCmdLast,
                                UINT uFlags) PURE;

    STDMETHOD(InvokeCommand)(THIS_
                             LPCMINVOKECOMMANDINFO lpici) PURE;

    STDMETHOD(GetCommandString)(THIS_
                                UINT_PTR    idCmd,
                                UINT        uType,
                                UINT      * pwReserved,
                                LPSTR       pszName,
                                UINT        cchMax) PURE;

    // *** IContextMenu2 methods ***

    STDMETHOD(HandleMenuMsg)(THIS_
                             UINT uMsg,
                             WPARAM wParam,
                             LPARAM lParam) PURE;
};

typedef IContextMenu2 * LPCONTEXTMENU2;

//
// IContextMenu3 (IContextMenu with one new member)
//
// IContextMenu3::HandleMenuMsg2
//
//  This function is called, if the client of IContextMenu is aware of
// IContextMenu3 interface and receives a menu message while
// it is calling TrackPopupMenu (in the window proc of hwnd):
//

#undef  INTERFACE
#define INTERFACE   IContextMenu3

DECLARE_INTERFACE_(IContextMenu3, IContextMenu2)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IContextMenu methods ***

    STDMETHOD(QueryContextMenu)(THIS_
                                HMENU hmenu,
                                UINT indexMenu,
                                UINT idCmdFirst,
                                UINT idCmdLast,
                                UINT uFlags) PURE;

    STDMETHOD(InvokeCommand)(THIS_
                             LPCMINVOKECOMMANDINFO lpici) PURE;

    STDMETHOD(GetCommandString)(THIS_
                                UINT_PTR    idCmd,
                                UINT        uType,
                                UINT      * pwReserved,
                                LPSTR       pszName,
                                UINT        cchMax) PURE;

    // *** IContextMenu2 methods ***

    STDMETHOD(HandleMenuMsg)(THIS_
                             UINT uMsg,
                             WPARAM wParam,
                             LPARAM lParam) PURE;

    // *** IContextMenu3 methods ***

    STDMETHOD(HandleMenuMsg2)(THIS_
                             UINT uMsg,
                             WPARAM wParam,
                             LPARAM lParam,
                             LRESULT* plResult) PURE;
};

typedef IContextMenu3 * LPCONTEXTMENU3;

//----------------------------------------------------------------------------        ;Internal
// Internal helper macro                                                              ;Internal
//----------------------------------------------------------------------------        ;Internal
                                                                                      ;Internal
#define _IOffset(class, itf)         ((UINT_PTR)&(((class *)0)->itf))                 ;Internal
#define IToClass(class, itf, pitf)   ((class  *)(((LPSTR)pitf)-_IOffset(class, itf))) ;Internal
#define IToClassN(class, itf, pitf)  IToClass(class, itf, pitf)                       ;Internal
                                                                                      ;Internal
//                                                                    ;Internal
// Helper macro definitions                                           ;Internal
//                                                                    ;Internal
#define S_BOOL(f)   MAKE_SCODE(SEVERITY_SUCCESS, 0, f)                ;Internal
                                                                      ;Internal
#ifdef DEBUG                                                          ;Internal
#define ReleaseAndAssert(punk) Assert(punk->lpVtbl->Release(punk)==0) ;Internal
#else                                                                 ;Internal
#define ReleaseAndAssert(punk) (punk->lpVtbl->Release(punk))          ;Internal
#endif                                                                ;Internal

#if (_WIN32_IE >= 0x0500)
#undef  INTERFACE
#define INTERFACE   IPersistFolder3

#define CSIDL_FLAG_PFTI_TRACKTARGET CSIDL_FLAG_DONT_VERIFY

// DESCRIPTION: PERSIST_FOLDER_TARGET_INFO
//    This stucture is used for Folder Shortcuts which allow the shell to
// have a file system folder act like another area in the name space.
// One of pidlTargetFolder, szTargetParsingName, or csidl needs to
// specify the destination name space.
//
// pidlTargetFolder: This is a full pidl to the target folder.  Can be NULL in the IPersistFolder3::InitializeEx()
//                   call but not in the GetFolderTargetInfo() return structure.
// szTargetParsingName: Empty string if not specified. Ortherwise, it is the parsible name
//                       to the target.  This name can be parsed by IShellFolder::
//                       ParsedName() from the desktop.
// szNetworkProvider: Can be an empty string.  If not empty, it specifies the type of network
//                    provider that will be used when binding to the target.  This is used
//                    for performance optimizations for the WNet APIs.
// dwAttributes: -1 if not known.  These are the SFGAO_ flags for IShellFolder::GetAttributesOf()
// csidl: This is -1 if it's not used.  This can be used instead of pidlTargetFolder or
//        szTargetParsingName to indicate the TargetFolder.  See the list of CSIDL_ folders
//        below.  CSIDL_FLAG_PFTI_TRACKTARGET means that the IShellFolder's target folder
//        should change if the user changes the target of the underlying CSIDL value.
//        You can also pass CSIDL_FLAG_CREATE to indicate that the target folder
//        should be created if it does not exist.  No other CSIDL_FLAG_* values are supported.

#include <pshpack8.h>

typedef struct
{
    LPITEMIDLIST  pidlTargetFolder;               // pidl for the folder we want to intiailize
    WCHAR         szTargetParsingName[MAX_PATH];  // optional parsing name for the target
    WCHAR         szNetworkProvider[MAX_PATH];    // optional network provider
    DWORD         dwAttributes;                   // optional FILE_ATTRIBUTES_ flags (-1 if not used)
    int           csidl;                          // optional folder index (SHGetFolderPath()) -1 if not used
} PERSIST_FOLDER_TARGET_INFO;

#include <poppack.h>        /* Return to byte packing */


// DESCRIPTION: IPersistFolder3
//    This interface is implemented by an IShellFolder object that wants non-default
// handling of Folder Shortcuts.  In general, shell name space extensions should use
// pidlRoot (the alias pidl) as their location in the name space and pass it to public
// APIs, such as ShellExecute().  The one exception is that pidlTarget should be used
// when sending ChangeNotifies or registering to listen for change notifies
// (see SFVM_GETNOTIFY).
//
// InitializeEx: This method initializes an IShellFolder and specifies where
//               it is rooted in the name space.
//      pbc: May be NULL.
//      pidlRoot: This is the same parameter as IPersistFolder::Initialize(). Caller allocates
//                and frees this parameter.
//      ppfti: May be NULL, in which case this is the same as a call to IPersistFolder::Initialize().
//             Otherwise this is a Folder Shortcut and this structure specifies the target
//             folder and it's attributes.
// GetFolderTargetInfo: This is used by the caller to find information about
//             the folder shortcut.  This structure may not be initialized by the caller,
//             so the callee needs to initialize every member.  The callee allocates
//             pidlTargetFolder and the caller will free it.  Filling in pidlTargetFolder is
//             ALWAYS required.
DECLARE_INTERFACE_(IPersistFolder3, IPersistFolder2)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface)(THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef)(THIS)  PURE;
    STDMETHOD_(ULONG,Release)(THIS) PURE;

    // *** IPersist methods ***
    STDMETHOD(GetClassID)(THIS_ LPCLSID lpClassID) PURE;

    // *** IPersistFolder methods ***
    STDMETHOD(Initialize)(THIS_ LPCITEMIDLIST pidl) PURE;

    // *** IPersistFolder2 methods ***
    STDMETHOD(GetCurFolder)(THIS_ LPITEMIDLIST *ppidl) PURE;

    // *** IPersistFolder3 methods ***
    STDMETHOD(InitializeEx)(THIS_ IBindCtx *pbc, LPCITEMIDLIST pidlRoot, const PERSIST_FOLDER_TARGET_INFO *ppfti) PURE;
    STDMETHOD(GetFolderTargetInfo)(THIS_ PERSIST_FOLDER_TARGET_INFO *ppfti) PURE;
};

;begin_internal
//
//  this interface is just the IID.  return back
//  a pointer to the IPersist interface if the object
//  implementation is free threaded.  this is used
//  for performance on free threaded objects.
//
#define IPersistFreeThreadedObject IPersist
;end_internal

#endif

//
//  this interface is just the IID.  return back                              ;Internal
//  a pointer to the IDropTarget interface if the                             ;Internal
//  object calls DAD_DragLeave/DAD_SetDragImage                               ;Internal
//  in its IDropTarget::Drop().                                               ;Internal
//                                                                            ;Internal
#define IDropTargetWithDADSupport IDropTarget                                 ;Internal

//===========================================================================
//
// IExtractIcon interface
//
//  This interface is used in two different places in the shell.
//
// Case-1: Icons of sub-folders for the scope-pane of the explorer.
//
//  It is used by the explorer to get the "icon location" of
// sub-folders from each shell folders. When the user expands a folder
// in the scope pane of the explorer, the explorer does following:
//  (1) binds to the folder (gets IShellFolder),
//  (2) enumerates its sub-folders by calling its EnumObjects member,
//  (3) calls its GetUIObjectOf member to get IExtractIcon interface
//     for each sub-folders.
//  In this case, the explorer uses only IExtractIcon::GetIconLocation
// member to get the location of the appropriate icon. An icon location
// always consists of a file name (typically DLL or EXE) and either an icon
// resource or an icon index.
//
//
// Case-2: Extracting an icon image from a file
//
//  It is used by the shell when it extracts an icon image
// from a file. When the shell is extracting an icon from a file,
// it does following:
//  (1) creates the icon extraction handler object (by getting its CLSID
//     under the {ProgID}\shell\ExtractIconHanler key and calling
//     CoCreateInstance requesting for IExtractIcon interface).
//  (2) Calls IExtractIcon::GetIconLocation.
//  (3) Then, calls IExtractIcon::ExtractIcon with the location/index pair.
//  (4) If (3) returns NOERROR, it uses the returned icon.
//  (5) Otherwise, it recursively calls this logic with new location
//     assuming that the location string contains a fully qualified path name.
//
//  From extension programmer's point of view, there are only two cases
// where they provide implementations of IExtractIcon:
//  Case-1) providing explorer extensions (i.e., IShellFolder).
//  Case-2) providing per-instance icons for some types of files.
//
// Because Case-1 is described above, we'll explain only Case-2 here.
//
// When the shell is about display an icon for a file, it does following:
//  (1) Finds its ProgID and ClassID.
//  (2) If the file has a ClassID, it gets the icon location string from the
//    "DefaultIcon" key under it. The string indicates either per-class
//    icon (e.g., "FOOBAR.DLL,2") or per-instance icon (e.g., "%1,1").
//  (3) If a per-instance icon is specified, the shell creates an icon
//    extraction handler object for it, and extracts the icon from it
//    (which is described above).
//
//  It is important to note that the shell calls IExtractIcon::GetIconLocation
// first, then calls IExtractIcon::Extract. Most application programs
// that support per-instance icons will probably store an icon location
// (DLL/EXE name and index/id) rather than an icon image in each file.
// In those cases, a programmer needs to implement only the GetIconLocation
// member and it Extract member simply returns S_FALSE. They need to
// implement Extract member only if they decided to store the icon images
// within files themselved or some other database (which is very rare).
//
//
//
// [Member functions]
//
//
// IExtractIcon::GetIconLocation
//
//  This function returns an icon location.
//
//  Parameters:
//   uFlags     [in]  -- Specifies if it is opened or not (GIL_OPENICON or 0)
//   szIconFile [out] -- Specifies the string buffer buffer for a location name.
//   cchMax     [in]  -- Specifies the size of szIconFile (almost always MAX_PATH)
//   piIndex    [out] -- Sepcifies the address of UINT for the index.
//   pwFlags    [out] -- Returns GIL_* flags
//  Returns:
//   NOERROR, if it returns a valid location; S_FALSE, if the shell use a
//   default icon.
//
//  Notes: The location may or may not be a path to a file. The caller can
//   not assume anything unless the subsequent Extract member call returns
//   S_FALSE.
//
//   if the returned location is not a path to a file, GIL_NOTFILENAME should
//   be set in the returned flags.
//
// IExtractIcon::Extract
//
//  This function extracts an icon image from a specified file.
//
//  Parameters:
//   pszFile [in] -- Specifies the icon location (typically a path to a file).
//   nIconIndex [in] -- Specifies the icon index.
//   phiconLarge [out] -- Specifies the HICON variable for large icon.
//   phiconSmall [out] -- Specifies the HICON variable for small icon.
//   nIconSize [in] -- Specifies the size icon required (size of large icon)
//                     LOWORD is the requested large icon size
//                     HIWORD is the requested small icon size
//  Returns:
//   NOERROR, if it extracted the from the file.
//   S_FALSE, if the caller should extract from the file specified in the
//           location.
//
//===========================================================================

// GetIconLocation() input flags

#define GIL_OPENICON     0x0001      // allows containers to specify an "open" look
#define GIL_FORSHELL     0x0002      // icon is to be displayed in a ShellFolder
#define GIL_ASYNC        0x0020      // this is an async extract, return E_PENDING
#define GIL_DEFAULTICON  0x0040      // get the default icon location if the final one takes too long to get
#define GIL_FORSHORTCUT  0x0080      // the icon is for a shortcut to the object

// GetIconLocation() return flags

#define GIL_SIMULATEDOC  0x0001      // simulate this document icon for this
#define GIL_PERINSTANCE  0x0002      // icons from this class are per instance (each file has its own)
#define GIL_PERCLASS     0x0004      // icons from this class per class (shared for all files of this type)
#define GIL_NOTFILENAME  0x0008      // location is not a filename, must call ::ExtractIcon
#define GIL_DONTCACHE    0x0010      // this icon should not be cached

#undef  INTERFACE
#define INTERFACE   IExtractIconA

DECLARE_INTERFACE_(IExtractIconA, IUnknown)     // exic
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IExtractIcon methods ***
    STDMETHOD(GetIconLocation)(THIS_
                         UINT   uFlags,
                         LPSTR  szIconFile,
                         UINT   cchMax,
                         int   * piIndex,
                         UINT  * pwFlags) PURE;

    STDMETHOD(Extract)(THIS_
                           LPCSTR pszFile,
                           UINT   nIconIndex,
                           HICON   *phiconLarge,
                           HICON   *phiconSmall,
                           UINT    nIconSize) PURE;
};

typedef IExtractIconA * LPEXTRACTICONA;

#undef  INTERFACE
#define INTERFACE   IExtractIconW

DECLARE_INTERFACE_(IExtractIconW, IUnknown)     // exic
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IExtractIcon methods ***
    STDMETHOD(GetIconLocation)(THIS_
                         UINT   uFlags,
                         LPWSTR szIconFile,
                         UINT   cchMax,
                         int   * piIndex,
                         UINT  * pwFlags) PURE;

    STDMETHOD(Extract)(THIS_
                           LPCWSTR pszFile,
                           UINT   nIconIndex,
                           HICON   *phiconLarge,
                           HICON   *phiconSmall,
                           UINT    nIconSize) PURE;
};

typedef IExtractIconW * LPEXTRACTICONW;

#ifdef UNICODE
#define IExtractIcon        IExtractIconW
#define IExtractIconVtbl    IExtractIconWVtbl
#define LPEXTRACTICON       LPEXTRACTICONW
#else
#define IExtractIcon        IExtractIconA
#define IExtractIconVtbl    IExtractIconAVtbl
#define LPEXTRACTICON       LPEXTRACTICONA
#endif

//===========================================================================
//
// IShellIcon Interface
//
// used to get a icon index for a IShellFolder object.
//
// this interface can be implemented by a IShellFolder, as a quick way to
// return the icon for a object in the folder.
//
// a instance of this interface is only created once for the folder, unlike
// IExtractIcon witch is created once for each object.
//
// if a ShellFolder does not implement this interface, the standard
// GetUIObject(....IExtractIcon) method will be used to get a icon
// for all objects.
//
// the following standard imagelist indexs can be returned:
//
//      0   document (blank page) (not associated)
//      1   document (with stuff on the page)
//      2   application (exe, com, bat)
//      3   folder (plain)
//      4   folder (open)
//
// IShellIcon:GetIconOf(pidl, flags, lpIconIndex)
//
//      pidl            object to get icon for.
//      flags           GIL_* input flags (GIL_OPEN, ...)
//      lpIconIndex     place to return icon index.
//
//  returns:
//      NOERROR, if lpIconIndex contains the correct system imagelist index.
//      S_FALSE, if unable to get icon for this object, go through
//               GetUIObject, IExtractIcon, methods.
//
//===========================================================================

#undef  INTERFACE
#define INTERFACE   IShellIcon

DECLARE_INTERFACE_(IShellIcon, IUnknown)      // shi
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IShellIcon methods ***
    STDMETHOD(GetIconOf)(THIS_ LPCITEMIDLIST pidl, UINT flags,
                    LPINT lpIconIndex) PURE;
};

typedef IShellIcon *LPSHELLICON;

//===========================================================================
//
// IShellIconOverlayIdentifier
//
// Used to identify a file as a member of the group of files that have this specific
// icon overlay
//
// Users can create new IconOverlayIdentifiers and place them in the following registry
// location together with the Icon overlay image and their priority.
// HKEY_LOCAL_MACHINE "Software\\Microsoft\\Windows\\CurrentVersion\\ShellIconOverlayIdentifiers"
//
// The shell will enumerate through all IconOverlayIdentifiers at start, and prioritize
// them according to internal rules, in case the internal rules don't apply, we use their
// input priority
//
// IShellIconOverlayIdentifier:IsMemberOf(LPCWSTR pwszPath, DWORD dwAttrib)
//      pwszPath        full path of the file
//      dwAttrib        attribute of this file
//
//  returns:
//      S_OK,    if the file is a member
//      S_FALSE, if the file is not a member
//      E_FAIL,  if the operation failed due to bad WIN32_FIND_DATA
//
// IShellIconOverlayIdentifier::GetOverlayInfo(LPWSTR pwszIconFile, int * pIndex, DWORD * dwFlags) PURE;
//      pszIconFile    the path of the icon file
//      pIndex         Depend on the flags, this could contain the IconIndex
//      dwFlags        defined below
//
// IShellIconOverlayIdentifier::GetPriority(int * pIPriority) PURE;
//      pIPriority     the priority of this Overlay Identifier
//
//===========================================================================

#undef  INTERFACE
#define INTERFACE   IShellIconOverlayIdentifier

DECLARE_INTERFACE_(IShellIconOverlayIdentifier, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IShellIconOverlayIdentifier methods ***
    STDMETHOD (IsMemberOf)(THIS_ LPCWSTR pwszPath, DWORD dwAttrib) PURE;
    STDMETHOD (GetOverlayInfo)(THIS_ LPWSTR pwszIconFile, int cchMax, int * pIndex, DWORD * pdwFlags) PURE;
    STDMETHOD (GetPriority)(THIS_ int * pIPriority) PURE;
};

#define ISIOI_ICONFILE            0x00000001          // path is returned through pwszIconFile
#define ISIOI_ICONINDEX           0x00000002          // icon index in pwszIconFile is returned through pIndex

//===========================================================================
//
// IShellIconOverlayManager
//
// Used to return the icon overlay information including OverlayIndex, Image Index or Priority for an IShellFolder object
;begin_internal
// this is only inherited by CFSFolder_IconOverlayManager, it enumerates through all IconOverlayID's and
// keep their information in an array.
;end_internal
//
// IShellIconOverlayManager:GetFileOverlayInfo(LPCWSTR pwszPath, DWORD dwAttrib, int * pIndex, DWORD dwflags)
//      pwszPath        full path of the file
//      dwAttrib        attribute of this file
//      pIndex          pointer to the Icon Index in the system image list
//      pOverlayIndex   pointer to the OverlayIndex in the system image list
//      pPriority       pointer to the Priority of this overlay
// IShellIconOverlayManager:GetReservedOverlayInfo(LPCWSTR pwszPath, DWORD dwAttrib, int * pIndex, DWORD dwflags, int iReservedID)
//      iReservedID     reserved icon overlay id
//  returns:
//      S_OK,  if the index of an Overlay is found
//      S_FALSE, if no Overlay exists for this file
//      E_FAIL, if lpfd is bad
// IShellIconOverlayManager:RefreshOverlayImages(DWORD dwFlags)
//      This will refresh the overlay cache, depends on the dwFlags passed in
//      It will reload the icons into the imagelist, when passed SIOM_ICONINDEX
// IShellIconOverlayManager::LoadNonloadedOverlayIdentifiers()
//      This method loads any registered overlay identifiers (handlers) that
//      are not currently loaded.
// IShellIconOverlayManager::OverlayIndexFromImageIndex(int iImage, int *piIndex, BOOL fAdd)
//      iImage          existing shell image list index to look for
//      piIndex         returned overlay index
//      fAdd            Add image if not already present?
//===========================================================================

#undef  INTERFACE
#define INTERFACE   IShellIconOverlayManager

DECLARE_INTERFACE_(IShellIconOverlayManager, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IShellIconOverlayManager methods ***
    STDMETHOD(GetFileOverlayInfo)(THIS_ LPCWSTR pwszPath, DWORD dwAttrib, int * pIndex, DWORD dwflags) PURE;
    STDMETHOD(GetReservedOverlayInfo)(THIS_ LPCWSTR pwszPath, DWORD dwAttrib, int * pIndex, DWORD dwflags, int iReservedID) PURE;
    STDMETHOD(RefreshOverlayImages)(THIS_ DWORD dwFlags) PURE;
    STDMETHOD(LoadNonloadedOverlayIdentifiers)(THIS) PURE;
    STDMETHOD(OverlayIndexFromImageIndex)(THIS_ int iImage, int * piIndex, BOOL fAdd) PURE;
};
#define SIOM_OVERLAYINDEX         1
#define SIOM_ICONINDEX            2
// #define SIOM_PRIORITY          3
#define SIOM_RESERVED_SHARED      0
#define SIOM_RESERVED_LINK        1
#define SIOM_RESERVED_SLOWFILE    2

//===========================================================================
//
// IShellIconOverlay
//
// Used to return the icon overlay index or its icon index for an IShellFolder object,
// this is always implemented with IShellFolder
//
// IShellIconOverlay:GetOverlayIndex(LPCITEMIDLIST pidl, DWORD * pdwIndex)
//      pidl            object to identify icon overlay for.
//      pdwIndex        the Overlay Index in the system image list
//
// IShellIconOverlay:GetOverlayIconIndex(LPCITEMIDLIST pidl, DWORD * pdwIndex)
//      pdwIconIndex    the Overlay Icon index in the system image list
// This method is only used for those who are interested in seeing the real bits
// of the Overlay Icon
//
//  returns:
//      S_OK,  if the index of an Overlay is found
//      S_FALSE, if no Overlay exists for this file
//      E_FAIL, if pidl is bad
//
//===========================================================================

#undef  INTERFACE
#define INTERFACE   IShellIconOverlay

DECLARE_INTERFACE_(IShellIconOverlay, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IShellIconOverlay methods ***
    STDMETHOD(GetOverlayIndex)(THIS_ LPCITEMIDLIST pidl, int * pIndex) PURE;
    STDMETHOD(GetOverlayIconIndex)(THIS_ LPCITEMIDLIST pidl, int * pIconIndex) PURE;
};

#define OI_ASYNC 0xFFFFEEEE

//-------------------------------------------------------------------------
//
// SHGetIconOverlayIndex
//
// This function takes the path and icon/res id to the icon and convert it into
// an overlay index in the system image list.
// Note: there are totally only 15 slots for system image overlays, some of which
// was reserved by the system, or taken by the overlayidentifiers, so it's possible
// that this function would fail and return -1;
//
// To get the default overlays in the system, such as the share hand, link shortcut
// and slow files, pass NULL as the file name, then the IDO_SHGIOI_* flags as the icon index
//-------------------------------------------------------------------------

#define IDO_SHGIOI_SHARE  0x0FFFFFFF
#define IDO_SHGIOI_LINK   0x0FFFFFFE
#define IDO_SHGIOI_SLOWFILE 0x0FFFFFFFD
SHSTDAPI_(int) SHGetIconOverlayIndex%(LPCTSTR% pszIconPath, int iIconIndex);

;begin_internal
//===========================================================================
//
// IBrowserBand
//
// IBrowserBand::GetObjectBB(REFIID riid, void **ppv)
//  Obtain a service from the web browser.
//
// IBrowserBand::SetBrowserBandInfo(DWORD dwMask, PBROWSERBANDINFO pbbi)
//  Set browser band properties based on members of browserbandinfo struct
//  specified by dwMask.  These properties include title, deskband mode, and
//  current size.
//
//===========================================================================

typedef struct {
    UINT    cbSize;
    DWORD   dwModeFlags;
    BSTR    bstrTitle;
    SIZE    sizeMin;
    SIZE    sizeMax;
    SIZE    sizeCur;
} BROWSERBANDINFO, *PBROWSERBANDINFO;

#define BBIM_MODEFLAGS  0x00000001
#define BBIM_TITLE      0x00000002
#define BBIM_SIZEMIN    0x00000004
#define BBIM_SIZEMAX    0x00000008
#define BBIM_SIZECUR    0x00000010

#undef  INTERFACE
#define INTERFACE  IBrowserBand
DECLARE_INTERFACE_(IBrowserBand, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface)(THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef)(THIS) PURE;
    STDMETHOD_(ULONG,Release)(THIS) PURE;

    // *** IBrowserBand methods ***
    STDMETHOD(GetObjectBB)(THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD(SetBrowserBandInfo)(THIS_ DWORD dwMask, PBROWSERBANDINFO pbbi) PURE;
    STDMETHOD(GetBrowserBandInfo)(THIS_ DWORD dwMask, PBROWSERBANDINFO pbbi) PURE;
};
;end_internal


#if (_WIN32_IE >= 0x0400)
;begin_internal
// NT4 Console Server included shell32\shlink.h to get structure
// definitions and mimicked shell32\shlink.c to understand the
// stream format so our stream format is fixed forever. This is
// not bad since it was designed with extension in mind. We need
// to publish (as privately as possible) the file format and
// structures needed to read the file format.
//
// The stream format is a SHELL_LINK_DATA followed by
//   if SLDF_HAS_ID_LIST an ILSaveToStream followed by
//   if SLDF_HAS_LINK_INFO a LINKINFO followed by
//   if SLDF_HAS_NAME a STREAMSTRING followed by
//   if SLDF_RELPATH a STREAMSTRING followed by
//   if SLDF_WORKINGDIR a STREAMSTRING followed by
//   if SLDF_HAS_ARGS a STREAMSTRING followed by
//   if SLDF_HAS_ICON_LOCATION a STREAMSTRING followed by
//   SHWriteDataBlockList list of signature blocks
//
// Where a STREAMSTRING is a USHORT count of characters
// followed by that many (SLDF_UNICODE ? WIDE : ANSI) characters.
//
typedef struct {        // sld
    DWORD       cbSize;                 // signature for this data structure
    CLSID       clsid;                  // our GUID
    DWORD       dwFlags;                // SHELL_LINK_DATA_FLAGS enumeration

    DWORD       dwFileAttributes;
    FILETIME    ftCreationTime;
    FILETIME    ftLastAccessTime;
    FILETIME    ftLastWriteTime;
    DWORD       nFileSizeLow;

    int         iIcon;
    int         iShowCmd;
    WORD        wHotkey;
    WORD        wUnused;
    DWORD       dwRes1;
    DWORD       dwRes2;
} SHELL_LINK_DATA, *LPSHELL_LINK_DATA;
;end_internal

// IShellLinkDataList::GetFlags()/SetFlags()
typedef enum {
   SLDF_HAS_ID_LIST         = 0x00000001,   // Shell link saved with ID list
   SLDF_HAS_LINK_INFO       = 0x00000002,   // Shell link saved with LinkInfo
   SLDF_HAS_NAME            = 0x00000004,
   SLDF_HAS_RELPATH         = 0x00000008,
   SLDF_HAS_WORKINGDIR      = 0x00000010,
   SLDF_HAS_ARGS            = 0x00000020,
   SLDF_HAS_ICONLOCATION    = 0x00000040,
   SLDF_UNICODE             = 0x00000080,   // the strings are unicode
   SLDF_FORCE_NO_LINKINFO   = 0x00000100,   // don't create a LINKINFO (make a dumb link)
   SLDF_HAS_EXP_SZ          = 0x00000200,   // the link contains expandable env strings
   SLDF_RUN_IN_SEPARATE     = 0x00000400,   // Run the 16-bit target exe in a separate VDM/WOW
   SLDF_HAS_LOGO3ID         = 0x00000800,   // this link is a special Logo3/MSICD link
   SLDF_HAS_DARWINID        = 0x00001000,   // this link is a special Darwin link
   SLDF_RUNAS_USER          = 0x00002000,   // Run this link as a different user
   SLDF_HAS_EXP_ICON_SZ     = 0x00004000,   // contains expandable env string for icon path
   SLDF_NO_PIDL_ALIAS       = 0x00008000,   // don't ever resolve to a logical location
   SLDF_FORCE_UNCNAME       = 0x00010000,   // make GetPath() prefer the UNC name to the local name
   SLDF_RUN_WITH_SHIMLAYER  = 0x00020000,   // Launch the target of this link w/ shim layer active
   SLDF_RESERVED            = 0x80000000,   // Reserved-- so we can use the low word as an index value in the future
} SHELL_LINK_DATA_FLAGS;

typedef struct tagDATABLOCKHEADER
{
    DWORD   cbSize;             // Size of this extra data block
    DWORD   dwSignature;        // signature of this extra data block
} DATABLOCK_HEADER, *LPDATABLOCK_HEADER, *LPDBLIST;

typedef struct {
#ifdef __cplusplus
    DATABLOCK_HEADER dbh;
#else
    DATABLOCK_HEADER;
#endif
    WORD     wFillAttribute;         // fill attribute for console
    WORD     wPopupFillAttribute;    // fill attribute for console popups
    COORD    dwScreenBufferSize;     // screen buffer size for console
    COORD    dwWindowSize;           // window size for console
    COORD    dwWindowOrigin;         // window origin for console
    DWORD    nFont;
    DWORD    nInputBufferSize;
    COORD    dwFontSize;
    UINT     uFontFamily;
    UINT     uFontWeight;
    WCHAR    FaceName[LF_FACESIZE];
    UINT     uCursorSize;
    BOOL     bFullScreen;
    BOOL     bQuickEdit;
    BOOL     bInsertMode;
    BOOL     bAutoPosition;
    UINT     uHistoryBufferSize;
    UINT     uNumberOfHistoryBuffers;
    BOOL     bHistoryNoDup;
    COLORREF ColorTable[ 16 ];
} NT_CONSOLE_PROPS, *LPNT_CONSOLE_PROPS;
#define NT_CONSOLE_PROPS_SIG 0xA0000002

// This is a FE Console property
typedef struct {
#ifdef __cplusplus
    DATABLOCK_HEADER dbh;
#else
    DATABLOCK_HEADER;
#endif
    UINT     uCodePage;
} NT_FE_CONSOLE_PROPS, *LPNT_FE_CONSOLE_PROPS;
#define NT_FE_CONSOLE_PROPS_SIG 0xA0000004

#if (_WIN32_IE >= 0x0500)
typedef struct {
#ifdef __cplusplus
    DATABLOCK_HEADER dbh;
#else
    DATABLOCK_HEADER;
#endif
    CHAR        szDarwinID[MAX_PATH];  // ANSI darwin ID associated with link
    WCHAR       szwDarwinID[MAX_PATH]; // UNICODE darwin ID associated with link
} EXP_DARWIN_LINK, *LPEXP_DARWIN_LINK;
#define EXP_DARWIN_ID_SIG       0xA0000006
// BUGBUG (reinerf) - this has the same value as EXP_SZ_ICON_SIG?!?!?!
#define EXP_LOGO3_ID_SIG        0xA0000007
#endif

#define EXP_SPECIAL_FOLDER_SIG         0xA0000005   // LPEXP_SPECIAL_FOLDER

;begin_internal
typedef struct
{
    DWORD       cbSize;             // Size of this extra data block
    DWORD       dwSignature;        // signature of this extra data block
} EXP_HEADER, *LPEXP_HEADER;
;end _internal

typedef struct
{
    DWORD       cbSize;             // Size of this extra data block
    DWORD       dwSignature;        // signature of this extra data block
    DWORD       idSpecialFolder;    // special folder id this link points into
    DWORD       cbOffset;           // ofset into pidl from SLDF_HAS_ID_LIST for child
} EXP_SPECIAL_FOLDER, *LPEXP_SPECIAL_FOLDER;


;begin_internal
typedef struct
{
    DWORD       cbSize;             // Size of this extra data block
    DWORD       dwSignature;        // signature of this extra data block
    BYTE        abTracker[ 1 ];     //
} EXP_TRACKER, *LPEXP_TRACKER;
#define EXP_TRACKER_SIG                0xA0000003   // LPEXP_TRACKER

typedef struct
{
    DWORD       cbSize;             // Size of this extra data block
    DWORD       dwSignature;        // signature of this extra data block
    WCHAR       wszLayerEnvName[64]; // name of shim layer to run with this link (eg "NT4SP5")
} EXP_SHIMLAYER;
#define EXP_SHIMLAYER_SIG              0xA0000008

;end_internal

typedef struct
{
    DWORD       cbSize;             // Size of this extra data block
    DWORD       dwSignature;        // signature of this extra data block
    CHAR        szTarget[ MAX_PATH ];   // ANSI target name w/EXP_SZ in it
    WCHAR       swzTarget[ MAX_PATH ];  // UNICODE target name w/EXP_SZ in it
} EXP_SZ_LINK, *LPEXP_SZ_LINK;
#define EXP_SZ_LINK_SIG                0xA0000001   // LPEXP_SZ_LINK (target)
#define EXP_SZ_ICON_SIG                0xA0000007   // LPEXP_SZ_LINK (icon)

;begin_internal
// NT40 Console Control Panel Applet does a CoCreateInstance(CLSID_CShellLink),
// used the CShellLink definition to get the 'this' pointer, and passed that
// along to some private exports in shell32. This completely prevents us
// from moving the CShellLink implementation to another DLL. (If we do, or an
// ISV takes our stream format and implements a better link by pointing the
// classid to their implementation, the NT40 Console CPA will fault.)
//
// To fix this problem in future revs, CShellLink will support IShellLinkDataList
//   AddDataBlock    adds the data block
//   FindDataBloc    returns a LocalAlloc()d COPY of a data block with the
//                   signature dwSig (NOTE: this is different than SHFindDataBlock)
//   RemoveDataBlock removes a data block with signature dwSig
// Plan is for NT50's Console CPA to use this interface instead.
//
;end_internal
#undef  INTERFACE
#define INTERFACE IShellLinkDataList

DECLARE_INTERFACE_(IShellLinkDataList, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG, AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG, Release) (THIS) PURE;

    // *** IShellLinkDataList methods ***
    STDMETHOD(AddDataBlock)(THIS_ void * pDataBlock) PURE;
    STDMETHOD(CopyDataBlock)(THIS_ DWORD dwSig, void **ppDataBlock) PURE;
    STDMETHOD(RemoveDataBlock)(THIS_ DWORD dwSig) PURE;
    STDMETHOD(GetFlags)(THIS_ DWORD *pdwFlags) PURE;
    STDMETHOD(SetFlags)(THIS_ DWORD dwFlags) PURE;
};

#endif // (_WIN32_IE >= 0x0400)

#if (_WIN32_IE >= 0x0500)
#undef  INTERFACE
#define INTERFACE IResolveShellLink

DECLARE_INTERFACE_(IResolveShellLink, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG, AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG, Release) (THIS) PURE;

    // *** IResolveShellLink methods ***
    STDMETHOD(ResolveShellLink)(THIS_ IUnknown* punk, HWND hwnd, DWORD fFlags) PURE;
};
#endif // (_WIN32_IE >= 0x0500)


#ifdef _INC_SHELLAPI    /* for LPSHELLEXECUTEINFO */
//===========================================================================
//
// IShellExecuteHook Interface
//
//===========================================================================

#undef  INTERFACE
#define INTERFACE   IShellExecuteHookA

DECLARE_INTERFACE_(IShellExecuteHookA, IUnknown) // shexhk
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG, AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG, Release) (THIS) PURE;

    // *** IShellExecuteHookA methods ***
    STDMETHOD(Execute)(THIS_ LPSHELLEXECUTEINFOA pei) PURE;
};

#undef  INTERFACE
#define INTERFACE   IShellExecuteHookW

DECLARE_INTERFACE_(IShellExecuteHookW, IUnknown) // shexhk
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG, AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG, Release) (THIS) PURE;

    // *** IShellExecuteHookW methods ***
    STDMETHOD(Execute)(THIS_ LPSHELLEXECUTEINFOW pei) PURE;
};

#ifdef UNICODE
#define IShellExecuteHook       IShellExecuteHookW
#define IShellExecuteHookVtbl   IShellExecuteHookWVtbl
#else
#define IShellExecuteHook       IShellExecuteHookA
#define IShellExecuteHookVtbl   IShellExecuteHookAVtbl
#endif
#endif

//===========================================================================
//
// IURLSearchHook Interface
;begin_internal

//
// IURLSearchHook Interface is called whenever the browser navigates to a
// non-standard URL. It can be used to redirect the user's request to a
// search engine or a specific web site.
//
// A non-standard URL does not have a protocol prefix (e.g.,
// "www.microsoft.com") and the protocol cannot be easily guessed by
// the browser (e.g., "home.microsoft.com").
//
// The parameters of Translate(..)
//    lpwszSearchURL -- (IN/OUT) Wide char buffer that contains the request
//                      "URL" user typed in as input and the tranlated URL
//                      as output.
//    cchBufferSize  -- (IN) size of lpwszSearchURL
//
// Return Values:
// S_OK         Search handled completely, pszResult has the full URL to
//              browse to.  Stop running any further IURLSearchHooks and
//              pass this URL back to the browser for browsing.
//
// S_FALSE      Query has been preprocessed, pszResult has the result of
//              the preprocess, further search still needed. Go on
//              executing the rest of the IURLSearchHooks.  The
//              preprocessing steps can be:
//
//                      1. replaced certain characters
//                      2. added more hints
//
// E_ABORT      Search handled completely, stop running any further
//              IURLSearchHooks, but NO BROWSING NEEDED as a result,
//              pszResult is a copy of pcszQuery.
//
//              ;BUGBUG: This is not fully implemented, yet, making IURLQualify return this  ;Internal
//              involves too much change.                                                   ;Internal
//                                                                                          ;Internal
// BUGBUG:: E_ABORT is currently treated as E_FAIL. It requires too much change.            ;Internal
//
// E_FAIL       This Hook was unsuccessful. Search not handled at all,
//              pcszQueryURL has the query string. Please go on running
//              other IURLSearchHooks.
//
// BUGBUG:  There is a potential danger in this Interface, that is people can write         ;Internal
//          very bad SearchHooks, but we (Microsoft) take the blame.                        ;Internal

;end_internal
//
//===========================================================================

#undef  INTERFACE
#define INTERFACE   IURLSearchHook

DECLARE_INTERFACE_(IURLSearchHook, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG, AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG, Release) (THIS) PURE;

    // *** IURLSearchHook methods ***
    STDMETHOD(Translate)(THIS_ LPWSTR lpwszSearchURL, DWORD cchBufferSize) PURE;
};

#undef  INTERFACE
#define INTERFACE   ISearchContext

DECLARE_INTERFACE_(ISearchContext, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG, AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG, Release) (THIS) PURE;

    // *** ISearchContext methods ***
    STDMETHOD(GetSearchUrl)(THIS_ BSTR * pbstrSearchUrl) PURE;
    STDMETHOD(GetSearchText)(THIS_ BSTR * pbstrSearchText) PURE;
    STDMETHOD(GetSearchStyle)(THIS_ DWORD * pdwSearchStyle) PURE;
};

#undef  INTERFACE
#define INTERFACE   IURLSearchHook2

DECLARE_INTERFACE_(IURLSearchHook2, IURLSearchHook)
{
    // *** IURLSearchHook2 methods ***
    STDMETHOD(TranslateWithSearchContext)(THIS_ LPWSTR lpwszSearchURL, DWORD cchBufferSize, ISearchContext * pSearchContext) PURE;
};

//===========================================================================
//
// INewShortcutHook Interface
//
//===========================================================================

#undef  INTERFACE
#define INTERFACE   INewShortcutHookA

DECLARE_INTERFACE_(INewShortcutHookA, IUnknown) // nshhk
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG, AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG, Release) (THIS) PURE;

    // *** INewShortcutHook methods ***
    STDMETHOD(SetReferent)(THIS_ LPCSTR pcszReferent, HWND hwnd) PURE;
    STDMETHOD(GetReferent)(THIS_ LPSTR pszReferent, int cchReferent) PURE;
    STDMETHOD(SetFolder)(THIS_ LPCSTR pcszFolder) PURE;
    STDMETHOD(GetFolder)(THIS_ LPSTR pszFolder, int cchFolder) PURE;
    STDMETHOD(GetName)(THIS_ LPSTR pszName, int cchName) PURE;
    STDMETHOD(GetExtension)(THIS_ LPSTR pszExtension, int cchExtension) PURE;
};

#undef  INTERFACE
#define INTERFACE   INewShortcutHookW

DECLARE_INTERFACE_(INewShortcutHookW, IUnknown) // nshhk
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG, AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG, Release) (THIS) PURE;

    // *** INewShortcutHook methods ***
    STDMETHOD(SetReferent)(THIS_ LPCWSTR pcszReferent, HWND hwnd) PURE;
    STDMETHOD(GetReferent)(THIS_ LPWSTR pszReferent, int cchReferent) PURE;
    STDMETHOD(SetFolder)(THIS_ LPCWSTR pcszFolder) PURE;
    STDMETHOD(GetFolder)(THIS_ LPWSTR pszFolder, int cchFolder) PURE;
    STDMETHOD(GetName)(THIS_ LPWSTR pszName, int cchName) PURE;
    STDMETHOD(GetExtension)(THIS_ LPWSTR pszExtension, int cchExtension) PURE;
};

#ifdef UNICODE
#define INewShortcutHook        INewShortcutHookW
#define INewShortcutHookVtbl    INewShortcutHookWVtbl
#else
#define INewShortcutHook        INewShortcutHookA
#define INewShortcutHookVtbl    INewShortcutHookAVtbl
#endif

//===========================================================================
//
// ICopyHook Interface
//
//  The copy hook is called whenever file system directories are
//  copy/moved/deleted/renamed via the shell.  It is also called by the shell
//  on changes of status of printers.
//
//  Clients register their id under STRREG_SHEX_COPYHOOK for file system hooks
//  and STRREG_SHEx_PRNCOPYHOOK for printer hooks.
//  the CopyCallback is called prior to the action, so the hook has the chance
//  to allow, deny or cancel the operation by returning the falues:
//     IDYES  -  means allow the operation
//     IDNO   -  means disallow the operation on this file, but continue with
//              any other operations (eg. batch copy)
//     IDCANCEL - means disallow the current operation and cancel any pending
//              operations
//
//   arguments to the CopyCallback
//      hwnd - window to use for any UI
//      wFunc - what operation is being done
//      wFlags - and flags (FOF_*) set in the initial call to the file operation
//      pszSrcFile - name of the source file
//      dwSrcAttribs - file attributes of the source file
//      pszDestFile - name of the destiation file (for move and renames)
//      dwDestAttribs - file attributes of the destination file
//
//
//===========================================================================

#ifndef FO_MOVE //these need to be kept in sync with the ones in shellapi.h

// file operations

#define FO_MOVE           0x0001
#define FO_COPY           0x0002
#define FO_DELETE         0x0003
#define FO_RENAME         0x0004

#define FOF_MULTIDESTFILES         0x0001
#define FOF_CONFIRMMOUSE           0x0002
#define FOF_SILENT                 0x0004  // don't create progress/report
#define FOF_RENAMEONCOLLISION      0x0008
#define FOF_NOCONFIRMATION         0x0010  // Don't prompt the user.
#define FOF_WANTMAPPINGHANDLE      0x0020  // Fill in SHFILEOPSTRUCT.hNameMappings
                                      // Must be freed using SHFreeNameMappings
#define FOF_ALLOWUNDO              0x0040
#define FOF_FILESONLY              0x0080  // on *.*, do only files
#define FOF_SIMPLEPROGRESS         0x0100  // means don't show names of files
#define FOF_NOCONFIRMMKDIR         0x0200  // don't confirm making any needed dirs
#define FOF_NOERRORUI              0x0400  // don't put up error UI
#define FOF_NOCOPYSECURITYATTRIBS  0x0800  // dont copy NT file Security Attributes
#define FOF_NORECURSION            0x1000  // don't recurse into directories.
#if (_WIN32_IE >= 0x500)
#define FOF_NO_CONNECTED_ELEMENTS  0x2000  // don't operate on connected file elements.
#define FOF_WANTNUKEWARNING        0x4000  // during delete operation, warn if nuking instead of recycling (partially overrides FOF_NOCONFIRMATION)
#endif // _WIN32_IE >= 0x500
#if (_WIN32_WINNT >= 0x0501)
#define FOF_NORECURSEREPARSE       0x8000  // treat reparse points as objects, not containers
#endif // (_WIN32_WINNT >= 0x501)

typedef WORD FILEOP_FLAGS;

// printer operations

#define PO_DELETE       0x0013  // printer is being deleted
#define PO_RENAME       0x0014  // printer is being renamed
#define PO_PORTCHANGE   0x0020  // port this printer connected to is being changed
                                // if this id is set, the strings received by
                                // the copyhook are a doubly-null terminated
                                // list of strings.  The first is the printer
                                // name and the second is the printer port.
#define PO_REN_PORT     0x0034  // PO_RENAME and PO_PORTCHANGE at same time.

// no POF_ flags currently defined

typedef UINT PRINTEROP_FLAGS;

#endif // FO_MOVE

#undef  INTERFACE
#define INTERFACE   ICopyHookA

DECLARE_INTERFACE_(ICopyHookA, IUnknown)        // sl
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** ICopyHook methods ***
    STDMETHOD_(UINT,CopyCallback) (THIS_ HWND hwnd, UINT wFunc, UINT wFlags, LPCSTR pszSrcFile, DWORD dwSrcAttribs,
                                   LPCSTR pszDestFile, DWORD dwDestAttribs) PURE;
};

typedef ICopyHookA *    LPCOPYHOOKA;

#undef  INTERFACE
#define INTERFACE   ICopyHookW

DECLARE_INTERFACE_(ICopyHookW, IUnknown)        // sl
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** ICopyHook methods ***
    STDMETHOD_(UINT,CopyCallback) (THIS_ HWND hwnd, UINT wFunc, UINT wFlags, LPCWSTR pszSrcFile, DWORD dwSrcAttribs,
                                   LPCWSTR pszDestFile, DWORD dwDestAttribs) PURE;
};

typedef ICopyHookW *    LPCOPYHOOKW;

#ifdef UNICODE
#define ICopyHook       ICopyHookW
#define ICopyHookVtbl   ICopyHookWVtbl
#define LPCOPYHOOK      LPCOPYHOOKW
#else
#define ICopyHook       ICopyHookA
#define ICopyHookVtbl   ICopyHookAVtbl
#define LPCOPYHOOK      LPCOPYHOOKA
#endif

//===========================================================================
//
// IFileViewerSite Interface
//
// History:                                                   ;Internal
//  --/--/94 KurtE Created                                    ;Internal
//                                                            ;Internal
//===========================================================================

#undef  INTERFACE
#define INTERFACE   IFileViewerSite

DECLARE_INTERFACE_(IFileViewerSite, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IFileViewerSite methods ***
    STDMETHOD(SetPinnedWindow) (THIS_ HWND hwnd) PURE;
    STDMETHOD(GetPinnedWindow) (THIS_ HWND *phwnd) PURE;
};

typedef IFileViewerSite * LPFILEVIEWERSITE;


//===========================================================================
//
// IFileViewer Interface
//
// Implemented in a FileViewer component object.  Used to tell a
// FileViewer to PrintTo or to view, the latter happening though
// ShowInitialize and Show.  The filename is always given to the
// viewer through IPersistFile.
//
// History:                                                   ;Internal
//  3/4/94 kraigb Created                                     ;Internal
//                                                            ;Internal
//===========================================================================

#include <pshpack8.h>

typedef struct
{
    // Stuff passed into viewer (in)
    DWORD cbSize;           // Size of structure for future expansion...
    HWND hwndOwner;         // who is the owner window.
    int iShow;              // The show command

    // Passed in and updated  (in/Out)
    DWORD dwFlags;          // flags
    RECT rect;              // Where to create the window may have defaults
    IUnknown *punkRel;      // Relese this interface when window is visible

    // Stuff that might be returned from viewer (out)
    OLECHAR strNewFile[MAX_PATH];   // New File to view.

} FVSHOWINFO, *LPFVSHOWINFO;

#include <poppack.h>        /* Return to byte packing */

    // Define File View Show Info Flags.
#define FVSIF_RECT      0x00000001      // The rect variable has valid data.
#define FVSIF_PINNED    0x00000002      // We should Initialize pinned

#define FVSIF_NEWFAILED 0x08000000      // The new file passed back failed
                                        // to be viewed.

#define FVSIF_NEWFILE   0x80000000      // A new file to view has been returned
#define FVSIF_CANVIEWIT 0x40000000      // The viewer can view it.

#undef  INTERFACE
#define INTERFACE   IFileViewerA

DECLARE_INTERFACE(IFileViewerA)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IFileViewer methods ***
    STDMETHOD(ShowInitialize) (THIS_ LPFILEVIEWERSITE lpfsi) PURE;
    STDMETHOD(Show) (THIS_ LPFVSHOWINFO pvsi) PURE;
    STDMETHOD(PrintTo) (THIS_ LPSTR pszDriver, BOOL fSuppressUI) PURE;
};

typedef IFileViewerA * LPFILEVIEWERA;

#undef  INTERFACE
#define INTERFACE   IFileViewerW

DECLARE_INTERFACE(IFileViewerW)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IFileViewer methods ***
    STDMETHOD(ShowInitialize) (THIS_ LPFILEVIEWERSITE lpfsi) PURE;
    STDMETHOD(Show) (THIS_ LPFVSHOWINFO pvsi) PURE;
    STDMETHOD(PrintTo) (THIS_ LPWSTR pszDriver, BOOL fSuppressUI) PURE;
};

typedef IFileViewerW * LPFILEVIEWERW;

#ifdef UNICODE
#define IFileViewer IFileViewerW
#define LPFILEVIEWER LPFILEVIEWERW
#else
#define IFileViewer IFileViewerA
#define LPFILEVIEWER LPFILEVIEWERA
#endif



;begin_internal

//  CGID_DefView Command Target IDs. used to persist global DefView state

enum
{
    DVID_SETASDEFAULT,          // Set the DefView state of this folder as default for all of the same class
    DVID_RESETDEFAULT           // Reset the DefView state to the default (delete subkeys)
};

// CGID_ShellDocView Command Target IDs. for shell doc view wedge
enum {
    SHDVID_FINALTITLEAVAIL,     // DEAD: variantIn bstr - sent after final OLECMDID_SETTITLE is sent
    SHDVID_MIMECSETMENUOPEN,    // mimecharset menu open commands
    SHDVID_PRINTFRAME,          // print HTML frame
    SHDVID_PUTOFFLINE,          // DEAD: The Offline property has been changed
    SHDVID_PUTSILENT,           // DEAD: The frame's Silent property has been changed
    SHDVID_GOBACK,              // Navigate Back
    SHDVID_GOFORWARD,           // Navigate Forward
    SHDVID_CANGOBACK,           // Is Back Navigation Possible?
    SHDVID_CANGOFORWARD,        // Is Forward Navigation Possible?
    SHDVID_CANACTIVATENOW,      // (down) (PICS) OK to navigate to this view now?
    SHDVID_ACTIVATEMENOW,       // (up) (PICS) Rating checks out, navigate now
    SHDVID_CANSUPPORTPICS,      // (down) variantIn I4: IOleCommandTarget to reply to
    SHDVID_PICSLABELFOUND,      // (up) variantIn bstr: PICS label
    SHDVID_NOMOREPICSLABELS,    // (up) End of document, no more PICS labels coming
    SHDVID_CANDEACTIVATENOW,    // (QS down) (in script/etc) OK to deactivate view now?
    SHDVID_DEACTIVATEMENOW,     // (EXEC up) (in script/etc) out of script, deactivate view now
    SHDVID_NODEACTIVATENOW,     // (EXEC up) (in script/etc) entering script, disable deactivate
    SHDVID_AMBIENTPROPCHANGE,   // variantIn I4: dispid of ambient property that changed
    SHDVID_GETSYSIMAGEINDEX,    // variantOut: image index for current page
    SHDVID_GETPENDINGOBJECT,    // variantOut: IUnknown of pending shellview/docobject
    SHDVID_GETPENDINGURL,       // variantOut: BSTR of URL for pending docobject
    SHDVID_SETPENDINGURL,       // variantIn: BSTR of URL passed to pending docobject
    SHDVID_ISDRAGSOURCE,        // (down) varioutOut I4: non-zero if it's initiated drag&drop
    SHDVID_DOCFAMILYCHARSET,    // variantOut: I4: windows (family) codepage
    SHDVID_DOCCHARSET,          // variantOut: I4: actual (mlang) codepage
    SHDVID_RAISE,               // vaIn:I4:DTRF_*, vaOut:NULL unless DTRF_QUERY
    SHDVID_GETTRANSITION,       // (down) vaIn: I4: TransitionEvent; vaOut BSTR (CLSID), I4 (dwSpeed)
    SHDVID_GETMIMECSETMENU,     // get menu handle for mimecharset
    SHDVID_DOCWRITEABORT,       // Abort binding but activate pending docobject
    SHDVID_SETPRINTSTATUS,      // VariantIn: BOOL, TRUE - Started printing, FALSE - Finished printing
    SHDVID_NAVIGATIONSTATUS,    // QS for tooltip text and Exec when user clicks
    SHDVID_PROGRESSSTATUS,      // QS for tooltip text and Exec when user clicks
    SHDVID_ONLINESTATUS,        // QS for tooltip text and Exec when user clicks
    SHDVID_SSLSTATUS,           // QS for tooltip text and Exec when user clicks
    SHDVID_PRINTSTATUS,         // QS for tooltip text and Exec when user clicks
    SHDVID_ZONESTATUS,          // QS for tooltip text and Exec when user clicks
    SHDVID_ONCODEPAGECHANGE,    // variantIn I4: new specified codepage
    SHDVID_SETSECURELOCK,       // set the secure icon
    SHDVID_SHOWBROWSERBAR,      // show browser bar of clsid guid
    SHDVID_NAVIGATEBB,          // navigate to pidl in browserbar.
    SHDVID_UPDATEOFFLINEDESKTOP,// put the desktop in ON-LINE mode, update and put it back in Offline mode
    SHDVID_PICSBLOCKINGUI,      // (up) In I4: pointer to "ratings nugget" for block API
    SHDVID_ONCOLORSCHANGE,      // (up) sent by mshtml to indicate color set change
    SHDVID_CANDOCOLORSCHANGE,   // (down) used to query if document supports the above
    SHDVID_QUERYMERGEDHELPMENU, // was the help menu micro-merged?
    SHDVID_QUERYOBJECTSHELPMENU,// return the object's help menu
    SHDVID_HELP,                // do help
    SHDVID_UEMLOG,              // set UEM logging vaIn:I4:UEMIND_*, vaOut:NULL
    SHDVID_GETBROWSERBAR,       // get IDeskBand for browser bar of clsid guid
    SHDVID_GETFONTMENU,
    SHDVID_FONTMENUOPEN,
    SHDVID_CLSIDTOIDM,          // get the idm for the given clsid
    SHDVID_GETDOCDIRMENU,       // get menu handle for document direction
    SHDVID_ADDMENUEXTENSIONS,   // Context Menu Extensions
    SHDVID_CLSIDTOMONIKER,      // CLSID to property page resource mapping
    SHDVID_RESETSTATUSBAR,      // set the status bar back to "normal" icon w/out text
    SHDVID_ISBROWSERBARVISIBLE, // is browser bar of clsid guid visible?
    SHDVID_GETOPTIONSHWND,      // gets hwnd for internet options prop sheet (NULL if not open)
    SHDVID_DELEGATEWINDOWOM,    // set policy for whether window OM methods should be delegated.
    SHDVID_PAGEFROMPOSTDATA,    // determines if page was generated by post data
    SHDVID_DISPLAYSCRIPTERRORS, // tells the top docobject host to display his script err dialog
    SHDVID_NAVIGATEBBTOURL,     // Navigate to an URL in browserbar (used in Trident).
    SHDVID_NAVIGATEFROMDOC,     // The document delegated the navigation for a non-html mime-type.
    SHDVID_STARTPICSFORWINDOW,  // (up) variantIn: IUnknown of window that is navigating
                                //      variantOut: bool if pics process started
    SHDVID_CANCELPICSFORWINDOW, // (up) variantIn: IUnknown of window that is no longer navigating
    SHDVID_ISPICSENABLED,       // (up) variantOut: bool
    SHDVID_PICSLABELFOUNDINHTTPHEADER,// (up) variantIn bstr: PICS label
    SHDVID_CHECKINCACHEIFOFFLINE, // Check in cache if offline
    SHDVID_CHECKDONTUPDATETLOG,   // check if the current navigate is already dealing with the travellog correctly
    SHDVID_UPDATEDOCHOSTSTATE,    // Sent from CBaseBrowser2::_UpdateBrowserState to tell the dochost to update its state.
    SHDVID_FIREFILEDOWNLOAD,
    SHDVID_COMPLETEDOCHOSTPASSING,
    SHDVID_NAVSTART,
    SHDVID_SETNAVIGATABLECODEPAGE,
    SHDVID_WINDOWOPEN,
    SHDVID_PRIVACYSTATUS,        // QS for tooltip text and exec when user clicks
    SHDVID_FORWARDSECURELOCK,   // asks CDocObjectHost to forward its security status up to the shell browser
    SHDVID_ISEXPLORERBARVISIBLE, // is any explorer bar visible?
};

// CGID_DocHostCmdPriv Command Target IDs
//
enum
{
    DOCHOST_DOCCANNAVIGATE,     // The document knows how to navigate.
    DOCHOST_NAVIGATION_ERROR,   // Navigation Error
    DOCHOST_DOCHYPERLINK,       // The document is navigating.
    DOCHOST_SENDINGREQUEST,     // The document is sending a request for download. Update the progress bar.
    DOCHOST_FINDINGRESOURCE,    // The document is finding a resource. Update the progress bar.
    DOCHOST_RESETSEARCHINFO,    // Reset search information (after a successful navigation)
    DOCHOST_SETBROWSERINDEX,    // Sets the browser ID to use for TravelLog and frame targeting
    DOCHOST_NOTE_ERROR_PAGE,    // Need to know when we're navigating to an error web page.
    DOCHOST_READYSTATE_INTERACTIVE, // a document on a page is readystate interactive
    DOCHOST_CONTENTDISPOSITIONATTACH // The document needs to be saved.

};

// CGID_SearchBand Command Target IDs.
enum {
    SBID_SEARCH_NEW,            // (re)load the context-appropriate url
    SBID_SEARCH_NEXT,           // cycle between multiple providers
    SBID_SEARCH_CUSTOMIZE,      // navigate to customization url
    SBID_SEARCH_HELP,           // what it says
    SBID_GETPIDL,               // get the search pane's pidl
    SBID_HASPIDL,               // does the search pane have a pidl (i.e, has it navigated)
};

// CGID_MediaBar target ids
enum {
    MBID_PLAY,     // Play an url
    MBID_POPOUT    // Detect state of player
};

enum {
    MB_DOCKED,
    MB_POPOUT
};


//
// Private struct passed as argument to SHDVID_UPDATEDOCHOSTSTATE
//
struct DOCHOSTUPDATEDATA
{
    LPITEMIDLIST    _pidl;
    BOOL            _fIsErrorUrl;
};


//
//  this enum is used by SHDVID_SETSECURELOCK and SBCMDID_SETSECURELOCKICON
//  when adding new values, make sure to add to both SET and SUGGEST, and
//  the code depends on a direct correlation between the level of security
//  and the value of the enum.  so keep new values in the correct order
//
enum {
    SECURELOCK_NOCHANGE        = -1,
    SECURELOCK_SET_UNSECURE    = 0,
    SECURELOCK_SET_MIXED,
    SECURELOCK_SET_SECUREUNKNOWNBIT,
    SECURELOCK_SET_SECURE40BIT,
    SECURELOCK_SET_SECURE56BIT,
    SECURELOCK_SET_FORTEZZA,
    SECURELOCK_SET_SECURE128BIT,
    SECURELOCK_FIRSTSUGGEST,
    SECURELOCK_SUGGEST_UNSECURE = SECURELOCK_FIRSTSUGGEST,
    SECURELOCK_SUGGEST_MIXED,
    SECURELOCK_SUGGEST_SECUREUNKNOWNBIT,
    SECURELOCK_SUGGEST_SECURE40BIT,
    SECURELOCK_SUGGEST_SECURE56BIT,
    SECURELOCK_SUGGEST_FORTEZZA,
    SECURELOCK_SUGGEST_SECURE128BIT,
};

;end_internal



//==========================================================================
//
// IShellBrowser/IShellView/IShellFolder interface
//
//  These three interfaces are used when the shell communicates with
// name space extensions. The shell (explorer) provides IShellBrowser
// interface, and extensions implements IShellFolder and IShellView
// interfaces.
//
//==========================================================================


//--------------------------------------------------------------------------
//
// Command/menuitem IDs
//
//  The explorer dispatches WM_COMMAND messages based on the range of
// command/menuitem IDs. All the IDs of menuitems that the view (right
// pane) inserts must be in FCIDM_SHVIEWFIRST/LAST (otherwise, the explorer
// won't dispatch them). The view should not deal with any menuitems
// in FCIDM_BROWSERFIRST/LAST (otherwise, it won't work with the future
// version of the shell).
//
//  FCIDM_SHVIEWFIRST/LAST      for the right pane (IShellView)
//  FCIDM_BROWSERFIRST/LAST     for the explorer frame (IShellBrowser)
//  FCIDM_GLOBAL/LAST           for the explorer's submenu IDs
//
//--------------------------------------------------------------------------

#define FCIDM_SHVIEWFIRST           0x0000
#define FCIDM_SHVIEWLAST            0x7fff
#define FCIDM_BROWSERFIRST          0xa000
#define FCIDM_BROWSERLAST           0xbf00
#define FCIDM_GLOBALFIRST           0x8000
#define FCIDM_GLOBALLAST            0x9fff

//
// Global submenu IDs and separator IDs
//
#define FCIDM_MENU_FILE             (FCIDM_GLOBALFIRST+0x0000)
#define FCIDM_MENU_EDIT             (FCIDM_GLOBALFIRST+0x0040)
#define FCIDM_MENU_VIEW             (FCIDM_GLOBALFIRST+0x0080)
#define FCIDM_MENU_VIEW_SEP_OPTIONS (FCIDM_GLOBALFIRST+0x0081)
#define FCIDM_MENU_TOOLS            (FCIDM_GLOBALFIRST+0x00c0) // for Win9x compat
#define FCIDM_MENU_TOOLS_SEP_GOTO   (FCIDM_GLOBALFIRST+0x00c1) // for Win9x compat
#define FCIDM_MENU_HELP             (FCIDM_GLOBALFIRST+0x0100)
#define FCIDM_MENU_FIND             (FCIDM_GLOBALFIRST+0x0140)
#define FCIDM_MENU_EXPLORE          (FCIDM_GLOBALFIRST+0x0150)
#define FCIDM_MENU_FAVORITES        (FCIDM_GLOBALFIRST+0x0170)

//--------------------------------------------------------------------------
// control IDs known to the view
//--------------------------------------------------------------------------

#define FCIDM_TOOLBAR      (FCIDM_BROWSERFIRST + 0)
#define FCIDM_STATUS       (FCIDM_BROWSERFIRST + 1)
#define FCIDM_DRIVELIST    (FCIDM_BROWSERFIRST + 2) // ;Internal
#define FCIDM_TREE         (FCIDM_BROWSERFIRST + 3) // ;Internal
#define FCIDM_TABS         (FCIDM_BROWSERFIRST + 4) // ;Internal
#define FCIDM_REBAR        (FCIDM_BROWSERFIRST + 5) // ;Internal


#if (_WIN32_IE >= 0x0400)
//--------------------------------------------------------------------------
//
// The resource id of the offline cursor
// This cursor is avaialble in shdocvw.dll
#define IDC_OFFLINE_HAND        103
//
//--------------------------------------------------------------------------
#endif

;begin_internal
// SBCMDID_SHOWCONTROL

enum {
    SBSC_HIDE = 0,
    SBSC_SHOW = 1,
    SBSC_TOGGLE = 2,
    SBSC_QUERY =  3
};

// SBCMDID_OPTIONS
enum {
        SBO_DEFAULT = 0 ,
        SBO_NOBROWSERPAGES = 1
};

// CGID_Explorer Command Target IDs
enum {
    SBCMDID_ENABLESHOWTREE          = 0,
    SBCMDID_SHOWCONTROL             = 1,        // variant vt_i4 = loword = FCW_* hiword = SBSC_*
    SBCMDID_CANCELNAVIGATION        = 2,        // cancel last navigation
    SBCMDID_MAYSAVECHANGES          = 3,        // about to close and may save changes
    SBCMDID_SETHLINKFRAME           = 4,        // variant vt_i4 = phlinkframe
    SBCMDID_ENABLESTOP              = 5,        // variant vt_bool = fEnable
    SBCMDID_OPTIONS                 = 6,        // the view.options page
    SBCMDID_EXPLORER                = 7,        // are you explorer.exe?
    SBCMDID_ADDTOFAVORITES          = 8,
    SBCMDID_ACTIVEOBJECTMENUS       = 9,
    SBCMDID_MAYSAVEVIEWSTATE        = 10,       // Should we save view stream
    SBCMDID_DOFAVORITESMENU         = 11,       // popup the favorites menu
    SBCMDID_DOMAILMENU              = 12,       // popup the mail menu
    SBCMDID_GETADDRESSBARTEXT       = 13,       // get user-typed text
    SBCMDID_ASYNCNAVIGATION         = 14,       // do an async navigation
    SBCMDID_SEARCHBAROBSOLETE       = 15,       // OBSOLETE beta-1 SEARCHBAR
    SBCMDID_FLUSHOBJECTCACHE        = 16,       // flush object cache
    SBCMDID_CREATESHORTCUT          = 17,       // create a shortcut
    SBCMDID_SETMERGEDWEBMENU        = 18,       // set pre-merged menu for HTML
    SBCMDID_REMOVELOCKICON          = 19,       // Remove lock icon
    SBCMDID_SELECTHISTPIDL          = 20,       // QS:EXEC select history pidl on navigate
    SBCMDID_WRITEHIST               = 21,       // QS only:write history sf on navigate
    SBCMDID_GETHISTPIDL             = 22,       // EXEC gets most recent history pidl
    SBCMDID_REGISTERNSCBAND         = 23,       // EXEC registers NscBand when visible
    SBCMDID_COCREATEDOCUMENT        = 24,       // Create an instance of MSHTML
    SBCMDID_SETSECURELOCKICON       = 25,       // sets the SSL lock icon for the current page
    SBCMDID_INITFILECTXMENU         = 26,       // EXEC,QS: file context menu for band item
    SBCMDID_UNREGISTERNSCBAND       = 27,       // EXEC unregisters NscBand when invisible
    SBCMDID_SEARCHBAR               = 28,       // show/hide/toggle BrowserBar search
    SBCMDID_HISTORYBAR              = 29,       // show/hide/toggle BrowserBar history
    SBCMDID_FAVORITESBAR            = 30,       // show/hide/toggle BrowserBar favorites
#ifdef ENABLE_CHANNELS
    SBCMDID_CHANNELSBAR             = 31,       // show/hide/toggle BrowserBar channels
#endif
    SBCMDID_SENDPAGE                = 32,       // sends the current page via email
    SBCMDID_SENDSHORTCUT            = 33,       // sends a shortcut to current page via email
    SBCMDID_TOOLBAREMPTY            = 34,       // toolbar has nothing visible
    SBCMDID_EXPLORERBAR             = 35,       // show/hide/toggle BrowserBar all folders
    SBCMDID_GETUSERADDRESSBARTEXT   = 36,       // get the exact text the user-entered
    SBCMDID_HISTSFOLDER             = 37,       // EXEC varOut returns cached history IShellFolder
    SBCMDID_UPDATETRAVELLOG         = 38,       // updates the travellog with the current info
    SBCMDID_MIXEDZONE               = 39,       // The current view has mixed zones
    SBCMDID_REPLACELOCATION         = 40,       // replace the current URL with this one.
    SBCMDID_GETPANE                 = 41,       // Browser asks the view for pane ordinal
    SBCMDID_FILERENAME              = 42,       // Browser forwards file->rename to explorer bar
    SBCMDID_FILEDELETE              = 43,       // Browser forwards file->delete to explorer bar
    SBCMDID_FILEPROPERTIES          = 44,       // Browser forwards file->properties to explorer bar
    SBCMDID_IESHORTCUT              = 45,       // Navigates the browser to an .url file
    SBCMDID_GETSHORTCUTPATH         = 46,       // Asks for the path to the shortcut - if it exists
    SBCMDID_DISCUSSIONBAND          = 47,       // show/hide/toggle the Office discussion band
    SBCMDID_SETADDRESSBARFOCUS      = 48,       // Set focus on address bar on WM_ACTIVATE (UNIX)
    SBCMDID_HASADDRESSBARFOCUS      = 49,       // Checks whether address bar has focus (UNIX)
    SBCMDID_MSGBAND                 = 50,       // MsgBand Message (UNIX)
    SBCMDID_ISIEMODEBROWSER         = 51,       // returns S_OK if browser is in IE mode
    SBCMDID_GETTEMPLATEMENU         = 52,       // get handle to template menu
    SBCMDID_GETCURRENTMENU          = 53,       // get handle to current menu
    SBCMDID_ERRORPAGE               = 54,       // informs addressbar mru that this is an error page
    SBCMDID_AUTOSEARCHING           = 55,       // informs addressbar mru that we are trying a new url
    SBCMDID_STARTEDFORINTERNET      = 56,       // return S_OK if window started as IE window, S_FALSE otherwise
    SBCMDID_ISBROWSERACTIVE         = 57,       // return S_OK if the browser is active, S_FALSE otherwise
    SBCMDID_SUGGESTSAVEWINPOS       = 58,       // return S_OK if browser decides to save window position, S_FALSE otherwise
    SBCMDID_CACHEINETZONEICON       = 59,       // Cache/refresh internet zone icons painted by status bar
    SBCMDID_ONVIEWMOVETOTOP         = 60,       // Notification that the view window has moved to HWND_TOP
    SBCMDID_ONCLOSE                 = 61,       // Close notification destined for the dochost.
    SBCMDID_CANCELANDCLOSE          = 62,       // Cancel the async download and close the browser.
    SBCMDID_MEDIABAR                = 63,       // show/hide/toggle MediaBar
};

#define ZONE_UNKNOWN    -1
#define ZONE_MIXED      -2
#define IS_SPECIAL_ZONE(a) (((a) == ZONE_UNKNOWN) || ((a) == ZONE_MIXED))

;end_internal

// SBCMDID_GETPANE - not necessarily in order
#define PANE_NONE        -1
#define PANE_ZONE        1
#define PANE_OFFLINE     2
#define PANE_PRINTER     3
#define PANE_SSL         4
#define PANE_NAVIGATION  5
#define PANE_PROGRESS    6
#define PANE_PRIVACY     7

;begin_internal



#if (_WIN32_IE >= 0x0400)
// CGID_AddresseditBox Command Target IDs
enum {
    AECMDID_SAVE                    = 0,        // Ask AddressEditBox to save
};
#endif

;end_internal

//-------------------------------------------------------------------------
// ICommDlgBrowser interface
//
//  ICommDlgBrowser interface is the interface that is provided by the new
// common dialog window to hook and modify the behavior of IShellView.  When
// a default view is created, it queries its parent IShellBrowser for the
// ICommDlgBrowser interface.  If supported, it calls out to that interface
// in several cases that need to behave differently in a dialog.
//
// Member functions:
//
//  ICommDlgBrowser::OnDefaultCommand()
//    Called when the user double-clicks in the view or presses Enter.  The
//   browser should return S_OK if it processed the action itself, S_FALSE
//   to let the view perform the default action.
//
//  ICommDlgBrowser::OnStateChange(ULONG uChange)
//    Called when some states in the view change.  'uChange' is one of the
//   CDBOSC_* values.  This call is made after the state (selection, focus,
//   etc) has changed.  There is no return value.
//
//  ICommDlgBrowser::IncludeObject(LPCITEMIDLIST pidl)
//    Called when the view is enumerating objects.  'pidl' is a relative
//   IDLIST.  The browser should return S_OK to include the object in the
//   view, S_FALSE to hide it
//
//-------------------------------------------------------------------------

#define CDBOSC_SETFOCUS     0x00000000
#define CDBOSC_KILLFOCUS    0x00000001
#define CDBOSC_SELCHANGE    0x00000002
#define CDBOSC_RENAME       0x00000003
#define CDBOSC_STATECHANGE  0x00000004

#undef  INTERFACE
#define INTERFACE   ICommDlgBrowser

DECLARE_INTERFACE_(ICommDlgBrowser, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** ICommDlgBrowser methods ***
    STDMETHOD(OnDefaultCommand) (THIS_ struct IShellView * ppshv) PURE;
    STDMETHOD(OnStateChange) (THIS_ struct IShellView * ppshv,
                ULONG uChange) PURE;
    STDMETHOD(IncludeObject) (THIS_ struct IShellView * ppshv,
                LPCITEMIDLIST pidl) PURE;
};

typedef ICommDlgBrowser * LPCOMMDLGBROWSER;

//-------------------------------------------------------------------------
// ICommDlgBrowser2 interface
//
// Member functions:
//
//  ICommDlgBrowser2::Notify(IShellView *pshv, DWORD dwNotfyType)
//   Called when the view is wants to notify common dialog when an event
//  occurrs.
//
//  CDB2N_CONTEXTMENU_START indicates the context menu has started.
//  CDB2N_CONTEXTMENU_DONE  indicates the context menu has completed.
//
//  ICommDlgBrowser2::GetDefaultMenuText(IShellView *pshv,
//                                      WCHAR *pszText, INT cchMax)
//   Called when the view wants to get the default context menu text.
//  pszText points to buffer and cchMax specifies the size of the
//  buffer in characters.  The browser on return has filled the buffer
//  with the default context menu text.  The Shell will call this method
//  with at least a buffer size of MAX_PATH.  The browser should return
//  S_OK if it returned a new default menu text, S_FALSE to let the view
//  to use the normal default menu text.
//
//  ICommDlgBrowser2::GetViewFlags(DWORD *pdwFlags)
//     Called when the view wants to determine  if special customization needs to
//    be done for the common dialog browser. For example View calls this function to
//    determin if all files(hidden and system)needs to be shown. If the GetViewFlags returns a DWORD with
//    CDB2GVF_SHOWALLFILES  flag set then it will show all the files.
//-------------------------------------------------------------------------

#define CDB2N_CONTEXTMENU_DONE  0x00000001
#define CDB2N_CONTEXTMENU_START 0x00000002

//GetViewFlags
#define CDB2GVF_SHOWALLFILES        0x00000001

#undef  INTERFACE
#define INTERFACE   ICommDlgBrowser2

DECLARE_INTERFACE_(ICommDlgBrowser2, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** ICommDlgBrowser methods ***
    STDMETHOD(OnDefaultCommand) (THIS_ struct IShellView * ppshv) PURE;
    STDMETHOD(OnStateChange) (THIS_ struct IShellView * ppshv,
                ULONG uChange) PURE;
    STDMETHOD(IncludeObject) (THIS_ struct IShellView * ppshv,
                LPCITEMIDLIST pidl) PURE;

    // *** ICommDlgBrowser2 methods ***
    STDMETHOD(Notify) (THIS_ struct IShellView * ppshv,
                DWORD dwNotifyType) PURE;
    STDMETHOD(GetDefaultMenuText) (THIS_ struct IShellView * ppshv,
                WCHAR *pszText, INT cchMax) PURE;
    STDMETHOD(GetViewFlags)(THIS_ DWORD *pdwFlags) PURE;

};

typedef ICommDlgBrowser2 * LPCOMMDLGBROWSER2;



;begin_internal
#ifdef NONAMELESSUNION
#define NAMELESS_MEMBER(member) DUMMYUNIONNAME.##member
#else
#define NAMELESS_MEMBER(member) member
#endif

#define STRRET_OLESTR  STRRET_WSTR          // same as STRRET_WSTR
#define STRRET_OFFPTR(pidl,lpstrret) ((LPSTR)((LPBYTE)(pidl)+(lpstrret)->NAMELESS_MEMBER(uOffset)))
;end_internal

//
// function assumes the size of the buffer (MAX_PATH). The pidl
// should point to a file system object.

SHSTDAPI_(BOOL) SHGetPathFromIDList%(LPCITEMIDLIST pidl, LPTSTR% pszPath);

;begin_internal
// DOC'ed for DOJ compliance
;end_internal
SHSTDAPI_(int) SHCreateDirectory(HWND hwnd, LPCWSTR pszPath);
SHSTDAPI_(int) SHCreateDirectoryEx%(HWND hwnd, LPCTSTR% pszPath, SECURITY_ATTRIBUTES *psa);

SHSTDAPI SHOpenFolderAndSelectItems(LPCITEMIDLIST pidlFolder, UINT cidl, LPCITEMIDLIST *apidl, DWORD dwFlags);


SHSTDAPI SHCreateShellItem(LPCITEMIDLIST pidlParent, IShellFolder *psfParent, LPCITEMIDLIST pidl, IShellItem **ppsi);

;begin_internal
SHSTDAPI SHParseShellItem(LPCWSTR psz, IShellItem **ppsi);
SHSTDAPI SIEnumObjects(IShellItem *psi, HWND hwnd, SHCONTF flags, IEnumShellItems **ppenum);
SHSTDAPI SHCreateShellItemArray(LPCITEMIDLIST pidlParent,IShellFolder *psfParent,UINT cidl,
                                        LPCITEMIDLIST *ppidl,IShellItemArray **ppsiItemArray);


;end_internal

//-------------------------------------------------------------------------
//
// SHGetSpecialFolderLocation
//
//  Caller should use SHGetMalloc to obtain an allocator that can free the pidl
//
//
//-------------------------------------------------------------------------
//
// registry entries for special paths are kept in :
#define REGSTR_PATH_SPECIAL_FOLDERS    REGSTR_PATH_EXPLORER TEXT("\\Shell Folders")

#define REGSTR_PATH_INTERNET_EXPLORER   TEXT("\\SOFTWARE\\Microsoft\\Internet Explorer")  ; Internal
#define REGSTR_PATH_IE_MAIN             REGSTR_PATH_INTERNET_EXPLORER TEXT("\\Main")  ; Internal
#define REGSTR_VALUE_USER_AGENT         TEXT("UserAgent")  ; Internal
#define REGSTR_DEFAULT_USER_AGENT       TEXT("Mozilla/2.0 (compatible; MSIE 3.0A; Windows 95)")  ; Internal

#define CSIDL_DESKTOP                   0x0000        // <desktop>
#define CSIDL_INTERNET                  0x0001        // Internet Explorer (icon on desktop)
#define CSIDL_PROGRAMS                  0x0002        // Start Menu\Programs
#define CSIDL_CONTROLS                  0x0003        // My Computer\Control Panel
#define CSIDL_PRINTERS                  0x0004        // My Computer\Printers
#define CSIDL_PERSONAL                  0x0005        // My Documents
#define CSIDL_FAVORITES                 0x0006        // <user name>\Favorites
#define CSIDL_STARTUP                   0x0007        // Start Menu\Programs\Startup
#define CSIDL_RECENT                    0x0008        // <user name>\Recent
#define CSIDL_SENDTO                    0x0009        // <user name>\SendTo
#define CSIDL_BITBUCKET                 0x000a        // <desktop>\Recycle Bin
#define CSIDL_STARTMENU                 0x000b        // <user name>\Start Menu
#define CSIDL_MYDOCUMENTS               0x000c        // logical "My Documents" desktop icon
#define CSIDL_MYMUSIC                   0x000d        // "My Music" folder
#define CSIDL_MYVIDEO                   0x000e        // "My Videos" folder
                                    //  0x000f ;Internal
#define CSIDL_DESKTOPDIRECTORY          0x0010        // <user name>\Desktop
#define CSIDL_DRIVES                    0x0011        // My Computer
#define CSIDL_NETWORK                   0x0012        // Network Neighborhood (My Network Places)
#define CSIDL_NETHOOD                   0x0013        // <user name>\nethood
#define CSIDL_FONTS                     0x0014        // windows\fonts
#define CSIDL_TEMPLATES                 0x0015
#define CSIDL_COMMON_STARTMENU          0x0016        // All Users\Start Menu
#define CSIDL_COMMON_PROGRAMS           0X0017        // All Users\Start Menu\Programs
#define CSIDL_COMMON_STARTUP            0x0018        // All Users\Startup
#define CSIDL_COMMON_DESKTOPDIRECTORY   0x0019        // All Users\Desktop
#define CSIDL_APPDATA                   0x001a        // <user name>\Application Data
#define CSIDL_PRINTHOOD                 0x001b        // <user name>\PrintHood

#ifndef CSIDL_LOCAL_APPDATA
#define CSIDL_LOCAL_APPDATA             0x001c        // <user name>\Local Settings\Applicaiton Data (non roaming)
#endif // CSIDL_LOCAL_APPDATA

#define CSIDL_ALTSTARTUP                0x001d        // non localized startup
#define CSIDL_COMMON_ALTSTARTUP         0x001e        // non localized common startup
#define CSIDL_COMMON_FAVORITES          0x001f

#ifndef _SHFOLDER_H_
#define CSIDL_INTERNET_CACHE            0x0020
#define CSIDL_COOKIES                   0x0021
#define CSIDL_HISTORY                   0x0022
#define CSIDL_COMMON_APPDATA            0x0023        // All Users\Application Data
#define CSIDL_WINDOWS                   0x0024        // GetWindowsDirectory()
#define CSIDL_SYSTEM                    0x0025        // GetSystemDirectory()
#define CSIDL_PROGRAM_FILES             0x0026        // C:\Program Files
#define CSIDL_MYPICTURES                0x0027        // C:\Program Files\My Pictures
#endif // _SHFOLDER_H_

#define CSIDL_PROFILE                   0x0028        // USERPROFILE
#define CSIDL_SYSTEMX86                 0x0029        // x86 system directory on RISC
#define CSIDL_PROGRAM_FILESX86          0x002a        // x86 C:\Program Files on RISC

#ifndef _SHFOLDER_H_
#define CSIDL_PROGRAM_FILES_COMMON      0x002b        // C:\Program Files\Common
#endif // _SHFOLDER_H_

#define CSIDL_PROGRAM_FILES_COMMONX86   0x002c        // x86 Program Files\Common on RISC
#define CSIDL_COMMON_TEMPLATES          0x002d        // All Users\Templates

#ifndef _SHFOLDER_H_
#define CSIDL_COMMON_DOCUMENTS          0x002e        // All Users\Documents
#define CSIDL_COMMON_ADMINTOOLS         0x002f        // All Users\Start Menu\Programs\Administrative Tools
#define CSIDL_ADMINTOOLS                0x0030        // <user name>\Start Menu\Programs\Administrative Tools
#endif // _SHFOLDER_H_

#define CSIDL_CONNECTIONS               0x0031        // Network and Dial-up Connections
#define CSIDL_PERUSER_TEMP              0x0032        // per user TEMP                      (reserved, not impelemented);Internal
#define CSIDL_9XCOMMAND                 0x0033        // Win9x COMMANDN (dos programs)      (reserved, not impelemented);Internal
#define CSIDL_9XSYSTEM                  0x0034        // Win9x/NT system (not system32)     (reserved, not impelemented);Internal
#define CSIDL_COMMON_MUSIC              0x0035        // All Users\My Music
#define CSIDL_COMMON_PICTURES           0x0036        // All Users\My Pictures
#define CSIDL_COMMON_VIDEO              0x0037        // All Users\My Video
#define CSIDL_RESOURCES                 0x0038        // Resource Direcotry

#ifndef _SHFOLDER_H_
#define CSIDL_RESOURCES_LOCALIZED       0x0039        // Localized Resource Direcotry
#endif // _SHFOLDER_H_

#define CSIDL_COMMON_OEM_LINKS          0x003a        // Links to All Users OEM specific apps
#define CSIDL_CDBURN_AREA               0x003b        // USERPROFILE\Local Settings\Application Data\Microsoft\CD Burning
// unused                               0x003c
#define CSIDL_COMPUTERSNEARME           0x003d        // Computers Near Me (computered from Workgroup membership)

#ifndef _SHFOLDER_H_
#define CSIDL_FLAG_CREATE               0x8000        // combine with CSIDL_ value to force folder creation in SHGetFolderPath()
#endif // _SHFOLDER_H_

#define CSIDL_FLAG_DONT_VERIFY          0x4000        // combine with CSIDL_ value to return an unverified folder path
;begin_internal
#define CSIDL_FLAG_DONT_UNEXPAND        0x2000        // combine with CSIDL_ value to avoid unexpanding environment variables
;end_internal
#define CSIDL_FLAG_NO_ALIAS             0x1000        // combine with CSIDL_ value to insure non-alias versions of the pidl
#define CSIDL_FLAG_PER_USER_INIT        0x0800        // combine with CSIDL_ value to indicate per-user init (eg. upgrade)
#define CSIDL_FLAG_MASK                 0xFF00        // mask for all possible flag values


SHSTDAPI SHGetSpecialFolderLocation(HWND hwnd, int csidl, LPITEMIDLIST *ppidl);

#if (_WIN32_IE >= 0x0400)
;begin_internal
// DOC'ed for DOJ compliance
;end_internal
SHSTDAPI_(void) SHFlushSFCache(void);   
SHSTDAPI_(LPITEMIDLIST) SHCloneSpecialIDList(HWND hwnd, int csidl, BOOL fCreate);  
SHSTDAPI_(BOOL) SHGetSpecialFolderPath%(HWND hwnd, LPTSTR% pszPath, int csidl, BOOL fCreate);

#if (_WIN32_IE >= 0x0500)

typedef enum {
    SHGFP_TYPE_CURRENT  = 0,   // current value for user, verify it exists
    SHGFP_TYPE_DEFAULT  = 1,   // default value, may not exist
} SHGFP_TYPE;

SHFOLDERAPI SHGetFolderPath%(HWND hwnd, int csidl, HANDLE hToken, DWORD dwFlags, LPTSTR% pszPath);
SHSTDAPI SHGetFolderLocation(HWND hwnd, int csidl, HANDLE hToken, DWORD dwFlags, LPITEMIDLIST *ppidl);

SHFOLDERAPI SHGetFolderPathAndSubDir%(HWND hwnd, int csidl, HANDLE hToken, DWORD dwFlags, LPCTSTR% pszSubDir, LPTSTR% pszPath);
;begin_internal
SHFOLDERAPI SHSetFolderPath%(int csidl, HANDLE hToken, DWORD dwFlags, LPCTSTR% pszPath);

SHSTDAPI_(BOOL) MakeShellURLFromPath%(LPCTSTR% pszPathIn, LPTSTR% pszUrl, DWORD dwCch);

SHSTDAPI_(BOOL) SHIsTempDisplayMode();

SHSTDAPI_(FILEDESCRIPTOR *) GetFileDescriptor(FILEGROUPDESCRIPTOR *pfgd, BOOL fUnicode, int nIndex, LPTSTR pszName);
SHSTDAPI CopyStreamUI(IStream *pstmSrc, IStream *pstmDest, IProgressDialog *pdlg, ULONGLONG ullMaxBytes);



;end_internal



#endif      // _WIN32_IE >= 0x0500

#endif      // _WIN32_IE >= 0x0400


;begin_internal
// DOC'ed for DOJ compliance
;end_internal
#if (_WIN32_IE >= 0x0500)

#define FCS_READ                    0x00000001
#define FCS_FORCEWRITE              0x00000002
#define FCS_WRITE                   (FCS_READ | FCS_FORCEWRITE)

#define FCS_FLAG_DRAGDROP           2

// Mask which values have been retreived or being set.
#define FCSM_VIEWID                 0x00000001
#define FCSM_WEBVIEWTEMPLATE        0x00000002
#define FCSM_INFOTIP                0x00000004
#define FCSM_CLSID                  0x00000008
#define FCSM_ICONFILE               0x00000010
#define FCSM_LOGO                   0x00000020
#define FCSM_FLAGS                  0x00000040

#include <pshpack8.h>

// Used by SHGetSetFolderCustomSettingsA
typedef struct
{
    DWORD           dwSize;
    DWORD           dwMask;             // IN/OUT   Which Attributes to Get/Set
    SHELLVIEWID*    pvid;               // OUT - if dwReadWrite is FCS_READ, IN - otherwise
    // The folder's WebView template path
    LPSTR           pszWebViewTemplate;  // OUT - if dwReadWrite is FCS_READ, IN - otherwise
    DWORD           cchWebViewTemplate;  // IN - Specifies the size of the buffer pointed to by pszWebViewTemplate
                                        // Ignored if dwReadWrite is FCS_READ
    LPSTR           pszWebViewTemplateVersion;  // currently IN only
    // Infotip for the folder
    LPSTR           pszInfoTip;         // OUT - if dwReadWrite is FCS_READ, IN - otherwise
    DWORD           cchInfoTip;         // IN - Specifies the size of the buffer pointed to by pszInfoTip
                                        // Ignored if dwReadWrite is FCS_READ
    // CLSID that points to more info in the registry
    CLSID*          pclsid;             // OUT - if dwReadWrite is FCS_READ, IN - otherwise
    // Other flags for the folder. Takes FCS_FLAG_* values
    DWORD           dwFlags;            // OUT - if dwReadWrite is FCS_READ, IN - otherwise

    LPSTR           pszIconFile;        // OUT - if dwReadWrite is FCS_READ, IN - otherwise
    DWORD           cchIconFile;        // IN - Specifies the size of the buffer pointed to by pszIconFile
                                        // Ignored if dwReadWrite is FCS_READ

    int             iIconIndex;         // OUT - if dwReadWrite is FCS_READ, IN - otherwise

    LPSTR           pszLogo;        // OUT - if dwReadWrite is FCS_READ, IN - otherwise
    DWORD           cchLogo;        // IN - Specifies the size of the buffer pointed to by pszIconFile
                                        // Ignored if dwReadWrite is FCS_READ


} SHFOLDERCUSTOMSETTINGSA, *LPSHFOLDERCUSTOMSETTINGSA;

// Used by SHGetSetFolderCustomSettingsW
typedef struct
{
    DWORD           dwSize;
    DWORD           dwMask;              // IN/OUT  Which Attributes to Get/Set
    SHELLVIEWID*    pvid;                // OUT - if dwReadWrite is FCS_READ, IN - otherwise
    // The folder's WebView template path
    LPWSTR          pszWebViewTemplate;   // OUT - if dwReadWrite is FCS_READ, IN - otherwise
    DWORD           cchWebViewTemplate;   // IN - Specifies the size of the buffer pointed to by pszWebViewTemplate
                                         // Ignored if dwReadWrite is FCS_READ
    LPWSTR           pszWebViewTemplateVersion;  // currently IN only
    // Infotip for the folder
    LPWSTR          pszInfoTip;          // OUT - if dwReadWrite is FCS_READ, IN - otherwise
    DWORD           cchInfoTip;          // IN - Specifies the size of the buffer pointed to by pszInfoTip
                                         // Ignored if dwReadWrite is FCS_READ
    // CLSID that points to more info in the registry
    CLSID*          pclsid;              // OUT - if dwReadWrite is FCS_READ, IN - otherwise
    // Other flags for the folder. Takes FCS_FLAG_* values
    DWORD           dwFlags;             // OUT - if dwReadWrite is FCS_READ, IN - otherwise


    LPWSTR           pszIconFile;        // OUT - if dwReadWrite is FCS_READ, IN - otherwise
    DWORD            cchIconFile;        // IN - Specifies the size of the buffer pointed to by pszIconFile
                                         // Ignored if dwReadWrite is FCS_READ

    int              iIconIndex;         // OUT - if dwReadWrite is FCS_READ, IN - otherwise

    LPWSTR           pszLogo;        // OUT - if dwReadWrite is FCS_READ, IN - otherwise
    DWORD            cchLogo;        // IN - Specifies the size of the buffer pointed to by pszIconFile
                                         // Ignored if dwReadWrite is FCS_READ
} SHFOLDERCUSTOMSETTINGSW, *LPSHFOLDERCUSTOMSETTINGSW;

#include <poppack.h>        /* Return to byte packing */

// Gets/Sets the Folder Custom Settings for pszPath based on dwReadWrite. dwReadWrite can be FCS_READ/FCS_WRITE/FCS_FORCEWRITE
SHSTDAPI SHGetSetFolderCustomSettingsA(LPSHFOLDERCUSTOMSETTINGSA pfcs, LPCSTR pszPath, DWORD dwReadWrite);
SHSTDAPI SHGetSetFolderCustomSettingsW(LPSHFOLDERCUSTOMSETTINGSW pfcs, LPCWSTR pszPath, DWORD dwReadWrite);

#ifdef UNICODE
#define SHFOLDERCUSTOMSETTINGS          SHFOLDERCUSTOMSETTINGSW
#define SHGetSetFolderCustomSettings    SHGetSetFolderCustomSettingsW
#define LPSHFOLDERCUSTOMSETTINGS        LPSHFOLDERCUSTOMSETTINGSW
#else
#define SHFOLDERCUSTOMSETTINGS          SHFOLDERCUSTOMSETTINGSA
#define SHGetSetFolderCustomSettings    SHGetSetFolderCustomSettingsA
#define LPSHFOLDERCUSTOMSETTINGS        LPSHFOLDERCUSTOMSETTINGSA
#endif

#endif  // _WIN32_IE >= 0x0500
;begin_internal
// above was doc'ed for DOJ compliance
;end_internal

//-------------------------------------------------------------------------
//
// SHBrowseForFolder API
//
//
//-------------------------------------------------------------------------

typedef int (CALLBACK* BFFCALLBACK)(HWND hwnd, UINT uMsg, LPARAM lParam, LPARAM lpData);

#include <pshpack8.h>

typedef struct _browseinfoA {
    HWND        hwndOwner;
    LPCITEMIDLIST pidlRoot;
    LPSTR        pszDisplayName;        // Return display name of item selected.
    // pszTitle can be a resource, but the hinst is assumed to be shell32.dll ;Internal
    LPCSTR       lpszTitle;                     // text to go in the banner over the tree.
    UINT         ulFlags;                       // Flags that control the return stuff
    BFFCALLBACK  lpfn;
    LPARAM       lParam;                        // extra info that's passed back in callbacks
    int          iImage;                        // output var: where to return the Image index.
} BROWSEINFOA, *PBROWSEINFOA, *LPBROWSEINFOA;

typedef struct _browseinfoW {
    HWND        hwndOwner;
    LPCITEMIDLIST pidlRoot;
    LPWSTR       pszDisplayName;        // Return display name of item selected.
    // lpszTitle can be a resource, but the hinst is assumed to be shell32.dll ;Internal
    LPCWSTR      lpszTitle;                     // text to go in the banner over the tree.
    UINT         ulFlags;                       // Flags that control the return stuff
    BFFCALLBACK  lpfn;
    LPARAM       lParam;                        // extra info that's passed back in callbacks
    int          iImage;                        // output var: where to return the Image index.
} BROWSEINFOW, *PBROWSEINFOW, *LPBROWSEINFOW;

#include <poppack.h>        /* Return to byte packing */

#ifdef UNICODE
#define BROWSEINFO      BROWSEINFOW
#define PBROWSEINFO     PBROWSEINFOW
#define LPBROWSEINFO    LPBROWSEINFOW
#else
#define BROWSEINFO      BROWSEINFOA
#define PBROWSEINFO     PBROWSEINFOA
#define LPBROWSEINFO    LPBROWSEINFOA
#endif

// Browsing for directory.
#define BIF_RETURNONLYFSDIRS   0x0001  // For finding a folder to start document searching
#define BIF_DONTGOBELOWDOMAIN  0x0002  // For starting the Find Computer
#define BIF_STATUSTEXT         0x0004   // Top of the dialog has 2 lines of text for BROWSEINFO.lpszTitle and one line if
                                        // this flag is set.  Passing the message BFFM_SETSTATUSTEXTA to the hwnd can set the
                                        // rest of the text.  This is not used with BIF_USENEWUI and BROWSEINFO.lpszTitle gets
                                        // all three lines of text.
#define BIF_RETURNFSANCESTORS  0x0008
#define BIF_EDITBOX            0x0010   // Add an editbox to the dialog
#define BIF_VALIDATE           0x0020   // insist on valid result (or CANCEL)

#define BIF_NEWDIALOGSTYLE     0x0040   // Use the new dialog layout with the ability to resize
                                        // Caller needs to call OleInitialize() before using this API

#define BIF_USENEWUI           (BIF_NEWDIALOGSTYLE | BIF_EDITBOX)

#define BIF_BROWSEINCLUDEURLS  0x0080   // Allow URLs to be displayed or entered. (Requires BIF_USENEWUI)
#define BIF_UAHINT             0x0100   // Add a UA hint to the dialog, in place of the edit box. May not be combined with BIF_EDITBOX
#define BIF_NONEWFOLDERBUTTON  0x0200   // Do not add the "New Folder" button to the dialog.  Only applicable with BIF_NEWDIALOGSTYLE.
#define BIF_NOTRANSLATETARGETS 0x0400   // don't traverse target as shortcut

#define BIF_BROWSEFORCOMPUTER  0x1000  // Browsing for Computers.
#define BIF_BROWSEFORPRINTER   0x2000  // Browsing for Printers
#define BIF_BROWSEINCLUDEFILES 0x4000  // Browsing for Everything
#define BIF_SHAREABLE          0x8000  // sharable resources displayed (remote shares, requires BIF_USENEWUI)

// message from browser
#define BFFM_INITIALIZED        1
#define BFFM_SELCHANGED         2
#define BFFM_VALIDATEFAILEDA    3   // lParam:szPath ret:1(cont),0(EndDialog)
#define BFFM_VALIDATEFAILEDW    4   // lParam:wzPath ret:1(cont),0(EndDialog)
#define BFFM_IUNKNOWN           5   // provides IUnknown to client. lParam: IUnknown*

// messages to browser
#define BFFM_SETSTATUSTEXTA     (WM_USER + 100)
#define BFFM_ENABLEOK           (WM_USER + 101)
#define BFFM_SETSELECTIONA      (WM_USER + 102)
#define BFFM_SETSELECTIONW      (WM_USER + 103)
#define BFFM_SETSTATUSTEXTW     (WM_USER + 104)
#define BFFM_SETOKTEXT          (WM_USER + 105) // Unicode only
#define BFFM_SETEXPANDED        (WM_USER + 106) // Unicode only

SHSTDAPI_(LPITEMIDLIST) SHBrowseForFolderA(LPBROWSEINFOA lpbi);
SHSTDAPI_(LPITEMIDLIST) SHBrowseForFolderW(LPBROWSEINFOW lpbi);

#ifdef UNICODE
#define SHBrowseForFolder   SHBrowseForFolderW
#define BFFM_SETSTATUSTEXT  BFFM_SETSTATUSTEXTW
#define BFFM_SETSELECTION   BFFM_SETSELECTIONW

#define BFFM_VALIDATEFAILED BFFM_VALIDATEFAILEDW
#else
#define SHBrowseForFolder   SHBrowseForFolderA
#define BFFM_SETSTATUSTEXT  BFFM_SETSTATUSTEXTA
#define BFFM_SETSELECTION   BFFM_SETSELECTIONA

#define BFFM_VALIDATEFAILED BFFM_VALIDATEFAILEDA
#endif

//-------------------------------------------------------------------------
//
// SHLoadInProc
//
//   When this function is called, the shell calls CoCreateInstance
//  (or equivalent) with CLSCTX_INPROC_SERVER and the specified CLSID
//  from within the shell's process and release it immediately.
//
//-------------------------------------------------------------------------

SHSTDAPI SHLoadInProc(REFCLSID rclsid);


#if _WIN32_IE >= 0x0600

//-------------------------------------------------------------------------
//
// SHEnableServiceObject
//
//   Like SHLoadInProc, but gives control over the object's lifetime
//  via fEnable parameter.  TRUE tells the shell to create the object
//  and hold onto it, FALSE tells the shell to look for the previously
//  created instance of the object and release it.
//
//-------------------------------------------------------------------------

SHSTDAPI SHEnableServiceObject(REFCLSID rclsid, BOOL fEnable);

#endif

;begin_internal

//-------------------------------------------------------------------------
//
// Shell Service Object
//
//-------------------------------------------------------------------------
// Cmds for CGID_ShellServiceObject
enum {
    SSOCMDID_OPEN        = 2,
    SSOCMDID_CLOSE       = 3,
};

;end_internal

//-------------------------------------------------------------------------
//
// Internet Shortcut Object
//
//-------------------------------------------------------------------------
// Cmds for CGID_ShortCut
enum {
    ISHCUTCMDID_DOWNLOADICON  = 0,
    ISHCUTCMDID_INTSHORTCUTCREATE = 1,
};
#define CMDID_INTSHORTCUTCREATE ISHCUTCMDID_INTSHORTCUTCREATE


;begin_internal

#define CMDID_SAVEASTHICKET     5


//-------------------------------------------------------------------------
// STR_DISPLAY_UI_DURING_BINDING - IBindCtx Key
//-------------------------------------------------------------------------
// If displaying UI during binding is allowed, this parameter
// will be in the IBindCtx so the object binding can get the
// IUnknown* of the site in order to:
// 1. Use the site's hwnd as the parent hwnd of any UI dialogs.
//    This is done via. IOleWindow::GetWindow() or IInternetSecurityMgrSite::GetWindow()
// 2. While the dialog is being displayed, make the site modal
//    This is done via:
//       IOleInPlaceActiveObject::EnableModeless()
//       IOleInPlaceUIWindow::EnableModelessSB()
//       IInternetSecurityMgrSite::EnableModeless()

#define STR_DISPLAY_UI_DURING_BINDING      L"UI During Binding"

// bindctx key, tells an FS folder to ignore the STGM_CREATE flag in ParseDisplayName.
// otherwise it will always succeed, but we need to be able to force it to fail for
// the cd-r drive.
#define STR_DONT_FORCE_CREATE              L"Don't Force Create"

// bindctx key, passed to IShellFolder::ParseDisplayName().  gives netfldr extra
// information it can use to route the parsing of the name we are giving it.
#define STR_PARSE_NETFOLDER_INFO                L"Net Parse Data"

// in the property bag associated with STR_PARSE_NETFOLDER_INFO this string property
// defines the WNetProvider to be used when calling WNetGetResourceInformation.
#define STR_PARSE_NETFOLDER_PROVIDERNAME        L"WNetProvider"

;end_internal


//
//  Helper function which returns a IShellFolder interface to the desktop
// folder. This is equivalent to call CoCreateInstance with CLSID_ShellDesktop.
//
//  CoCreateInstance(CLSID_Desktop, NULL,
//                   CLSCTX_INPROC, IID_IShellFolder, &pshf);
//
SHSTDAPI SHGetDesktopFolder(IShellFolder **ppshf);


// IShellFolder IBindCtx* parameters. the IUnknown for these are
// accessed through IBindCtx::RegisterObjectParam/GetObjectParam
// use this to provide the data needed create IDLists through
// IShellFolder::ParseDisplayName(). this data applies to the last element
// of the name that is parsed (c:\foo\bar.txt, data applies to bar.txt)
// this makes creating these IDLists much faster that suppling the name only

#define STR_FILE_SYS_BIND_DATA      L"File System Bind Data"

#undef  INTERFACE
#define INTERFACE   IFileSystemBindData

DECLARE_INTERFACE_(IFileSystemBindData, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IFileSystemBindData methods ***
    STDMETHOD(SetFindData)(THIS_ const WIN32_FIND_DATAW *pfd) PURE;
    STDMETHOD(GetFindData)(THIS_ WIN32_FIND_DATAW *pfd) PURE;
};

;begin_internal

//
// The IShellDetails interface was private in win95 and didnt have a _WIN32_IE guard,
// so it is now in shlobj.h, along with the definition of SHELLDETAILS
//

;end_internal
#undef  INTERFACE
#define INTERFACE   IShellDetails

DECLARE_INTERFACE_(IShellDetails, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IShellDetails methods ***
    STDMETHOD(GetDetailsOf)(THIS_ LPCITEMIDLIST pidl, UINT iColumn, SHELLDETAILS *pDetails) PURE;
    STDMETHOD(ColumnClick)(THIS_ UINT iColumn) PURE;
};



;begin_internal

//-------------------------------------------------------------------------
//
// DELEGATEITEMID structure
//
//
// A Delegate Item ID is a standard SHITEMID with some additional
// fields defined.
//
//-------------------------------------------------------------------------

typedef struct tagDELEGATEITEMID {
    WORD cbSize;                // Size of entire item ID
    WORD wOuter;                // Private data owned by the outer folder
    WORD cbInner;               // Size of delegate's data
    BYTE rgb[1];                // Inner folder's data,
                                //   followed by outer folder's data.
} DELEGATEITEMID;

typedef const UNALIGNED DELEGATEITEMID *PCDELEGATEITEMID;
typedef UNALIGNED DELEGATEITEMID *PDELEGATEITEMID;


//-------------------------------------------------------------------------
//
// IDelegateFolder interface
//
//
// [Member functions]
//
// IDelegateFolder::SetItemAlloc(pm)
//   This function gives the object an IMalloc interface that it
//   should use to alloc and free item IDs.  These IDs are in the
//   form of DELEGATEITEMIDs.
//
//-------------------------------------------------------------------------

#undef INTERFACE
#define INTERFACE IDelegateFolder

DECLARE_INTERFACE_(IDelegateFolder, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IDelegateFolder methods ***
    STDMETHOD(SetItemAlloc)(THIS_ IMalloc *pmalloc) PURE;
};

#undef  INTERFACE
#define INTERFACE   IMountedVolume

DECLARE_INTERFACE_(IMountedVolume, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IMountedVolume methods ***
    STDMETHOD(Initialize)(THIS_ LPCWSTR pcszHostFolderPath) PURE;
};
;end_internal


//-------------------------------------------------------------------------
//
// IObjMgr interface
//
//
// [Member functions]
//
// IObjMgr::Append(punk)
//   This function adds an object to the end of a list of objects.
//
// IObjMgr::Remove(punk)
//   This function removes an object from a list of objects.
//
// This is implemented by CLSID_ACLMulti so each AutoComplete List
// (CLSID_ACLHistory, CLSID_ACListISF, CLSID_ACLMRU) can be added.
// CLSID_ACLMulti's IEnumString will then be the union of the results
// from the COM Objects added.
//-------------------------------------------------------------------------

#undef INTERFACE
#define INTERFACE IObjMgr

DECLARE_INTERFACE_(IObjMgr, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG, AddRef) (THIS) PURE;
    STDMETHOD_(ULONG, Release) (THIS) PURE;

    // *** IObjMgr specific methods ***
    STDMETHOD(Append) (THIS_ IUnknown *punk) PURE;
    STDMETHOD(Remove) (THIS_ IUnknown *punk) PURE;
};


//-------------------------------------------------------------------------
//
// ICurrentWorkingDirectory interface
//
//
// [Member functions]
//
// ICurrentWorkingDirectory::GetDirectory(LPWSTR pwzPath, DWORD cchSize)
//   This function gets the Current Working Directory from a COM object that
//   stores such state.
//
// ICurrentWorkingDirectory::SetDirectory(LPCWSTR pwzPath)
//   This function sets the Current Working Directory of a COM object that
//   stores such state.
//
// This function can be used generically.  One COM object that implements it
// is CLSID_ACListISF so that the AutoComplete engine can complete relative
// paths.  SetDirectory() will set the "Current Working Directory" and
// AutoComplete with then complete both absolute and relative paths.
// For Example, if ::SetDirectory(L"C:\Program Files") is called, then
// the user can AutoComplete "..\winnt".  In order to set the current
// working directory for non-file system paths, "ftp://ftp.microsoft.com/" or
// "Control Panel" for example, use IPersistFolder.
//-------------------------------------------------------------------------

#undef INTERFACE
#define INTERFACE ICurrentWorkingDirectory

DECLARE_INTERFACE_(ICurrentWorkingDirectory, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG, AddRef) (THIS) PURE;
    STDMETHOD_(ULONG, Release) (THIS) PURE;

    // *** ICurrentWorkingDirectory specific methods ***
    STDMETHOD(GetDirectory) (THIS_ LPWSTR pwzPath, DWORD cchSize) PURE;
    STDMETHOD(SetDirectory) (THIS_ LPCWSTR pwzPath) PURE;
};


//-------------------------------------------------------------------------
//
// IACList interface
//
//
// [Member functions]
//
// IObjMgr::Expand(LPCOLESTR)
//   This function tells an autocomplete list to expand a specific string.
//
// If the user enters a multi-level path, AutoComplete (CLSID_AutoComplete)
// will use this interface to tell the "AutoComplete Lists" where to expand
// the results.
//
// For Example, if the user enters "C:\Program Files\Micros", AutoComplete
// first completely enumerate the "AutoComplete Lists" via IEnumString.  Then it
// will call the "AutoComplete Lists" with IACList::Expand(L"C:\Program Files").
// It will then enumerate the IEnumString interface again to get results in
// that directory.
//-------------------------------------------------------------------------

#undef INTERFACE
#define INTERFACE IACList

DECLARE_INTERFACE_(IACList, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG, AddRef) (THIS) PURE;
    STDMETHOD_(ULONG, Release) (THIS) PURE;

    // *** IACList specific methods ***
    STDMETHOD(Expand) (THIS_ LPCOLESTR pszExpand) PURE;
};

//-------------------------------------------------------------------------
//
// IACList2 interface
//
// [Description]
//              This interface exists to allow the caller to set filter criteria
// for an AutoComplete List.  AutoComplete Lists generates the list of
// possible AutoComplete completions.  CLSID_ACListISF is one AutoComplete
// List COM object that implements this interface.
//-------------------------------------------------------------------------

#undef INTERFACE
#define INTERFACE IACList2

typedef enum _tagAUTOCOMPLETELISTOPTIONS
{
    ACLO_NONE            = 0,    // don't enumerate anything
    ACLO_CURRENTDIR      = 1,    // enumerate current directory
    ACLO_MYCOMPUTER      = 2,    // enumerate MyComputer
    ACLO_DESKTOP         = 4,    // enumerate Desktop Folder
    ACLO_FAVORITES       = 8,    // enumerate Favorites Folder
    ACLO_FILESYSONLY     = 16,   // enumerate only the file system
    ACLO_FILESYSDIRS     = 32,   // enumerate only the file system dirs, UNC shares, and UNC servers.
} AUTOCOMPLETELISTOPTIONS;

DECLARE_INTERFACE_(IACList2, IACList)
{
    // *** IACList2 specific methods ***
    STDMETHOD(SetOptions)(THIS_ DWORD dwFlag) PURE;
    STDMETHOD(GetOptions)(THIS_ DWORD* pdwFlag) PURE;
};


/*-------------------------------------------------------------------------*\
    INTERFACE: IProgressDialog

    DESCRIPTION:
        CLSID_ProgressDialog/IProgressDialog exist to allow a caller to create
    a progress dialog, set it's title, animation, text lines, progress, and
    it will do all the work of updating on a background thread, being modless,
    handling the user cancelling the operation, and estimating the time remaining
    until the operation completes.

    USAGE:
        This is how the dialog is used during operations that require progress
    and the ability to cancel:
    {
        DWORD dwComplete, dwTotal;
        IProgressDialog * ppd;
        CoCreateInstance(CLSID_ProgressDialog, NULL, CLSCTX_INPROC_SERVER, IID_IProgressDialog, (void **)&ppd);
        ppd->SetTitle(L"My Slow Operation");                                // Set the title of the dialog.
        ppd->SetAnimation(hInstApp, IDA_OPERATION_ANIMATION);               // Set the animation to play.
        ppd->StartProgressDialog(hwndParent, punk, PROGDLG_AUTOTIME, NULL); // Display and enable automatic estimated time remaining.
        ppd->SetCancelMsg(L"Please wait while the current operation is cleaned up", NULL);   // Will only be displayed if Cancel button is pressed.

        dwComplete = 0;
        dwTotal = CalcTotalUnitsToDo();

        // Reset because CalcTotalUnitsToDo() took a long time and the estimated time
        // is based on the time between ::StartProgressDialog() and the first
        // ::SetProgress() call.
        ppd->Timer(PDTIMER_RESET, NULL);

        for (nIndex = 0; nIndex < nTotal; nIndex++)
        {
            if (TRUE == ppd->HasUserCancelled())
                break;

            ppd->SetLine(2, L"I'm processing item n", FALSE, NULL);
            dwComplete += DoSlowOperation();

            ppd->SetProgress(dwCompleted, dwTotal);
        }

        ppd->StopProgressDialog();
        ppd->Release();
    }
\*-------------------------------------------------------------------------*/

// Flags for IProgressDialog::StartProgressDialog() (dwFlags)
#define PROGDLG_NORMAL          0x00000000      // default normal progress dlg behavior
#define PROGDLG_MODAL           0x00000001      // the dialog is modal to its hwndParent (default is modeless)
#define PROGDLG_AUTOTIME        0x00000002      // automatically updates the "Line3" text with the "time remaining" (you cant call SetLine3 if you passs this!)
#define PROGDLG_NOTIME          0x00000004      // we dont show the "time remaining" if this is set. We need this if dwTotal < dwCompleted for sparse files
#define PROGDLG_NOMINIMIZE      0x00000008      // Do not have a minimize button in the caption bar.
#define PROGDLG_NOPROGRESSBAR   0x00000010      // Don't display the progress bar

// Time Actions (dwTimerAction)
#define PDTIMER_RESET       0x00000001       // Reset the timer so the progress will be calculated from now until the first ::SetProgress() is called so
                                             // those this time will correspond to the values passed to ::SetProgress().  Only do this before ::SetProgress() is called.


#undef  INTERFACE
#define INTERFACE   IProgressDialog

DECLARE_INTERFACE_(IProgressDialog, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IProgressDialog specific methods
    STDMETHOD(StartProgressDialog)(THIS_ HWND hwndParent, IUnknown * punkEnableModless, DWORD dwFlags, LPCVOID pvResevered) PURE;
    STDMETHOD(StopProgressDialog)(THIS) PURE;
    STDMETHOD(SetTitle)(THIS_ LPCWSTR pwzTitle) PURE;
    STDMETHOD(SetAnimation)(THIS_ HINSTANCE hInstAnimation, UINT idAnimation) PURE;
    STDMETHOD_(BOOL,HasUserCancelled) (THIS) PURE;
    STDMETHOD(SetProgress)(THIS_ DWORD dwCompleted, DWORD dwTotal) PURE;
    STDMETHOD(SetProgress64)(THIS_ ULONGLONG ullCompleted, ULONGLONG ullTotal) PURE;
    STDMETHOD(SetLine)(THIS_ DWORD dwLineNum, LPCWSTR pwzString, BOOL fCompactPath, LPCVOID pvResevered) PURE;
    STDMETHOD(SetCancelMsg)(THIS_ LPCWSTR pwzCancelMsg, LPCVOID pvResevered) PURE;
    STDMETHOD(Timer)(THIS_ DWORD dwTimerAction, LPCVOID pvResevered) PURE;
};

;begin_internal
//-------------------------------------------------------------------------
// This is the interface for a browser to "subclass" the main File Cabinet
// window.  Note that only the hwnd, message, wParam, and lParam fields of
// the msg structure are used.  The browser window will get a WM_NOTIFY
// message with NULL ID, FCN_MESSAGE as the code, and a pointer to
// FCMSG_NOTIFY as the lParam.
//
//-------------------------------------------------------------------------

#include <pshpack8.h>

typedef struct tagFCMSG_NOTIFY
{
    NMHDR   hdr;
    MSG     msg;
    LRESULT lResult;
} FCMSG_NOTIFY;

#include <poppack.h>        /* Return to byte packing */

#define FCN_MESSAGE (100)


//---------------------------------------------------------------------------
// messages that can be send to the cabinet by other apps
//
// REVIEW: Do we really need to publish any of those?
//---------------------------------------------------------------------------

#define NF_INHERITVIEW 0x0000
#define NF_LOCALVIEW   0x0001

// Change the path of an existing folder.
// wParam:
//      0:              LPARAM is a pidl, handle the message immediately.
//      CSP_REPOST:     LPARAM is a pidl, copy the pidl and handle the
//                      message later.
//      CSP_NOEXECUTE:  if this path is not a folder, fail, don't shell exec
//
//
// lParam: LPITEMIDLIST of path.
//
//
#define CSP_REPOST                  0x0001
#define CSP_INITIATEDBYHLINKFRAME   0x0002
#define CSP_NOEXECUTE               0x0004
#define CSP_NONAVIGATE              0x0008
#define CWM_SETPATH                 (WM_USER + 2)

// lpsv points to the Shell View extension that requested idle processing
// uID is an app define identifier for the processor
// returns: TRUE if there is more idle processing necessary, FALSE if all done
// Note that the idle processor should do one "atomic" operation and return
// as soon as possible.
typedef BOOL (CALLBACK *FCIDLEPROC)(void *lpsv, UINT uID);

// Inform the File Cabinet that you want idle messages.
// This should ONLY be used by File Cabinet extensions.
// wParam: app define UINT (passed to FCIDLEPROC).
// lParam: pointer to an FCIDLEPROC.
// return: TRUE if successful; FALSE otherwise
//
#define CWM_WANTIDLE                (WM_USER + 3)

// get or set the FOLDERSETTINGS for a view
// wParam: BOOL TRUE -> set to view info buffer, FALSE -> get view info buffer
// lParam: LPFOLDERSETTINGS buffer to get or set view info
//
#define CWM_GETSETCURRENTINFO       (WM_USER + 4)
#define FileCabinet_GetSetCurrentInfo(_hwnd, _bSet, _lpfs) \
             SendMessage(_hwnd, CWM_GETSETCURRENTINFO, (WPARAM)(_bSet), (LPARAM)(LPFOLDERSETTINGS)_lpfs)

// selects the specified item in the current view
// wParam: SVSI_* flags
// lParam: LPCITEMIDLIST of the item ID, NULL -> all items
//
#define CWM_SELECTITEM              (WM_USER + 5)
#define FileCabinet_SelectItem(_hwnd, _sel, _item) \
            SendMessage(_hwnd, CWM_SELECTITEM, _sel, (LPARAM)(LPCITEMIDLIST)(_item))

// selects the specified path in the current view
// wParam: SVSI_* flags
// lParam: LPCSTR of the display name
//
#define CWM_SELECTPATH              (WM_USER + 6)
#define FileCabinet_SelectPath(_hwnd, _sel, _path)  \
            SendMessage(_hwnd, CWM_SELECTPATH, _sel, (LPARAM)(LPCSTR)(_path))

// Get the IShellBrowser object associated with an hwndMain
#define CWM_GETISHELLBROWSER        (WM_USER + 7)
#define FileCabinet_GetIShellBrowser(_hwnd)     \
            (IShellBrowser*)SendMessage(_hwnd, CWM_GETISHELLBROWSER, 0, 0L)

//
//  two pidls can have the same path, so we need a compare pidl message
#define CWM_COMPAREPIDL                (WM_USER + 9)
//
//  sent when the global state changes
#define CWM_GLOBALSTATECHANGE           (WM_USER + 10)
#define CWMF_GLOBALSTATE                0x0000
#define CWMF_SECURITY                   0x0001

//  sent to the desktop from a second instance
#define CWM_COMMANDLINE                 (WM_USER + 11)
// global clone your current pidl
#define CWM_CLONEPIDL                   (WM_USER + 12)
// See if the root of the instance is as specified
#define CWM_COMPAREROOT                 (WM_USER + 13)
// Tell desktop our root
#define CWM_SPECIFYCOMPARE              (WM_USER + 14)
// See if the root of the instance matches a hwnd
#define CWM_PERFORMCOMPARE              (WM_USER + 15)
// Forward SHChangeNotify events
#define CWM_FSNOTIFY                    (WM_USER + 16)
// Forward SHChangeRegistration events
#define CWM_CHANGEREGISTRATION          (WM_USER + 17)
// For AddToRecentDocs processing by desktop
#define CWM_ADDTORECENT                 (WM_USER + 18)
// For SHWaitForFile processing by desktopop
#define CWM_WAITOP                      (WM_USER + 19)
// Notify for changes to the fav's folder.
#define CWM_FAV_CHANGE                  (WM_USER + 20)
#define CWM_SHOWDRAGIMAGE               (WM_USER + 21)

#define CWM_SHOWFOLDEROPT               (WM_USER + 22)
#define CWMW_FOLDEROPTIONS      0               // wParam for CWM_SHOWFOLDEROPT
#define CWMW_TASKBAROPTIONS     1               // wParam for CWM_SHOWFOLDEROPT

#define CWM_FSNOTIFYSUSPENDRESUME       (WM_USER + 23)
#define CWM_CREATELOCALSERVER           (WM_USER + 24)
#define CWM_GETSCNWINDOW                (WM_USER + 25)
#define CWM_TASKBARWAKEUP               (WM_USER + 26) // Used to restore tray thread to normal priority in extremely stressed machines
#define CWM_STARTNETCRAWLER             (WM_USER + 27) 

#define CWM_RESERVEDFORCOMDLG_FIRST     (WM_USER + 100)
#define CWM_RESERVEDFORCOMDLG_LAST      (WM_USER + 199)
#define CWM_RESERVEDFORWEBBROWSER_FIRST (WM_USER + 200)
#define CWM_RESERVEDFORWEBBROWSER_LAST  (WM_USER + 299)


;end_internal

//==========================================================================
// IInputObjectSite/IInputObject interfaces
//
//  These interfaces allow us (or ISVs) to install/update external Internet
// Toolbar for IE and the shell. The frame will simply get the CLSID from
// registry (to be defined) and CoCreateInstance it.
//
//==========================================================================

//-------------------------------------------------------------------------
//
// IInputObjectSite interface
//
//   A site implements this interface so the object can communicate
// focus change to it.
//
// [Member functions]
//
// IInputObjectSite::OnFocusChangeIS(punkObj, fSetFocus)
//   Object (punkObj) is getting or losing the focus.
//
//-------------------------------------------------------------------------


#undef  INTERFACE
#define INTERFACE   IInputObjectSite

DECLARE_INTERFACE_(IInputObjectSite, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IInputObjectSite specific methods ***
    STDMETHOD(OnFocusChangeIS)(THIS_ IUnknown* punkObj, BOOL fSetFocus) PURE;
};


//-------------------------------------------------------------------------
//
// IInputObject interface
//
//   An object implements this interface so the site can communicate
// activation and accelerator events to it.
//
// [Member functions]
//
// IInputObject::UIActivateIO(fActivate, lpMsg)
//   Activates or deactivates the object.  lpMsg may be NULL.  Returns
//   S_OK if the activation succeeded.
//
// IInputObject::HasFocusIO()
//   Returns S_OK if the object has the focus, S_FALSE if not.
//
// IInputObject::TranslateAcceleratorIO(lpMsg)
//   Allow the object to process the message.  Returns S_OK if the
//   message was processed (eaten).
//
//-------------------------------------------------------------------------


#undef  INTERFACE
#define INTERFACE   IInputObject

DECLARE_INTERFACE_(IInputObject, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IInputObject specific methods ***
    STDMETHOD(UIActivateIO)(THIS_ BOOL fActivate, LPMSG lpMsg) PURE;
    STDMETHOD(HasFocusIO)(THIS) PURE;
    STDMETHOD(TranslateAcceleratorIO)(THIS_ LPMSG lpMsg) PURE;
};


//==========================================================================
// IDockingWindowSite/IDockingWindow/IDockingWindowFrame interfaces
// IInputObjectSite/IInputObject interfaces
//
//  These interfaces allow us (or ISVs) to install/update external Internet
// Toolbar for IE and the shell. The frame will simply get the CLSID from
// registry (to be defined) and CoCreateInstance it.
//
//==========================================================================


//-------------------------------------------------------------------------
//
// IDockingWindowSite interface
//
//   A site implements this interface so the object can negotiate for
// and inquire about real estate on the site.
//
// [Member functions]
//
// IDockingWindowSite::GetBorderDW(punkObj, prcBorder)
//   Site returns the bounding rectangle of the given source object
//   (punkObj).
//
// IDockingWindowSite::RequestBorderSpaceDW(punkObj, pbw)
//   Object requests that the site makes room for it, as specified in
//   *pbw.
//
// IDockingWindowSite::SetBorderSpaceDW(punkObj, pbw)
//   Object requests that the site set the border spacing to the size
//   specified in *pbw.
//
//-------------------------------------------------------------------------


#undef  INTERFACE
#define INTERFACE   IDockingWindowSite

DECLARE_INTERFACE_(IDockingWindowSite, IOleWindow)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IOleWindow methods ***
    STDMETHOD(GetWindow) (THIS_ HWND * lphwnd) PURE;
    STDMETHOD(ContextSensitiveHelp) (THIS_ BOOL fEnterMode) PURE;

    // *** IDockingWindowSite methods ***
    STDMETHOD(GetBorderDW) (THIS_ IUnknown* punkObj, LPRECT prcBorder) PURE;
    STDMETHOD(RequestBorderSpaceDW) (THIS_ IUnknown* punkObj, LPCBORDERWIDTHS pbw) PURE;
    STDMETHOD(SetBorderSpaceDW) (THIS_ IUnknown* punkObj, LPCBORDERWIDTHS pbw) PURE;
};



//-------------------------------------------------------------------------
//
// IDockingWindowFrame interface
//
//   ;BUGBUG (scotth): fill this in                      ;Internal
//
// [Member functions]
//
// IDockingWindowFrame::AddToolbar(punkSrc, pwszItem, dwReserved)
//
// IDockingWindowFrame::RemoveToolbar(punkSrc, dwRemoveFlags)
//
// IDockingWindowFrame::FindToolbar(pwszItem, riid, ppv)
//
//-------------------------------------------------------------------------


// flags for RemoveToolbar
#define DWFRF_NORMAL            0x0000
#define DWFRF_DELETECONFIGDATA  0x0001

;begin_internal
#define STFRF_NORMAL            DWFRF_NORMAL
#define STFRF_DELETECONFIGDATA  DWFRF_DELETECONFIGDATA
;end_internal

// flags for AddToolbar
#define DWFAF_HIDDEN  0x0001   // add hidden

#undef  INTERFACE
#define INTERFACE   IDockingWindowFrame

DECLARE_INTERFACE_(IDockingWindowFrame, IOleWindow)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IOleWindow methods ***
    STDMETHOD(GetWindow) (THIS_ HWND * lphwnd) PURE;
    STDMETHOD(ContextSensitiveHelp) (THIS_ BOOL fEnterMode) PURE;

    // *** IDockingWindowFrame methods ***
    STDMETHOD(AddToolbar) (THIS_ IUnknown* punkSrc, LPCWSTR pwszItem, DWORD dwAddFlags) PURE;
    STDMETHOD(RemoveToolbar) (THIS_ IUnknown* punkSrc, DWORD dwRemoveFlags) PURE;
    STDMETHOD(FindToolbar) (THIS_ LPCWSTR pwszItem, REFIID riid, void **ppv) PURE;
};



;begin_internal

#undef  INTERFACE
#define INTERFACE   IMultiMonitorDockingSite

DECLARE_INTERFACE_(IMultiMonitorDockingSite, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IMultiMonitorDockingSite methods ***
    STDMETHOD(GetMonitor) (THIS_ IUnknown* punkSrc, HMONITOR * phMon) PURE;
    STDMETHOD(RequestMonitor) (THIS_ IUnknown* punkSrc, HMONITOR * phMon) PURE;
    STDMETHOD(SetMonitor) (THIS_ IUnknown* punkSrc, HMONITOR hMonNew, HMONITOR *phMonOld) PURE;
};
;end_internal


#if (_WIN32_IE >= 0x0400)

//-------------------------------------------------------------------------
//
// IRunnableTask interface
//
//   This is a free threaded interface used for putting items on a background
// scheduler for execution within the view.  It allows a scheduler to start and
// stop tasks on as many worker threads as it deems necessary.
//
// Run(), Kill() and Suspend() may be called from different threads.
//
// [Member functions]
//
// IRunnableTask::Run(void)
//   Initiate the task to run.  This should return E_PENDING if the task
//   has been suspended.
//
// IRunnableTask::Kill(void)
//
// IRunnableTask::Suspend(void)
//
// IRunnableTask::Resume(void)
//
// IRunnableTask::IsRunning(void)
//
//-------------------------------------------------------------------------

// Convenient state values
#define IRTIR_TASK_NOT_RUNNING  0
#define IRTIR_TASK_RUNNING      1
#define IRTIR_TASK_SUSPENDED    2
#define IRTIR_TASK_PENDING      3
#define IRTIR_TASK_FINISHED     4

#undef  INTERFACE
#define INTERFACE   IRunnableTask

DECLARE_INTERFACE_( IRunnableTask, IUnknown )
{
    // *** IUnknown methods ***
    STDMETHOD (QueryInterface)(THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG, AddRef)(THIS) PURE;
    STDMETHOD_(ULONG, Release)(THIS) PURE;

    // *** IRunnableTask methods ***
    STDMETHOD (Run)(THIS) PURE;
    STDMETHOD (Kill)(THIS_ BOOL fWait ) PURE;
    STDMETHOD (Suspend)(THIS) PURE;
    STDMETHOD (Resume)(THIS) PURE;
    STDMETHOD_(ULONG, IsRunning)(THIS) PURE;
};

typedef IRunnableTask * LPRUNNABLETASK;
#endif


#if (_WIN32_IE >= 0x0400)

#define TASKOWNERID     GUID
#define REFTASKOWNERID  REFGUID


// ---IShellTaskScheduler
// An interface for interacting with and controlling a task scheduler. This
// interface does not need to be free-threaded unless the items in the queue
// interact with the scheduler as well as the main execution thread on which the
// task scheduler was created.

// IShellTaskScheduler::AddTask()
//      Adds Tasks to the scheduler's background queue. The TASKOWNERID allow particular types
//      of tasks to be grouped so that they can be counted or removed. The lParam allows the task
//      to be associated with a particular item (for example an item in a listview).
// IShellTaskScheduler::RemoveTasks()
//      Removes tasks from the scheduler's queue. These can be sepcified in terms of their TASKOWNERID
//      or their LPARAM, or both, or neither (TOID_NULL && ITSAT_DEFAULT_LPARAM results in all tasks being
//      removed). If a task that matches is currently running and ITaskScheduler::Status() has been
//      passeed ITSSFLAG_KILL_ON_DESTROY then the scheduler will attempt to kill the current task. The
//      fWaitIfRunning parameter is then passed to IRunnableTask::Kill().
// IShellTaskScheduler::CountTasks()
//      Counts the tasks in the queue depending upon the TASKOWNERID and the LPARAM passed. (TOID_NULL and
//      ITSAT_DEFAULT_LPARAM will count all tasks in the queue)
// IShellTaskScheduler::Status()
//      This sets the ReleaseStatus for the current task and the background thread timeout. When
//      ITaskScheduler::RemoveTasks() is called and there is a task currently running that matches
//      ITSSFLAG_COMPLETE_ON_DESTROY will cause TRUE to be passed to the task's IRunnableTask::Kill().
//      The dwThreadTimeout parameter if not set to the default will cause the background thread to
//      die if no new tasks have been added to the queue in the timeout period. The Thread will be
//      recreated when the next new task is added.

////////////////////////
// Status() flags,
// wait for the current task to complete before deleting the scheduler
#define ITSSFLAG_COMPLETE_ON_DESTROY        0x0000

// kill the current task (if there is one) when the task scheduler is deleted
#define ITSSFLAG_KILL_ON_DESTROY            0x0001

#define ITSSFLAG_SUPPORTS_TERMINATE         0x0002

#define ITSSFLAG_FLAGS_MASK                 0x0003

// set the timeout for killing the thread when the object is terminated.
// this timeout can be used to stop the object from blocking the system
// indefinitely.
#define ITSSFLAG_THREAD_TERMINATE_TIMEOUT   0x0010

// set the timeout for threads that are idle in the thread pool
#define ITSSFLAG_THREAD_POOL_TIMEOUT        0x0020

// The default timeout passed to release Status to determine how long the thread
// can be asleep before the thread is expired
#define ITSS_THREAD_DESTROY_DEFAULT_TIMEOUT     (60*1000)

// default, we won't kill it...
#define ITSS_THREAD_TERMINATE_TIMEOUT           (INFINITE)

// there is no change to the thread timeout
#define ITSS_THREAD_TIMEOUT_NO_CHANGE           (INFINITE - 1)

// the LPARAM allows task to be associated with items thus all tasks owned by a
// particular item can be accessed by passing a non default value for this parameter
#define ITSAT_DEFAULT_LPARAM        0xffffffff

// Task priorities
// ---------------
// This depends on the cooperation of tasks currently under execution. New tasks will
// be inserted in the queue in priority order. If a task of a low priority is currently
// under execution when a higher priority task is added, the scheduler will attempt
// to suspend the task currently under execution. It will be resumed when the other tasks
// have been completed.
#define ITSAT_DEFAULT_PRIORITY      0x10000000
#define ITSAT_MAX_PRIORITY          0x7fffffff
#define ITSAT_MIN_PRIORITY          0x00000000

#define TOID_NULL   CLSID_NULL

#undef INTERFACE
#define INTERFACE IShellTaskScheduler

DECLARE_INTERFACE_( IShellTaskScheduler, IUnknown )
{
    // *** IUnknown methods ***
    STDMETHOD (QueryInterface)(THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG, AddRef)(THIS) PURE;
    STDMETHOD_(ULONG, Release)(THIS) PURE;

    // *** IShellTaskScheduler methods ***
    STDMETHOD (AddTask)(THIS_ IRunnableTask * pTask,
               REFTASKOWNERID rtoid,
               DWORD_PTR lParam,
               DWORD dwPriority ) PURE;

    STDMETHOD (RemoveTasks)(THIS_ REFTASKOWNERID rtoid,
               DWORD_PTR lParam,
               BOOL fWaitIfRunning ) PURE;

    STDMETHOD_(UINT, CountTasks)(THIS_ REFTASKOWNERID rtoid) PURE;

    STDMETHOD (Status)(THIS_ DWORD dwReleaseStatus, DWORD dwThreadTimeout ) PURE;
};

typedef IShellTaskScheduler * LPSHELLTASKSCHEDULER;

#if (_WIN32_IE >= 0x0501)

#define ITSSFLAG_TASK_PLACEINFRONT 0x00000001
#define ITSSFLAG_TASK_PLACEINBACK  0x00000002

#undef INTERFACE
#define INTERFACE IShellTaskScheduler2

DECLARE_INTERFACE_( IShellTaskScheduler2, IShellTaskScheduler )
{
    // *** IUnknown methods ***
    STDMETHOD (QueryInterface)(THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG, AddRef)(THIS) PURE;
    STDMETHOD_(ULONG, Release)(THIS) PURE;

    // *** IShellTaskScheduler methods ***
    STDMETHOD (AddTask)(THIS_ IRunnableTask * pTask,
               REFTASKOWNERID rtoid,
               DWORD_PTR lParam,
               DWORD dwPriority ) PURE;

    STDMETHOD (RemoveTasks)(THIS_ REFTASKOWNERID rtoid,
               DWORD_PTR lParam,
               BOOL fWaitIfRunning ) PURE;

    STDMETHOD_(UINT, CountTasks)(THIS_ REFTASKOWNERID rtoid) PURE;

    STDMETHOD (Status)(THIS_ DWORD dwReleaseStatus, DWORD dwThreadTimeout ) PURE;

    // *** IShellTaskScheduler2 methods ***
    STDMETHOD (AddTask2)(THIS_ IRunnableTask * pTask,
               REFTASKOWNERID rtoid,
               DWORD_PTR lParam,
               DWORD dwPriority,
               DWORD grfFlags ) PURE;

    STDMETHOD (MoveTask)(THIS_ REFTASKOWNERID rtoid,
               DWORD_PTR lParam,
               DWORD dwPriority,
               DWORD grfFlags ) PURE;
};

#endif // (_WIN32_IE >= 0x0501)

#endif // (_WIN32_IE >= 0x0400)


#if (_WIN32_IE >= 0x0400)

/* ***************** IThumbnailCapture
 * CaptureThumbnail : takes an IHTMLDocument2 and returns a thumbnail of specified
 *                    size as an hbitmap
 */

#undef  INTERFACE
#define INTERFACE   IThumbnailCapture

DECLARE_INTERFACE_ ( IThumbnailCapture, IUnknown )
{
    // *** IThumbnailCapture methods ***
    STDMETHOD (CaptureThumbnail)    ( THIS_ const SIZE * pMaxSize,
                                      IUnknown * pHTMLDoc2,
                                      HBITMAP * phbmThumbnail ) PURE;
};
typedef IThumbnailCapture * LPTHUMBNAILCAPTURE;

#endif

;begin_internal
#if (_WIN32_IE >= 0x0400)

// Interface used to scale and sharpen images...
// right now, always pass the palette from SHCreateShellPalette on a 256 colour machine...
#undef  INTERFACE
#define INTERFACE   IScaleAndSharpenImage2

DECLARE_INTERFACE_ (IScaleAndSharpenImage2, IUnknown )
{
    // *** IUnknown methods ***
    STDMETHOD (QueryInterface)(THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG, AddRef) ( THIS ) PURE;
    STDMETHOD_(ULONG, Release) ( THIS ) PURE;

    // *** IScaleAndSharpenImage methods ***
    STDMETHOD( ScaleSharpen2 ) ( THIS_ BITMAPINFO * pbi,
                                void * pBits,
                                HBITMAP * phBmpThumbnail,
                                const SIZE * prgSize,
                                DWORD dwRecClrDepth,
                                HPALETTE hpal,
                                UINT uiSharpPct,
                                BOOL fOrigSize) PURE;
};

// IImageCache
// Interface for controlling and accessing an imagecache of bitmaps for icons..

// flags for the dwMask member of IMAGECACHEINFO
#define ICIFLAG_LARGE       0x0001
#define ICIFLAG_SMALL       0x0002
#define ICIFLAG_BITMAP      0x0004
#define ICIFLAG_ICON        0x0008
#define ICIFLAG_INDEX       0x0010
#define ICIFLAG_NAME        0x0020
#define ICIFLAG_FLAGS       0x0040
#define ICIFLAG_NOUSAGE     0x0080
#define ICIFLAG_DATESTAMP   0x0100
#define ICIFLAG_MIRROR      0x2000
#if (_WIN32_IE >= 0x0501)
#define ICIFLAG_SYSTEM      0x4000
#endif

typedef struct _tagImageCacheInfo
{
    DWORD        cbSize;
    DWORD        dwMask;
    union
    {
        HBITMAP  hBitmapLarge;
        HICON    hIconLarge;
    };
    HBITMAP      hMaskLarge;
    union
    {
        HBITMAP  hBitmapSmall;
        HICON    hIconSmall;
    };
    HBITMAP      hMaskSmall;
    LPCWSTR      pszName;
    int          iIndex;
    DWORD        dwFlags;
#if (_WIN32_IE >= 0x0500)
    FILETIME     ftDateStamp;
#endif
} IMAGECACHEINFO;

typedef IMAGECACHEINFO * LPIMAGECACHEINFO;
typedef const IMAGECACHEINFO * LPCIMAGECACHEINFO;

#define ICIIFLAG_LARGE          0x0001
#define ICIIFLAG_SMALL          0x0002
#if (_WIN32_IE >= 0x0501)
#define ICIIFLAG_SORTBYUSED     0x0004
#endif

typedef struct _tagImageCacheInitInfo
{
    DWORD cbSize;
    DWORD dwMask;
    HIMAGELIST himlLarge;
    HIMAGELIST himlSmall;
    SIZEL rgSizeLarge;
    SIZEL rgSizeSmall;
    DWORD dwFlags;
    int   iStart;
    int   iGrow;
}IMAGECACHEINITINFO;

typedef IMAGECACHEINITINFO * LPIMAGECACHEINITINFO;

#undef  INTERFACE
#define INTERFACE   IImageCache

DECLARE_INTERFACE_ ( IImageCache, IUnknown )
{
    // *** IUnknown methods ***
    STDMETHOD (QueryInterface)(THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG, AddRef) ( THIS ) PURE;
    STDMETHOD_(ULONG, Release) ( THIS ) PURE;

    // *** IImageCache methods ***
    STDMETHOD ( AddImage ) ( THIS_ LPCIMAGECACHEINFO pInfo, UINT * puIndex ) PURE;
    STDMETHOD ( FindImage ) ( THIS_ LPCIMAGECACHEINFO pInfo, UINT * puIndex ) PURE;
    STDMETHOD ( FreeImage ) ( THIS_ UINT iImageIndex ) PURE;
    STDMETHOD ( Flush )( THIS_ BOOL fRelease ) PURE;
    STDMETHOD ( ChangeImageInfo ) ( THIS_ UINT IImageIndex, LPCIMAGECACHEINFO pInfo ) PURE;
    STDMETHOD ( GetCacheSize ) ( THIS_ UINT * puSize ) PURE;
    STDMETHOD ( GetUsage ) ( THIS_ UINT uIndex, UINT * puUsage ) PURE;

    STDMETHOD( GetImageList ) ( THIS_ LPIMAGECACHEINITINFO pInfo ) PURE;
};
typedef IImageCache * LPIMAGECACHE;

#if (_WIN32_IE >= 0x0500)

// IImageCache 2

#undef  INTERFACE
#define INTERFACE  IImageCache2

DECLARE_INTERFACE_ ( IImageCache2, IImageCache )
{
    // *** IUnknown methods ***
    STDMETHOD (QueryInterface)(THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG, AddRef) ( THIS ) PURE;
    STDMETHOD_(ULONG, Release) ( THIS ) PURE;

    // *** IImageCache methods ***
    STDMETHOD ( AddImage ) ( THIS_ LPCIMAGECACHEINFO pInfo, UINT * puIndex ) PURE;
    STDMETHOD ( FindImage ) ( THIS_ LPCIMAGECACHEINFO pInfo, UINT * puIndex ) PURE;
    STDMETHOD ( FreeImage ) ( THIS_ UINT iImageIndex ) PURE;
    STDMETHOD ( Flush )( THIS_ BOOL fRelease ) PURE;
    STDMETHOD ( ChangeImageInfo ) ( THIS_ UINT IImageIndex, LPCIMAGECACHEINFO pInfo ) PURE;
    STDMETHOD ( GetCacheSize ) ( THIS_ UINT * puSize ) PURE;
    STDMETHOD ( GetUsage ) ( THIS_ UINT uIndex, UINT * puUsage ) PURE;

    STDMETHOD( GetImageList ) ( THIS_ LPIMAGECACHEINITINFO pInfo ) PURE;

    // IImageCache2 methods
    STDMETHOD ( DeleteImage ) ( THIS_ UINT iImageIndex ) PURE;
    STDMETHOD ( GetImageInfo ) (THIS_ UINT iImageIndex, LPIMAGECACHEINFO pInfo ) PURE;
};

#endif

#if (_WIN32_IE >= 0x0501)

// These are values returned from IImageCache::GetUsage which correspond
// to the state of the cache entry
#define ICD_USAGE_NOUSAGE (UINT) -1
#define ICD_USAGE_DELETED (UINT) -2
#define ICD_USAGE_SYSTEM  (UINT) -3

// IImageCache 3
#undef  INTERFACE
#define INTERFACE  IImageCache3

DECLARE_INTERFACE_ ( IImageCache3, IImageCache2 )
{
    // *** IUnknown methods ***
    STDMETHOD (QueryInterface)(THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG, AddRef) ( THIS ) PURE;
    STDMETHOD_(ULONG, Release) ( THIS ) PURE;

    // *** IImageCache methods ***
    STDMETHOD ( AddImage ) ( THIS_ LPCIMAGECACHEINFO pInfo, UINT * puIndex ) PURE;
    STDMETHOD ( FindImage ) ( THIS_ LPCIMAGECACHEINFO pInfo, UINT * puIndex ) PURE;
    STDMETHOD ( FreeImage ) ( THIS_ UINT iImageIndex ) PURE;
    STDMETHOD ( Flush )( THIS_ BOOL fRelease ) PURE;
    STDMETHOD ( ChangeImageInfo ) ( THIS_ UINT IImageIndex, LPCIMAGECACHEINFO pInfo ) PURE;
    STDMETHOD ( GetCacheSize ) ( THIS_ UINT * puSize ) PURE;
    STDMETHOD ( GetUsage ) ( THIS_ UINT uIndex, UINT * puUsage ) PURE;

    STDMETHOD ( GetImageList ) ( THIS_ LPIMAGECACHEINITINFO pInfo ) PURE;

    // *** IImageCache2 methods ***
    STDMETHOD ( DeleteImage ) ( THIS_ UINT iImageIndex ) PURE;
    STDMETHOD ( GetImageInfo ) (THIS_ UINT iImageIndex, LPIMAGECACHEINFO pInfo ) PURE;

    // *** IImageCache3 methods ***
    STDMETHOD ( GetImageIndexFromCacheIndex )( UINT iCacheIndex, UINT * puImageIndex ) PURE;
};

#endif

;end_internal

#if ( _WIN32_IE >= 0x0500 )
///////////////////////////////////////////////////////////////////////
// interface for

#include <pshpack8.h>

typedef struct _EnumImageStoreDATAtag
{
    WCHAR     szPath[MAX_PATH];
    FILETIME  ftTimeStamp;
} ENUMSHELLIMAGESTOREDATA, * PENUMSHELLIMAGESTOREDATA;

#include <poppack.h>        /* Return to byte packing */

#undef  INTERFACE
#define INTERFACE   IEnumShellImageStore

DECLARE_INTERFACE_( IEnumShellImageStore, IUnknown )
{
    STDMETHOD ( QueryInterface ) ( THIS_ REFIID riid, void **ppv ) PURE;
    STDMETHOD_( ULONG, AddRef ) ( THIS ) PURE;
    STDMETHOD_( ULONG, Release ) ( THIS ) PURE;

    STDMETHOD ( Reset ) ( THIS ) PURE;
    STDMETHOD ( Next ) ( THIS_ ULONG celt, PENUMSHELLIMAGESTOREDATA * prgElt, ULONG * pceltFetched ) PURE;
    STDMETHOD ( Skip ) ( THIS_ ULONG celt ) PURE;
    STDMETHOD ( Clone ) ( THIS_ IEnumShellImageStore ** ppEnum ) PURE;
};

typedef IEnumShellImageStore * LPENUMSHELLIMAGESTORE;


// flags used to determine the capabilities of the storage for the images
#define SHIMSTCAPFLAG_LOCKABLE    0x0001       // does the store require/support locking
#define SHIMSTCAPFLAG_PURGEABLE   0x0002       // does the store require dead items purging externally ?

#undef  INTERFACE
#define INTERFACE   IShellImageStore

// this interface is used to manipulate the Image cache. It can potentially be used
// in a free threaded manner in conjunction with the Lock parameter to Open and close
DECLARE_INTERFACE_( IShellImageStore, IUnknown )
{
    STDMETHOD ( QueryInterface )( THIS_ REFIID riid, void **ppv ) PURE;
    STDMETHOD_( ULONG, AddRef ) ( THIS ) PURE;
    STDMETHOD_( ULONG, Release ) ( THIS ) PURE;

    // if the lock parameter is used, then all other calls into
    // open and/or create will block until the lock is released.
    STDMETHOD ( Open ) ( THIS_ DWORD dwMode, DWORD * pdwLock ) PURE;
    STDMETHOD ( Create ) ( THIS_ DWORD dwMode, DWORD * pdwLock ) PURE;

    // if the lock is passed to either of these two methods, it releases the lock
    // once the operation is complete.
    STDMETHOD ( ReleaseLock ) ( THIS_ DWORD const * pdwLock ) PURE;
    STDMETHOD ( Close ) ( THIS_ DWORD const * pdwLock ) PURE;
    STDMETHOD ( Commit ) ( THIS_ DWORD const * pdwLock ) PURE;
    STDMETHOD ( IsLocked ) ( THIS ) PURE;

    STDMETHOD ( GetMode ) ( THIS_ DWORD * pdwMode ) PURE;
    STDMETHOD ( GetCapabilities ) ( THIS_ DWORD * pdwCapMask ) PURE;

    STDMETHOD ( AddEntry ) ( THIS_ LPCWSTR pszName, const FILETIME * pftTimeStamp, DWORD dwMode, HBITMAP hImage ) PURE;
    STDMETHOD ( GetEntry ) ( THIS_ LPCWSTR pszName, DWORD dwMode, HBITMAP * phImage ) PURE;
    STDMETHOD ( DeleteEntry ) ( THIS_ LPCWSTR pszName ) PURE;
    STDMETHOD ( IsEntryInStore ) ( THIS_ LPCWSTR pszName, FILETIME * pftTimeStamp ) PURE;

    STDMETHOD ( Enum ) ( THIS_ LPENUMSHELLIMAGESTORE * ppEnum ) PURE;
};

typedef IShellImageStore * LPSHELLIMAGESTORE;
#endif

;begin_internal
//
// Interface for interacting with the IE splash screen
//

#undef  INTERFACE
#define INTERFACE   ISplashScreen

DECLARE_INTERFACE_( ISplashScreen, IUnknown )
{
    // *** IUnknown methods ***
    STDMETHOD (QueryInterface)(THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG, AddRef) ( THIS ) PURE;
    STDMETHOD_(ULONG, Release) ( THIS ) PURE;

    // *** ISplashScreen methods ***
    STDMETHOD ( Show ) ( THIS_ HINSTANCE hinst, UINT idResHi, UINT idResLow, HWND * phwnd ) PURE;
    STDMETHOD ( Dismiss ) (THIS) PURE;
};

typedef ISplashScreen * LPSPLASHSCREEN;

;begin_internal

//
// Interface for Multiple Monitor Configurations
//

#define MD_PRIMARY  0x00000001
#define MD_ATTACHED 0x00000002

#include <pshpack8.h>

typedef struct _MonitorData
{
    DWORD dwSize;
    DWORD dwFlags;
    DWORD dwStatus;
    RECT rcPos;
} MonitorData, * LPMONITORDATA;

#include <poppack.h>        /* Return to byte packing */

#undef  INTERFACE
#define INTERFACE   IMultiMonConfig

DECLARE_INTERFACE_( IMultiMonConfig, IUnknown )
{
    // *** IUnknown methods ***
    STDMETHOD (QueryInterface)(THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG, AddRef) ( THIS ) PURE;
    STDMETHOD_(ULONG, Release) ( THIS ) PURE;

    // *** IMultiMonConfig methods ***
    STDMETHOD ( Initialize ) ( THIS_ HWND hwndHost, WNDPROC WndProc, DWORD dwReserved) PURE;
    STDMETHOD ( GetNumberOfMonitors ) (THIS_ int * pCMon, DWORD dwReserved) PURE;
    STDMETHOD ( GetMonitorData) (THIS_ int iMonitor, MonitorData * pmd, DWORD dwReserved) PURE;
    STDMETHOD ( Paint) (THIS_ int iMonitor, DWORD dwReserved) PURE;
};

typedef IMultiMonConfig * LPMULTIMONCONFIG;
;end_internal
#endif // _WIN32_IE > 0x0400

////  IRestrict
// For the pdwRestrictionResult out parameter in IRestrict::IsRestricted() for
// all pguidIDs.
typedef enum
{
    RR_ALLOW  = 1,
    RR_DISALLOW,
    RR_NOCHANGE,
} RESTRICTION_RESULT;

// IRestrict::IsRestricted() dwRestrictAction parameter values for
// the RID_RDeskBars pguidID.
typedef enum
{
    RA_DRAG  = 1,
    RA_DROP,
    RA_ADD,
    RA_CLOSE,
    RA_MOVE,
} RESTRICT_ACTIONS;

#undef INTERFACE
#define INTERFACE IRestrict

DECLARE_INTERFACE_(IRestrict, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IRestrict Methods ***
    STDMETHOD(IsRestricted) (THIS_ const GUID * pguidID, DWORD dwRestrictAction, VARIANT * pvarArgs, OUT DWORD * pdwRestrictionResult) PURE;
};


////  IAddressBand
#define OLECMD_REFRESH_TOPMOST     0x00000000
#define OLECMD_REFRESH_ENTIRELIST  0x00000001

#undef INTERFACE
#define INTERFACE IAddressBand

DECLARE_INTERFACE_(IAddressBand, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IAddressBand Methods ***
    STDMETHOD(FileSysChange) (THIS_ DWORD dwEvent, LPCITEMIDLIST * ppidl1) PURE;
    STDMETHOD(Refresh) (THIS_ VARIANT * pvarType) PURE;
};

#undef INTERFACE
#define INTERFACE IAddressEditBox

// Init Flags
#define AEB_INIT_DEFAULT     0x00000000
#define AEB_INIT_NOSHELL     0x00000001
#define AEB_INIT_NOWEB       0x00000002
#define AEB_INIT_NOFILE      0x00000004
#define AEB_INIT_AUTOEXEC    0x00000008     // Set if you want the item Navigated/ShellExeced when ENTER occurs.
#define AEB_INIT_SUBCLASS    0x00000010     // If set parent needs to pass HWND events thru IWinEventHandler::OnWinEvent()
#define AEB_INIT_NOASYNC     0x00000020     // Set if you don't want/support async navigation (from a modal dlg for instance)

// Parse Flags for IAddressEditBox::ParseNow()
#define SHURL_FLAGS_NONE        0x00000000
#define SHURL_FLAGS_NOUI        0x00000001      // Don't display any UI.
#define SHURL_FLAGS_NOSNS       0x00000002      // Ignore SHELL URLs. (FILE and Internet URLs still work)
#define SHURL_FLAGS_NOWEB       0x00000004      // Ignore WEB URLs. (Don't successfully parse if not found in shell name space)
#define SHURL_FLAGS_NOPATHSEARCH 0x00000008     // don't search on dos paths or app path
#define SHURL_FLAGS_AUTOCORRECT 0x00000010      // Try to autocorrect WEB URLs

// Exec Flags for IAddressEditBox::Execute()
#define SHURL_EXECFLAGS_NONE        0x00000000
#define SHURL_EXECFLAGS_SEPVDM      0x00000001      // If ShellExec(), set SEE_MASK_FLAG_SEPVDM fMask.
#define SHURL_EXECFLAGS_DONTFORCEIE 0x00000002      // If some browser other than IE is associated with HTML files, allow them to launch.


DECLARE_INTERFACE_(IAddressEditBox, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IAddressEditBox Methods ***
    STDMETHOD(Init) (THIS_ HWND hwnd, HWND hwndEditBox, DWORD dwFlags, IUnknown * punkParent) PURE;
    STDMETHOD(SetCurrentDir) (THIS_ LPCOLESTR pwzDir) PURE;
    STDMETHOD(ParseNow) (THIS_ DWORD dwParseFlags) PURE;
    STDMETHOD(Execute) (THIS_ DWORD dwExecFlags) PURE;
    STDMETHOD(Save) (THIS_ DWORD dwReserved) PURE;
};


;begin_both
#if (_WIN32_IE >= 0x0400)

;end_both

;end_internal

////  IShellFolderBand

// Field mask
#define ISFB_MASK_STATE          0x00000001 // TRUE if dwStateMask and dwState is valid
#define ISFB_MASK_BKCOLOR        0x00000002 // TRUE if crBkgnd field is valid
#define ISFB_MASK_VIEWMODE       0x00000004 // TRUE if wViewMode field is valid
#define ISFB_MASK_SHELLFOLDER    0x00000008
#define ISFB_MASK_IDLIST         0x00000010
#define ISFB_MASK_COLORS         0x00000020 // TRUE if crXXXX fields are valid (except bkgnd)
#define ISFB_MASK_ALL            0x0000003F         // ;Internal
#define ISFB_MASK_INVALID        (~(ISFB_MASK_ALL)) // ;Internal

#define ISFB_STATE_DEFAULT       0x00000000
#define ISFB_STATE_DEBOSSED      0x00000001
#define ISFB_STATE_ALLOWRENAME   0x00000002
#define ISFB_STATE_NOSHOWTEXT    0x00000004 // TRUE if _fNoShowText
//#define ISFB_STATE_NOTITLE       0x00000008 // obsolete! (use cbs::SetBandState) ;Internal
#define ISFB_STATE_CHANNELBAR    0x00000010 // TRUE if we want NavigateTarget support
#define ISFB_STATE_QLINKSMODE    0x00000020 // TRUE if we want to turn off drag & drop onto content items
#define ISFB_STATE_FULLOPEN      0x00000040 // TRUE if band should maximize when opened
#define ISFB_STATE_NONAMESORT    0x00000080 // TRUE if band should _not_ sort icons by name
#define ISFB_STATE_BTNMINSIZE    0x00000100 // TRUE if band should report min thickness of button
#define ISFB_STATE_ALL           0x000001FF // ;Internal

#define ISFBVIEWMODE_SMALLICONS   0x0001
#define ISFBVIEWMODE_LARGEICONS   0x0002
#define ISFBVIEWMODE_LOGOS        0x0003

#include <pshpack8.h>

typedef struct {
    DWORD       dwMask;       // [in] ISFB_MASK mask of valid fields from crBkgnd on
    DWORD       dwStateMask;  // [in] ISFB_STATE mask of dwState bits being set/queried
    DWORD       dwState;      // [in/out] ISFB_STATE bits
    COLORREF    crBkgnd;      // [in/out]
    COLORREF    crBtnLt;      // [in/out]
    COLORREF    crBtnDk;      // [in/out]
    WORD        wViewMode;    // [in/out]
    WORD        wAlign;       // not used (yet)
    IShellFolder * psf;       // [out]
    LPITEMIDLIST   pidl;      // [out]
} BANDINFOSFB, *PBANDINFOSFB;

#include <poppack.h>        /* Return to byte packing */

#undef INTERFACE
#define INTERFACE IShellFolderBand

DECLARE_INTERFACE_(IShellFolderBand, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IShellFolderBand Methods ***
    STDMETHOD(InitializeSFB)(THIS_ IShellFolder *psf, LPCITEMIDLIST pidl) PURE;
    STDMETHOD(SetBandInfoSFB)(THIS_ PBANDINFOSFB pbi) PURE;
    STDMETHOD(GetBandInfoSFB)(THIS_ PBANDINFOSFB pbi) PURE;
};

// Command Target IDs
enum {
    SFBID_PIDLCHANGED,
};

;begin_internal

//-------------------------------------------------------------------------
//
// IWinEventHandler interface
//
//   An object that wants to send messages to another object (typically
// a sub-object) QI's for the sub-object's IWinEventHandler interface.
// Once the object determines the hwnd is owned by the sub-object (via
// IsWindowOwner), the object calls OnWinEvent for send the message.
//
//
// [Member functions]
//
// IWinEventHandler::IsWindowOwner(hwnd)
//   Returns S_OK if the hwnd is owned by the object, S_FALSE if not.
//
// IWinEventHandler::OnWinEvent(hwnd, dwMsg, wParam, lParam, plRet)
//   Sends a message to the object.  The Win32 return value (i.e., the
//   value returned by DefWindowProc) is returned in *plRet.  Return
//   S_OK if the message is handled, otherwise S_FALSE.
//
//-------------------------------------------------------------------------


#undef INTERFACE
#define INTERFACE IWinEventHandler

DECLARE_INTERFACE_(IWinEventHandler, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IWinEventHandler Methods ***
    STDMETHOD(OnWinEvent) (THIS_ HWND hwnd, UINT dwMsg, WPARAM wParam, LPARAM lParam, LRESULT* plres) PURE;
    STDMETHOD(IsWindowOwner) (THIS_ HWND hwnd) PURE;
};


;end_internal

////  IDeskBarClient

#undef  INTERFACE
#define INTERFACE   IDeskBarClient

DECLARE_INTERFACE_(IDeskBarClient, IOleWindow)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IOleWindow methods ***
    STDMETHOD(GetWindow) (THIS_ HWND * lphwnd) PURE;
    STDMETHOD(ContextSensitiveHelp) (THIS_ BOOL fEnterMode) PURE;

    // *** IDeskBarClient methods ***
    STDMETHOD(SetDeskBarSite)   (THIS_ IUnknown* punkSite) PURE;
    STDMETHOD(SetModeDBC)          (THIS_ DWORD dwMode) PURE;
    STDMETHOD(UIActivateDBC)    (THIS_ DWORD dwState) PURE;
    STDMETHOD(GetSize)    (THIS_ DWORD dwWhich, LPRECT prc) PURE;
};

#define DBC_GS_IDEAL          0  // get the ideal size
#define DBC_GS_SIZEDOWN       1  // clip the height of a rect to a multiple of the rebar's integral size


#define DBC_HIDE        0 // Band is hidden (being destroyed)
#define DBC_SHOW        1 // Band is visible
#define DBC_SHOWOBSCURE 2 // Band is completely obscured


enum {
    DBCID_EMPTY = 0,        // bandsite is empty
    DBCID_ONDRAG = 1,       // (down)DragMoveEnter/Leave vaIn:I4:eDrag
    DBCID_CLSIDOFBAR = 2,   // clsid of bar inside  
    DBCID_RESIZE = 3,       // resize from keyboard
    DBCID_GETBAR = 4,       // returns vaOut:VT_UNKNOWN of hosting dockbar (IDeskBar)
};

;begin_both

#endif // _WIN32_IE > 0x0400

;end_both

;begin_internal


//==========================================================================
// IExplorerToolbar interfaces
//
//  This is an interface to the shell toolbar which allows shell views
// to add buttons and process.
// See http://ohserv/users/satona/toolbar_extension.htm for spec.
//
//==========================================================================

// Bitmap types
#define BITMAP_NORMAL         0x1
#define BITMAP_HOT            0x2
#define BITMAP_DISABLED       0x3

// Band Visibility Flags
#define VBF_TOOLS               0x00000001
#define VBF_ADDRESS             0x00000002
#define VBF_LINKS               0x00000004
#define VBF_BRAND               0x00000008
#define VBF_MENU                0x00000010

#define VBF_ONELINETEXT         0x00000020
#define VBF_TWOLINESTEXT        0x00000040
#define VBF_NOCUSTOMIZE         0x00000080

#define VBF_EXTERNALBANDS       0xFFFF0000

#define VBF_VALID               (VBF_TOOLS | VBF_ADDRESS | VBF_LINKS | VBF_BRAND | VBF_MENU | VBF_EXTERNALBANDS)

#undef  INTERFACE
#define INTERFACE   IExplorerToolbar

typedef enum {
    ETCMDID_GETBUTTONS          = 0x0001,
    ETCMDID_NEWCOMMANDTARGET    = 0x0002,   // sent to the previous command target when a new one is coming in
#if (_WIN32_IE >= 0x500)
    ETCMDID_RELOADBUTTONS       = 0x0003,   // command target needs to call AddButtons again
#endif
} ENUM_ETCMDID;

DECLARE_INTERFACE_(IExplorerToolbar, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IExplorerToolbar methods ***
    STDMETHOD(SetCommandTarget) (THIS_ IUnknown* punkCmdTarget, const GUID* pguidCmdGrp, DWORD dwFlags) PURE;
    STDMETHOD(AddStdBrowserButtons) (THIS) PURE;

    // Wrap of the TB_* messages the messages that are implmented
    // are just the ones to add delete and modify the buttons, and not
    // the ones to manipulate the toolbar.
    STDMETHOD(AddButtons)       (THIS_ const GUID * pguidButtonGroup, UINT nButtons, const TBBUTTON * lpButtons) PURE;
    STDMETHOD(AddString)        (THIS_ const GUID * pguidButtonGroup, HINSTANCE hInst, UINT_PTR uiResID, LRESULT * pOffset) PURE;
    STDMETHOD(GetButton)        (THIS_ const GUID * pguidButtonGroup, UINT uiCommand, LPTBBUTTON lpButton) PURE;
    STDMETHOD(GetState)         (THIS_ const GUID * pguidButtonGroup, UINT uiCommand, UINT * pfState) PURE;
    STDMETHOD(SetState)         (THIS_ const GUID * pguidButtonGroup, UINT uiCommand, UINT fState) PURE;
    STDMETHOD(AddBitmap)        (THIS_ const GUID * pguidButtonGroup, UINT uiBMPType, UINT uiCount, TBADDBITMAP * ptb,
                                                        LRESULT * pOffset, COLORREF rgbMask) PURE;
    STDMETHOD(GetBitmapSize)    (THIS_ UINT * uiID) PURE;
    STDMETHOD(SendToolbarMsg)   (THIS_ const GUID * pguidButtonGroup, UINT uMsg, WPARAM wParam, LPARAM lParam, LRESULT * plRes) PURE;

    STDMETHOD(SetImageList) (THIS_ const GUID* pguidCmdGroup, HIMAGELIST himlNormal, HIMAGELIST himlHot, HIMAGELIST himlDisabled) PURE;
    STDMETHOD(ModifyButton)     (THIS_ const GUID * pguidButtonGroup, UINT uiCommand, LPTBBUTTON lpButton) PURE;
};

//==========================================================================
// DefView supports a private service id for extended views.
// DefView's IOleCommandTarget supports the below command group and ids too.
//==========================================================================
// SID_DefView and CGID_DefView are defined in shlguid.w
//
#define DVCMDID_GETTHISDIRPATH 1 // pvaOut = path to this directory (if in filesystem)
#define DVCMDID_GETTHISDIRNAME 2 // pvaOut = friendly name of this directory
#define DVCMDID_GETTEMPLATEDIRNAME 3 // pvaOut = webview template (.htt) dir
;end_internal

#if (_WIN32_IE >= 0x400)
//
// We need to make sure that WININET.H is included before this interface is
// used because the COMPONENT structure uses INTERNET_MAX_URL_LENGTH
//
#ifdef _WININET_
//
//  Flags and structures used by IActiveDesktop
//

typedef struct _tagWALLPAPEROPT
{
    DWORD   dwSize;     // size of this Structure.
    DWORD   dwStyle;    // WPSTYLE_* mentioned above
}
WALLPAPEROPT;

typedef WALLPAPEROPT  *LPWALLPAPEROPT;
typedef const WALLPAPEROPT *LPCWALLPAPEROPT;

typedef struct _tagCOMPONENTSOPT
{
    DWORD   dwSize;             //Size of this structure
    BOOL    fEnableComponents;  //Enable components?
    BOOL    fActiveDesktop;     // Active desktop enabled ?
}
COMPONENTSOPT;

typedef COMPONENTSOPT   *LPCOMPONENTSOPT;
typedef const COMPONENTSOPT   *LPCCOMPONENTSOPT;

typedef struct _tagCOMPPOS
{
    DWORD   dwSize;             //Size of this structure
    int     iLeft;              //Left of top-left corner in screen co-ordinates.
    int     iTop;               //Top of top-left corner in screen co-ordinates.
    DWORD   dwWidth;            // Width in pixels.
    DWORD   dwHeight;           // Height in pixels.
    int     izIndex;            // Indicates the Z-order of the component.
    BOOL    fCanResize;         // Is the component resizeable?
    BOOL    fCanResizeX;        // Resizeable in X-direction?
    BOOL    fCanResizeY;        // Resizeable in Y-direction?
    int     iPreferredLeftPercent;    //Left of top-left corner as percent of screen width
    int     iPreferredTopPercent;     //Top of top-left corner as percent of screen height
}
COMPPOS;

typedef COMPPOS *LPCOMPPOS;
typedef const COMPPOS *LPCCOMPPOS;

typedef struct  _tagCOMPSTATEINFO
{
    DWORD   dwSize;             // Size of this structure.
    int     iLeft;              // Left of the top-left corner in screen co-ordinates.
    int     iTop;               // Top of top-left corner in screen co-ordinates.
    DWORD   dwWidth;            // Width in pixels.
    DWORD   dwHeight;           // Height in pixels.
    DWORD   dwItemState;        // State of the component (full-screen mode or split-screen or normal state.
}
COMPSTATEINFO;

typedef COMPSTATEINFO   *LPCOMPSTATEINFO;
typedef const COMPSTATEINFO *LPCCOMPSTATEINFO;



#define COMPONENT_TOP (0x3fffffff)  // izOrder value meaning component is at the top


// iCompType values
#define COMP_TYPE_HTMLDOC       0
#define COMP_TYPE_PICTURE       1
#define COMP_TYPE_WEBSITE       2
#define COMP_TYPE_CONTROL       3
#define COMP_TYPE_CFHTML        4
#define COMP_TYPE_MAX           4

// The following is the COMPONENT structure used in IE4.01, IE4.0 and Memphis. It is kept here for compatibility
// reasons.
typedef struct _tagIE4COMPONENT
{
    DWORD   dwSize;             //Size of this structure
    DWORD   dwID;               //Reserved: Set it always to zero.
    int     iComponentType;     //One of COMP_TYPE_*
    BOOL    fChecked;           // Is this component enabled?
    BOOL    fDirty;             // Had the component been modified and not yet saved to disk?
    BOOL    fNoScroll;          // Is the component scrollable?
    COMPPOS cpPos;              // Width, height etc.,
    WCHAR   wszFriendlyName[MAX_PATH];          // Friendly name of component.
    WCHAR   wszSource[INTERNET_MAX_URL_LENGTH]; //URL of the component.
    WCHAR   wszSubscribedURL[INTERNET_MAX_URL_LENGTH]; //Subscrined URL
}
IE4COMPONENT;

typedef IE4COMPONENT *LPIE4COMPONENT;
typedef const IE4COMPONENT *LPCIE4COMPONENT;

//
// The following is the new NT5 component structure. Note that the initial portion of this component exactly
// matches the IE4COMPONENT structure. All new fields are added at the bottom and the dwSize field is used to
// distinguish between IE4COMPONENT and the new COMPONENT structures.
//
typedef struct _tagCOMPONENT
{
    DWORD   dwSize;             //Size of this structure
    DWORD   dwID;               //Reserved: Set it always to zero.
    int     iComponentType;     //One of COMP_TYPE_*
    BOOL    fChecked;           // Is this component enabled?
    BOOL    fDirty;             // Had the component been modified and not yet saved to disk?
    BOOL    fNoScroll;          // Is the component scrollable?
    COMPPOS cpPos;              // Width, height etc.,
    WCHAR   wszFriendlyName[MAX_PATH];          // Friendly name of component.
    WCHAR   wszSource[INTERNET_MAX_URL_LENGTH]; //URL of the component.
    WCHAR   wszSubscribedURL[INTERNET_MAX_URL_LENGTH]; //Subscrined URL

    //New fields are added below. Everything above here must exactly match the IE4COMPONENT Structure.
    DWORD           dwCurItemState; // Current state of the Component.
    COMPSTATEINFO   csiOriginal;    // Original state of the component when it was first added.
    COMPSTATEINFO   csiRestored;    // Restored state of the component.
}
COMPONENT;

typedef COMPONENT *LPCOMPONENT;
typedef const COMPONENT *LPCCOMPONENT;


// Defines for dwCurItemState
#define IS_NORMAL               0x00000001
#define IS_FULLSCREEN           0x00000002
#define IS_SPLIT                0x00000004
#define IS_VALIDSIZESTATEBITS   (IS_NORMAL | IS_SPLIT | IS_FULLSCREEN)  // The set of IS_* state bits which define the "size" of the component - these bits are mutually exclusive.
#define IS_VALIDSTATEBITS       (IS_NORMAL | IS_SPLIT | IS_FULLSCREEN | 0x80000000 | 0x40000000)  // All of the currently defined IS_* bits.
;begin_internal
#define IS_ADJUSTLISTVIEW       0x80000000
#define IS_INTERNALDUMMYBIT     0x40000000
#define IS_VALIDINTERNALBITS    (IS_ADJUSTLISTVIEW | IS_INTERNALDUMMYBIT)
;end_internal

////////////////////////////////////////////
// Flags for IActiveDesktop::ApplyChanges()
#define AD_APPLY_SAVE             0x00000001
#define AD_APPLY_HTMLGEN          0x00000002
#define AD_APPLY_REFRESH          0x00000004
#define AD_APPLY_ALL              (AD_APPLY_SAVE | AD_APPLY_HTMLGEN | AD_APPLY_REFRESH)
#define AD_APPLY_FORCE            0x00000008
#define AD_APPLY_BUFFERED_REFRESH 0x00000010
#define AD_APPLY_DYNAMICREFRESH   0x00000020

////////////////////////////////////////////
// Flags for IActiveDesktop::GetWallpaperOptions()
//           IActiveDesktop::SetWallpaperOptions()
#define WPSTYLE_CENTER      0
#define WPSTYLE_TILE        1
#define WPSTYLE_STRETCH     2
#define WPSTYLE_MAX         3


////////////////////////////////////////////
// Flags for IActiveDesktop::ModifyComponent()

#define COMP_ELEM_TYPE          0x00000001
#define COMP_ELEM_CHECKED       0x00000002
#define COMP_ELEM_DIRTY         0x00000004
#define COMP_ELEM_NOSCROLL      0x00000008
#define COMP_ELEM_POS_LEFT      0x00000010
#define COMP_ELEM_POS_TOP       0x00000020
#define COMP_ELEM_SIZE_WIDTH    0x00000040
#define COMP_ELEM_SIZE_HEIGHT   0x00000080
#define COMP_ELEM_POS_ZINDEX    0x00000100
#define COMP_ELEM_SOURCE        0x00000200
#define COMP_ELEM_FRIENDLYNAME  0x00000400
#define COMP_ELEM_SUBSCRIBEDURL 0x00000800
#define COMP_ELEM_ORIGINAL_CSI  0x00001000
#define COMP_ELEM_RESTORED_CSI  0x00002000
#define COMP_ELEM_CURITEMSTATE  0x00004000

#define COMP_ELEM_ALL   (COMP_ELEM_TYPE | COMP_ELEM_CHECKED | COMP_ELEM_DIRTY |                     \
                         COMP_ELEM_NOSCROLL | COMP_ELEM_POS_LEFT | COMP_ELEM_SIZE_WIDTH  |          \
                         COMP_ELEM_SIZE_HEIGHT | COMP_ELEM_POS_ZINDEX | COMP_ELEM_SOURCE |          \
                         COMP_ELEM_FRIENDLYNAME | COMP_ELEM_POS_TOP | COMP_ELEM_SUBSCRIBEDURL |     \
                         COMP_ELEM_ORIGINAL_CSI | COMP_ELEM_RESTORED_CSI | COMP_ELEM_CURITEMSTATE)


////////////////////////////////////////////
// Flags for IActiveDesktop::AddDesktopItemWithUI()
typedef enum tagDTI_ADTIWUI
{
    DTI_ADDUI_DEFAULT               = 0x00000000,
    DTI_ADDUI_DISPSUBWIZARD         = 0x00000001,
    DTI_ADDUI_POSITIONITEM          = 0x00000002,
};


////////////////////////////////////////////
// Flags for IActiveDesktop::AddUrl()
#define ADDURL_SILENT           0X0001


////////////////////////////////////////////
// Default positions for ADI
#define COMPONENT_DEFAULT_LEFT    (0xFFFF)
#define COMPONENT_DEFAULT_TOP     (0xFFFF)




//
//  Interface for manipulating the Active Desktop.
//

#undef INTERFACE
#define INTERFACE IActiveDesktop

DECLARE_INTERFACE_( IActiveDesktop, IUnknown )
{
    // IUnknown methods
    STDMETHOD (QueryInterface)(THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG, AddRef) ( THIS ) PURE;
    STDMETHOD_(ULONG, Release) ( THIS ) PURE;

    // IActiveDesktop methods
    STDMETHOD (ApplyChanges)(THIS_ DWORD dwFlags) PURE;
    STDMETHOD (GetWallpaper)(THIS_ LPWSTR pwszWallpaper, UINT cchWallpaper, DWORD dwReserved) PURE;
    STDMETHOD (SetWallpaper)(THIS_ LPCWSTR pwszWallpaper, DWORD dwReserved) PURE;
    STDMETHOD (GetWallpaperOptions)(THIS_ LPWALLPAPEROPT pwpo, DWORD dwReserved) PURE;
    STDMETHOD (SetWallpaperOptions)(THIS_ LPCWALLPAPEROPT pwpo, DWORD dwReserved) PURE;
    STDMETHOD (GetPattern)(THIS_ LPWSTR pwszPattern, UINT cchPattern, DWORD dwReserved) PURE;
    STDMETHOD (SetPattern)(THIS_ LPCWSTR pwszPattern, DWORD dwReserved) PURE;
    STDMETHOD (GetDesktopItemOptions)(THIS_ LPCOMPONENTSOPT pco, DWORD dwReserved) PURE;
    STDMETHOD (SetDesktopItemOptions)(THIS_ LPCCOMPONENTSOPT pco, DWORD dwReserved) PURE;
    STDMETHOD (AddDesktopItem)(THIS_ LPCCOMPONENT pcomp, DWORD dwReserved) PURE;
    STDMETHOD (AddDesktopItemWithUI)(THIS_ HWND hwnd, LPCOMPONENT pcomp, DWORD dwReserved) PURE;
    STDMETHOD (ModifyDesktopItem)(THIS_ LPCCOMPONENT pcomp, DWORD dwFlags) PURE;
    STDMETHOD (RemoveDesktopItem)(THIS_ LPCCOMPONENT pcomp, DWORD dwReserved) PURE;
    STDMETHOD (GetDesktopItemCount)(THIS_ LPINT lpiCount, DWORD dwReserved) PURE;
    STDMETHOD (GetDesktopItem)(THIS_ int nComponent, LPCOMPONENT pcomp, DWORD dwReserved) PURE;
    STDMETHOD (GetDesktopItemByID)(THIS_ ULONG_PTR dwID, LPCOMPONENT pcomp, DWORD dwReserved) PURE;
    STDMETHOD (GenerateDesktopItemHtml)(THIS_ LPCWSTR pwszFileName, LPCOMPONENT pcomp, DWORD dwReserved) PURE;
    STDMETHOD (AddUrl)(THIS_ HWND hwnd, LPCWSTR pszSource, LPCOMPONENT pcomp, DWORD dwFlags) PURE;
    STDMETHOD (GetDesktopItemBySource)(THIS_ LPCWSTR pwszSource, LPCOMPONENT pcomp, DWORD dwReserved) PURE;
};

typedef IActiveDesktop * LPACTIVEDESKTOP;

// Flags for SetSafeMode
#define SSM_CLEAR   0x0000
#define SSM_SET     0x0001
#define SSM_REFRESH 0x0002
#define SSM_UPDATE  0x0004

// Flags for Set/GetScheme
#define SCHEME_DISPLAY          0x0001
#define SCHEME_EDIT             0x0002
#define SCHEME_LOCAL            0x0004
#define SCHEME_GLOBAL           0x0008
#define SCHEME_REFRESH          0x0010
#define SCHEME_UPDATE           0x0020
#define SCHEME_DONOTUSE 0x0040 // used to be SCHEME_ENUMERATE; no longer supported
#define SCHEME_CREATE           0x0080

#undef INTERFACE
#define INTERFACE IActiveDesktopP

DECLARE_INTERFACE_( IActiveDesktopP, IUnknown )
{
    // IUnknown methods
    STDMETHOD (QueryInterface)(THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG, AddRef) ( THIS ) PURE;
    STDMETHOD_(ULONG, Release) ( THIS ) PURE;

    // IActiveDesktopP methods
    STDMETHOD (SetSafeMode)(THIS_ DWORD dwFlags) PURE;
    STDMETHOD (EnsureUpdateHTML)(THIS) PURE;
    STDMETHOD (SetScheme)(THIS_ LPCWSTR pwszSchemeName, DWORD dwFlags) PURE;
    STDMETHOD (GetScheme)(THIS_ LPWSTR pwszSchemeName, DWORD *lpdwcchBuffer, DWORD dwFlags) PURE;
    //
};

typedef IActiveDesktopP * LPACTIVEDESKTOPP;

//Flags for GetObjectFlags
#define GADOF_DIRTY    0x00000001

#undef INTERFACE
#define INTERFACE IADesktopP2

DECLARE_INTERFACE_( IADesktopP2, IUnknown )
{
    // IUnknown methods
    STDMETHOD (QueryInterface)(THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG, AddRef) ( THIS ) PURE;
    STDMETHOD_(ULONG, Release) ( THIS ) PURE;

    // IADesktopP2 methods
    STDMETHOD (ReReadWallpaper)(THIS) PURE;
    STDMETHOD (GetADObjectFlags)(THIS_ DWORD *lpdwFlags, DWORD dwMask) PURE;
    STDMETHOD (UpdateAllDesktopSubscriptions)(THIS) PURE;
    STDMETHOD (MakeDynamicChanges)(THIS_ IOleObject *pOleObj) PURE;
};

typedef IADesktopP2 * LPADESKTOPP2;


#endif // _WININET_

#if (_WIN32_IE >= 0x0500)

#define MAX_COLUMN_NAME_LEN 80
#define MAX_COLUMN_DESC_LEN 128

#include <pshpack1.h>

typedef struct {
    SHCOLUMNID  scid;                           // OUT the unique identifier of this column
    VARTYPE     vt;                             // OUT the native type of the data returned
    DWORD       fmt;                            // OUT this listview format (LVCFMT_LEFT, usually)
    UINT        cChars;                         // OUT the default width of the column, in characters
    DWORD       csFlags;                        // OUT SHCOLSTATE flags
    WCHAR wszTitle[MAX_COLUMN_NAME_LEN];        // OUT the title of the column
    WCHAR wszDescription[MAX_COLUMN_DESC_LEN];  // OUT full description of this column
} SHCOLUMNINFO, *LPSHCOLUMNINFO;
typedef const SHCOLUMNINFO* LPCSHCOLUMNINFO;

#include <poppack.h>        /* Return to default */

#include <pshpack8.h>

typedef struct {
    ULONG   dwFlags;              // initialization flags
    ULONG   dwReserved;           // reserved for future use.
    WCHAR   wszFolder[MAX_PATH];  // fully qualified folder path (or empty if multiple folders)
} SHCOLUMNINIT, *LPSHCOLUMNINIT;
typedef const SHCOLUMNINIT* LPCSHCOLUMNINIT;

#define SHCDF_UPDATEITEM        0x00000001      // this flag is a hint that the file has changed since the last call to GetItemData

typedef struct {
    ULONG   dwFlags;             // combination of SHCDF_ flags.
    DWORD   dwFileAttributes;    // file attributes.
    ULONG   dwReserved;          // reserved for future use.
    WCHAR*  pwszExt;             // address of file name extension
    WCHAR   wszFile[MAX_PATH];   // Absolute path of file.
} SHCOLUMNDATA, *LPSHCOLUMNDATA;
typedef const SHCOLUMNDATA* LPCSHCOLUMNDATA;

#include <poppack.h>        /* Return to byte packing */

#undef INTERFACE
#define INTERFACE IColumnProvider

// Note: these objects must be threadsafe!  GetItemData _will_ be called
// simultaneously from multiple threads.
DECLARE_INTERFACE_(IColumnProvider, IUnknown)
{
    // IUnknown methods
    STDMETHOD (QueryInterface)(THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG, AddRef)(THIS) PURE;
    STDMETHOD_(ULONG, Release)(THIS) PURE;

    // IColumnProvider methods
    STDMETHOD (Initialize)(THIS_ LPCSHCOLUMNINIT psci) PURE;
    STDMETHOD (GetColumnInfo)(THIS_ DWORD dwIndex, SHCOLUMNINFO *psci) PURE;
    STDMETHOD (GetItemData)(THIS_ LPCSHCOLUMNID pscid, LPCSHCOLUMNDATA pscd, VARIANT *pvarData) PURE;
};


///////////////////////////////////////////////////////
//
// Drag and Drop helper
//
// Purpose: To expose the Shell drag images
//
// This interface is implemented in the shell by CLSID_DragDropHelper.
//
// To use:
//   If you are the source of a drag (i.e. in response to LV_DRAGBEGIN or
//    equivelent begin drag message) call
//    IDragSourceHelper::InitializeFromWindow
//              (<hwnd of window supporting DI_GETDRAGIMAGE>,
//               <pointer to POINT indicating offset to the mouse from
//                  the upper left corner of the image>,
//               <pointer to data object>)
//
//      NOTE: The Data object must support IDataObject::SetData with multiple
//            data types and GetData must implement data type cloning
//            (Including HGLOBAL), not just aliasing.
//
//   If you wish to have an image while over your application add the
//    IDragImages::Dr* calls to your IDropTarget implementation. For Example:
//
//    STDMETHODIMP CUserDropTarget::DragEnter(IDataObject* pDataObject,
//                                            DWORD grfKeyState,
//                                            POINTL pt, DWORD* pdwEffect)
//    {
//          // Process your DragEnter
//          // Call IDragImages::DragEnter last.
//          _pDropTargetHelper->DragEnter(_hwndDragOver, pDataObject,
//                                        (POINT*)&pt, *pdwEffect);
//          return hres;
//    }
//
//
//   If you wish to be able to source a drag image from a custom control,
//     implement a handler for the RegisterWindowMessage(DI_GETDRAGIMAGE).
//     The LPARAM is a pointer to an SHDRAGIMAGE structure.
//
//      sizeDragImage  -   Calculate the length and width required to render
//                          the images.
//      ptOffset       -   Calculate the offset from the upper left corner to
//                          the mouse cursor within the image
//      hbmpDragImage  -   CreateBitmap( sizeDragImage.cx, sizeDragImage.cy,
//                           GetDeviceCaps(hdcScreen, PLANES),
//                           GetDeviceCaps(hdcScreen, BITSPIXEL),
//                           NULL);
//
//   Drag Images will only be displayed on Windows NT 5.0 or later.
//
//
//   Note about IDropTargetHelper::Show - This method is provided for
//     showing/hiding the Drag image in low color depth video modes. When
//     painting to a window that is currently being dragged over (i.e. For
//     indicating a selection) you need to hide the drag image by calling this
//     method passing FALSE. After the window is done painting, Show the image
//     again by passing TRUE.

#include <pshpack8.h>

typedef struct
{
    SIZE        sizeDragImage;      // OUT - The length and Width of the
                                    //        rendered image
    POINT       ptOffset;           // OUT - The Offset from the mouse cursor to
                                    //        the upper left corner of the image
    HBITMAP     hbmpDragImage;      // OUT - The Bitmap containing the rendered
                                    //        drag images
    COLORREF    crColorKey;         // OUT - The COLORREF that has been blitted
                                    //        to the background of the images
} SHDRAGIMAGE, *LPSHDRAGIMAGE;

#include <poppack.h>        /* Return to byte packing */

// This is sent to a window to get the rendered images to a bitmap
// Call RegisterWindowMessage to get the ID
#define DI_GETDRAGIMAGE     TEXT("ShellGetDragImage")

#undef INTERFACE
#define INTERFACE IDropTargetHelper

DECLARE_INTERFACE_( IDropTargetHelper, IUnknown )
{
    // IUnknown methods
    STDMETHOD (QueryInterface)(THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG, AddRef) ( THIS ) PURE;
    STDMETHOD_(ULONG, Release) ( THIS ) PURE;

    // IDropTargetHelper
    STDMETHOD (DragEnter)(THIS_ HWND hwndTarget, IDataObject* pDataObject,
                          POINT* ppt, DWORD dwEffect) PURE;
    STDMETHOD (DragLeave)(THIS) PURE;
    STDMETHOD (DragOver)(THIS_ POINT* ppt, DWORD dwEffect) PURE;
    STDMETHOD (Drop)(THIS_ IDataObject* pDataObject, POINT* ppt,
                     DWORD dwEffect) PURE;
    STDMETHOD (Show)(THIS_ BOOL fShow) PURE;

};

#undef INTERFACE
#define INTERFACE IDragSourceHelper

DECLARE_INTERFACE_( IDragSourceHelper, IUnknown )
{
    // IUnknown methods
    STDMETHOD (QueryInterface)(THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG, AddRef) ( THIS ) PURE;
    STDMETHOD_(ULONG, Release) ( THIS ) PURE;

    // IDragSourceHelper
    STDMETHOD (InitializeFromBitmap)(THIS_ LPSHDRAGIMAGE pshdi,
                                     IDataObject* pDataObject) PURE;
    STDMETHOD (InitializeFromWindow)(THIS_ HWND hwnd, POINT* ppt,
                                     IDataObject* pDataObject) PURE;
};
#endif // _WIN32_IE >= 0x0500
#endif // _WIN32_IE

//==========================================================================
// Clipboard format which may be supported by IDataObject from system
// defined shell folders (such as directories, network, ...).
//==========================================================================

#define CFSTR_SHELLIDLISTP                  TEXT("Shell IDLData Private") ;Internal
#define CFSTR_SHELLIDLIST                   TEXT("Shell IDList Array")      // CF_IDLIST
#define CFSTR_SHELLIDLISTOFFSET             TEXT("Shell Object Offsets")    // CF_OBJECTPOSITIONS
#define CFSTR_NETRESOURCES                  TEXT("Net Resource")            // CF_NETRESOURCE
#define CFSTR_FILEDESCRIPTORA               TEXT("FileGroupDescriptor")     // CF_FILEGROUPDESCRIPTORA
#define CFSTR_FILEDESCRIPTORW               TEXT("FileGroupDescriptorW")    // CF_FILEGROUPDESCRIPTORW
#define CFSTR_FILECONTENTS                  TEXT("FileContents")            // CF_FILECONTENTS
#define CFSTR_FILENAMEA                     TEXT("FileName")                // CF_FILENAMEA
#define CFSTR_FILENAMEW                     TEXT("FileNameW")               // CF_FILENAMEW
#define CFSTR_PRINTERGROUP                  TEXT("PrinterFriendlyName")     // CF_PRINTERS
#define CFSTR_FILENAMEMAPA                  TEXT("FileNameMap")             // CF_FILENAMEMAPA
#define CFSTR_FILENAMEMAPW                  TEXT("FileNameMapW")            // CF_FILENAMEMAPW
#define CFSTR_SHELLURL                      TEXT("UniformResourceLocator")
#define CFSTR_INETURLA                      CFSTR_SHELLURL
#define CFSTR_INETURLW                      TEXT("UniformResourceLocatorW")
#define CFSTR_SHELLCOPYDATA                 TEXT("Shell Copy Data")   ;Internal
#define CFSTR_PREFERREDDROPEFFECT           TEXT("Preferred DropEffect")
#define CFSTR_PERFORMEDDROPEFFECT           TEXT("Performed DropEffect")
#define CFSTR_PASTESUCCEEDED                TEXT("Paste Succeeded")
#define CFSTR_INDRAGLOOP                    TEXT("InShellDragLoop")
#define CFSTR_DRAGCONTEXT                   TEXT("DragContext")
#define CFSTR_MOUNTEDVOLUME                 TEXT("MountedVolume")
#define CFSTR_PERSISTEDDATAOBJECT           TEXT("PersistedDataObject")
#define CFSTR_TARGETCLSID                           TEXT("TargetCLSID")                         // HGLOBAL with a CLSID of the drop target
#define CFSTR_LOGICALPERFORMEDDROPEFFECT    TEXT("Logical Performed DropEffect")
#define CFSTR_DROPEFFECTFOLDERLIST          TEXT("DropEffectFolderList")    ;Internal
#define CFSTR_AUTOPLAY_SHELLIDLISTS         TEXT("Autoplay Enumerated IDList Array")  //  (HGLOBAL with LPIDA)

#ifdef UNICODE
#define CFSTR_FILEDESCRIPTOR    CFSTR_FILEDESCRIPTORW
#define CFSTR_FILENAME          CFSTR_FILENAMEW
#define CFSTR_FILENAMEMAP       CFSTR_FILENAMEMAPW
#define CFSTR_INETURL           CFSTR_INETURLW
#else
#define CFSTR_FILEDESCRIPTOR    CFSTR_FILEDESCRIPTORA
#define CFSTR_FILENAME          CFSTR_FILENAMEA
#define CFSTR_FILENAMEMAP       CFSTR_FILENAMEMAPA
#define CFSTR_INETURL           CFSTR_INETURLA
#endif

#define DVASPECT_SHORTNAME      2 // use for CF_HDROP to get short name version of file paths
#define DVASPECT_COPY           3 // use to indicate format is a "Copy" of the data (FILECONTENTS, FILEDESCRIPTOR, etc)
#define DVASPECT_LINK           4 // use to indicate format is a "Shortcut" to the data (FILECONTENTS, FILEDESCRIPTOR, etc)

#include <pshpack8.h>
//
// format of CF_NETRESOURCE
//
typedef struct _NRESARRAY {     // anr
    UINT cItems;
    NETRESOURCE nr[1];
} NRESARRAY, * LPNRESARRAY;
#include <poppack.h>        /* Return to byte packing */

//
// format of CF_IDLIST
//
typedef struct _IDA {
    UINT cidl;          // number of relative IDList
    UINT aoffset[1];    // [0]: folder IDList, [1]-[cidl]: item IDList
} CIDA, * LPIDA;

//
// FILEDESCRIPTOR.dwFlags field indicate which fields are to be used
//
typedef enum {
    FD_CLSID            = 0x0001,
    FD_SIZEPOINT        = 0x0002,
    FD_ATTRIBUTES       = 0x0004,
    FD_CREATETIME       = 0x0008,
    FD_ACCESSTIME       = 0x0010,
    FD_WRITESTIME       = 0x0020,
    FD_FILESIZE         = 0x0040,
    FD_PROGRESSUI       = 0x4000,       // Show Progress UI w/Drag and Drop
    FD_LINKUI           = 0x8000,       // 'link' UI is prefered
} FD_FLAGS;

typedef struct _FILEDESCRIPTORA { // fod
    DWORD dwFlags;

    CLSID clsid;
    SIZEL sizel;
    POINTL pointl;

    DWORD dwFileAttributes;
    FILETIME ftCreationTime;
    FILETIME ftLastAccessTime;
    FILETIME ftLastWriteTime;
    DWORD nFileSizeHigh;
    DWORD nFileSizeLow;
    CHAR   cFileName[ MAX_PATH ];
} FILEDESCRIPTORA, *LPFILEDESCRIPTORA;

typedef struct _FILEDESCRIPTORW { // fod
    DWORD dwFlags;

    CLSID clsid;
    SIZEL sizel;
    POINTL pointl;

    DWORD dwFileAttributes;
    FILETIME ftCreationTime;
    FILETIME ftLastAccessTime;
    FILETIME ftLastWriteTime;
    DWORD nFileSizeHigh;
    DWORD nFileSizeLow;
    WCHAR  cFileName[ MAX_PATH ];
} FILEDESCRIPTORW, *LPFILEDESCRIPTORW;

#ifdef UNICODE
#define FILEDESCRIPTOR      FILEDESCRIPTORW
#define LPFILEDESCRIPTOR    LPFILEDESCRIPTORW
#else
#define FILEDESCRIPTOR      FILEDESCRIPTORA
#define LPFILEDESCRIPTOR    LPFILEDESCRIPTORA
#endif

//
// format of CF_FILEGROUPDESCRIPTOR
//
typedef struct _FILEGROUPDESCRIPTORA { // fgd
     UINT cItems;
     FILEDESCRIPTORA fgd[1];
} FILEGROUPDESCRIPTORA, * LPFILEGROUPDESCRIPTORA;

typedef struct _FILEGROUPDESCRIPTORW { // fgd
     UINT cItems;
     FILEDESCRIPTORW fgd[1];
} FILEGROUPDESCRIPTORW, * LPFILEGROUPDESCRIPTORW;

#ifdef UNICODE
#define FILEGROUPDESCRIPTOR     FILEGROUPDESCRIPTORW
#define LPFILEGROUPDESCRIPTOR   LPFILEGROUPDESCRIPTORW
#else
#define FILEGROUPDESCRIPTOR     FILEGROUPDESCRIPTORA
#define LPFILEGROUPDESCRIPTOR   LPFILEGROUPDESCRIPTORA
#endif

//
// format of CF_HDROP and CF_PRINTERS, in the HDROP case the data that follows
// is a double null terinated list of file names, for printers they are printer
// friendly names
//
typedef struct _DROPFILES {
   DWORD pFiles;                       // offset of file list
   POINT pt;                           // drop point (client coords)
   BOOL fNC;                           // is it on NonClient area
                                       // and pt is in screen coords
   BOOL fWide;                         // WIDE character switch
} DROPFILES, *LPDROPFILES;

//                                                                      ;Internal
// Win 3.1 style HDROP                                                  ;Internal
//                                                                      ;Internal
//  Notes: Our API works only if pFiles == sizeof(DROPFILES16)          ;Internal
//                                                                      ;Internal
typedef struct _DROPFILES16 {                                           ;Internal
    WORD pFiles;                // offset to double null list of files  ;Internal
    POINTS pt;                  // drop point (client coords)           ;Internal
    WORD fNC;                   // is it on non client area             ;Internal
                                // and pt is in screen coords           ;Internal
} DROPFILES16, * LPDROPFILES16;                                         ;Internal
                                                                        ;Internal
//                                                          ;Internal
// format of CF_SHELLCOPYDATA                               ;Internal
//                                                          ;Internal
                                                            ;Internal
typedef struct _SHELLCOPYDATA {                             ;Internal
    DWORD dwEffect;                 // Intended effect      ;Internal
} SHELLCOPYDATA;                                            ;Internal

;begin_internal
//
// CFSTR_DROPEFFECTFOLDERLIST defines the drop effects to certain folders
// this is applied when dropping to a file system folder.
//

typedef struct {
    DWORD dwDropEffect;
    WCHAR wszPath[MAX_PATH];
} DROPEFFECTFOLDER;

typedef struct {
    DWORD dwDefaultDropEffect;          // default drop effect (==0 for current behaviour)
    INT cFolders;                       // number of folders in the list
    DROPEFFECTFOLDER aFolders[1];
} DROPEFFECTFOLDERLIST;
;end_internal


//====== File System Notification APIs ===============================
//
//------ See shelldll\fsnotify.c for function descriptions. ---------- ;Internal
                                                                        ;Internal
//                                                                      ;Internal
//  Definition of the function type to be called by the notification    ;Internal
//  service when a file the client has registered to monitor changes.   ;Internal
//                                                                      ;Internal

// DOC'ed for DOJ compliance:                                           ;Internal
typedef struct _SHChangeNotifyEntry
{
    LPCITEMIDLIST pidl;
    BOOL   fRecursive;
} SHChangeNotifyEntry;


//
//  File System Notification flags
//

#define SHCNRF_InterruptLevel      0x0001                       ;Internal
#define SHCNRF_ShellLevel          0x0002                       ;Internal

// If the caller passes SHCNRF_RecursiveInterrupt (meaning that they want interrupt events on the whole     ;Internal
// subtree), then they must also pass SHCNRF_InterruptLevel flag (duh), and they must be a recursive (eg    ;Internal
// fRecursive == TRUE) type notification.                                                                   ;Internal
#define SHCNRF_RecursiveInterrupt  0x1000                       ;Internal
#define SHCNRF_ResumeThread        0x2000                       ;Internal
#define SHCNRF_CreateSuspended     0x4000                       ;Internal
#define SHCNRF_NewDelivery         0x8000                       ;Internal

;begin_internal
// !! WARNING !!
// If you change/add any new SHCNE_ events, you will need
// to possibly modify the SHCNE_XXXXEVENTS masks that are
// defined below as well.
;end_internal
#define SHCNE_RENAMEITEM          0x00000001L
#define SHCNE_CREATE              0x00000002L
#define SHCNE_DELETE              0x00000004L
#define SHCNE_MKDIR               0x00000008L
#define SHCNE_RMDIR               0x00000010L
#define SHCNE_MEDIAINSERTED       0x00000020L
#define SHCNE_MEDIAREMOVED        0x00000040L
#define SHCNE_DRIVEREMOVED        0x00000080L
#define SHCNE_DRIVEADD            0x00000100L
#define SHCNE_NETSHARE            0x00000200L
#define SHCNE_NETUNSHARE          0x00000400L
#define SHCNE_ATTRIBUTES          0x00000800L
#define SHCNE_UPDATEDIR           0x00001000L
#define SHCNE_UPDATEITEM          0x00002000L
#define SHCNE_SERVERDISCONNECT    0x00004000L
#define SHCNE_UPDATEIMAGE         0x00008000L
#define SHCNE_DRIVEADDGUI         0x00010000L
#define SHCNE_RENAMEFOLDER        0x00020000L
#define SHCNE_FREESPACE           0x00040000L

#if (_WIN32_IE >= 0x0400)
// SHCNE_EXTENDED_EVENT: the extended event is identified in dwItem1,
// packed in LPITEMIDLIST format (same as SHCNF_DWORD packing).
// Additional information can be passed in the dwItem2 parameter
// of SHChangeNotify (called "pidl2" below), which if present, must also
// be in LPITEMIDLIST format.
//
// Unlike the standard events, the extended events are ORDINALs, so we
// don't run out of bits.  Extended events follow the SHCNEE_* naming
// convention.
//
// The dwItem2 parameter varies according to the extended event.

#define SHCNE_EXTENDED_EVENT      0x04000000L
#endif      // _WIN32_IE >= 0x0400

#define SHCNE_ASSOCCHANGED        0x08000000L

#define SHCNE_DISKEVENTS          0x0002381FL
;begin_internal
// NOTE: SHCNE_GLOBALEVENTS are typically used to pass
// non-pidl information (packed into pidl format). We cannot
// extend SHCNE_GLOBALEVENTS and expect clients of the new
// events to work on a down-level shell32. In fact, they
// may very well fault during psfDesktop->CompareIDs.
// So be careful when adding to this bitfield!
//
// Win95 and NT4 and IE4 shipped with 0x0C0581E0L.
;end_internal
#define SHCNE_GLOBALEVENTS        0x0C0581E0L // Events that dont match pidls first
#define SHCNE_ALLEVENTS           0x7FFFFFFFL
#define SHCNE_INTERRUPT           0x80000000L // The presence of this flag indicates
                                            // that the event was generated by an
                                            // interrupt.  It is stripped out before
                                            // the clients of SHCNNotify_ see it.
;begin_internal
// We use this event mask to tell if we need to possibly throw out a SHCNE_UPDATEDIR that was
// generated by the filesystem because we have a more specific event already in our queue.
// NOTE: only non-interrupt events could cause us to throw out a interrupt generated UPDATEDIR event.
#define SHCNE_UPDATEDIR_OVERRIDE_EVENTS 0x00023818L
;end_internal

#if (_WIN32_IE >= 0x0400)
// SHCNE_EXTENDED_EVENT extended events.  These events are ordinals.
// This is not a bitfield.

;begin_internal
// This event was defined early on in IE4 for the Theme Switcher to
// notify the shell that a system-wide update needed to happen.
// This has been removed but I don't want to re-use the id just yet...

// BUGBUG (scotth) 6/11/98: can we remove this yet??

//#define SHCNEE_THEMECHANGED       1L  // The theme changed
;end_internal
#define SHCNEE_ORDERCHANGED         2L  // pidl2 is the changed folder
;begin_internal
#define SHCNEE_WININETCHANGED       3L  // dwItem2 contains CACHE_NOTIFY_* bits
;end_internal
#define SHCNEE_MSI_CHANGE           4L  // pidl2 is a SHChangeProductKeyAsIDList
#define SHCNEE_MSI_UNINSTALL        5L  // pidl2 is a SHChangeProductKeyAsIDList
;begin_internal
#if (_WIN32_IE >= 0x0500)
#define SHCNEE_PROMOTEDITEM         6L  // pidl2 is the pidl of the Promoted item
#define SHCNEE_DEMOTEDITEM          7L  // pidl2 is the pidl of the demoted item
#define SHCNEE_ALIASINUSE           8L  // some alias style folder is now being used
#endif
#if (_WIN32_IE >= 0x0600)
#define SHCNEE_SHORTCUTINVOKE       9L  // an app has been launched via a shortcut
                                        // pidl1 = SHShortcutInvokeAsIDList, pidl2=unused
#define SHCNEE_PINLISTCHANGED      10L  // a change was made to the pin list
                                        // pidl1 = SHChangeDWORDAsIDList, pidl2=unused
#define SHCNEE_USERINFOCHANGED     11L  // A user picture was updated. pidl1 = SHChangeDWORDAsIDList, pidl2=unused
#define SHCNEE_UPDATEFOLDERLOCATION  12L  // a special folder changed pidl1 = {SHChangeDWORDAsIDList, csidlFolder}, pidl2=unused
#endif
;end_internal
#endif

// Update types for the UpdateEntryList api                              ;Internal
#define SHCNNU_SET        1   // Set the notify list to passed in list   ;Internal
#define SHCNNU_ADD        2   // Add the items to the current list       ;Internal
#define SHCNNU_REMOVE     3   // Remove the items from the current list  ;Internal

// Flags
// uFlags & SHCNF_TYPE is an ID which indicates what dwItem1 and dwItem2 mean
#define SHCNF_IDLIST      0x0000        // LPITEMIDLIST
#define SHCNF_PATHA       0x0001        // path name
#define SHCNF_PRINTERA    0x0002        // printer friendly name
#define SHCNF_DWORD       0x0003        // DWORD
#define SHCNF_PRINTJOBA   0x0004        // dwItem1: printer name        ;Internal
                                        // dwItem2: SHCNF_PRINTJOB_DATA ;Internal
#define SHCNF_PATHW       0x0005        // path name
#define SHCNF_PRINTERW    0x0006        // printer friendly name
#define SHCNF_PRINTJOBW   0x0007        // dwItem1: printer name        ;Internal
                                        // dwItem2: SHCNF_PRINTJOB_DATA ;Internal
#define SHCNF_INSTRUMENT  0x0080        // dwItem1: LPSHCNF_INSTRUMENT  ;Internal
#define SHCNF_TYPE        0x00FF
#define SHCNF_FLUSH       0x1000
#define SHCNF_FLUSHNOWAIT 0x2000
#define SHCNF_TRANSLATEDALIAS       0x4000 // for internals to filter on ;Internal
#define SHCNF_ONLYNOTIFYINTERNALS   0x8000 // only notify internal clients ;Internal

#ifdef UNICODE
#define SHCNF_PATH      SHCNF_PATHW
#define SHCNF_PRINTER   SHCNF_PRINTERW
#else
#define SHCNF_PATH      SHCNF_PATHA
#define SHCNF_PRINTER   SHCNF_PRINTERA
#endif

#ifdef UNICODE                                                          ;Internal
#define SHCNF_PRINTJOB  SHCNF_PRINTJOBW                                 ;Internal
#else                                                                   ;Internal
#define SHCNF_PRINTJOB  SHCNF_PRINTJOBA                                 ;Internal
#endif                                                                  ;Internal
                                                                        ;Internal
typedef struct tagSHCNF_PRINTJOB_DATA {                                 ;Internal
    DWORD JobId;                                                        ;Internal
    DWORD Status;                                                       ;Internal
    DWORD TotalPages;                                                   ;Internal
    DWORD Size;                                                         ;Internal
    DWORD PagesPrinted;                                                 ;Internal
} SHCNF_PRINTJOB_DATA, *LPSHCNF_PRINTJOB_DATA;                          ;Internal

//                                                                      ;Internal
// This is all the INSTRUMENTation stuff...                             ;Internal
// make this look like an ITEMIDLIST (uOffset points to 0 uTerm)        ;Internal
#include <pshpack1.h>                                                   ;Internal
typedef struct tagSHCNF_INSTRUMENT {                                    ;Internal
    USHORT uOffset;                                                     ;Internal
    USHORT uAlign;                                                      ;Internal
    DWORD dwEventType;                                                  ;Internal
    DWORD dwEventStructure;                                             ;Internal
    SYSTEMTIME st;                                                      ;Internal
    union tagEvents {                                                   ;Internal
        struct tagSTRING {                                              ;Internal
            TCHAR sz[32];                                               ;Internal
        } string;                                                       ;Internal
        struct tagHOTKEY {                                              ;Internal
            WPARAM wParam;                                              ;Internal
        } hotkey;                                                       ;Internal
        struct tagWNDPROC {                                             ;Internal
            HWND hwnd;                                                  ;Internal
            UINT uMsg;                                                  ;Internal
            WPARAM wParam;                                              ;Internal
            LPARAM lParam;                                              ;Internal
        } wndproc;                                                      ;Internal
        struct tagCOMMAND {                                             ;Internal
            HWND hwnd;                                                  ;Internal
            UINT idCmd;                                                 ;Internal
        } command;                                                      ;Internal
        struct tagDROP {                                                ;Internal
            HWND hwnd;                                                  ;Internal
            UINT idCmd;                                                 ;Internal
//          TCHAR sz[32]; // convert pDataObject into something we can log ;Internal
        } drop;                                                         ;Internal
    } e;                                                                ;Internal
    USHORT uTerm;                                                       ;Internal
} SHCNF_INSTRUMENT_INFO, * LPSHCNF_INSTRUMENT_INFO;                     ;Internal
#include <poppack.h>                                                    ;Internal
                                    ;Internal
#define SHCNFI_EVENT_STATECHANGE          0   // dwEventType            ;Internal
#define SHCNFI_EVENT_STRING               1   // e.string               ;Internal
#define SHCNFI_EVENT_HOTKEY               2   // e.hotkey               ;Internal
#define SHCNFI_EVENT_WNDPROC              3   // e.wndproc              ;Internal
#define SHCNFI_EVENT_WNDPROC_HOOK         4   // e.wndproc              ;Internal
#define SHCNFI_EVENT_ONCOMMAND            5   // e.command              ;Internal
#define SHCNFI_EVENT_INVOKECOMMAND        6   // e.command              ;Internal
#define SHCNFI_EVENT_TRACKPOPUPMENU       7   // e.command              ;Internal
#define SHCNFI_EVENT_DROP                 8   // e.drop                 ;Internal
#define SHCNFI_EVENT_MAX                  9                             ;Internal
                                    ;Internal
#define SHCNFI_STRING_SHOWEXTVIEW         0                             ;Internal
                                    ;Internal
#define SHCNFI_STATE_KEYBOARDACTIVE         0   // _KEYBOARDACTIVE or _MOUSEACTIVE ;Internal
#define SHCNFI_STATE_MOUSEACTIVE            1   // _KEYBOARDACTIVE or _MOUSEACTIVE ;Internal
#define SHCNFI_STATE_ACCEL_TRAY             2   // _ACCEL_TRAY or _ACCEL_DESKTOP   ;Internal
#define SHCNFI_STATE_ACCEL_DESKTOP          3   // _ACCEL_TRAY or _ACCEL_DESKTOP   ;Internal
#define SHCNFI_STATE_START_DOWN             4   // _START_DOWN or _START_UP        ;Internal
#define SHCNFI_STATE_START_UP               5   // _START_DOWN or _START_UP        ;Internal
#define SHCNFI_STATE_TRAY_CONTEXT           6                           ;Internal
#define SHCNFI_STATE_TRAY_CONTEXT_CLOCK     7                           ;Internal
#define SHCNFI_STATE_TRAY_CONTEXT_START     8                           ;Internal
#define SHCNFI_STATE_DEFVIEWX_ALT_DBLCLK    9                           ;Internal
#define SHCNFI_STATE_DEFVIEWX_SHIFT_DBLCLK 10                           ;Internal
#define SHCNFI_STATE_DEFVIEWX_DBLCLK       11                           ;Internal
                                    ;Internal
#define SHCNFI_GLOBALHOTKEY               0                             ;Internal
                                    ;Internal
#define SHCNFI_CABINET_WNDPROC            0                             ;Internal
#define SHCNFI_DESKTOP_WNDPROC            1                             ;Internal
#define SHCNFI_PROXYDESKTOP_WNDPROC       2                             ;Internal
#define SHCNFI_TRAY_WNDPROC               3                             ;Internal
#define SHCNFI_DRIVES_WNDPROC             4                             ;Internal
#define SHCNFI_ONETREE_WNDPROC            5                             ;Internal
#define SHCNFI_MAIN_WNDPROC               6                             ;Internal
#define SHCNFI_FOLDEROPTIONS_DLGPROC      7                             ;Internal
#define SHCNFI_VIEWOPTIONS_DLGPROC        8                             ;Internal
#define SHCNFI_FT_DLGPROC                 9                             ;Internal
#define SHCNFI_FTEdit_DLGPROC            10                             ;Internal
#define SHCNFI_FTCmd_DLGPROC             11                             ;Internal
#define SHCNFI_TASKMAN_DLGPROC           12                             ;Internal
#define SHCNFI_TRAYVIEWOPTIONS_DLGPROC   13                             ;Internal
#define SHCNFI_INITSTARTMENU_DLGPROC     14                             ;Internal
#define SHCNFI_PRINTERQUEUE_DLGPROC      15                             ;Internal
                                    ;Internal
#define SHCNFI_CABINET_ONCOMMAND          0                             ;Internal
#define SHCNFI_TRAYCOMMAND                1                             ;Internal
                                    ;Internal
#define SHCNFI_BITBUCKET_DFM_INVOKE       0                             ;Internal
#define SHCNFI_BITBUCKET_FNV_INVOKE       1                             ;Internal
#define SHCNFI_BITBUCKET_INVOKE           2                             ;Internal
#define SHCNFI_BITBUCKETBG_DFM_INVOKE     3                             ;Internal
#define SHCNFI_CONTROLS_DFM_INVOKE        4                             ;Internal
#define SHCNFI_CONTROLS_FNV_INVOKE        5                             ;Internal
#define SHCNFI_CONTROLSBG_DFM_INVOKE      6                             ;Internal
#define SHCNFI_DEFFOLDER_DFM_INVOKE       7                             ;Internal
#define SHCNFI_DEFFOLDER_INVOKE           8                             ;Internal
#define SHCNFI_FINDEXT_INVOKE             9                             ;Internal
#define SHCNFI_DEFFOLDER_FNV_INVOKE      10                             ;Internal
#define SHCNFI_DRIVESBG_DFM_INVOKE       11                             ;Internal
#define SHCNFI_DRIVES_FNV_INVOKE         12                             ;Internal
#define SHCNFI_DRIVES_DFM_INVOKE         13                             ;Internal
#define SHCNFI_FOLDERBG_DFM_INVOKE       14                             ;Internal
#define SHCNFI_FOLDER_FNV_INVOKE         15                             ;Internal
#define SHCNFI_FOLDER_DFM_INVOKE         16                             ;Internal
#define SHCNFI_NETWORKBG_DFM_INVOKE      17                             ;Internal
#define SHCNFI_NETWORK_FNV_INVOKE        18                             ;Internal
#define SHCNFI_NETWORK_DFM_INVOKE        19                             ;Internal
#define SHCNFI_NETWORKPRINTER_DFM_INVOKE 20                             ;Internal
#define SHCNFI_DESKTOPBG_DFM_INVOKE      21                             ;Internal
#define SHCNFI_DESKTOP_DFM_INVOKE        22                             ;Internal
#define SHCNFI_DESKTOP_FNV_INVOKE        23                             ;Internal
#define SHCNFI_PRINTERS_DFM_INVOKE       24                             ;Internal
#define SHCNFI_PRINTERSBG_DFM_INVOKE     25                             ;Internal
#define SHCNFI_PRINTERS_FNV_INVOKE       26                             ;Internal
#define SHCNFI_DEFVIEWX_INVOKE           27                             ;Internal
                                    ;Internal
#define SHCNFI_FOLDER_DROP                0                             ;Internal
#define SHCNFI_PRINTQUEUE_DROP            1                             ;Internal
#define SHCNFI_DEFVIEWX_TPM               2                             ;Internal
#define SHCNFI_DROP_EXE_TPM               3                             ;Internal
#define SHCNFI_IDLDT_TPM                  4                             ;Internal
                                    ;Internal
#define SHCNFI_DROP_BITBUCKET             0                             ;Internal
#define SHCNFI_DROP_PRINTFOLDER           1                             ;Internal
#define SHCNFI_DROP_PRINTER               2                             ;Internal
#define SHCNFI_DROP_RUN                   3                             ;Internal
#define SHCNFI_DROP_SHELLLINK             4                             ;Internal
#define SHCNFI_DROP_DRIVES                5                             ;Internal
#define SHCNFI_DROP_FS                    6                             ;Internal
#define SHCNFI_DROP_EXE                   7                             ;Internal
#define SHCNFI_DROP_NETROOT               8                             ;Internal
#define SHCNFI_DROP_PRINTQUEUE            9                             ;Internal
#define SHCNFI_DROP_BRIEFCASE            10                             ;Internal
                                    ;Internal
#ifdef WANT_SHELL_INSTRUMENTATION                                       ;Internal
#define INSTRUMENT_STATECHANGE(t)                               \       ;Internal
{                                                               \       ;Internal
    SHCNF_INSTRUMENT_INFO s;                                    \       ;Internal
    s.dwEventType=(t);                                          \       ;Internal
    s.dwEventStructure=SHCNFI_EVENT_STATECHANGE;                \       ;Internal
    SHChangeNotify(SHCNE_INSTRUMENT,SHCNF_INSTRUMENT,&s,NULL);  \       ;Internal
}                                                                       ;Internal
#define INSTRUMENT_STRING(t,p)                                  \       ;Internal
{                                                               \       ;Internal
    SHCNF_INSTRUMENT_INFO s;                                    \       ;Internal
    s.dwEventType=(t);                                          \       ;Internal
    s.dwEventStructure=SHCNFI_EVENT_STRING;                     \       ;Internal
    lstrcpyn(s.e.string.sz,(p),ARRAYSIZE(s.e.string.sz));       \       ;Internal
    SHChangeNotify(SHCNE_INSTRUMENT,SHCNF_INSTRUMENT,&s,NULL);  \       ;Internal
}                                                                       ;Internal
#define INSTRUMENT_HOTKEY(t,w)                                  \       ;Internal
{                                                               \       ;Internal
    SHCNF_INSTRUMENT_INFO s;                                    \       ;Internal
    s.dwEventType=(t);                                          \       ;Internal
    s.dwEventStructure=SHCNFI_EVENT_HOTKEY;                     \       ;Internal
    s.e.hotkey.wParam=(w);                                      \       ;Internal
    SHChangeNotify(SHCNE_INSTRUMENT,SHCNF_INSTRUMENT,&s,NULL);  \       ;Internal
}                                                                       ;Internal
#define INSTRUMENT_WNDPROC(t,h,u,w,l)                           \       ;Internal
{                                                               \       ;Internal
    SHCNF_INSTRUMENT_INFO s;                                    \       ;Internal
    s.dwEventType=(t);                                          \       ;Internal
    s.dwEventStructure=SHCNFI_EVENT_WNDPROC;                    \       ;Internal
    s.e.wndproc.hwnd=(h);                                       \       ;Internal
    s.e.wndproc.uMsg=(u);                                       \       ;Internal
    s.e.wndproc.wParam=(w);                                     \       ;Internal
    s.e.wndproc.lParam=(l);                                     \       ;Internal
    SHChangeNotify(SHCNE_INSTRUMENT,SHCNF_INSTRUMENT,&s,NULL);  \       ;Internal
}                                                                       ;Internal
#define INSTRUMENT_WNDPROC_HOOK(h,u,w,l)                        \       ;Internal
{                                                               \       ;Internal
    SHCNF_INSTRUMENT_INFO s;                                    \       ;Internal
    s.dwEventType=0;                                            \       ;Internal
    s.dwEventStructure=SHCNFI_EVENT_WNDPROC_HOOK;               \       ;Internal
    s.e.wndproc.hwnd=(h);                                       \       ;Internal
    s.e.wndproc.uMsg=(u);                                       \       ;Internal
    s.e.wndproc.wParam=(w);                                     \       ;Internal
    s.e.wndproc.lParam=(l);                                     \       ;Internal
    SHChangeNotify(SHCNE_INSTRUMENT,SHCNF_INSTRUMENT,&s,NULL);  \       ;Internal
}                                                                       ;Internal
#define INSTRUMENT_ONCOMMAND(t,h,u)                             \       ;Internal
{                                                               \       ;Internal
    SHCNF_INSTRUMENT_INFO s;                                    \       ;Internal
    s.dwEventType=(t);                                          \       ;Internal
    s.dwEventStructure=SHCNFI_EVENT_ONCOMMAND;                  \       ;Internal
    s.e.command.hwnd=(h);                                       \       ;Internal
    s.e.command.idCmd=(u);                                      \       ;Internal
    SHChangeNotify(SHCNE_INSTRUMENT,SHCNF_INSTRUMENT,&s,NULL);  \       ;Internal
}                                                                       ;Internal
#define INSTRUMENT_INVOKECOMMAND(t,h,u)                         \       ;Internal
{                                                               \       ;Internal
    SHCNF_INSTRUMENT_INFO s;                                    \       ;Internal
    s.dwEventType=(t);                                          \       ;Internal
    s.dwEventStructure=SHCNFI_EVENT_INVOKECOMMAND;              \       ;Internal
    s.e.command.hwnd=(h);                                       \       ;Internal
    s.e.command.idCmd=(u);                                      \       ;Internal
    SHChangeNotify(SHCNE_INSTRUMENT,SHCNF_INSTRUMENT,&s,NULL);  \       ;Internal
}                                                                       ;Internal
#define INSTRUMENT_TRACKPOPUPMENU(t,h,u)                        \       ;Internal
{                                                               \       ;Internal
    SHCNF_INSTRUMENT_INFO s;                                    \       ;Internal
    s.dwEventType=(t);                                          \       ;Internal
    s.dwEventStructure=SHCNFI_EVENT_TRACKPOPUPMENU;             \       ;Internal
    s.e.command.hwnd=(h);                                       \       ;Internal
    s.e.command.idCmd=(u);                                      \       ;Internal
    SHChangeNotify(SHCNE_INSTRUMENT,SHCNF_INSTRUMENT,&s,NULL);  \       ;Internal
}                                                                       ;Internal
#define INSTRUMENT_DROP(t,h,u,p)                                \       ;Internal
{                                                               \       ;Internal
    SHCNF_INSTRUMENT_INFO s;                                    \       ;Internal
    s.dwEventType=(t);                                          \       ;Internal
    s.dwEventStructure=SHCNFI_EVENT_DROP;                       \       ;Internal
    s.e.drop.hwnd=(h);                                          \       ;Internal
    s.e.drop.idCmd=(u);                                         \       ;Internal
    SHChangeNotify(SHCNE_INSTRUMENT,SHCNF_INSTRUMENT,&s,NULL);  \       ;Internal
}                                                                       ;Internal
#else                                                                   ;Internal
#define INSTRUMENT_STATECHANGE(t)                                       ;Internal
#define INSTRUMENT_STRING(t,p)                                          ;Internal
#define INSTRUMENT_HOTKEY(t,w)                                          ;Internal
#define INSTRUMENT_WNDPROC(t,h,u,w,l)                                   ;Internal
#define INSTRUMENT_WNDPROC_HOOK(h,u,w,l)                                ;Internal
#define INSTRUMENT_ONCOMMAND(t,h,u)                                     ;Internal
#define INSTRUMENT_INVOKECOMMAND(t,h,u)                                 ;Internal
#define INSTRUMENT_TRACKPOPUPMENU(t,h,u)                                ;Internal
#define INSTRUMENT_DROP(t,h,u,p)                                        ;Internal
#endif //WANT_SHELL_INSTRUMENTATION                                     ;Internal
//                                                                      ;Internal

//
//  APIs
//
SHSTDAPI_(void) SHChangeNotify(LONG wEventId, UINT uFlags, LPCVOID dwItem1, LPCVOID dwItem2);

//
// IShellChangeNotify
//
#undef  INTERFACE
#define INTERFACE  IShellChangeNotify

DECLARE_INTERFACE_(IShellChangeNotify, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IShellChangeNotify methods ***
    STDMETHOD(OnChange) (THIS_ LONG lEvent, LPCITEMIDLIST pidl1, LPCITEMIDLIST pidl2) PURE;
} ;

//
// IQueryInfo
//
//-------------------------------------------------------------------------
//
// IQueryInfo interface
//
// [Methods]
//              ::GetInfoTip()
//-------------------------------------------------------------------------

#undef  INTERFACE
#define INTERFACE  IQueryInfo

DECLARE_INTERFACE_(IQueryInfo, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IQueryInfo methods ***
    STDMETHOD(GetInfoTip)(THIS_ DWORD dwFlags, WCHAR **ppwszTip) PURE;
    STDMETHOD(GetInfoFlags)(THIS_ DWORD *pdwFlags) PURE;
} ;

#define QITIPF_DEFAULT          0x00000000
#define QITIPF_USENAME          0x00000001
#define QITIPF_LINKNOTARGET     0x00000002
#define QITIPF_LINKUSETARGET    0x00000004
#define QITIPF_USESLOWTIP       0x00000008  // Flag says it's OK to take a long time generating tip

#define QIF_CACHED           0x00000001
#define QIF_DONTEXPANDFOLDER 0x00000002

;begin_internal
//
// IQueryCodePage
//
#undef  INTERFACE
#define INTERFACE  IQueryCodePage

DECLARE_INTERFACE_(IQueryCodePage, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IQueryCodePage methods ***
    STDMETHOD(GetCodePage)(THIS_ UINT * puiCodePage) PURE;
    STDMETHOD(SetCodePage)(THIS_ UINT uiCodePage) PURE;
} ;
;end_internal

//
// SHAddToRecentDocs
//
#define SHARD_PIDL      0x00000001L
#define SHARD_PATHA     0x00000002L
#define SHARD_PATHW     0x00000003L

#ifdef UNICODE
#define SHARD_PATH  SHARD_PATHW
#else
#define SHARD_PATH  SHARD_PATHA
#endif

SHSTDAPI_(void) SHAddToRecentDocs(UINT uFlags, LPCVOID pv);

;begin_internal
SHSTDAPI_(void) SHWaitOp_Operate(HANDLE hWaitOp, DWORD dwProcId);

// DOC'ed for DOJ compliance:
;end_internal
typedef struct _SHChangeDWORDAsIDList {
    USHORT   cb;
    DWORD    dwItem1;
    DWORD    dwItem2;
    USHORT   cbZero;
} SHChangeDWORDAsIDList, *LPSHChangeDWORDAsIDList;


#if (_WIN32_IE >= 0x0400)                                               ;both

;begin_internal
// Use this instead of SHChangeDWORDAsIDList for SHCNEE_ORDERCHANGED
// SHCNEE_PROMOTEDITEM and SHCNEE_DEMOTEDITEM
//
// When filling in the pSender, cast LPVOID directly to INT64.
// Do not cast through DWORD_PTR because that will not sign extend
// properly on Win32.

typedef struct _SHChangeMenuAsIDList {
    USHORT  cb;
    DWORD   dwItem1;        // SHCNEE_EXTENDED_EVENT requires this
    // pSender must appear immediately after dwItem1 for IE5.0 compat
    INT64 pSender;          // address of sender (64-bit for Win64)
    DWORD   dwProcessID;    // pid of sender
    USHORT  cbZero;
} SHChangeMenuAsIDList, * LPSHChangeMenuAsIDList;

// DOC'ed for DOJ Compliance
;end_internal

typedef struct _SHChangeUpdateImageIDList {
    USHORT cb;
    int iIconIndex;
    int iCurIndex;
    UINT uFlags;
    DWORD dwProcessID;
    WCHAR szName[MAX_PATH];
    USHORT cbZero;
} SHChangeUpdateImageIDList, * LPSHChangeUpdateImageIDList;

SHSTDAPI_(int)  SHHandleUpdateImage( LPCITEMIDLIST pidlExtra );
;begin_internal


;end_internal

typedef struct _SHChangeProductKeyAsIDList {
    USHORT cb;
    WCHAR wszProductKey[39];
    USHORT cbZero;
} SHChangeProductKeyAsIDList, *LPSHChangeProductKeyAsIDList;

;begin_internal
typedef struct _SHShortcutInvokeAsIDList {
    USHORT  cb;
    DWORD   dwItem1;                    // SHCNEE_EXTENDED_EVENT requires this
    DWORD   dwPid;                      // PID of target application
    WCHAR   szShortcutName[MAX_PATH];   // Path to shortcut
    WCHAR   szTargetName[MAX_PATH];     // Path to target application
    USHORT  cbZero;
} SHShortcutInvokeAsIDList, *LPSHShortcutInvokeAsIDList;
;end_internal

SHSTDAPI_(void) SHUpdateImage%(LPCTSTR% pszHashItem, int iIndex, UINT uFlags, int iImageIndex);
#endif /* _WIN32_IE */                                                  ;both

;begin_internal
#define SHChangeNotifyHandleEvents() SHChangeNotify(0, SHCNF_FLUSH, NULL, NULL)
// DOC'ed for DOJ compliance
;end_internal
SHSTDAPI_(ULONG) SHChangeNotifyRegister(HWND hwnd, int fSources, LONG fEvents, UINT wMsg, int cEntries, SHChangeNotifyEntry *pshcne);
;begin_internal
#define SHChangeNotifyRegisterORD 2
// DOC'ed for DOJ compliance
;end_internal
SHSTDAPI_(BOOL) SHChangeNotifyDeregister(unsigned long ulID);
;begin_internal
#define SHChangeNotifyDeregisterORD 4

SHSTDAPI_(BOOL) SHChangeNotifyUpdateEntryList(unsigned long ulID, int iUpdateType, int cEntries, SHChangeNotifyEntry *pshcne);

SHSTDAPI_(void)   SHChangeNotifyReceive(LONG lEvent, UINT uFlags, LPCITEMIDLIST pidl, LPCITEMIDLIST pidlExtra);
SHSTDAPI_(BOOL) SHChangeRegistrationReceive(HANDLE hChangeNotification, DWORD dwProcId);
SHSTDAPI_(void) SHChangeNotifyDeregisterWindow(HWND hwnd);
SHSTDAPI_(LRESULT) SHChangeNotifySuspendResumeReceive(WPARAM wParam, LPARAM lParam);
SHSTDAPI_(BOOL) SHChangeNotifySuspendResume(BOOL bSuspend, LPITEMIDLIST pidlSuspend, BOOL bRescursive, DWORD dwReserved);

typedef HANDLE LPSHChangeNotificationLock;

// DOC'ed for DOJ compliance
;end_internal
SHSTDAPI_(HANDLE) SHChangeNotification_Lock(HANDLE hChangeNotification, DWORD dwProcessId, LPITEMIDLIST **pppidl, LONG *plEvent);
SHSTDAPI_(BOOL) SHChangeNotification_Unlock(HANDLE hLock);
;begin_internal

//  END Internal SHChangeNotify HELPERS

// DOC'ed for DOJ compliance
;end_internal
#if (_WIN32_IE >= 0x0400)
// The pidls that are given to the view via the ChangeNotifyEvents are simple Pidls,
// SHGetRealIDL() will convert them to true PIDLs.
SHSTDAPI SHGetRealIDL(IShellFolder *psf, LPCITEMIDLIST pidlSimple, LPITEMIDLIST * ppidlReal);
#endif // _WIN32_IE >= 0x0400


SHSTDAPI SHGetInstanceExplorer(IUnknown **ppunk);

//
// SHGetDataFromIDListA/W
//
// SHGetDataFromIDList nFormat values TCHAR
#define SHGDFIL_FINDDATA        1
#define SHGDFIL_NETRESOURCE     2
#define SHGDFIL_DESCRIPTIONID   3

#define SHDID_ROOT_REGITEM          1
#define SHDID_FS_FILE               2
#define SHDID_FS_DIRECTORY          3
#define SHDID_FS_OTHER              4
#define SHDID_COMPUTER_DRIVE35      5
#define SHDID_COMPUTER_DRIVE525     6
#define SHDID_COMPUTER_REMOVABLE    7
#define SHDID_COMPUTER_FIXED        8
#define SHDID_COMPUTER_NETDRIVE     9
#define SHDID_COMPUTER_CDROM        10
#define SHDID_COMPUTER_RAMDISK      11
#define SHDID_COMPUTER_OTHER        12
#define SHDID_NET_DOMAIN            13
#define SHDID_NET_SERVER            14
#define SHDID_NET_SHARE             15
#define SHDID_NET_RESTOFNET         16
#define SHDID_NET_OTHER             17
#define SHDID_COMPUTER_IMAGING      18
#define SHDID_COMPUTER_AUDIO        19
#define SHDID_COMPUTER_SHAREDDOCS   20

#include <pshpack8.h>

typedef struct _SHDESCRIPTIONID {
    DWORD   dwDescriptionId;
    CLSID   clsid;
} SHDESCRIPTIONID, *LPSHDESCRIPTIONID;

#include <poppack.h>        /* Return to byte packing */

// these delegate to IShellFolder2::GetItemData()

SHSTDAPI SHGetDataFromIDList%(IShellFolder *psf, LPCITEMIDLIST pidl, int nFormat, void *pv, int cb);

;begin_internal
#ifndef NOOCHOST // {

//
// ====== OCHOST CONTROL ==========================================
//
// The following are all definations of structures, windows messages needed for OCHOST,
// the window control you can use to host an OC.
// To use OCHOST, you must specify the window class as OCHOST_CLASS or "OCHOST"
// -- To Create and initialize OCHOST:
// 1. CreateWindow with window title = the string version of class id or the OC
// 2. CreateWindow with a pointer to the OCHINITSTRUCT structure as the last parameter
//    you must allocate and initialize the OCHINITSTRUCT structure
// 3. CreateWindow with no title and the last param == NULL, then use the OCM_INITIALIZE message
//    or the OCHost_InitOC macro to initialize it.
// 4. Use OCM_QUERYINTERFACE to QI an interface pointer from the OC.
// 5. Simply destroy the window when you exit.

// SHDRC -- Shell Doc Register Classes

typedef struct _SHDRC {
    DWORD cbSize;   // size of this structure in bytes
    DWORD dwFlags;  // SHDRCF_ flags
} SHDRC;

#define SHDRCF_OCHOST   0x0001 // Register the OCHOST_CLASS window
#define SHDRCF_ALL      0x0001 // ;Internal

SHDOCAPI_(BOOL)     DllRegisterWindowClasses(const SHDRC * pshdrc);
BROWSEUIAPI_(BOOL)  InitOCHostClass(const SHDRC *pshdrc);

#define OCHOST_CLASSA   "OCHost"
#define OCHOST_CLASSW   L"OCHost"

#ifdef UNICODE
#define OCHOST_CLASS    OCHOST_CLASSW
#else
#define OCHOST_CLASS    OCHOST_CLASSA
#endif

// ------------------- Window messages for OC Host --------------------

// IUnknown::QueryInterface the hosted OC
typedef struct _QIMSG {
    const IID * qiid;
    void **ppvObject;
} QIMSG, *LPQIMSG;

// ................. Query Interface Message ..........
#define OCM_QUERYINTERFACE      (WM_USER+0)

#ifdef __cplusplus
inline HRESULT OCHost_QueryInterface(HWND hwndOCH, REFIID riid, void **ppv) \
{ QIMSG qimsg = {&riid, ppv}; \
  return (HRESULT)SNDMSG((hwndOCH), OCM_QUERYINTERFACE, (WPARAM)sizeof(qimsg), (LPARAM)&qimsg); \
}
#else
#define OCHost_QueryInterface(hwndOCH, riid, ppv) \
{ QIMSG qimsg = {&riid, ppv}; \
  SNDMSG((hwndOCH), OCM_QUERYINTERFACE, (WPARAM)sizeof(qimsg), (LPARAM)&qimsg); \
}
#endif


// ------------------- OC Initialization Structure ---------------------
// This is intended to be passed in as the lParam of the OCM_INITOC message
typedef struct _OCHINITSTRUCT {
    UINT cbSize;                    // size of this structure
    CLSID clsidOC;                  // class ID of the OC
    IUnknown * punkOwner;           // owner of OCHOST
} OCHINITSTRUCT, *LPOCHINITSTRUCT;
//--------------------------------------------------------------------

// ................ Initialize and activate the OC ...............
#define OCM_INITIALIZE      (WM_USER+1)
#define OCM_INITOC          OCM_INITIALIZE
#define OCHost_InitOC(hwndOCH, lpOCS) \
  (HRESULT)SNDMSG((hwndOCH), OCM_INITOC, 0, (LPARAM)lpOCS)


// ............... give ochost a parent IUnknown .......
#define OCM_SETOWNER            (WM_USER+2)
#define OCHost_SetOwner(hwndOC, punk) \
  (HRESULT)SNDMSG((hwndOC), OCM_SETOWNER, 0, (LPARAM)(IUnknown*)(punk))

// ............... DoVerb the OC .......
// n.b. iVerb is technically a long, WPARAM might truncate it
#define OCM_DOVERB              (WM_USER+3)
#define OCHost_DoVerb(hwndOC, iVerb, lpMsg) \
  (HRESULT)SNDMSG((hwndOC), OCM_DOVERB, (WPARAM)iVerb, (LPARAM)lpMsg)

//.................Enable/Disable OC event notifications
#define OCM_ENABLEEVENTS       (WM_USER+4)
//  WPARAM: TRUE to enable event notifications, FALSE to disable.
//  returns: TRUE if successful, otherwise FALSE.
//  Event notification is in the form of a WM_NOTIFY with
//  code OCN_OCEVENT and an NMOCEVENT block.

#define OCHost_EnableEvents(hwndOC, bEnable) \
    (BOOL)SNDMSG((hwndOC), OCM_ENABLEEVENTS, (WPARAM)bEnable, 0L)


#define OCM_SETSERVICEPROVIDER (WM_USER+5)
//  LPARAM: IServiceProvider* pSP.
//  This message sets a service provider for SID_OleClientSite delegation.
//  Currently, OCHost will just call this guy with (SID_OleClientSite, IDispatch)
//  and the client-implemented service provider can return an IDispatch to
//  handle ambient properties.
#define OCHost_SetServiceProvider(hwndOC, pSP) \
    (BOOL)SNDMSG((hwndOC), OCM_SETSERVICEPROVIDER, 0L, (LPARAM) pSP)

// ------------------ Window Notify messages from OC Host --------------

#define OCN_FIRST               0x1300
#define OCN_COCREATEINSTANCE    (OCN_FIRST + 1)

typedef struct _OCNCOCREATEMSG {
    NMHDR nmhdr;
    CLSID clsidOC;
    IUnknown ** ppunk;
} OCNCOCREATEMSG, *LPOCNCOCREATEMSG;

// NOTE: return values are defined as the following
// If the handler of OCN_COCREATEINSTANCE Notify message returns OCNCOCREATE_ALREADYCREATED,
// on return the (*ppvObj) is assumed to have the value of the OC's IUnkown pointer
#define OCNCOCREATE_CONTINUE       0
#define OCNCOCREATE_HANDLED       -1


#define OCN_PERSISTINIT         (OCN_FIRST + 2)
// NOTE: return values are defined as the following
// If the handler of OCN_PERSISTINIT Notify message returns OCNPERSIST_ABORT,
// the OCHOST will abort IPersist's initialization.
#define OCNPERSISTINIT_CONTINUE    0
#define OCNPERSISTINIT_HANDLED    -1

// The return value on the following notify messages are ignored.
#define OCN_ACTIVATE            (OCN_FIRST + 3)
#define OCN_DEACTIVATE          (OCN_FIRST + 4)
#define OCN_EXIT                (OCN_FIRST + 5)
#define OCN_ONPOSRECTCHANGE     (OCN_FIRST + 6)

typedef struct _OCNONPOSRECTCHANGEMSG {
    NMHDR nmhdr;
    LPCRECT prcPosRect;
} OCNONPOSRECTCHANGEMSG, *LPOCNONPOSRECTCHANGEMSG;

#define OCN_ONUIACTIVATE        (OCN_FIRST + 7)
typedef struct _OCNONUIACTIVATEMSG {
    NMHDR nmhdr;
    IUnknown *punk;
} OCNONUIACTIVATEMSG, *LPOCNONUIACTIVATEMSG;

#define OCNONUIACTIVATE_HANDLED       -1

#define OCN_ONSETSTATUSTEXT     (OCN_FIRST + 8)
typedef struct _OCNONSETSTATUSTEXT {
    NMHDR nmhdr;
    LPCOLESTR pwszStatusText;
} OCNONSETSTATUSTEXTMSG, *LPOCNONSETSTATUSTEXTMSG;


#define OCN_OCEVENT    (OCN_FIRST + 9)
//  OC event notification block.
//  Recipient should return nonzero if any outbound parameters were modified
//  and should be returned to the ActiveX control object; otherwse zero.
//  NOTE: Structure is not properly aligned. Already shipped so too late to fix;internal
typedef struct tagNMOCEVENT
{
    IN NMHDR           hdr ;
    IN DISPID          dispID ;
    IN IID             iid ;
    IN LCID            lcid ;
    IN WORD            wFlags ;
    IN OUT DISPPARAMS  *pDispParams ;
    OUT VARIANT        *pVarResult ;
    OUT EXCEPINFO      *pExepInfo ;
    OUT UINT           *puArgErr ;
} NMOCEVENT, *PNMOCEVENT, *LPNMOCEVENT ;

#endif // NOOCHOST // }
;end_internal

;begin_internal
//
// Access to shdocvw's active session count
//
enum SessionOp {
    SESSION_QUERY = 0,
    SESSION_INCREMENT,
    SESSION_DECREMENT,
        SESSION_INCREMENT_NODEFAULTBROWSERCHECK
};

long SetQueryNetSessionCount(enum SessionOp Op);
SHDOCAPI_(void) IEWriteErrorLog(const EXCEPTION_RECORD* pexr);

;end_internal

//===========================================================================

;begin_internal
//
// Internal APIs Follow.  NOT FOR PUBLIC CONSUMPTION.
//

// Errors shared in the shell

#define E_FILE_NOT_FOUND        MAKE_SCODE(SEVERITY_ERROR, FACILITY_WIN32, ERROR_FILE_NOT_FOUND)
#define E_PATH_NOT_FOUND        MAKE_SCODE(SEVERITY_ERROR, FACILITY_WIN32, ERROR_PATH_NOT_FOUND)


// Useful macros

#define ResultFromShort(i)      MAKE_HRESULT(SEVERITY_SUCCESS, 0, (USHORT)(i))
#define ShortFromResult(r)      (short)HRESULT_CODE(r)


#if (defined(UNICODE) && !defined(_X86_)) // all non-x86 systems require alignment
#ifndef ALIGNMENT_SCENARIO
#define ALIGNMENT_SCENARIO
#endif
#endif

#ifndef LPNTSTR_DEFINED
#define LPNTSTR_DEFINED
typedef UNALIGNED const WCHAR * LPNCWSTR;
typedef UNALIGNED WCHAR *       LPNWSTR;
#ifdef UNICODE
#define LPNCTSTR        LPNCWSTR
#define LPNTSTR         LPNWSTR
#else
#define LPNCTSTR        LPCSTR
#define LPNTSTR         LPSTR
#endif
#endif // LPNTSTR_DEFINED

#define RFN_FIRST       (0U-510U) // run file dialog notify
#define RFN_LAST        (0U-519U)


//=======================================================================
// String constants for
//  1. Registration database keywords       (prefix STRREG_)
//  2. Exported functions from handler dlls (prefix STREXP_)
//  3. .INI file keywords                   (prefix STRINI_)
//  4. Others                               (prefix STR_)
//=======================================================================
#define STRREG_SHELLUI          TEXT("ShellUIHandler")
#define STRREG_SHELL            TEXT("Shell")
#define STRREG_DEFICON          TEXT("DefaultIcon")
#define STRREG_SHEX             TEXT("shellex")
#define STRREG_SHEX_PROPSHEET   STRREG_SHEX TEXT("\\PropertySheetHandlers")
#define STRREG_SHEX_DDHANDLER   STRREG_SHEX TEXT("\\DragDropHandlers")
#define STRREG_SHEX_MENUHANDLER STRREG_SHEX TEXT("\\ContextMenuHandlers")
#define STRREG_SHEX_COPYHOOK    TEXT("Directory\\") STRREG_SHEX TEXT("\\CopyHookHandlers")
#define STRREG_SHEX_PRNCOPYHOOK TEXT("Printers\\") STRREG_SHEX TEXT("\\CopyHookHandlers")
#define STRREG_STARTMENU TEXT("Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\MenuOrder\\Start Menu")
#define STRREG_STARTMENU2 TEXT("Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\MenuOrder\\Start Menu2")
#define STRREG_FAVORITES TEXT("Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\MenuOrder\\Favorites")
#define STRREG_DISCARDABLE      TEXT("Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Discardable")
#define STRREG_POSTSETUP        TEXT("\\PostSetup")

#define STREXP_CANUNLOAD        "DllCanUnloadNow"       // From OLE 2.0

#define STRINI_CLASSINFO        TEXT(".ShellClassInfo")       // secton name
#define STRINI_SHELLUI          TEXT("ShellUIHandler")
#define STRINI_OPENDIRICON      TEXT("OpenDirIcon")
#define STRINI_DIRICON          TEXT("DirIcon")

#define STR_DESKTOPINI          TEXT("desktop.ini")
#define STR_DESKTOPINIA         "desktop.ini"

#define DRIVEID(path)   ((*path - 'A') & 31)

#define PATH_CCH_EXT    64

// DOC'ed for DOJ Compliance
;end_internal
// PathResolve flags
#define PRF_VERIFYEXISTS            0x0001
#define PRF_TRYPROGRAMEXTENSIONS    (0x0002 | PRF_VERIFYEXISTS)
#define PRF_FIRSTDIRDEF             0x0004
#define PRF_DONTFINDLNK             0x0008      // if PRF_TRYPROGRAMEXTENSIONS is specified
;begin_internal

#ifndef NOUSER                                                            ;internal_win40

typedef struct {                                                          ;internal_win40
    NMHDR  hdr;                                                           ;internal_win40
    TCHAR% szCmd[MAX_PATH*2];                                             ;internal_win40
    DWORD  dwHotKey;                                                      ;internal_win40
    HMONITOR hMonitor;                                                    ;internal_win40
} NMVIEWFOLDER%, *LPNMVIEWFOLDER%;                                        ;internal_win40

#endif

//                                                                                               ;internal_win40
//  DDE related APIs                                                                             ;internal_win40
//                                                                                               ;internal_win40
SHSTDDOCAPI_(void) ShellDDEInit(BOOL fInit);                                                          ;internal_win40
SHSTDDOCAPI_(BOOL) DDEHandleViewFolderNotify(IShellBrowser* psb, HWND hwnd, LPNMVIEWFOLDER lpnm);     ;internal_win40
SHSTDDOCAPI_(LPNMVIEWFOLDER) DDECreatePostNotify(LPNMVIEWFOLDER lpnm);                                ;internal_win40

// DOC'ed for DOJ compliance
;end_internal
SHSTDAPI_(int) RestartDialog(HWND hwnd, LPCWSTR lpPrompt, DWORD dwReturn);
SHSTDAPI_(int) RestartDialogEx(HWND hwnd, LPCWSTR lpPrompt, DWORD dwReturn, DWORD dwReasonCode);

SHSTDAPI SHCoCreateInstance(LPCWSTR pszCLSID, const CLSID *pclsid, IUnknown *pUnkOuter, REFIID riid, void **ppv);
;begin_internal

SHSTDAPI CIDLData_CreateFromIDArray(LPCITEMIDLIST pidlFolder, UINT cidl, LPCITEMIDLIST apidl[], IDataObject **ppdtobj);
SHSTDAPI SHCreateFileDataObject(LPCITEMIDLIST pidlFolder, UINT cidl, LPCITEMIDLIST *apidl, IDataObject *pdtInner, IDataObject **pdtobj);


// Common strings
#define STR_DESKTOPCLASS        "Progman"

//
// Storage name of a scrap/bookmark item
//
#define WSTR_SCRAPITEM L"\003ITEM000"

// DOC'ed for DOJ Compliance
;end_internal
// For CallCPLEntry16
//
DECLARE_HANDLE(FARPROC16);
SHSTDAPI_(LRESULT) CallCPLEntry16(HINSTANCE hinst, FARPROC16 lpfnEntry, HWND hwndCPL, UINT msg, LPARAM lParam1, LPARAM lParam2);
;begin_internal

#ifdef RFN_FIRST
#define RFN_EXECUTE             (RFN_FIRST - 0)
typedef struct {
    NMHDR hdr;
    LPCTSTR% lpszCmd;
    LPCTSTR% lpszWorkingDir;
    int nShowCmd;
} NMRUNFILE%, *LPNMRUNFILE%;

#endif

// DOC'ed for DOJ compliance
;end_internal
SHSTDAPI SHCreateStdEnumFmtEtc(UINT cfmt, const FORMATETC afmt[], IEnumFORMATETC **ppenumFormatEtc);
;begin_internal

// Shell create link API
#define SHCL_USETEMPLATE        0x0001
#define SHCL_USEDESKTOP         0x0002
#define SHCL_CONFIRM            0x0004
#define SHCL_MAKEFOLDERSHORTCUT 0x0008
#if (_WIN32_IE >= 0x0600)
#define SHCL_NOUNIQUE           0x0010
#endif // _WIN2_IE >= 0x0600

SHSTDAPI SHCreateLinks(HWND hwnd, LPCTSTR pszDir, IDataObject *pDataObj, UINT fFlags, LPITEMIDLIST* ppidl);

SHSTDAPI SHRegisterDragDrop(HWND hwnd, IDropTarget *pdtgt);
SHSTDAPI SHRevokeDragDrop(HWND hwnd);

// DOC'ed for DOJ compliance
;end_internal
SHSTDAPI SHDoDragDrop(HWND hwnd, IDataObject *pdata, IDropSource *pdsrc, DWORD dwEffect, DWORD *pdwEffect);
;begin_internal

//===========================================================================
// office 9 pluggable UI
//===========================================================================

#define PUI_OFFICE_COMMAND     (WM_USER + 0x901)
#define PLUGUI_CMD_SHUTDOWN    0 // wParam value
#define PLUGUI_CMD_QUERY       1 // wParam value
#define OFFICE_VERSION_9       9 // standardized value to return for Office 9 apps

typedef struct _PLUGUI_INFO
{
    unsigned uMajorVersion : 8; // Used to indicate App's major version number
    unsigned uOleServer : 1;    // BOOL, TRUE if this is an OLE process
    unsigned uUnused : 23;      // not used
} PLUGUI_INFO;

typedef union _PLUGUI_QUERY
{
    UINT uQueryVal;
    PLUGUI_INFO PlugUIInfo;
} PLUGUI_QUERY;

//===========================================================================
// Image dragging API (definitely private)
//===========================================================================

// DOC'ed for DOJ Compliance
;end_internal
// stuff for doing auto scrolling
#define NUM_POINTS      3
typedef struct {        // asd
    int iNextSample;
    DWORD dwLastScroll;
    BOOL bFull;
    POINT pts[NUM_POINTS];
    DWORD dwTimes[NUM_POINTS];
} AUTO_SCROLL_DATA;

;begin_internal

//Contains the drag context header.
// Must be pack1 since it's persisted into a stream that travels between    ;internal
// processes.                                                               ;internal
typedef struct {
    BOOL  fImage;
    BOOL  fLayered;
    POINT ptOffset;
} DragContextHeader;

#define DAD_InitScrollData(pad) (pad)->bFull = FALSE, (pad)->iNextSample = 0, (pad)->dwLastScroll = 0

// DOC'ed for DOJ Compliance
;end_internal
SHSTDAPI_(BOOL) DAD_SetDragImage(HIMAGELIST him, POINT * pptOffset);
;begin_internal
SHSTDAPI_(BOOL) DAD_DragEnter(HWND hwndTarget);

// DOC'ed for DOJ Compliance
;end_internal
SHSTDAPI_(BOOL) DAD_DragEnterEx(HWND hwndTarget, const POINT ptStart);
SHSTDAPI_(BOOL) DAD_DragEnterEx2(HWND hwndTarget, const POINT ptStart, IDataObject *pdtObject);
SHSTDAPI_(BOOL) DAD_ShowDragImage(BOOL fShow);                                                      
SHSTDAPI_(BOOL) DAD_DragMove(POINT pt);
SHSTDAPI_(BOOL) DAD_DragLeave(void);
SHSTDAPI_(BOOL) DAD_AutoScroll(HWND hwnd, AUTO_SCROLL_DATA *pad, const POINT *pptNow);
SHSTDAPI_(BOOL) DAD_SetDragImageFromListView(HWND hwndLV, POINT ptOffset);                          ;internal
SHSTDAPI_(void) DAD_InvalidateCursors(void);                                                        ;internal
;begin_internal


//----------------------------------------------------------------------------
// CABINETSTATE holds the global configuration for the Explorer and its cohorts.
//
// Originally the cLength was an 'int', it is now two words, allowing us to
// specify a version number.
//----------------------------------------------------------------------------

// DOC'ed for DOJ Compliance
;end_internal
typedef struct {
    WORD cLength;
    WORD nVersion;

    BOOL fFullPathTitle            : 1;
    BOOL fSaveLocalView            : 1;
    BOOL fNotShell                 : 1;
    BOOL fSimpleDefault            : 1;
    BOOL fDontShowDescBar          : 1;
    BOOL fNewWindowMode            : 1;
    BOOL fShowCompColor            : 1;  // NT: Show compressed volumes in a different colour
    BOOL fDontPrettyNames          : 1;  // NT: Do 8.3 name conversion, or not!
    BOOL fAdminsCreateCommonGroups : 1;  // NT: Administrators create comon groups
    UINT fUnusedFlags : 7;

    UINT fMenuEnumFilter;

} CABINETSTATE, * LPCABINETSTATE;

#define CABINETSTATE_VERSION 2

// APIs for reading and writing the cabinet state.
SHSTDAPI_(BOOL) ReadCabinetState( LPCABINETSTATE lpState, int iSize );
SHSTDAPI_(BOOL) WriteCabinetState( LPCABINETSTATE lpState );
;begin_internal

// RUN FILE RETURN values from notify message
#define RFR_NOTHANDLED 0
#define RFR_SUCCESS 1
#define RFR_FAILURE 2

#define PathGetExtensionORD     158

SHSTDAPI_(LPTSTR) PathGetExtension(LPCTSTR pszPath, LPTSTR pszExtension, int cchExt);

// DOC'ed for DOJ Compliance
;end_internal
SHSTDAPI_(BOOL) PathMakeUniqueName(LPWSTR pszUniqueName, UINT cchMax, LPCWSTR pszTemplate, LPCWSTR pszLongPlate, LPCWSTR pszDir);
;begin_internal
SHSTDAPI_(BOOL) PathGetShortName(LPCTSTR pszLongName, LPTSTR pszShortName, UINT cbShortName);
SHSTDAPI_(BOOL) PathGetLongName(LPCTSTR pszShortName, LPTSTR pszLongName, UINT cbLongName);
SHSTDAPI_(BOOL) PathDirectoryExists(LPCTSTR pszDir);
// DOC'ed for DOJ Compliance
;end_internal
SHSTDAPI_(void) PathQualify(LPWSTR psz);
;begin_internal
SHSTDAPI_(LPTSTR) PathGetNextComponent(LPCTSTR pszPath, LPTSTR pszComponent);

// DOC'ed for DOJ Compliance
;end_internal
SHSTDAPI_(BOOL) PathIsExe(LPCWSTR pszPath);
;begin_internal

SHSTDAPI_(BOOL) PathIsEqualOrSubFolder(LPCTSTR pszFolder, LPCTSTR pszSubFolder);

// DOC'ed for DOJ Compliance
;end_internal
SHSTDAPI_(BOOL) PathIsSlow%(LPCTSTR% pszFile, DWORD dwAttr);
;begin_internal

SHSTDAPI_(BOOL) PathIsTemporary%(LPCTSTR% pszPath);

// DOC'ed for DOJ Compliance
;end_internal
//
//  Return codes from PathCleanupSpec.  Negative return values are
//  unrecoverable errors
//
#define PCS_FATAL           0x80000000
#define PCS_REPLACEDCHAR    0x00000001
#define PCS_REMOVEDCHAR     0x00000002
#define PCS_TRUNCATED       0x00000004
#define PCS_PATHTOOLONG     0x00000008  // Always combined with FATAL

SHSTDAPI_(int) PathCleanupSpec(LPCWSTR pszDir, LPWSTR pszSpec);
;begin_internal

SHSTDAPI_(int) PathCleanupSpecEx(LPCTSTR pszDir, LPTSTR pszSpec);

// DOC'ed for DOJ Compliance
;end_internal
SHSTDAPI_(int) PathResolve(LPWSTR pszPath, LPCWSTR dirs[], UINT fFlags);
;begin_internal

SHSTDAPI_(BOOL) ParseField(LPCTSTR szData, int n, LPTSTR szBuf, int iBufLen);

// Needed for RunFileDlg
#define RFD_NOBROWSE            0x00000001
#define RFD_NODEFFILE           0x00000002
#define RFD_USEFULLPATHDIR      0x00000004
#define RFD_NOSHOWOPEN          0x00000008
#define RFD_WOW_APP             0x00000010
#define RFD_NOSEPMEMORY_BOX     0x00000020


SHSTDAPI_(int) RunFileDlg(HWND hwnd, HICON hIcon, LPCTSTR pszWorkingDir, LPCTSTR pszTitle,
                          LPCTSTR pszPrompt, DWORD dwFlags);


// DOC'ed for DOJ Compliance
;end_internal
SHSTDAPI_(BOOL) GetFileNameFromBrowse(HWND hwnd, LPWSTR pszFilePath, UINT cbFilePath,
                                      LPCWSTR pszWorkingDir, LPCWSTR pszDefExt, LPCWSTR pszFilters, LPCWSTR pszTitle);
SHSTDAPI_(int) DriveType(int iDrive);

;begin_internal
SHSTDAPI_(int) RealDriveTypeFlags(int iDrive, BOOL fOKToHitNet);

// DOC'ed for DOJ compliance
;end_internal
SHSTDAPI_(int) RealDriveType(int iDrive, BOOL fOKToHitNet);
;begin_internal

SHSTDAPI_(void) InvalidateDriveType(int iDrive);

// DOC'ed for DOJ Compliance
;end_internal
SHSTDAPI_(int) IsNetDrive(int iDrive);
;begin_internal

//
// Constants used for dwNumFmtFlags argument in Int64ToString and LargeIntegerToString.
//
#define NUMFMT_IDIGITS    0x00000001
#define NUMFMT_ILZERO     0x00000002
#define NUMFMT_SGROUPING  0x00000004
#define NUMFMT_SDECIMAL   0x00000008
#define NUMFMT_STHOUSAND  0x00000010
#define NUMFMT_INEGNUMBER 0x00000020
#define NUMFMT_ALL        0xFFFFFFFF

SHSTDAPI_(int) LargeIntegerToString(LARGE_INTEGER *pN, LPTSTR szOutStr, UINT nSize, BOOL bFormat, NUMBERFMT *pFmt, DWORD dwNumFmtFlags);
SHSTDAPI_(int) Int64ToString(_int64 n, LPTSTR szOutStr, UINT nSize, BOOL bFormat, NUMBERFMT *pFmt, DWORD dwNumFmtFlags);

//-------- drive type identification --------------
// iDrive      drive index (0=A, 1=B, ...)
//
#define DRIVE_CDROM     5           // extended DriveType() types
#define DRIVE_RAMDRIVE  6
#define DRIVE_TYPE      0x000F      // type masek
#define DRIVE_SLOW      0x0010      // drive is on a slow link
#define DRIVE_LFN       0x0020      // drive supports LFNs
#define DRIVE_AUTORUN   0x0040      // drive has AutoRun.inf in root.
#define DRIVE_AUDIOCD   0x0080      // drive is a AudioCD
#define DRIVE_AUTOOPEN  0x0100      // should *always* auto open on insert
#define DRIVE_NETUNAVAIL 0x0200     // Network drive that is not available
#define DRIVE_SHELLOPEN  0x0400     // should auto open on insert, if shell has focus
#define DRIVE_SECURITY   0x0800     // Supports ACLs
#define DRIVE_COMPRESSED 0x1000     // Root of volume is compressed
#define DRIVE_ISCOMPRESSIBLE 0x2000 // Drive supports compression (not nescesarrily compressed)
#define DRIVE_DVD       0x4000      // drive is a DVD

#define DriveTypeFlags(iDrive)      DriveType('A' + (iDrive))
#define DriveIsSlow(iDrive)         (RealDriveTypeFlags(iDrive, FALSE) & DRIVE_SLOW)
#define DriveIsLFN(iDrive)          (RealDriveTypeFlags(iDrive, TRUE)  & DRIVE_LFN)
#define DriveIsAutoRun(iDrive)      (RealDriveTypeFlags(iDrive, FALSE) & DRIVE_AUTORUN)
#define DriveIsAutoOpen(iDrive)     (RealDriveTypeFlags(iDrive, FALSE) & DRIVE_AUTOOPEN)
#define DriveIsShellOpen(iDrive)    (RealDriveTypeFlags(iDrive, FALSE) & DRIVE_SHELLOPEN)
#define DriveIsAudioCD(iDrive)      (RealDriveTypeFlags(iDrive, FALSE) & DRIVE_AUDIOCD)
#define DriveIsNetUnAvail(iDrive)   (RealDriveTypeFlags(iDrive, FALSE) & DRIVE_NETUNAVAIL)
#define DriveIsSecure(iDrive)       (RealDriveTypeFlags(iDrive, TRUE)  & DRIVE_SECURITY)
#define DriveIsCompressed(iDrive)   (RealDriveTypeFlags(iDrive, TRUE)  & DRIVE_COMPRESSED)
#define DriveIsCompressible(iDrive) (RealDriveTypeFlags(iDrive, TRUE)  & DRIVE_ISCOMPRESSIBLE)
#define DriveIsDVD(iDrive)          (RealDriveTypeFlags(iDrive, FALSE) & DRIVE_DVD)

#define IsCDRomDrive(iDrive)        (RealDriveType(iDrive, FALSE) == DRIVE_CDROM)
#define IsRamDrive(iDrive)          (RealDriveType(iDrive, FALSE) == DRIVE_RAMDRIVE)
#define IsRemovableDrive(iDrive)    (RealDriveType(iDrive, FALSE) == DRIVE_REMOVABLE)
#define IsRemoteDrive(iDrive)       (RealDriveType(iDrive, FALSE) == DRIVE_REMOTE)


//
// For SHCreateDefClassObject
//
typedef HRESULT (CALLBACK *LPFNCREATEINSTANCE)(IUnknown *pUnkOuter, REFIID riid, void **ppvObject);

SHSTDAPI SHCreateDefClassObject(REFIID riid, void **ppv, LPFNCREATEINSTANCE lpfn, UINT *pcRefDll, REFIID riidInstance);

// DOC'ed for DOJ compliance
;end_internal
// Flags for Shell_MergeMenus
#define MM_ADDSEPARATOR         0x00000001L
#define MM_SUBMENUSHAVEIDS      0x00000002L
#define MM_DONTREMOVESEPS       0x00000004L

SHSTDAPI_(UINT) Shell_MergeMenus(HMENU hmDst, HMENU hmSrc, UINT uInsert, UINT uIDAdjust, UINT uIDAdjustMax, ULONG uFlags);

;begin_internal
typedef HANDLE HNRES;           // for SHGetNetResource
SHSTDAPI_(UINT) SHGetNetResource(HNRES hnres, UINT iItem, LPNETRESOURCE pnres, UINT cbMax);
;end_internal

/*
 * The SHObjectProperties API provides an easy way to invoke
 *   the Properties context menu command on shell objects.
 *
 *   PARAMETERS
 *
 *     hwnd    The window handle of the window which will own the dialog
 *     dwType       A SHOP_ value as defined below
 *     lpObject     Name of the object, see SHOP_ values below
 *     lpPage       The name of the property sheet page to open to or NULL.
 *
 *   RETURN
 *
 *     TRUE if the Properties command was invoked
 */
SHSTDAPI_(BOOL) SHObjectProperties(HWND hwnd, DWORD dwType, LPCWSTR lpObject, LPCWSTR lpPage);

#define SHOP_PRINTERNAME 0x00000001  // lpObject points to a printer friendly name
#define SHOP_FILEPATH    0x00000002  // lpObject points to a fully qualified path+file name
#define SHOP_VOLUMEGUID  0x00000004  // lpObject points to a Volume GUID

;begin_internal
#define SHOP_TYPEMASK    0x00000007	
#define SHOP_MODAL       0x80000000	
;end_internal


/*
 * The SHFormatDrive API provides access to the Shell
 *   format dialog. This allows apps which want to format disks
 *   to bring up the same dialog that the Shell does to do it.
 *
 *   This dialog is not sub-classable. You cannot put custom
 *   controls in it. If you want this ability, you will have
 *   to write your own front end for the DMaint_FormatDrive
 *   engine.
 *
 *   NOTE that the user can format as many diskettes in the specified
 *   drive, or as many times, as he/she wishes to. There is no way to
 *   force any specififc number of disks to format. If you want this
 *   ability, you will have to write your own front end for the
 *   DMaint_FormatDrive engine.
 *
 *   NOTE also that the format will not start till the user pushes the
 *   start button in the dialog. There is no way to do auto start. If
 *   you want this ability, you will have to write your own front end
 *   for the DMaint_FormatDrive engine.
 *
 *   PARAMETERS
 *
 *     hwnd    = The window handle of the window which will own the dialog
 *               NOTE that unlike SHCheckDrive, hwnd == NULL does not cause
 *               this dialog to come up as a "top level application" window.
 *               This parameter should always be non-null, this dialog is
 *               only designed to be the child of another window, not a
 *               stand-alone application.
 *     drive   = The 0 based (A: == 0) drive number of the drive to format
 *     fmtID   = The ID of the physical format to format the disk with
 *               NOTE: The special value SHFMT_ID_DEFAULT means "use the
 *                     default format specified by the DMaint_FormatDrive
 *                     engine". If you want to FORCE a particular format
 *                     ID "up front" you will have to call
 *                     DMaint_GetFormatOptions yourself before calling
 *                     this to obtain the valid list of phys format IDs
 *                     (contents of the PhysFmtIDList array in the
 *                     FMTINFOSTRUCT).
 *     options = There is currently only two option bits defined
 *
 *                SHFMT_OPT_FULL
 *                SHFMT_OPT_SYSONLY
 *
 *               The normal defualt in the Shell format dialog is
 *               "Quick Format", setting this option bit indicates that
 *               the caller wants to start with FULL format selected
 *               (this is useful for folks detecting "unformatted" disks
 *               and wanting to bring up the format dialog).
 *
 *               The SHFMT_OPT_SYSONLY initializes the dialog to
 *               default to just sys the disk.
 *
 *               All other bits are reserved for future expansion and
 *               must be 0.
 *
 *               Please note that this is a bit field and not a value
 *               and treat it accordingly.
 *
 *   RETURN
 *      The return is either one of the SHFMT_* values, or if the
 *      returned DWORD value is not == to one of these values, then
 *      the return is the physical format ID of the last succesful
 *      format. The LOWORD of this value can be passed on subsequent
 *      calls as the fmtID parameter to "format the same type you did
 *      last time".
 *
 */
SHSTDAPI_(DWORD) SHFormatDrive(HWND hwnd, UINT drive, UINT fmtID, UINT options);
;begin_internal

SHSTDAPI_(DWORD) SHChkDskDrive(HWND hwnd, UINT drive);

// DOC'ed for DOJ compliance
;end_internal
//
// Special value of fmtID which means "use the default format"
//
#define SHFMT_ID_DEFAULT    0xFFFF

//
// Option bits for options parameter
//
#define SHFMT_OPT_FULL     0x0001
#define SHFMT_OPT_SYSONLY  0x0002

//
// Special return values. PLEASE NOTE that these are DWORD values.
//
#define SHFMT_ERROR     0xFFFFFFFFL     // Error on last format, drive may be formatable
#define SHFMT_CANCEL    0xFFFFFFFEL     // Last format was canceled
#define SHFMT_NOFORMAT  0xFFFFFFFDL     // Drive is not formatable

;begin_internal
//====== SEMI-PRIVATE API ===============================
// DOC'ed for DOJ compliance
;end_internal
#ifndef HPSXA_DEFINED
#define HPSXA_DEFINED
DECLARE_HANDLE( HPSXA );
#endif
WINSHELLAPI HPSXA SHCreatePropSheetExtArray( HKEY hKey, LPCWSTR pszSubKey, UINT max_iface );
WINSHELLAPI void SHDestroyPropSheetExtArray( HPSXA hpsxa );
WINSHELLAPI UINT SHAddFromPropSheetExtArray( HPSXA hpsxa, LPFNADDPROPSHEETPAGE lpfnAddPage, LPARAM lParam );
WINSHELLAPI UINT SHReplaceFromPropSheetExtArray( HPSXA hpsxa, UINT uPageID, LPFNADDPROPSHEETPAGE lpfnReplaceWith, LPARAM lParam );
;begin_internal
WINSHELLAPI HPSXA SHCreatePropSheetExtArrayEx( HKEY hKey, LPCTSTR pszSubKey, UINT max_iface, IDataObject * pdo );

//====== SEMI-PRIVATE API ORDINALS ===============================
// This is the list of semi-private ordinals we semi-publish.
#define SHGetNetResourceORD                      69
#define SHObjectPropertiesORD                   178
#define SHAddFromPropSheetExtArrayORD           167
#define SHCreatePropSheetExtArrayORD            168
#define SHDestroyPropSheetExtArrayORD           169
#define SHReplaceFromPropSheetExtArrayORD       170
#define SHCreateDefClassObjectORD                70

#define SHEXP_SHGETNETRESOURCE                  MAKEINTRESOURCE(SHGetNetResourceORD)

#define SHEXP_SHADDFROMPROPSHEETEXTARRAY        MAKEINTRESOURCE(SHAddFromPropSheetExtArrayORD)
#define SHEXP_SHCREATEPROPSHEETEXTARRAY         MAKEINTRESOURCE(SHCreatePropSheetExtArrayORD)
#define SHEXP_SHDESTROYPROPSHEETEXTARRAY        MAKEINTRESOURCE(SHDestroyPropSheetExtArrayORD)
#define SHEXP_SHREPLACEFROMPROPSHEETEXTARRAY    MAKEINTRESOURCE(SHReplaceFromPropSheetExtArrayORD)
#define SHEXP_SHCREATEDEFCLASSOBJECT            MAKEINTRESOURCE(SHCreateDefClassObjectORD)


// This avoids duplicate definition problems in the net\config project
// which defines *some* of its own PIDL utility functions, but depends on
// us for others (ILClone())

// DOC'ed for DOJ Compliance
;end_internal
SHSTDAPI_(LPITEMIDLIST) ILClone(LPCITEMIDLIST pidl);
;begin_internal

#ifndef AVOID_NET_CONFIG_DUPLICATES
//===========================================================================
// ITEMIDLIST
//===========================================================================

// flags for ILGetDisplayNameEx
#define ILGDN_FULLNAME  0
#define ILGDN_ITEMONLY  1
#define ILGDN_INFOLDER  2

// DOC'ed for DOJ Compliance
;end_internal
SHSTDAPI_(LPITEMIDLIST) ILGetNext(LPCITEMIDLIST pidl);
SHSTDAPI_(UINT)         ILGetSize(LPCITEMIDLIST pidl);
SHSTDAPI_(LPITEMIDLIST) ILFindLastID(LPCITEMIDLIST pidl);
SHSTDAPI_(BOOL)         ILRemoveLastID(LPITEMIDLIST pidl);
;begin_internal

#define ILIsEmpty(pidl)     ((pidl) == NULL || (pidl)->mkid.cb==0)

SHSTDAPI_(LPITEMIDLIST) ILCreate(void);

// DOC'ed for DOJ Compliance
;end_internal
SHSTDAPI_(LPITEMIDLIST) ILAppendID(LPITEMIDLIST pidl, LPCSHITEMID pmkid, BOOL fAppend);
SHSTDAPI_(void)         ILFree(LPITEMIDLIST pidl);
;begin_internal

SHSTDAPI_(void)         ILGlobalFree(LPITEMIDLIST pidl);
SHSTDAPI_(BOOL)         ILGetDisplayName(LPCITEMIDLIST pidl, LPTSTR pszName);
SHSTDAPI_(BOOL)         ILGetDisplayNameEx(IShellFolder *psfRoot, LPCITEMIDLIST pidl, LPTSTR pszName, int fType);

// DOC'ed for DOJ Compliance
;end_internal
SHSTDAPI_(LPITEMIDLIST) ILCloneFirst(LPCITEMIDLIST pidl);
;begin_internal

SHSTDAPI_(LPITEMIDLIST) ILGlobalClone(LPCITEMIDLIST pidl);

// DOC'ed for DOJ Compliance
;end_internal
SHSTDAPI_(BOOL)         ILIsEqual(LPCITEMIDLIST pidl1, LPCITEMIDLIST pidl2);
SHSTDAPI_(BOOL)         ILIsParent(LPCITEMIDLIST pidl1, LPCITEMIDLIST pidl2, BOOL fImmediate);
SHSTDAPI_(LPITEMIDLIST) ILFindChild(LPCITEMIDLIST pidlParent, LPCITEMIDLIST pidlChild);
SHSTDAPI_(LPITEMIDLIST) ILCombine(LPCITEMIDLIST pidl1, LPCITEMIDLIST pidl2);
SHSTDAPI                ILLoadFromStream(IStream *pstm, LPITEMIDLIST *pidl);
SHSTDAPI                ILSaveToStream(IStream *pstm, LPCITEMIDLIST pidl);
;begin_internal

SHSTDAPI                ILLoadFromFile(HFILE hfile, LPITEMIDLIST *pidl);
SHSTDAPI                ILSaveToFile(HFILE hfile, LPCITEMIDLIST pidl);

// DOC'ed for DOJ Compliance
;end_internal
#if (_WIN32_IE >= 0x0400)

SHSTDAPI_(LPITEMIDLIST) ILCreateFromPathA(LPCSTR pszPath);
SHSTDAPI_(LPITEMIDLIST) ILCreateFromPathW(LPCWSTR pszPath);

#ifdef NO_WRAPPERS_FOR_ILCREATEFROMPATH
SHSTDAPI_(LPITEMIDLIST) ILCreateFromPath(LPCTSTR pszPath);
#else
#ifdef UNICODE
#define ILCreateFromPath  ILCreateFromPathW
#else
#define ILCreateFromPath  ILCreateFromPathA
#endif // !UNICODE
#endif

#endif
SHSTDAPI SHILCreateFromPath(LPCWSTR szPath, LPITEMIDLIST *ppidl, DWORD *rgfInOut);
;begin_internal

// helper macros
#define ILCreateFromID(pmkid)   ILAppendID(NULL, pmkid, TRUE)

#endif // AVOID_NET_CONFIG_DUPLICATES

// WARNING: this interface is not supported on the current platform, just downlevel

;end_internal
#undef  INTERFACE
#define INTERFACE   IDefViewFrame
DECLARE_INTERFACE_(IDefViewFrame, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IDefViewFrame methods ***
    STDMETHOD(GetWindowLV) (THIS_ HWND * phwnd) PURE;
    STDMETHOD(ReleaseWindowLV) (THIS) PURE;
    STDMETHOD(GetShellFolder)(THIS_ IShellFolder **ppsf) PURE;
};

;begin_internal

#undef  INTERFACE
#define INTERFACE   IWebViewOCWinMan
DECLARE_INTERFACE_(IWebViewOCWinMan, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IWebViewOCWinMan methods ***
    STDMETHOD(SwapWindow) (THIS_ HWND hwndLV, IWebViewOCWinMan **pocWinMan) PURE;
};

// DOC'ed for DOJ compliance
;end_internal
//===========================================================================
// Shell restrictions. (Parameter for SHRestricted)
typedef enum RESTRICTIONS
{
;begin_internal
    // Classic Win95 policy bits.  Do NOT add any more bits in
    // this range.  See the ranges below to add new policies.
    //          |                        |
    //          v                        v
;end_internal
    REST_NONE                       = 0x00000000,
    REST_NORUN                      = 0x00000001,
    REST_NOCLOSE                    = 0x00000002,
    REST_NOSAVESET                  = 0x00000004,
    REST_NOFILEMENU                 = 0x00000008,
    REST_NOSETFOLDERS               = 0x00000010,
    REST_NOSETTASKBAR               = 0x00000020,
    REST_NODESKTOP                  = 0x00000040,
    REST_NOFIND                     = 0x00000080,
    REST_NODRIVES                   = 0x00000100,
    REST_NODRIVEAUTORUN             = 0x00000200,
    REST_NODRIVETYPEAUTORUN         = 0x00000400,
    REST_NONETHOOD                  = 0x00000800,
    REST_STARTBANNER                = 0x00001000,
    REST_RESTRICTRUN                = 0x00002000,
    REST_NOPRINTERTABS              = 0x00004000,
    REST_NOPRINTERDELETE            = 0x00008000,
    REST_NOPRINTERADD               = 0x00010000,
    REST_NOSTARTMENUSUBFOLDERS      = 0x00020000,
    REST_MYDOCSONNET                = 0x00040000,
    REST_NOEXITTODOS                = 0x00080000,
    REST_ENFORCESHELLEXTSECURITY    = 0x00100000,
    REST_LINKRESOLVEIGNORELINKINFO  = 0x00200000,
    REST_NOCOMMONGROUPS             = 0x00400000,
    REST_SEPARATEDESKTOPPROCESS     = 0x00800000,
    REST_NOWEB                      = 0x01000000,
    REST_NOTRAYCONTEXTMENU          = 0x02000000,
    REST_NOVIEWCONTEXTMENU          = 0x04000000,
    REST_NONETCONNECTDISCONNECT     = 0x08000000,
    REST_STARTMENULOGOFF            = 0x10000000,
    REST_NOSETTINGSASSIST           = 0x20000000,
;begin_internal
    // Values starting at 4000001 are treated as raw INTs.  New
    // *shell-specific* policies (NOT browser policies) should
    // be added in this range.  Use SHRestricted() with these bits.
    //          |                        |
    //          v                        v
;end_internal
    REST_NOINTERNETICON             = 0x40000001,
    REST_NORECENTDOCSHISTORY        = 0x40000002,
    REST_NORECENTDOCSMENU           = 0x40000003,
    REST_NOACTIVEDESKTOP            = 0x40000004,
    REST_NOACTIVEDESKTOPCHANGES     = 0x40000005,
    REST_NOFAVORITESMENU            = 0x40000006,
    REST_CLEARRECENTDOCSONEXIT      = 0x40000007,
    REST_CLASSICSHELL               = 0x40000008,
    REST_NOCUSTOMIZEWEBVIEW         = 0x40000009,
    REST_NOHTMLWALLPAPER            = 0x40000010,
    REST_NOCHANGINGWALLPAPER        = 0x40000011,
    REST_NODESKCOMP                 = 0x40000012,
    REST_NOADDDESKCOMP              = 0x40000013,
    REST_NODELDESKCOMP              = 0x40000014,
    REST_NOCLOSEDESKCOMP            = 0x40000015,
    REST_NOCLOSE_DRAGDROPBAND       = 0x40000016,   // Disable Close and Drag & Drop on ALL Bands
    REST_NOMOVINGBAND               = 0x40000017,   // Disable Moving ALL Bands
    REST_NOEDITDESKCOMP             = 0x40000018,
    REST_NORESOLVESEARCH            = 0x40000019,
    REST_NORESOLVETRACK             = 0x4000001A,
    REST_FORCECOPYACLWITHFILE       = 0X4000001B,
    REST_NOLOGO3CHANNELNOTIFY       = 0x4000001C,
    REST_NOFORGETSOFTWAREUPDATE     = 0x4000001D,
    REST_NOSETACTIVEDESKTOP         = 0x4000001E,   // No Active desktop on Settings Menu
    REST_NOUPDATEWINDOWS            = 0x4000001F,   // No Windows Update on Settings Menu
    REST_NOCHANGESTARMENU           = 0x40000020,   // No Context menu or Drag and Drop on Start menu
    REST_NOFOLDEROPTIONS            = 0x40000021,   // No Folder Options on Settings Menu
    REST_HASFINDCOMPUTERS           = 0x40000022,   // Show Start/Search/Computers
    REST_INTELLIMENUS               = 0x40000023,
    REST_RUNDLGMEMCHECKBOX          = 0x40000024,
    REST_ARP_ShowPostSetup          = 0x40000025,   // ARP: Show Post-Setup page
    REST_NOCSC                      = 0x40000026,   // Disable the ClientSide caching on SM
    REST_NOCONTROLPANEL             = 0x40000027,   // Remove the Control Panel only from SM|Settings
    REST_ENUMWORKGROUP              = 0x40000028,   // Enumerate workgroup in root of nethood
    REST_ARP_NOARP                  = 0x40000029,   // ARP: Don't Allow ARP to come up at all
    REST_ARP_NOREMOVEPAGE           = 0x4000002A,   // ARP: Don't allow Remove page
    REST_ARP_NOADDPAGE              = 0x4000002B,   // ARP: Don't allow Add page
    REST_ARP_NOWINSETUPPAGE         = 0x4000002C,   // ARP: Don't allow opt components page
    REST_GREYMSIADS                 = 0x4000002D,    // SM: Allow the greying of Darwin Ads in SM
    REST_NOCHANGEMAPPEDDRIVELABEL   = 0x4000002E,   // Don't enable the UI which allows users to rename mapped drive labels
    REST_NOCHANGEMAPPEDDRIVECOMMENT = 0x4000002F,   // Don't enable the UI which allows users to change mapped drive comments
    REST_MaxRecentDocs              = 0x40000030,
    REST_NONETWORKCONNECTIONS       = 0x40000031,   // No Start Menu | Settings |Network Connections
    REST_FORCESTARTMENULOGOFF       = 0x40000032,   // Force logoff on the Start Menu
    REST_NOWEBVIEW                  = 0x40000033,   // Disable Web View
    REST_NOCUSTOMIZETHISFOLDER      = 0x40000034,   // Disable Customize This Folder
    REST_NOENCRYPTION               = 0x40000035,   // Don't allow file encryption
//  Do NOT use me                     0x40000036,
    REST_DONTSHOWSUPERHIDDEN        = 0x40000037,   // don't show super hidden files
    REST_NOSHELLSEARCHBUTTON        = 0x40000038,
    REST_NOHARDWARETAB              = 0x40000039,   // No Hardware tab on Drives or in control panel
    REST_NORUNASINSTALLPROMPT       = 0x4000003A,   // Don't bring up "Run As" prompt for install programs
    REST_PROMPTRUNASINSTALLNETPATH  = 0x4000003B,   // Force the  "Run As" prompt for install programs on unc/network shares
    REST_NOMANAGEMYCOMPUTERVERB     = 0x4000003C,   // No Manage verb on My Computer
    REST_NORECENTDOCSNETHOOD        = 0x4000003D,   // dont add the recent docs shares to nethood
    REST_DISALLOWRUN                = 0x4000003E,   // don't allow certain apps to be run
    REST_NOWELCOMESCREEN            = 0x4000003F,   // don't allow the welcome screen to be displayed.
    REST_RESTRICTCPL                = 0x40000040,   // only allow certain cpls to be run
    REST_DISALLOWCPL                = 0x40000041,   // don't allow certain cpls to be run
    REST_NOSMBALLOONTIP             = 0x40000042,   // No Start Menu Balloon Tip
    REST_NOSMHELP                   = 0x40000043,   // No Help on the Start Menu
    REST_NOWINKEYS                  = 0x40000044,   // No Windows-X Hot keys
    REST_NOENCRYPTONMOVE            = 0x40000045,   // Don't automatically try to encrypt files that are moved to encryped directories
    REST_NOLOCALMACHINERUN          = 0x40000046,   // ignore HKLM\sw\ms\win\cv\Run and all of it's sub keys
    REST_NOCURRENTUSERRUN           = 0x40000047,   // ignore HKCU\sw\ms\win\cv\Run and all of it's sub keys
    REST_NOLOCALMACHINERUNONCE      = 0x40000048,   // ignore HKLM\sw\ms\win\cv\RunOnce and all of it's sub keys
    REST_NOCURRENTUSERRUNONCE       = 0x40000049,   // ignore HKCU\sw\ms\win\cv\RunOnce and all of it's sub keys
    REST_FORCEACTIVEDESKTOPON       = 0x4000004A,   // Force ActiveDesktop to be turned ON all the time.
    REST_NOCOMPUTERSNEARME          = 0x4000004B,   // removes the "Computers near me" link
    REST_NOVIEWONDRIVE              = 0x4000004C,   // disallows CreateViewObject() on specified drives (CFSFolder only)
    REST_NONETCRAWL                 = 0x4000004D,   // disables the crawling of the WNet namespace.
    REST_NOSHAREDDOCUMENTS          = 0x4000004E,   // don't auto share the Shared Documents/create link
    REST_NOSMMYDOCS                 = 0x4000004F,   // Don't show the My Documents item on the Start Menu.
    REST_NOSMMYPICS                 = 0x40000050,   // Don't show the My Pictures item on the Start Menu
    REST_ALLOWBITBUCKDRIVES         = 0x40000051,   // Bit mask indicating which which drives have bit bucket support
    REST_NONLEGACYSHELLMODE         = 0x40000052,   // new consumer shell modes
    REST_NOCONTROLPANELBARRICADE    = 0x40000053,   // The webview barricade in Control Panel
    REST_NOSTARTPAGE                = 0x40000054,   // Whistler Start Page on desktop.
    REST_NOAUTOTRAYNOTIFY           = 0x40000055,   // Whistler auto-tray notify feature
    REST_NOTASKGROUPING             = 0x40000056,   // Whistler taskbar button grouping feature
    REST_NOCDBURNING                = 0x40000057,   // whistler cd burning feature
    REST_MYCOMPNOPROP               = 0x40000058,   // disables Properties on My Computer's context menu
    REST_MYDOCSNOPROP               = 0x40000059,   // disables Properties on My Documents' context menu
    REST_NOSTARTPANEL               = 0x4000005A,   // Windows start panel (New start menu) for Whistler.
    REST_NODISPLAYAPPEARANCEPAGE    = 0x4000005B,   // disable Themes and Appearance tabs in the Display Control Panel.
    REST_NOTHEMESTAB                = 0x4000005C,   // disable the Themes tab in the Display Control Panel.
    REST_NOVISUALSTYLECHOICE        = 0x4000005D,   // disable the visual style drop down in the Appearance tab of the Display Control Panel.
    REST_NOSIZECHOICE               = 0x4000005E,   // disable the size drop down in the Appearance tab of the Display Control Panel.
    REST_NOCOLORCHOICE              = 0x4000005F,   // disable the color drop down in the Appearance tab of the Display Control Panel.
    REST_SETVISUALSTYLE             = 0x40000060,   // Load the specified file as the visual style.
    REST_STARTRUNNOHOMEPATH         = 0x40000061,   // dont use the %HOMEPATH% env var for the Start-Run dialog
    REST_NOUSERNAMEINSTARTPANEL     = 0x40000062,   // don't show the username is the startpanel.
    REST_NOMYCOMPUTERICON           = 0x40000063,   // don't show my computer anywhere, hide its contents
    REST_NOSMNETWORKPLACES          = 0x40000064,   // don't show network places in startpanel.
    REST_NOSMPINNEDLIST             = 0x40000065,   // don't show the pinned list in startpanel.
    REST_NOSMMYMUSIC                = 0x40000066,   // don't show MyMusic folder in startpanel
    REST_NOSMEJECTPC                = 0x40000067,   // don't show "Undoc PC" command in startmenu
    REST_NOSMMOREPROGRAMS           = 0x40000068,   // don't show "More Programs" button in StartPanel.
    REST_NOSMMFUPROGRAMS            = 0x40000069,   // don't show the MFU programs list in StartPanel.
    REST_NOTRAYITEMSDISPLAY         = 0x4000006A,   // disables the display of the system tray
    REST_NOTOOLBARSONTASKBAR        = 0x4000006B,   // disables toolbar display on the taskbar
;begin_internal    
  //--- UNUSED -- USE THIS SPACE ---  0x4000006C to 0x4000006E
;end_internal
    REST_NOSMCONFIGUREPROGRAMS      = 0x4000006F,   // No Configure Programs on Settings Menu
    REST_HIDECLOCK                  = 0x40000070,   // don't show the clock
    REST_NOLOWDISKSPACECHECKS       = 0x40000071,   // disable the low disk space checking
    REST_NOENTIRENETWORK            = 0x40000072,   // removes the "Entire Network" link (i.e. from "My Network Places")
    REST_NODESKTOPCLEANUP           = 0x40000073,   // disable the desktop cleanup wizard
    REST_BITBUCKNUKEONDELETE        = 0x40000074,   // disables recycling of files
    REST_BITBUCKCONFIRMDELETE       = 0x40000075,   // always show the delete confirmation dialog when deleting files
    REST_BITBUCKNOPROP              = 0x40000076,   // disables Properties on Recycle Bin's context menu
    REST_NODISPBACKGROUND           = 0x40000077,   // disables the Desktop tab in the Display CPL
    REST_NODISPSCREENSAVEPG         = 0x40000078,   // disables the Screen Saver tab in the Display CPL
    REST_NODISPSETTINGSPG           = 0x40000079,   // disables the Settings tab in the Display CPL
    REST_NODISPSCREENSAVEPREVIEW    = 0x4000007A,   // disables the screen saver on the Screen Saver tab in the Display CPL
    REST_NODISPLAYCPL               = 0x4000007B,   // disables the Display CPL
    REST_HIDERUNASVERB              = 0x4000007C,   // hides the "Run As..." context menu item
    REST_NOTHUMBNAILCACHE           = 0x4000007D,   // disables use of the thumbnail cache
    REST_NOSTRCMPLOGICAL            = 0x4000007E,   // dont use StrCmpLogical() instead use default CompareString()

    REST_ALLOWUNHASHEDWEBVIEW       = 0x40000082,   // allow the user to be promted to accept web view templates that don't already have an md5 hash in the registry
    REST_ALLOWLEGACYWEBVIEW         = 0x40000083,   // allow legacy webview template to be shown.
    REST_REVERTWEBVIEWSECURITY      = 0x40000084,   // disable added webview security measures (revert to w2k functionality).

    REST_INHERITCONSOLEHANDLES      = 0x40000086,   // ShellExec() will check for the current process and target process being console processes to inherit handles

    REST_NODISCONNECT               = 0x41000001,   // No Disconnect option in Start menu
    REST_NOSECURITY                 = 0x41000002,   // No Security option in start menu
    REST_NOFILEASSOCIATE            = 0x41000003,   // Do not allow user to change file association

} RESTRICTIONS;
;begin_internal

// Browser restrictions (parameter for SHRestricted2)
//
// The browser restrictions are divided into two ranges, "explorer restrictions" and
// "infodelivery restrictions".  Explorer restrictions are kept under "Software\\Microsoft\\
// Windows\\CurrentVersion\\Policies\\Explorer," while infodelivery restrictions are kept
// under "Software\\Policies\\Microsoft\\Internet Explorer\\Infodelivery\\Restrictions."
//
// **NOTE**: SHRestricted2 assumes each range is continuous.
typedef enum {
    // explorer restrictions
    REST_BROWSER_NONE               = 0x00000000,   // REST_EXPLORER_FIRST
    REST_NOTOOLBARCUSTOMIZE         = 0x00000001,
    REST_NOBANDCUSTOMIZE            = 0x00000002,
    REST_SMALLICONS                 = 0x00000003,
    REST_LOCKICONSIZE               = 0x00000004,
    REST_SPECIFYDEFAULTBUTTONS      = 0x00000005,
    REST_BTN_BACK                   = 0x00000006,
    REST_BTN_FORWARD                = 0x00000007,
    REST_BTN_STOPDOWNLOAD           = 0x00000008,
    REST_BTN_REFRESH                = 0x00000009,
    REST_BTN_HOME                   = 0x0000000A,
    REST_BTN_SEARCH                 = 0x0000000B,
    REST_BTN_HISTORY                = 0x0000000C,
    REST_BTN_FAVORITES              = 0x0000000D,
    REST_BTN_ALLFOLDERS             = 0x0000000E,
    REST_BTN_THEATER                = 0x0000000F,
    REST_BTN_TOOLS                  = 0x00000010,
    REST_BTN_MAIL                   = 0x00000011,
    REST_BTN_FONTS                  = 0x00000012,
    REST_BTN_PRINT                  = 0x00000013,
    REST_BTN_EDIT                   = 0x00000014,
    REST_BTN_DISCUSSIONS            = 0x00000015,
    REST_BTN_CUT                    = 0x00000016,
    REST_BTN_COPY                   = 0x00000017,
    REST_BTN_PASTE                  = 0x00000018,
    REST_BTN_ENCODING               = 0x00000019,
    REST_NoUserAssist               = 0x0000001A,
    REST_NoWindowsUpdate            = 0x0000001B,
    REST_NoExpandedNewMenu          = 0x0000001C,
    REST_NOFILEURL                  = 0x0000001D,
    REST_BTN_PRINTPREVIEW           = 0X0000001E,   
    REST_BTN_MEDIABAR               = 0x0000001F,   // REST_EXPLORER_LAST

    // infodelivery restrictions
    REST_NoChannelUI                = 0x50000001,   // REST_INFO_FIRST
    REST_NoAddingChannels           = 0x50000002,
    REST_NoEditingChannels          = 0x50000003,
    REST_NoRemovingChannels         = 0x50000004,
    REST_NoAddingSubscriptions      = 0x50000005,
    REST_NoEditingSubscriptions     = 0x50000006,
    REST_NoRemovingSubscriptions    = 0x50000007,
    REST_NoChannelLogging           = 0x50000008,
    REST_NoManualUpdates            = 0x50000009,
    REST_NoScheduledUpdates         = 0x5000000A,
    REST_NoUnattendedDialing        = 0x5000000B,
    REST_NoChannelContent           = 0x5000000C,
    REST_NoSubscriptionContent      = 0x5000000D,
    REST_NoEditingScheduleGroups    = 0x5000000E,
    REST_MaxChannelSize             = 0x5000000F,
    REST_MaxSubscriptionSize        = 0x50000010,
    REST_MaxChannelCount            = 0x50000011,
    REST_MaxSubscriptionCount       = 0x50000012,
    REST_MinUpdateInterval          = 0x50000013,
    REST_UpdateExcludeBegin         = 0x50000014,
    REST_UpdateExcludeEnd           = 0x50000015,
    REST_UpdateInNewProcess         = 0x50000016,
    REST_MaxWebcrawlLevels          = 0x50000017,
    REST_MaxChannelLevels           = 0x50000018,
    REST_NoSubscriptionPasswords    = 0x50000019,
    REST_NoBrowserSaveWebComplete   = 0x5000001A,
    REST_NoSearchCustomization      = 0x5000001B,
    REST_NoSplash                   = 0x5000001C,  // REST_INFO_LAST

    // restrictions ported from SP2
    REST_NoFileOpen                 = 0x60000001,  // REST_BROWSER_FIRST
    REST_NoFileNew                  = 0x60000002,
    REST_NoBrowserSaveAs            = 0x60000003,
    REST_NoBrowserOptions           = 0x60000004,
    REST_NoFavorites                = 0x60000005,
    REST_NoSelectDownloadDir        = 0x60000006,
    REST_NoBrowserContextMenu       = 0x60000007,
    REST_NoBrowserClose             = 0x60000008,
    REST_NoOpeninNewWnd             = 0x60000009,
    REST_NoTheaterMode              = 0x6000000A,
    REST_NoFindFiles                = 0x6000000B,
    REST_NoViewSource               = 0x6000000C,
    REST_GoMenu                     = 0x6000000D,
    REST_NoToolbarOptions           = 0x6000000E,

    REST_NoHelpItem_TipOfTheDay     = 0x6000000F,
    REST_NoHelpItem_NetscapeHelp    = 0x60000010,
    REST_NoHelpItem_Tutorial        = 0x60000011,
    REST_NoHelpItem_SendFeedback    = 0x60000012,
    REST_AlwaysPromptWhenDownload   = 0x60000013,

    REST_NoNavButtons               = 0x60000014,
    REST_NoHelpMenu                 = 0x60000015,
    REST_NoBrowserBars              = 0x60000016,
    REST_NoToolBar                  = 0x60000017,
    REST_NoAddressBar               = 0x60000018,
    REST_NoLinksBar                 = 0x60000019,
    REST_NoPrinting                 = 0x60000020,

    REST_No_LaunchMediaBar          = 0x60000021,
    REST_No_MediaBarOnlineContent   = 0x60000022,   // REST_BROWSER_LAST   

} BROWSER_RESTRICTIONS;

#define REST_EXPLORER_FIRST     REST_BROWSER_NONE
#define REST_EXPLORER_LAST      REST_BTN_MEDIABAR

#define REST_INFO_FIRST         REST_NoChannelUI
#define REST_INFO_LAST          REST_NoSplash

#define REST_BROWSER_FIRST      REST_NoFileOpen
#define REST_BROWSER_LAST       REST_No_MediaBarOnlineContent

// codes for REST_BTN policies
#define RESTOPT_BTN_STATE_DEFAULT       0   // must be zero, else break browseui\itbar.cpp assumption
#define RESTOPT_BTN_STATE_VISIBLE       1
#define RESTOPT_BTN_STATE_HIDDEN        2

// REST_INTELLIMENUS
#define RESTOPT_INTELLIMENUS_USER       0
#define RESTOPT_INTELLIMENUS_DISABLED   1       // Match Restriction assumption: 1 == Off
#define RESTOPT_INTELLIMENUS_ENABLED    2


// FTP Exports
STDAPI IsIEDefautlFTPClient(void);
STDAPI MakeIEDefautlFTPClient(void);
STDAPI RestoreFTPClient(void);

SHSTDAPI_(void) SHSettingsChanged(WPARAM wParam, LPARAM lParam);
SHSTDAPI_(BOOL) SHIsBadInterfacePtr(LPCVOID pv, UINT cbVtbl);
// DOC'ed for DOJ Compliance
;end_internal
SHSTDAPI_(IStream *) OpenRegStream(HKEY hkey, LPCWSTR pszSubkey, LPCWSTR pszValue, DWORD grfMode);
;begin_internal
SHSTDAPI_(void) SHHandleDiskFull(HWND hwnd, int idDrive);

// DOC'ed for DOJ compliance
;end_internal
SHSTDAPI_(BOOL) SHFindFiles(LPCITEMIDLIST pidlFolder, LPCITEMIDLIST pidlSaveFile);
;begin_internal
SHSTDAPI_(BOOL) SHFindComputer(LPCITEMIDLIST pidlFolder, LPCITEMIDLIST pidlSaveFile);

// DOC'ed for DOJ Compliance
;end_internal
SHSTDAPI_(void) PathGetShortPath(LPWSTR pszLongPath);
SHSTDAPI_(BOOL) PathYetAnotherMakeUniqueName(LPWSTR  pszUniqueName, LPCWSTR pszPath, LPCWSTR pszShort, LPCWSTR pszFileSpec);
;begin_internal

SHSTDAPI_(BOOL) Win32CreateDirectory(LPCTSTR pszPath, SECURITY_ATTRIBUTES *psa);
SHSTDAPI_(BOOL) Win32RemoveDirectory(LPCTSTR pszPath);

// DOC'ed for DOJ Compliance
;end_internal
SHSTDAPI_(BOOL) Win32DeleteFile(LPCWSTR pszPath);
;begin_internal

SHSTDAPI_(void) SHUpdateRecycleBinIcon();

// DOC'ed for DOJ Compliance
;end_internal
//
// Path processing function
//
#define PPCF_ADDQUOTES               0x00000001        // return a quoted name if required
#define PPCF_ADDARGUMENTS            0x00000003        // appends arguments (and wraps in quotes if required)
#define PPCF_NODIRECTORIES           0x00000010        // don't match to directories
#define PPCF_NORELATIVEOBJECTQUALIFY 0x00000020        // don't return fully qualified relative objects
#define PPCF_FORCEQUALIFY            0x00000040        // qualify even non-relative names
#define PPCF_LONGESTPOSSIBLE         0x00000080        // always find the longest possible name

SHSTDAPI_(LONG) PathProcessCommand(LPCWSTR lpSrc, LPWSTR lpDest, int iMax, DWORD dwFlags);
;begin_internal

SHSTDAPI_(LPITEMIDLIST) SHLogILFromFSIL(LPCITEMIDLIST pidlFS);
SHSTDAPI_(BOOL) StrRetToStrN(LPTSTR szOut, UINT uszOut, STRRET *pStrRet, LPCITEMIDLIST pidl);
SHSTDAPI_(DWORD) SHWaitForFileToOpen(LPCITEMIDLIST pidl, UINT uOptions, DWORD dwtimeout);
SHSTDAPI_(void) SetAppStartingCursor(HWND hwnd, BOOL fSet);
// DOC'ed for DOJ compliance
;end_internal
SHSTDAPI_(DWORD) SHRestricted(RESTRICTIONS rest);
;begin_internal
SHSTDAPI_(void *) SHGetHandlerEntry(LPCTSTR szHandler, LPCSTR szProcName, HINSTANCE *lpModule);

// This is sent to a browser windows letting them know that we have
// opened a folder, i.e. the folder open operation is done.
// Call RegisterWindowMessage to get the ID
#define SH_FILEOPENED     TEXT("ShellFileOpened")

// DOC'ed for DOJ compliance
;end_internal
SHSTDAPI_(BOOL) SignalFileOpen(LPCITEMIDLIST pidl);
SHSTDAPI_(LPITEMIDLIST) SHSimpleIDListFromPath(LPCWSTR pszPath);
;begin_internal

SHSTDAPI SHCreatePropertyBag(REFIID riid, void **ppv);

SHSTDAPI_(DWORD) SHNetConnectionDialog(HWND hwnd, LPTSTR pszRemoteName, DWORD dwType);

// DOC'ed for DOJ Compliance
;end_internal
SHSTDAPI SHLoadOLE(LPARAM lParam);
SHSTDAPI SHStartNetConnectionDialog%(HWND hwnd, LPCTSTR% pszRemoteName, DWORD dwType);
SHSTDAPI SHDefExtractIcon%(LPCTSTR% pszIconFile, int iIndex, UINT uFlags,
                           HICON *phiconLarge, HICON *phiconSmall, UINT nIconSize);
;begin_internal
SHSTDAPI_(int) SHLookupIconIndex%(LPCTSTR% pszFile, int iIconIndex, UINT uFlags);
SHSTDAPI_(UINT) SHExtractIcons%(LPCTSTR% pszFileName, int nIconIndex, int cxIcon, int cyIcon,
                                HICON *phicon, UINT *piconid, UINT nIcons, UINT flags);
SHSTDAPI SHGetAssociations(LPCITEMIDLIST pidl, void **ppvQueryAssociations);

#define SHLookupIconIndexAORD   7
#define SHLookupIconIndexWORD   8
#ifdef UNICODE
#define SHLookupIconIndexORD    SHLookupIconIndexWORD
#else
#define SHDefExtractIcon    SHDefExtractIconA
#endif


// BUGBUG (scotth): temporary.  move to shdocvw.
// OpenAsInfo flags
#define OAIF_ALLOW_REGISTRATION     0x00000001      // enable the "always use this file" checkbox (NOTE if you dont pass this, it will be disabled)
#define OAIF_REGISTER_EXT           0x00000002      // do the registration after the user hits "ok"
#define OAIF_EXEC                   0x00000004      // execute file after registering
#define OAIF_FORCE_REGISTRATION     0x00000008      // force the "always use this file" checkbox to be checked (normally, you wont use the OAIF_ALLOW_REGISTRATION wen you pass this)
#define OAIF_ALL                    (OAIF_ALLOW_REGISTRATION | OAIF_REGISTER_EXT | OAIF_EXEC | OAIF_FORCE_REGISTRATION)  // ;internal

#include <pshpack8.h>

typedef struct _openasinfo
{
    LPCTSTR pcszFile;           // [in] file name
    LPCTSTR pcszClass;          // [in] file class description.  NULL means
                                //      use pcszFile's extension
    DWORD dwInFlags;            // [in] input flags from OAIF_*

    TCHAR szApp[MAX_PATH];      // [out] application selected
} OPENASINFO, * POPENASINFO;

#include <poppack.h>        /* Return to byte packing */

SHSTDAPI OpenAsDialog(HWND hwnd, POPENASINFO poainfo);

//
// Interface pointer validation
//
#define IsBadInterfacePtr(pitf, ITF)  SHIsBadInterfacePtr(pitf, sizeof(ITF##Vtbl))

//===========================================================================
// Another block of private API
//===========================================================================

// indexes into the shell image lists (Shell_GetImageList) for default images
// If you add to this list, you also need to update II_LASTSYSICON!

#define II_DOCNOASSOC         0  // document (blank page) (not associated)
#define II_DOCUMENT           1  // document (with stuff on the page)
#define II_APPLICATION        2  // application (exe, com, bat)
#define II_FOLDER             3  // folder (plain)
#define II_FOLDEROPEN         4  // folder (open)
#define II_DRIVE525           5
#define II_DRIVE35            6
#define II_DRIVEREMOVE        7
#define II_DRIVEFIXED         8
#define II_DRIVENET           9
#define II_DRIVENETDISABLED  10
#define II_DRIVECD           11
#define II_DRIVERAM          12
#define II_WORLD             13
#define II_NETWORK           14
#define II_SERVER            15
#define II_PRINTER           16
#define II_MYNETWORK         17
#define II_GROUP             18
// Startmenu images.
#define II_STPROGS           19
#define II_STDOCS            20
#define II_STSETNGS          21
#define II_STFIND            22
#define II_STHELP            23
#define II_STRUN             24
#define II_STSUSPEND         25
#define II_STEJECT           26
#define II_STSHUTD           27

#define II_SHARE             28
#define II_LINK              29
#define II_SLOWFILE          30
#define II_RECYCLER          31
#define II_RECYCLERFULL      32
#define II_RNA               33
#define II_DESKTOP           34

// More startmenu image.
#define II_STCPANEL          35
#define II_STSPROGS          36
#define II_STPRNTRS          37
#define II_STFONTS           38
#define II_STTASKBR          39

#define II_CDAUDIO           40
#define II_TREE              41
#define II_STCPROGS          42
#define II_STFAVORITES       43
#define II_STLOGOFF          44
#define II_STFLDRPROP        45
#define II_WINUPDATE         46

#define II_MU_STSECURITY     47
#define II_MU_STDISCONN      48

#ifdef WINNT // hydra specific id
#define II_LASTSYSICON       II_MU_STDISCONN
#else
// Last system image list icon index - used by icon cache manager
#define II_LASTSYSICON       II_WINUPDATE
#endif

// Overlay indexes
#define II_OVERLAYFIRST      II_SHARE
#define II_OVERLAYLAST       II_SLOWFILE

#define II_NDSCONTAINER      72
#define II_SERVERSHARE       73

SHSTDAPI_(BOOL) FileIconInit( BOOL fRestoreCache );

// DOC'ed for DOJ compliance
;end_internal
SHSTDAPI_(BOOL) Shell_GetImageLists(HIMAGELIST *phiml, HIMAGELIST *phimlSmall);
;begin_internal
SHSTDAPI_(void) Shell_SysColorChange(void);
// DOC'ed for DOJ compliance
;end_internal
SHSTDAPI_(int)  Shell_GetCachedImageIndex(LPCWSTR pszIconPath, int iIconIndex, UINT uIconFlags);
;begin_internal

//
// OLE string
//
SHSTDAPI_(int) OleStrToStrN(LPTSTR, int, LPCOLESTR, int);
SHSTDAPI_(int) StrToOleStrN(LPOLESTR, int, LPCTSTR, int);
SHSTDAPI_(int) OleStrToStr(LPTSTR, LPCOLESTR);
SHSTDAPI_(int) StrToOleStr(LPOLESTR, LPCTSTR);


#define LIPF_ENABLE     0x00000001  // create the object (vs release the object)
#define LIPF_HOLDREF    0x00000002  // hold ref on object after creation (vs release immediately)

typedef struct
{
    CLSID clsid;
    DWORD dwFlags;
} LOADINPROCDATA, *PLOADINPROCDATA;

// Tray CopyData Messages
#define TCDM_APPBAR     0x00000000
#define TCDM_NOTIFY     0x00000001
#define TCDM_LOADINPROC 0x00000002

//
// Private QueryContextMenuFlag passed from Bands
//
#define CMF_BANDCMD      0x00020000     // Install Band Context menu commands

//
// Functions to help the cabinets sync to each other
//  uOptions parameter to SHWaitForFileOpen
//
#define WFFO_WAITTIME 10000L

#define WFFO_ADD        0x0001
#define WFFO_REMOVE     0x0002
#define WFFO_WAIT       0x0004
#define WFFO_SIGNAL     0x0008



//
// NOTES: IShellService is used when we share a service component
//  (which implements a certain interface) among multiple clients
//  (such as IE 3.0 and Explorer). The client always CoCreateInstance
//  it and call SetOwner(this). When the client is going away
//  (typically when the window is closed), it calls SetOwner(NULL)
//  to let the service object releases the reference to the owner
//  object.
//
#undef  INTERFACE
#define INTERFACE   IShellService

DECLARE_INTERFACE_(IShellService, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IShellService specific methods ***
    STDMETHOD(SetOwner)(THIS_ struct IUnknown* punkOwner) PURE;
};


//
// NOTES: IHistSFPrivate is used when manipulating a history IShellFolder object
//      It includes methods for pointing the shell folder at the correct virtual
//      directory.  QIing for IHistSFPrivate also guarantees the pidl format can
//      safely be delved into to access the INTERNET_CACHE_ENTRY_INFO structure
//
#undef  INTERFACE
#define INTERFACE   IHistSFPrivate

DECLARE_INTERFACE_(IHistSFPrivate, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IHistPrivate specific methods ***
    STDMETHOD(SetCachePrefix)(THIS_ LPCWSTR pszCachePrefix) PURE;
    STDMETHOD(SetDomain)(THIS_ LPCWSTR pszDomain) PURE;
    STDMETHOD(WriteHistory)(THIS_ LPCWSTR pszPrefixedUrl, FILETIME ftExpires, FILETIME ftModified, LPITEMIDLIST * ppidlSelect) PURE;
    STDMETHOD(ClearHistory) (THIS) PURE;
};

//
// NOTES:  IShellFolderViewType lets a shell folder support different "views" on
//      its contents (meaning different hierarchical layouts of its data) with
//      the default "view" being the one the shell folder displays normally.
//      This enumerator returns pidls that are special hidden folders at the
//      top level of the shell folder (which are not otherwise enumerated).
#undef  INTERFACE
#define INTERFACE   IShellFolderViewType
DECLARE_INTERFACE_(IShellFolderViewType, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef)  (THIS) PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IShellFolderViewType Methods ***

    // NOTE: "Views" are seen by the user as hidden folders off the
    //       root (represented by pidls).  Whenever appropriate, the
    //       default view (coming off the root folder) is represented
    //       as the NULL *or* empty pidl.

    // EnumViews:
    //   Return an enumerator which will give out one pidl for every extended view.
    STDMETHOD(EnumViews)(THIS_ ULONG grfFlags, IEnumIDList **ppenum) PURE;

    // GetDefaultViewName:
    //   Return the name of the default view.  The names of the other views
    //   can be retrieved by calling GetDisplayNameOf.
    STDMETHOD(GetDefaultViewName)(THIS_ DWORD  uFlags, LPWSTR *ppwszName)      PURE;
    STDMETHOD(GetViewTypeProperties)(THIS_ LPCITEMIDLIST pidl, DWORD *pdwFlags)  PURE;

    // TranslateViewPidl:
    //   Attempt to take a pidl represented in one heirarchical representation of
    //   the shell folder, and find it in a different representation.
    //   pidl should be relative to the root folder.
    //   Remember to ILFree ppidlOut
    STDMETHOD(TranslateViewPidl)(THIS_ LPCITEMIDLIST pidl, LPCITEMIDLIST pidlView, LPITEMIDLIST *ppidlOut) PURE;
};

#define SFVTFLAG_NOTIFY_CREATE  0x00000001
#define SFVTFLAG_NOTIFY_RESORT  0x00000002

//
// NOTES: IShellFolderSearchableCallback allows the searcher to provide
//          callback routines that moniter the search process
//
#undef  INTERFACE
#define INTERFACE IShellFolderSearchableCallback
DECLARE_INTERFACE_(IShellFolderSearchableCallback, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef)  (THIS) PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IShellFolderSearchableCallback Methods ***

    // NOTE: Caller may pass NULL for pVar or pdwFlags as a legal value
    STDMETHOD(RunBegin)(THIS_ DWORD dwReserved) PURE;
    STDMETHOD(RunEnd)(THIS_ DWORD dwReserved) PURE;
};

//
// NOTES: IShellFolderSearchable allows a shell extension to provide a searchable
//        namespace.
#undef  INTERFACE
#define INTERFACE IShellFolderSearchable
DECLARE_INTERFACE_(IShellFolderSearchable, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef)  (THIS) PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IShellFolderSearchable methods ***

    // FindString -
    //  The returned shell folder's enumerator will have any
    //   search hits for the given search string.
    //  As no flags are currently defined, we suggest you pass
    //    NULL as lpdword
    //  punkOnAsyncSearch will be QI'd for IShellFolderSearchableCallback
    STDMETHOD(FindString)(THIS_ LPCWSTR pwszTarget, DWORD *pdwFlags,
                          IUnknown *punkOnAsyncSearch, LPITEMIDLIST *ppidlOut)   PURE;
    // CancelAsyncSearch -
    //   Begins the process of cancelling  any pending
    //    asynchronous search from this pidl.
    //    When the search is actually cancelled, RunEnd will be called
    //   Returns: S_OK => cancelling, S_FALSE => not running
    STDMETHOD(CancelAsyncSearch) (THIS_ LPCITEMIDLIST pidlSearch, DWORD *pdwFlags) PURE;

    // InvalidateSearch -
    //   Makes this pidl no longer a valid portion of the shell folder
    //    also does some cleanup of any databases used in the search and
    //    will cause the eventual release of the IRunHook callback
    //   May cause async search to be cancelled
    STDMETHOD(InvalidateSearch)  (THIS_ LPCITEMIDLIST pidlSearch, DWORD *pdwFlags) PURE;
};

//
// NOTES: IBandSiteHelper is used to let explorer's BandSite implementation,
//  which aggregates shdocvw's BandSite, provide callback hooks for shdocvw
//  to call.
//
#undef  INTERFACE
#define INTERFACE   IBandSiteHelper

DECLARE_INTERFACE_(IBandSiteHelper, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IBandSiteHelper specific methods ***
    STDMETHOD(LoadFromStreamBS)(THIS_ struct IStream* pstm, REFIID riid, void **ppv) PURE;
    STDMETHOD(SaveToStreamBS)(THIS_ struct IUnknown* punk, struct IStream* pstm) PURE;
};

// This private interface is added such that some of the support features that is in
// SHDocvw's Internet explorer frame automation code, that is not part of publicly
// defined interfaces can be used in the Explorer code...
//
// Note: FindCIE4ConnectionPoint was a hack for IE4.  New code should use
//       shlwapi helper functions like IConnectionPoint_Invoke instead.
//

#ifdef __cplusplus
class CIE4ConnectionPoint;
#else
typedef struct CIE4ConnectionPoint CIE4ConnectionPoint;
#endif

#undef  INTERFACE
#define INTERFACE   IExpDispSupport

DECLARE_INTERFACE_(IExpDispSupport, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IExpDispSupport specific methods ***
    STDMETHOD(FindCIE4ConnectionPoint)(THIS_ REFIID riid, CIE4ConnectionPoint **ppccp) PURE;
    STDMETHOD(OnTranslateAccelerator)(THIS_ MSG  *pMsg, DWORD grfModifiers) PURE;
    STDMETHOD(OnInvoke)(THIS_ DISPID dispidMember, REFIID iid, LCID lcid, WORD wFlags, DISPPARAMS *pdispparams,
                        VARIANT *pVarResult, EXCEPINFO *pexcepinfo, UINT *puArgErr) PURE;
};

//
// This interface is related to the above. It contains functions
// that would only be implemented on the WebBrowserOC version if IExpDispSupport.
//
#undef  INTERFACE
#define INTERFACE   IExpDispSupportOC
DECLARE_INTERFACE_(IExpDispSupportOC, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IExpDispSupportOC specific methods ***
    STDMETHOD(OnOnControlInfoChanged)(THIS) PURE;
    STDMETHOD(GetDoVerbMSG)(THIS_ MSG *pMsg) PURE;
};



//===========================================================================
// IConnectionPointCB interface
#undef  INTERFACE
#define INTERFACE  IConnectionPointCB
DECLARE_INTERFACE_(IConnectionPointCB, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IConnectionPointCB Methods ***
    STDMETHOD(OnAdvise) (THIS_ REFIID iid, DWORD cSinks, ULONG_PTR dwCookie) PURE;
    STDMETHOD(OnUnadvise) (THIS_ REFIID iid, DWORD cSinks, ULONG_PTR dwCookie) PURE;

};

//===========================================================================
// IDelegateDropTargetCB interface
//
// This interface is used by CDelegateDropTarget implementation in shdocvw
// to generate an IDropTarget implementation that delegates to different
// IDropTarget implementations depending on the point currently over. The
// implementor of IDelegateDropTargetCB can handle feedback, scrolling,
// hit testing, and returning interfaces for ids returned from hit testing.
//
// GetWindows returns the hwnd to lock and the hwnd to scroll (not necesarily
//            the same window, as you often want to lock the parent of the window
//            you want to scroll)
//
// HitTest    should return an id of the object over as well as
//            uptate UI (highlights, etc). if ppt is NULL
//            that means remove any UI as the drag is terminating.
//            this should be able to handle hittesting on points not
//            even inside hwndScroll.
//
// GetObject  returns an interface for an id returned from HitTest
//
// OnDrop     gives the CB a chance to take action on the drop.
//            returning S_FALSE from this function prevents
//            CDelegateDropTarget from calling pdt->Drop(...).
//
#undef  INTERFACE
#define INTERFACE  IDelegateDropTargetCB
DECLARE_INTERFACE_(IDelegateDropTargetCB, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IDelegateDropTargetCB Methods ***
    STDMETHOD(GetWindows) (THIS_ HWND * phwndLock, HWND * phwndScroll) PURE;
    STDMETHOD(HitTest) (THIS_ LPPOINT ppt, DWORD * pdwId) PURE;
    STDMETHOD(GetObject) (THIS_ DWORD dwId, REFIID riid, void **ppv) PURE;
    STDMETHOD(OnDrop) (THIS_ IDropTarget *pdt, IDataObject *pdtobj, DWORD grfKeyState, POINTL pt, DWORD *pdwEffect) PURE;

};


#ifdef __COMMCTRL_DA_DEFINED__ // we need HDPAs for this interface
//
// IOrderList - for ordering info in favorites/channels
//
// Typical usage is: GetOrderList, AllocOrderItem, insert into correct
// position, SetOrderList, and then FreeOrderList.
//
typedef struct
{
    LPITEMIDLIST    pidl;       // IDlist for this item
    int             nOrder;     // Ordinal indicating user preference
    DWORD           lParam;     // store custom order info.
} ORDERITEM, * PORDERITEM;

// Values for SortOrderList
#define OI_SORTBYNAME       0
#define OI_SORTBYORDINAL    1
#define OI_MERGEBYNAME      2

#undef  INTERFACE
#define INTERFACE  IOrderList
DECLARE_INTERFACE_(IOrderList, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IOrderList Methods ***
    STDMETHOD(GetOrderList)(THIS_ HDPA * phdpa) PURE;
    STDMETHOD(SetOrderList)(THIS_ HDPA hdpa, IShellFolder *psf) PURE;
    STDMETHOD(FreeOrderList)(THIS_ HDPA hdpa) PURE;
    STDMETHOD(SortOrderList)(THIS_ HDPA hdpa, DWORD dw) PURE;
    STDMETHOD(AllocOrderItem)(THIS_ PORDERITEM * ppoi, LPCITEMIDLIST pidl) PURE;
    STDMETHOD(FreeOrderItem)(THIS_ PORDERITEM poi) PURE;
};

#undef  INTERFACE
#define INTERFACE  IOrderList2
DECLARE_INTERFACE_(IOrderList2, IOrderList)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppvObj) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IOrderList Methods ***
    STDMETHOD(GetOrderList)(THIS_ HDPA * phdpa) PURE;           // BUGBUG (lamadio): This assumes Favorites Menu
    STDMETHOD(SetOrderList)(THIS_ HDPA hdpa, IShellFolder *psf) PURE; // BUGBUG (lamadio): This assumes Favorites Menu
    STDMETHOD(FreeOrderList)(THIS_ HDPA hdpa) PURE;
    STDMETHOD(SortOrderList)(THIS_ HDPA hdpa, DWORD dw) PURE;
    STDMETHOD(AllocOrderItem)(THIS_ PORDERITEM * ppoi, LPCITEMIDLIST pidl) PURE;
    STDMETHOD(FreeOrderItem)(THIS_ PORDERITEM poi) PURE;

    // *** IOrderList2
    STDMETHOD(LoadFromStream)(THIS_ IStream* pstm, HDPA* phdpa, IShellFolder* psf) PURE;
    STDMETHOD(SaveToStream)(THIS_ IStream* pstm, HDPA hdpa) PURE;
};

#endif


//===========================================================================
// IShellHTMLWindowSupport private COmWindow interface. This should never be exposed.
typedef struct IHTMLElement IHTMLElement;

#undef  INTERFACE
#define INTERFACE  IShellHTMLWindowSupport
DECLARE_INTERFACE_(IShellHTMLWindowSupport, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    STDMETHOD(ViewReleaseIntelliForms)(THIS) PURE;
    STDMETHOD(ViewReleased)(THIS) PURE;
    STDMETHOD(ViewActivated)(THIS) PURE;
    STDMETHOD(ReadyStateChangedTo)(THIS_ long, IShellView* ) PURE;
    STDMETHOD(CanNavigate)(THIS) PURE;
    STDMETHOD(ActiveElementChanged)(THIS_ IHTMLElement * pHTMLElement) PURE;

};

//===========================================================================
// IShellHTMLWindowSupport2 private COmWindow interface. This should never be exposed.

#undef  INTERFACE
#define INTERFACE  IShellHTMLWindowSupport2
DECLARE_INTERFACE_(IShellHTMLWindowSupport2, IShellHTMLWindowSupport)
{

    STDMETHOD(IsGalleryMeta)(THIS_ BOOL bFlag) PURE;

};


//===========================================================================
// IBandProxy private COmWindow interface. This should never be exposed.
#undef INTERFACE
#define INTERFACE IBandProxy
DECLARE_INTERFACE_(IBandProxy, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IBandProxy Methods ***
    STDMETHOD(SetSite) (THIS_ IUnknown* punkSite) PURE;
    STDMETHOD(CreateNewWindow) (THIS_ IUnknown** ppunk) PURE;
    STDMETHOD(GetBrowserWindow) (THIS_ IUnknown** ppunk) PURE;
    STDMETHOD(IsConnected) (THIS) PURE;
    STDMETHOD(NavigateToPIDL) (THIS_ LPCITEMIDLIST pidl) PURE;
    STDMETHOD(NavigateToURL) (THIS_ LPCWSTR wzUrl, VARIANT * Flags) PURE;
};



//===========================================================================
//
// Make it sure that we include ole2x.h and shlobj.h
//
#if defined(__IOleInPlaceSite_FWD_DEFINED__) && defined(FCIDM_SHVIEWFIRST)

#ifdef HLINK_H

#include <pshpack8.h>

typedef struct {
    HWND _hwnd;
    ITravelLog  *_ptl;
    IHlinkFrame *_phlf;
    IWebBrowser2    *_pautoWB2; // use this to reference _pauto's IWebBrowser2 functions
    IExpDispSupport *_pautoEDS; // use this to reference _pauto's IExpDispSupport functions
    IShellService   *_pautoSS;  // use this to reference _pauto's IShellService functions
    int _eSecureLockIcon;
    DWORD _fCreatingViewWindow :1;
    UINT _uActivateState;   // this is the state we should use when we go active..
                            // this is here so that derived classes can set us for UI or non-UI active

    // The following pidl is used in CBaseBrowser2::GetViewStateStream because
    // at that time, neither _pidlCur nor _pidlPending are initialized.
    LPCITEMIDLIST  _pidlNewShellView;

    IOleCommandTarget* _pctView;

    LPITEMIDLIST _pidlCur;
    IShellView *_psv;
    IShellFolder *_psf; // IShellFolder for _psv (used in CVOCBrowser)
    HWND        _hwndView;
    LPWSTR      _pszTitleCur;

    LPITEMIDLIST _pidlPending;
    IShellView *_psvPending;
    IShellFolder *_psfPending;
    HWND        _hwndViewPending;
    LPWSTR      _pszTitlePending;

    BOOL _fIsViewMSHTML;
    BOOL _fPrivacyImpacted;

} BASEBROWSERDATA, *LPBASEBROWSERDATA;
typedef const BASEBROWSERDATA *LPCBASEBROWSERDATA;

#include <poppack.h>

#else
// so (unref'ed) ifaces will compile (?)
typedef LPVOID BASEBROWSERDATA;
typedef LPCVOID *LPBASEBROWSERDATA;     // BUGBUG LPVOID?
typedef LPCVOID *LPCBASEBROWSERDATA;

#endif // hlink_h

typedef struct _travellog * PTRAVELLOG;

#undef  INTERFACE
#define INTERFACE   IBrowserService

DECLARE_INTERFACE_(IBrowserService, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IBrowserService specific methods ***
    STDMETHOD(GetParentSite)(THIS_ struct IOleInPlaceSite** ppipsite) PURE;
    STDMETHOD(SetTitle)(THIS_ IShellView* psv, LPCWSTR pszName) PURE;
    STDMETHOD(GetTitle)(THIS_ IShellView* psv, LPWSTR pszName, DWORD cchName) PURE;
    STDMETHOD(GetOleObject)(THIS_ struct IOleObject** ppobjv) PURE;

    // think about this one.. I'm not sure we want to expose this -- Chee
    // BUGBUG:: Yep soon we should have interface instead.
    // My impression is that we won't document this whole interface???
    STDMETHOD(GetTravelLog)(THIS_ ITravelLog** pptl) PURE;

    STDMETHOD(ShowControlWindow)(THIS_ UINT id, BOOL fShow) PURE;
    STDMETHOD(IsControlWindowShown)(THIS_ UINT id, BOOL *pfShown) PURE;
    STDMETHOD(IEGetDisplayName)(THIS_ LPCITEMIDLIST pidl, LPWSTR pwszName, UINT uFlags) PURE;
    STDMETHOD(IEParseDisplayName)(THIS_ UINT uiCP, LPCWSTR pwszPath, LPITEMIDLIST * ppidlOut) PURE;
    STDMETHOD(DisplayParseError)(THIS_ HRESULT hres, LPCWSTR pwszPath) PURE;
    STDMETHOD(NavigateToPidl)(THIS_ LPCITEMIDLIST pidl, DWORD grfHLNF) PURE;

    STDMETHOD (SetNavigateState)(THIS_ BNSTATE bnstate) PURE;
    STDMETHOD (GetNavigateState) (THIS_ BNSTATE *pbnstate) PURE;

    STDMETHOD (NotifyRedirect) (THIS_ struct IShellView* psv, LPCITEMIDLIST pidl, BOOL *pfDidBrowse) PURE;
    STDMETHOD (UpdateWindowList) (THIS) PURE;

    STDMETHOD (UpdateBackForwardState) (THIS) PURE;

    STDMETHOD(SetFlags)(THIS_ DWORD dwFlags, DWORD dwFlagMask) PURE;
    STDMETHOD(GetFlags)(THIS_ DWORD *pdwFlags) PURE;

    // Tells if it can navigate now or not.
    STDMETHOD (CanNavigateNow) (THIS) PURE;

    STDMETHOD (GetPidl) (THIS_ LPITEMIDLIST *ppidl) PURE;
    STDMETHOD (SetReferrer) (THIS_ LPITEMIDLIST pidl) PURE;
    STDMETHOD_(DWORD, GetBrowserIndex)(THIS) PURE;
    STDMETHOD (GetBrowserByIndex)(THIS_ DWORD dwID, IUnknown **ppunk) PURE;
    STDMETHOD (GetHistoryObject)(THIS_ IOleObject **ppole, IStream **pstm, IBindCtx **ppbc) PURE;
    STDMETHOD (SetHistoryObject)(THIS_ IOleObject *pole, BOOL fIsLocalAnchor) PURE;

    STDMETHOD (CacheOLEServer)(THIS_ IOleObject *pole) PURE;

    STDMETHOD (GetSetCodePage)(THIS_ VARIANT* pvarIn, VARIANT* pvarOut) PURE;
    STDMETHOD (OnHttpEquiv)(THIS_ IShellView* psv, BOOL fDone, VARIANT* pvarargIn, VARIANT* pvarargOut) PURE;

    STDMETHOD (GetPalette)( THIS_ HPALETTE * hpal ) PURE;

    STDMETHOD (RegisterWindow)(THIS_ BOOL fUnregister, int swc) PURE;

    // Warning!  Do not add any new methods to this interface
    // because IE4 shell32.dll uses it, so changing the interface
    // breaks IE4 interop.
};

#define BSF_REGISTERASDROPTARGET   0x00000001
#define BSF_THEATERMODE            0x00000002
#define BSF_NOLOCALFILEWARNING     0x00000010
#define BSF_UISETBYAUTOMATION      0x00000100
#define BSF_RESIZABLE              0x00000200
#define BSF_CANMAXIMIZE            0x00000400
#define BSF_TOPBROWSER             0x00000800
#define BSF_NAVNOHISTORY           0x00001000
#define BSF_HTMLNAVCANCELED        0x00002000
#define BSF_DONTSHOWNAVCANCELPAGE  0x00004000
#define BSF_SETNAVIGATABLECODEPAGE 0x00008000
#define BSF_DELEGATEDNAVIGATION    0x00010000

#define TRAVELLOG_LOCALANCHOR      0x00000001
#define TRAVELLOG_FORCEUPDATE      0x00000002

#include <pshpack8.h>

typedef struct SToolbarItem {
    IDockingWindow * ptbar;
    BORDERWIDTHS    rcBorderTool;
    LPWSTR          pwszItem;
    BOOL            fShow;
    HMONITOR        hMon;
} TOOLBARITEM, *LPTOOLBARITEM;
#define ITB_VIEW        ((UINT)-1)      // view

#include <poppack.h>   /* Assume byte packing throughout */

struct tagFolderSetData;

// TEMPORARY.  this is so that we don't have to keep writing dummy subs in basesb as we're
// building basesb2
DECLARE_INTERFACE_(IBrowserService2, IBrowserService)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IBrowserService specific methods ***
    // TODO: break into 3 sections (outer, inner, and both/inherit)
    STDMETHOD(GetParentSite)(THIS_ struct IOleInPlaceSite** ppipsite) PURE;
    STDMETHOD(SetTitle)(THIS_ IShellView* psv, LPCWSTR pszName) PURE;
    STDMETHOD(GetTitle)(THIS_ IShellView* psv, LPWSTR pszName, DWORD cchName) PURE;
    STDMETHOD(GetOleObject)(THIS_ struct IOleObject** ppobjv) PURE;

    // think about this one.. I'm not sure we want to expose this -- Chee
    // BUGBUG:: Yep soon we should have interface instead.
    // My impression is that we won't document this whole interface???
    STDMETHOD(GetTravelLog)(THIS_ ITravelLog** pptl) PURE;

    STDMETHOD(ShowControlWindow)(THIS_ UINT id, BOOL fShow) PURE;
    STDMETHOD(IsControlWindowShown)(THIS_ UINT id, BOOL *pfShown) PURE;
    STDMETHOD(IEGetDisplayName)(THIS_ LPCITEMIDLIST pidl, LPWSTR pwszName, UINT uFlags) PURE;
    STDMETHOD(IEParseDisplayName)(THIS_ UINT uiCP, LPCWSTR pwszPath, LPITEMIDLIST * ppidlOut) PURE;
    STDMETHOD(DisplayParseError)(THIS_ HRESULT hres, LPCWSTR pwszPath) PURE;
    STDMETHOD(NavigateToPidl)(THIS_ LPCITEMIDLIST pidl, DWORD grfHLNF) PURE;

    STDMETHOD (SetNavigateState)(THIS_ BNSTATE bnstate) PURE;
    STDMETHOD (GetNavigateState) (THIS_ BNSTATE *pbnstate) PURE;

    STDMETHOD (NotifyRedirect) (THIS_ struct IShellView* psv, LPCITEMIDLIST pidl, BOOL *pfDidBrowse) PURE;
    STDMETHOD (UpdateWindowList) (THIS) PURE;

    STDMETHOD (UpdateBackForwardState) (THIS) PURE;

    STDMETHOD(SetFlags)(THIS_ DWORD dwFlags, DWORD dwFlagMask) PURE;
    STDMETHOD(GetFlags)(THIS_ DWORD *pdwFlags) PURE;

    // Tells if it can navigate now or not.
    STDMETHOD (CanNavigateNow) (THIS) PURE;

    STDMETHOD (GetPidl) (THIS_ LPITEMIDLIST *ppidl) PURE;
    STDMETHOD (SetReferrer) (THIS_ LPITEMIDLIST pidl) PURE;
    STDMETHOD_(DWORD, GetBrowserIndex)(THIS) PURE;
    STDMETHOD (GetBrowserByIndex)(THIS_ DWORD dwID, IUnknown **ppunk) PURE;
    STDMETHOD (GetHistoryObject)(THIS_ IOleObject **ppole, IStream **pstm, IBindCtx **ppbc) PURE;
    STDMETHOD (SetHistoryObject)(THIS_ IOleObject *pole, BOOL fIsLocalAnchor) PURE;

    STDMETHOD (CacheOLEServer)(THIS_ IOleObject *pole) PURE;

    STDMETHOD (GetSetCodePage)(THIS_ VARIANT* pvarIn, VARIANT* pvarOut) PURE;
    STDMETHOD (OnHttpEquiv)(THIS_ IShellView* psv, BOOL fDone, VARIANT* pvarargIn, VARIANT* pvarargOut) PURE;

    STDMETHOD (GetPalette)( THIS_ HPALETTE * hpal ) PURE;

    STDMETHOD (RegisterWindow)(THIS_ BOOL fUnregister, int swc) PURE;

    // Stuff added for shbrowse->shbrows2 split
    // These remove "friend" functions and classes
    //
    STDMETHOD_(LRESULT, WndProcBS)(THIS_ HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) PURE;

    STDMETHOD (SetAsDefFolderSettings)(THIS) PURE;
    STDMETHOD (GetViewRect)(THIS_ RECT * prc) PURE;

    STDMETHOD (OnSize)(THIS_ WPARAM wParam) PURE;
    STDMETHOD (OnCreate)(THIS_ LPCREATESTRUCT pcs) PURE;
    STDMETHOD_(LRESULT, OnCommand)(THIS_ WPARAM wParam, LPARAM lParam) PURE;
    STDMETHOD (OnDestroy)(THIS ) PURE;
    STDMETHOD_(LRESULT, OnNotify)(THIS_ NMHDR * pnm) PURE;
    STDMETHOD (OnSetFocus)(THIS ) PURE;
    STDMETHOD (OnFrameWindowActivateBS)(THIS_ BOOL fActive) PURE;

    STDMETHOD (ReleaseShellView)(THIS ) PURE;
    STDMETHOD (ActivatePendingView)(THIS ) PURE;
    STDMETHOD (CreateViewWindow)(THIS_ IShellView* psvNew, IShellView* psvOld, LPRECT prcView, HWND* phwnd) PURE;
    STDMETHOD (CreateBrowserPropSheetExt)(THIS_ REFIID riid, void **ppv) PURE;

    // these could be base browser only interfaces
    // they are not overridden by anyone, and perhaps only there for the aggregators to get info from the
    // aggregatee. NOTE: where basesb calls these,
    // it does NOT go through _pbsOuter
    STDMETHOD (GetViewWindow)(THIS_ HWND * phwndView) PURE;
    STDMETHOD (GetBaseBrowserData)(THIS_ LPCBASEBROWSERDATA * pbbd) PURE;
    STDMETHOD_(LPBASEBROWSERDATA, PutBaseBrowserData)(THIS) PURE;
    STDMETHOD (InitializeTravelLog)(THIS_ ITravelLog* ptl, DWORD dw) PURE;
    STDMETHOD (SetTopBrowser)(THIS) PURE;
    STDMETHOD (Offline)(THIS_ int iCmd) PURE;
    STDMETHOD (AllowViewResize)(THIS_ BOOL f) PURE;
    STDMETHOD (SetActivateState)(THIS_ UINT u) PURE;
    STDMETHOD (UpdateSecureLockIcon)(THIS_ int eSecureLock) PURE;
    STDMETHOD (InitializeDownloadManager)(THIS) PURE;
    STDMETHOD (InitializeTransitionSite)(THIS) PURE;
    STDMETHOD (_Initialize)(THIS_ HWND hwnd, IUnknown *pauto) PURE;


    // BEGIN REVIEW:  review names and need of each.
    //
    // this first set could be basebrowser only members.  no one overrides
    // NOTE: where basesb calls these, it does NOT go throug _pbsOuter
    STDMETHOD (_CancelPendingNavigationAsync)(THIS) PURE;
    STDMETHOD (_CancelPendingView)(THIS) PURE;
    STDMETHOD (_MaySaveChanges)(THIS) PURE;
    STDMETHOD (_PauseOrResumeView)(THIS_ BOOL fPaused) PURE;
    STDMETHOD (_DisableModeless)(THIS) PURE;

    // rethink these... are all of these necessary?
    STDMETHOD (_NavigateToPidl)(THIS_ LPCITEMIDLIST pidl, DWORD grfHLNF, DWORD dwFlags)PURE;
    STDMETHOD (_TryShell2Rename)(THIS_ IShellView* psv, LPCITEMIDLIST pidlNew)PURE;
    STDMETHOD (_SwitchActivationNow)(THIS )PURE;

    // this set is overridden and called thru _pbsOuter (and SUPER:_pbsInner)
    STDMETHOD (_ExecChildren)(THIS_ IUnknown *punkBar, BOOL fBroadcast,
                              const GUID *pguidCmdGroup, DWORD nCmdID, DWORD nCmdexecopt,
                              VARIANTARG *pvarargIn, VARIANTARG *pvarargOut)PURE;
    STDMETHOD (_SendChildren)(THIS_ HWND hwndBar, BOOL fBroadcast,
        UINT uMsg, WPARAM wParam, LPARAM lParam) PURE;

    //END REVIEW:

    // querying from the outer.
    STDMETHOD (GetFolderSetData)(THIS_ struct tagFolderSetData* pfsd) PURE;

    // Toolbar stuff is here temporarily. Eventually it will move out
    // of basesb into commonsb, so I'm keeping the underscore "_"
    // Except those noted below, none of these are overridden by
    // outer guys, so no calls are made through _pbsOuter
    STDMETHOD (_OnFocusChange)(THIS_ UINT itb) PURE;
    STDMETHOD (v_ShowHideChildWindows)(THIS_ BOOL fChildOnly) PURE; // NOTE: overridden and called thru _pbsOuter
    STDMETHOD_(UINT,_get_itbLastFocus)(THIS) PURE;
    STDMETHOD (_put_itbLastFocus)(THIS_ UINT itbLastFocus) PURE;
    STDMETHOD (_UIActivateView)(THIS_ UINT uState) PURE;

    // Check the following functions
    STDMETHOD (_GetViewBorderRect)(THIS_ RECT* prc) PURE;
    STDMETHOD (_UpdateViewRectSize)(THIS) PURE;
    STDMETHOD (_ResizeNextBorder)(THIS_ UINT itb) PURE;
    STDMETHOD (_ResizeView)(THIS) PURE;

    STDMETHOD (_GetEffectiveClientArea)(THIS_ LPRECT lprectBorder, HMONITOR hmon) PURE;

    // Desktop needs to override this from commonsb
    STDMETHOD_(IStream*,v_GetViewStream)(THIS_ LPCITEMIDLIST pidl, DWORD grfMode, LPCWSTR pwszName) PURE;

    // Desktop needs access to these commonsb functions, they are not overridden:
    STDMETHOD_(LRESULT,ForwardViewMsg)(THIS_ UINT uMsg, WPARAM wParam, LPARAM lParam) PURE;
    STDMETHOD (SetAcceleratorMenu)(THIS_ HACCEL hacc) PURE;
    STDMETHOD_(int,_GetToolbarCount)(THIS) PURE;
    STDMETHOD_(LPTOOLBARITEM,_GetToolbarItem)(THIS_ int itb) PURE;
    STDMETHOD (_SaveToolbars)(THIS_ IStream* pstm) PURE;
    STDMETHOD (_LoadToolbars)(THIS_ IStream* pstm) PURE;
    STDMETHOD (_CloseAndReleaseToolbars)(THIS_ BOOL fClose) PURE;
    STDMETHOD (v_MayGetNextToolbarFocus)(THIS_ LPMSG lpMsg, UINT itbNext, int citb, LPTOOLBARITEM * pptbi, HWND * phwnd) PURE;
    STDMETHOD (_ResizeNextBorderHelper)(THIS_ UINT itb, BOOL bUseHmonitor) PURE;
    STDMETHOD_(UINT,_FindTBar)(THIS_ IUnknown* punkSrc) PURE;
    STDMETHOD (_SetFocus)(THIS_ LPTOOLBARITEM ptbi, HWND hwnd, LPMSG lpMsg) PURE;
    STDMETHOD (v_MayTranslateAccelerator)(THIS_ MSG* pmsg) PURE;
    STDMETHOD (_GetBorderDWHelper)(THIS_ IUnknown* punkSrc, LPRECT lprectBorder, BOOL bUseHmonitor) PURE;

    // Shell browser needs to override this from basesb.

    STDMETHOD (v_CheckZoneCrossing)(THIS_ LPCITEMIDLIST pidl) PURE;
};

DECLARE_INTERFACE_(IBrowserService3, IBrowserService2)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IBrowserService specific methods ***
    // TODO: break into 3 sections (outer, inner, and both/inherit)
    STDMETHOD(GetParentSite)(THIS_ struct IOleInPlaceSite** ppipsite) PURE;
    STDMETHOD(SetTitle)(THIS_ IShellView* psv, LPCWSTR pszName) PURE;
    STDMETHOD(GetTitle)(THIS_ IShellView* psv, LPWSTR pszName, DWORD cchName) PURE;
    STDMETHOD(GetOleObject)(THIS_ struct IOleObject** ppobjv) PURE;

    // think about this one.. I'm not sure we want to expose this -- Chee
    // BUGBUG:: Yep soon we should have interface instead.
    // My impression is that we won't document this whole interface???
    STDMETHOD(GetTravelLog)(THIS_ ITravelLog** pptl) PURE;

    STDMETHOD(ShowControlWindow)(THIS_ UINT id, BOOL fShow) PURE;
    STDMETHOD(IsControlWindowShown)(THIS_ UINT id, BOOL *pfShown) PURE;
    STDMETHOD(IEGetDisplayName)(THIS_ LPCITEMIDLIST pidl, LPWSTR pwszName, UINT uFlags) PURE;
    STDMETHOD(IEParseDisplayName)(THIS_ UINT uiCP, LPCWSTR pwszPath, LPITEMIDLIST * ppidlOut) PURE;
    STDMETHOD(DisplayParseError)(THIS_ HRESULT hres, LPCWSTR pwszPath) PURE;
    STDMETHOD(NavigateToPidl)(THIS_ LPCITEMIDLIST pidl, DWORD grfHLNF) PURE;

    STDMETHOD (SetNavigateState)(THIS_ BNSTATE bnstate) PURE;
    STDMETHOD (GetNavigateState) (THIS_ BNSTATE *pbnstate) PURE;

    STDMETHOD (NotifyRedirect) (THIS_ struct IShellView* psv, LPCITEMIDLIST pidl, BOOL *pfDidBrowse) PURE;
    STDMETHOD (UpdateWindowList) (THIS) PURE;

    STDMETHOD (UpdateBackForwardState) (THIS) PURE;

    STDMETHOD(SetFlags)(THIS_ DWORD dwFlags, DWORD dwFlagMask) PURE;
    STDMETHOD(GetFlags)(THIS_ DWORD *pdwFlags) PURE;

    // Tells if it can navigate now or not.
    STDMETHOD (CanNavigateNow) (THIS) PURE;

    STDMETHOD (GetPidl) (THIS_ LPITEMIDLIST *ppidl) PURE;
    STDMETHOD (SetReferrer) (THIS_ LPITEMIDLIST pidl) PURE;
    STDMETHOD_(DWORD, GetBrowserIndex)(THIS) PURE;
    STDMETHOD (GetBrowserByIndex)(THIS_ DWORD dwID, IUnknown **ppunk) PURE;
    STDMETHOD (GetHistoryObject)(THIS_ IOleObject **ppole, IStream **pstm, IBindCtx **ppbc) PURE;
    STDMETHOD (SetHistoryObject)(THIS_ IOleObject *pole, BOOL fIsLocalAnchor) PURE;

    STDMETHOD (CacheOLEServer)(THIS_ IOleObject *pole) PURE;

    STDMETHOD (GetSetCodePage)(THIS_ VARIANT* pvarIn, VARIANT* pvarOut) PURE;
    STDMETHOD (OnHttpEquiv)(THIS_ IShellView* psv, BOOL fDone, VARIANT* pvarargIn, VARIANT* pvarargOut) PURE;

    STDMETHOD (GetPalette)( THIS_ HPALETTE * hpal ) PURE;

    STDMETHOD (RegisterWindow)(THIS_ BOOL fUnregister, int swc) PURE;

    // Stuff added for shbrowse->shbrows2 split
    // These remove "friend" functions and classes
    //
    STDMETHOD_(LRESULT, WndProcBS)(THIS_ HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) PURE;

    STDMETHOD (SetAsDefFolderSettings)(THIS) PURE;
    STDMETHOD (GetViewRect)(THIS_ RECT * prc) PURE;

    STDMETHOD (OnSize)(THIS_ WPARAM wParam) PURE;
    STDMETHOD (OnCreate)(THIS_ LPCREATESTRUCT pcs) PURE;
    STDMETHOD_(LRESULT, OnCommand)(THIS_ WPARAM wParam, LPARAM lParam) PURE;
    STDMETHOD (OnDestroy)(THIS ) PURE;
    STDMETHOD_(LRESULT, OnNotify)(THIS_ NMHDR * pnm) PURE;
    STDMETHOD (OnSetFocus)(THIS ) PURE;
    STDMETHOD (OnFrameWindowActivateBS)(THIS_ BOOL fActive) PURE;

    STDMETHOD (ReleaseShellView)(THIS ) PURE;
    STDMETHOD (ActivatePendingView)(THIS ) PURE;
    STDMETHOD (CreateViewWindow)(THIS_ IShellView* psvNew, IShellView* psvOld, LPRECT prcView, HWND* phwnd) PURE;
    STDMETHOD (CreateBrowserPropSheetExt)(THIS_ REFIID riid, void **ppv) PURE;

    // these could be base browser only interfaces
    // they are not overridden by anyone, and perhaps only there for the aggregators to get info from the
    // aggregatee. NOTE: where basesb calls these,
    // it does NOT go through _pbsOuter
    STDMETHOD (GetViewWindow)(THIS_ HWND * phwndView) PURE;
    STDMETHOD (GetBaseBrowserData)(THIS_ LPCBASEBROWSERDATA * pbbd) PURE;
    STDMETHOD_(LPBASEBROWSERDATA, PutBaseBrowserData)(THIS) PURE;
    STDMETHOD (InitializeTravelLog)(THIS_ ITravelLog* ptl, DWORD dw) PURE;
    STDMETHOD (SetTopBrowser)(THIS) PURE;
    STDMETHOD (Offline)(THIS_ int iCmd) PURE;
    STDMETHOD (AllowViewResize)(THIS_ BOOL f) PURE;
    STDMETHOD (SetActivateState)(THIS_ UINT u) PURE;
    STDMETHOD (UpdateSecureLockIcon)(THIS_ int eSecureLock) PURE;
    STDMETHOD (InitializeDownloadManager)(THIS) PURE;
    STDMETHOD (InitializeTransitionSite)(THIS) PURE;
    STDMETHOD (_Initialize)(THIS_ HWND hwnd, IUnknown *pauto) PURE;


    // BEGIN REVIEW:  review names and need of each.
    //
    // this first set could be basebrowser only members.  no one overrides
    // NOTE: where basesb calls these, it does NOT go throug _pbsOuter
    STDMETHOD (_CancelPendingNavigationAsync)(THIS) PURE;
    STDMETHOD (_CancelPendingView)(THIS) PURE;
    STDMETHOD (_MaySaveChanges)(THIS) PURE;
    STDMETHOD (_PauseOrResumeView)(THIS_ BOOL fPaused) PURE;
    STDMETHOD (_DisableModeless)(THIS) PURE;

    // rethink these... are all of these necessary?
    STDMETHOD (_NavigateToPidl)(THIS_ LPCITEMIDLIST pidl, DWORD grfHLNF, DWORD dwFlags)PURE;
    STDMETHOD (_TryShell2Rename)(THIS_ IShellView* psv, LPCITEMIDLIST pidlNew)PURE;
    STDMETHOD (_SwitchActivationNow)(THIS )PURE;

    // this set is overridden and called thru _pbsOuter (and SUPER:_pbsInner)
    STDMETHOD (_ExecChildren)(THIS_ IUnknown *punkBar, BOOL fBroadcast,
                              const GUID *pguidCmdGroup, DWORD nCmdID, DWORD nCmdexecopt,
                              VARIANTARG *pvarargIn, VARIANTARG *pvarargOut)PURE;
    STDMETHOD (_SendChildren)(THIS_ HWND hwndBar, BOOL fBroadcast,
        UINT uMsg, WPARAM wParam, LPARAM lParam) PURE;

    //END REVIEW:

    // querying from the outer.
    STDMETHOD (GetFolderSetData)(THIS_ struct tagFolderSetData* pfsd) PURE;

    // Toolbar stuff is here temporarily. Eventually it will move out
    // of basesb into commonsb, so I'm keeping the underscore "_"
    // Except those noted below, none of these are overridden by
    // outer guys, so no calls are made through _pbsOuter
    STDMETHOD (_OnFocusChange)(THIS_ UINT itb) PURE;
    STDMETHOD (v_ShowHideChildWindows)(THIS_ BOOL fChildOnly) PURE; // NOTE: overridden and called thru _pbsOuter
    STDMETHOD_(UINT,_get_itbLastFocus)(THIS) PURE;
    STDMETHOD (_put_itbLastFocus)(THIS_ UINT itbLastFocus) PURE;
    STDMETHOD (_UIActivateView)(THIS_ UINT uState) PURE;

    // Check the following functions
    STDMETHOD (_GetViewBorderRect)(THIS_ RECT* prc) PURE;
    STDMETHOD (_UpdateViewRectSize)(THIS) PURE;
    STDMETHOD (_ResizeNextBorder)(THIS_ UINT itb) PURE;
    STDMETHOD (_ResizeView)(THIS) PURE;

    STDMETHOD (_GetEffectiveClientArea)(THIS_ LPRECT lprectBorder, HMONITOR hmon) PURE;

    // Desktop needs to override this from commonsb
    STDMETHOD_(IStream*,v_GetViewStream)(THIS_ LPCITEMIDLIST pidl, DWORD grfMode, LPCWSTR pwszName) PURE;

    // Desktop needs access to these commonsb functions, they are not overridden:
    STDMETHOD_(LRESULT,ForwardViewMsg)(THIS_ UINT uMsg, WPARAM wParam, LPARAM lParam) PURE;
    STDMETHOD (SetAcceleratorMenu)(THIS_ HACCEL hacc) PURE;
    STDMETHOD_(int,_GetToolbarCount)(THIS) PURE;
    STDMETHOD_(LPTOOLBARITEM,_GetToolbarItem)(THIS_ int itb) PURE;
    STDMETHOD (_SaveToolbars)(THIS_ IStream* pstm) PURE;
    STDMETHOD (_LoadToolbars)(THIS_ IStream* pstm) PURE;
    STDMETHOD (_CloseAndReleaseToolbars)(THIS_ BOOL fClose) PURE;
    STDMETHOD (v_MayGetNextToolbarFocus)(THIS_ LPMSG lpMsg, UINT itbNext, int citb, LPTOOLBARITEM * pptbi, HWND * phwnd) PURE;
    STDMETHOD (_ResizeNextBorderHelper)(THIS_ UINT itb, BOOL bUseHmonitor) PURE;
    STDMETHOD_(UINT,_FindTBar)(THIS_ IUnknown* punkSrc) PURE;
    STDMETHOD (_SetFocus)(THIS_ LPTOOLBARITEM ptbi, HWND hwnd, LPMSG lpMsg) PURE;
    STDMETHOD (v_MayTranslateAccelerator)(THIS_ MSG* pmsg) PURE;
    STDMETHOD (_GetBorderDWHelper)(THIS_ IUnknown* punkSrc, LPRECT lprectBorder, BOOL bUseHmonitor) PURE;

    // Shell browser needs to override this from basesb.

    STDMETHOD (v_CheckZoneCrossing)(THIS_ LPCITEMIDLIST pidl) PURE;

    // IBrowserService3
    STDMETHOD (_PositionViewWindow)(THIS_ HWND hwnd, LPRECT prc) PURE; // this was virtual in basesb/shbrowse, but missed this interface!
};

typedef enum
{
    NAVDATA_DONTUPDATETRAVELLOG = 0x00000001,
    NAVDATA_FRAMEWINDOW         = 0x00000002,
    NAVDATA_FRAMECREATION       = 0x00000004,
    NAVDATA_RESTARTLOAD         = 0x00000008,

} ENUMNAVDATA;

typedef struct IHTMLWindow2 IHTMLWindow2;

#undef  INTERFACE
#define INTERFACE    ITridentService

DECLARE_INTERFACE_(ITridentService, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** ITridentService specific methods ***
    STDMETHOD(FireBeforeNavigate2)(THIS_
                                   IDispatch * pDispatch,
                                   LPCTSTR     lpszUrl,
                                   DWORD       dwFlags,
                                   LPCTSTR     lpszFrameName,
                                   LPBYTE      pPostData,
                                   DWORD       cbPostData,
                                   LPCTSTR     lpszHeaders,
                                   BOOL        fPlayNavSound,
                                   BOOL      * pfCancel) PURE;
    STDMETHOD(FireNavigateComplete2)(THIS_ IHTMLWindow2 * pHTMLWindow2,
                                     DWORD          dwFlags) PURE;
    STDMETHOD(FireDownloadBegin)(THIS) PURE;
    STDMETHOD(FireDownloadComplete)(THIS) PURE;
    STDMETHOD(FireDocumentComplete)(THIS_
                                    IHTMLWindow2 * pHTMLWindow,
                                    DWORD          dwFlags) PURE;
    STDMETHOD(UpdateDesktopComponent)(THIS_ IHTMLWindow2 * pHTMLWindow) PURE;
    STDMETHOD(GetPendingUrl)(THIS_ BSTR * pbstrPendingUrl) PURE;
    STDMETHOD(ActiveElementChanged)(THIS_ IHTMLElement * pHTMLElement) PURE;
    STDMETHOD(GetUrlSearchComponent)(THIS_ BSTR * pbstrSearch) PURE;
    STDMETHOD(IsErrorUrl)(THIS_ LPCTSTR lpszUrl, BOOL *pfIsError) PURE;
};

#undef  INTERFACE
#define INTERFACE    ITridentService2

DECLARE_INTERFACE_(ITridentService2, ITridentService)
{
    // *** ITridentService2 methods ***
    STDMETHOD(AttachMyPics)(THIS_ void *pDoc2, void **ppMyPics) PURE;
    STDMETHOD_(BOOL,ReleaseMyPics)(THIS_ void *pMyPics) PURE;
    STDMETHOD(IsGalleryMeta)(THIS_ BOOL bFlag, void *pMyPics) PURE;
    STDMETHOD(EmailPicture)(THIS_ BSTR bstrURL) PURE;

    STDMETHOD(FireNavigateError)(THIS_  IHTMLWindow2 * pHTMLWindow2,
                                 BSTR   bstrURL,
                                 BSTR   bstrTargetFrameName,
                                 DWORD  dwStatusCode,
                                 BOOL * pfCancel) PURE;

    STDMETHOD(FirePrintTemplateEvent)(THIS_ IHTMLWindow2 * pHTMLWindow2,
                                      DISPID dispidPrintEvent) PURE;
    STDMETHOD(FireUpdatePageStatus)(THIS_ IHTMLWindow2 * pHTMLWindow2,
                                    DWORD nPage,
                                    BOOL fDone) PURE;
    STDMETHOD(FirePrivacyImpactedStateChange)(THIS_ BOOL bPrivacyImpacted) PURE;
    STDMETHOD(InitAutoImageResize)(THIS) PURE;
    STDMETHOD(UnInitAutoImageResize)(THIS) PURE;
};


#undef  INTERFACE
#define INTERFACE    IWebBrowserPriv

DECLARE_INTERFACE_(IWebBrowserPriv, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IWebBrowserPriv specific methods ***
    STDMETHOD(NavigateWithBindCtx)(THIS_ VARIANT *pvarUrl,
                                   VARIANT  *pvarFlags,
                                   VARIANT  *pvarTargetFrameName,
                                   VARIANT  *pvarPostData,
                                   VARIANT  *pvarHeaders,
                                   IBindCtx    * pBindCtx,
                                   BSTR          bstrLocation) PURE;
    STDMETHOD(OnClose)(THIS) PURE;
};

// these MUST be listed in  the same order a c_szPropNames in deskbar.cpp
typedef enum {
    PROPDATA_SIDE = 0,
    PROPDATA_MODE,
    PROPDATA_LEFT,
    PROPDATA_TOP,
    PROPDATA_RIGHT,
    PROPDATA_BOTTOM,
    PROPDATA_DELETEABLE,
    PROPDATA_X,
    PROPDATA_Y,
    PROPDATA_CX,
    PROPDATA_CY,

    PROPDATA_COUNT
} ENUMPROPDATA ;

// PROPDATA_MODE values:
//  (aka. WBM_* -- webbar modes (_eMode))
#define WBM_BOTTOMMOST  ((UINT) 0x0)      // bottommost
#define WBM_TOPMOST     ((UINT) 0x1)      // topmost
#define WBM_FLOATING    ((UINT) 0x2)      // floating
#define WBM_NIL         ((UINT) 0x7)      // nil

#undef  INTERFACE
#define INTERFACE  IDockingBarPropertyBagInit
DECLARE_INTERFACE_(IDockingBarPropertyBagInit, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface)(THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef)(THIS) PURE;
    STDMETHOD_(ULONG,Release)(THIS) PURE;

    // *** IDockingBarPropertyBag ***
    STDMETHOD(SetDataDWORD)(THIS_ ENUMPROPDATA e, DWORD dwData) PURE;
} ;

#if (_WIN32_IE) >= 0x0400
//===========================================================================
// IAddressList private COmWindow interface. This should never be exposed.
#undef INTERFACE
#define INTERFACE IAddressList
DECLARE_INTERFACE_(IAddressList, IWinEventHandler)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IWinEventHandler Methods ***
    STDMETHOD(OnWinEvent) (THIS_ HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam, LRESULT* plres) PURE;
    STDMETHOD(IsWindowOwner) (THIS_ HWND hwnd) PURE;

    // *** IAddressList Methods ***
    STDMETHOD(Connect) (THIS_ BOOL fConnect, HWND hwnd, IBrowserService* pbs, IBandProxy* pbp, IAutoComplete * pac) PURE;
    STDMETHOD(NavigationComplete) (THIS_ void *pvCShellUrl) PURE;
    STDMETHOD(Refresh) (THIS_ DWORD dwType) PURE;
    STDMETHOD(Load) (THIS) PURE;
    STDMETHOD(Save) (THIS) PURE;
    STDMETHOD(SetToListIndex) (THIS_ int nIndex, void *pvShelLUrl) PURE;
    STDMETHOD(FileSysChangeAL) (THIS_ DWORD dw, LPCITEMIDLIST *ppidl) PURE;
};
#endif


// DOC'ed for DOJ compliance
;end_internal

//
// IDocViewSite
//
#undef  INTERFACE
#define INTERFACE  IDocViewSite
DECLARE_INTERFACE_(IDocViewSite, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface)(THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef)(THIS) PURE;
    STDMETHOD_(ULONG,Release)(THIS) PURE;

    // *** IDocViewSite methods ***
    STDMETHOD(OnSetTitle) (THIS_ VARIANTARG *pvTitle) PURE;

} ;
;begin_internal

#endif

//===========================================================================
// IDwnCodePage: This is a private interface to pass codepage info.
#undef INTERFACE
#define INTERFACE IDwnCodePage

DECLARE_INTERFACE_(IDwnCodePage, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IDwnCodePage Methods ***
    STDMETHOD_(UINT,GetCodePage) (THIS) PURE;
    STDMETHOD(SetCodePage) (THIS_ UINT uiCP) PURE;
};

SHSTDAPI SHDllGetClassObject(REFCLSID rclsid, REFIID riid, void **ppv);

//===========================================================================

//----------------------------------------------------------------------------
#define IsLFNDriveORD           119
SHSTDAPI_(int) SHOutOfMemoryMessageBox(HWND hwndOwner, LPTSTR pszTitle, UINT fuStyle);
SHSTDAPI_(BOOL) SHWinHelp(HWND hwndMain, LPCTSTR pszHelp, UINT usCommand, ULONG_PTR ulData);

SHSTDAPI_(BOOL) RLBuildListOfPaths(void);

#ifdef WINNT
SHSTDAPI_(BOOL) RegenerateUserEnvironment(void **pPrevEnv, BOOL bSetCurrentEnv);
#endif

#define SHValidateUNCORD        173

// DOC'ed for DOJ compliance
;end_internal
#define VALIDATEUNC_NOUI        0x0002          // don't bring up UI
#define VALIDATEUNC_CONNECT     0x0001          // connect a drive letter
#define VALIDATEUNC_PRINT       0x0004          // validate as print share instead of disk share
#define VALIDATEUNC_VALID       0x0007          // valid flags

SHSTDAPI_(BOOL) SHValidateUNC(HWND hwndOwner, LPWSTR pszFile, UINT fConnect);
;begin_internal

//----------------------------------------------------------------------------
#define OleStrToStrNORD                         78
#define SHCloneSpecialIDListORD                 89
#define SHDllGetClassObjectORD                 128
#define SHLogILFromFSILORD                      95
#define SHMapPIDLToSystemImageListIndexORD      77
#define SHShellFolderView_MessageORD            73
#define Shell_GetImageListsORD                  71
#define SHGetSpecialFolderPathORD              175
#define StrToOleStrNORD                         79

#define ILCloneORD                              18
#define ILCloneFirstORD                         19
#define ILCombineORD                            25
#define ILCreateFromPathORD                     157
#define ILFindChildORD                          24
#define ILFreeORD                               155
#define ILGetNextORD                            153
#define ILGetSizeORD                            152
#define ILIsEqualORD                            21
#define ILRemoveLastIDORD                       17
#define PathAddBackslashORD                     32
#define PathCombineORD                          37
#define PathIsExeORD                            43
#define PathMatchSpecORD                        46
#define SHGetSetSettingsORD                     68
#define SHILCreateFromPathORD                   28

#define SHFreeORD                               195

#define CheckWinIniForAssocsORD                 711

// DOC'ed for DOJ Compliance
;end_internal
#define OPENPROPS_NONE          0x0000
#define OPENPROPS_INHIBITPIF    0x8000
#define GETPROPS_NONE           0x0000
#define SETPROPS_NONE           0x0000
#define CLOSEPROPS_NONE         0x0000		
#define CLOSEPROPS_DISCARD      0x0001		

#define PIFNAMESIZE     30
#define PIFSTARTLOCSIZE 63
#define PIFDEFPATHSIZE  64
#define PIFPARAMSSIZE   64
#define PIFSHPROGSIZE   64
#define PIFSHDATASIZE   64
#define PIFDEFFILESIZE  80
#define PIFMAXFILEPATH  260

typedef struct PROPPRG {                    /* prg */
    WORD    flPrg;                          // see PRG_ flags
    WORD    flPrgInit;                      // see PRGINIT_ flags
    CHAR    achTitle[PIFNAMESIZE];          // name[30]
    CHAR    achCmdLine[PIFSTARTLOCSIZE+PIFPARAMSSIZE+1];// startfile[63] + params[64]
    CHAR    achWorkDir[PIFDEFPATHSIZE];     // defpath[64]
    WORD    wHotKey;                        // PfHotKeyScan thru PfHotKeyVal
    CHAR    achIconFile[PIFDEFFILESIZE];    // name of file containing icon
    WORD    wIconIndex;                     // index of icon within file
    DWORD   dwEnhModeFlags;                 // reserved enh-mode flags
    DWORD   dwRealModeFlags;                // real-mode flags (see RMOPT_*)
    CHAR    achOtherFile[PIFDEFFILESIZE];   // name of "other" file in directory
    CHAR    achPIFFile[PIFMAXFILEPATH];     // name of PIF file
} PROPPRG;
typedef UNALIGNED PROPPRG *PPROPPRG;
typedef UNALIGNED PROPPRG FAR *LPPROPPRG;
typedef const UNALIGNED PROPPRG FAR *LPCPROPPRG;

SHSTDAPI_(HANDLE) PifMgr_OpenProperties(LPCWSTR pszApp, LPCWSTR pszPIF, UINT hInf, UINT flOpt);
SHSTDAPI_(int)    PifMgr_GetProperties(HANDLE hProps, LPCSTR pszGroup, void *lpProps, int cbProps, UINT flOpt);
SHSTDAPI_(int)    PifMgr_SetProperties(HANDLE hProps, LPCSTR pszGroup, const VOID *lpProps, int cbProps, UINT flOpt);
SHSTDAPI_(HANDLE) PifMgr_CloseProperties(HANDLE hProps, UINT flOpt);

SHSTDAPI_(void) SHSetInstanceExplorer(IUnknown *punk);
;begin_internal


#ifndef WINNT
// Always usr TerminateThreadEx.
BOOL APIENTRY TerminateThreadEx(HANDLE hThread, DWORD dwExitCode, BOOL bCleanupFlag);
#define TerminateThread(hThread, dwExitCode) TerminateThreadEx(hThread, dwExitCode, TRUE)
#endif

// DOC'ed for DOJ Compliance
;end_internal
SHSTDAPI_(BOOL) IsUserAnAdmin(void);
;begin_internal
SHSTDAPI SHCreateSessionKey(REGSAM sam, HKEY *phkOut);

// Sortof Gross but if we pass this flag in with STGM_CREATE we will fail if file already exists
// with ERROR_ALREADY_EXISTS
#define CSOF_FAILIFTHERE         0x80000000L


//===========================================================================
// Structure for covert communication
// between shdocvw's CShellBrowser::Exec()
// and shell32's DefView WM_COMMAND handler

// NOTE: this structure is revealed in the KB
// (articles Q252610 and Q216954).  So even though
// it's in a private section, treat it as public.

struct _DFVCMDDATA
{
    HWND        hwnd;               // Browser hwnd
    VARIANTARG  *pva;               // Args passed to Exec()
    DWORD       nCmdIDTranslated;   // Replacement OLECMDID_* value
};
typedef struct _DFVCMDDATA DFVCMDDATA;
typedef struct _DFVCMDDATA *LPDFVCMDDATA;
typedef const struct _DFVCMDDATA *LPCDFVCMDDATA;


SHSTDAPI_(DWORD) SHGetProcessDword(DWORD idProcess, LONG iIndex);
SHSTDAPI_(BOOL)  SHSetShellWindowEx(HWND hwnd, HWND hwndChild);

#define CCH_MENUMAX     80          // DOC: max size of a menu string


// WinEventHandler message ranges
#define MBHM_FIRST          (0x00000001)    // MenuBandHandler
#define MBHM_LAST           (0x000000ff)

#define MSFM_FIRST          (0x00000100)    // MenuShellFolder
#define MSFM_LAST           (0x000001ff)

#define FSFM_FIRST          (0x00000200)    // FileShellFolder
#define FSFM_LAST           (0x000002ff)



//-------------------------------------------------------------------------
//
// SID_SMenuBandHandler
//
//  The menuband calls QueryService(SID_SMenuBandHandler, IID_IWinEventHandler)
//  on its shellfolder.  If the shellfolder supports this service, the
//  menuband will call the event handler on certain menu events.  These
//  events and messages are as follows:
//
//    MBHM_INITMENUPOPUP    sent when a drop-down menu or submenu is
//                          about to become active.
//
//
//   File-system ShellFolder events:
//
//    FSFM_COMMAND          sent when a file-system item is executed
//
//-------------------------------------------------------------------------

typedef struct tagMBINITMENUPOPUP
{
    DWORD           dwMask;     // MBIMP_*
    IShellFolder *  psf;
    LPCITEMIDLIST   pidl;
    HMENU           hmenu;
    int             iPos;
} MBINITMENUPOPUP;

#define MBIMP_HMENU     0x00000001      // hmenu and iPos are set


// Messages sent to the WinEventHandler         wParam      lParam      *plRet
//                                              ------      ------      ---
#define MBHM_INITMENUPOPUP  (MBHM_FIRST+0)  //  0           MBINITMENUPOPUP *


// Messages sent to the WinEventHandler         wParam      lParam      *plRet
//                                              ------      ------      ------
#define FSFM_COMMAND        (FSFM_FIRST+0)  //  cmd ID      pidl


//-------------------------------------------------------------------------
//
// IAugmentedShellFolder interface
//
//   This provides methods to add multiple Shell Folder objects to a
//  single augmented object (CLSID_AugmentedShellFolder), which will
//  enumerate them as if they were in a single namespace.
//
//
// [Member functions]
//
// IAugmentedShellFolder::AddNameSpace(rguidObject, psf, pidl)
//   Add the object represented by the IShellFolder interface to
//   the augmented list.  The rguidObject is used to identify the
//   given object.  It may be NULL.  The optional pidl refers to
//   the location of the psf.
//
// IAugmentedShellFolder::GetNameSpaceID(pidl, rguidOut)
//   This method returns the rguidObject associated with the given
//   pidl.  This is how a caller can identify which namespace the
//   pidl resides, given the list of IShellFolder objects that were
//   added to this augmented object.
//
// IAugmentedShellFolder::QueryNameSpace(dwNameSpaceID, pguidOut, ppsf)
//   Returns the shellfolder and guid associated with the given ID.
//
// IAugmentedShellFolder::EnumNameSpace(uNameSpace, pdwNameSpaceID)
//   Enumerates the namespace shellfolders.  If uNameSpace is -1,
//   pdwNameSpaceID is ignored and this method returns the count of
//   shellfolders in the augmented namespace.  Call this method with
//   uNameSpace starting at 0 to begin enumerating.  Returns S_OK and
//   and namespace ID in *pdwNameSpaceID.
//
//-------------------------------------------------------------------------

//  IAugmentedShellFolder::AddNameSpace flags
enum
{
    ASFF_DEFAULT                   = 0x00000000, // There are no applicable Flags
    ASFF_SORTDOWN                  = 0x00000001, // Sort the items in this ISF to the bottom.
    ASFF_MERGESAMEGUID             = 0x00000002, // Merge only namespaces with the same pguidObjects
    ASFF_COMMON                    = 0x00000004, // this is a "Common" or "All Users" folder
    // the following should all be collapsed to one ASFF_DEFNAMESPACE
    ASFF_DEFNAMESPACE_BINDSTG      = 0x00000100, // The namespace is the default handler for BindToStorage() for merged child items.
    ASFF_DEFNAMESPACE_COMPARE      = 0x00000200, // The namespace is the default handler for CompareIDs() for merged child items.
    ASFF_DEFNAMESPACE_VIEWOBJ      = 0x00000400, // The namespace is the default handler for CreateViewObject() for merged child items.
    ASFF_DEFNAMESPACE_ATTRIB       = 0x00001800, // The namespace is the default handler for GetAttributesOf() for merged child items.
    ASFF_DEFNAMESPACE_DISPLAYNAME  = 0x00001000, // The namespace is the default handler for GetDisplayNameOf(), SetNameOf() and ParseDisplayName() for merged child items.
    ASFF_DEFNAMESPACE_UIOBJ        = 0x00002000, // The namespace is the default handler for GetUIObjectOf() for merged child items.
    ASFF_DEFNAMESPACE_ITEMDATA     = 0x00004000, // The namespace is the default handler for GetItemData() for merged child items.
    ASFF_DEFNAMESPACE_ALL          = 0x0000FF00  // The namespace is the primary handler for all IShellFolder operations on merged child items.
};

enum QUERYNAMESPACEINFO_MASK
{
    ASFQNSI_FLAGS                  = 0x00000001,
    ASFQNSI_FOLDER                 = 0x00000002,
    ASFQNSI_GUID                   = 0x00000004,
    ASFQNSI_PIDL                   = 0x00000008,
};

#include <pshpack8.h>

typedef struct QUERYNAMESPACEINFO
{
    DWORD cbSize;
    DWORD dwMask;
    DWORD dwFlags;              // ASFF_*
    IShellFolder *psf;
    GUID  guidObject;
    LPITEMIDLIST pidl;
} QUERYNAMESPACEINFO;

#include <poppack.h>        /* Return to byte packing */

#undef  INTERFACE
#define INTERFACE   IAugmentedShellFolder

DECLARE_INTERFACE_(IAugmentedShellFolder, IShellFolder)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface)   (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef)    (THIS) PURE;
    STDMETHOD_(ULONG,Release)   (THIS) PURE;

    // *** IShellFolder methods ***
    STDMETHOD(ParseDisplayName) (THIS_ HWND hwndOwner,LPBC pbc, LPOLESTR pszDisplayName,
                                 ULONG * pchEaten, LPITEMIDLIST * ppidl, ULONG *pdwAttributes) PURE;
    STDMETHOD(EnumObjects)      (THIS_ HWND hwndOwner, DWORD grfFlags, IEnumIDList ** ppenumIDList) PURE;
    STDMETHOD(BindToObject)     (THIS_ LPCITEMIDLIST pidl, LPBC pbc, REFIID riid, void **ppv) PURE;
    STDMETHOD(BindToStorage)    (THIS_ LPCITEMIDLIST pidl, LPBC pbc, REFIID riid, void **ppv) PURE;
    STDMETHOD(CompareIDs)       (THIS_ LPARAM lParam, LPCITEMIDLIST pidl1, LPCITEMIDLIST pidl2) PURE;
    STDMETHOD(CreateViewObject) (THIS_ HWND hwndOwner, REFIID riid, void **ppv) PURE;
    STDMETHOD(GetAttributesOf)  (THIS_ UINT cidl, LPCITEMIDLIST * apidl, ULONG * rgfInOut) PURE;
    STDMETHOD(GetUIObjectOf)    (THIS_ HWND hwndOwner, UINT cidl, LPCITEMIDLIST * apidl,
                                 REFIID riid, UINT * prgfInOut, void **ppv) PURE;
    STDMETHOD(GetDisplayNameOf) (THIS_ LPCITEMIDLIST pidl, DWORD uFlags, LPSTRRET lpName) PURE;
    STDMETHOD(SetNameOf)        (THIS_ HWND hwndOwner, LPCITEMIDLIST pidl,
                                 LPCOLESTR pszName, DWORD uFlags,
                                 LPITEMIDLIST * ppidlOut) PURE;

    // *** IAugmentedShellFolder methods ***
    STDMETHOD(AddNameSpace)     (THIS_ const GUID * pguidObject, IShellFolder * psf,
                                 LPCITEMIDLIST pidl, DWORD dwFlags) PURE;
    STDMETHOD(GetNameSpaceID)   (THIS_ LPCITEMIDLIST pidl, GUID * pguidOut) PURE;
    STDMETHOD(QueryNameSpace)   (THIS_ DWORD dwID, GUID * pguidOut, IShellFolder ** ppsf) PURE;
    STDMETHOD(EnumNameSpace)    (THIS_ DWORD uNameSpace, DWORD * pdwID) PURE;
};

#undef  INTERFACE
#define INTERFACE   IAugmentedShellFolder2

DECLARE_INTERFACE_(IAugmentedShellFolder2, IAugmentedShellFolder)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface)   (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef)    (THIS) PURE;
    STDMETHOD_(ULONG,Release)   (THIS) PURE;

    // *** IShellFolder methods ***
    STDMETHOD(ParseDisplayName) (THIS_ HWND hwndOwner, LPBC pbc, LPOLESTR pszDisplayName,
                                 ULONG * pchEaten, LPITEMIDLIST * ppidl, ULONG *pdwAttributes) PURE;
    STDMETHOD(EnumObjects)      (THIS_ HWND hwndOwner, DWORD grfFlags, IEnumIDList ** ppenumIDList) PURE;
    STDMETHOD(BindToObject)     (THIS_ LPCITEMIDLIST pidl, LPBC pbc, REFIID riid, void **ppv) PURE;
    STDMETHOD(BindToStorage)    (THIS_ LPCITEMIDLIST pidl, LPBC pbc, REFIID riid, void **ppv) PURE;
    STDMETHOD(CompareIDs)       (THIS_ LPARAM lParam, LPCITEMIDLIST pidl1, LPCITEMIDLIST pidl2) PURE;
    STDMETHOD(CreateViewObject) (THIS_ HWND hwndOwner, REFIID riid, void **ppv) PURE;
    STDMETHOD(GetAttributesOf)  (THIS_ UINT cidl, LPCITEMIDLIST * apidl,
                                 ULONG * rgfInOut) PURE;
    STDMETHOD(GetUIObjectOf)    (THIS_ HWND hwndOwner, UINT cidl, LPCITEMIDLIST * apidl,
                                 REFIID riid, UINT * prgfInOut, void **ppv) PURE;
    STDMETHOD(GetDisplayNameOf) (THIS_ LPCITEMIDLIST pidl, DWORD uFlags, LPSTRRET lpName) PURE;
    STDMETHOD(SetNameOf)        (THIS_ HWND hwndOwner, LPCITEMIDLIST pidl,
                                 LPCOLESTR pszName, DWORD uFlags,
                                 LPITEMIDLIST * ppidlOut) PURE;

    // *** IAugmentedShellFolder methods ***
    STDMETHOD(AddNameSpace)     (THIS_ const GUID * pguidObject, IShellFolder * psf,
                                 LPCITEMIDLIST pidl, DWORD dwFlags) PURE;
    STDMETHOD(GetNameSpaceID)   (THIS_ LPCITEMIDLIST pidl, GUID * pguidOut) PURE;
    STDMETHOD(QueryNameSpace)   (THIS_ DWORD dwID, GUID * pguidOut, IShellFolder ** ppsf) PURE;
    STDMETHOD(EnumNameSpace)    (THIS_ DWORD uNameSpace, DWORD * pdwID) PURE;

    // *** IAugmentedShellFolder2 methods ***
    STDMETHOD(UnWrapIDList)       (THIS_ LPCITEMIDLIST pidlWrap, LONG cPidls, IShellFolder ** apsf, LPITEMIDLIST * apidlFolder, LPITEMIDLIST * apidlItems, LONG * pcFetched ) PURE ;
};

#undef  INTERFACE
#define INTERFACE   IAugmentedShellFolder3

DECLARE_INTERFACE_(IAugmentedShellFolder3, IAugmentedShellFolder2)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface)   (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef)    (THIS) PURE;
    STDMETHOD_(ULONG,Release)   (THIS) PURE;

    // *** IShellFolder methods ***
    STDMETHOD(ParseDisplayName) (THIS_ HWND hwndOwner, LPBC pbc, LPOLESTR pszDisplayName,
                                 ULONG * pchEaten, LPITEMIDLIST * ppidl, ULONG *pdwAttributes) PURE;
    STDMETHOD(EnumObjects)      (THIS_ HWND hwndOwner, DWORD grfFlags, IEnumIDList ** ppenumIDList) PURE;
    STDMETHOD(BindToObject)     (THIS_ LPCITEMIDLIST pidl, LPBC pbc, REFIID riid, void **ppv) PURE;
    STDMETHOD(BindToStorage)    (THIS_ LPCITEMIDLIST pidl, LPBC pbc, REFIID riid, void **ppv) PURE;
    STDMETHOD(CompareIDs)       (THIS_ LPARAM lParam, LPCITEMIDLIST pidl1, LPCITEMIDLIST pidl2) PURE;
    STDMETHOD(CreateViewObject) (THIS_ HWND hwndOwner, REFIID riid, void **ppv) PURE;
    STDMETHOD(GetAttributesOf)  (THIS_ UINT cidl, LPCITEMIDLIST * apidl,
                                 ULONG * rgfInOut) PURE;
    STDMETHOD(GetUIObjectOf)    (THIS_ HWND hwndOwner, UINT cidl, LPCITEMIDLIST * apidl,
                                 REFIID riid, UINT * prgfInOut, void **ppv) PURE;
    STDMETHOD(GetDisplayNameOf) (THIS_ LPCITEMIDLIST pidl, DWORD uFlags, LPSTRRET lpName) PURE;
    STDMETHOD(SetNameOf)        (THIS_ HWND hwndOwner, LPCITEMIDLIST pidl,
                                 LPCOLESTR pszName, DWORD uFlags,
                                 LPITEMIDLIST * ppidlOut) PURE;

    // *** IAugmentedShellFolder methods ***
    STDMETHOD(AddNameSpace)     (THIS_ const GUID * pguidObject, IShellFolder * psf,
                                 LPCITEMIDLIST pidl, DWORD dwFlags) PURE;
    STDMETHOD(GetNameSpaceID)   (THIS_ LPCITEMIDLIST pidl, GUID * pguidOut) PURE;
    STDMETHOD(QueryNameSpace)   (THIS_ DWORD dwID, GUID * pguidOut, IShellFolder ** ppsf) PURE;
    STDMETHOD(EnumNameSpace)    (THIS_ DWORD uNameSpace, DWORD * pdwID) PURE;

    // *** IAugmentedShellFolder2 methods ***
    STDMETHOD(UnWrapIDList)       (THIS_ LPCITEMIDLIST pidlWrap, LONG cPidls, IShellFolder ** apsf, LPITEMIDLIST * apidlFolder, LPITEMIDLIST * apidlItems, LONG * pcFetched ) PURE ;

    // *** IAugmentedShellFolder3 methods ***
    STDMETHOD(QueryNameSpace2)  (THIS_ DWORD dwID, QUERYNAMESPACEINFO *pqnsi) PURE;
};


//-------------------------------------------------------------------------
//
// IProxyShellFolder interface
//
//   This provides methods to set a proxy object which can respond
//  to GetUIObjectOf instead of or in addition to the hosted object
//  the supports IShellFolder.  All other methods are forwarded onto
//  the hosted object.  The CLSID_HostProxyShellFolder object implements
//  this interface.
//
//   The Win95 shell does not support aggregation, so this object
//  must be extra careful that it follows the rules of COM.
//
//   This interface is implemented by an object that wishes to provide
//  more support for GetUIObjectOf on behalf of another object that
//  implements an original IShellFolder.
//
// [Member functions]
//
// IProxyShellFolder::InitHostProxy(psf, pidl, punk, dwFlags)
//   Set the object that implements IProxyShellFolder.  Depending
//   on dwFlags, this object will be called instead of or in addition
//   to the host's method.
//
//      SPF_PRIORITY            - call the proxy's method instead of
//                              the host's method.
//      SPF_SECONDARY           - call the proxy's method only if the
//                              host's method doesn't support it.
//      SPF_INHERIT             - create a new object of this class and
//                              hand it back for BindToObject.
//      SPF_FOLDERPRECEDENCE    - have the proxy give folders priority
//                              over files in a call to CompareIDs.
//      SPF_HAVECALLBACK        - have the proxy call the owner's
//                              IOleCommandTarget on each enumerated
//                              object, for filtering.
//
//   Also sets as the host the given object which fully implements
//   IShellFolder.  pidl refers to the shell folder.
//
// IProxyShellFolder::CloneProxyPSF(riid, ppv)
//   Tells the object to clone itself.  The host proxy will call this
//   whenever IShellFolder::BindToObject is called.
//
// IProxyShellFolder::GetUIObjectOfPSF(hwndOwner, cidl, apidl, riid, prgfInOut, ppv)
//   Called by CLSID_HostProxyShellFolder to allow the proxy object
//   an opportunity to respond.
//
// IProxyShellFolder::CreateViewObjectPSF(hwndOwner, riid, ppv)
//   Called by CLSID_HostProxyShellFolder to allow the proxy object
//   an opportunity to respond.
//
//-------------------------------------------------------------------------

// SetProxyObject flags
#define SPF_PRIORITY            0x00000001       // This is mutually exclusive w/ SPF_SECONDARY
#define SPF_SECONDARY           0x00000002
#define SPF_INHERIT             0x00000004
#define SPF_FOLDERPRECEDENCE    0x00000008
#define SPF_HAVECALLBACK        0x00000010

//For filtering of Pidls
#define PHID_FilterOutPidl  0


#undef  INTERFACE
#define INTERFACE   IProxyShellFolder

DECLARE_INTERFACE_(IProxyShellFolder, IShellFolder)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface)   (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef)    (THIS) PURE;
    STDMETHOD_(ULONG,Release)   (THIS) PURE;

    // *** IShellFolder methods ***
    STDMETHOD(ParseDisplayName) (THIS_ HWND hwndOwner, LPBC pbc, LPOLESTR pszDisplayName,
                                 ULONG * pchEaten, LPITEMIDLIST * ppidl, ULONG *pdwAttributes) PURE;
    STDMETHOD(EnumObjects)      (THIS_ HWND hwndOwner, DWORD grfFlags, IEnumIDList ** ppenumIDList) PURE;
    STDMETHOD(BindToObject)     (THIS_ LPCITEMIDLIST pidl, LPBC pbc, REFIID riid, void **ppv) PURE;
    STDMETHOD(BindToStorage)    (THIS_ LPCITEMIDLIST pidl, LPBC pbc, REFIID riid, void **ppv) PURE;
    STDMETHOD(CompareIDs)       (THIS_ LPARAM lParam, LPCITEMIDLIST pidl1, LPCITEMIDLIST pidl2) PURE;
    STDMETHOD(CreateViewObject) (THIS_ HWND hwndOwner, REFIID riid, void **ppv) PURE;
    STDMETHOD(GetAttributesOf)  (THIS_ UINT cidl, LPCITEMIDLIST * apidl,
                                 ULONG * rgfInOut) PURE;
    STDMETHOD(GetUIObjectOf)    (THIS_ HWND hwndOwner, UINT cidl, LPCITEMIDLIST * apidl,
                                 REFIID riid, UINT * prgfInOut, void **ppv) PURE;
    STDMETHOD(GetDisplayNameOf) (THIS_ LPCITEMIDLIST pidl, DWORD uFlags, LPSTRRET lpName) PURE;
    STDMETHOD(SetNameOf)        (THIS_ HWND hwndOwner, LPCITEMIDLIST pidl,
                                 LPCOLESTR pszName, DWORD uFlags,
                                 LPITEMIDLIST * ppidlOut) PURE;

    // *** IProxyShellFolder methods ***
    STDMETHOD(InitHostProxy)     (THIS_ IShellFolder * psf, LPCITEMIDLIST pidl, DWORD dwFlags) PURE;
    STDMETHOD(CloneProxyPSF)     (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD(GetUIObjectOfPSF) (THIS_ HWND hwndOwner, UINT cidl, LPCITEMIDLIST * apidl,
                                 REFIID riid, UINT * prgfInOut, void **ppv) PURE;
    STDMETHOD(CreateViewObjectPSF) (THIS_ HWND hwndOwner, REFIID riid, void **ppv) PURE;

};


//-------------------------------------------------------------------------
//
// BUGBUG (scotth): I don't think we're using this anymore.
//
// ISetWinHandler interface
//
// [Member functions]
//
// ISetWinHandler::SetWindow(hwndOwner)
//   Specifies the window owner.  This may be NULL.
//
// ISetWinHandler::SetWinHandler(punk)
//   Gives a pointer to an object which supports IWinEventHandler.  The
//   hwnd will be the window handle set by the SetWindow method.  The
//   handler should return S_OK if the message is handled, otherwise S_FALSE.
//
//-------------------------------------------------------------------------

#undef  INTERFACE
#define INTERFACE   ISetWinHandler

DECLARE_INTERFACE_(ISetWinHandler, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface)   (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef)    (THIS) PURE;
    STDMETHOD_(ULONG,Release)   (THIS) PURE;

    // *** ISetWinHandler methods ***
    STDMETHOD(SetWindow)        (THIS_ HWND hwndOwner) PURE;
    STDMETHOD(SetWinHandler)    (THIS_ IUnknown * punk) PURE;
};


//-------------------------------------------------------------------------
//
// IMenuShellFolder interface
//
//   This wraps a static HMENU with an IShellFolder interface.
//
//
// [Member functions]
//
// IMenuShellFolder::SetMenu(hmenu)
//   Specifies the hmenu to wrap.  This may be NULL.
//
//   BUGBUG (scotth): does this copy or not?
//
// IMenuShellFolder::GetMenu(phmenu)
//   Returns the current menu in *phmenu.  Returns S_FALSE if no menu is
//   set (*phmenu will be NULL).
//
// IMenuShellFolder::SetWindow(hwndOwner)
//   Specifies the window owner.  This may be NULL.
//
//-------------------------------------------------------------------------

// Messages sent to the WinEventHandler         wParam      lParam      *plRet
//                                              ------      ------      ---
#define MSFM_COMMAND        (MSFM_FIRST+0)  //  cmd ID      0
#define MSFM_ISDROPTARGET   (MSFM_FIRST+1)  //  id          0           1 if yes


#undef  INTERFACE
#define INTERFACE   IMenuShellFolder

DECLARE_INTERFACE_(IMenuShellFolder, IShellFolder)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface)   (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef)    (THIS) PURE;
    STDMETHOD_(ULONG,Release)   (THIS) PURE;

    // *** IShellFolder methods ***
    STDMETHOD(ParseDisplayName) (THIS_ HWND hwndOwner, LPBC pbc, LPOLESTR pszDisplayName,
                                 ULONG * pchEaten, LPITEMIDLIST * ppidl, ULONG *pdwAttributes) PURE;
    STDMETHOD(EnumObjects)      (THIS_ HWND hwndOwner, DWORD grfFlags, IEnumIDList ** ppenumIDList) PURE;
    STDMETHOD(BindToObject)     (THIS_ LPCITEMIDLIST pidl, LPBC pbc, REFIID riid, void **ppv) PURE;
    STDMETHOD(BindToStorage)    (THIS_ LPCITEMIDLIST pidl, LPBC pbc, REFIID riid, void **ppv) PURE;
    STDMETHOD(CompareIDs)       (THIS_ LPARAM lParam, LPCITEMIDLIST pidl1, LPCITEMIDLIST pidl2) PURE;
    STDMETHOD(CreateViewObject) (THIS_ HWND hwndOwner, REFIID riid, void **ppv) PURE;
    STDMETHOD(GetAttributesOf)  (THIS_ UINT cidl, LPCITEMIDLIST * apidl,
                                 ULONG * rgfInOut) PURE;
    STDMETHOD(GetUIObjectOf)    (THIS_ HWND hwndOwner, UINT cidl, LPCITEMIDLIST * apidl,
                                 REFIID riid, UINT * prgfInOut, void **ppv) PURE;
    STDMETHOD(GetDisplayNameOf) (THIS_ LPCITEMIDLIST pidl, DWORD uFlags, LPSTRRET lpName) PURE;
    STDMETHOD(SetNameOf)        (THIS_ HWND hwndOwner, LPCITEMIDLIST pidl,
                                 LPCOLESTR pszName, DWORD uFlags,
                                 LPITEMIDLIST * ppidlOut) PURE;

    // *** IMenuShellFolder methods ***
    STDMETHOD(SetMenu)          (THIS_ HMENU hmenu) PURE;
    STDMETHOD(GetMenu)          (THIS_ HMENU * phmenu) PURE;
    STDMETHOD(SetWindow)        (THIS_ HWND hwndOwner) PURE;
    STDMETHOD(GetWindow)        (THIS_ HWND *phwndOwner) PURE;
    STDMETHOD(GetIDPosition)    (THIS_ LPCITEMIDLIST pidl, int * pnPos) PURE;
};


//-------------------------------------------------------------------------
//
// ITranslateShellChangeNotify interface
//
//   This interface allows an object to translate the pidls that are
// passed to it.
//
// Note:  IE4 had an interface of the same name but with a different IID,
//        so there is no conflict.
//
// [Member functions]
//
// ITranslateShellChangeNotify::TranslateIDs(&lEvent, pidl1, pidl2, ppidlOut1, ppidlOut2)
//   Return converted pidls given the event. it also can change the event if appropriate
//
//-------------------------------------------------------------------------

#undef  INTERFACE
#define INTERFACE   ITranslateShellChangeNotify

DECLARE_INTERFACE_(ITranslateShellChangeNotify, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface)   (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef)    (THIS) PURE;
    STDMETHOD_(ULONG,Release)   (THIS) PURE;

    // *** ITranslateShellChangeNotify methods ***
    STDMETHOD(TranslateIDs) (THIS_ LONG *plEvent , LPCITEMIDLIST pidl1, LPCITEMIDLIST pidl2, LPITEMIDLIST * ppidlOut1, LPITEMIDLIST * ppidlOut2,
                                   LONG *plEvent2, LPITEMIDLIST * ppidlOut1Event2, LPITEMIDLIST * ppidlOut2Event2) PURE;
    STDMETHOD(IsChildID)(THIS_ LPCITEMIDLIST pidlKid, BOOL fImmediate) PURE;
    STDMETHOD(IsEqualID)(THIS_ LPCITEMIDLIST pidl1, LPCITEMIDLIST pidl2) PURE;
    STDMETHOD(Register)(THIS_ HWND hwnd, UINT uMsg, long lEvents) PURE;
    STDMETHOD(Unregister)(THIS) PURE;
};

////////////////////////////////////////////////////
//
// IRegTreeOptions
//
typedef enum tagBUTTON_STATES
{
    IDCHECKED,
    IDUNCHECKED,
    IDRADIOON,
    IDRADIOOFF,
    IDUNKNOWN
} BUTTON_STATES;

//
// Avoid conflicts in the windows\shell project
//
#ifndef NO_SHELL_TREE_TYPE
typedef enum tagTREE_TYPE
{
    TREE_CHECKBOX,
    TREE_RADIO,
    TREE_GROUP,
    TREE_UNKNOWN
} TREE_TYPE;
#endif // NO_SHELL_TREE_TYPE

typedef enum tagWALK_TREE_CMD
{
    WALK_TREE_SAVE,
    WALK_TREE_DELETE,
    WALK_TREE_RESTORE,
    WALK_TREE_REFRESH
} WALK_TREE_CMD;


enum REG_CMD
{
    REG_SET,
    REG_GET,
    REG_GETDEFAULT
};

#undef  INTERFACE
#define INTERFACE   IRegTreeOptions

DECLARE_INTERFACE_(IRegTreeOptions, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IRegTreeOptions specific methods ***
    STDMETHOD(InitTree)(THIS_ HWND hwndTree, HKEY hkeyRoot, LPCSTR pszRegKey, LPCSTR pszParam) PURE;
    STDMETHOD(WalkTree)(THIS_ WALK_TREE_CMD cmd ) PURE;
    STDMETHOD(ToggleItem)(THIS_ HTREEITEM hti ) PURE;
    STDMETHOD(ShowHelp)(THIS_ HTREEITEM hti , DWORD dwFlags ) PURE;
};



//
// Interface: IShellHotKey
//

#undef  INTERFACE
#define INTERFACE   IShellHotKey

DECLARE_INTERFACE_(IShellHotKey, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IShellHotKey methods ***
    STDMETHOD(RegisterHotKey)(THIS_ IShellFolder * psf, LPCITEMIDLIST pidlParent, LPCITEMIDLIST pidl) PURE;
};


//
// Interface: ITrayPriv
//
// Purpose: Talks to the new Start Menu code in Shdocvw from explorer.exe
//
// For flags on ShowFolder see inc\IETHREAD.H
//

#undef  INTERFACE
#define INTERFACE   ITrayPriv

DECLARE_INTERFACE_(ITrayPriv, IOleWindow)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IOleWindow methods ***
    STDMETHOD(GetWindow) (THIS_ HWND * lphwnd) PURE;
    STDMETHOD(ContextSensitiveHelp) (THIS_ BOOL fEnterMode) PURE;

    // *** ITrayPriv methods ***
    STDMETHOD(ExecItem)(THIS_ IShellFolder* psf, LPCITEMIDLIST pidl) PURE;
    STDMETHOD(GetFindCM)(THIS_ HMENU hmenu, UINT idFirst, UINT idLast, IContextMenu** ppcmFind) PURE;
    STDMETHOD(GetStaticStartMenu)(THIS_ HMENU* phmenu) PURE;
};

// ITrayPriv2 - new for Whistler
//
// Purpose: Allows Explorer Start Menu object to participate in customdraw.
//
#undef  INTERFACE
#define INTERFACE   ITrayPriv2

DECLARE_INTERFACE_(ITrayPriv2, ITrayPriv)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IOleWindow methods ***
    STDMETHOD(GetWindow) (THIS_ HWND * lphwnd) PURE;
    STDMETHOD(ContextSensitiveHelp) (THIS_ BOOL fEnterMode) PURE;

    // *** ITrayPriv methods ***
    STDMETHOD(ExecItem)(THIS_ IShellFolder* psf, LPCITEMIDLIST pidl) PURE;
    STDMETHOD(GetFindCM)(THIS_ HMENU hmenu, UINT idFirst, UINT idLast, IContextMenu** ppcmFind) PURE;
    STDMETHOD(GetStaticStartMenu)(THIS_ HMENU* phmenu) PURE;

    // *** ITrayPriv2 methods ***
    STDMETHOD(ModifySMInfo)(THIS_ IN LPSMDATA psmd, IN OUT SMINFO *psminfo) PURE;
};

;end_internal

#undef  INTERFACE
#define INTERFACE   IInitializeObject

DECLARE_INTERFACE_(IInitializeObject, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IInitializeObject methods
    STDMETHOD(Initialize)(THIS) PURE;
};


enum
{
    BMICON_LARGE = 0,
    BMICON_SMALL
};

#undef  INTERFACE
#define INTERFACE   IBanneredBar

DECLARE_INTERFACE_(IBanneredBar, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IBanneredBar methods ***
    STDMETHOD(SetIconSize)(THIS_ DWORD iIcon) PURE;
    STDMETHOD(GetIconSize)(THIS_ DWORD* piIcon) PURE;
    STDMETHOD(SetBitmap)(THIS_ HBITMAP hBitmap) PURE;
    STDMETHOD(GetBitmap)(THIS_ HBITMAP* phBitmap) PURE;

};

;begin_internal

//
// Interface: IFolderShortcutConvert
//
// Purpose: Converts between FolderShortcuts and links
//

#undef  INTERFACE
#define INTERFACE   IFolderShortcutConvert

DECLARE_INTERFACE_(IFolderShortcutConvert, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface)(THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef)(THIS)  PURE;
    STDMETHOD_(ULONG,Release)(THIS) PURE;

    //*** IFolderShortcutConvert methods ***
    STDMETHOD(ConvertToLink)(THIS_ LPCOLESTR pszFSPath, DWORD fFlags) PURE;
    STDMETHOD(ConvertToFolderShortcut)(THIS_ LPCOLESTR pszLinkPath, DWORD fFlags) PURE;
};

//
// Interface: IShellFolderTask
//
// Purpose: Initializes a task that does something by enumerating a shellfolder
//

#undef  INTERFACE
#define INTERFACE   IShellFolderTask

DECLARE_INTERFACE_(IShellFolderTask, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface)(THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef)(THIS)  PURE;
    STDMETHOD_(ULONG,Release)(THIS) PURE;

    // *** IShellFolderTask methods ***
    STDMETHOD(InitTaskSFT)(THIS_ IShellFolder *psfParent, LPITEMIDLIST pidlFull,
                           LONG nMaxRecursionLevel, DWORD dwFlags, DWORD dwTaskPriority) PURE;
};

// Flags for InitTaskSFT
#define ITSFT_RECURSE   0x00000001      // recurse into subfolders


//
// Interface: IStartMenuTask
//
// Purpose: Initializes a task that does something for the start menu
//

#undef  INTERFACE
#define INTERFACE   IStartMenuTask

DECLARE_INTERFACE_(IStartMenuTask, IShellFolderTask)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface)(THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef)(THIS)  PURE;
    STDMETHOD_(ULONG,Release)(THIS) PURE;

    // *** IShellFolderTask methods ***
    STDMETHOD(InitTaskSFT)(THIS_ IShellFolder *psfParent, LPITEMIDLIST pidlFull,
                           LONG nMaxRecursionLevel, DWORD dwFlags, DWORD dwTaskPriority) PURE;

    // *** IStartMenuTask methods ***
    STDMETHOD(InitTaskSMT)(THIS_ IShellHotKey * photkey, int iThreadPriority) PURE;
};

//
// Interface: IContextMenuCB
//
// Purpose: A call defview context menu callback object
//

#undef  INTERFACE
#define INTERFACE   IContextMenuCB

DECLARE_INTERFACE_(IContextMenuCB, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface)   (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef)    (THIS) PURE;
    STDMETHOD_(ULONG,Release)   (THIS) PURE;

    // *** IContextMenuCB methods ***
    STDMETHOD(CallBack) (THIS_  IShellFolder *psf, HWND hwndOwner, IDataObject *pdtobj, UINT uMsg,
                                WPARAM wParam, LPARAM lParam) PURE;
};

//
// Possible underline settings for shell icons.
//
enum
{
    ICON_YES,
    ICON_NO,
    ICON_HOVER,
    ICON_IE         // Use IE hyperlink settings
};

//-----------------------------------------------
// IOleCommand Target Command IDs

// CGID_BandHandler
    //  Get the order stream from parent.
#define BHCMDID_GetOrderStream      0x00000001

// CGID_Persist
    // Set the storage key.
#define MCBID_SetKey                0x00000001

// CGID_MenuBandItem
#define MBICMDID_IsVisible          0x00000001

// CGID_MenuBand
#define MBANDCID_REFRESH            0x10000000


//
// Interface: IShellMallocSpy
//
// Purpose: Facilitate IMallocSpy in the shell
//

#undef  INTERFACE
#define INTERFACE  IShellMallocSpy
DECLARE_INTERFACE_(IShellMallocSpy, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface)   (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef)    (THIS) PURE;
    STDMETHOD_(ULONG,Release)   (THIS) PURE;

    // *** IShellMallocSpy methods ***
    STDMETHOD(RegisterSpy) (THIS) PURE;
    STDMETHOD(RevokeSpy) (THIS) PURE;
    STDMETHOD(SetTracking) (THIS_ BOOL bTrack) PURE;
    STDMETHOD(AddToList) (THIS_ void *pv, SIZE_T cb) PURE;
    STDMETHOD(RemoveFromList) (THIS_ void *pv) PURE;
};

#undef  INTERFACE
#define INTERFACE   ISearchProvider

DECLARE_INTERFACE_(ISearchProvider, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** ISearchObject methods ***
    STDMETHOD(GetSearchGUID)(THIS_ LPGUID lpGuid) PURE;
};

#undef  INTERFACE
#define INTERFACE   ISearchItems

DECLARE_INTERFACE_(ISearchItems, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** ISearchItems methods ***
    //used by CSearchBand
    STDMETHOD(GetDefaultSearchUrl) (THIS_ LPWSTR pwzUrl, UINT cch) PURE;
};

#undef  INTERFACE
#define INTERFACE   ISearchBandTBHelper50

DECLARE_INTERFACE_(ISearchBandTBHelper50, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** ISearchBandTBHelper50 methods ***
    // implemented by CSearchBand
    STDMETHOD(AddNextMenuItem) (THIS_ LPCWSTR pwszText, int idItem) PURE;
    STDMETHOD(SetOCCallback) (THIS_ IOleCommandTarget *pOleCmdTarget) PURE;
    STDMETHOD(ResetNextMenu) (THIS) PURE;
};

#undef  INTERFACE
#define INTERFACE   ISearchBandTBHelper

DECLARE_INTERFACE_(ISearchBandTBHelper, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** ISearchBandTBHelper methods ***
    // implemented by CSearchBand
    STDMETHOD(AddNextMenuItem) (THIS_ LPCWSTR pwszText, int idItem) PURE;
    STDMETHOD(SetOCCallback) (THIS_ IOleCommandTarget *pOleCmdTarget) PURE;
    STDMETHOD(ResetNextMenu) (THIS) PURE;
    STDMETHOD(NavigateToPidl) (THIS_ LPCITEMIDLIST pidl) PURE;
};

#undef  INTERFACE
#define INTERFACE   IEnumUrlSearch

#include <pshpack8.h>

typedef struct
{
    GUID  guid;
    WCHAR wszName[80];
    WCHAR wszUrl[2048];
} URLSEARCH, *LPURLSEARCH;

#include <poppack.h>        /* Return to byte packing */

DECLARE_INTERFACE_(IEnumUrlSearch, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppvObj) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IEnumUrlSearch methods ***
    STDMETHOD(Next)(THIS_ ULONG celt, LPURLSEARCH rgelt, ULONG *pceltFetched) PURE;
    STDMETHOD(Skip)(THIS_ ULONG celt) PURE;
    STDMETHOD(Reset)(THIS) PURE;
    STDMETHOD(Clone)(THIS_ IEnumUrlSearch **ppenum) PURE;
};

#undef  INTERFACE
#define INTERFACE   IFolderSearches

DECLARE_INTERFACE_(IFolderSearches, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppvObj) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IFolderSearches methods ***
    STDMETHOD(EnumSearches) (THIS_ IEnumUrlSearch **ppenum) PURE;
    STDMETHOD(DefaultSearch) (THIS_ GUID *pguid) PURE;
};
#undef  INTERFACE
#define INTERFACE   IUserAssist

typedef struct
{
    DWORD   cbSize;     // SIZEOF
    DWORD   dwMask;     // INOUT requested/given (UEIM_*)
    int     cHit;       // profile count
    DWORD   dwAttrs;    // attributes (UEIA_*)
    FILETIME ftExecute; // Last execute filetime
} UEMINFO, *LPUEMINFO;

#define UEIM_HIT        0x01
#define UEIM_FILETIME   0x02

DECLARE_INTERFACE_(IUserAssist, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IUserAssist methods ***
    STDMETHOD(FireEvent)(THIS_ const GUID *pguidGrp, int eCmd, DWORD dwFlags, WPARAM wParam, LPARAM lParam) PURE;
    STDMETHOD(QueryEvent)(THIS_ const GUID *pguidGrp, int eCmd, WPARAM wParam, LPARAM lParam, LPUEMINFO pui) PURE;
    STDMETHOD(SetEvent)(THIS_ const GUID *pguidGrp, int eCmd, WPARAM wParam, LPARAM lParam, LPUEMINFO pui) PURE;
};



// This exists for the Internet Control Panel to be able to toggle who is the
// currently installed handler for FTP for the browser.
DECLARE_INTERFACE_(IFtpInstaller, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface)   (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef)    (THIS) PURE;
    STDMETHOD_(ULONG,Release)   (THIS) PURE;

    // *** IFtpInstaller methods ***
    STDMETHOD(IsIEDefautlFTPClient)(THIS) PURE;
    STDMETHOD(RestoreFTPClient)(THIS) PURE;
    STDMETHOD(MakeIEDefautlFTPClient)(THIS) PURE;
};

// DOC'ed for DOJ compliance
;end_internal
SHSTDAPI_(LRESULT) SHShellFolderView_Message(HWND hwndMain, UINT uMsg, LPARAM lParam);

//
// Callback interface for the IShellFolderView
//
#undef  INTERFACE
#define INTERFACE   IShellFolderViewCB

DECLARE_INTERFACE_(IShellFolderViewCB, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IShellFolderViewCB methods ***
    STDMETHOD(MessageSFVCB)(THIS_ UINT uMsg, WPARAM wParam, LPARAM lParam) PURE;
};

;begin_internal

#define CLR_MYINVALID 0x8fffffff       // I need to use a special value since CLR_INVALID == CLR_NONE!!!!
#define ISVALIDCOLOR(a) ((a) != CLR_MYINVALID)

// The following are used as indexes into the crCustomColors array.
#define CRID_CUSTOMTEXTBACKGROUND   0
#define CRID_CUSTOMTEXT             1
#define CRID_COLORCOUNT             2

typedef struct _CUSTOMVIEWSDATA
{
    DWORD      cchSizeOfBlock;  // size of lpDataBlock in WCHARs
    LPWSTR     lpDataBlock;     // Pointer to the Strings data block, allocated by the task allocator (SHAlloc)

    // The following are offsets (in WCHARs) to be added to lpDataBlock.
    // If the offset is -1 => That data is not present for this view.
    int        acchOffExtViewUIstr[6]; // ID_EXTVIEWSTRCOUNT was 6, but is no longer used
    COLORREF   crCustomColors[CRID_COLORCOUNT];

    // Once IE4 ships, we can extend this structure by adding new SFVF_ flags
    // in the main structure that say "customviewsdata contains xxx info".

} CUSTOMVIEWSDATA;

//
// Interface for enumerating "external" views for the ShellFolderView
//
typedef struct _SFVVIEWSDATA
{
    // idView specifies the view. Unless specified in pCustomData, look up
    // HKLM\CLSID\Software\Microsoft\Windows\CurrentVersion\ExtShellFolderViews\idView
    // to find the menu name, help text, tt text.
    //
    // the shell's IShellFolderView implementations get these as
    // subkeys of the shellex\ExtShellFolderViews key under the folder's
    // clsid type (or progid type, depending on the IShellFolderView impl).
    //
    // In desktop.ini, these are keys read from the [ExtShellFolderViews]
    // section, in the form of "{idView}" or "{idView}={idExtShellView}"
    //
    GUID idView;    // This is the GUID that specifies the View.

    // idExtShellView specifies the IDefViewExtInit IShellView extension
    // to use for this view.
    //
    // the shell's IShellFolderView implementations get this from
    // the "ISV" value under the shellex\ExtShellFolderViews\{idView}
    // key in the registry.
    //
    // In desktop.ini, this is read from the [ExtShellFolderViews]
    // section, in the form of "{idView}={idExtShellView}"
    //
    GUID idExtShellView; // [optional] This is the GUID for the extended IShellView

    // dwFlags - see the SFVF_ flags below.
    //
    // the shell's IShellFolderView implementations get this from
    // the "Attributes" value under the shellex\ExtShellFolderViews\{idView}
    // key in the registry.
    //
    // In desktop.ini, this is read from the [{idView}] section,
    // from the "Attributes=" line.
    //
    DWORD dwFlags;

    // lParam is passed to IShellView view extensions
    //
    // the shell's IShellFolderView implementations get this from
    // the "lparam" value under the shellex\ExtShellFolderViews\{idView}
    // key in the registry.
    //
    // In desktop.ini, this is read from the [{idView}] section,
    // from the "LParam=" line.
    //
    DWORD lParam;

    // wszMoniker is used to either bind to a docobject extended view,
    // or as the data for an idExtShellView view.
    //
    // the shell's IShellFolderView implementations get this from
    // the "PersistMoniker" value under the shellex\ExtShellFolderViews\{idView}
    // key in the registry.
    //
    // In desktop.ini, this is read from the [{idView}] section,
    // from the "PersistMoniker=" line.
    //
    WCHAR wszMoniker[MAX_PATH];

    // pCustomData overrides/provides menu and other ui options
    // for this view. If a WebViewFolderContents OC appears in the
    // docobject extended view, it pays attention to color and
    // background bitmaps.
    //
    // the shell's IShellFolderView implementations do not fill out this structure.
    //
    // In desktop.ini, this is read from the [{idView}] section,
    // from the "IconArea_Image", "IconArea_TextBackground", and "IconArea_Text".
    //
    CUSTOMVIEWSDATA *pCustomData; //This is valid only if SFVF_CUSTOMIZEDVIEW is set.

} SFVVIEWSDATA;

//
// SFVF_CUSTOMIZEDVIEW - This flag is set only for those views whose
// data are picked up from the Desktop.ini.
//
#define SFVF_CUSTOMIZEDVIEW  0x80000000

//
// SFVF_TREATASNORMAL - This flag is set for those views that wish to
// be treated as normal views, this means they will show up in the file-open/SaveAs
// Dialogs.
//
#define SFVF_TREATASNORMAL   0x40000000

//
// SFVF_NOWEBVIEWFOLDERCONTENTS - This is used to detect those views that
// never host the WebViewFolderContents OC and so cannot toggle on and off,
// ie, they are exclusive views such as Thumbnail View.
//
#define SFVF_NOWEBVIEWFOLDERCONTENTS   0x20000000


#undef  INTERFACE
#define INTERFACE   IEnumSFVViews

DECLARE_INTERFACE_(IEnumSFVViews, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IEnumSFVViews methods ***
    STDMETHOD(Next)  (THIS_ ULONG celt,
                      SFVVIEWSDATA **ppData,
                      ULONG *pceltFetched) PURE;
    STDMETHOD(Skip)  (THIS_ ULONG celt) PURE;
    STDMETHOD(Reset) (THIS) PURE;
    STDMETHOD(Clone) (THIS_ IEnumSFVViews **ppenum) PURE;
};


#undef  INTERFACE
#define INTERFACE   IPersistString

DECLARE_INTERFACE_(IPersistString, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IPersist methods ***
    STDMETHOD(GetClassID) (THIS_ LPCLSID lpClassID) PURE;

    // *** IPersistString methods ***
    STDMETHOD(Initialize) (THIS_ LPCWSTR pwszInit) PURE;
};

#pragma warning (disable: 4200)
#pragma warning (disable: 4510)
#pragma warning (disable: 4512)
#pragma warning (disable: 4610)
// From sdkinc\platform.h
// We can't simply include that file because it breaks other projects
// that include platform.h.

// DOC'ed for DOJ compliance:
;end_internal

;begin_both
#include <pshpack8.h>
;end_both

#undef UNSIZED_ARRAY2
#undef EMPTY_SIZE2
#define UNSIZED_ARRAY2
#define EMPTY_SIZE2 UNSIZED_ARRAY2

#define QCMINFO_PLACE_BEFORE    0
#define QCMINFO_PLACE_AFTER     1
typedef struct _QCMINFO_IDMAP_PLACEMENT
{
    UINT id;
    UINT fFlags;
} QCMINFO_IDMAP_PLACEMENT;

typedef struct _QCMINFO_IDMAP
{
    UINT                    nMaxIds;
    QCMINFO_IDMAP_PLACEMENT pIdList[1];
} QCMINFO_IDMAP;

typedef struct _QCMINFO
{
    HMENU       hmenu;          // in
    UINT        indexMenu;      // in
    UINT        idCmdFirst;     // in/out
    UINT        idCmdLast;      // in
    QCMINFO_IDMAP const*  pIdMap; // in / unused
} QCMINFO;
typedef QCMINFO * LPQCMINFO;

// TBINFO flags
#define TBIF_APPEND     0
#define TBIF_PREPEND    1
#define TBIF_REPLACE    2
#define TBIF_DEFAULT      0x00000000
#define TBIF_INTERNETBAR  0x00010000
#define TBIF_STANDARDTOOLBAR   0x00020000
#define TBIF_NOTOOLBAR  0x00030000

typedef struct _TBINFO
{
    UINT        cbuttons;       // out
    UINT        uFlags;         // out (one of TBIF_ flags)
} TBINFO;

;begin_internal

typedef struct _SFVM_SELCHANGE_DATA
{
    UINT uOldState;
    UINT uNewState;
    LPARAM lParamItem;
} SFVM_SELCHANGE_DATA;


typedef struct _COPYHOOKINFO
{
    HWND hwnd;
    DWORD wFunc;
    DWORD wFlags;
    LPCTSTR pszSrcFile;
    DWORD dwSrcAttribs;
    LPCTSTR pszDestFile;
    DWORD dwDestAttribs;
} COPYHOOKINFO;

;end_internal

typedef struct _DETAILSINFO
{
    LPCITEMIDLIST pidl;
    int fmt;
    int cxChar;
    STRRET str;
    int iImage;
} DETAILSINFO;

typedef struct _SFVM_PROPPAGE_DATA
{
    DWORD                dwReserved;
    LPFNADDPROPSHEETPAGE pfn;
    LPARAM               lParam;
} SFVM_PROPPAGE_DATA;

typedef struct _SFVM_HELPTOPIC_DATA
{
    WCHAR wszHelpFile[MAX_PATH];
    WCHAR wszHelpTopic[MAX_PATH];
} SFVM_HELPTOPIC_DATA;

;begin_internal

typedef struct
{
    DWORD bWantWebview;             // in: caller should return template
    DWORD dwOptions;                // out: SFVMQVI_ flags
    WCHAR szWebView[MAX_PATH];      // out: webview template path
} SFVM_VIEWINFO_DATA;

typedef struct
{
    DWORD dwOptions;                // out: SFVMQVI_ flags for the [in,wParam]uViewMode
} SFVM_VIEW_DATA;
// dwOptions control the state of corresponding [in,wParam]uViewMode:
#define SFVMQVI_NORMAL          0x0 // out: let defview decide what to do
#define SFVMQVI_INCLUDE         0x1 // out: force include
#define SFVMQVI_EXCLUDE         0x2 // out: force exclude


typedef struct
{
    FOLDERVIEWMODE    fvm;             // out: view mode
    BOOL              fGroupView;      // out: group view on/off
    UINT              uSortCol;        // out: sort by scid
    int               iSortDirection;  // out: ascending or descending sort
    FOLDERFLAGS       fFlags;          // out: folder flags to set (supports FWF_AUTOARRANGE)
} SFVM_DEFERRED_VIEW_SETTINGS;

typedef struct
{
    WCHAR szWebView[MAX_PATH];      // out: webview template path for [in,wParam]uViewMode
} SFVM_WEBVIEW_TEMPLATE_DATA;

typedef struct _SFVM_CUSTOMVIEWINFO_DATA
{
    COLORREF crCustomColors[CRID_COLORCOUNT];
    WCHAR    szIconAreaImage[MAX_PATH]; // Note: the old struct used INTERNET_MAX_URL_LENGTH, but we only use local cases so this isn't needed
} SFVM_CUSTOMVIEWINFO_DATA;

typedef struct
{
    DWORD dwLayout;         // out: SFVMWLV_ for [in,wParam]uViewMode
    IUnknown* punkPreview;  // out: IUnknown of preview control, if SFVMWVL_PREVIEW specified
} SFVM_WEBVIEW_LAYOUT_DATA;
// dwLayout:
#define SFVMWVL_NORMAL          0           // standard Web View format
#define SFVMWVL_PREVIEW         1           // "preview" Web View format
#define SFVMWVL_DETAILS         2           // standard Web View format with details expanded by default
#define SFVMWVL_ITEMS           0x00000000  // HACK (added for Whistler, remove in BlackComb): item Web View format
#define SFVMWVL_FILES           0x00010000  // HACK (added for Whistler, remove in BlackComb): file Web View format
#define SFVMWVL_NOPRINT         0x00020000  // HACK (added for Whistler, remove in BlackComb): unconditionally hide "Print this file" folder task
#define SFVMWVL_NOPUBLISH       0x00040000  // HACK (added for Whistler, remove in BlackComb): unconditionally hide "Publish this file" folder task
#define SFVMWVL_ORDINAL_MASK    0x0000ffff  // HACK (added for Whistler, remove in BlackComb): overload dwLayout for ordinals and flags
#define SFVMWVL_FLAGS_MASK      0xffff0000  // HACK (added for Whistler, remove in BlackComb): overload dwLayout for ordinals and flags


typedef struct
{
    DWORD           dwFlags;
    IUIElement*     pIntroText;         // can be NULL for no explanatory text
    IUIElement*     pSpecialTaskHeader; // can be NULL for no special task section
    IUIElement*     pFolderTaskHeader;  // if NULL, defview will provide a default folder task section
    IEnumIDList*    penumOtherPlaces;   // if NULL, defview will provide a default Other Places list
} SFVM_WEBVIEW_CONTENT_DATA;
// dwFlags:
#define SFVMWVF_BARRICADE       0x00000001   // this is a barricaded folder
#define SFVMWVF_ENUMTASKS       0x00000002   // Folder uses non-standard tasks.  Will enumerate.
#define SFVMWVF_NOMORETASKS     0x00000004   // No more tasks in enumeration.
#define SFVMWVF_SPECIALTASK     0x00000008   // Used in ENUMTASKSECTION_DATA.dwFlags.
#define SFVMWVF_CONTENTSCHANGE  0x00000010   // Refresh WV content when folder contents change.

typedef struct
{
    IEnumUICommand* penumSpecialTasks;  // can be NULL for no special task section
    IEnumUICommand* penumFolderTasks;   // if NULL, defview will provide a default folder task section
    DWORD           dwUpdateFlags;      // bitmask of the extra special events that we should listen to
} SFVM_WEBVIEW_TASKSECTION_DATA;
// dwUpdateFlags:
#define SFVMWVTSDF_CONTENTSCHANGE 0x00000001

typedef struct
{
    LPCWSTR pszThemeID; // [out] fill with a pointer a string who's lifetime is at least as long as your IShellFolderViewCB object.
} SFVM_WEBVIEW_THEME_DATA;


//
// To replace the standard webview tasks with a set enumerated by the view
// callback, the callback sets the SFVMWVF_ENUMTASKS flag in the dwFlags
// member of SFVM_WEBVIEWCONTENT_DATA.  This causes the shell to send
// SFVM_ENUMWEBVIEWTASKS repeatedly in place of SFVM_GETWEBVIEWCONTENT and
// SFVM_GETWEBVIEWTASKS.  Each time SFVM_ENUMWEBVIEWTASKS is sent,
// the view callback provides a header and task enumerator via a
// SFVM_WEBVIEW_ENUMTASKSECTION_DATA structure.  The message is sent to the
// view repeatedly until the handler sets the SFVMWVF_NOMORETASKS flag
// in SFVM_WEBVIEW_ENUMTASKSECTION_DATA.dwFlags.  The top-down display order
// of task sections is the same as the order in which they are provided by
// the view callback.
//
// The dwFlags member of SFVM_WEBVIEW_ENUMTASKSECTION_DATA supports
// the following values:
//      SFVMWVF_SPECIALTASK   - Use the 'special' task section style.
//                              If not set, use the 'normal' style.
//      SFVMWVF_NOMORETASKS   - Terminate the enumeration.
//
typedef struct
{
    DWORD           dwFlags;   // SFVMWVF_XXXX flags.  See above.
    IUIElement     *pHeader;
    IEnumUICommand *penumTasks;
    int             idBitmap;     // Valid only for SPECIALTASK sections.
    int             idWatermark;  // Valid only for SPECIALTASK sections.
} SFVM_WEBVIEW_ENUMTASKSECTION_DATA;


// WebView Task helper functions provided by shell32
// to help answer SFVM_GETWEBVIEWCONTENT and SFVM_GETWEBVIEWTASKS messages.
//
// The idea here being that you provide task implementations in the static
// functions with a pv parameter that gets passed through to your static functions
// so they can get back to your IShellFolderViewCB object.  These helper
// functions assume that all strings are resources to be loaded out of your DLL.
//
typedef HRESULT (*PFN_get_State)(IUnknown* pv,IShellItemArray *psiItemArray, BOOL fOkToBeSlow, UISTATE* puisState);
typedef HRESULT (*PFN_Invoke)(IUnknown* pv,IShellItemArray *psiItemArray, IBindCtx *pbc);
typedef struct {
    const GUID* pguidCanonicalName;
    LPCWSTR pszDllName;
    DWORD   dwTitleIndexNoSelection;
    DWORD   dwTitleIndexFileSelected;
    DWORD   dwTitleIndexFolderSelected;
    DWORD   dwTitleIndexMultiSelected;
    DWORD   dwTooltipIndex;
    DWORD   dwIconIndex;
    PFN_get_State pfn_get_State;
    PFN_Invoke    pfn_Invoke;
} WVTASKITEM;

// Use for tasks that want to be displayed when something is selected, where the UI is independent of the selection
#define WVTI_ENTRY(g, d, t, p, i, s, k) {&(g), (d), (0), (t), (t), (t), (p), (i), (s), (k)}

// Use for tasks that want to be displayed when nothing is selected
#define WVTI_ENTRY_NOSELECTION(g, d, t, p, i, s, k) {&(g), (d), (t), 0, 0, 0, (p), (i), (s), (k)}

// Use for tasks that want to be displayed when a file is selected
#define WVTI_ENTRY_FILE(g, d, t, p, i, s, k) {&(g), (d), (0), (t), (0), (0), (p), (i), (s), (k)}

// Use for tasks that want to be displayed when something is selected, and you want different UI depending on the selection
// Use this one if you want to control the title, but the tooltip is constant:
#define WVTI_ENTRY_TITLE(g, d, t2, t3, t4, p, i, s, k) {&(g), (d), (0), (t2), (t3), (t4), (p), (i), (s), (k)}

// Use this one if you want the same text everywhere:
#define WVTI_ENTRY_ALL(g, d, t, p, i, s, k) {&(g), (d), (t), (t), (t), (t), (p), (i), (s), (k)}

// Use this one if you want to control everything:
#define WVTI_ENTRY_ALL_TITLE(g, d, t1, t2, t3, t4, p, i, s, k) {&(g), (d), (t1), (t2), (t3), (t4), (p), (i), (s), (k)}

// Use this one for a header:
#define WVTI_HEADER(d, t, p) {&(CLSID_NULL), (d), (t), (t), (t), (t), (p), 0, NULL, NULL}

// Use this one for a header that changes with the selection:
#define WVTI_HEADER_ENTRY(d, t1, t2, t3, t4, p) {&(CLSID_NULL), (d), (t1), (t2), (t3), (t4), (p), 0, NULL, NULL}

// Creates an IEnumUICommand over an array of WVTASKITEM structures.
// The enumerator/objects hold a ref on the pv param for the lifetime of the enumerator/objects.
// The pv param gets passed through to the static WVTASKITEM.pfn functions.
//
HRESULT Create_IEnumUICommand(IUnknown *pv, const WVTASKITEM* rgwvti, UINT cwvti, IEnumUICommand**ppenum);

// Creates an IUICommand out of a single WVTASKITEM, never calling the pfn functions
HRESULT Create_IUIElement(const WVTASKITEM* pwvti, IUIElement**ppuie);



// SFVM_GETNOTIFY: The shell will use the pidl returned from this message to synch
//                 change notifies.  Folders in Folder Shortcuts should return pidlTarget
//                 because that is where the change notifies are sent.
//
// DOC'ed for DOJ compliance:
;end_internal
//                                 uMsg    wParam             lParam
#define SFVM_MERGEMENU             1    // -                  LPQCMINFO
#define SFVM_INVOKECOMMAND         2    // idCmd              -
#define SFVM_GETHELPTEXT           3    // idCmd,cchMax       pszText
#define SFVM_GETTOOLTIPTEXT        4    // idCmd,cchMax       pszText
#define SFVM_GETBUTTONINFO         5    // -                  LPTBINFO
#define SFVM_GETBUTTONS            6    // idCmdFirst,cbtnMax LPTBBUTTON
#define SFVM_INITMENUPOPUP         7    // idCmdFirst,nIndex  hmenu
;begin_internal
#define SFVM_SELCHANGE             8    // idCmdFirst,nItem   SFVM_SELCHANGE_DATA*
#define SFVM_DRAWITEM              9    // idCmdFirst         DRAWITEMSTRUCT*
#define SFVM_MEASUREITEM          10    // idCmdFirst         MEASUREITEMSTRUCT*
#define SFVM_EXITMENULOOP         11    // -                  -
#define SFVM_PRERELEASE           12    // -                  -
#define SFVM_GETCCHMAX            13    // LPCITEMIDLIST      pcchMax
#define SFVM_FSNOTIFY             14    // LPCITEMIDLIST*     lEvent
// DOC'ed for DOJ compliance:
;end_internal
#define SFVM_WINDOWCREATED        15    // hwnd               -
;begin_internal
#define SFVM_WINDOWDESTROY        16    // hwnd               -
#define SFVM_REFRESH              17    // BOOL fPreOrPost    -                         NB: this may be called multiple times in a row
#define SFVM_SETFOCUS             18    // -                  -
#define SFVM_QUERYCOPYHOOK        20    // -                  -
#define SFVM_NOTIFYCOPYHOOK       21    // -                  COPYHOOKINFO*
// DOC'ed for DOJ compliance:
;end_internal
#define SFVM_GETDETAILSOF         23    // iColumn            DETAILSINFO*
#define SFVM_COLUMNCLICK          24    // iColumn            -
#define SFVM_QUERYFSNOTIFY        25    // -                  SHChangeNotifyEntry *
#define SFVM_DEFITEMCOUNT         26    // -                  UINT*
#define SFVM_DEFVIEWMODE          27    // -                  FOLDERVIEWMODE*
#define SFVM_UNMERGEMENU          28    // -                  hmenu
;begin_internal
#define SFVM_INSERTITEM           29    // pidl               -
#define SFVM_DELETEITEM           30    // pidl               -
// DOC'ed for DOJ compliance:
;end_internal
#define SFVM_UPDATESTATUSBAR      31    // fInitialize        -
#define SFVM_BACKGROUNDENUM       32    // -                  -
;begin_internal
#define SFVM_GETWORKINGDIR        33    // uMax               pszDir
#define SFVM_GETCOLSAVESTREAM     34    // flags              IStream **
#define SFVM_SELECTALL            35    // -                  -
// DOC'ed for DOJ compliance:
;end_internal
#define SFVM_DIDDRAGDROP          36    // dwEffect           IDataObject *
;begin_internal
#define SFVM_SUPPORTSIDENTITY     37    // -                  -                         // NOT USED: must support IShellFolder2
#define SFVM_FOLDERISPARENT       38    // -                  pidlChild
// DOC'ed for DOJ compliance:
;end_internal
#define SFVM_SETISFV              39    // -                  IShellFolderView*
;begin_internal
#define SFVM_GETVIEWS             40    // SHELLVIEWID*       IEnumSFVViews **
// DOC'ed for DOJ compliance:
;end_internal
#define SFVM_THISIDLIST           41    // -                  LPITMIDLIST*
;begin_internal
#define SFVM_GETITEMIDLIST        42    // iItem              LPITMIDLIST*
#define SFVM_SETITEMIDLIST        43    // iItem              LPITEMIDLIST
#define SFVM_INDEXOFITEMIDLIST    44    // *iItem             LPITEMIDLIST
#define SFVM_ODFINDITEM           45    // *iItem             NM_FINDITEM*
#define SFVM_HWNDMAIN             46    //                    hwndMain
// DOC'ed for DOJ compliance:
;end_internal
#define SFVM_ADDPROPERTYPAGES     47    // -                  SFVM_PROPPAGE_DATA *
#define SFVM_BACKGROUNDENUMDONE   48    // -                  -
#define SFVM_GETNOTIFY            49    // LPITEMIDLIST*      LONG*
;begin_internal
#define SFVM_ARRANGE              50    // -                  lParamSort
#define SFVM_QUERYSTANDARDVIEWS   51    // -                  BOOL *                    // NOT USED: must use SFVM_GETVIEWDATA instead
#define SFVM_QUERYREUSEEXTVIEW    52    // -                  BOOL *                    // NOT USED
// DOC'ed for DOJ compliance:
;end_internal
#define SFVM_GETSORTDEFAULTS      53    // iDirection         iParamSort
;begin_internal
#define SFVM_GETEMPTYTEXT         54    // cchMax             pszText
#define SFVM_GETITEMICONINDEX     55    // iItem              int *piIcon
#define SFVM_DONTCUSTOMIZE        56    // -                  BOOL *pbDontCustomize     // NOT USED
// DOC'ed for DOJ compliance:
;end_internal
#define SFVM_SIZE                 57    // -                  -
#define SFVM_GETZONE              58    // -                  DWORD*
#define SFVM_GETPANE              59    // Pane ID            DWORD*
;begin_internal
#define SFVM_ISOWNERDATA          60    // ISOWNERDATA        BOOL *
#define SFVM_GETODRANGEOBJECT     61    // iWhich             ILVRange **
#define SFVM_ODCACHEHINT          62    // -                  NMLVCACHEHINT *
// DOC'ed for DOJ compliance:
;end_internal
#define SFVM_GETHELPTOPIC         63    // -                  SFVM_HELPTOPIC_DATA *
;begin_internal
#define SFVM_OVERRIDEITEMCOUNT    64    // -                  UINT*                     // NOT USED: allowed override of actual item count for sizing calculations
#define SFVM_GETHELPTEXTW         65    // idCmd,cchMax       pszText - unicode
#define SFVM_GETTOOLTIPTEXTW      66    // idCmd,cchMax       pszText - unicode
#define SFVM_GETIPERSISTHISTORY   67    //                    IPersistHistory **
#define SFVM_GETANIMATION         68    // HINSTANCE *        WCHAR *
#define SFVM_GETHELPTEXTA         69    // idCmd,cchMax       pszText - ansi
#define SFVM_GETTOOLTIPTEXTA      70    // idCmd,cchMax       pszText - ansi
// The below two messages are only used in ownder data case, i.e. when SFVM_ISOWNERDATA returns TRUE
#define SFVM_GETICONOVERLAY       71    // iItem              int iOverlayIndex
#define SFVM_SETICONOVERLAY       72    // iItem              int * piOverlayIndex
#define SFVM_ALTERDROPEFFECT      73    // DWORD*             IDataObject*
#define SFVM_DELAYWINDOWCREATE    74    // HWND               - posted version of SFVM_WINDOWCREATED, no params
#define SFVM_FORCEWEBVIEW         75    // BOOL*              -
#define SFVM_GETVIEWINFO          76    // fvm.uViewMode      SFVM_VIEWINFO_DATA*          // NOT USED: shipped in Whistler Beta 1 only, remove soon
#define SFVM_GETCUSTOMVIEWINFO    77    // -                  SFVM_CUSTOMVIEWINFO_DATA*
#define SFVM_FOLDERSETTINGSFLAGS  78    // -                  DWORD * (FWF_ flags)
#define SFVM_ENUMERATEDITEMS      79    // UINT celt          LPCITEMIDLIST* rgpidl      // fired once at view creation, before first SFVM_GETVIEWDATA SFVM_GETDEFERREDVIEWSETTINGS
#define SFVM_GETVIEWDATA          80    // fvm.uViewMode      SFVM_VIEW_DATA*
#define SFVM_GETWEBVIEW_TEMPLATE  81    // fvm.uViewMode      SFVM_WEBVIEW_TEMPLATE_DATA*  // NOTE: going away soon
#define SFVM_GETWEBVIEWLAYOUT     82    // fvm.uViewMode      SFVM_WEBVIEW_LAYOUT_DATA*
#define SFVM_GETWEBVIEWCONTENT    83    // -                  SFVM_WEBVIEW_CONTENT_DATA*
#define SFVM_GETWEBVIEWTASKS      84    // -                  SFVM_WEBVIEW_TASKSECTION_DATA*
#define SFVM_GETWEBVIEWTHEME      86    // -                  SFVM_WEBVIEW_THEME_DATA* // HACK for Whistler, will remove when DirectUI goes DLL
#define SFVM_SORTLISTDATA         87    // PFNLVCOMPARE       lParamSort
#define SFVM_GETWEBVIEWBARRICADE  88    // -                  Element* // HACK for Whistler, will remove when DirectUI goes DLL
#define SFVM_ENUMWEBVIEWTASKS     90    // -                  SFVM_WEBVIEW_ENUMTASKSECTION_DATA*
#define SFVM_SETEMPTYTEXT         91    // -                  pszText
#define SFVM_GETDEFERREDVIEWSETTINGS 92 // -                  SFVM_DEFERRED_VIEW_SETTINGS* // set the default view settings

// All of these macros are compatible with HANDLE_MSG in WINDOWSX.H

#define HANDLE_SFVM_MERGEMENU(pv, wP, lP, fn) \
    ((fn)((pv), (QCMINFO*)(lP)))

#define HANDLE_SFVM_INVOKECOMMAND(pv, wP, lP, fn) \
    ((fn)((pv), (UINT)(wP)))

#define HANDLE_SFVM_GETHELPTEXT(pv, wP, lP, fn) \
    ((fn)((pv), LOWORD(wP), HIWORD(wP), (LPTSTR)(lP)))

#define HANDLE_SFVM_GETTOOLTIPTEXT(pv, wP, lP, fn) \
    ((fn)((pv), LOWORD(wP), HIWORD(wP), (LPTSTR)(lP)))

#define HANDLE_SFVM_GETBUTTONINFO(pv, wP, lP, fn) \
    ((fn)((pv), (TBINFO*)(lP)))

#define HANDLE_SFVM_GETBUTTONS(pv, wP, lP, fn) \
    ((fn)((pv), LOWORD(wP), HIWORD(wP), (TBBUTTON*)(lP)))

#define HANDLE_SFVM_INITMENUPOPUP(pv, wP, lP, fn) \
    ((fn)((pv), LOWORD(wP), HIWORD(wP), (HMENU)(lP)))

#define HANDLE_SFVM_SELCHANGE(pv, wP, lP, fn) \
    ((fn)((pv), LOWORD(wP), HIWORD(wP), (SFVM_SELCHANGE_DATA*)(lP)))

#define HANDLE_SFVM_DRAWITEM(pv, wP, lP, fn) \
    ((fn)((pv), (UINT)(wP), (DRAWITEMSTRUCT*)(lP)))

#define HANDLE_SFVM_MEASUREITEM(pv, wP, lP, fn) \
    ((fn)((pv), (UINT)(wP), (MEASUREITEMSTRUCT*)(lP)))

#define HANDLE_SFVM_EXITMENULOOP(pv, wP, lP, fn) \
    ((fn)(pv))

#define HANDLE_SFVM_PRERELEASE(pv, wP, lP, fn) \
    ((fn)(pv))

#define HANDLE_SFVM_GETCCHMAX(pv, wP, lP, fn) \
    ((fn)((pv), (LPCITEMIDLIST)(wP), (UINT*)(lP)))

#define HANDLE_SFVM_FSNOTIFY(pv, wP, lP, fn) \
    ((fn)((pv), (LPCITEMIDLIST*)(wP), (lP)))

#define HANDLE_SFVM_WINDOWCREATED(pv, wP, lP, fn) \
    ((fn)((pv), (HWND)(wP)))

#define HANDLE_SFVM_WINDOWDESTROY(pv, wP, lP, fn) \
    ((fn)((pv), (HWND)(wP)))

#define HANDLE_SFVM_REFRESH(pv, wP, lP, fn) \
    ((fn)((pv), (BOOL) wP))

#define HANDLE_SFVM_SETFOCUS(pv, wP, lP, fn) \
    ((fn)(pv))

#define HANDLE_SFVM_QUERYCOPYHOOK(pv, wP, lP, fn) \
    ((fn)(pv))

#define HANDLE_SFVM_NOTIFYCOPYHOOK(pv, wP, lP, fn) \
    ((fn)((pv), (COPYHOOKINFO*)(lP)))

#define HANDLE_SFVM_GETDETAILSOF(pv, wP, lP, fn) \
    ((fn)((pv), (UINT)(wP), (DETAILSINFO*)(lP)))

#define HANDLE_SFVM_COLUMNCLICK(pv, wP, lP, fn) \
    ((fn)((pv), (UINT)(wP)))

#define HANDLE_SFVM_QUERYFSNOTIFY(pv, wP, lP, fn) \
    ((fn)((pv), (SHChangeNotifyEntry*)(lP)))

#define HANDLE_SFVM_DEFITEMCOUNT(pv, wP, lP, fn) \
    ((fn)((pv), (UINT*)(lP)))

#define HANDLE_SFVM_OVERRIDEITEMCOUNT(pv, wP, lP, fn) \
    ((fn)((pv), (UINT*)(lP)))

#define HANDLE_SFVM_DEFVIEWMODE(pv, wP, lP, fn) \
    ((fn)((pv), (FOLDERVIEWMODE*)(lP)))

#define HANDLE_SFVM_UNMERGEMENU(pv, wP, lP, fn) \
    ((fn)((pv), (HMENU)(lP)))

#define HANDLE_SFVM_INSERTITEM(pv, wP, lP, fn) \
    ((fn)((pv), (LPCITEMIDLIST)(lP)))

#define HANDLE_SFVM_DELETEITEM(pv, wP, lP, fn) \
    ((fn)((pv), (LPCITEMIDLIST)(lP)))

#define HANDLE_SFVM_UPDATESTATUSBAR(pv, wP, lP, fn) \
    ((fn)((pv), (BOOL)(wP)))

#define HANDLE_SFVM_BACKGROUNDENUM(pv, wP, lP, fn) \
    ((fn)(pv))

#define HANDLE_SFVM_GETWORKINGDIR(pv, wP, lP, fn) \
    ((fn)((pv), (UINT)(wP), (LPTSTR)(lP)))

#define HANDLE_SFVM_GETCOLSAVESTREAM(pv, wP, lP, fn) \
    ((fn)((pv), (wP), (IStream**)(lP)))

#define HANDLE_SFVM_SELECTALL(pv, wP, lP, fn) \
    ((fn)(pv))

#define HANDLE_SFVM_DIDDRAGDROP(pv, wP, lP, fn) \
    ((fn)((pv), (DWORD)(wP), (IDataObject*)(lP)))

#define HANDLE_SFVM_SUPPORTSIDENTITY(pv, wp, lP, fn) \
    ((fn)(pv))    /* Only 1 parameter */

#define HANDLE_SFVM_HWNDMAIN(pv, wP, lP, fn) \
    ((fn)((pv), (HWND)(lP)))

#define HANDLE_SFVM_GETNOTIFY(pv, wP, lP, fn) \
    ((fn)((pv), (LPITEMIDLIST*)(wP), (LONG*)(lP)))

#define HANDLE_SFVM_SETISFV(pv, wP, lP, fn) \
    ((fn)((pv), (IShellFolderView*)(lP)))

#define HANDLE_SFVM_GETVIEWS(pv, wP, lP, fn) \
    ((fn)((pv), (SHELLVIEWID*)(wP), (IEnumSFVViews**)(lP)))

#define HANDLE_SFVM_THISIDLIST(pv, wP, lP, fn) \
    ((fn)((pv), (LPITEMIDLIST*)(lP)))

#define HANDLE_SFVM_GETITEMIDLIST(pv, wP, lP, fn) \
    ((fn)((pv), (wP), (LPITEMIDLIST*)(lP)))

#define HANDLE_SFVM_SETITEMIDLIST(pv, wP, lP, fn) \
    ((fn)((pv), (wP), (LPITEMIDLIST)(lP)))

#define HANDLE_SFVM_INDEXOFITEMIDLIST(pv, wP, lP, fn) \
    ((fn)((pv), (int*)(wP), (LPITEMIDLIST)(lP)))

#define HANDLE_SFVM_ODFINDITEM(pv, wP, lP, fn) \
    ((fn)((pv), (int*)(wP), (NM_FINDITEM*)(lP)))

#define HANDLE_SFVM_ADDPROPERTYPAGES(pv, wP, lP, fn) \
    ((fn)((pv), (SFVM_PROPPAGE_DATA *)(lP)))

#define HANDLE_SFVM_FOLDERISPARENT(pv, wP, lP, fn) \
    ((fn)((pv), (LPITEMIDLIST)(lP)))

#define HANDLE_SFVM_ARRANGE(pv, wP, lP, fn) \
    ((fn)((pv), (LPARAM)(lP)))

#define HANDLE_SFVM_QUERYSTANDARDVIEWS(pv, wP, lP, fn) \
    ((fn)((pv), (BOOL*)(lP)))

#define HANDLE_SFVM_QUERYREUSEEXTVIEW(pv, wP, lP, fn) \
    ((fn)((pv), (BOOL*)(lP)))

#define HANDLE_SFVM_GETEMPTYTEXT(pv, wP, lP, fn) \
    ((fn)((pv), (UINT)(wP), (LPTSTR)(lP)))

#define HANDLE_SFVM_GETITEMICONINDEX(pv, wP, lP, fn) \
    ((fn)((pv), (wP), (int*)(lP)))

#define HANDLE_SFVM_SIZE(pv, wP, lP, fn) \
    ((fn)((pv), LOWORD(lP), HIWORD(lP)))

#define HANDLE_SFVM_GETZONE(pv, wP, lP, fn) \
    ((fn)((pv), (DWORD *)(lP)))

#define HANDLE_SFVM_GETPANE(pv, wP, lP, fn) \
    ((fn)((pv), (wP), (DWORD *)(lP)))

#define HANDLE_SFVM_ISOWNERDATA(pv, wP, lP, fn) \
    ((fn)((pv), (BOOL*)(lP)))

#define HANDLE_SFVM_GETODRANGEOBJECT(pv, wP, lP, fn) \
    ((fn)((pv), (wP), (ILVRange **)(lP)))

#define HANDLE_SFVM_ODCACHEHINT(pv, wP, lP, fn) \
    ((fn)((pv), (NMLVCACHEHINT*)(lP)))

#define HANDLE_SFVM_GETHELPTOPIC(pv, wP, lP, fn) \
    ((fn)((pv), (SFVM_HELPTOPIC_DATA *)(lP)))

#define HANDLE_SFVM_GETIPERSISTHISTORY(pv, wP, lP, fn) \
    ((fn)((pv), (IPersistHistory **)(lP)))

#define HANDLE_SFVM_SETICONOVERLAY(pv, wP, lP, fn) \
    ((fn)((pv), (wP), (int)(lP)))

#define HANDLE_SFVM_GETICONOVERLAY(pv, wP, lP, fn) \
    ((fn)((pv), (wP), (int *)(lP)))

#define HANDLE_SFVM_ALTERDROPEFFECT(pv, wP, lP, fn) \
    ((fn)((pv), (DWORD *)(wP), (IDataObject *)(lP)))

#define HANDLE_SFVM_DELAYWINDOWCREATE(pv, wP, lP, fn) \
    ((fn)((pv), (HWND)(wP)))

#define HANDLE_SFVM_FORCEWEBVIEW(pv, wP, lP, fn) \
    ((fn)((pv), (BOOL*)(wP)))

#define HANDLE_SFVM_GETVIEWINFO(pv, wP, lP, fn) \
    ((fn)((pv), (UINT)(wP), (SFVM_VIEWINFO_DATA*)lP))

#define HANDLE_SFVM_GETCUSTOMVIEWINFO(pv, wP, lP, fn) \
    ((fn)((pv), (SFVM_CUSTOMVIEWINFO_DATA*)(lP)))

#define HANDLE_SFVM_FOLDERSETTINGSFLAGS(pv, wP, lP, fn) \
    ((fn)((pv), (DWORD*)(lP)))

#define HANDLE_SFVM_ENUMERATEDITEMS(pv, wP, lP, fn) \
    ((fn)((pv), (UINT)(wP), (LPCITEMIDLIST*)(lP)))

#define HANDLE_SFVM_GETVIEWDATA(pv, wP, lP, fn) \
    ((fn)((pv), (UINT)(wP), (SFVM_VIEW_DATA*)lP))

#define HANDLE_SFVM_GETWEBVIEW_TEMPLATE(pv, wP, lP, fn) \
    ((fn)((pv), (UINT)(wP), (SFVM_WEBVIEW_TEMPLATE_DATA*)(lP)))

#define HANDLE_SFVM_GETWEBVIEWLAYOUT(pv, wP, lP, fn) \
    ((fn)((pv), (UINT)(wP), (SFVM_WEBVIEW_LAYOUT_DATA*)(lP)))

#define HANDLE_SFVM_GETWEBVIEWCONTENT(pv, wP, lP, fn) \
    ((fn)((pv), (SFVM_WEBVIEW_CONTENT_DATA*)(lP)))

#define HANDLE_SFVM_GETWEBVIEWTASKS(pv, wP, lP, fn) \
    ((fn)((pv), (SFVM_WEBVIEW_TASKSECTION_DATA*)(lP)))

#define HANDLE_SFVM_ENUMWEBVIEWTASKS(pv, wP, lP, fn) \
    ((fn)((pv), (SFVM_WEBVIEW_ENUMTASKSECTION_DATA*)(lP)))

#define HANDLE_SFVM_GETWEBVIEWTHEME(pv, wP, lP, fn) \
    ((fn)((pv), (SFVM_WEBVIEW_THEME_DATA*)(lP)))

#define HANDLE_SFVM_SORTLISTDATA(pv, wP, lP, fn) \
    ((fn)((pv), (PFNLVCOMPARE)(wP), (lP)))

#define HANDLE_SFVM_GETDEFERREDVIEWSETTINGS(pv, wP, lP, fn) \
    ((fn)((pv), (SFVM_DEFERRED_VIEW_SETTINGS*)(lP)))

#define HANDLE_SFVM_SETEMPTYTEXT(pv, wP, lP, fn) \
    ((fn)((pv), (UINT)(wP), (LPCTSTR)(lP)))

//
// Return values for SFVM_GETICONOVERLAY:
// If the icon overlay is not set and you want the shell to set it for you.
// return SFVOVERLAY_UNSET. This will cause the shell to retrieve the overlay and
// send SFVM_SETICONOVERLAY.
// If there is no overlay for this item at all, the correct return value is
// SFVOVERLAY_DEFAULT
// If you return SFVOVERLAY_UNSET every time for SFVM_GETICONOVERLAY, the
// shell will keep setting it indefinitely, so there is a danger of infinite loop
//
#define SFV_ICONOVERLAY_DEFAULT    0
#define SFV_ICONOVERLAY_UNSET      0xFFFFFFFF

//
// What you can return from SFVM_UPDATESTATUSBAR:
//
//  E_NOTIMPL - Message not handled; DefView should manage status bar
//
// Otherwise, update the status bar yourself and return a bitmask of the
// following codes indicating what you want DefView to do for you.
//
#define SFVUSB_HANDLED      0x0000  // Client handled completely - DefView does nothing
#define SFVUSB_INITED       0x0001  // Client initialized parts  - DefView will set text
#define SFVUSB_ALL          0x0001;internal


// IShellFolderView interface for getting the SFV to do things
//

typedef struct _ITEMSPACING
{
    int cxSmall;
    int cySmall;
    int cxLarge;
    int cyLarge;
} ITEMSPACING;


// Define OPtions for SetObjectCount
#define SFVSOC_INVALIDATE_ALL   0x00000001  // Assumed to reset only what is neccessary...
#define SFVSOC_NOSCROLL         LVSICF_NOSCROLL

// defines for IShellFolderView::SelectItems()
#define SFVS_SELECT_NONE        0x0 // unselect all
#define SFVS_SELECT_ALLITEMS    0x1 // select all
#define SFVS_SELECT_INVERT      0x2 // Inver the selection

// defines for IShellFolderView::QuerySupport()
// allows a view to be queried to see if it supports various operations (useful for
// enabling menu items)
#define SFVQS_AUTO_ARRANGE      0x0001
#define SFVQS_ARRANGE_GRID      0x0002
#define SFVQS_SELECT_ALL        0x0004
#define SFVQS_SELECT_NONE       0x0008
#define SFVQS_SELECT_INVERT     0x0010

#undef  INTERFACE
#define INTERFACE   IShellFolderView

DECLARE_INTERFACE_(IShellFolderView, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface) (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef) (THIS)  PURE;
    STDMETHOD_(ULONG,Release) (THIS) PURE;

    // *** IShellFolderView methods ***
    STDMETHOD(Rearrange) (THIS_ LPARAM lParamSort) PURE;
    STDMETHOD(GetArrangeParam) (THIS_ LPARAM *plParamSort) PURE;
    STDMETHOD(ArrangeGrid) (THIS) PURE;
    STDMETHOD(AutoArrange) (THIS) PURE;
    STDMETHOD(GetAutoArrange) (THIS) PURE;
    STDMETHOD(AddObject) (THIS_ LPITEMIDLIST pidl, UINT *puItem) PURE;
    STDMETHOD(GetObject) (THIS_ LPITEMIDLIST *ppidl, UINT uItem) PURE;
    STDMETHOD(RemoveObject) (THIS_ LPITEMIDLIST pidl, UINT *puItem) PURE;
    STDMETHOD(GetObjectCount) (THIS_ UINT *puCount) PURE;
    STDMETHOD(SetObjectCount) (THIS_ UINT uCount, UINT dwFlags) PURE;
    STDMETHOD(UpdateObject) (THIS_ LPITEMIDLIST pidlOld, LPITEMIDLIST pidlNew, UINT *puItem) PURE;
    STDMETHOD(RefreshObject) (THIS_ LPITEMIDLIST pidl, UINT *puItem) PURE;
    STDMETHOD(SetRedraw) (THIS_ BOOL bRedraw) PURE;
    STDMETHOD(GetSelectedCount) (THIS_ UINT *puSelected) PURE;
    STDMETHOD(GetSelectedObjects) (THIS_ LPCITEMIDLIST **pppidl, UINT *puItems) PURE;
    STDMETHOD(IsDropOnSource) (THIS_ IDropTarget *pDropTarget) PURE;
    STDMETHOD(GetDragPoint) (THIS_ POINT *ppt) PURE;
    STDMETHOD(GetDropPoint) (THIS_ POINT *ppt) PURE;
    STDMETHOD(MoveIcons) (THIS_ IDataObject *pDataObject) PURE;
    STDMETHOD(SetItemPos) (THIS_ LPCITEMIDLIST pidl, POINT *ppt) PURE;
    STDMETHOD(IsBkDropTarget) (THIS_ IDropTarget *pDropTarget) PURE;
    STDMETHOD(SetClipboard) (THIS_ BOOL bMove) PURE;
    STDMETHOD(SetPoints) (THIS_ IDataObject *pDataObject) PURE;
    STDMETHOD(GetItemSpacing) (THIS_ ITEMSPACING *pSpacing) PURE;
    STDMETHOD(SetCallback) (THIS_ IShellFolderViewCB* pNewCB, IShellFolderViewCB** ppOldCB) PURE;
    STDMETHOD(Select) ( THIS_  UINT dwFlags ) PURE;
    STDMETHOD(QuerySupport) (THIS_ UINT * pdwSupport ) PURE;
    STDMETHOD(SetAutomationObject)(THIS_ IDispatch* pdisp) PURE;
} ;

// DOC'ed for DOJ compliance:
;end_internal
// SHCreateShellFolderView struct
typedef struct _SFV_CREATE
{
    UINT            cbSize;
    IShellFolder*   pshf;
    IShellView*     psvOuter;
    IShellFolderViewCB* psfvcb; // No callback if NULL
} SFV_CREATE;

SHSTDAPI SHCreateShellFolderView(const SFV_CREATE* pcsfv, IShellView **ppsv);
;begin_internal
#define SHCreateShellFolderViewORD      256

SHSTDAPI_(IShellFolderViewCB*) SHGetShellFolderViewCB(HWND hwndMain);

#define SHGetShellFolderViewCBORD   257

//===========================================================================
// Defview APIs to make name space author lives somewhat easier

// DOC'ed for DOJ compliance
;end_internal
typedef HRESULT (CALLBACK * LPFNDFMCALLBACK)(IShellFolder *psf, HWND hwnd,
                                             IDataObject *pdtobj, UINT uMsg, WPARAM wParam, LPARAM lParam);

SHSTDAPI CDefFolderMenu_Create2(LPCITEMIDLIST pidlFolder, HWND hwnd,
                                UINT cidl, LPCITEMIDLIST *apidl,
                                IShellFolder *psf, LPFNDFMCALLBACK lpfn,
                                UINT nKeys, const HKEY *ahkeyClsKeys,
                                IContextMenu **ppcm);

SHSTDAPI_(BOOL) SHOpenPropSheet%(LPCTSTR% pszCaption, HKEY ahkeys[], UINT cikeys,
                                 const CLSID * pclsidDefault, IDataObject *pdtobj,
                                 IShellBrowser *psb, LPCTSTR% pStartPage);
;begin_internal

// structure for lParam of DFM_INFOKECOMMANDEX
typedef struct
{
    DWORD  cbSize;

    DWORD  fMask;   // CMIC_MASK_ values for the invoke
    LPARAM lParam;  // same as lParam of DFM_INFOKECOMMAND
    UINT idCmdFirst;
    UINT idDefMax;
    LPCMINVOKECOMMANDINFO pici; // the whole thing so you can re-invoke on a child
} DFMICS, *PDFMICS;

// Note on context menus ranges:
//  Standard Items // DFM_MERGECONTEXTMENU, context menu extensions, DFM_MERGECONTEXTMENU_TOP
//  Separator
//  View Items   // context menu extensions can get here
//  Separator
//  (defcm S_FALSE "default" items, if applicable)
//  Separator
//  Folder Items // context menu extensions can get here
//  Separator
//  Bottom Items // DFM_MERGECONTEXTMENU_BOTTOM

// DOC'ed for DOJ compliance
;end_internal
//                                  uMsg       wParam       lParam
#define DFM_MERGECONTEXTMENU         1      // uFlags       LPQCMINFO
#define DFM_INVOKECOMMAND            2      // idCmd        pszArgs
;begin_internal
#define DFM_ADDREF                   3      // 0            0
#define DFM_RELEASE                  4      // 0            0
#define DFM_GETHELPTEXT              5      // idCmd,cchMax pszText -Ansi
#define DFM_WM_MEASUREITEM           6      // ---from the message---
#define DFM_WM_DRAWITEM              7      // ---from the message---
#define DFM_WM_INITMENUPOPUP         8      // ---from the message---
#define DFM_VALIDATECMD              9      // idCmd        0
#define DFM_MERGECONTEXTMENU_TOP     10     // uFlags       LPQCMINFO
#define DFM_GETHELPTEXTW             11     // idCmd,cchMax pszText -Unicode
#define DFM_INVOKECOMMANDEX          12     // idCmd        PDFMICS
#define DFM_MAPCOMMANDNAME           13     // idCmd *      pszCommandName
;end_internal
#define DFM_GETDEFSTATICID           14     // idCmd *      0
;begin_internal
#define DFM_GETVERBW                 15     // idCmd,cchMax pszText -Unicode
#define DFM_GETVERBA                 16     // idCmd,cchMax pszText -Ansi
#define DFM_MERGECONTEXTMENU_BOTTOM  17     // uFlags       LPQCMINFO


;end_internal
// Commands from DFM_INVOKECOMMAND when strings are passed in
;begin_internal
#define DFM_CMD_DELETE          ((UINT)-1)
#define DFM_CMD_MOVE            ((UINT)-2)
#define DFM_CMD_COPY            ((UINT)-3)
#define DFM_CMD_LINK            ((UINT)-4)
;end_internal
#define DFM_CMD_PROPERTIES      ((UINT)-5)
;begin_internal
#define DFM_CMD_NEWFOLDER       ((UINT)-6)
#define DFM_CMD_PASTE           ((UINT)-7)
#define DFM_CMD_VIEWLIST        ((UINT)-8)
#define DFM_CMD_VIEWDETAILS     ((UINT)-9)
#define DFM_CMD_PASTELINK       ((UINT)-10)
#define DFM_CMD_PASTESPECIAL    ((UINT)-11)
#define DFM_CMD_MODALPROP       ((UINT)-12)
#define DFM_CMD_RENAME          ((UINT)-13)

SHSTDAPI CDefFolderMenu_Create(LPCITEMIDLIST pidlFolder,
                             HWND hwndOwner,
                             UINT cidl, LPCITEMIDLIST * apidl,
                             IShellFolder *psf,
                             LPFNDFMCALLBACK lpfn,
                             HKEY hkeyProgID, HKEY hkeyBaseProgID,
                             IContextMenu ** ppcm);


SHSTDAPI_(void) CDefFolderMenu_MergeMenu(HINSTANCE hinst, UINT idMainMerge, UINT idPopupMerge,
        LPQCMINFO pqcm);
STDAPI_(void) Def_InitFileCommands(ULONG dwAttr, HMENU hmInit, UINT idCmdFirst,
        BOOL bContext);
STDAPI_(void) Def_InitEditCommands(ULONG dwAttr, HMENU hmInit, UINT idCmdFirst,
        IDropTarget *pdtgt, UINT fContext);

// indeces in bitmap strip
#define VIEW_MOVETO     24
#define VIEW_COPYTO     25
#define VIEW_OPTIONS    26

//===========================================================================
// Default IShellView for IShellFolder
//===========================================================================

// Menu ID's
#define SFVIDM_FIRST            (FCIDM_SHVIEWLAST-0x0fff)
#define SFVIDM_LAST             (FCIDM_SHVIEWLAST)

// Hardcoded message values => This range can be used for messages that we
// pass from shdoc401 to shell32
#define SFVIDM_HARDCODED_FIRST  (SFVIDM_LAST-0x0010)
#define SFVIDM_HARDCODED_LAST   (SFVIDM_LAST)

#define SFVIDM_MISC_SETWEBVIEW  (SFVIDM_HARDCODED_FIRST)

// Popup menu ID's used in merging menus
#define SFVIDM_MENU_ARRANGE     (SFVIDM_FIRST + 0x0001)
#define SFVIDM_MENU_VIEW        (SFVIDM_FIRST + 0x0002)
#define SFVIDM_MENU_SELECT      (SFVIDM_FIRST + 0x0003)

#define SHARED_FILE_FIRST               0x0010
#define SHARED_FILE_LINK                (SHARED_FILE_FIRST + 0x0000)
#define SHARED_FILE_DELETE              (SHARED_FILE_FIRST + 0x0001)
#define SHARED_FILE_RENAME              (SHARED_FILE_FIRST + 0x0002)
#define SHARED_FILE_PROPERTIES          (SHARED_FILE_FIRST + 0x0003)

#define SHARED_EDIT_FIRST               0x0018
#define SHARED_EDIT_CUT                 (SHARED_EDIT_FIRST + 0x0000)
#define SHARED_EDIT_COPY                (SHARED_EDIT_FIRST + 0x0001)
#define SHARED_EDIT_PASTE               (SHARED_EDIT_FIRST + 0x0002)
#define SHARED_EDIT_UNDO                (SHARED_EDIT_FIRST + 0x0003)
#define SHARED_EDIT_PASTELINK           (SHARED_EDIT_FIRST + 0x0004)
#define SHARED_EDIT_PASTESPECIAL        (SHARED_EDIT_FIRST + 0x0005)
#define SHARED_EDIT_COPYTO              (SHARED_EDIT_FIRST + 0x0006)
#define SHARED_EDIT_MOVETO              (SHARED_EDIT_FIRST + 0x0007)

#define SFVIDM_FILE_FIRST               (SFVIDM_FIRST + SHARED_FILE_FIRST)
#define SFVIDM_FILE_LINK                (SFVIDM_FIRST + SHARED_FILE_LINK)
#define SFVIDM_FILE_DELETE              (SFVIDM_FIRST + SHARED_FILE_DELETE)
#define SFVIDM_FILE_RENAME              (SFVIDM_FIRST + SHARED_FILE_RENAME)
#define SFVIDM_FILE_PROPERTIES          (SFVIDM_FIRST + SHARED_FILE_PROPERTIES)

#define SFVIDM_EDIT_FIRST               (SFVIDM_FIRST + SHARED_EDIT_FIRST)
#define SFVIDM_EDIT_CUT                 (SFVIDM_FIRST + SHARED_EDIT_CUT)
#define SFVIDM_EDIT_COPY                (SFVIDM_FIRST + SHARED_EDIT_COPY)
#define SFVIDM_EDIT_PASTE               (SFVIDM_FIRST + SHARED_EDIT_PASTE)
#define SFVIDM_EDIT_UNDO                (SFVIDM_FIRST + SHARED_EDIT_UNDO)
#define SFVIDM_EDIT_PASTELINK           (SFVIDM_FIRST + SHARED_EDIT_PASTELINK)
#define SFVIDM_EDIT_PASTESPECIAL        (SFVIDM_FIRST + SHARED_EDIT_PASTESPECIAL)
#define SFVIDM_EDIT_COPYTO              (SFVIDM_FIRST + SHARED_EDIT_COPYTO)
#define SFVIDM_EDIT_MOVETO              (SFVIDM_FIRST + SHARED_EDIT_MOVETO)

#define SFVIDM_SELECT_FIRST             (SFVIDM_FIRST + 0x0020)
#define SFVIDM_SELECT_ALL               (SFVIDM_SELECT_FIRST + 0x0001)
#define SFVIDM_SELECT_INVERT            (SFVIDM_SELECT_FIRST + 0x0002)
#define SFVIDM_DESELECT_ALL             (SFVIDM_SELECT_FIRST + 0x0003)

#define SFVIDM_VIEW_FIRST               (SFVIDM_FIRST + 0x0028)
#define SFVIDM_VIEW_FIRSTVIEW           (SFVIDM_VIEW_FIRST + 1)
#define SFVIDM_VIEW_ICON                (SFVIDM_VIEW_FIRST + 1)
#define SFVIDM_VIEW_SMALLICON           (SFVIDM_VIEW_FIRST + 2)
#define SFVIDM_VIEW_LIST                (SFVIDM_VIEW_FIRST + 3)
#define SFVIDM_VIEW_DETAILS             (SFVIDM_VIEW_FIRST + 4)
#define SFVIDM_VIEW_THUMBNAIL           (SFVIDM_VIEW_FIRST + 5)
#define SFVIDM_VIEW_TILE                (SFVIDM_VIEW_FIRST + 6)
#define SFVIDM_VIEW_THUMBSTRIP          (SFVIDM_VIEW_FIRST + 7)
#define SFVIDM_VIEW_LASTVIEW            (SFVIDM_VIEW_FIRST + 7)

// TileView
// One more for safe keeping
#define SFVIDM_VIEW_OPTIONS             (SFVIDM_VIEW_FIRST + 0x0008)
#define SFVIDM_VIEW_VIEWMENU            (SFVIDM_VIEW_FIRST + 0x0009)
#define SFVIDM_VIEW_CUSTOMWIZARD        (SFVIDM_VIEW_FIRST + 0x000A)
#define SFVIDM_VIEW_COLSETTINGS         (SFVIDM_VIEW_FIRST + 0x000B)

#define SFVIDM_VIEW_EXTFIRST            (SFVIDM_VIEW_FIRST + 0x000C)
#define SFVIDM_VIEW_EXTLAST             (SFVIDM_VIEW_EXTFIRST + 0x0017)
#define SFVIDM_VIEW_SVEXTFIRST          (SFVIDM_VIEW_EXTFIRST)
#define SFVIDM_VIEW_SVEXTLAST           (SFVIDM_VIEW_EXTFIRST + 0x000F)
#define SFVIDM_VIEW_EXTENDEDFIRST       (SFVIDM_VIEW_EXTFIRST + 0x0010)
#define SFVIDM_VIEW_EXTENDEDLAST        (SFVIDM_VIEW_EXTLAST)
// #define SFVIDM_VIEW_THUMBNAIL           (SFVIDM_VIEW_FIRST + 0x0021) defined above


#define SFVIDM_ARRANGE_FIRST            (SFVIDM_FIRST + 0x0050)
#define SFVIDM_ARRANGE_AUTO             (SFVIDM_ARRANGE_FIRST + 0x0001)
#define SFVIDM_ARRANGE_GRID             (SFVIDM_ARRANGE_FIRST + 0x0002)
#define SFVIDM_ARRANGE_DISPLAYICONS     (SFVIDM_ARRANGE_FIRST + 0x0003)
#define SFVIDM_ARRANGE_AUTOGRID         (SFVIDM_ARRANGE_FIRST + 0x0004)

#define SFVIDM_TOOL_FIRST               (SFVIDM_FIRST + 0x0060)
#define SFVIDM_TOOL_CONNECT             (SFVIDM_TOOL_FIRST + 0x0001)
#define SFVIDM_TOOL_DISCONNECT          (SFVIDM_TOOL_FIRST + 0x0002)
#define SFVIDM_TOOL_OPTIONS             (SFVIDM_TOOL_FIRST + 0x0003)
#define SFVIDM_DEBUG_WEBVIEW            (SFVIDM_TOOL_FIRST + 0x0004)

#define SFVIDM_HELP_FIRST               (SFVIDM_FIRST + 0x0070)
#define SFVIDM_HELP_TOPIC               (SFVIDM_HELP_FIRST + 0x0001)

#define SFVIDM_MISC_FIRST               (SFVIDM_FIRST + 0x0100)
#define SFVIDM_MISC_REFRESH             (SFVIDM_MISC_FIRST + 0x0003)
#define SFVIDM_MISC_HARDREFRESH         (SFVIDM_MISC_FIRST + 0x0004)

// Range for the client's additional menus
#define SFVIDM_CLIENT_FIRST             (SFVIDM_FIRST + 0x0200)
#define SFVIDM_CLIENT_LAST              (SFVIDM_FIRST + 0x02ff)

// ---- SFVIDM_UNUSED_FIRST             (SFVIDM_FIRST + 0x0300)

#define SFVIDM_DESKTOP_FIRST            (SFVIDM_FIRST + 0x0400)
#define SFVIDM_DESKTOPHTML_WEBCONTENT   (SFVIDM_DESKTOP_FIRST + 0x0001)
#define SFVIDM_DESKTOPHTML_ICONS        (SFVIDM_DESKTOP_FIRST + 0x0002)
#define SFVIDM_DESKTOPHTML_LOCK         (SFVIDM_DESKTOP_FIRST + 0x0003)
#define SFVIDM_DESKTOPHTML_WIZARD       (SFVIDM_DESKTOP_FIRST + 0x0004)
#define SFVIDM_DESKTOP_LAST             (SFVIDM_FIRST + 0x04ff)

#define SFVIDM_COLUMN_FIRST             (SFVIDM_FIRST + 0x0500)
#define SFVIDM_COLUMN_LAST              (SFVIDM_FIRST + 0x05ff)

#define SFVIDM_GROUPSEP                 (SFVIDM_FIRST + 0x0600)
#define SFVIDM_GROUPBY                  (SFVIDM_FIRST + 0x0601)
#define SFVIDM_GROUPSFIRST              (SFVIDM_FIRST + 0x0602)
#define SFVIDM_GROUPSLAST               (SFVIDM_FIRST + 0x067f)
#define SFVIDM_GROUPSEXTENDEDFIRST      (SFVIDM_FIRST + 0x0680)
#define SFVIDM_GROUPSEXTENDEDLAST       (SFVIDM_FIRST + 0x06ff)


// Range for context menu id's
#define SFVIDM_CONTEXT_FIRST            (SFVIDM_FIRST + 0x0800)
#define SFVIDM_CONTEXT_LAST             (SFVIDM_FIRST + 0x0900)
#define SFVIDM_BACK_CONTEXT_FIRST       (SFVIDM_FIRST + 0x0901)
#define SFVIDM_BACK_CONTEXT_LAST        (SFVIDM_FIRST + 0x09ff)


// DOC'ed for DOJ compliance:
;end_internal
typedef TBINFO * LPTBINFO;

typedef DETAILSINFO *PDETAILSINFO;
;begin_internal

typedef COPYHOOKINFO *LPCOPYHOOKINFO;


//                              uMsg                     wParam         lParam
#define DVM_MERGEMENU           SFVM_MERGEMENU        // uFlags             LPQCMINFO
#define DVM_INVOKECOMMAND       SFVM_INVOKECOMMAND    // idCmd              0
#define DVM_GETHELPTEXT         SFVM_GETHELPTEXT      // idCmd,cchMax       pszText - Ansi
#define DVM_GETTOOLTIPTEXT      SFVM_GETTOOLTIPTEXT   // idCmd,cchMax       pszText
#define DVM_GETBUTTONINFO       SFVM_GETBUTTONINFO    // 0                  LPTBINFO
#define DVM_GETBUTTONS          SFVM_GETBUTTONS       // idCmdFirst,cbtnMax LPTBBUTTON
#define DVM_INITMENUPOPUP       SFVM_INITMENUPOPUP    // idCmdFirst,nIndex  hmenu
#define DVM_SELCHANGE           SFVM_SELCHANGE        // idCmdFirst,nItem   PDVSELCHANGEINFO
#define DVM_DRAWITEM            SFVM_DRAWITEM         // idCmdFirst         pdis
#define DVM_MEASUREITEM         SFVM_MEASUREITEM      // idCmdFirst         pmis
#define DVM_EXITMENULOOP        SFVM_EXITMENULOOP     // -                  -
#define DVM_RELEASE             SFVM_PRERELEASE       // -                  lSelChangeInfo (ShellFolder private)
#define DVM_GETCCHMAX           SFVM_GETCCHMAX        // pidlItem           pcchMax
#define DVM_FSNOTIFY            SFVM_FSNOTIFY         // LPITEMIDLIST*      lEvent
#define DVM_WINDOWCREATED       SFVM_WINDOWCREATED    // hwnd               PDVSELCHANGEINFO
#define DVM_WINDOWDESTROY       SFVM_WINDOWDESTROY    // hwnd               PDVSELCHANGEINFO
#define DVM_REFRESH             SFVM_REFRESH          // -                  lSelChangeInfo
#define DVM_SETFOCUS            SFVM_SETFOCUS         // -                  lSelChangeInfo
#define DVM_KILLFOCUS           19                    // unused
#define DVM_QUERYCOPYHOOK       SFVM_QUERYCOPYHOOK    // -                  -
#define DVM_NOTIFYCOPYHOOK      SFVM_NOTIFYCOPYHOOK   // -                  LPCOPYHOOKINFO
#define DVM_NOTIFY              SFVM_NOTIFY           // idFrom             LPNOTIFY
#define DVM_GETDETAILSOF        SFVM_GETDETAILSOF     // iColumn            PDETAILSINFO
#define DVM_COLUMNCLICK         SFVM_COLUMNCLICK      // iColumn            -
#define DVM_QUERYFSNOTIFY       SFVM_QUERYFSNOTIFY    // -                  FSNotifyEntry *
#define DVM_DEFITEMCOUNT        SFVM_DEFITEMCOUNT     // -                  PINT
#define DVM_DEFVIEWMODE         SFVM_DEFVIEWMODE      // -                  PFOLDERVIEWMODE
#define DVM_UNMERGEMENU         SFVM_UNMERGEMENU      // uFlags
#define DVM_INSERTITEM          SFVM_INSERTITEM       // pidl               PDVSELCHANGEINFO
#define DVM_DELETEITEM          SFVM_DELETEITEM       // pidl               PDVSELCHANGEINFO
#define DVM_UPDATESTATUSBAR     SFVM_UPDATESTATUSBAR  // -                  lSelChangeInfo
#define DVM_BACKGROUNDENUM      SFVM_BACKGROUNDENUM   //
#define DVM_GETWORKINGDIR       SFVM_GETWORKINGDIR    //
#define DVM_GETCOLSAVESTREAM    SFVM_GETCOLSAVESTREAM // flags              IStream **
#define DVM_SELECTALL           SFVM_SELECTALL        //                    lSelChangeInfo
#define DVM_DIDDRAGDROP         SFVM_DIDDRAGDROP      // dwEffect           IDataObject *
#define DVM_SUPPORTSIDENTIFY    SFVM_SUPPORTSIDENTITY // -                  -
#define DVM_FOLDERISPARENT      SFVM_FOLDERISPARENT   // -                  pidlChild

// max length for guid strings
#define GUIDSTR_MAX (1+ 8 + 1 + 4 + 1 + 4 + 1 + 4 + 1 + 12 + 1 + 1)

typedef struct _DVSELCHANGEINFO {
    UINT uOldState;
    UINT uNewState;
    LPARAM lParamItem;
    LPARAM* plParam;
} DVSELCHANGEINFO, *PDVSELCHANGEINFO;

// DOC'ed for DOJ compliance:
;end_internal

typedef HRESULT (CALLBACK * LPFNVIEWCALLBACK)(IShellView *psvOuter,
                                                IShellFolder *psf,
                                                HWND hwndMain,
                                                UINT uMsg,
                                                WPARAM wParam,
                                                LPARAM lParam);

// SHCreateShellFolderViewEx struct
typedef struct _CSFV
{
    UINT            cbSize;
    IShellFolder *  pshf;
    IShellView *    psvOuter;
    LPCITEMIDLIST   pidl;
    LONG            lEvents;
    LPFNVIEWCALLBACK pfnCallback;       // No callback if NULL
    FOLDERVIEWMODE  fvm;
} CSFV, * LPCSFV;


;begin_internal
// DOC'ed for DOJ Compliance
;end_internal
// Tell the FolderView to rearrange.  The lParam will be passed to
// IShellFolder::CompareIDs
#define SFVM_REARRANGE          0x00000001
#define ShellFolderView_ReArrange(_hwnd, _lparam) \
        (BOOL)SHShellFolderView_Message(_hwnd, SFVM_REARRANGE, _lparam)
;begin_internal

// Get the last sorting parameter given to FolderView
#define SFVM_GETARRANGEPARAM    0x00000002
#define ShellFolderView_GetArrangeParam(_hwnd) \
        (LPARAM)SHShellFolderView_Message(_hwnd, SFVM_GETARRANGEPARAM, 0L)

// DOC'ed for DOJ Compliance
;end_internal
// Add an OBJECT into the view
#define SFVM_ADDOBJECT         0x00000003
#define ShellFolderView_AddObject(_hwnd, _pidl) \
        (LPARAM)SHShellFolderView_Message(_hwnd, SFVM_ADDOBJECT, (LPARAM)_pidl)
;begin_internal

// Gets the count of objects in the view
#define SFVM_GETOBJECTCOUNT         0x00000004
#define ShellFolderView_GetObjectCount(_hwnd) \
        (LPARAM)SHShellFolderView_Message(_hwnd, SFVM_GETOBJECTCOUNT, (LPARAM)0)

// Returns a pointer to the Idlist associated with the specified index
// Returns NULL if at end of list.
#define SFVM_GETOBJECT         0x00000005
#define ShellFolderView_GetObject(_hwnd, _iObject) \
        (LPARAM)SHShellFolderView_Message(_hwnd, SFVM_GETOBJECT, _iObject)

// DOC'ed for DOJ Compliance
;end_internal
// Remove an OBJECT into the view
#define SFVM_REMOVEOBJECT         0x00000006
#define ShellFolderView_RemoveObject(_hwnd, _pidl) \
        (LPARAM)SHShellFolderView_Message(_hwnd, SFVM_REMOVEOBJECT, (LPARAM)_pidl)

// updates an object by passing in pointer to two PIDLS, the first
// is the old pidl, the second one is the one with update information.
//
// _ppidl[1] must be a *copy* of a pidl, as control over the lifetime
// of the pidl belongs to the view after successful completion of
// this call.  (Unsuccessful completion (a -1 return) implies failure
// and the caller must free the memory.)  Win95 waits a while before
// freeing the pidl, IE4 frees the pidl immediately.
// IShellFolderView::UpdateObject does not suffer from this problem.
//
#define SFVM_UPDATEOBJECT         0x00000007
#define ShellFolderView_UpdateObject(_hwnd, _ppidl) \
        (LPARAM)SHShellFolderView_Message(_hwnd, SFVM_UPDATEOBJECT, (LPARAM)_ppidl)


;begin_internal
// Sets the redraw mode for the window that is displaying the information
#define SFVM_SETREDRAW           0x00000008
#define ShellFolderView_SetRedraw(_hwnd, fRedraw) \
        (LPARAM)SHShellFolderView_Message(_hwnd, SFVM_SETREDRAW, (LPARAM)fRedraw)

// DOC'ed for DOJ Compliance
;end_internal
// Returns an array of the selected IDS to the caller.
//     lparam is a pointer to receive the idlists into
//     return value is the count of items in the array.
#define SFVM_GETSELECTEDOBJECTS 0x00000009
#define ShellFolderView_GetSelectedObjects(_hwnd, ppidl) \
        (LPARAM)SHShellFolderView_Message(_hwnd, SFVM_GETSELECTEDOBJECTS, (LPARAM)ppidl)
;begin_internal

// Checks if the current drop is on the view window
//     lparam is unused
//     return value is TRUE if the current drop is upon the background of the
//         view window, FALSE otherwise
#define SFVM_ISDROPONSOURCE     0x0000000a
#define ShellFolderView_IsDropOnSource(_hwnd, _pdtgt) \
        (BOOL)SHShellFolderView_Message(_hwnd, SFVM_ISDROPONSOURCE, (LPARAM)_pdtgt)

// Moves the selected icons in the listview
//     lparam is a pointer to a drop target
//     return value is unused
#define SFVM_MOVEICONS          0x0000000b
#define ShellFolderView_MoveIcons(_hwnd, _pdt) \
        (void)SHShellFolderView_Message(_hwnd, SFVM_MOVEICONS, (LPARAM)(LPDROPTARGET)_pdt)

// Gets the start point of a drag-drop
//     lparam is a pointer to a point
//     return value is unused
#define SFVM_GETDRAGPOINT       0x0000000c
#define ShellFolderView_GetDragPoint(_hwnd, _ppt) \
        (BOOL)SHShellFolderView_Message(_hwnd, SFVM_GETDRAGPOINT, (LPARAM)(LPPOINT)_ppt)

// Gets the end point of a drag-drop
//     lparam is a pointer to a point
//     return value is unused
#define SFVM_GETDROPPOINT       0x0000000d
#define ShellFolderView_GetDropPoint(_hwnd, _ppt) \
        SHShellFolderView_Message(_hwnd, SFVM_GETDROPPOINT, (LPARAM)(LPPOINT)_ppt)

#define ShellFolderView_GetAnchorPoint(_hwnd, _fStart, _ppt) \
        (BOOL)((_fStart) ? ShellFolderView_GetDragPoint(_hwnd, _ppt) : ShellFolderView_GetDropPoint(_hwnd, _ppt))


// DOC'ed for DOJ Compliance
;end_internal
typedef struct _SFV_SETITEMPOS
{
        LPCITEMIDLIST pidl;
        POINT pt;
} SFV_SETITEMPOS, *LPSFV_SETITEMPOS;

// Sets the position of an item in the viewer
//     lparam is a pointer to a SVF_SETITEMPOS
//     return value is unused
#define SFVM_SETITEMPOS         0x0000000e
#define ShellFolderView_SetItemPos(_hwnd, _pidl, _x, _y) \
{       SFV_SETITEMPOS _sip = {_pidl, {_x, _y}}; \
        SHShellFolderView_Message(_hwnd, SFVM_SETITEMPOS, (LPARAM)(LPSFV_SETITEMPOS)&_sip);}
;begin_internal


// Determines if a given drop target interface is the one being used for
// the background of the ShellFolderView (as opposed to an object in the
// view)
//     lparam is a pointer to a drop target interface
//     return value is TRUE if it is the background drop target, FALSE otherwise
#define SFVM_ISBKDROPTARGET     0x0000000f
#define ShellFolderView_IsBkDropTarget(_hwnd, _pdptgt) \
        (BOOL)SHShellFolderView_Message(_hwnd, SFVM_ISBKDROPTARGET, (LPARAM)(LPDROPTARGET)_pdptgt)


// DOC'ed for DOJ Compliance
;end_internal
//  Notifies a ShellView when one of its objects get put on the clipboard
//  as a result of a menu command.
//
//  called by defcm.c when it does a copy/cut ;internal
//
//     lparam is the dwEffect (DROPEFFECT_MOVE, DROPEFFECT_COPY)
//     return value is void.
#define SFVM_SETCLIPBOARD       0x00000010
#define ShellFolderView_SetClipboard(_hwnd, _dwEffect) \
        (void)SHShellFolderView_Message(_hwnd, SFVM_SETCLIPBOARD, (LPARAM)(DWORD)(_dwEffect))
;begin_internal

// sets auto arrange
#define SFVM_AUTOARRANGE        0x00000011
#define ShellFolderView_AutoArrange(_hwnd) \
        (void)SHShellFolderView_Message(_hwnd, SFVM_AUTOARRANGE, 0)

// sets snap to grid
#define SFVM_ARRANGEGRID        0x00000012
#define ShellFolderView_ArrangeGrid(_hwnd) \
        (void)SHShellFolderView_Message(_hwnd, SFVM_ARRANGEGRID, 0)

#define SFVM_GETAUTOARRANGE     0x00000013
#define ShellFolderView_GetAutoArrange(_hwnd) \
        (BOOL)SHShellFolderView_Message(_hwnd, SFVM_GETAUTOARRANGE, 0)

#define SFVM_GETSELECTEDCOUNT     0x00000014
#define ShellFolderView_GetSelectedCount(_hwnd) \
        (BOOL)SHShellFolderView_Message(_hwnd, SFVM_GETSELECTEDCOUNT, 0)

typedef ITEMSPACING *LPITEMSPACING;

#define SFVM_GETITEMSPACING     0x00000015
#define ShellFolderView_GetItemSpacing(_hwnd, lpis) \
        (BOOL)SHShellFolderView_Message(_hwnd, SFVM_GETITEMSPACING, (LPARAM)lpis)

// Causes an object to be repainted
#define SFVM_REFRESHOBJECT      0x00000016
#define ShellFolderView_RefreshObject(_hwnd, _ppidl) \
        (LPARAM)SHShellFolderView_Message(_hwnd, SFVM_REFRESHOBJECT, (LPARAM)_ppidl)

// Causes the the whole view to be refreshed
#define ShellFolderView_RefreshAll(_hwnd) \
        (LPARAM)PostMessage(_hwnd, WM_KEYDOWN, (WPARAM)VK_F5, (LPARAM)0);


// DOC'ed for DOJ Compliance
;end_internal
#define SFVM_SETPOINTS           0x00000017
#define ShellFolderView_SetPoints(_hwnd, _pdtobj) \
        (void)SHShellFolderView_Message(_hwnd, SFVM_SETPOINTS, (LPARAM)_pdtobj)
;begin_internal

// SVM_SELECTANDPOSITIONITEM lParam
typedef struct
{
        LPCITEMIDLIST pidl;     // relative pidl to the view
        UINT  uSelectFlags;     // select flags
        BOOL fMove; // if true, we should also move it to point pt
        POINT pt;
} SFM_SAP;

// shell view messages
#define SVM_SELECTITEM                  (WM_USER + 1)
#define SVM_SELECTANDPOSITIONITEM       (WM_USER + 5)

;end_internal
;begin_both
#include <poppack.h>        /* Return to byte packing */
;end_both
;begin_internal

//===========================================================================
// CDefShellFolder members (for easy subclassing)
//===========================================================================

// Default implementation (no dependencies to the instance data)
STDMETHODIMP CDefShellFolder_QueryInterface(IShellFolder *psf, REFIID riid, void **ppv);
STDMETHODIMP CDefShellFolder_BindToStorage(IShellFolder *psf, LPCITEMIDLIST pidl, LPBC pbc, REFIID riid, void **ppv);
STDMETHODIMP CDefShellFolder_BindToObject(IShellFolder *psf, LPCITEMIDLIST pidl, LPBC pbc, REFIID riid, void **ppv);
STDMETHODIMP CDefShellFolder_GetAttributesOf(IShellFolder *psf, UINT cidl, LPCITEMIDLIST * apidl, ULONG * rgfOut);
STDMETHODIMP CDefShellFolder_SetNameOf(IShellFolder *psf, HWND hwndOwner, LPCITEMIDLIST pidl, LPCOLESTR pszName, DWORD dwReserved, LPITEMIDLIST * ppidlOut);

// File Search APIS
// DOC'ed for DOJ compliance
;end_internal
SHSTDAPI_(IContextMenu *) SHFind_InitMenuPopup(HMENU hmenu, HWND hwndOwner, UINT idCmdFirst, UINT idCmdLast);
;begin_internal

SHSTDAPI_(void) Control_RunDLL(HWND hwndStub, HINSTANCE hAppInstance, LPSTR pszCmdLine, int nCmdShow);
SHSTDAPI_(void) Control_RunDLLW(HWND hwndStub, HINSTANCE hAppInstance, LPWSTR pszCmdLine, int nCmdShow);
SHSTDAPI_(void) Control_RunDLLAsUserW(HWND hwndStub, HINSTANCE hAppInstance, LPWSTR lpwszCmdLine, int nCmdShow);


// to add 16 bit pages to 32bit things.  hGlobal can be NULL
SHSTDAPI_(UINT) SHAddPages16(HGLOBAL hGlobal, LPCTSTR pszDllEntry, LPFNADDPROPSHEETPAGE pfnAddPage, LPARAM lParam);

// DOC'ed for DOJ compliance
;end_internal
SHSTDAPI SHCreateShellFolderViewEx(LPCSFV pcsfv, IShellView ** ppsv);
;begin_internal

// Access to MSHMTL's ditherer

/* Definition of interface: IIntDitherer */
#undef INTERFACE
#define INTERFACE IIntDitherer

DECLARE_INTERFACE_(IIntDitherer, IUnknown)
{
#ifndef NO_BASEINTERFACE_FUNCS
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface)(THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG, AddRef)(THIS) PURE;
    STDMETHOD_(ULONG, Release)(THIS) PURE;
#endif

    // *** IIntDitherer methods ***
    STDMETHOD(DitherTo8bpp)(THIS_ BYTE * pDestBits, LONG nDestPitch,
                    BYTE * pSrcBits, LONG nSrcPitch, REFGUID bfidSrc,
                    RGBQUAD * prgbDestColors, RGBQUAD * prgbSrcColors,
                    BYTE * pbDestInvMap,
                    LONG x, LONG y, LONG cx, LONG cy,
                    LONG lDestTrans, LONG lSrcTrans) PURE;
};

#ifdef COBJMACROS


#define IntDitherer_QueryInterface(This,riid,ppvObject) \
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define IntDitherer_AddRef(This)    \
    (This)->lpVtbl -> AddRef(This)

#define IntDitherer_Release(This)   \
    (This)->lpVtbl -> Release(This)

#define IntDitherer_DitherTo8bpp(This, pDestBits, nDestPitch, \
                    pSrcBits, nSrcPitch, bfidSrc, \
                    prgbDestColors, prgbSrcColors, \
                    pbDestInvMap, x, y, cx, cy, \
                    lDestTrans, lSrcTrans)  \
    (This)->lpVtbl -> DitherTo8bpp(This, pDestBits, nDestPitch, pSrcBits, nSrcPitch, bfidSrc, \
                    prgbDestColors, prgbSrcColors, pbDestInvMap, x, y, cx, cy, lDestTrans, lSrcTrans)

#endif

;end_internal


//
// PROPIDs for Internet Shortcuts (FMTID_Intshcut) to be used with
// IPropertySetStorage/IPropertyStorage
//
// The known property ids and their variant types are:
//      PID_IS_URL          [VT_LPWSTR]   URL
//      PID_IS_SCHEME       [VT_UI4]      Scheme value          ;Internal
//      PID_IS_NAME         [VT_LPWSTR]   Name of the internet shortcut
//      PID_IS_WORKINGDIR   [VT_LPWSTR]   Working directory for the shortcut
//      PID_IS_HOTKEY       [VT_UI2]      Hotkey for the shortcut
//      PID_IS_SHOWCMD      [VT_I4]       Show command for shortcut
//      PID_IS_ICONINDEX    [VT_I4]       Index into file that has icon
//      PID_IS_ICONFILE     [VT_LPWSTR]   File that has the icon
//      PID_IS_WHATSNEW     [VT_LPWSTR]   What's New text
//      PID_IS_AUTHOR       [VT_LPWSTR]   Author
//      PID_IS_DESCRIPTION  [VT_LPWSTR]   Description text of site
//      PID_IS_COMMENT      [VT_LPWSTR]   User annotated comment
//

#define PID_IS_FIRST         2                          ;Internal
#define PID_IS_URL           2
#define PID_IS_SCHEME        3                          ;Internal
#define PID_IS_NAME          4
#define PID_IS_WORKINGDIR    5
#define PID_IS_HOTKEY        6
#define PID_IS_SHOWCMD       7
#define PID_IS_ICONINDEX     8
#define PID_IS_ICONFILE      9
#define PID_IS_WHATSNEW      10
#define PID_IS_AUTHOR        11
#define PID_IS_DESCRIPTION   12
#define PID_IS_COMMENT       13
#define PID_IS_IDLIST        14                         ;Internal
#define PID_IS_LAST          14                         ;Internal


//
// PROPIDs for Internet Sites (FMTID_InternetSite) to be used with
// IPropertySetStorage/IPropertyStorage
//
// The known property ids and their variant types are:
//      PID_INTSITE_WHATSNEW     [VT_LPWSTR]   What's New text
//      PID_INTSITE_AUTHOR       [VT_LPWSTR]   Author
//      PID_INTSITE_LASTVISIT    [VT_FILETIME] Time site was last visited
//      PID_INTSITE_LASTMOD      [VT_FILETIME] Time site was last modified
//      PID_INTSITE_VISITCOUNT   [VT_UI4]      Number of times user has visited
//      PID_INTSITE_DESCRIPTION  [VT_LPWSTR]   Description text of site
//      PID_INTSITE_COMMENT      [VT_LPWSTR]   User annotated comment
//      PID_INTSITE_FLAGS        [VT_UI4]      PIDISF_ flags         ;Internal
//      PID_INTSITE_CONTENTLEN   [VT_UI4]      Content length        ;Internal
//      PID_INTSITE_CONTENTCODE  [VT_UI8]      Content code          ;Internal
//      PID_INTSITE_RECURSE      [VT_UI4]      Levels to recurse (0-3)
//      PID_INTSITE_WATCH        [VT_UI4]      PIDISM_ flags
//      PID_INTSITE_SUBSCRIPTION [VT_UI8]      Subscription cookie
//      PID_INTSITE_URL          [VT_LPWSTR]   URL
//      PID_INTSITE_TITLE        [VT_LPWSTR]   Title
//      PID_INTSITE_FRAGMENT     [VT_NULL]     Fragments             ;Internal
//      PID_INTSITE_CODEPAGE     [VT_UI4]      Codepage of the document
//      PID_INTSITE_TRACKING     [VT_UI4]      Tracking
//      PID_INTSITE_ICONINDEX    [VT_I4]       Retrieve the index to the icon
//      PID_INTSITE_ICONFILE     [VT_LPWSTR]   Retrieve the file containing the icon index.


#define PID_INTSITE_FIRST         2                         ;Internal
#define PID_INTSITE_WHATSNEW      2
#define PID_INTSITE_AUTHOR        3
#define PID_INTSITE_LASTVISIT     4
#define PID_INTSITE_LASTMOD       5
#define PID_INTSITE_VISITCOUNT    6
#define PID_INTSITE_DESCRIPTION   7
#define PID_INTSITE_COMMENT       8
#define PID_INTSITE_FLAGS         9
#define PID_INTSITE_CONTENTLEN    10
#define PID_INTSITE_CONTENTCODE   11
#define PID_INTSITE_RECURSE       12
#define PID_INTSITE_WATCH         13
#define PID_INTSITE_SUBSCRIPTION  14
#define PID_INTSITE_URL           15
#define PID_INTSITE_TITLE         16
#define PID_INTSITE_FRAGMENT      17                        ;Internal
#define PID_INTSITE_CODEPAGE      18
#define PID_INTSITE_TRACKING      19
#define PID_INTSITE_ICONINDEX     20
#define PID_INTSITE_ICONFILE      21

#define PID_INTSITE_LAST          21                        ;Internal

// Flags for PID_IS_FLAGS
#define PIDISF_RECENTLYCHANGED  0x00000001
#define PIDISF_CACHEDSTICKY     0x00000002
#define PIDISF_CACHEIMAGES      0x00000010
#define PIDISF_FOLLOWALLLINKS   0x00000020
  //Is URL entered in IE history bucket?                   ; Internal
#define PIDISF_HISTORY          0x10000000                 ; Internal

// Values for PID_INTSITE_WATCH
#define PIDISM_GLOBAL           0       // Monitor based on global setting
#define PIDISM_WATCH            1       // User says watch
#define PIDISM_DONTWATCH        2       // User says don't watch


////////////////////////////////////////////////////////////////////
//
// The shell keeps track of some per-user state to handle display
// options that is of major interest to ISVs.
// The key one requested right now is "DoubleClickInWebView".
;begin_internal
// Athena needs this to determine whether to double click or not.
//
// NOTE: if user uninstalls IE4, the Win95 code will
// realize that the size has changed (even though it's not
// in this struct, it is saved) and drop back to default state.
//
// Since we're exporting this so ISVs can get access to our flags,
// let's avoid the need for a thunk and export the beginning section
// of this structure ONLY. Here are the A and W versions for internal use:
//
// DOC'ed for DOJ compliance
;end_internal

typedef struct {
    // These were in Win95 //;Internal
    BOOL fShowAllObjects : 1;
    BOOL fShowExtensions : 1;
    BOOL fNoConfirmRecycle : 1;

    // The below were added for IE4 //;Internal
    BOOL fShowSysFiles : 1;
    BOOL fShowCompColor : 1;
    BOOL fDoubleClickInWebView : 1;
    BOOL fDesktopHTML : 1;
    BOOL fWin95Classic : 1;
    BOOL fDontPrettyPath : 1;
    BOOL fShowAttribCol : 1; // No longer used, dead bit
    BOOL fMapNetDrvBtn : 1;
    BOOL fShowInfoTip : 1;
    BOOL fHideIcons : 1;
    BOOL fWebView : 1;
    BOOL fFilter : 1;
    BOOL fShowSuperHidden : 1;
    BOOL fNoNetCrawling : 1;

    DWORD dwWin95Unused; // Win95 only - no longer supported pszHiddenFileExts
    UINT  uWin95Unused; // Win95 only - no longer supported cbHiddenFileExts

;begin_internal
    // These must have been an OSR release, as they aren't on \\guilo\slmadd\src\dev\inc16\shsemip.h
;end_internal
    // Note: Not a typo!  This is a persisted structure so we cannot use LPARAM
    LONG   lParamSort;
    int    iSortDirection;

;begin_internal
    // This was added for IE4
;end_internal
    UINT   version;

    // new for win2k. need notUsed var to calc the right size of ie4 struct
    // FIELD_OFFSET does not work on bit fields
    UINT uNotUsed; // feel free to rename and use
    BOOL fSepProcess: 1;

    // new for Whistler.
    BOOL fStartPanelOn: 1;       //Indicates if the Whistler StartPanel mode is ON or OFF.

    BOOL fShowStartPage: 1;      //Indicates if the Whistler StartPage on desktop is ON or OFF.

    // If you need a new flag, steal a bit from from fSpareFlags.;internal
    UINT fSpareFlags : 13;

    //                                                      ;internal
    // If you add any fields to this structure, you         ;internal
    // must also add upgrade code to shell32\util.cpp.      ;internal
    //                                                      ;internal
} SHELLSTATEA, *LPSHELLSTATEA;

typedef struct {
    BOOL fShowAllObjects : 1;
    BOOL fShowExtensions : 1;
    BOOL fNoConfirmRecycle : 1;
    BOOL fShowSysFiles : 1;
    BOOL fShowCompColor : 1;
    BOOL fDoubleClickInWebView : 1;
    BOOL fDesktopHTML : 1;
    BOOL fWin95Classic : 1;
    BOOL fDontPrettyPath : 1;
    BOOL fShowAttribCol : 1;
    BOOL fMapNetDrvBtn : 1;
    BOOL fShowInfoTip : 1;
    BOOL fHideIcons : 1;
    BOOL fWebView : 1;
    BOOL fFilter : 1;
    BOOL fShowSuperHidden : 1;
    BOOL fNoNetCrawling : 1;

    DWORD dwWin95Unused; // Win95 only - no longer supported pszHiddenFileExts
    UINT  uWin95Unused; // Win95 only - no longer supported cbHiddenFileExts

    // Note: Not a typo!  This is a persisted structure so we cannot use LPARAM
    LONG   lParamSort;
    int    iSortDirection;
    UINT   version;

    // new for win2k. need notUsed var to calc the right size of ie4 struct
    // FIELD_OFFSET does not work on bit fields
    UINT uNotUsed; // feel free to rename and use
    BOOL fSepProcess: 1;

    // new for Whistler.
    BOOL fStartPanelOn: 1;       //Indicates if the Whistler StartPage mode is ON or OFF.

    BOOL fShowStartPage: 1;      //Indicates if the Whistler StartPage on desktop is ON or OFF.

    // If you need a new flag, steal a bit from from fSpareFlags.
    UINT fSpareFlags : 13;


    //                                                      ;internal
    // If you add any fields to this structure, you         ;internal
    // must also add upgrade code to shell32\util.cpp.      ;internal
    //                                                      ;internal
} SHELLSTATEW, *LPSHELLSTATEW;

#define SHELLSTATEVERSION_IE4   9
#define SHELLSTATEVERSION_WIN2K 10
#define SHELLSTATEVERSION 13 // rev if defaults change but size doesn't //;Internal

#ifdef UNICODE
#define SHELLSTATE   SHELLSTATEW
#define LPSHELLSTATE LPSHELLSTATEW
#else
#define SHELLSTATE   SHELLSTATEA
#define LPSHELLSTATE LPSHELLSTATEA
#endif

#define SHELLSTATE_SIZE_WIN95 FIELD_OFFSET(SHELLSTATE,lParamSort)
#define SHELLSTATE_SIZE_NT4   FIELD_OFFSET(SHELLSTATE,version)
#define SHELLSTATE_SIZE_IE4   FIELD_OFFSET(SHELLSTATE,uNotUsed)
#define SHELLSTATE_SIZE_WIN2K sizeof(SHELLSTATE)

SHSTDAPI_(void) SHGetSetSettings(LPSHELLSTATE lpss, DWORD dwMask, BOOL bSet);

;begin_internal
// And here's the beginning portion for public use:
;end_internal
//
//  SysFiles are these windows special files:
//      "dll sys vxd 386 drv"
//
//  hidden files are files with the FILE_ATTRIBUTE_HIDDEN attribute
//
//  system files are files with the FILE_ATTRIBUTE_SYSTEM attribute
//
//      fShowAllObjects fShowSysFiles   Result
//      --------------- -------------   ------
//      0               0               hide hidden + SysFiles + system files
//      0               1               hide hidden files.
//      1               0               show all files.
//      1               1               show all files.
//
typedef struct {
    BOOL fShowAllObjects : 1;
    BOOL fShowExtensions : 1;
    BOOL fNoConfirmRecycle : 1;
    BOOL fShowSysFiles : 1;
    BOOL fShowCompColor : 1;
    BOOL fDoubleClickInWebView : 1;
    BOOL fDesktopHTML : 1;
    BOOL fWin95Classic : 1;
    BOOL fDontPrettyPath : 1;
    BOOL fShowAttribCol : 1;
    BOOL fMapNetDrvBtn : 1;
    BOOL fShowInfoTip : 1;
    BOOL fHideIcons : 1;
    UINT fRestFlags : 3;
} SHELLFLAGSTATE, *LPSHELLFLAGSTATE;

#define SSF_SHOWALLOBJECTS          0x00000001
#define SSF_SHOWEXTENSIONS          0x00000002
#define SSF_HIDDENFILEEXTS          0x00000004  // ;Internal - not supported
#define SSF_SHOWCOMPCOLOR           0x00000008
#define SSF_SORTCOLUMNS             0x00000010  // ;Internal - corresponding SHELLSTATE fields don't exist in SHELLFLAGSTATE
#define SSF_SHOWSYSFILES            0x00000020
#define SSF_DOUBLECLICKINWEBVIEW    0x00000080
#define SSF_SHOWATTRIBCOL           0x00000100
#define SSF_DESKTOPHTML             0x00000200
#define SSF_WIN95CLASSIC            0x00000400
#define SSF_DONTPRETTYPATH          0x00000800
#define SSF_SHOWINFOTIP             0x00002000
#define SSF_MAPNETDRVBUTTON         0x00001000
#define SSF_NOCONFIRMRECYCLE        0x00008000
#define SSF_HIDEICONS               0x00004000
#define SSF_FILTER                  0x00010000  // ;Internal - corresponding SHELLSTATE fields don't exist in SHELLFLAGSTATE
#define SSF_WEBVIEW                 0x00020000  // ;Internal
#define SSF_SHOWSUPERHIDDEN         0x00040000  // ;Internal
#define SSF_SEPPROCESS              0x00080000  // ;Internal
#define SSF_NONETCRAWLING           0x00100000  // ;Internal
#define SSF_STARTPANELON            0x00200000  // ;Internal
#define SSF_SHOWSTARTPAGE           0x00400000  // ;Internal

// SHGetSettings(LPSHELLFLAGSTATE lpss, DWORD dwMask)
//
// Specify the bits you are interested in in dwMask and they will be
// filled out in the lpss structure.
//
// When these settings change, a WM_SETTINGCHANGE message is sent
// with the string lParam value of "ShellState".
//
SHSTDAPI_(void) SHGetSettings(LPSHELLFLAGSTATE lpsfs, DWORD dwMask);

// SHBindToParent(LPCITEMIDLIST pidl, REFIID riid, void **ppv, LPCITEMIDLIST *ppidlLast)
//
// Given a pidl, you can get an interface pointer (as specified by riid) of the pidl's parent folder (in ppv)
// If ppidlLast is non-NULL, you can also get the pidl of the last item.
//
SHSTDAPI SHBindToParent(LPCITEMIDLIST pidl, REFIID riid, void **ppv, LPCITEMIDLIST *ppidlLast);

// SHSTDAPI SHParseDisplayName(PCWSTR pszName, IBindCtx *pbc, LPITEMIDLIST *ppidl, SFGAOF sfgaoIn, SFGAOF *psfgaoOut)
//
//  given a string it will call psfDesktop->ParseDisplayName() to try and create a pidl
//  if no pbc specified, it uses the preferred options for parsing.
//  this includes mapping file system paths to their appropriate aliased location (RegisterObjectParam(STR_PARSE_TRANSLATE_ALIASES))
//  psfgaoOut is optional for SFGAO attributes
//
SHSTDAPI SHParseDisplayName(PCWSTR pszName, IBindCtx *pbc, LPITEMIDLIST *ppidl, SFGAOF sfgaoIn, SFGAOF *psfgaoOut);


// SHPathPrepareForWrite(HWND hwnd, IUnknown *punkEnableModless, LPCTSTR pszPath, DWORD dwFlags)
//
// DESCRIPTION:
//     This API will prepare the path for the caller.  This includes:
// 1. Prompting for the ejectable media to be re-inserted. (Floppy, CD-ROM, ZIP drive, etc.)
// 2. Prompting for the media to be formatted. (Floppy, hard drive, etc.)
// 3. Remount mapped drives if the connection was lost. (\\unc\share mapped to N: becomes disconnected)
// 4. If the path doesn't exist, create it.  (SHPPFW_DIRCREATE and SHPPFW_ASKDIRCREATE)
// 5. Display an error if the media is read only. (SHPPFW_NOWRITECHECK not set)
//
// PARAMETERS:
//      hwnd: Parernt window for UI.  NULL means don't display UI. OPTIONAL
//      punkEnableModless: Parent that will be set to modal during UI using IOleInPlaceActiveObject::EnableModeless(). OPTIONAL
//      pszPath: Path to verify is valid for writting.  This can be a UNC or file drive path.  The path
//               should only contain directories.  Pass SHPPFW_IGNOREFILENAME if the last path segment
//               is always filename to ignore.
//      dwFlags: SHPPFW_* Flags to modify behavior
//
//-------------------------------------------------------------------------
#define SHPPFW_NONE             0x00000000
#define SHPPFW_DEFAULT          SHPPFW_DIRCREATE        // May change
#define SHPPFW_DIRCREATE        0x00000001              // Create the directory if it doesn't exist without asking the user.
#define SHPPFW_ASKDIRCREATE     0x00000002              // Create the directory if it doesn't exist after asking the user.
#define SHPPFW_IGNOREFILENAME   0x00000004              // Ignore the last item in pszPath because it's a file.  Example: pszPath="C:\DirA\DirB", only use "C:\DirA".
#define SHPPFW_NOWRITECHECK     0x00000008              // Caller only needs to read from the drive, so don't check if it's READ ONLY.
#define SHPPFW_MEDIACHECKONLY   0x00000010              // do the retrys on the media (or net path), return errors if the file can't be found

SHSTDAPI SHPathPrepareForWrite%(HWND hwnd, IUnknown *punkEnableModless, LPCTSTR% pszPath, DWORD dwFlags);





//--------------------------------------------------------------------------
//
// Interface used for exposing the INI file methods on a shortcut file
//
//
//--------------------------------------------------------------------------
#undef  INTERFACE
#define INTERFACE  INamedPropertyBag
DECLARE_INTERFACE_(INamedPropertyBag, IUnknown)
{
    // *** IUnknown methods ***
    STDMETHOD(QueryInterface)   (THIS_ REFIID riid, void **ppv) PURE;
    STDMETHOD_(ULONG,AddRef)    (THIS) PURE;
    STDMETHOD_(ULONG,Release)   (THIS) PURE;
    // *** INamedPropertyBag methods ***
    STDMETHOD(ReadPropertyNPB) (THIS_  /* [in] */ LPCOLESTR pszBagname,
                            /* [in] */ LPCOLESTR pszPropName,
                            /* [out][in] */ PROPVARIANT *pVar) PURE;

    STDMETHOD(WritePropertyNPB)(THIS_ /* [in] */ LPCOLESTR pszBagname,
                           /* [in] */ LPCOLESTR pszPropName,
                           /* [in] */ PROPVARIANT  *pVar) PURE;

    STDMETHOD(RemovePropertyNPB)(THIS_ /* [in] */ LPCOLESTR pszBagname,
                          /* [in] */ LPCOLESTR pszPropName) PURE;
};

#ifdef __urlmon_h__
//    NOTE: urlmon.h must be included before shlobj.h to access this function.
//
//    SoftwareUpdateMessageBox
//
//    Provides a standard message box for the alerting the user that a software
//    update is available or installed. No UI will be displayed if there is no
//    update available or if the available update version is less than or equal
//    to the Advertised update version.
//
//    hWnd                - [in] Handle of owner window
//    szDistUnit          - [in] Unique identifier string for a code distribution unit. For
//                               ActiveX controls and Active Setup installed components, this
//                               is typically a GUID string.
//    dwFlags             - [in] Must be 0.
//    psdi                - [in,out] Pointer to SOFTDISTINFO ( see URLMon.h ). May be NULL.
//                                cbSize should be initialized
//                                by the caller to sizeof(SOFTDISTINFO), dwReserved should be set to 0.
//
//    RETURNS:
//
//    IDNO     - The user chose cancel. If *pbRemind is FALSE, the caller should save the
//               update version from the SOFTDISTINFO and pass it in as the Advertised
//               version in future calls.
//
//    IDYES    - The user has selected Update Now/About Update. The caller should navigate to
//               the SOFTDISTINFO's pszHREF to initiate the install or learn about it.
//               The caller should save the update version from the SOFTDISTINFO and pass
//               it in as the Advertised version in future calls.
//
//    IDIGNORE - There is no pending software update. Note: There is
//               no Ignore button in the standard UI. This occurs if the available
//               version is less than the installed version or is not present or if the
//               Advertised version is greater than or equal to the update version.
//
//    IDABORT  - An error occured. Call GetSoftwareUpdateInfo() for a more specific HRESULT.
//               Note: There is no Abort button in the standard UI.


SHDOCAPI_(DWORD) SoftwareUpdateMessageBox( HWND hWnd,
                                           LPCWSTR szDistUnit,
                                           DWORD dwFlags,
                                           LPSOFTDISTINFO psdi );
#endif // if __urlmon_h__


;begin_internal

// CmdID's for CGID_MENUDESKBAR
#define  MBCID_GETSIDE   1
#define  MBCID_RESIZE    2
#define  MBCID_SETEXPAND 3
#define  MBCID_SETFLAT   4
#define  MBCID_NOBORDER  5

// menubar orientation
#define MENUBAR_LEFT     ABE_LEFT
#define MENUBAR_TOP      ABE_TOP
#define MENUBAR_RIGHT    ABE_RIGHT
#define MENUBAR_BOTTOM   ABE_BOTTOM


//
// Net Access Wizard - called from NetID and WinLogon.
//

#define NAW_NETID              0x00          // called from netid tab
#define NAW_PSDOMAINJOINED     0x02          // post setup (joined domain)
#define NAW_PSDOMAINJOINFAILED 0x03          // post setup (domain joined failed)

STDAPI NetAccessWizard(HWND hwnd, UINT uType, BOOL *pfReboot);
typedef HRESULT (CALLBACK *LPNETACCESSWIZARD)(HWND hwnd, UINT uType, BOOL *pfReboot);

STDAPI ClearAutoLogon(VOID);

//
// Net Places API's called from mpr.
//

typedef enum
{
    NETPLACES_WIZARD_MAPDRIVE = 0,
    NETPLACES_WIZARD_ADDPLACE,
} NETPLACESWIZARDTYPE;

STDAPI_(DWORD)
NetPlacesWizardDoModal(
    LPCONNECTDLGSTRUCTW lpConnDlgStruct,
    NETPLACESWIZARDTYPE npwt,
    BOOL                fIsRoPath
    );

// Definition for the exported function types (for GetProcAddress)
typedef DWORD (STDAPICALLTYPE*NetPlacesWizardDoModal_t)(LPCONNECTDLGSTRUCTW lpConnDlgStruct, NETPLACESWIZARDTYPE npwt, BOOL fIsROPath);

//
// moved here from nettarg.h (shell\inc)
//

// nCmdID
#define CFCID_SETENUMTYPE       0

//nCmdExecOpt
#define CFCOPT_ENUMINCOMING     1
#define CFCOPT_ENUMOUTGOING     2
#define CFCOPT_ENUMALL          3

/****************************************************
 Items to display in the shutdown dialog (dwItems)
 -------------------------------------------------

  These flags can be |'d when passed in. A single
  value will be returned, with NONE indicating an
  error or the user clicked cancel.
  -dsheldon
****************************************************/
#define SHTDN_NONE                      0x000000000
#define SHTDN_LOGOFF                    0x000000001
#define SHTDN_SHUTDOWN                  0x000000002
#define SHTDN_RESTART                   0x000000004
#define SHTDN_RESTART_DOS               0x000000008
#define SHTDN_SLEEP                     0x000000010
#define SHTDN_SLEEP2                    0x000000020
#define SHTDN_HIBERNATE                 0x000000040
#define SHTDN_DISCONNECT                0x000000080

// Shutdown dialog function exported from MSGINA.dll

STDAPI_(DWORD) ShellShutdownDialog(HWND hwndParent, LPCTSTR szUsername, DWORD dwExcludeItems);
typedef DWORD (STDAPICALLTYPE*PFNSHELLSHUTDOWNDIALOG)(HWND hwndParent, LPCTSTR szUsername, DWORD dwExcludeItems);

// Define a clipboard format for a data object to pass a user's SID
// A data object supporting this format is passed to IShellExtInit::Initialize
// before calling IShellPropSheetExt::AddPages.
#define CFSTR_USERPROPPAGESSID TEXT("UserPropertyPagesSid")


// Registry paths where extra IShellPropSheetExt handlers can be put so that
// extended pages are added to the CPL or User Properties
#define REGSTR_USERSANDPASSWORDS_CPL \
/* HKLM\\ */ TEXT("Software\\Microsoft\\Windows\\CurrentVersion\\Control Panel\\Users and Passwords")
// CLSIDs go in HKLM\Software\Microsoft\Windows\CurrentVersion\Control Panel\Users and Passwords\shellex\PropertySheetHandlers

#define REGSTR_USERPROPERTIES_SHEET \
/* HKLM\\ */ TEXT("Software\\Microsoft\\Windows\\CurrentVersion\\Control Panel\\Users and Passwords\\User Properties")
// CLSIDs go in HKLM\Software\Microsoft\Windows\CurrentVersion\Control Panel\Users and Passwords\User Properties\shellex\PropertySheetHandlers

//
//  SHFileSysBindToStorage()
//  Wrap of file system IShellFolder::BindToStorage
//
//  pszPath       // storage path
//  grfFileAttrib // optional Win32/64 file attribute bits.  Use 0 to specify default behavior
//  grfMode       // STGM_ mode flags.
//  grfFlags      // BIND_xxx bind flags
//  riid          // storage interface ID
//  **ppv         // outbound storage interface pointer.
//
SHSTDAPI SHFileSysBindToStorage(LPCWSTR pszPath, DWORD grfFileAttrib, DWORD grfMode, DWORD grfFlags, REFIID riid, void **ppv);

// DOC'ed for DOJ compliance
;end_internal
//  SHPropStgCreate()
//  Wrap of IPropertySetStorage::Open/Create
//
//  This function ensures proper handling of code page retrieval/assignment
//  for the requested property set operation.
//
//  psstg,          //  Address of IPropertySetStorage vtable
//  fmtid,          //  property set ID
//  pclsid,         //  class ID associated with the set. This can be NULL
//  grfFlags,       //  PROPSETFLAG_xxx.  All sets containing ansi bytes should be created with
                    //  PROPSETFLAG_ANSI, otherwise PROPSETFLAG_DEFAULT.
//  grfMode,        //  STGM_ flags.  Must contain STGM_DIRECT|STGM_EXCLUSIVE.
//  dwDisposition,  //  OPEN_EXISTING. OPEN_ALWAYS, CREATE_NEW, or CREATE_ALWAYS
//  IPropertyStorage** ppstg,  // Address to receive requested vtable
//  puCodePage      //  Optional address to receive the code page ID for the set.
//
SHSTDAPI SHPropStgCreate( IPropertySetStorage* psstg, REFFMTID fmtid, CLSID* pclsid, DWORD grfFlags, DWORD grfMode, DWORD dwDisposition, OUT IPropertyStorage** ppstg, OUT OPTIONAL UINT* puCodePage );


//  SHPropStgReadMultiple()
//  IPropertyStorage::ReadMultiple wrap
//
//  The wrap ensures ANSI/UNICODE translations are handled properly for
//  legacy property sets.
//
//  pps,       // address of IPropertyStorage vtable.
//  uCodePage, //Code page value retrieved from SHCreatePropertySet
//  cpspec,    //Count of properties being read
//  rgpspec,   //Array of the properties to be read
//  rgvar      //Array of PROPVARIANTs containing the property values on return
//
SHSTDAPI SHPropStgReadMultiple( IPropertyStorage* pps, UINT uCodePage, ULONG cpspec, PROPSPEC const rgpspec[], PROPVARIANT rgvar[] );


//  SHPropStgWriteMultiple()
//  IPropertyStorage::WriteMultiple wrap
//
//  The wrap ensures ANSI/UNICODE translations are handled properly for
//  legacy property sets.
//
//  pps,       // address of IPropertyStorage vtable.
//  uCodePage, // code page retrieved from SHCreatePropertySet.
//  cpspec,    // The number of properties being set
//  rgpspec,   // Property specifiers
//  rgvar,     // Array of PROPVARIANT values
//  propidNameFirst // Minimum value for property identifiers. This value should be >= PID_FIRST_USABLE
//
SHSTDAPI SHPropStgWriteMultiple( IPropertyStorage* pps, UINT* puCodePage, ULONG cpspec, PROPSPEC const rgpspec[], PROPVARIANT rgvar[], PROPID propidNameFirst );

;begin_internal

//  SHIsLegacyAnsiProperty()
//
//  Determine whether the property is a legacy ANSI property, and if so,
//  compute a conversion type for the property.
//
//  fmtid,     // property set identifier
//  propid,    // property identifier
//  pvt,       // optional:  if non-null, contains on input the VARTYPE for the property; on output,
               //            the converted type.  (e.g., VT_LPSTR <--> VT_LPWSTR).

SHSTDAPI_(BOOL) SHIsLegacyAnsiProperty( REFFMTID fmtid, PROPID propid, IN OUT OPTIONAL VARTYPE* pvt );


//-------------------------------------------------------------------------//
//  linkwnd.h - declaration of LinkWindow control
//
//  LinkWindow supports HTML-like embedded links in the caption text.
//  (e.g. "<a>Click Here</a> to see something cool"
//
//  An unlimited number of embedded links are supported.   When the user clicks
//  on a link, an WM_NOTIFY - LWN_CLICK notification message is sent to the
//  parent window.   The message data includes the zero-based index
//  (left to right orientation) of the link that was clicked.
//
//  scotthan: author/owner
//  dsheldon: moved this to shlobjp.h. Eventually destined for comctl32.

EXTERN_C BOOL WINAPI LinkWindow_RegisterClass() ;
EXTERN_C BOOL WINAPI LinkWindow_UnregisterClass( HINSTANCE ) ;

#define INVALID_LINK_INDEX  (-1)
#define MAX_LINKID_TEXT     48
#define LINKWINDOW_CLASS    TEXT("Link Window")

#define LWS_TRANSPARENT 0x0001
#define LWS_HOTTRACK    0x0002

#define LWIF_ITEMINDEX  0x00000001
#define LWIF_STATE      0x00000002
#define LWIF_ITEMID     0x00000004
#define LWIF_URL        0x00000008

#define LWIS_FOCUSED    0x0001
#define LWIS_ENABLED    0x0002
#define LWIS_VISITED    0x0004
#define LWIS_SHELLEXECURL 0x00000008    // If the caller didn't handle the msg (NM_CLICK), then ShellExecute the szURL

//  BUGBUG: we've got to change the following definition to
//  wininet.h::INTERNET_MAX_URL_LENGTH.
//  Currently, this breaks various dependents.
#define LW_MAX_URL_LENGTH   (2048 + 32 + sizeof("://"))

//  LWITEM
typedef struct tagLWITEMA {
    UINT        mask ;
    int         iLink ;
    UINT        state ;
    UINT        stateMask ;
    CHAR        szID[MAX_LINKID_TEXT] ;
    CHAR        szUrl[LW_MAX_URL_LENGTH] ;   //bugbug: INTERNET_MAX_URL_LENGTH
} LWITEMA, *LPLWITEMA;

typedef struct tagLWITEMW {
    UINT        mask ;
    int         iLink ;
    UINT        state ;
    UINT        stateMask ;
    WCHAR       szID[MAX_LINKID_TEXT] ;
    WCHAR       szUrl[LW_MAX_URL_LENGTH] ;  //bugbug: INTERNET_MAX_URL_LENGTH
} LWITEMW, *LPLWITEMW;

//  LWHITTESTINFO
typedef struct tagLWHITTESTINFOA {
    POINT       pt ;
    LWITEMA     item ;
} LWHITTESTINFOA, *LPLWHITTESTINFOA;

//  LWHITTESTINFO
typedef struct tagLWHITTESTINFOW {
    POINT       pt ;
    LWITEMW     item ;
} LWHITTESTINFOW, *LPLWHITTESTINFOW;

//  NMLINKWND
typedef struct tagNMLINKWNDA {
    NMHDR       hdr;
    LWITEMA     item ;
} NMLINKWNDA, *LPNMLINKWNDA;

typedef struct tagNMLINKWNDW {
    NMHDR       hdr;
    LWITEMW     item ;
} NMLINKWNDW, *LPNMLINKWNDW;

#ifdef UNICODE
#define LWITEM          LWITEMW
#define LPLWITEM        LPLWITEMW
#define LWHITTESTINFO   LWHITTESTINFOW
#define LPLWHITTESTINFO LPLWHITTESTINFOW
#define NMLINKWND       NMLINKWNDW
#define LPNMLINKWND     LPNMLINKWNDW
#else //UNICODE
#define LWITEM          LWITEMA
#define LPLWITEM        LPLWITEMA
#define LWHITTESTINFO   LWHITTESTINFOA
#define LPLWHITTESTINFO LPLWHITTESTINFOA
#define NMLINKWND       NMLINKWNDA
#define LPNMLINKWND     LPNMLINKWNDA
#endif //UNICODE

//  LinkWindow notifications
//  NM_CLICK   // wParam: n/a, lParam: LPLWITEM, ret: ignored.

//  LinkWindow messages
#define LWM_HITTEST         (WM_USER+0x300)  // wParam: n/a, lparam: LPLWHITTESTINFO, ret: BOOL
#define LWM_GETIDEALHEIGHT  (WM_USER+0x301)  // wParam: n/a, lparam: n/a, ret: cy
#define LWM_SETITEM        (WM_USER+0x302)  // wParam: n/a, lparam: LWITEM*, ret: BOOL
#define LWM_GETITEM        (WM_USER+0x303)  // wParam: n/a, lparam: LWITEM*, ret: BOOL
//-------------------------------------------------------------------------//


//  INTERNAL: Darwin link tracking for start menu
//     lives in unicpp\startmnu.cpp
#if         _WIN32_IE >= 0x0600
//         Note: SHRegisterDarwinLink takes ownership of pidlFull. fUpdate means: update the Darwin state right away
    SHSTDAPI_(BOOL) SHRegisterDarwinLink(LPITEMIDLIST pidlFull, LPWSTR pszDarwinID, BOOL fUpdate);

    // Use this function to update the Darwin state for all registered Darwin shortcuts.
    SHSTDAPI_(void) SHReValidateDarwinCache();

    SHSTDAPI SHParseDarwinIDFromCacheW(LPWSTR pszDarwinDescriptor, LPWSTR *ppwszOut);
#endif


//
//  GroupButton is a variation of a group box control but supports a link-like
//  caption bar, and optionally, can be buddied to a containee window for
//  auto-positioning behavior.
//
//  scotthan: author/owner

#define GROUPBUTTON_CLASS  TEXT("GroupButton")

EXTERN_C ATOM WINAPI GroupButton_RegisterClass() ;
EXTERN_C BOOL WINAPI GroupButton_UnregisterClass() ;

#include <pshpack8.h>

typedef struct tagGBPLACEMENT
{
    LONG x ;            // in: top left; -1 to ignore
    LONG y ;            // in: top right; -1 to ignore
    LONG cx ;           // in: width to assign; -1 to ignore.
                        //     If cx != -1, cxContain and cxMax are ignored.
    LONG cy ;           // in: height to assign; -1 to ignore.
                        //     If cy != -1, cyContain and cyMax are ignored.
    LONG cxBuddy ;      // in: width of buddy area; -1 to ignore
    LONG cyBuddy ;      // in: height of buddy area; -1 to ignore
    LONG cxBuddyMargin ;// in: width of buddy margin; -1 to ignore
    LONG cyBuddyMargin ;// in: height of buddy margin; -1 to ignore
    RECT rcBuddy ;      // out: new buddy rect in parent coords.
    RECT rcWindow ;     // out: new window rect in parent coords.
    HDWP hdwp ;         // optional in: Non-NULL => DeferWindowPos,
                        //              NULL => SetWindowPos
} GBPLACEMENT, *PGBPLACEMENT, *LPGBPLACEMENT ;
#include <poppack.h>        /* Return to byte packing */

//  Buddy flags
#define GBBF_HRESIZE   0x00000001
#define GBBF_VRESIZE   0x00000002
#define GBBF_HSCROLL   0x00000004
#define GBBF_VSCROLL   0x00000008
#define GBBF_HSLAVE    0x00000010
#define GBBF_VSLAVE    0x00000020

//  Group button messages
#define GBM_FIRST        (WM_USER+0x400) // arbitrary
#define GBM_SETPLACEMENT (GBM_FIRST+0)   // WPARAM: n/a, LPARAM: PGBPLACEMENT, return: BOOL
#define GBM_SETBUDDY     (GBM_FIRST+1)   // WPARAM: HWND hwndBuddy, LPARAM: dwBuddyFlags, return: BOOL
#define GBM_GETBUDDY     (GBM_FIRST+2)   // WPARAM: n/a, LPARAM: n/a, return: HWND
#define GBM_SETDROPSTATE (GBM_FIRST+3)   // WPARAM: BOOL fDropped, LPARAM: n/a, return: BOOL
#define GBM_GETDROPSTATE (GBM_FIRST+4)   // WPARAM: n/a, LPARAM: n/a, return: BOOL fDropped
#define GBM_LAST         GBM_GETDROPSTATE

typedef struct tagGBNQUERYBUDDYSIZE
{
    NMHDR   hdr;
    LONG    cx ;
    LONG    cy ;
} GBNQUERYBUDDYSIZE, *LPGBNQUERYBUDDYSIZE, *PGBNQUERYBUDDYSIZE ;

//  Group button notifications
#define GBN_FIRST               2000U
#define GBN_LAST                2020U
#define GBN_QUERYBUDDYHEIGHT    (GBN_FIRST+0)   // LPARAM: LPGBNQUERYBUDDYSIZE
#define GBN_QUERYBUDDYWIDTH     (GBN_FIRST+1)   // LPARAM: LPGBNQUERYBUDDYSIZE.


// create standard IExtractIcon for file system like things (that does not really exist)
// DOC'ed for DOJ compliance
;end_internal
SHSTDAPI SHCreateFileExtractIcon%(LPCTSTR% pszFile, DWORD dwFileAttributes, REFIID riid, void **ppv);
;begin_internal

// Limit Input Mask values:
#define LIM_FLAGS           0x00000001      // dwFlags contains valid data.  Otherwise all default values are used.
#define LIM_FILTER          0x00000002      // pszFilter contains valid data.  At least one of the filter and mask fields must be used.  Both can be used it desired.
#define LIM_HINST           0x00000008      // hinst contains valid data
#define LIM_TITLE           0x00000010      // pszTitle contains valid data.  This data will be shown in bold at the top of any tooltips displayed.
#define LIM_MESSAGE         0x00000020      // pszMessage contains valid data.  This data will be shown in default font below the title if a title is also used.
#define LIM_ICON            0x00000040      // hicon contains valid data.  This icon will be displayed in front of the title if a title is given.
#define LIM_NOTIFY          0x00000080      // hwndNotify contains the window handle that should receive any notification messages.  By default, the parent of hwndEdit recieves notifications.
#define LIM_TIMEOUT         0x00000100      // iTimeout is valid.  Otherwise the default timeout of 10 seconds is used.
#define LIM_TIPWIDTH        0x00000200      // cxTipWidth is valid.  Otherwiser the default is 500 pixels.


// Limit Input Flags values:
#define LIF_INCLUDEFILTER   0x00000000      // default value.  pszFilter is a string of allowable characters.
#define LIF_EXCLUDEFILTER   0x00000001      // pszFilter is a string of excluded characters.
#define LIF_CATEGORYFILTER  0x00000002      // pszFilter is not a pointer, but rather its a bitfield indicating types or characters.  If combined with LIF_EXCLUDEFILTER these are excluded categories, otherwise they are allowed categories.

#define LIF_WARNINGBELOW    0x00000000      // default value.  Balloon tooltips will be shown below the window by default.
#define LIF_WARNINGABOVE    0x00000004      // Ballon tooltips will be shown above the window by default.
#define LIF_WARNINGCENTERED 0x00000008      // Ballon tooltips will be shown pointing to the center of the window.
#define LIF_WARNINGOFF      0x00000010      // no balloon tooltip will be displayed upon invalid input.

#define LIF_FORCEUPPERCASE  0x00000020      // all characters will be converted to upper case.  Cannot be use with LIF_FORCELOWERCASE.
#define LIF_FORCELOWERCASE  0x00000040      // all characters will be converted to lower case.  Cannot be use with LIF_FORCEUPPERCASE.

#define LIF_MEESAGEBEEP     0x00000000      // default value.  A tone will be played to alert the user if they attemp invalid input.
#define LIF_SILENT          0x00000080      // No tone will be played.

#define LIF_NOTIFYONBADCHAR 0x00000100      // a notify message will be sent to hwndNotify when invalid input is attempted.
#define LIF_HIDETIPONVALID  0x00000200      // if the tooltip is displayed, it should be hidden when the next valid character is entered.  By default, the tip remains visible for iTimeOut milliseconds.

#define LIF_PASTESKIP       0x00000000      // default value.  When pasting, skip the bad characters and paste all of the good characters.
#define LIF_PASTESTOP       0x00000400      // When pasting, stop when the first bad character is incountered.  Valid characters in front of this will get pasted.
#define LIF_PASTECANCEL     0x00000800      // When pasting, abort the entire paste if any characters are invalid.

#define LIF_KEEPCLIPBOARD   0x00001000      // When pasting, don't modify the contents of the clipboard when there are invalid characters.  By defualt the clipboard is changed.  How it is changed depends on which LIF_PASTE* flag is used.


// Limit Input Category Filters:
// these flags use the result of GetStringTypeEx with CT_TYPE1:
#define LICF_UPPER          0x00000001      // Uppercase
#define LICF_LOWER          0x00000002      // Lowercase
#define LICF_DIGIT          0x00000004      // Decimal digits
#define LICF_SPACE          0x00000008      // Space characters
#define LICF_PUNCT          0x00000010      // Punctuation
#define LICF_CNTRL          0x00000020      // Control characters
#define LICF_BLANK          0x00000040      // Blank characters
#define LICF_XDIGIT         0x00000080      // Hexadecimal digits
#define LICF_ALPHA          0x00000100      // Any linguistic character: alphabetic, syllabary, or ideographic
// these flags check for a few things that GetStringTypeEx doesn't check
#define LICF_BINARYDIGIT    0x00010000      // 0-1
#define LICF_OCTALDIGIT     0x00020000      // 0-7
#define LICF_ATOZUPPER      0x00100000      // A-Z (use LICF_ALPHA for language independent check)
#define LICF_ATOZLOWER      0x00200000      // a-z (use LICF_ALPHA for language independent check)
#define LICF_ATOZ           (LICF_ATOZUPPER|LICF_ATOZLOWER)     // a-z, A-Z

;end_internal
;begin_both
#include <pshpack8.h>
;end_both
;begin_internal

typedef struct tagLIMITINPUT
{
    DWORD       cbSize;
    DWORD       dwMask;
    DWORD       dwFlags;
    HINSTANCE   hinst;
    LPWSTR      pszFilter;      // pointer to a string, or the ID of a string resource if hinst is also given, or LPSTR_TEXTCALLBACK if the parent window should be notified to provide a string.
    LPWSTR      pszTitle;       // pointer to a string, or the ID of a string resource if hinst is also given, or LPSTR_TEXTCALLBACK if the parent window should be notified to provide a string.
    LPWSTR      pszMessage;     // pointer to a string, or the ID of a string resource if hinst is also given, or LPSTR_TEXTCALLBACK if the parent window should be notified to provide a string.
    HICON       hIcon;          // handle to an icon, or I_ICONCALLBACK if the notify window should be asked to provide an icon.
    HWND        hwndNotify;     // handle to a window to process notify messages
    INT         iTimeout;       // time in milliseconds to display the tooltip
    INT         cxTipWidth;     // max width of the tooltip in pixels.  Defaults to 500.
} LIMITINPUT;


typedef struct tagNMLIDISPINFO
{
    NMHDR       hdr;            // standard notification header structure
    LIMITINPUT  li;             // the mask member indicates which fields must be filled out.
} NMLIDISPINFO, * LPNMLIDISPINFO, NMLIFILTERINFO, * LPNMLIFILTERINFO;

#define LIN_GETDISPINFO     0x01            // notify code sent to retrieve tooltip display info
#define LIN_GETFILTERINFO   0x02            // notify code sent to retrieve filter or mask info

typedef struct tagNMLIBADCHAR
{
    NMHDR       hdr;            // standard notification header structure
    WPARAM      wParam;         // wParam sent in WM_CHAR message
    LPARAM      lParam;         // lParam sent in WM_CHAR message
} NMLIBADCHAR, * LPNMLIBADCHAR;

#define LIN_BADCHAR         0x03            // notify code sent when a character is filtered out

#define I_ICONCALLBACK      ((HICON)-1L)

// Helpers which prevent entry of invalid (as defined by the folder) characters.  Call on LVN_BEGIN_INPUT_EDIT
// doc'ed for DOJ compliance
;end_internal
SHSTDAPI SHLimitInputEdit(HWND hwndEdit, IShellFolder *psf);
;begin_internal
SHSTDAPI SHLimitInputEditWithFlags(HWND hwndEdit, LIMITINPUT * pil);
SHSTDAPI SHLimitInputEditChars(HWND hwndEdit, LPCWSTR pszValidChars, LPCWSTR pszInvalidChars);
SHSTDAPI SHLimitInputCombo(HWND hwndComboBox, IShellFolder *psf);

// DOC'ed for DOJ Compliance
;end_internal

#if (_WIN32_WINNT >= 0x0500) || (_WIN32_WINDOWS >= 0x0500)  

//
// The SHMultiFileProperties API displays a property sheet for a 
// set of files specified in an IDList Array.
//
// Parameters:
//      pdtobj  - Data object containing list of files.  The data
//                object must provide the "Shell IDList Array" 
//                clipboard format.  The parent folder's implementation of
//                IShellFolder::GetDisplayNameOf must return a fully-qualified
//                filesystem path for each item in response to the 
//                SHGDN_FORPARSING flag.
//
//      dwFlags - Reserved for future use.  Should be set to 0.
//
// Returns:
//      S_OK
// 
SHSTDAPI SHMultiFileProperties(IDataObject *pdtobj, DWORD dwFlags);

#endif 

#if (_WIN32_IE >= 0x0600)
//
//
typedef void (CALLBACK *PFNASYNCICONTASKBALLBACK)(LPCITEMIDLIST pidl, LPVOID pvData, LPVOID pvHint, INT iIconIndex, INT iOpenIconIndex);

// HRESULT SHMapIDListToImageListIndexAsync(IShellTaskScheduler* pts, IShellFolder *psf, LPCITEMIDLIST pidl, UINT flags,
//                                            PFNASYNCICONTASKBALLBACK pfn, LPVOID pvData, LPVOID pvHint, int *piIndex, int *piIndexSel);
// A usefull function for asynchronously mapping idlist into index into system
// image list.  Optionally it can also look up the index of the selected icon.
// pts          Task scheduler interface to use to create the background task
// psf          Shell folder relating to the pidl
// pidl         Item whose icon is requested
// flags        GIL_ flags
// pfn          Function called back when the background task is done
// pvData       User data passed back in the (*pfn) callback
// pvHint       User data passed back in the (*pfn) callback
// piIndex      Icon index returned. This is the temporary index if the function returns E_PENDING. The final index will be provided thru the callback
// piIndexSel   Optional icon index for the open icon case (GIL_OPENICON).
//
// Returns S_OK if all the requested info was available. E_PENDING means that you get temporary icons, and will be called back
//              asynchronously with the final icons. Other failure code means the function failed.
SHSTDAPI SHMapIDListToImageListIndexAsync(IShellTaskScheduler* pts, IShellFolder *psf, LPCITEMIDLIST pidl, UINT flags,
                                            PFNASYNCICONTASKBALLBACK pfn, LPVOID pvData, LPVOID pvHint, int *piIndex, int *piIndexSel);
#endif // (_WIN32_IE >= 0x0600)

// A usefull function in Defview for mapping idlist into index into system
// image list.  Optionally it can also look up the index of the selected
// icon.
SHSTDAPI_(int) SHMapPIDLToSystemImageListIndex(IShellFolder *pshf, LPCITEMIDLIST pidl, int *piIndexSel);

;begin_internal
// DOC'ed for DOJ Compliance
;end_internal
EXTERN_C WINSHELLAPI HRESULT STDAPICALLTYPE SHCLSIDFromString(LPCWSTR lpsz, LPCLSID lpclsid);
HANDLE _SHAllocShared(LPCVOID pvData, DWORD dwSize, DWORD dwDestinationProcessId);
BOOL _SHFreeShared(HANDLE hData, DWORD dwSourceProcessId);
void *_SHLockShared(HANDLE hData, DWORD dwSourceProcessId);
BOOL _SHUnlockShared(void * pvData);
STDAPI SHFlushClipboard(void);
STDAPI SHCreateQueryCancelAutoPlayMoniker(IMoniker** ppmoniker);
HINSTANCE WINAPI SHGetShellStyleHInstance(void);
STDAPI_(void) PerUserInit(void);
WINSHELLAPI BOOL    WINAPI SHRunControlPanel(LPCWSTR lpcszCmdLine, HWND hwndMsgParent);

#ifndef _SHLOBJ_NO_PICKICONDLG
WINSHELLAPI int   WINAPI PickIconDlg(HWND hwnd, LPWSTR pszIconPath, UINT cbIconPath, int *piIconIndex);
#endif


typedef struct tagAAMENUFILENAME
{
  SHORT  cbTotal;
  BYTE   rgbReserved[12];
  WCHAR  szFileName[1]; 	// variable length string
} AASHELLMENUFILENAME, *LPAASHELLMENUFILENAME;

typedef struct tagAASHELLMENUITEM
{
  void*  lpReserved1;
  int    iReserved;
  UINT   uiReserved;
  LPAASHELLMENUFILENAME lpName; // name of file
  LPWSTR psz; 			// text to use if no file
} AASHELLMENUITEM, *LPAASHELLMENUITEM;


;begin_internal

int _cdecl ShellMessageBoxWrapW(HINSTANCE hInst, HWND hWnd, LPCWSTR pszMsg, LPCWSTR pszTitle, UINT fuStyle, ...);

#ifdef UNICODE
#define ShellMessageBoxWrap         ShellMessageBoxWrapW
#else
#define ShellMessageBoxWrap         ShellMessageBoxA
#endif

// Helpers for handling IDataObject stuff - from shell32.dll
// DOC'ed for DOJ compliance
;end_internal
STDAPI SHGetAttributesFromDataObject(IDataObject *pdo, DWORD dwAttributeMask, DWORD *pdwAttributes, UINT *pcItems);
;begin_internal
STDAPI SHSimulateDropOnClsid(REFCLSID clsidDrop, IUnknown* punkSite, IDataObject* pdo);

;end_internal

;begin_both
#include <poppack.h>        /* Return to byte packing */
;end_both



;begin_both
#ifdef __cplusplus
}

#endif  /* __cplusplus */

#include <poppack.h>
;end_both


SHDOCAPI_(BOOL) ImportPrivacySettings( LPCWSTR szFilename,
                            IN OUT BOOL* pfParsePrivacyPreferences, IN OUT BOOL* pfParsePerSiteRules);
#ifndef IEnumPrivacyRecords
typedef interface IEnumPrivacyRecords IEnumPrivacyRecords;
#endif
SHDOCAPI DoPrivacyDlg( HWND hwndParent, LPOLESTR pszUrl, IEnumPrivacyRecords *pPrivacyEnum, BOOL fReportAllSites);


#endif // _SHLOBJ_H_
#endif // _SHLOBJP_H_       ;Internal
