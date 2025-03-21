// This file contains the implementation of CShellTreeWalker, a COM object
// that inherits IShellTreeWalker, and it will recursively enumerate all the
// files (or directories or both) starting from a root directory that match a
// certain spec. 
// 1. The tree walker is reparse point aware, it does not traverse into reparse 
// point folders by default, but will if specified
// 2. It keeps track of the number of files, directories, depth, and total
// size of all files encountered.
// 3. It will stop the traversal right away if any error message is returned
// from the callback functions except for E_NOTIMPL
// 4. It will jump out of the current working directory if S_FALSE is returned from callback
// functions.
//
// History:
//         12-5-97  by dli

#include "shellprv.h"
#include "validate.h"

#define IS_FILE_DIRECTORY(pwfd)     ((pwfd)->dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
#define IS_FILE_REPARSE_POINT(pwfd) ((pwfd)->dwFileAttributes & FILE_ATTRIBUTE_REPARSE_POINT)

// Call back flags for _CallCallBack
#define STWCB_FILE     1
#define STWCB_ERROR    2
#define STWCB_ENTERDIR 3
#define STWCB_LEAVEDIR 4

#define TF_TREEWALKER 0

STDAPI_(DWORD) PathGetClusterSize(LPCTSTR pszPath);

class CShellTreeWalker : public IShellTreeWalker
{
public:
    CShellTreeWalker();
    
    // IUnknown
    STDMETHODIMP QueryInterface(REFIID riid, void ** ppv);
    STDMETHODIMP_(ULONG) AddRef(void) ;
    STDMETHODIMP_(ULONG) Release(void);

    // IShellTreeWalker
    STDMETHODIMP WalkTree(DWORD dwFlags, LPCWSTR pwszWalkRoot, LPCWSTR pwszWalkSpec, int iMaxPath, IShellTreeWalkerCallBack * pstwcb);

private:
    LONG _cRef;
    
    DWORD _dwFlags;     // Flags indicating the search status
    UINT _nMaxDepth;    // Maximum depth we walk into
    UINT _nDepth;       // Current depth
    UINT _nFiles;       // Number of files we have seen so far
    UINT _nDirs;        // Number of directories we have seen

    BOOL _bFolderFirst; // Do the folders first
    DWORD _dwClusterSize;    // the size of a cluster
    ULONGLONG _ulTotalSize;  // total size of all files we have seen
    ULONGLONG _ulActualSize; // total size on disk, taking into account compression, sparse files, and cluster slop

    TCHAR _szWalkBuf[MAX_PATH];         // The path buffer used in the walk
    LPCTSTR _pszWalkSpec;               // The spec we use in FindFirstFile and FindNextFile

    IShellTreeWalkerCallBack * _pstwcb; // The call back interface pointer
    
    WIN32_FIND_DATA  _wfd;              // The temp storage of WIN32_FIND_DATA 

    WIN32_FIND_DATA _fdTopLevelFolder;  // The top level folder info
    
    HRESULT _CallCallBacks(DWORD dwCallReason, WIN32_FIND_DATA * pwfd);
    HRESULT _ProcessAndRecurse(WIN32_FIND_DATA * pwfd);
    HRESULT _TreeWalkerHelper();
}; 

CShellTreeWalker::CShellTreeWalker() : _cRef(1) 
{
    ASSERT(_dwFlags == 0);
    ASSERT(_bFolderFirst == FALSE);
    ASSERT(_nMaxDepth == 0);
    ASSERT(_nDepth == 0);
    ASSERT(_nDirs == 0);
    ASSERT(_ulTotalSize == 0);
    ASSERT(_ulActualSize == 0);
    ASSERT(_pszWalkSpec == NULL);
    ASSERT(_pstwcb == NULL);
    ASSERT(_szWalkBuf[0] == 0);
}

