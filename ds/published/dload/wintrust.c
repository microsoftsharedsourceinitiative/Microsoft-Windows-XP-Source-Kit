#include "dspch.h"
#pragma hdrstop

#include <wincrypt.h>
#include <mscat.h>


static
LONG
WINAPI
WinVerifyTrust (
    HWND hwnd,
    GUID *pgActionID,
    LPVOID pWVTData
    )
{
    return E_UNEXPECTED;
}

static
BOOL
WINAPI
CryptCATAdminAcquireContext(
    OUT HCATADMIN *phCatAdmin,
    IN const GUID *pgSubsystem,
    IN DWORD dwFlags) 
{
    SetLastError(ERROR_PROC_NOT_FOUND);
    return FALSE;
}

static
HCATINFO
WINAPI
CryptCATAdminEnumCatalogFromHash(
    IN HCATADMIN hCatAdmin,
    IN BYTE *pbHash,
    IN DWORD cbHash,
    IN DWORD dwFlags,
    IN OUT HCATINFO *phPrevCatInfo)
{
    SetLastError(ERROR_PROC_NOT_FOUND);
    return NULL;
}

static
BOOL
WINAPI
CryptCATAdminCalcHashFromFileHandle(
    IN HANDLE hFile,
    IN OUT DWORD *pcbHash,
    OUT OPTIONAL BYTE *pbHash,
    IN DWORD dwFlags)
{
    SetLastError(ERROR_PROC_NOT_FOUND);
    return FALSE;
}

static
HCATINFO
WINAPI
CryptCATAdminAddCatalog(
    IN HCATADMIN hCatAdmin,
    IN WCHAR *pwszCatalogFile,
    IN OPTIONAL WCHAR *pwszSelectBaseName,
    IN DWORD dwFlags)
{
    SetLastError(ERROR_PROC_NOT_FOUND);
    return NULL;
}

static
BOOL
WINAPI
CryptCATCatalogInfoFromContext(
    IN HCATINFO hCatInfo,
    IN OUT CATALOG_INFO *psCatInfo,
    IN DWORD dwFlags)
{
    SetLastError(ERROR_PROC_NOT_FOUND);
    return FALSE;
}

static
BOOL
WINAPI
CryptCATAdminReleaseContext(
    IN HCATADMIN hCatAdmin,
    IN DWORD dwFlags)
{
    SetLastError(ERROR_PROC_NOT_FOUND);
    return FALSE;
}

static
BOOL
WINAPI
CryptCATAdminReleaseCatalogContext(
    IN HCATADMIN hCatAdmin,
    IN HCATINFO hCatInfo,
    IN DWORD dwFlags)
{
    SetLastError(ERROR_PROC_NOT_FOUND);
    return FALSE;
}

static
BOOL
WINAPI
CryptCATAdminRemoveCatalog(
    IN HCATADMIN hCatAdmin,
    IN LPCWSTR pwszCatalogFile,
    IN DWORD dwFlags)
{
    SetLastError(ERROR_PROC_NOT_FOUND);
    return FALSE;
}

static
BOOL
WINAPI
CryptCATAdminResolveCatalogPath(
    IN HCATADMIN hCatAdmin,
    IN WCHAR *pwszCatalogFile,
    IN OUT CATALOG_INFO *psCatInfo,
    IN DWORD dwFlags)
{
    SetLastError(ERROR_PROC_NOT_FOUND);
    return FALSE;
}

//
// !! WARNING !! The entries below must be in alphabetical order, and are CASE SENSITIVE (eg lower case comes last!)
//
DEFINE_PROCNAME_ENTRIES(wintrust)
{
    DLPENTRY(CryptCATAdminAcquireContext)
    DLPENTRY(CryptCATAdminAddCatalog)
    DLPENTRY(CryptCATAdminCalcHashFromFileHandle)
    DLPENTRY(CryptCATAdminEnumCatalogFromHash)
    DLPENTRY(CryptCATAdminReleaseCatalogContext)
    DLPENTRY(CryptCATAdminReleaseContext)
    DLPENTRY(CryptCATAdminRemoveCatalog)
    DLPENTRY(CryptCATAdminResolveCatalogPath)
    DLPENTRY(CryptCATCatalogInfoFromContext)
    DLPENTRY(WinVerifyTrust)
};

DEFINE_PROCNAME_MAP(wintrust)



