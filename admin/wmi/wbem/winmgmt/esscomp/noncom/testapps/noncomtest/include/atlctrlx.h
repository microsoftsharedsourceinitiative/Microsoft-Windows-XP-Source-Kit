// WTL Version 3.0
// Copyright (C) 1997-1999 Microsoft Corporation
// All rights reserved.
//
// This file is a part of Windows Template Library.
// The code and information is provided "as-is" without
// warranty of any kind, either expressed or implied.

#ifndef __ATLCTRLX_H__
#define __ATLCTRLX_H__

#pragma once

#ifndef __cplusplus
	#error ATL requires C++ compilation (use a .cpp suffix)
#endif

#ifndef __ATLAPP_H__
	#error atlctrlx.h requires atlapp.h to be included first
#endif

#ifndef __ATLCTRLS_H__
	#error atlctrlx.h requires atlctrls.h to be included first
#endif


namespace WTL
{

/////////////////////////////////////////////////////////////////////////////
// Forward declarations

template <class T, class TBase = CButton, class TWinTraits = CControlWinTraits> class CBitmapButtonImpl;
class CBitmapButton;
template <class T, class TBase = CListViewCtrl, class TWinTraits = CCheckListViewCtrlTraits> class CCheckListViewCtrlImpl;
class CCheckListViewCtrl;
template <class T, class TBase = CWindow, class TWinTraits = CControlWinTraits> class CHyperLinkImpl;
class CHyperLink;
class CWaitCursor;
template <class T, class TBase = CStatusBarCtrl> class CMultiPaneStatusBarCtrlImpl;
class CMultiPaneStatusBarCtrl;


/////////////////////////////////////////////////////////////////////////////
// CBitmapButton - bitmap button implementation

// bitmap button extended styles
#define BMPBTN_HOVER		0x00000001
#define BMPBTN_AUTO3D_SINGLE	0x00000002
#define BMPBTN_AUTO3D_DOUBLE	0x00000004
#define BMPBTN_AUTOSIZE		0x00000008
#define BMPBTN_SHAREIMAGELISTS	0x00000010

template <class T, class TBase = CButton, class TWinTraits = CControlWinTraits>
class ATL_NO_VTABLE CBitmapButtonImpl : public CWindowImpl< T, TBase, TWinTraits>
{
public:
	DECLARE_WND_SUPERCLASS(NULL, TBase::GetWndClassName())

	enum
	{
		_nImageNormal = 0,
		_nImagePushed,
		_nImageFocusOrHover,
		_nImageDisabled,

		_nImageCount = 4
	};

	// Bitmap button specific extended styles
	DWORD m_dwExtendedStyle;

	CImageList m_ImageList;
	int m_nImage[_nImageCount];

	CToolTipCtrl m_tip;
	LPTSTR m_lpstrToolTipText;

	// Internal states
	unsigned m_fMouseOver:1;
	unsigned m_fFocus:1;
	unsigned m_fPressed:1;


// Constructor/Destructor
	CBitmapButtonImpl(DWORD dwExtendedStyle = BMPBTN_AUTOSIZE, HIMAGELIST hImageList = NULL) : 
			m_ImageList(hImageList), m_dwExtendedStyle(dwExtendedStyle), m_lpstrToolTipText(NULL),
			m_fMouseOver(0), m_fFocus(0), m_fPressed(0)
	{
		m_nImage[_nImageNormal] = -1;
		m_nImage[_nImagePushed] = -1;
		m_nImage[_nImageFocusOrHover] = -1;
		m_nImage[_nImageDisabled] = -1;
	}

	~CBitmapButtonImpl()
	{
		if((m_dwExtendedStyle & BMPBTN_SHAREIMAGELISTS) == 0)
			m_ImageList.Destroy();
		delete [] m_lpstrToolTipText;
	}