// _CallCallBack: convert the TCHARs to WCHARs and call the callback functions
HRESULT CShellTreeWalker::_CallCallBacks(DWORD dwReason, WIN32_FIND_DATA * pwfd)
{
    HRESULT hr;
    WCHAR wszDir[MAX_PATH];
    WCHAR wszFileName[MAX_PATH];
#ifndef UNICODE
    CHAR szTemp[MAX_PATH];
#endif
    WIN32_FIND_DATAW wfdw = {0};
    WIN32_FIND_DATAW* pwfdw = NULL;
    TREEWALKERSTATS tws = {0};

    tws.nFiles = _nFiles;
    tws.nFolders     = _nDirs;
    tws.nDepth       = _nDepth;
    tws.ulTotalSize  = _ulTotalSize;
    tws.ulActualSize = _ulActualSize;
    tws.dwClusterSize = _dwClusterSize;

    // _szWalkBuf to wszDir
#ifdef UNICODE
    lstrcpy(wszDir, _szWalkBuf);
    lstrcpy(wszFileName, wszDir);
    PathCombine(wszFileName, wszFileName, pwfd->cFileName);
#else
    SHAnsiToUnicode(_szWalkBuf, wszDir, ARRAYSIZE(wszDir));
    lstrcpy(szTemp, _szWalkBuf);
    PathCombine(szTemp, szTemp, pwfd->cFileName);
    SHAnsiToUnicode(szTemp, wszFileName, ARRAYSIZE(wszFileName));
#endif

    if (pwfd && ((dwReason == STWCB_FILE) || (dwReason == STWCB_ENTERDIR)))
    {
        // WIN32_FIND_DATAA to WIN32_FIND_DATAW
        memcpy(&wfdw, pwfd, sizeof(*pwfd));
#ifndef UNICODE
        SHAnsiToUnicode(pwfd->cFileName, wfdw.cFileName, ARRAYSIZE(wfdw.cFileName));
        SHAnsiToUnicode(pwfd->cAlternateFileName, wfdw.cAlternateFileName, ARRAYSIZE(wfdw.cAlternateFileName));
#endif
        pwfdw = &wfdw;
    }

    switch (dwReason) 
    {
    case STWCB_FILE:
        hr = _pstwcb->FoundFile(wszFileName, &tws, pwfdw);
        TraceMsg(TF_TREEWALKER, "TreeWalker Callback FoundFile: %s\\%s dwReason: %x  nFiles: %d  nDepth: %d  nDirs: %d",
                 _szWalkBuf, pwfd->cFileName, dwReason, _nFiles, _nDepth, _nDirs);
        break;

    case STWCB_ENTERDIR:
        hr = _pstwcb->EnterFolder(wszDir, &tws, pwfdw);
        TraceMsg(TF_TREEWALKER, "TreeWalker Callback EnterFolder: %s dwReason: %x  nFiles: %d  nDepth: %d  nDirs: %d",
                 _szWalkBuf, dwReason, _nFiles, _nDepth, _nDirs);
        break;

    case STWCB_LEAVEDIR:
        hr = _pstwcb->LeaveFolder(wszDir, &tws);
        break;

//  case STWCB_ERROR:
//      hr = _pstwcb->HandleError(S_OK, wszDir, &tws);
//      break;

    default:
        hr = S_OK;
        break;
    }

    // Error messages are significant to us, all E_ messages are interpreted as "Stop right now!!"
    if (hr == E_NOTIMPL)
        hr = S_OK;
    
    return hr;
}


