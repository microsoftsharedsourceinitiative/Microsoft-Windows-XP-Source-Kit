/*++

Copyright (c) 1999  Microsoft Corporation

Abstract:

    @doc
    @module Find.hxx | Defines the internal snapshot persistency-related methods.
    @end

Author:

    Adi Oltean  [aoltean]   01/10/2000

Revision History:

    Name        Date        Comments

    aoltean     01/10/2000  Created.


--*/


/////////////////////////////////////////////////////////////////////////////
//  Includes


#include "stdafx.hxx"
#include <winnt.h>
#include "swprv.hxx"

#include "vs_idl.hxx"

#include "resource.h"
#include "vs_inc.hxx"
#include "ichannel.hxx"

#include "copy.hxx"
#include "pointer.hxx"
#include "enum.hxx"

#include "qsnap.hxx"

#include "ntddsnap.h"

////////////////////////////////////////////////////////////////////////
//  Standard foo for file name aliasing.  This code block must be after
//  all includes of VSS header files.
//
#ifdef VSS_FILE_ALIAS
#undef VSS_FILE_ALIAS
#endif
#define VSS_FILE_ALIAS "SPRFINDC"
//
////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
// CVssQueuedSnapshot::SaveXXX methods
//


void CVssQueuedSnapshot::EnumerateSnapshots(
	    IN  bool bSearchBySnapshotID,
	    IN  VSS_ID SnapshotID,
		IN  LONG lContext,
		IN OUT	VSS_OBJECT_PROP_Array* pArray
	    ) throw(HRESULT)

/*++

Description:

	This method enumerates all snapshots

Throws:

    VSS_E_PROVIDER_VETO
        - On runtime errors
    E_OUTOFMEMORY

--*/

{	
	CVssFunctionTracer ft( VSSDBG_SWPRV, L"CVssQueuedSnapshot::EnumerateSnapshots");
		
	// Enumerate snapshots through all the volumes
	WCHAR wszVolumeName[MAX_PATH+1];
	CVssAutoSearchHandle hSearch;
	bool bFirstVolume = true;
	while(true) {
	    
		// Get the volume name
		if (bFirstVolume) {
			hSearch.Set(::FindFirstVolumeW( wszVolumeName, MAX_PATH));
			if (hSearch == INVALID_HANDLE_VALUE)
				ft.TranslateInternalProviderError( VSSDBG_SWPRV, 
				    HRESULT_FROM_WIN32(GetLastError()), VSS_E_PROVIDER_VETO,
				    L"FindFirstVolumeW( [%s], MAX_PATH)", wszVolumeName);
		    BS_ASSERT( (HANDLE)hSearch );
			bFirstVolume = false;
		} else {
		    BS_ASSERT( (HANDLE)hSearch );
			if (!::FindNextVolumeW( hSearch, wszVolumeName, MAX_PATH) ) {
				if (GetLastError() == ERROR_NO_MORE_FILES)
					break;	// End of iteration
				else
    				ft.TranslateInternalProviderError( VSSDBG_SWPRV, 
    				    HRESULT_FROM_WIN32(GetLastError()), VSS_E_PROVIDER_VETO,
    				    L"FindNextVolumeW( %p, [%s], MAX_PATH)", hSearch, wszVolumeName);
			}
		}

        // Check if the volume is fixed (i.e. no CD-ROM, no removable)
        UINT uDriveType = ::GetDriveTypeW(wszVolumeName);
        if ( uDriveType != DRIVE_FIXED) {
            ft.Trace( VSSDBG_SWPRV, L"Warning: Ingnoring the non-fixed volume (%s) - %ud",
                      wszVolumeName, uDriveType);
            continue;
        }

        // Enumerate the snapshots on that volume
        BOOL bResult = EnumerateSnapshotsOnVolume( wszVolumeName, 
            bSearchBySnapshotID, SnapshotID, lContext, pArray );

        if (!bResult)
            continue;
	}
}


bool CVssQueuedSnapshot::EnumerateSnapshotsOnVolume(
		IN  VSS_PWSZ wszVolumeName,
	    IN  bool bSearchBySnapshotID,
	    IN  VSS_ID SnapshotID,
		IN  LONG lContext,
		IN OUT	VSS_OBJECT_PROP_Array* pArray,
	    IN  bool bThrowOnError // = false  By default do not throw on error
	    ) throw(HRESULT)

