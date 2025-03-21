/* this file contains the actual definitions of */
/* the IIDs and CLSIDs */

/* link this file in with the server and any clients */


/* File created by MIDL compiler version 3.01.75 */
/* at Mon Dec 01 17:04:01 1997
 */
/* Compiler settings for D:\test\mot\dmiengin\src\DmiActx.odl:
    Os (OptLev=s), W1, Zp8, env=Win32, ms_ext, c_ext
    error checks: none
*/
//@@MIDL_FILE_HEADING(  )
#ifdef __cplusplus
extern "C"{
#endif 


#ifndef __IID_DEFINED__
#define __IID_DEFINED__

typedef struct _IID
{
    unsigned long x;
    unsigned short s1;
    unsigned short s2;
    unsigned char  c[8];
} IID;

#endif // __IID_DEFINED__

#ifndef CLSID_DEFINED
#define CLSID_DEFINED
typedef IID CLSID;
#endif // CLSID_DEFINED

const IID LIBID_MOTDMIEngine = {0xF45FB440,0xC9DA,0x11CF,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID DIID_IEventFilter = {0x6313BC6E,0xAEBF,0x11D0,{0xB8,0x65,0x00,0xA0,0xC9,0x24,0x79,0xE2}};


const IID IID_IDualEventFilter = {0x48EC0E24,0xAEC2,0x11d0,{0xB8,0x65,0x00,0xA0,0xC9,0x24,0x79,0xE2}};


const CLSID CLSID_DMIEventFilter = {0x6313BC6F,0xAEBF,0x11D0,{0xB8,0x65,0x00,0xA0,0xC9,0x24,0x79,0xE2}};


const IID DIID_IColLanguages = {0xA24E5B80,0x7AC3,0x11D0,{0x88,0x45,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID IID_IDualColLanguages = {0x13AE3E40,0x7B54,0x11d0,{0x88,0x45,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const CLSID CLSID_DMILanguages = {0xA24E5B81,0x7AC3,0x11D0,{0x88,0x45,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID DIID_IEnumeration = {0xF1DC8AE2,0x36FE,0x11D0,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID IID_IDualEnumeration = {0x9EACD1E0,0x3703,0x11d0,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const CLSID CLSID_DMIEnumeration = {0xF1DC8AE3,0x36FE,0x11D0,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID DIID_IColEnumerations = {0xF1DC8AE4,0x36FE,0x11D0,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID IID_IDualColEnumerations = {0x2C7E6960,0x3714,0x11d0,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const CLSID CLSID_DMIEnumerations = {0xF1DC8AE5,0x36FE,0x11D0,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID DIID_IAttribute = {0xF45FB448,0xC9DA,0x11CF,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID IID_IDualAttribute = {0x61DB0E60,0xCAAE,0x11cf,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const CLSID CLSID_DMIAttribute = {0xF45FB449,0xC9DA,0x11CF,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID DIID_IColAttributes = {0x1A10B900,0xCDD7,0x11CF,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID IID_IDualColAttributes = {0xE2239A00,0xCE60,0x11cf,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const CLSID CLSID_DMIAttributes = {0x1A10B901,0xCDD7,0x11CF,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID DIID_IRow = {0x3AB30761,0xE3B9,0x11CF,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID IID_IDualRow = {0x87DFD221,0xE3D7,0x11cf,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const CLSID CLSID_DMIRow = {0x3AB30762,0xE3B9,0x11CF,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID DIID_IColRows = {0x7BF7A480,0xE3D5,0x11CF,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID IID_IDualColRows = {0x87DFD220,0xE3D7,0x11cf,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const CLSID CLSID_DMIRows = {0x7BF7A481,0xE3D5,0x11CF,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID DIID_IGroup = {0xDA6FAB60,0xDF21,0x11CF,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID IID_IDualGroup = {0xB9C1FDE0,0xE152,0x11cf,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const CLSID CLSID_DMIGroup = {0xDA6FAB61,0xDF21,0x11CF,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID DIID_IColGroups = {0xDA6FAB62,0xDF21,0x11CF,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID IID_IDualColGroups = {0xB9C1FDE1,0xE152,0x11cf,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const CLSID CLSID_DMIGroups = {0xDA6FAB63,0xDF21,0x11CF,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID DIID_IComponent = {0x445360E0,0xDF26,0x11CF,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID IID_IDualComponent = {0xB9C1FDE2,0xE152,0x11cf,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const CLSID CLSID_DMIComponent = {0x445360E1,0xDF26,0x11CF,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID DIID_IColComponents = {0x445360E2,0xDF26,0x11CF,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID IID_IDualColComponents = {0xB9C1FDE3,0xE152,0x11cf,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const CLSID CLSID_DMIComponents = {0x445360E3,0xDF26,0x11CF,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID DIID_IMgmtNode = {0x165125A0,0xDFC2,0x11CF,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID IID_IDualMgmtNode = {0xDDAE04C0,0xE3C7,0x11cf,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const CLSID CLSID_DMIMgmtNode = {0x165125A1,0xDFC2,0x11CF,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID DIID_IColMgmtNodes = {0xF1DC8AE0,0x36FE,0x11D0,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID IID_IDualColMgmtNodes = {0x2C7E6961,0x3714,0x11d0,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const CLSID CLSID_DMIMgmtNodes = {0xF1DC8AE1,0x36FE,0x11D0,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID DIID_INotification = {0x5847E2F7,0xA2E4,0x11D0,{0xB8,0x4F,0x00,0xA0,0xC9,0x24,0x79,0xE2}};


const CLSID CLSID_DMINotification = {0x5847E2F8,0xA2E4,0x11D0,{0xB8,0x4F,0x00,0xA0,0xC9,0x24,0x79,0xE2}};


const IID DIID_IEvent = {0x20A41620,0x33EB,0x11D0,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const CLSID CLSID_DMIEvent = {0x20A41621,0x33EB,0x11D0,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID DIID__DDualint = {0xF45FB441,0xC9DA,0x11CF,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID IID__DualDMIEngine = {0x45D155A0,0x3CAD,0x11d0,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const IID DIID__DDualintEvents = {0xF45FB442,0xC9DA,0x11CF,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


const CLSID CLSID_MOTDmiEngine = {0xF45FB443,0xC9DA,0x11CF,{0x88,0x44,0x00,0xAA,0x00,0x6B,0x21,0xBF}};


#ifdef __cplusplus
}
#endif