// Call call back funtions on directories and files, recurse on directories if there is no objection
// from the callback object
HRESULT CShellTreeWalker::_ProcessAndRecurse(WIN32_FIND_DATA * pwfd)
{
    HRESULT hr = S_OK;

    // Don't recurse on reparse points by default
    if (IS_FILE_DIRECTORY(pwfd) && (!IS_FILE_REPARSE_POINT(pwfd) || (_dwFlags & WT_GOINTOREPARSEPOINT)))
    {
        // NTRAID94635 15mar00: If we are in a symbolic link, we need to detect cycles, 
        // the common prefix method in BeenThereDoneThat will work as long as we
        // keep track of all junction point targets we ran into. 

        // use _szWalkBuf since we dont want any stack variables, because we are a recursive function
        if (PathCombine(_szWalkBuf, _szWalkBuf, pwfd->cFileName))
        {
            // We remember the total number of sub directories we have seen
            // doesn't matter if the client approves or not(call back returns S_OK or S_FALSE or E_FAIL)
            _nDirs++;

            // Let the CallBack object know that we are about to enter a directory 
            if (_dwFlags & WT_NOTIFYFOLDERENTER)
                hr = _CallCallBacks(STWCB_ENTERDIR, pwfd);

            if ((hr == S_OK) && (_nDepth < _nMaxDepth))
            {
                _nDepth++;
                hr = _TreeWalkerHelper();
                _nDepth--;
            }
            else if (hr == S_FALSE)
                hr = S_OK;

            // Let the CallBack object know that we are about to leave a directory 
            if (_dwFlags & WT_NOTIFYFOLDERLEAVE)
                _CallCallBacks(STWCB_LEAVEDIR, NULL);
            
            // Peel off the subdirectory we tagged on in the above PathCombine Ex:"c:\bin\fun --> c:\bin" 
            PathRemoveFileSpec(_szWalkBuf);
        }
    }
    else
    {
        // Count the number of files and compute the total size before calling the
        // call back object. 
        ULARGE_INTEGER ulTemp;
        _nFiles++;

        ulTemp.LowPart  = pwfd->nFileSizeLow;
        ulTemp.HighPart = pwfd->nFileSizeHigh;
        _ulTotalSize += ulTemp.QuadPart;

        // when calculating the total size, we need to find out if the file is compressed or sparse (NTFS only case)
        if (pwfd->dwFileAttributes & (FILE_ATTRIBUTE_COMPRESSED | FILE_ATTRIBUTE_SPARSE_FILE))
        {
            // use _szWalkBuf since we dont want any stack variables, because we are a recursive function
            PathCombine(_szWalkBuf, _szWalkBuf, pwfd->cFileName);

            // eithe the file is compressed or sparse, we need to call GetCompressedFileSize to get the real
            // size on disk for this file (NOTE: GetCompressedFileSize takes into account cluster slop, except
            // for files < 1 cluster, and we take care of that below)
            ulTemp.LowPart = SHGetCompressedFileSize(_szWalkBuf, &ulTemp.HighPart);

            _ulActualSize += ulTemp.QuadPart;

            // Peel off the filename we tagged on above
            PathRemoveFileSpec(_szWalkBuf);
        }
        else
        {
            // (reinerf) the cluster size could change if we started on one volume and have now
            // walked onto another mounted volume
            //
            // PathGetClusterSize caches the last request, so this check will be fast in the common case
            //
            PathCombine(_szWalkBuf, _szWalkBuf, pwfd->cFileName);
            _dwClusterSize = PathGetClusterSize(_szWalkBuf);
            PathRemoveFileSpec(_szWalkBuf);

            // if its not compressed, we just round up to the drive's cluster size. ulTemp was setup
            // already for us above, so just round it to the cluster and add it in
            _ulActualSize += ROUND_TO_CLUSTER(ulTemp.QuadPart, _dwClusterSize);
        }
        
        hr = _CallCallBacks(STWCB_FILE, pwfd);
    }

    return hr;
}

#define DELAY_ARRAY_GROW  32