/*++

Description:

	This method enumerates all snapshots o the give volume

Returns:

    false - if the enumeration of volumes may continue
    true - otherwise

Throws:

    VSS_E_PROVIDER_VETO
        - On runtime errors
    E_OUTOFMEMORY

--*/
{
	CVssFunctionTracer ft( VSSDBG_SWPRV, L"CVssQueuedSnapshot::EnumerateSnapshotsOnVolume");
		
	// Check if the snapshot is belonging to that volume
	// Open a IOCTL channel on that volume
	// Eliminate the last backslash in order to open the volume
	CVssIOCTLChannel volumeIChannel;
	ft.hr = volumeIChannel.Open(ft, wszVolumeName, true, bThrowOnError, 
	            bThrowOnError? VSS_ICHANNEL_LOG_PROV: VSS_ICHANNEL_LOG_NONE);
	if (ft.HrFailed())
		return false;

	// Get the list of snapshots
	// If IOCTL_VOLSNAP_QUERY_NAMES_OF_SNAPSHOTS not
	// supported then try with the next volume.
	ft.hr = volumeIChannel.Call(ft, IOCTL_VOLSNAP_QUERY_NAMES_OF_SNAPSHOTS, 
	            bThrowOnError, bThrowOnError? VSS_ICHANNEL_LOG_PROV: VSS_ICHANNEL_LOG_NONE);
	if (ft.HrFailed())
		return false;

	// Get the length of snapshot names multistring
	ULONG ulMultiszLen;
	volumeIChannel.Unpack(ft, &ulMultiszLen);

#ifdef _DEBUG
	// Try to find the snapshot with the corresponding Id
	DWORD dwInitialOffset = volumeIChannel.GetCurrentOutputOffset();
#endif

	CVssAutoPWSZ pwszSnapshotName;
	while(volumeIChannel.UnpackZeroString(ft, pwszSnapshotName.GetRef())) {
	    
		// Compose the snapshot name in a user-mode style
		WCHAR wszUserModeSnapshotName[MAX_PATH];
        ::VssConcatenate( ft, wszUserModeSnapshotName, MAX_PATH - 1,
            wszGlobalRootPrefix, pwszSnapshotName );
		
		// Open that snapshot 
		// Do not eliminate the trailing backslash
		// Do not throw on error
    	CVssIOCTLChannel snapshotIChannel;
		ft.hr = snapshotIChannel.Open(ft, wszUserModeSnapshotName, false, 
		            bThrowOnError, bThrowOnError? VSS_ICHANNEL_LOG_PROV: VSS_ICHANNEL_LOG_NONE);
		if (ft.HrFailed()) {
			ft.Warning( VSSDBG_SWPRV, L"Warning: Error opening the snapshot device name %s [0x%08lx]",
						wszUserModeSnapshotName, ft.hr );
			return false;
		}

		// Send the IOCTL to get the application buffer
		ft.hr = snapshotIChannel.Call(ft, IOCTL_VOLSNAP_QUERY_APPLICATION_INFO, 
		            bThrowOnError, bThrowOnError? VSS_ICHANNEL_LOG_PROV: VSS_ICHANNEL_LOG_NONE);
		if (ft.HrFailed()) {
			ft.Warning( VSSDBG_SWPRV,
						L"Warning: Error sending the query IOCTL to the snapshot device name %s [0x%08lx]",
						wszUserModeSnapshotName, ft.hr );
			return false;
		}

		// Unpack the length of the application buffer
		ULONG ulLen;
		snapshotIChannel.Unpack(ft, &ulLen);

		if (ulLen == 0) {
		    BS_ASSERT(false);
			ft.Warning(VSSDBG_SWPRV, L"Warning: zero-size snapshot detected: %s", pwszSnapshotName);
			continue;
		}

    	// Unpack the Appinfo ID
    	VSS_ID AppinfoId;
    	snapshotIChannel.Unpack(ft, &AppinfoId);

        // We encountered a hidden snapshot
        if (AppinfoId == VOLSNAP_APPINFO_GUID_HIDDEN)
            continue;

        // Check for invalid values
    	if ((AppinfoId != VOLSNAP_APPINFO_GUID_BACKUP_SERVER_SKU) &&
    	    (AppinfoId != VOLSNAP_APPINFO_GUID_CLIENT_ACCESSIBLE))
    	{
    	    ft.Trace(VSSDBG_SWPRV, L"Unsupported app info for snapshot %s: " WSTR_GUID_FMT, 
    	        pwszSnapshotName.GetRef(), GUID_PRINTF_ARG(AppinfoId));
    	    continue;
    	}

		// Get the snapshot Id
		VSS_ID CurrentSnapshotId;
		snapshotIChannel.Unpack(ft, &CurrentSnapshotId);

        // If we are filtering, ignore the rest...
        if (bSearchBySnapshotID)
            if (SnapshotID != CurrentSnapshotId)
                continue;

		// Get the snapshot set Id
		VSS_ID CurrentSnapshotSetId;
		snapshotIChannel.Unpack(ft, &CurrentSnapshotSetId);

        // Get the snapshot context
        LONG lStructureContext;
		snapshotIChannel.Unpack(ft, &lStructureContext);

        // Further validation
        switch(lStructureContext)
        {
        case VSS_CTX_BACKUP:
            BS_ASSERT(AppinfoId == VOLSNAP_APPINFO_GUID_BACKUP_SERVER_SKU);
            break;
        case VSS_CTX_CLIENT_ACCESSIBLE:
            BS_ASSERT(AppinfoId == VOLSNAP_APPINFO_GUID_CLIENT_ACCESSIBLE);
            break;
        default:
            BS_ASSERT(false);
            continue;
        }

		// If the snapshot belongs to the wrong context, then ignore it.
		if (lContext != VSS_CTX_ALL)
		    if (lContext != lStructureContext)
                continue;
		
        //
		// Process the snapshot that was just found
		//
		
		// Initialize an empty snapshot properties structure
		VSS_OBJECT_PROP_Ptr ptrSnapProp;
		ptrSnapProp.InitializeAsSnapshot( ft,
			CurrentSnapshotId,
			CurrentSnapshotSetId,
			0,
			wszUserModeSnapshotName,
			wszVolumeName,
			NULL,
			NULL,
			NULL,
			NULL,
			VSS_SWPRV_ProviderId,
			lStructureContext,
			0,
			VSS_SS_UNKNOWN);

		// Get the snapshot structure
		VSS_OBJECT_PROP* pObj = ptrSnapProp.GetStruct();
		BS_ASSERT(pObj);
		VSS_SNAPSHOT_PROP* pSnap = &(pObj->Obj.Snap);

		// Load the rest of properties
		// Do not load the Name and the Original volume name fields
		// twice since they are already known
		LoadStructure( snapshotIChannel, pSnap, NULL, NULL, true );

    	// Get the original volume name and Id
		CVssQueuedSnapshot::LoadOriginalVolumeNameIoctl(
		    snapshotIChannel, 
		    &(pSnap->m_pwszOriginalVolumeName));

    	// Get the timestamp
    	CVssQueuedSnapshot::LoadTimestampIoctl(
    	    snapshotIChannel, 
    	    &(pSnap->m_tsCreationTimestamp));
    		
		if (!pArray->Add(ptrSnapProp))
			ft.Throw( VSSDBG_SWPRV, E_OUTOFMEMORY,
					  L"Cannot add element to the array");

		// Reset the current pointer to NULL
		ptrSnapProp.Reset(); // The internal pointer was detached into pArray.
	}

#ifdef _DEBUG
	// Check if all strings were browsed correctly
	DWORD dwFinalOffset = volumeIChannel.GetCurrentOutputOffset();
	BS_ASSERT( (dwFinalOffset - dwInitialOffset == ulMultiszLen));
#endif

	return true;
}