	// overridden to provide proper initialization
	BOOL SubclassWindow(HWND hWnd)
	{
		BOOL bRet = CWindowImpl< T, TBase, TWinTraits>::SubclassWindow(hWnd);
		if(bRet)
			Init();
		return bRet;
	}

// Attributes
	DWORD GetBitmapButtonExtendedStyle() const
	{
		return m_dwExtendedStyle;
	}
	DWORD SetBitmapButtonExtendedStyle(DWORD dwExtendedStyle)
	{
		DWORD dwPrevStyle = m_dwExtendedStyle;
		m_dwExtendedStyle = dwExtendedStyle;
		return dwPrevStyle;
	}
	HIMAGELIST GetImageList() const
	{
		return m_ImageList;
	}
	HIMAGELIST SetImageList(HIMAGELIST hImageList)
	{
		HIMAGELIST hImageListPrev = m_ImageList;
		m_ImageList = hImageList;
		if((m_dwExtendedStyle & BMPBTN_AUTOSIZE) != 0 && ::IsWindow(m_hWnd))
			SizeToImage();
		return hImageListPrev;
	}
	int GetToolTipTextLength() const
	{
		return (m_lpstrToolTipText == NULL) ? -1 : lstrlen(m_lpstrToolTipText);
	}
	bool GetToolTipText(LPTSTR lpstrText, int nLength) const
	{
		ATLASSERT(lpstrText != NULL);
		if(m_lpstrToolTipText == NULL)
			return false;
		return (lstrcpyn(lpstrText, m_lpstrToolTipText, min(nLength, lstrlen(m_lpstrToolTipText) + 1)) != NULL);
	}
	bool SetToolTipText(LPCTSTR lpstrText)
	{
		if(m_lpstrToolTipText != NULL)
		{
			delete [] m_lpstrToolTipText;
			m_lpstrToolTipText = NULL;
		}
		if(lpstrText == NULL)
		{
			if(m_tip.IsWindow())
				m_tip.Activate(FALSE);
			return true;
		}
		ATLTRY(m_lpstrToolTipText = new TCHAR[lstrlen(lpstrText) + 1]);
		if(m_lpstrToolTipText == NULL)
			return false;
		bool bRet = (lstrcpy(m_lpstrToolTipText, lpstrText) != NULL);
		if(bRet && m_tip.IsWindow())
		{
			m_tip.Activate(TRUE);
			m_tip.AddTool(m_hWnd, m_lpstrToolTipText);
		}
		return bRet;
	}

// Operations
	void SetImages(int nNormal, int nPushed = -1, int nFocusOrHover = -1, int nDisabled = -1)
	{
		if(nNormal != -1)
			m_nImage[_nImageNormal] = nNormal;
		if(nPushed != -1)
			m_nImage[_nImagePushed] = nPushed;
		if(nFocusOrHover != -1)
			m_nImage[_nImageFocusOrHover] = nFocusOrHover;
		if(nDisabled != -1)
			m_nImage[_nImageDisabled] = nDisabled;
	}
	BOOL SizeToImage()
	{
		ATLASSERT(::IsWindow(m_hWnd) && m_ImageList.m_hImageList != NULL);
		int cx = 0;
		int cy = 0;
		if(!m_ImageList.GetIconSize(cx, cy))
			return FALSE;
		return ResizeClient(cx, cy);
	}

// Overrideables
	void DoPaint(CDCHandle dc)
	{
		ATLASSERT(m_ImageList.m_hImageList != NULL);	// image list must be set
		ATLASSERT(m_nImage[0] != -1);			// main bitmap must be set

		// set bitmap according to the current button state
		int nImage = -1;
		bool bHover = IsHoverMode();
		if(m_fPressed == 1)
			nImage = m_nImage[_nImagePushed];
		else if((!bHover && m_fFocus == 1) || (bHover && m_fMouseOver == 1))
			nImage = m_nImage[_nImageFocusOrHover];
		else if(!IsWindowEnabled())
			nImage = m_nImage[_nImageDisabled];
		if(nImage == -1)	// not there, use default one
			nImage = m_nImage[_nImageNormal];

		// draw the button image
		int xyPos = 0;
		if((m_fPressed == 1) && (m_dwExtendedStyle & (BMPBTN_AUTO3D_SINGLE | BMPBTN_AUTO3D_DOUBLE) != 0) && (m_nImage[_nImagePushed] == -1))
			xyPos = 1;
		m_ImageList.Draw(dc, nImage, xyPos, xyPos, ILD_NORMAL);

		// draw 3D border if required
		if((m_dwExtendedStyle & (BMPBTN_AUTO3D_SINGLE | BMPBTN_AUTO3D_DOUBLE)) != 0)
		{
			RECT rect;
			GetClientRect(&rect);

			if(m_fPressed == 1)
				dc.DrawEdge(&rect, ((m_dwExtendedStyle & BMPBTN_AUTO3D_SINGLE) != 0) ? BDR_SUNKENOUTER : EDGE_SUNKEN, BF_RECT);
			else if(!bHover || m_fMouseOver == 1)
				dc.DrawEdge(&rect, ((m_dwExtendedStyle & BMPBTN_AUTO3D_SINGLE) != 0) ? BDR_RAISEDINNER : EDGE_RAISED, BF_RECT);

			if(!bHover && m_fFocus == 1)
			{
				::InflateRect(&rect, -2 * ::GetSystemMetrics(SM_CXEDGE), -2 * ::GetSystemMetrics(SM_CYEDGE));
				dc.DrawFocusRect(&rect);
			}
		}
	}

// Message map and handlers
	typedef CBitmapButtonImpl< T, TBase, TWinTraits >	thisClass;
	BEGIN_MSG_MAP(thisClass)
		MESSAGE_HANDLER(WM_CREATE, OnCreate)
		MESSAGE_RANGE_HANDLER(WM_MOUSEFIRST, WM_MOUSELAST, OnMouseMessage)
		MESSAGE_HANDLER(WM_ERASEBKGND, OnEraseBackground)
		MESSAGE_HANDLER(WM_PAINT, OnPaint)
		MESSAGE_HANDLER(WM_PRINTCLIENT, OnPaint)
		MESSAGE_HANDLER(WM_SETFOCUS, OnFocus)
		MESSAGE_HANDLER(WM_KILLFOCUS, OnFocus)
		MESSAGE_HANDLER(WM_LBUTTONDOWN, OnLButtonDown)
		MESSAGE_HANDLER(WM_LBUTTONDBLCLK, OnLButtonDblClk)
		MESSAGE_HANDLER(WM_LBUTTONUP, OnLButtonUp)
		MESSAGE_HANDLER(WM_CAPTURECHANGED, OnCaptureChanged)
		MESSAGE_HANDLER(WM_ENABLE, OnEnable)
		MESSAGE_HANDLER(WM_MOUSEMOVE, OnMouseMove)
		MESSAGE_HANDLER(WM_MOUSELEAVE, OnMouseLeave)
		MESSAGE_HANDLER(WM_KEYDOWN, OnKeyDown)
		MESSAGE_HANDLER(WM_KEYUP, OnKeyUp)
	END_MSG_MAP()