// Recursive function that does the real work on the traversal,
HRESULT CShellTreeWalker::_TreeWalkerHelper()
{
    HRESULT hr = S_OK;
    TraceMsg(TF_TREEWALKER, "TreeWalkerHelper started on: %s flags: %x  nFiles: %d  nDepth: %d  nDirs: %d",
             _szWalkBuf, _dwFlags, _nFiles, _nDepth, _nDirs);

    // Let the CallBack object know that we are about to start the walk
    // provided he cares about the root
    if (_nDepth == 0 && !(_dwFlags & WT_EXCLUDEWALKROOT) &&
        (_dwFlags & WT_NOTIFYFOLDERENTER))
    {
        // Get the info for the TopLevelFolder
        HANDLE hTopLevelFolder = FindFirstFile(_szWalkBuf, &_fdTopLevelFolder);

        if (hTopLevelFolder == INVALID_HANDLE_VALUE)
        {
            LPTSTR pszFileName;
            DWORD dwAttribs = -1; // assume failure

            // We could have failed if we tried to do a FindFirstFile on the root (c:\)
            // or if something is really wrong, to test for this we do a GetFileAttributes (GetFileAttributesEx on NT)
            // on NT we can use GetFileAttributesEx to get both the attribs and part of the win32fd
            if (GetFileAttributesEx(_szWalkBuf, GetFileExInfoStandard, (LPVOID)&_fdTopLevelFolder))
            {
                // success!
                dwAttribs = _fdTopLevelFolder.dwFileAttributes;
                pszFileName = PathFindFileName(_szWalkBuf);
                lstrcpyn(_fdTopLevelFolder.cFileName, pszFileName, ARRAYSIZE(_fdTopLevelFolder.cFileName));
                lstrcpyn(_fdTopLevelFolder.cAlternateFileName, pszFileName, ARRAYSIZE(_fdTopLevelFolder.cAlternateFileName));
            }
            else
            {
                // fall back to the ole GetFileAttrbutes
                dwAttribs = GetFileAttributes(_szWalkBuf);

                if (dwAttribs != -1)
                {
                    // success!

                    // On win95 we steal a bunch of the find data from our first child, and fake the rest.
                    // Its the best we can do.
                    memcpy(&_fdTopLevelFolder, &_wfd, sizeof(_fdTopLevelFolder));

                    _fdTopLevelFolder.dwFileAttributes = dwAttribs;

                    pszFileName = PathFindFileName(_szWalkBuf);
                    lstrcpyn(_fdTopLevelFolder.cFileName, pszFileName, ARRAYSIZE(_fdTopLevelFolder.cFileName));
                    lstrcpyn(_fdTopLevelFolder.cAlternateFileName, pszFileName, ARRAYSIZE(_fdTopLevelFolder.cAlternateFileName));
                }
            }

            if (dwAttribs == -1)
            {
                // this is very bad, so we bail
                TraceMsg(TF_TREEWALKER, "Tree Walker: GetFileAttributes/Ex(%s) failed. Stopping the walk.", _szWalkBuf);
                return E_FAIL;
            }

        }
        else
        {
            // We sucessfully got the find data, good.
            FindClose(hTopLevelFolder);
        }

        // call the callback for the first enterdir
        hr = _CallCallBacks(STWCB_ENTERDIR, &_fdTopLevelFolder);
    }

    // Do the real tree walk here
    if (hr == S_OK)
    {
        // always use *.* to search when we are not at our maximum level because
        // we need the sub directories
        // PERF: this can be changed on NT by using FindFirstFileEx if WT_FOLDERONLY
        LPCTSTR pszSpec = (_pszWalkSpec && (_nDepth == _nMaxDepth)) ? _pszWalkSpec : c_szStarDotStar;
        if (PathCombine(_szWalkBuf, _szWalkBuf, pszSpec))
        {
            HDSA hdsaDelayed = NULL;  // array of found items that will be delayed and processed later
            HANDLE hFind;

            // Start finding the sub folders and files 
            hFind = FindFirstFile(_szWalkBuf, &_wfd);

            // Peel off the find spec Ex:"c:\bin\*.* --> c:\bin" 
            PathRemoveFileSpec(_szWalkBuf);

            if (hFind != INVALID_HANDLE_VALUE)
            {
                BOOL bDir = FALSE;

                do
                {
                    //  Skip over the . and .. entries.
                    if (PathIsDotOrDotDot(_wfd.cFileName))
                        continue;

                    bDir = BOOLIFY(IS_FILE_DIRECTORY(&_wfd));

                    // If this is a file, and we are not interested in files or this file spec does not match the one we were
                    // looking for. 
                    if ((!bDir) && ((_dwFlags & WT_FOLDERONLY) ||
                                    (_pszWalkSpec && (_nDepth < _nMaxDepth) && !PathMatchSpec(_wfd.cFileName, _pszWalkSpec))))
                        continue;

                    //  The following EQUAL determines whether we want to process
                    //  the data found or save it in the HDSA array and process them later. 

                    // Enumerate the folder or file now? (determined by the WT_FOLDERFIRST flag)
                    if (bDir == BOOLIFY(_bFolderFirst))
                    {
                        // Yes
                        hr = _ProcessAndRecurse(&_wfd);

                        // if hr is failure code someone said "stop right now"
                        // if hr is S_FALSE some one said "quit this directory and start with next one"
                        if (hr != S_OK)
                            break;
                    }
                    else 
                    {
                        // No; enumerate it once we're finished with the opposite.
                        if (!hdsaDelayed)
                            hdsaDelayed = DSA_Create(sizeof(WIN32_FIND_DATA), DELAY_ARRAY_GROW);
                        if (!hdsaDelayed)
                        {
                            hr = E_OUTOFMEMORY;
                            break;
                        }
                        DSA_AppendItem(hdsaDelayed, &_wfd);

                    }
                } while (FindNextFile(hFind, &_wfd));

                FindClose(hFind);
            }
            else
            {
               // find first file failed, this is a good place to report error 
               DWORD dwErr = GetLastError();
               TraceMsg(TF_TREEWALKER, "***WARNING***: FindFirstFile faied on %s%s with error = %d", _szWalkBuf, _pszWalkSpec, dwErr);
            }

            // Process the delayed items, these are either directories or files
            if (hdsaDelayed)
            {
                // we should have finished everything in the above do while loop in folderonly case
                ASSERT(!(_dwFlags & WT_FOLDERONLY));

                // if hr is failure code someone said "stop right now"
                // if hr is S_FALSE some one said "quit this directory and start with next one"
                if (hr == S_OK)   
                {
                    int ihdsa;
                    for (ihdsa = 0; ihdsa < DSA_GetItemCount(hdsaDelayed); ihdsa++)
                    {
                        WIN32_FIND_DATA * pwfd = (WIN32_FIND_DATA *)DSA_GetItemPtr(hdsaDelayed, ihdsa);
                        hr = _ProcessAndRecurse(pwfd);
                        if (hr != S_OK)
                            break;
                    }
                }
                DSA_Destroy(hdsaDelayed);
            }

            // Let the CallBack object know that we are finishing the walk
            if (_nDepth == 0 && !(_dwFlags & WT_EXCLUDEWALKROOT) &&
                (_dwFlags & WT_NOTIFYFOLDERLEAVE) && (S_OK == hr))
                hr = _CallCallBacks(STWCB_LEAVEDIR, &_fdTopLevelFolder);

            // hr was S_FALSE because someone wanted us to jump out of this current directory
            // but don't pass it back to our parent directory  
            if (hr == S_FALSE)
                hr = S_OK;
        }
        else
            TraceMsg(TF_TREEWALKER, "***WARNING***: PathCombine failed!!!!");
    }
    
    return hr;
}

