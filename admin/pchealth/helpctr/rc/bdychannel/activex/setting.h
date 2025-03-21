/* 
Copyright (c) 2000 Microsoft Corporation

Module Name:
    setting.h

Abstract:
    Definition of the CSetting class

Revision History:
    created     steveshi      08/23/00
    
*/

#ifndef __SETTING_H_
#define __SETTING_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CSetting
class ATL_NO_VTABLE CSetting : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CSetting, &CLSID_Setting>,
	public IDispatchImpl<ISetting, &IID_ISetting, &LIBID_RCBDYCTLLib>
{
public:
	CSetting()
	{
        m_pIniFile = NULL;
        m_pProfileDir = NULL;
	}

    ~CSetting()
    {
        if (m_pIniFile) free(m_pIniFile);
        if (m_pProfileDir) free(m_pProfileDir);
    }

DECLARE_REGISTRY_RESOURCEID(IDR_Setting)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CSetting)
	COM_INTERFACE_ENTRY(ISetting)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// Ismapi
public:
	STDMETHOD(get_GetIPAddress)(/*[out, retval]*/ BSTR *pVal);
//	STDMETHOD(get_GetUserTempFileName)(/*[out, retval]*/ BSTR *pVal);
//	STDMETHOD(GetProfileString)(/*[in]*/ BSTR session, /*[out, retval]*/ BSTR *pVal);
//	STDMETHOD(SetProfileString)(/*[in]*/ BSTR session, /*[in]*/ BSTR newVal);
	STDMETHOD(get_CreatePassword)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_GetPropertyInBlob)(/*[in]*/ BSTR bstrBlob, /*[in]*/ BSTR bstrName, /*[out, retval]*/ BSTR *pVal);

public:

    TCHAR* m_pIniFile;
    TCHAR* m_pProfileDir;
/*
protected:
    HRESULT InitProfile();*/
};

#endif //__SETTING_H_