	LRESULT OnCreate(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
	{
		Init();
		bHandled = FALSE;
		return 1;
	}

	LRESULT OnMouseMessage(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
	{
		MSG msg = { m_hWnd, uMsg, wParam, lParam };
		if(m_tip.IsWindow())
			m_tip.RelayEvent(&msg);
		bHandled = FALSE;
		return 1;
	}

	LRESULT OnEraseBackground(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/)
	{
		return 1;	// no background needed
	}

	LRESULT OnPaint(UINT /*uMsg*/, WPARAM wParam, LPARAM /*lParam*/, BOOL& /*bHandled*/)
	{
		T* pT = static_cast<T*>(this);
		if(wParam != NULL)
		{
			pT->DoPaint((HDC)wParam);
		}
		else
		{
			CPaintDC dc(m_hWnd);
			pT->DoPaint(dc.m_hDC);
		}
		return 0;
	}

	LRESULT OnFocus(UINT uMsg, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
	{
		m_fFocus = (uMsg == WM_SETFOCUS) ? 1 : 0;
		Invalidate();
		UpdateWindow();
		bHandled = FALSE;
		return 1;
	}

	LRESULT OnLButtonDown(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& /*bHandled*/)
	{
		LRESULT lRet = DefWindowProc(uMsg, wParam, lParam);
		if(::GetCapture() == m_hWnd)
		{
			m_fPressed = 1;
			Invalidate();
			UpdateWindow();
		}
		return lRet;
	}

	LRESULT OnLButtonDblClk(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& /*bHandled*/)
	{
		LRESULT lRet = DefWindowProc(uMsg, wParam, lParam);
		if(::GetCapture() != m_hWnd)
			SetCapture();
		if(m_fPressed == 0)
		{
			m_fPressed = 1;
			Invalidate();
			UpdateWindow();
		}
		return lRet;
	}

	LRESULT OnLButtonUp(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& /*bHandled*/)
	{
		LRESULT lRet = DefWindowProc(uMsg, wParam, lParam);
		if(::GetCapture() == m_hWnd)
			::ReleaseCapture();
		return lRet;
	}

	LRESULT OnCaptureChanged(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
	{
		if(m_fPressed == 1)
		{
			m_fPressed = 0;
			Invalidate();
			UpdateWindow();
		}
		bHandled = FALSE;
		return 1;
	}

	LRESULT OnEnable(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
	{
		Invalidate();
		UpdateWindow();
		bHandled = FALSE;
		return 1;
	}

	LRESULT OnMouseMove(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM lParam, BOOL& bHandled)
	{
		if(::GetCapture() == m_hWnd)
		{
			POINT ptCursor = { GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam) };
			ClientToScreen(&ptCursor);
			RECT rect;
			GetWindowRect(&rect);
			unsigned int uPressed = ::PtInRect(&rect, ptCursor) ? 1 : 0;
			if(m_fPressed != uPressed)
			{
				m_fPressed = uPressed;
				Invalidate();
				UpdateWindow();
			}
		}
		else if(IsHoverMode() && m_fMouseOver == 0)
		{
			m_fMouseOver = 1;
			Invalidate();
			UpdateWindow();
			StartTrackMouseLeave();
		}
		bHandled = FALSE;
		return 1;
	}

	LRESULT OnMouseLeave(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/)
	{
		if(m_fMouseOver == 1)
		{
			m_fMouseOver = 0;
			Invalidate();
			UpdateWindow();
		}
		return 0;
	}

	LRESULT OnKeyDown(UINT /*uMsg*/, WPARAM wParam, LPARAM /*lParam*/, BOOL& bHandled)
	{
		if(wParam == VK_SPACE && IsHoverMode())
			return 0;	// ignore if in hover mode
		if(wParam == VK_SPACE && m_fPressed == 0)
		{
			m_fPressed = 1;
			Invalidate();
			UpdateWindow();
		}
		bHandled = FALSE;
		return 1;
	}

	LRESULT OnKeyUp(UINT /*uMsg*/, WPARAM wParam, LPARAM /*lParam*/, BOOL& bHandled)
	{
		if(wParam == VK_SPACE && IsHoverMode())
			return 0;	// ignore if in hover mode
		if(wParam == VK_SPACE && m_fPressed == 1)
		{
			m_fPressed = 0;
			Invalidate();
			UpdateWindow();
		}
		bHandled = FALSE;
		return 1;
	}

// Implementation
	void Init()
	{
		// We need this style to prevent Windows from painting the button
		ModifyStyle(0, BS_OWNERDRAW);

		// create a tool tip
		m_tip.Create(m_hWnd);
		ATLASSERT(m_tip.IsWindow());
		if(m_tip.IsWindow() && m_lpstrToolTipText != NULL)
		{
			m_tip.Activate(TRUE);
			m_tip.AddTool(m_hWnd, m_lpstrToolTipText);
		}

		if(m_ImageList.m_hImageList != NULL && (m_dwExtendedStyle & BMPBTN_AUTOSIZE) != 0)
			SizeToImage();
	}

	BOOL StartTrackMouseLeave()
	{
		TRACKMOUSEEVENT tme;
		tme.cbSize = sizeof(tme);
		tme.dwFlags = TME_LEAVE;
		tme.hwndTrack = m_hWnd;
		return _TrackMouseEvent(&tme);
	}

	bool IsHoverMode() const
	{
		return ((m_dwExtendedStyle & BMPBTN_HOVER) != 0);
	}
};


class CBitmapButton : public CBitmapButtonImpl<CBitmapButton>
{
public:
	DECLARE_WND_SUPERCLASS(_T("WTL_BitmapButton"), GetWndClassName())

	CBitmapButton(DWORD dwExtendedStyle = BMPBTN_AUTOSIZE, HIMAGELIST hImageList = NULL) : 
		CBitmapButtonImpl<CBitmapButton>(dwExtendedStyle, hImageList)
	{ }
};


/////////////////////////////////////////////////////////////////////////////
// CCheckListCtrlView - list view control with check boxes

template <DWORD t_dwStyle, DWORD t_dwExStyle, DWORD t_dwExListViewStyle>
class CCheckListViewCtrlImplTraits
{
public:
	static DWORD GetWndStyle(DWORD dwStyle)
	{
		return dwStyle == 0 ? t_dwStyle : dwStyle;
	}
	static DWORD GetWndExStyle(DWORD dwExStyle)
	{
		return dwExStyle == 0 ? t_dwExStyle : dwExStyle;
	}
	static DWORD GetExtendedLVStyle()
	{
		return t_dwExListViewStyle;
	}
};

typedef CCheckListViewCtrlImplTraits<WS_CHILD | WS_VISIBLE | LVS_REPORT | LVS_SHOWSELALWAYS, WS_EX_CLIENTEDGE, LVS_EX_CHECKBOXES | LVS_EX_FULLROWSELECT>	CCheckListViewCtrlTraits;

template <class T, class TBase = CListViewCtrl, class TWinTraits = CCheckListViewCtrlTraits>
class ATL_NO_VTABLE CCheckListViewCtrlImpl : public CWindowImpl<T, TBase, TWinTraits>
{
public:
	DECLARE_WND_SUPERCLASS(NULL, TBase::GetWndClassName())

// Attributes
	static DWORD GetExtendedLVStyle()
	{
		return TWinTraits::GetExtendedLVStyle();
	}

// Operations
	BOOL SubclassWindow(HWND hWnd)
	{
		BOOL bRet = CWindowImplBaseT< TBase, TWinTraits>::SubclassWindow(hWnd);
		if(bRet)
		{
			T* pT = static_cast<T*>(this);
			pT;
			ATLASSERT((pT->GetExtendedLVStyle() & LVS_EX_CHECKBOXES) != 0);
			SetExtendedListViewStyle(pT->GetExtendedLVStyle());
		}
		return bRet;
	}

	void CheckSelectedItems(int nCurrItem)
	{
		// first check if this item is selected
		LVITEM lvi;
		lvi.iItem = nCurrItem;
		lvi.iSubItem = 0;
		lvi.mask = LVIF_STATE;
		lvi.stateMask = LVIS_SELECTED;
		GetItem(&lvi);
		// if item is not selected, don't do anything
		if(!(lvi.state & LVIS_SELECTED))
			return;
		// new check state will be reverse of the current state,
		BOOL bCheck = !GetCheckState(nCurrItem);
		int nItem = -1;
		int nOldItem = -1;
		while((nItem = GetNextItem(nOldItem, LVNI_SELECTED)) != -1)
		{
			if(nItem != nCurrItem)
				SetCheckState(nItem, bCheck);
			nOldItem = nItem;
		}
	}

// Implementation
	typedef CCheckListViewCtrlImpl< T, TBase, TWinTraits >	thisClass;
	BEGIN_MSG_MAP(thisClass)
		MESSAGE_HANDLER(WM_CREATE, OnCreate)
		MESSAGE_HANDLER(WM_LBUTTONDOWN, OnLButtonDown)
		MESSAGE_HANDLER(WM_LBUTTONDBLCLK, OnLButtonDown)
		MESSAGE_HANDLER(WM_KEYDOWN, OnKeyDown)
	END_MSG_MAP()

	LRESULT OnCreate(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& /*bHandled*/)
	{
		// first let list view control initialize everything
		LRESULT lRet = DefWindowProc(uMsg, wParam, lParam);
		T* pT = static_cast<T*>(this);
		pT;
		ATLASSERT((pT->GetExtendedLVStyle() & LVS_EX_CHECKBOXES) != 0);
		SetExtendedListViewStyle(pT->GetExtendedLVStyle());
		return lRet;
	}

	LRESULT OnLButtonDown(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM lParam, BOOL& bHandled)
	{
		POINT ptMsg = { GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam) };
		LVHITTESTINFO lvh;
		lvh.pt = ptMsg;
		if(HitTest(&lvh) != -1 && lvh.flags == LVHT_ONITEMSTATEICON && ::GetKeyState(VK_CONTROL) >= 0)
			CheckSelectedItems(lvh.iItem);
		bHandled = FALSE;
		return 1;
	}

	LRESULT OnKeyDown(UINT /*uMsg*/, WPARAM wParam, LPARAM /*lParam*/, BOOL& bHandled)
	{
		if(wParam == VK_SPACE)
		{
			int nCurrItem = GetNextItem(-1, LVNI_FOCUSED);
			if(nCurrItem != -1  && ::GetKeyState(VK_CONTROL) >= 0)
				CheckSelectedItems(nCurrItem);
		}
		bHandled = FALSE;
		return 1;
	}
};

class CCheckListViewCtrl : public CCheckListViewCtrlImpl<CCheckListViewCtrl>
{
public:
	DECLARE_WND_SUPERCLASS(_T("WTL_CheckListView"), GetWndClassName())
};


/////////////////////////////////////////////////////////////////////////////
// CHyperLink - hyper link control implementation

#if (WINVER < 0x0500)
__declspec(selectany) struct
{
	enum { cxWidth = 32, cyHeight = 32 };
	int xHotSpot;
	int yHotSpot;
	unsigned char arrANDPlane[cxWidth * cyHeight / 8];
	unsigned char arrXORPlane[cxWidth * cyHeight / 8];
} _AtlHyperLink_CursorData = 
{
	5, 0, 
	{
		0xF9, 0xFF, 0xFF, 0xFF, 0xF0, 0xFF, 0xFF, 0xFF, 0xF0, 0xFF, 0xFF, 0xFF, 0xF0, 0xFF, 0xFF, 0xFF, 
		0xF0, 0xFF, 0xFF, 0xFF, 0xF0, 0x3F, 0xFF, 0xFF, 0xF0, 0x07, 0xFF, 0xFF, 0xF0, 0x01, 0xFF, 0xFF, 
		0xF0, 0x00, 0xFF, 0xFF, 0x10, 0x00, 0x7F, 0xFF, 0x00, 0x00, 0x7F, 0xFF, 0x00, 0x00, 0x7F, 0xFF, 
		0x80, 0x00, 0x7F, 0xFF, 0xC0, 0x00, 0x7F, 0xFF, 0xC0, 0x00, 0x7F, 0xFF, 0xE0, 0x00, 0x7F, 0xFF, 
		0xE0, 0x00, 0xFF, 0xFF, 0xF0, 0x00, 0xFF, 0xFF, 0xF0, 0x00, 0xFF, 0xFF, 0xF8, 0x01, 0xFF, 0xFF, 
		0xF8, 0x01, 0xFF, 0xFF, 0xF8, 0x01, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
	},
	{
		0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 
		0x06, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 0x06, 0xC0, 0x00, 0x00, 0x06, 0xD8, 0x00, 0x00, 
		0x06, 0xDA, 0x00, 0x00, 0x06, 0xDB, 0x00, 0x00, 0x67, 0xFB, 0x00, 0x00, 0x77, 0xFF, 0x00, 0x00, 
		0x37, 0xFF, 0x00, 0x00, 0x17, 0xFF, 0x00, 0x00, 0x1F, 0xFF, 0x00, 0x00, 0x0F, 0xFF, 0x00, 0x00, 
		0x0F, 0xFE, 0x00, 0x00, 0x07, 0xFE, 0x00, 0x00, 0x07, 0xFE, 0x00, 0x00, 0x03, 0xFC, 0x00, 0x00, 
		0x03, 0xFC, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	}
};
#endif //(WINVER < 0x0500)


template <class T, class TBase = CWindow, class TWinTraits = CControlWinTraits>
class ATL_NO_VTABLE CHyperLinkImpl : public CWindowImpl< T, TBase, TWinTraits >
{
public:
	LPTSTR m_lpstrLabel;
	LPTSTR m_lpstrHyperLink;
	HCURSOR m_hCursor;
	HFONT m_hFont;
	RECT m_rcLink;
	bool m_bPaintLabel;
	CToolTipCtrl m_tip;

	bool m_bVisited;
	COLORREF m_clrLink;
	COLORREF m_clrVisited;


// Constructor/Destructor
	CHyperLinkImpl() : m_lpstrLabel(NULL), m_lpstrHyperLink(NULL),
			m_hCursor(NULL), m_hFont(NULL), m_bPaintLabel(true), m_bVisited(false),
			m_clrLink(RGB(0, 0, 255)), m_clrVisited(RGB(128, 0, 128))
	{
		::SetRectEmpty(&m_rcLink);
	}

	~CHyperLinkImpl()
	{
		free(m_lpstrLabel);
		free(m_lpstrHyperLink);
		if(m_hFont != NULL)
			::DeleteObject(m_hFont);
#if (WINVER < 0x0500)
		// It was created, not loaded, so we have to destroy it
		if(m_hCursor != NULL)
			::DestroyCursor(m_hCursor);
#endif //(WINVER < 0x0500)
	}

// Attributes
	bool GetLabel(LPTSTR lpstrBuffer, int nLength) const
	{
		if(m_lpstrLabel == NULL)
			return false;
		ATLASSERT(lpstrBuffer != NULL);
		if(nLength > lstrlen(m_lpstrLabel) + 1)
		{
			lstrcpy(lpstrBuffer, m_lpstrLabel);
			return true;
		}
		return false;
	}

	bool SetLabel(LPCTSTR lpstrLabel)
	{
		free(m_lpstrLabel);
		m_lpstrLabel = NULL;
		ATLTRY(m_lpstrLabel = (LPTSTR)malloc((lstrlen(lpstrLabel) + 1) * sizeof(TCHAR)));
		if(m_lpstrLabel == NULL)
			return false;
		lstrcpy(m_lpstrLabel, lpstrLabel);
		CalcLabelRect();
		return true;
	}

	bool GetHyperLink(LPTSTR lpstrBuffer, int nLength) const
	{
		if(m_lpstrHyperLink == NULL)
			return false;
		ATLASSERT(lpstrBuffer != NULL);
		if(nLength > lstrlen(m_lpstrHyperLink) + 1)
		{
			lstrcpy(lpstrBuffer, m_lpstrHyperLink);
			return true;
		}
		return false;
	}

	bool SetHyperLink(LPCTSTR lpstrLink)
	{
		free(m_lpstrHyperLink);
		m_lpstrHyperLink = NULL;
		ATLTRY(m_lpstrHyperLink = (LPTSTR)malloc((lstrlen(lpstrLink) + 1) * sizeof(TCHAR)));
		if(m_lpstrHyperLink == NULL)
			return false;
		lstrcpy(m_lpstrHyperLink, lpstrLink);
		if(m_lpstrLabel == NULL)
			CalcLabelRect();
		return true;
	}

// Operations
	BOOL SubclassWindow(HWND hWnd)
	{
		ATLASSERT(m_hWnd == NULL);
		ATLASSERT(::IsWindow(hWnd));
		BOOL bRet = CWindowImpl< T, TBase, TWinTraits >::SubclassWindow(hWnd);
		if(bRet)
			Init();
		return bRet;
	}

	bool Navigate()
	{
		ATLASSERT(::IsWindow(m_hWnd));
		ATLASSERT(m_lpstrHyperLink != NULL);
		DWORD_PTR dwRet = (DWORD_PTR)::ShellExecute(0, _T("open"), m_lpstrHyperLink, 0, 0, SW_SHOWNORMAL);
		if(dwRet > 32)
		{
			m_bVisited = true;
			Invalidate();
		}
		return (dwRet > 32);
	}

// Message map and handlers
	BEGIN_MSG_MAP(CHyperLinkImpl)
		MESSAGE_HANDLER(WM_CREATE, OnCreate)
		MESSAGE_RANGE_HANDLER(WM_MOUSEFIRST, WM_MOUSELAST, OnMouseMessage)
		MESSAGE_HANDLER(WM_ERASEBKGND, OnEraseBackground)
		MESSAGE_HANDLER(WM_PAINT, OnPaint)
		MESSAGE_HANDLER(WM_PRINTCLIENT, OnPaint)
		MESSAGE_HANDLER(WM_SETFOCUS, OnFocus)
		MESSAGE_HANDLER(WM_KILLFOCUS, OnFocus)
		MESSAGE_HANDLER(WM_MOUSEMOVE, OnMouseMove)
		MESSAGE_HANDLER(WM_LBUTTONDOWN, OnLButtonDown)
		MESSAGE_HANDLER(WM_LBUTTONUP, OnLButtonUp)
		MESSAGE_HANDLER(WM_CHAR, OnChar)
		MESSAGE_HANDLER(WM_GETDLGCODE, OnGetDlgCode)
		MESSAGE_HANDLER(WM_SETCURSOR, OnSetCursor)
	END_MSG_MAP()

	LRESULT OnCreate(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/)
	{
		Init();
		return 0;
	}

	LRESULT OnEraseBackground(UINT /*uMsg*/, WPARAM wParam, LPARAM /*lParam*/, BOOL& bHandled)
	{
		if(m_bPaintLabel)
		{
			HBRUSH hBrush = (HBRUSH)::SendMessage(GetParent(), WM_CTLCOLORSTATIC, wParam, (LPARAM)m_hWnd);
			if(hBrush != NULL)
			{
				CDCHandle dc = (HDC)wParam;
				RECT rect;
				GetClientRect(&rect);
				dc.FillRect(&rect, hBrush);
			}
		}
		else
		{
			bHandled = FALSE;
		}
		return 1;
	}

	LRESULT OnPaint(UINT /*uMsg*/, WPARAM wParam, LPARAM /*lParam*/, BOOL& bHandled)
	{
		if(!m_bPaintLabel)
		{
			bHandled = FALSE;
			return 1;
		}

		T* pT = static_cast<T*>(this);
		if(wParam != NULL)
		{
			pT->DoPaint((HDC)wParam);
		}
		else
		{
			CPaintDC dc(m_hWnd);
			pT->DoPaint(dc.m_hDC);
		}

		return 0;
	}

	LRESULT OnFocus(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
	{
		if(m_bPaintLabel)
			Invalidate();
		else
			bHandled = FALSE;
		return 0;
	}

	LRESULT OnMouseMove(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM lParam, BOOL& bHandled)
	{
		POINT pt = { GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam) };
		if(m_lpstrHyperLink != NULL && ::PtInRect(&m_rcLink, pt))
			::SetCursor(m_hCursor);
		else
			bHandled = FALSE;
		return 0;
	}

	LRESULT OnLButtonDown(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM lParam, BOOL& /*bHandled*/)
	{
		POINT pt = { GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam) };
		if(::PtInRect(&m_rcLink, pt))
		{
			SetFocus();
			SetCapture();
		}
		return 0;
	}

	LRESULT OnLButtonUp(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM lParam, BOOL& /*bHandled*/)
	{
		if(GetCapture() == m_hWnd)
		{
			ReleaseCapture();
			POINT pt = { GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam) };
			if(::PtInRect(&m_rcLink, pt))
				Navigate();
		}
		return 0;
	}

	LRESULT OnSetCursor(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
	{
		POINT pt;
		GetCursorPos(&pt);
		ScreenToClient(&pt);
		if(m_lpstrHyperLink != NULL && ::PtInRect(&m_rcLink, pt))
		{
			return TRUE;
		}
		bHandled = FALSE;
		return FALSE;
	}

	LRESULT OnChar(UINT /*uMsg*/, WPARAM wParam, LPARAM /*lParam*/, BOOL& /*bHandled*/)
	{
		if(wParam == VK_RETURN || wParam == VK_SPACE)
			Navigate();
		return 0;
	}

	LRESULT OnGetDlgCode(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/)
	{
		return DLGC_WANTCHARS;
	}

	LRESULT OnMouseMessage(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
	{
		MSG msg = { m_hWnd, uMsg, wParam, lParam };
		if(m_tip.IsWindow())
			m_tip.RelayEvent(&msg);
		bHandled = FALSE;
		return 1;
	}

// Implementation
	void Init()
	{
		ATLASSERT(::IsWindow(m_hWnd));

		// Check if we should paint a label
		TCHAR lpszBuffer[8];
		if(::GetClassName(m_hWnd, lpszBuffer, 8))
		{
			if(lstrcmpi(lpszBuffer, _T("static")) == 0)
			{
				ModifyStyle(0, SS_NOTIFY);	// we need this
				DWORD dwStyle = GetStyle() & 0x000000FF;
				if(dwStyle == SS_ICON || dwStyle == SS_BLACKRECT || dwStyle == SS_GRAYRECT || 
						dwStyle == SS_WHITERECT || dwStyle == SS_BLACKFRAME || dwStyle == SS_GRAYFRAME || 
						dwStyle == SS_WHITEFRAME || dwStyle == SS_OWNERDRAW || 
						dwStyle == SS_BITMAP || dwStyle == SS_ENHMETAFILE)
					m_bPaintLabel = false;
			}
		}

		// create or load a cursor
#if (WINVER >= 0x0500)
		m_hCursor = ::LoadCursor(NULL, IDC_HAND);
#else
		m_hCursor = ::CreateCursor(_Module.GetModuleInstance(), _AtlHyperLink_CursorData.xHotSpot, _AtlHyperLink_CursorData.yHotSpot, _AtlHyperLink_CursorData.cxWidth, _AtlHyperLink_CursorData.cyHeight, _AtlHyperLink_CursorData.arrANDPlane, _AtlHyperLink_CursorData.arrXORPlane);
#endif //!(WINVER >= 0x0500)
		ATLASSERT(m_hCursor != NULL);

		// set font
		if(m_bPaintLabel)
		{
			CWindow wnd = GetParent();
			CFontHandle font = wnd.GetFont();
			if(font.m_hFont != NULL)
			{
				LOGFONT lf;
				font.GetLogFont(&lf);
				lf.lfUnderline = TRUE;
				m_hFont = ::CreateFontIndirect(&lf);
			}
		}

		// set label (defaults to window text)
		if(m_lpstrLabel == NULL)
		{
			int nLen = GetWindowTextLength();
			if(nLen > 0)
			{
				LPTSTR lpszText = (LPTSTR)_alloca((nLen+1)*sizeof(TCHAR));
				if(GetWindowText(lpszText, nLen+1))
					SetLabel(lpszText);
			}
		}

		// set hyperlink (defaults to label)
		if(m_lpstrHyperLink == NULL && m_lpstrLabel != NULL)
			SetHyperLink(m_lpstrLabel);

		CalcLabelRect();

		// create a tool tip
		m_tip.Create(m_hWnd);
		ATLASSERT(m_tip.IsWindow());
		m_tip.Activate(TRUE);
		m_tip.AddTool(m_hWnd, m_lpstrHyperLink);

		// set link colors
		if(m_bPaintLabel)
		{
			CRegKey rk;
			LONG lRet = rk.Open(HKEY_CURRENT_USER, _T("Software\\Microsoft\\Internet Explorer\\Settings"));
			if(lRet == 0)
			{
				TCHAR szBuff[12];
				DWORD dwCount = 12 * sizeof(TCHAR);
				lRet = rk.QueryValue(szBuff, _T("Anchor Color"), &dwCount);
				if(lRet == 0)
				{
					COLORREF clr = _ParseColorString(szBuff);
					ATLASSERT(clr != CLR_INVALID);
					if(clr != CLR_INVALID)
						m_clrLink = clr;
				}

				dwCount = 12 * sizeof(TCHAR);
				lRet = rk.QueryValue(szBuff, _T("Anchor Color Visited"), &dwCount);
				if(lRet == 0)
				{
					COLORREF clr = _ParseColorString(szBuff);
					ATLASSERT(clr != CLR_INVALID);
					if(clr != CLR_INVALID)
						m_clrVisited = clr;
				}
			}
		}
	}

	static COLORREF _ParseColorString(LPTSTR lpstr)
	{
		int c[3] = { -1, -1, -1 };
		LPTSTR p;
		for(int i = 0; i < 2; i++)
		{
			for(p = lpstr; *p != _T('\0'); p = ::CharNext(p))
			{
				if(*p == _T(','))
				{
					*p = _T('\0');
					c[i] = _ttoi(lpstr);
					lpstr = &p[1];
					break;
				}
			}
			if(c[i] == -1)
				return CLR_INVALID;
		}
		if(*lpstr == _T('\0'))
			return CLR_INVALID;
		c[2] = _ttoi(lpstr);

		return RGB(c[0], c[1], c[2]);
	}

	bool CalcLabelRect()
	{
		if(!::IsWindow(m_hWnd))
			return false;
		if(m_lpstrLabel == NULL && m_lpstrHyperLink == NULL)
			return false;

		CClientDC dc(m_hWnd);
		RECT rect;
		GetClientRect(&rect);
		m_rcLink = rect;
		if(m_bPaintLabel)
		{
			HFONT hOldFont = NULL;
			if(m_hFont != NULL)
				hOldFont = dc.SelectFont(m_hFont);
			LPTSTR lpstrText = (m_lpstrLabel != NULL) ? m_lpstrLabel : m_lpstrHyperLink;
			DWORD dwStyle = GetStyle();
			int nDrawStyle = DT_LEFT;
			if (dwStyle & SS_CENTER)
				nDrawStyle = DT_CENTER;
			else if (dwStyle & SS_RIGHT)
				nDrawStyle = DT_RIGHT;
			dc.DrawText(lpstrText, -1, &m_rcLink, nDrawStyle | DT_WORDBREAK | DT_CALCRECT);
			if(m_hFont != NULL)
				dc.SelectFont(hOldFont);
		}

		return true;
	}

	void DoPaint(CDCHandle dc)
	{
		dc.SetBkMode(TRANSPARENT);
		dc.SetTextColor(m_bVisited ? m_clrVisited : m_clrLink);
		if(m_hFont != NULL)
			dc.SelectFont(m_hFont);
		LPTSTR lpstrText = (m_lpstrLabel != NULL) ? m_lpstrLabel : m_lpstrHyperLink;
		DWORD dwStyle = GetStyle();
		int nDrawStyle = DT_LEFT;
		if (dwStyle & SS_CENTER)
			nDrawStyle = DT_CENTER;
		else if (dwStyle & SS_RIGHT)
			nDrawStyle = DT_RIGHT;
		dc.DrawText(lpstrText, -1, &m_rcLink, nDrawStyle | DT_WORDBREAK);
		if(GetFocus() == m_hWnd)
			dc.DrawFocusRect(&m_rcLink);
	}
};


class CHyperLink : public CHyperLinkImpl<CHyperLink>
{
public:
	DECLARE_WND_CLASS(_T("WTL_HyperLink"))
};


/////////////////////////////////////////////////////////////////////////////
// CWaitCursor - displays a wait cursor

class CWaitCursor
{
public:
// Data
	HCURSOR m_hWaitCursor;
	HCURSOR m_hOldCursor;
	bool m_bInUse;

// Constructor/destructor
	CWaitCursor(bool bSet = true, LPCTSTR lpstrCursor = IDC_WAIT, bool bSys = true) : m_hOldCursor(NULL), m_bInUse(false)
	{
		HINSTANCE hInstance = bSys ? NULL : _Module.GetResourceInstance();
		m_hWaitCursor = ::LoadCursor(hInstance, lpstrCursor);
		ATLASSERT(m_hWaitCursor != NULL);

		if(bSet)
			Set();
	}

	~CWaitCursor()
	{
		Restore();
	}

// Methods
	bool Set()
	{
		if(m_bInUse)
			return false;
		m_hOldCursor = ::SetCursor(m_hWaitCursor);
		m_bInUse = true;
		return true;
	}

	bool Restore()
	{
		if(!m_bInUse)
			return false;
		::SetCursor(m_hOldCursor);
		m_bInUse = false;
		return true;
	}
};


/////////////////////////////////////////////////////////////////////////////
// CMultiPaneStatusBarCtrl - Status Bar with multiple panes

#define ID_DEFAULT_PANE		0       // default status bar pane

template <class T, class TBase = CStatusBarCtrl>
class ATL_NO_VTABLE CMultiPaneStatusBarCtrlImpl : public CWindowImpl< T, TBase >
{
public:
	DECLARE_WND_SUPERCLASS(NULL, TBase::GetWndClassName())

// Data
	enum { m_cxPaneMargin = 3 };

	int m_nPanes;
	int* m_pPane;

// Constructor/destructor
	CMultiPaneStatusBarCtrlImpl() : m_nPanes(0), m_pPane(NULL)
	{ }

	~CMultiPaneStatusBarCtrlImpl()
	{
		delete [] m_pPane;
	}

// Methods
	HWND Create(HWND hWndParent, LPCTSTR lpstrText, DWORD dwStyle = WS_CHILD | WS_VISIBLE | WS_CLIPCHILDREN | WS_CLIPSIBLINGS | SBARS_SIZEGRIP, UINT nID = ATL_IDW_STATUS_BAR)
	{
		return CWindowImpl< T, TBase >::Create(hWndParent, rcDefault, lpstrText, dwStyle, 0, nID);
	}

	HWND Create(HWND hWndParent, UINT nTextID = ATL_IDS_IDLEMESSAGE, DWORD dwStyle = WS_CHILD | WS_VISIBLE | WS_CLIPCHILDREN | WS_CLIPSIBLINGS | SBARS_SIZEGRIP, UINT nID = ATL_IDW_STATUS_BAR)
	{
		TCHAR szText[128];	// max text lentgth is 127 for status bars
		szText[0] = 0;
		::LoadString(_Module.GetResourceInstance(), nTextID, szText, 127);
		return Create(hWndParent, szText, dwStyle, nID);
	}

	BOOL SetPanes(int* pPanes, int nPanes, bool bSetText = true)
	{
		ATLASSERT(::IsWindow(m_hWnd));
		ATLASSERT(nPanes > 0);

		m_nPanes = nPanes;
		delete [] m_pPane;
		m_pPane = NULL;

		ATLTRY(m_pPane = new int[nPanes]);
		ATLASSERT(m_pPane != NULL);
		if(m_pPane == NULL)
			return FALSE;
		memcpy(m_pPane, pPanes, nPanes * sizeof(int));

		int* pPanesPos = NULL;
		ATLTRY(pPanesPos = (int*)_alloca(nPanes * sizeof(int)));
		ATLASSERT(pPanesPos != NULL);

		// get status bar DC and set font
		CClientDC dc(m_hWnd);
		HFONT hOldFont = dc.SelectFont(GetFont());

		// get status bar borders
		int arrBorders[3];
		GetBorders(arrBorders);

		TCHAR szBuff[256];
		SIZE size;
		int cxLeft = arrBorders[0];

		// calculate right edge of each part
		for(int i = 0; i < nPanes; i++)
		{
			if(pPanes[i] == ID_DEFAULT_PANE)
			{
				// will be resized later
				pPanesPos[i] = 100 + cxLeft + arrBorders[2];
			}
			else
			{
				::LoadString(_Module.GetResourceInstance(), pPanes[i], szBuff, sizeof(szBuff) / sizeof(TCHAR));
				dc.GetTextExtent(szBuff, lstrlen(szBuff), &size);
				T* pT = static_cast<T*>(this);
				pT;
				pPanesPos[i] = cxLeft + size.cx + arrBorders[2] + 2 * pT->m_cxPaneMargin;
			}
			cxLeft = pPanesPos[i];
		}

		BOOL bRet = SetParts(nPanes, pPanesPos);

		if(bRet && bSetText)
		{
			for(int i = 0; i < nPanes; i++)
			{
				if(pPanes[i] != ID_DEFAULT_PANE)
				{
					::LoadString(_Module.GetResourceInstance(), pPanes[i], szBuff, sizeof(szBuff) / sizeof(TCHAR));
					SetPaneText(m_pPane[i], szBuff);
				}
			}
		}

		dc.SelectFont(hOldFont);
		return bRet;
	}

	bool GetPaneTextLength(int nPaneID, int* pcchLength = NULL, int* pnType = NULL) const
	{
		ATLASSERT(::IsWindow(m_hWnd));
		int nIndex  = GetPaneIndexFromID(nPaneID);
		if(nIndex == -1)
			return false;

		int nLength = GetTextLength(nIndex, pnType);
		if(pcchLength != NULL)
			*pcchLength = nLength;

		return true;
	}

	BOOL GetPaneText(int nPaneID, LPTSTR lpstrText, int* pcchLength = NULL, int* pnType = NULL) const
	{
		ATLASSERT(::IsWindow(m_hWnd));
		int nIndex  = GetPaneIndexFromID(nPaneID);
		if(nIndex == -1)
			return FALSE;

		int nLength = GetText(nIndex, lpstrText, pnType);
		if(pcchLength != NULL)
			*pcchLength = nLength;

		return TRUE;
	}

	BOOL SetPaneText(int nPaneID, LPCTSTR lpstrText, int nType = 0)
	{
		ATLASSERT(::IsWindow(m_hWnd));
		int nIndex  = GetPaneIndexFromID(nPaneID);
		if(nIndex == -1)
			return FALSE;

		return SetText(nIndex, lpstrText, nType);
	}

	BOOL GetPaneRect(int nPaneID, LPRECT lpRect) const
	{
		ATLASSERT(::IsWindow(m_hWnd));
		int nIndex  = GetPaneIndexFromID(nPaneID);
		if(nIndex == -1)
			return FALSE;

		return GetRect(nIndex, lpRect);
	}

	BOOL SetPaneWidth(int nPaneID, int cxWidth)
	{
		ATLASSERT(::IsWindow(m_hWnd));
		ATLASSERT(nPaneID != ID_DEFAULT_PANE);	// Can't resize this one
		int nIndex  = GetPaneIndexFromID(nPaneID);
		if(nIndex == -1)
			return FALSE;

		// get pane positions
		int* pPanesPos = NULL;
		ATLTRY(pPanesPos = (int*)_alloca(m_nPanes * sizeof(int)));
		GetParts(m_nPanes, pPanesPos);
		// calculate offset
		int cxPaneWidth = pPanesPos[nIndex] - ((nIndex == 0) ? 0 : pPanesPos[nIndex - 1]);
		int cxOff = cxWidth - cxPaneWidth;
		// find variable width pane
		int nDef = m_nPanes;
		for(int i = 0; i < m_nPanes; i++)
		{
			if(m_pPane[i] == ID_DEFAULT_PANE)
			{
				nDef = i;
				break;
			}
		}
		// resize
		if(nIndex < nDef)	// before default pane
		{
			for(int i = nIndex; i < nDef; i++)
				pPanesPos[i] += cxOff;
				
		}
		else			// after default one
		{
			for(int i = nDef; i < nIndex; i++)
				pPanesPos[i] -= cxOff;
		}
		// set pane postions
		return SetParts(m_nPanes, pPanesPos);
	}

#if (_WIN32_IE >= 0x0400)
	BOOL GetPaneTipText(int nPaneID, LPTSTR lpstrText, int nSize) const
	{
		ATLASSERT(::IsWindow(m_hWnd));
		int nIndex  = GetPaneIndexFromID(nPaneID);
		if(nIndex == -1)
			return FALSE;

		GetTipText(nPaneID, lpstrText, nSize);
		return TRUE;
	}

	BOOL SetPaneTipText(int nPaneID, LPCTSTR lpstrText)
	{
		ATLASSERT(::IsWindow(m_hWnd));
		int nIndex  = GetPaneIndexFromID(nPaneID);
		if(nIndex == -1)
			return FALSE;

		SetTipText(nIndex, lpstrText);
		return TRUE;
	}

	BOOL GetPaneIcon(int nPaneID, HICON& hIcon) const
	{
		ATLASSERT(::IsWindow(m_hWnd));
		int nIndex  = GetPaneIndexFromID(nPaneID);
		if(nIndex == -1)
			return FALSE;

		hIcon = GetIcon(nIndex);
		return TRUE;
	}

	BOOL SetPaneIcon(int nPaneID, HICON hIcon)
	{
		ATLASSERT(::IsWindow(m_hWnd));
		int nIndex  = GetPaneIndexFromID(nPaneID);
		if(nIndex == -1)
			return FALSE;

		return SetIcon(nIndex, hIcon);
	}
#endif //(_WIN32_IE >= 0x0400)

// Message map and handlers
	BEGIN_MSG_MAP(CMultiPaneStatusBarCtrlImpl< T >)
		MESSAGE_HANDLER(WM_SIZE, OnSize)
	END_MSG_MAP()

	LRESULT OnSize(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& /*bHandled*/)
	{
		LRESULT lRet = DefWindowProc(uMsg, wParam, lParam);
		if(wParam != SIZE_MINIMIZED && m_nPanes > 0)
		{
			T* pT = static_cast<T*>(this);
			pT->UpdatePanesLayout();
		}
		return lRet;
	}

// Implementation
	BOOL UpdatePanesLayout()
	{
		// get pane positions
		int* pPanesPos = NULL;
		ATLTRY(pPanesPos = (int*)_alloca(m_nPanes * sizeof(int)));
		ATLASSERT(pPanesPos != NULL);
		if(pPanesPos == NULL)
			return FALSE;
		int nRet = GetParts(m_nPanes, pPanesPos);
		ATLASSERT(nRet == m_nPanes);
		if(nRet != m_nPanes)
			return FALSE;
		// calculate offset
		RECT rcClient;
		GetClientRect(&rcClient);
		int cxOff = rcClient.right - (pPanesPos[m_nPanes - 1] + ::GetSystemMetrics(SM_CXVSCROLL) + ::GetSystemMetrics(SM_CXEDGE));
		// find variable width pane
		int i;
		for(i = 0; i < m_nPanes; i++)
		{
			if(m_pPane[i] == ID_DEFAULT_PANE)
				break;
		}
		// resize all panes from the variable one to the right
		if((i < m_nPanes) && (pPanesPos[i] + cxOff) > ((i == 0) ? 0 : pPanesPos[i - 1]))
		{
			for(; i < m_nPanes; i++)
				pPanesPos[i] += cxOff;
		}
		// set pane postions
		return SetParts(m_nPanes, pPanesPos);
	}

	int GetPaneIndexFromID(int nPaneID) const
	{
		for(int i = 0; i < m_nPanes; i++)
		{
			if(m_pPane[i] == nPaneID)
				return i;
		}

		return -1;	// not found
	}
};

class CMultiPaneStatusBarCtrl : public CMultiPaneStatusBarCtrlImpl<CMultiPaneStatusBarCtrl>
{
public:
	DECLARE_WND_SUPERCLASS(_T("WTL_MultiPaneStatusBar"), GetWndClassName())
};

}; //namespace WTL

#endif // __ATLCTRLX_H__