// IShellTreeWalker::WalkTree is the main function for the IShellTreeWalker interface 
HRESULT CShellTreeWalker::WalkTree(DWORD dwFlags, LPCWSTR pwszWalkRoot, LPCWSTR pwszWalkSpec, int iMaxDepth, IShellTreeWalkerCallBack * pstwcb)
{
    HRESULT hr = E_FAIL;
    TCHAR szWalkSpec[64];

    // must have a call back object to talk to
    ASSERT(IS_VALID_CODE_PTR(pstwcb, IShellTreeWalkerCackBack));
    if (pstwcb == NULL)
        return E_INVALIDARG;

    // make sure we have a valid directory to start with
    ASSERT(IS_VALID_STRING_PTRW(pwszWalkRoot, -1));
    if ((pwszWalkRoot != NULL) && (pwszWalkRoot[0] != L'\0'))
    {
        SHUnicodeToTChar(pwszWalkRoot, _szWalkBuf, ARRAYSIZE(_szWalkBuf));
        // call back 
        _pstwcb = pstwcb;

        // copy the search flags and fix it up  
        _dwFlags = dwFlags & WT_ALL;
        
        // this will save us from using the hdsa array to hold the directories
        if (_dwFlags & WT_FOLDERONLY)
        {
            _dwFlags |= WT_FOLDERFIRST;

            // It will be pretty meanless if the below flags are not set, because
            // we don't call FoundFile in the FolderOnly case. 
            ASSERT(_dwFlags & (WT_NOTIFYFOLDERENTER | WT_NOTIFYFOLDERLEAVE));
        }

        if (_dwFlags & WT_FOLDERFIRST)
            _bFolderFirst = TRUE;
        
        if ((pwszWalkSpec != NULL) && (pwszWalkSpec[0] != L'\0'))
        {
            SHUnicodeToTChar(pwszWalkSpec, szWalkSpec, ARRAYSIZE(szWalkSpec));
            _pszWalkSpec = szWalkSpec;
        }
        
        _nMaxDepth = (dwFlags & WT_MAXDEPTH) ? iMaxDepth : 256;
        _dwClusterSize = PathGetClusterSize(_szWalkBuf);
        hr = _TreeWalkerHelper();
    }
    else
        TraceMsg(TF_WARNING, "CShellTreeWalker::WalkTree Failed! due to bad _szWalkBuf");
    
    return hr;
}

// IShellTreeWalker::QueryInterface
HRESULT CShellTreeWalker::QueryInterface(REFIID riid, void ** ppv)
{ 
    static const QITAB qit[] = {
        QITABENT(CShellTreeWalker, IShellTreeWalker),
        { 0 },
    };
    return QISearch(this, qit, riid, ppv);
}

// IShellTreeWalker::AddRef
ULONG CShellTreeWalker::AddRef()
{
    return InterlockedIncrement(&_cRef);
}

// IShellTreeWalker::Release
ULONG CShellTreeWalker::Release()
{
    if (InterlockedDecrement(&_cRef))
        return _cRef;

    delete this;
    return 0;
}

STDAPI CShellTreeWalker_CreateInstance(IUnknown* pUnkOuter, REFIID riid, OUT void **ppvOut)
{
    HRESULT hr;
    
    *ppvOut = NULL;                     

    CShellTreeWalker *pstw = new CShellTreeWalker;
    if (!pstw)
        return E_OUTOFMEMORY;
    
    hr = pstw->QueryInterface(riid, ppvOut);
    pstw->Release();
    
    return hr;
}