bool CVssQueuedSnapshot::FindPersistedSnapshotByID(
    IN  VSS_ID SnapshotID,
    IN  LONG lContext,
    OUT LPWSTR * ppwszSnapshotDeviceObject
    ) throw(HRESULT)

/*++

Description:

	Finds a snapshot (and its device name) based on ID.

Throws:

    E_OUTOFMEMORY

    [EnumerateSnapshots() failures]
        VSS_E_PROVIDER_VETO
            - On runtime errors (like Unpack)
        E_OUTOFMEMORY    

--*/
{
	CVssFunctionTracer ft( VSSDBG_SWPRV, L"CVssQueuedSnapshot::FindPersistedSnapshotByID");
		
	BS_ASSERT(SnapshotID != GUID_NULL);
	if (ppwszSnapshotDeviceObject != NULL) {
    	BS_ASSERT((*ppwszSnapshotDeviceObject) == NULL);
	}

    // Create the collection object. Initial reference count is 0.
    VSS_OBJECT_PROP_Array* pArray = new VSS_OBJECT_PROP_Array;
    if (pArray == NULL)
        ft.Throw( VSSDBG_SWPRV, E_OUTOFMEMORY, L"Memory allocation error.");

    // Get the pointer to the IUnknown interface.
	// The only purpose of this is to use a smart ptr to destroy correctly the array on error.
	// Now pArray's reference count becomes 1 (because of the smart pointer).
    CComPtr<IUnknown> pArrayItf = static_cast<IUnknown*>(pArray);
    BS_ASSERT(pArrayItf);

    // Put into the array only one element.
    EnumerateSnapshots(
	    true,
    	SnapshotID,
    	lContext,
    	pArray
    	);

    // Extract the element from the array.
    if (pArray->GetSize() == 0)
    	return false;

    if (ppwszSnapshotDeviceObject) {
    	VSS_OBJECT_PROP_Ptr& ptrObj = (*pArray)[0];
    	VSS_OBJECT_PROP* pObj = ptrObj.GetStruct();
    	BS_ASSERT(pObj);
    	BS_ASSERT(pObj->Type == VSS_OBJECT_SNAPSHOT);
    	VSS_SNAPSHOT_PROP* pSnap = &(pObj->Obj.Snap);
    	BS_ASSERT(pSnap->m_pwszSnapshotDeviceObject);
    	::VssSafeDuplicateStr(ft, (*ppwszSnapshotDeviceObject), 
    	    pSnap->m_pwszSnapshotDeviceObject);
    }

    return true;
}



