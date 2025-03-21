/*++ BUILD Version: 0002    // Increment this if a change has global effects

Copyright (c) 1991-1999  Microsoft Corporation

Module Name:

    lmerrlog.h

Abstract:

    This module defines the API function prototypes and data structures
    for the following groups of NT API functions:
        NetErrorLog

Environment:

    User Mode - Win32

Notes:

    You must include NETCONS.H before this file, since this file depends
    on values defined in NETCONS.H.

--*/

#ifndef _LMERRLOG_
#define _LMERRLOG_

#if _MSC_VER > 1000
#pragma once
#endif

#ifdef __cplusplus
extern "C" {
#endif

//
// Data Structures - Config
//

typedef struct _ERROR_LOG {
     DWORD         el_len;
     DWORD         el_reserved;
     DWORD         el_time;
     DWORD         el_error;
     LPWSTR        el_name;             // pointer to service name
     LPWSTR        el_text;             // pointer to string array
     LPBYTE        el_data;             // pointer to BYTE array
     DWORD         el_data_size;        // byte count of el_data area
     DWORD         el_nstrings;         // number of strings in el_text.
} ERROR_LOG, *PERROR_LOG, *LPERROR_LOG;


#define REVISED_ERROR_LOG_STRUCT


#ifndef _LMHLOGDEFINED_
#define _LMHLOGDEFINED_

typedef struct _HLOG {
     DWORD          time;
     DWORD          last_flags;
     DWORD          offset;
     DWORD          rec_offset;
} HLOG, *PHLOG, *LPHLOG;

#define LOGFLAGS_FORWARD    0
#define LOGFLAGS_BACKWARD   0x1
#define LOGFLAGS_SEEK       0x2

#endif

//
// Function Prototypes - ErrorLog
//

NET_API_STATUS NET_API_FUNCTION
NetErrorLogClear (
    IN LPCWSTR server,
    IN LPCWSTR backupfile,
    IN LPBYTE  reserved
    );

NET_API_STATUS NET_API_FUNCTION
NetErrorLogRead (
    IN LPCWSTR server,
    IN LPWSTR  reserved1,
    IN LPHLOG  errloghandle,
    IN DWORD   offset,
    IN LPDWORD reserved2,
    IN DWORD   reserved3,
    IN DWORD offsetflag,
    OUT LPBYTE * bufptr,
    IN DWORD prefmaxlen,
    OUT LPDWORD bytesread,
    OUT LPDWORD totalbytes
    );

NET_API_STATUS NET_API_FUNCTION
NetErrorLogWrite (
    IN LPBYTE  reserved1,
    IN DWORD   code,
    IN LPCWSTR component,
    IN LPBYTE  buffer,
    IN DWORD numbytes,
    IN LPBYTE msgbuf,
    IN DWORD strcount,
    IN LPBYTE reserved2
    );

//
// Special Values and Constants
//


//
//  Generic (could be used by more than one service)
//   error log messages from 0 to 25
//
// Do not change the comments following the manifest constants without
// understanding how mapmsg works.
//

#define ERRLOG_BASE 3100        /* NELOG errors start here */

#define NELOG_Internal_Error        (ERRLOG_BASE + 0)
    /*
    * The operation failed because a network software error occurred.
    */

#define NELOG_Resource_Shortage     (ERRLOG_BASE + 1)
    /*
    * The system ran out of a resource controlled by the %1 option.
    */

#define NELOG_Unable_To_Lock_Segment    (ERRLOG_BASE + 2)
    /*
    * The service failed to obtain a long-term lock on the
    *  segment for network control blocks (NCBs). The error code is the data.
    */

#define NELOG_Unable_To_Unlock_Segment  (ERRLOG_BASE + 3)
    /*
    * The service failed to release the long-term lock on the
    *  segment for network control blocks (NCBs). The error code is the data.
    */

#define NELOG_Uninstall_Service     (ERRLOG_BASE + 4)
    /*
    * There was an error stopping service %1.
    *  The error code from NetServiceControl is the data.
    */

#define NELOG_Init_Exec_Fail        (ERRLOG_BASE + 5)
    /*
    * Initialization failed because of a system execution failure on
    *  path %1. The system error code is the data.
    */

#define NELOG_Ncb_Error         (ERRLOG_BASE + 6)
    /*
    * An unexpected network control block (NCB) was received. The NCB is the data.
    */

#define NELOG_Net_Not_Started       (ERRLOG_BASE + 7)
    /*
    * The network is not started.
    */

#define NELOG_Ioctl_Error       (ERRLOG_BASE + 8)
    /*
    * A DosDevIoctl or DosFsCtl to NETWKSTA.SYS failed.
    * The data shown is in this format:
    *     DWORD  approx CS:IP of call to ioctl or fsctl
    *     WORD   error code
    *     WORD   ioctl or fsctl number
    */

#define NELOG_System_Semaphore      (ERRLOG_BASE + 9)
    /*
    * Unable to create or open system semaphore %1.
    *  The error code is the data.
    */

#define NELOG_Init_OpenCreate_Err   (ERRLOG_BASE + 10)
    /*
    * Initialization failed because of an open/create error on the
    *  file %1. The system error code is the data.
    */

#define NELOG_NetBios           (ERRLOG_BASE + 11)
    /*
    * An unexpected NetBIOS error occurred.
    *  The error code is the data.
    */

#define NELOG_SMB_Illegal       (ERRLOG_BASE + 12)
    /*
    * An illegal server message block (SMB) was received.
    *  The SMB is the data.
    */

#define NELOG_Service_Fail      (ERRLOG_BASE + 13)
    /*
    * Initialization failed because the requested service %1
    *  could not be started.
   */

#define NELOG_Entries_Lost      (ERRLOG_BASE + 14)
    /*
    * Some entries in the error log were lost because of a buffer
    * overflow.
    */


//
//  Server specific error log messages from 20 to 40
//

#define NELOG_Init_Seg_Overflow     (ERRLOG_BASE + 20)
    /*
    * Initialization parameters controlling resource usage other
    *  than net buffers are sized so that too much memory is needed.
    */

#define NELOG_Srv_No_Mem_Grow       (ERRLOG_BASE + 21)
    /*
    * The server cannot increase the size of a memory segment.
    */

#define NELOG_Access_File_Bad       (ERRLOG_BASE + 22)
    /*
    * Initialization failed because account file %1 is either incorrect
    * or not present.
    */

#define NELOG_Srvnet_Not_Started    (ERRLOG_BASE + 23)
    /*
    * Initialization failed because network %1 was not started.
    */

#define NELOG_Init_Chardev_Err      (ERRLOG_BASE + 24)
    /*
    * The server failed to start. Either all three chdev
    *  parameters must be zero or all three must be nonzero.
    */

#define NELOG_Remote_API        (ERRLOG_BASE + 25)
    /* A remote API request was halted due to the following
    * invalid description string: %1.
    */

#define NELOG_Ncb_TooManyErr        (ERRLOG_BASE + 26)
    /* The network %1 ran out of network control blocks (NCBs).  You may need to increase NCBs
    * for this network.  The following information includes the
    * number of NCBs submitted by the server when this error occurred:
    */

#define NELOG_Mailslot_err      (ERRLOG_BASE + 27)
    /* The server cannot create the %1 mailslot needed to send
    * the ReleaseMemory alert message.  The error received is:
    */

#define NELOG_ReleaseMem_Alert      (ERRLOG_BASE + 28)
    /* The server failed to register for the ReleaseMemory alert,
    * with recipient %1. The error code from
    * NetAlertStart is the data.
    */

#define NELOG_AT_cannot_write       (ERRLOG_BASE + 29)
    /* The server cannot update the AT schedule file. The file
    * is corrupted.
    */

#define NELOG_Cant_Make_Msg_File    (ERRLOG_BASE + 30)
    /* The server encountered an error when calling
    * NetIMakeLMFileName. The error code is the data.
    */

#define NELOG_Exec_Netservr_NoMem   (ERRLOG_BASE + 31)
    /* Initialization failed because of a system execution failure on
    * path %1. There is not enough memory to start the process.
    * The system error code is the data.
    */

#define NELOG_Server_Lock_Failure   (ERRLOG_BASE + 32)
    /* Longterm lock of the server buffers failed.
    * Check swap disk's free space and restart the system to start the server.
    */

//
//  Message service and POPUP specific error log messages from 40 to 55
//

#define NELOG_Msg_Shutdown      (ERRLOG_BASE + 40)
    /*
    * The service has stopped due to repeated consecutive
    *  occurrences of a network control block (NCB) error.  The last bad NCB follows
    *  in raw data.
    */

#define NELOG_Msg_Sem_Shutdown      (ERRLOG_BASE + 41)
    /*
    * The Message server has stopped due to a lock on the
    *  Message server shared data segment.
    */

#define NELOG_Msg_Log_Err       (ERRLOG_BASE + 50)
    /*
    * A file system error occurred while opening or writing to the
    *  system message log file %1. Message logging has been
    *  switched off due to the error. The error code is the data.
    */



#define NELOG_VIO_POPUP_ERR     (ERRLOG_BASE + 51)
    /*
    * Unable to display message POPUP due to system VIO call error.
    *  The error code is the data.
    */

#define NELOG_Msg_Unexpected_SMB_Type   (ERRLOG_BASE + 52)
    /*
    * An illegal server message block (SMB) was received.  The SMB is the data.
    */

//
//  Workstation specific error log messages from 60 to 75
//


#define NELOG_Wksta_Infoseg     (ERRLOG_BASE + 60)
    /*
    * The workstation information segment is bigger than 64K.
    *  The size follows, in DWORD format:
    */

#define NELOG_Wksta_Compname        (ERRLOG_BASE + 61)
    /*
    * The workstation was unable to get the name-number of the computer.
    */

#define NELOG_Wksta_BiosThreadFailure   (ERRLOG_BASE + 62)
    /*
    * The workstation could not initialize the Async NetBIOS Thread.
    *  The error code is the data.
    */

#define NELOG_Wksta_IniSeg      (ERRLOG_BASE + 63)
    /*
    * The workstation could not open the initial shared segment.
    *  The error code is the data.
    */

#define NELOG_Wksta_HostTab_Full    (ERRLOG_BASE + 64)
    /*
    * The workstation host table is full.
    */

#define NELOG_Wksta_Bad_Mailslot_SMB    (ERRLOG_BASE + 65)
    /*
    * A bad mailslot server message block (SMB) was received.  The SMB is the data.
    */

#define NELOG_Wksta_UASInit     (ERRLOG_BASE + 66)
    /*
    * The workstation encountered an error while trying to start the user accounts database.
    *  The error code is the data.
    */

#define NELOG_Wksta_SSIRelogon      (ERRLOG_BASE + 67)
    /*
    * The workstation encountered an error while responding to an SSI revalidation request.
    *  The function code and the error codes are the data.
    */

//
//  Alerter service specific error log messages from 70 to 79
//


#define NELOG_Build_Name        (ERRLOG_BASE + 70)
    /*
    * The Alerter service had a problem creating the list of
    * alert recipients.  The error code is %1.
    */

#define NELOG_Name_Expansion        (ERRLOG_BASE + 71)
    /*
    * There was an error expanding %1 as a group name. Try
    *  splitting the group into two or more smaller groups.
    */

#define NELOG_Message_Send      (ERRLOG_BASE + 72)
    /*
    * There was an error sending %2 the alert message -
    *  (
    *  %3 )
    *  The error code is %1.
    */

#define NELOG_Mail_Slt_Err      (ERRLOG_BASE + 73)
    /*
    * There was an error in creating or reading the alerter mailslot.
    *  The error code is %1.
    */

#define NELOG_AT_cannot_read        (ERRLOG_BASE + 74)
    /*
    * The server could not read the AT schedule file.
    */

#define NELOG_AT_sched_err      (ERRLOG_BASE + 75)
    /*
    * The server found an invalid AT schedule record.
    */

#define NELOG_AT_schedule_file_created  (ERRLOG_BASE + 76)
    /*
    * The server could not find an AT schedule file so it created one.
    */

#define NELOG_Srvnet_NB_Open        (ERRLOG_BASE + 77)
    /*
    * The server could not access the %1 network with NetBiosOpen.
    */

#define NELOG_AT_Exec_Err       (ERRLOG_BASE + 78)
    /*
    * The AT command processor could not run %1.
   */

//
//      Cache Lazy Write and HPFS386 specific error log messages from 80 to 89
//

#define NELOG_Lazy_Write_Err            (ERRLOG_BASE + 80)
        /*
        * WARNING:  Because of a lazy-write error, drive %1 now
        *  contains some corrupted data.  The cache is stopped.
        */

#define NELOG_HotFix            (ERRLOG_BASE + 81)
    /*
    * A defective sector on drive %1 has been replaced (hotfixed).
    * No data was lost.  You should run CHKDSK soon to restore full
    * performance and replenish the volume's spare sector pool.
    *
    * The hotfix occurred while processing a remote request.
    */

#define NELOG_HardErr_From_Server   (ERRLOG_BASE + 82)
    /*
    * A disk error occurred on the HPFS volume in drive %1.
    * The error occurred while processing a remote request.
    */

#define NELOG_LocalSecFail1 (ERRLOG_BASE + 83)
    /*
    * The user accounts database (NET.ACC) is corrupted.  The local security
    * system is replacing the corrupted NET.ACC with the backup
    * made at %1.
    * Any updates made to the database after this time are lost.
    *
    */

#define NELOG_LocalSecFail2 (ERRLOG_BASE + 84)
    /*
    * The user accounts database (NET.ACC) is missing.  The local
    * security system is restoring the backup database
    * made at %1.
    * Any updates made to the database made after this time are lost.
    *
    */

#define NELOG_LocalSecFail3 (ERRLOG_BASE + 85)
    /*
    * Local security could not be started because the user accounts database
    * (NET.ACC) was missing or corrupted, and no usable backup
    * database was present.
    *
    * THE SYSTEM IS NOT SECURE.
    */

#define NELOG_LocalSecGeneralFail   (ERRLOG_BASE + 86)
    /*
    * Local security could not be started because an error
    * occurred during initialization. The error code returned is %1.
    *
    * THE SYSTEM IS NOT SECURE.
    *
    */

//
//  NETWKSTA.SYS specific error log messages from 90 to 99
//

#define NELOG_NetWkSta_Internal_Error   (ERRLOG_BASE + 90)
    /*
    * A NetWksta internal error has occurred:
    *  %1
    */

#define NELOG_NetWkSta_No_Resource  (ERRLOG_BASE + 91)
    /*
    * The redirector is out of a resource: %1.
    */

#define NELOG_NetWkSta_SMB_Err      (ERRLOG_BASE + 92)
    /*
    * A server message block (SMB) error occurred on the connection to %1.
    *  The SMB header is the data.
    */

#define NELOG_NetWkSta_VC_Err       (ERRLOG_BASE + 93)
    /*
    * A virtual circuit error occurred on the session to %1.
    *  The network control block (NCB) command and return code is the data.
    */

#define NELOG_NetWkSta_Stuck_VC_Err (ERRLOG_BASE + 94)
    /*
    * Hanging up a stuck session to %1.
    */

#define NELOG_NetWkSta_NCB_Err      (ERRLOG_BASE + 95)
    /*
    * A network control block (NCB) error occurred (%1).
    *  The NCB is the data.
    */

#define NELOG_NetWkSta_Write_Behind_Err (ERRLOG_BASE + 96)
    /*
    * A write operation to %1 failed.
    *  Data may have been lost.
    */

#define NELOG_NetWkSta_Reset_Err    (ERRLOG_BASE + 97)
    /*
    * Reset of driver %1 failed to complete the network control block (NCB).
    *  The NCB is the data.
    */

#define NELOG_NetWkSta_Too_Many     (ERRLOG_BASE + 98)
    /*
    * The amount of resource %1 requested was more
    *  than the maximum. The maximum amount was allocated.
    */

//
//  Spooler specific error log messages from 100 to 103
//

#define NELOG_Srv_Thread_Failure        (ERRLOG_BASE + 104)
    /*
    * The server could not create a thread.
    *  The THREADS parameter in the CONFIG.SYS file should be increased.
    */

#define NELOG_Srv_Close_Failure         (ERRLOG_BASE + 105)
    /*
    * The server could not close %1.
    *  The file is probably corrupted.
    */

#define NELOG_ReplUserCurDir               (ERRLOG_BASE + 106)
    /*
    *The replicator cannot update directory %1. It has tree integrity
    * and is the current directory for some process.
    */

#define NELOG_ReplCannotMasterDir       (ERRLOG_BASE + 107)
    /*
    *The server cannot export directory %1 to client %2.
    * It is exported from another server.
    */

#define NELOG_ReplUpdateError           (ERRLOG_BASE + 108)
    /*
    *The replication server could not update directory %2 from the source
    * on %3 due to error %1.
    */

#define NELOG_ReplLostMaster            (ERRLOG_BASE + 109)
    /*
    *Master %1 did not send an update notice for directory %2 at the expected
    * time.
    */

#define NELOG_NetlogonAuthDCFail        (ERRLOG_BASE + 110)
    /*
    *This computer could not authenticate with %2, a Windows domain controller
    * for domain %1, and therefore this computer might deny logon requests.
    * This inability to authenticate might be caused by another computer on the
    * same network using the same name or the password for this computer account
    * is not recognized. If this message appears again, contact your system
    * administrator.
    */

#define NELOG_ReplLogonFailed           (ERRLOG_BASE + 111)
    /*
    *The replicator attempted to log on at %2 as %1 and failed.
    */

#define NELOG_ReplNetErr            (ERRLOG_BASE + 112)
    /*
    *  Network error %1 occurred.
    */

#define NELOG_ReplMaxFiles            (ERRLOG_BASE + 113)
    /*
    *  Replicator limit for files in a directory has been exceeded.
    */


#define NELOG_ReplMaxTreeDepth            (ERRLOG_BASE + 114)
    /*
    *  Replicator limit for tree depth has been exceeded.
    */

#define NELOG_ReplBadMsg             (ERRLOG_BASE + 115)
    /*
    *  Unrecognized message received in mailslot.
    */

#define NELOG_ReplSysErr            (ERRLOG_BASE + 116)
    /*
    *  System error %1 occurred.
    */

#define NELOG_ReplUserLoged          (ERRLOG_BASE + 117)
    /*
    *  Cannot log on. User is currently logged on and argument TRYUSER
    *  is set to NO.
    */

#define NELOG_ReplBadImport           (ERRLOG_BASE + 118)
    /*
    *  IMPORT path %1 cannot be found.
    */

#define NELOG_ReplBadExport           (ERRLOG_BASE + 119)
    /*
    *  EXPORT path %1 cannot be found.
    */

#define NELOG_ReplSignalFileErr           (ERRLOG_BASE + 120)
    /*
    *  Replicator failed to update signal file in directory %2 due to
    *  %1 system error.
    */

#define NELOG_DiskFT                (ERRLOG_BASE+121)
    /*
    * Disk Fault Tolerance Error
    *
    * %1
    */

#define NELOG_ReplAccessDenied           (ERRLOG_BASE + 122)
    /*
    *  Replicator could not access %2
    *  on %3 due to system error %1.
    */

#define NELOG_NetlogonFailedPrimary      (ERRLOG_BASE + 123)
    /*
    *The primary domain controller for domain %1 has apparently failed.
    */

#define NELOG_NetlogonPasswdSetFailed (ERRLOG_BASE + 124)
    /*
    * Changing machine account password for account %1 failed with
    * the following error: %n%2
    */

#define NELOG_NetlogonTrackingError      (ERRLOG_BASE + 125)
    /*
    *An error occurred while updating the logon or logoff information for %1.
    */

#define NELOG_NetlogonSyncError          (ERRLOG_BASE + 126)
    /*
    *An error occurred while synchronizing with primary domain controller %1
    */

#define NELOG_NetlogonRequireSignOrSealError (ERRLOG_BASE + 127)
    /*
    * The session setup to the Windows NT or Windows 2000 Domain Controller %1 for the domain %2
    * failed because %1 does not support signing or sealing the Netlogon
    * session.
    *
    * Either upgrade the Domain controller or set the RequireSignOrSeal
    * registry entry on this machine to 0.
    */

//
//  UPS service specific error log messages from 130 to 135
//

#define NELOG_UPS_PowerOut      (ERRLOG_BASE + 130)
    /*
    * A power failure was detected at the server.
    */

#define NELOG_UPS_Shutdown      (ERRLOG_BASE + 131)
    /*
    * The UPS service performed server shut down.
    */

#define NELOG_UPS_CmdFileError      (ERRLOG_BASE + 132)
    /*
    * The UPS service did not complete execution of the
    * user specified shut down command file.
    */

#define NELOG_UPS_CannotOpenDriver  (ERRLOG_BASE+133)
    /*
    * The UPS driver could not be opened.  The error code is
    * the data.
    */

#define NELOG_UPS_PowerBack     (ERRLOG_BASE + 134)
    /*
    * Power has been restored.
    */

#define NELOG_UPS_CmdFileConfig     (ERRLOG_BASE + 135)
    /*
    * There is a problem with a configuration of user specified
    * shut down command file.
    */

#define NELOG_UPS_CmdFileExec       (ERRLOG_BASE + 136)
    /*
    * The UPS service failed to execute a user specified shutdown
    * command file %1.  The error code is the data.
    */

//
//  Remoteboot server specific error log messages are from 150 to 157
//

#define NELOG_Missing_Parameter     (ERRLOG_BASE + 150)
    /*
    * Initialization failed because of an invalid or missing
    *  parameter in the configuration file %1.
    */

#define NELOG_Invalid_Config_Line   (ERRLOG_BASE + 151)
    /*
    * Initialization failed because of an invalid line in the
    *  configuration file %1. The invalid line is the data.
    */

#define NELOG_Invalid_Config_File   (ERRLOG_BASE + 152)
    /*
    * Initialization failed because of an error in the configuration
    *  file %1.
    */

#define NELOG_File_Changed      (ERRLOG_BASE + 153)
    /*
    * The file %1 has been changed after initialization.
    *  The boot-block loading was temporarily terminated.
    */

#define NELOG_Files_Dont_Fit        (ERRLOG_BASE + 154)
    /*
    * The files do not fit to the boot-block configuration
    * file %1. Change the BASE and ORG definitions or the order
    * of the files.
    */

#define NELOG_Wrong_DLL_Version     (ERRLOG_BASE + 155)
    /*
    * Initialization failed because the dynamic-link
    *  library %1 returned an incorrect version number.
    */

#define NELOG_Error_in_DLL      (ERRLOG_BASE + 156)
    /*
    * There was an unrecoverable error in the dynamic-
    *  link library of the service.
    */

#define NELOG_System_Error      (ERRLOG_BASE + 157)
    /*
    * The system returned an unexpected error code.
    *  The error code is the data.
    */

#define NELOG_FT_ErrLog_Too_Large (ERRLOG_BASE + 158)
    /*
    * The fault-tolerance error log file, LANROOT\LOGS\FT.LOG,
    *  is more than 64K.
    */

#define NELOG_FT_Update_In_Progress (ERRLOG_BASE + 159)
    /*
    * The fault-tolerance error-log file, LANROOT\LOGS\FT.LOG, had the
    * update in progress bit set upon opening, which means that the
    * system crashed while working on the error log.
    */

#define NELOG_Joined_Domain         (ERRLOG_BASE + 160)
    /*
    * This computer has been successfully joined to %1 '%2'.
    */


//
// Microsoft has created a generic error log entry for OEMs to use to
// log errors from OEM value added services.  The code, which is the
// 2nd arg to NetErrorLogWrite, is 3299.  This value is manifest in
// NET/H/ERRLOG.H as NELOG_OEM_Code.  The text for error log entry
// NELOG_OEM_Code is:  "%1 %2 %3 %4 %5 %6 %7 %8 %9.".
//
// Microsoft suggests that OEMs use the insertion strings as follows:
// %1:  OEM System Name (e.g. 3+Open)
// %2:  OEM Service Name (e.g. 3+Mail)
// %3:  Severity level (e.g.  error, warning, etc.)
// %4:  OEM error log entry sub-identifier  (e.g. error code #)
// %5 - % 9:  Text.
//
// The call to NetErrorWrite must set nstrings = 9, and provide 9
// ASCIIZ strings.  If the caller does not have 9 insertion strings,
// provide null strings for the empty insertion strings.
//

#define NELOG_OEM_Code              (ERRLOG_BASE + 199)
    /*
    * %1 %2 %3 %4 %5 %6 %7 %8 %9.
    */

//
// another error log range defined for NT Lanman.
//

#define ERRLOG2_BASE 5700        /* New NT NELOG errors start here */

#define NELOG_NetlogonSSIInitError              (ERRLOG2_BASE + 0)
    /*
     * The Netlogon service could not initialize the replication data
     * structures successfully. The service was terminated.  The following
     * error occurred: %n%1
     */

#define NELOG_NetlogonFailedToUpdateTrustList   (ERRLOG2_BASE + 1)
    /*
     * The Netlogon service failed to update the domain trust list.  The
     * following error occurred: %n%1
     */

#define NELOG_NetlogonFailedToAddRpcInterface   (ERRLOG2_BASE + 2)
    /*
     * The Netlogon service could not add the RPC interface.  The
     * service was terminated. The following error occurred: %n%1
     */

#define NELOG_NetlogonFailedToReadMailslot      (ERRLOG2_BASE + 3)
    /*
     * The Netlogon service could not read a mailslot message from %1 due
     * to the following error: %n%2
     */

#define NELOG_NetlogonFailedToRegisterSC        (ERRLOG2_BASE + 4)
    /*
     * The Netlogon service failed to register the service with the
     * service controller. The service was terminated. The following
     * error occurred: %n%1
     */

#define NELOG_NetlogonChangeLogCorrupt          (ERRLOG2_BASE + 5)
    /*
     * The change log cache maintained by the Netlogon service for
     * database changes is corrupted. The Netlogon service is resetting
     * the change log.
     */

#define NELOG_NetlogonFailedToCreateShare       (ERRLOG2_BASE + 6)
    /*
     * The Netlogon service could not create server share %1.  The following
     * error occurred: %n%2
     */

#define NELOG_NetlogonDownLevelLogonFailed      (ERRLOG2_BASE + 7)
    /*
     * The down-level logon request for the user %1 from %2 failed.
     */

#define NELOG_NetlogonDownLevelLogoffFailed     (ERRLOG2_BASE + 8)
    /*
     * The down-level logoff request for the user %1 from %2 failed.
     */

#define NELOG_NetlogonNTLogonFailed             (ERRLOG2_BASE + 9)
    /*
     * The Windows NT or Windows 2000 %1 logon request for the user %2\%3 from %4 (via %5)
     * failed.
     */

#define NELOG_NetlogonNTLogoffFailed            (ERRLOG2_BASE + 10)
    /*
     * The Windows NT or Windows 2000 %1 logoff request for the user %2\%3 from %4
     * failed.
     */

#define NELOG_NetlogonPartialSyncCallSuccess    (ERRLOG2_BASE + 11)
    /*
     * The partial synchronization request from the server %1 completed
     * successfully. %2 changes(s) has(have) been returned to the
     * caller.
     */

#define NELOG_NetlogonPartialSyncCallFailed     (ERRLOG2_BASE + 12)
    /*
     * The partial synchronization request from the server %1 failed with
     * the following error: %n%2
     */

#define NELOG_NetlogonFullSyncCallSuccess       (ERRLOG2_BASE + 13)
    /*
     * The full synchronization request from the server %1 completed
     * successfully. %2 object(s) has(have) been returned to
     * the caller.
     */

#define NELOG_NetlogonFullSyncCallFailed        (ERRLOG2_BASE + 14)
    /*
     * The full synchronization request from the server %1 failed with
     * the following error: %n%2
     */

#define NELOG_NetlogonPartialSyncSuccess        (ERRLOG2_BASE + 15)
    /*
     * The partial synchronization replication of the %1 database from the
     * primary domain controller %2 completed successfully. %3 change(s) is(are)
     * applied to the database.
     */


#define NELOG_NetlogonPartialSyncFailed         (ERRLOG2_BASE + 16)
    /*
     * The partial synchronization replication of the %1 database from the
     * primary domain controller %2 failed with the following error: %n%3
     */

#define NELOG_NetlogonFullSyncSuccess           (ERRLOG2_BASE + 17)
    /*
     * The full synchronization replication of the %1 database from the
     * primary domain controller %2 completed successfully.
     */


#define NELOG_NetlogonFullSyncFailed            (ERRLOG2_BASE + 18)
    /*
     * The full synchronization replication of the %1 database from the
     * primary domain controller %2 failed with the following error: %n%3
     */

#define NELOG_NetlogonAuthNoDomainController    (ERRLOG2_BASE + 19)
    /*
     * No Domain Controller is available for domain %1 due to the following: %n%2.
     * %nMake sure that the computer is connected to the network and try
     * again. If the problem persists, please contact your domain administrator.
     */

#define NELOG_NetlogonAuthNoTrustLsaSecret      (ERRLOG2_BASE + 20)
    /*
     * The session setup to the Windows NT or Windows 2000 Domain Controller %1 for the domain %2
     * failed because the computer %3 does not have a local security database account.
     */

#define NELOG_NetlogonAuthNoTrustSamAccount     (ERRLOG2_BASE + 21)
    /*
     * The session setup to the Windows NT or Windows 2000 Domain Controller %1 for the domain %2
     * failed because the Domain Controller does not have an account
     * for the computer %3.
     */

#define NELOG_NetlogonServerAuthFailed          (ERRLOG2_BASE + 22)
    /*
     * The session setup from the computer %1 failed to authenticate.
     * The name(s) of the account(s) referenced in the security database is
     * %2.  The following error occurred: %n%3
     */

#define NELOG_NetlogonServerAuthNoTrustSamAccount (ERRLOG2_BASE + 23)
    /*
     * The session setup from the computer %1 failed because there is
     * no trust account in the security database for this computer. The name of
     * the account referenced in the security database is %2.
     */

//
// General log messages for NT services.
//

#define NELOG_FailedToRegisterSC                  (ERRLOG2_BASE + 24)
    /*
     * Could not register control handler with service controller %1.
     */

#define NELOG_FailedToSetServiceStatus            (ERRLOG2_BASE + 25)
    /*
     * Could not set service status with service controller %1.
     */

#define NELOG_FailedToGetComputerName             (ERRLOG2_BASE + 26)
    /*
     * Could not find the computer name %1.
     */

#define NELOG_DriverNotLoaded                     (ERRLOG2_BASE + 27)
    /*
     * Could not load %1 device driver.
     */

#define NELOG_NoTranportLoaded                    (ERRLOG2_BASE + 28)
    /*
     * Could not load any transport.
     */

//
// More Netlogon service events
//

#define NELOG_NetlogonFailedDomainDelta           (ERRLOG2_BASE + 29)
    /*
     * Replication of the %1 Domain Object "%2" from primary domain controller
     * %3 failed with the following error: %n%4
     */

#define NELOG_NetlogonFailedGlobalGroupDelta      (ERRLOG2_BASE + 30)
    /*
     * Replication of the %1 Global Group "%2" from primary domain controller
     * %3 failed with the following error: %n%4
     */

#define NELOG_NetlogonFailedLocalGroupDelta       (ERRLOG2_BASE + 31)
    /*
     * Replication of the %1 Local Group "%2" from primary domain controller
     * %3 failed with the following error: %n%4
     */

#define NELOG_NetlogonFailedUserDelta             (ERRLOG2_BASE + 32)
    /*
     * Replication of the %1 User "%2" from primary domain controller
     * %3 failed with the following error: %n%4
     */

#define NELOG_NetlogonFailedPolicyDelta           (ERRLOG2_BASE + 33)
    /*
     * Replication of the %1 Policy Object "%2" from primary domain controller
     * %3 failed with the following error: %n%4
     */

#define NELOG_NetlogonFailedTrustedDomainDelta    (ERRLOG2_BASE + 34)
    /*
     * Replication of the %1 Trusted Domain Object "%2" from primary domain controller
     * %3 failed with the following error: %n%4
     */

#define NELOG_NetlogonFailedAccountDelta          (ERRLOG2_BASE + 35)
    /*
     * Replication of the %1 Account Object "%2" from primary domain controller
     * %3 failed with the following error: %n%4
     */

#define NELOG_NetlogonFailedSecretDelta           (ERRLOG2_BASE + 36)
    /*
     * Replication of the %1 Secret "%2" from primary domain controller
     * %3 failed with the following error: %n%4
     */

#define NELOG_NetlogonSystemError                 (ERRLOG2_BASE + 37)
    /*
    * The system returned the following unexpected error code: %n%1
    */

#define NELOG_NetlogonDuplicateMachineAccounts    (ERRLOG2_BASE + 38)
    /*
    * Netlogon has detected two machine accounts for server "%1".
    * The server can be either a Windows 2000 Server that is a member of the
    * domain or the server can be a LAN Manager server with an account in the
    * SERVERS global group.  It cannot be both.
    */

#define NELOG_NetlogonTooManyGlobalGroups         (ERRLOG2_BASE + 39)
    /*
    * This domain has more global groups than can be replicated to a LanMan
    * BDC.  Either delete some of your global groups or remove the LanMan
    * BDCs from the domain.
    */

#define NELOG_NetlogonBrowserDriver               (ERRLOG2_BASE + 40)
    /*
    * The Browser driver returned the following error to Netlogon: %n%1
    */

#define NELOG_NetlogonAddNameFailure              (ERRLOG2_BASE + 41)
    /*
    * Netlogon could not register the %1<1B> name for the following reason: %n%2
    */

//
//  More Remoteboot service events.
//
#define NELOG_RplMessages                         (ERRLOG2_BASE + 42)
    /*
    * Service failed to retrieve messages needed to boot remote boot clients.
    */

#define NELOG_RplXnsBoot                          (ERRLOG2_BASE + 43)
    /*
    * Service experienced a severe error and can no longer provide remote boot
    * for 3Com 3Start remote boot clients.
    */

#define NELOG_RplSystem                           (ERRLOG2_BASE + 44)
    /*
    * Service experienced a severe system error and will shut itself down.
    */

#define NELOG_RplWkstaTimeout                     (ERRLOG2_BASE + 45)
    /*
    * Client with computer name %1 failed to acknowledge receipt of the
    * boot data.  Remote boot of this client was not completed.
    */

#define NELOG_RplWkstaFileOpen                    (ERRLOG2_BASE + 46)
    /*
    * Client with computer name %1 was not booted due to an error in opening
    * file %2.
    */

#define NELOG_RplWkstaFileRead                    (ERRLOG2_BASE + 47)
    /*
    * Client with computer name %1 was not booted due to an error in reading
    * file %2.
    */

#define NELOG_RplWkstaMemory                      (ERRLOG2_BASE + 48)
    /*
    * Client with computer name %1 was not booted due to insufficient memory
    * at the remote boot server.
    */

#define NELOG_RplWkstaFileChecksum                (ERRLOG2_BASE + 49)
    /*
    * Client with computer name %1 will be booted without using checksums
    * because checksum for file %2 could not be calculated.
    */

#define NELOG_RplWkstaFileLineCount               (ERRLOG2_BASE + 50)
    /*
    * Client with computer name %1 was not booted due to too many lines in
    * file %2.
    */

#define NELOG_RplWkstaBbcFile                     (ERRLOG2_BASE + 51)
    /*
    * Client with computer name %1 was not booted because the boot block
    * configuration file %2 for this client does not contain boot block
    * line and/or loader line.
    */

#define NELOG_RplWkstaFileSize                    (ERRLOG2_BASE + 52)
    /*
    * Client with computer name %1 was not booted due to a bad size of
    * file %2.
    */

#define NELOG_RplWkstaInternal                    (ERRLOG2_BASE + 53)
    /*
    * Client with computer name %1 was not booted due to remote boot
    * service internal error.
    */

#define NELOG_RplWkstaWrongVersion                (ERRLOG2_BASE + 54)
    /*
    * Client with computer name %1 was not booted because file %2 has an
    * invalid boot header.
    */

#define NELOG_RplWkstaNetwork                     (ERRLOG2_BASE + 55)
    /*
    * Client with computer name %1 was not booted due to network error.
    */

#define NELOG_RplAdapterResource                  (ERRLOG2_BASE + 56)
    /*
    * Client with adapter id %1 was not booted due to lack of resources.
    */

#define NELOG_RplFileCopy                         (ERRLOG2_BASE + 57)
    /*
    * Service experienced error copying file or directory %1.
    */

#define NELOG_RplFileDelete                       (ERRLOG2_BASE + 58)
    /*
    * Service experienced error deleting file or directory %1.
    */

#define NELOG_RplFilePerms                        (ERRLOG2_BASE + 59)
    /*
    * Service experienced error setting permissions on file or directory %1.
    */
#define NELOG_RplCheckConfigs                     (ERRLOG2_BASE + 60)
    /*
    * Service experienced error evaluating RPL configurations.
    */
#define NELOG_RplCreateProfiles                   (ERRLOG2_BASE + 61)
    /*
    * Service experienced error creating RPL profiles for all configurations.
    */
#define NELOG_RplRegistry                         (ERRLOG2_BASE + 62)
    /*
    * Service experienced error accessing registry.
    */
#define NELOG_RplReplaceRPLDISK                   (ERRLOG2_BASE + 63)
    /*
    * Service experienced error replacing possibly outdated RPLDISK.SYS.
    */
#define NELOG_RplCheckSecurity                    (ERRLOG2_BASE + 64)
    /*
    * Service experienced error adding security accounts or setting
    * file permissions.  These accounts are the RPLUSER local group
    * and the user accounts for the individual RPL workstations.
    */
#define NELOG_RplBackupDatabase                   (ERRLOG2_BASE + 65)
    /*
    * Service failed to back up its database.
    */
#define NELOG_RplInitDatabase                     (ERRLOG2_BASE + 66)
    /*
    * Service failed to initialize from its database.  The database may be
    * missing or corrupted.  Service will attempt restoring the database
    * from the backup.
    */
#define NELOG_RplRestoreDatabaseFailure           (ERRLOG2_BASE + 67)
    /*
    * Service failed to restore its database from the backup.  Service
    * will not start.
    */
#define NELOG_RplRestoreDatabaseSuccess           (ERRLOG2_BASE + 68)
    /*
    * Service successfully restored its database from the backup.
    */
#define NELOG_RplInitRestoredDatabase             (ERRLOG2_BASE + 69)
    /*
    * Service failed to initialize from its restored database.  Service
    * will not start.
    */

//
// More Netlogon and RPL service events
//
#define NELOG_NetlogonSessionTypeWrong            (ERRLOG2_BASE + 70)
    /*
     * The session setup to the Windows NT or Windows 2000 Domain Controller %1 from computer
     * %2 using account %4 failed.  %2 is declared to be a BDC in domain %3.
     * However, %2 tried to connect as either a DC in a trusted domain,
     * a member workstation in domain %3, or as a server in domain %3.
     * Use the Active Directory Users and Computers tool or Server Manager to remove the BDC account for %2.
     */
#define NELOG_RplUpgradeDBTo40                    (ERRLOG2_BASE + 71)
    /*
    * The Remoteboot database was in NT 3.5 / NT 3.51 format and NT is
    * attempting to convert it to NT 4.0 format. The JETCONV converter
    * will write to the Application event log when it is finished.
    */
#define NELOG_NetlogonLanmanBdcsNotAllowed        (ERRLOG2_BASE + 72)
    /*
     * Global group SERVERS exists in domain %1 and has members.
     * This group defines Lan Manager BDCs in the domain.
     * Lan Manager BDCs are not permitted in NT domains.
     */
#define NELOG_NetlogonNoDynamicDns                (ERRLOG2_BASE + 73)
    /*
     * The DNS server (with IP address %1) for this DC does not support dynamic DNS.
     * Add the DNS records from the file '%SystemRoot%\System32\Config\netlogon.dns'
     * to the DNS server serving the domain referenced in that file. The DNS server
     * returned an error code given in the Data field.
     */
#define NELOG_NetlogonDynamicDnsRegisterFailure   (ERRLOG2_BASE + 74)
    /*
     * Registration of the DNS record '%1' failed on the DNS server (with IP address %3)
     * with the following error: %n%2
     * %nThe DNS server returned an error code given in the Data field.
     */

#define NELOG_NetlogonDynamicDnsDeregisterFailure (ERRLOG2_BASE + 75)
    /*
     * Deregistration of the DNS record '%1' failed on the DNS server (with IP address %3)
     * with the following error: %n%2
     * %nThe DNS server returned an error code given in the Data field.
     * %nAlthough this is not a critical error as it doesn't prevent normal behavior of
     * the Domain Controller, we strongly recommend to ensure the deletion of the record
     * from DNS to prevent unnecessary connections to this computer.
     */

#define NELOG_NetlogonFailedFileCreate            (ERRLOG2_BASE + 76)
    /*
     * Failed to create/open file %1 with the following error: %n%2
     */

#define NELOG_NetlogonGetSubnetToSite             (ERRLOG2_BASE + 77)
    /*
     * Netlogon got the following error while trying to get the subnet to site
     * mapping information from the DS: %n%1
     */

#define NELOG_NetlogonNoSiteForClient              (ERRLOG2_BASE + 78)
   /*
    * '%1' tried to determine its site by looking up its IP address ('%2')
    * in the Configuration\Sites\Subnets container in the DS.  No subnet matched
    * the IP address.  Consider adding a subnet object for this IP address.
    */

#define NELOG_NetlogonBadSiteName                  (ERRLOG2_BASE + 79)
    /*
     * The site name for this computer is '%1'.  That site name is not a valid
     * site name.  A site name must be a valid DNS label.
     * Rename the site to be a valid name.
     */

#define NELOG_NetlogonBadSubnetName                (ERRLOG2_BASE + 80)
    /*
     * The subnet object '%1' appears in the Configuration\Sites\Subnets
     * container in the DS.  The name is not syntactically valid.  The valid
     * syntax is xx.xx.xx.xx/yy where xx.xx.xx.xx is a valid IP subnet number
     * and yy is the number of bits in the subnet mask.
     *
     * Correct the name of the subnet object.
     */

#define NELOG_NetlogonDynamicDnsServerFailure      (ERRLOG2_BASE + 81)
    /*
     * Dynamic registration or deregistration of one or more DNS records failed because no DNS servers are available.
     */

#define NELOG_NetlogonDynamicDnsFailure            (ERRLOG2_BASE + 82)
    /*
     * Dynamic registration or deregistration of one or more DNS records failed with the following error: %n%1
     */

#define NELOG_NetlogonRpcCallCancelled             (ERRLOG2_BASE + 83)
    /*
     * The session setup to the Windows NT or Windows 2000 Domain Controller %1 for the domain %2
     * is not responsive.  The current RPC call from Netlogon on \\%3 to %1 has been cancelled.
     */

#define NELOG_NetlogonDcSiteCovered                (ERRLOG2_BASE + 84)
    /*
     * Site '%2' does not have any Domain Controllers for domain '%3'.
     * Domain Controllers in site '%1' have been automatically
     * selected to cover site '%2' for domain '%3' based on configured
     * Directory Server replication costs.
     */

#define NELOG_NetlogonDcSiteNotCovered             (ERRLOG2_BASE + 85)
    /*
     * This Domain Controller no longer automatically covers site '%1' for domain '%2'.
     */

#define NELOG_NetlogonGcSiteCovered                (ERRLOG2_BASE + 86)
    /*
     * Site '%2' does not have any Global Catalog servers for forest '%3'.
     * Global Catalog servers in site '%1' have been automatically
     * selected to cover site '%2' for forest '%3' based on configured
     * Directory Server replication costs.
     */

#define NELOG_NetlogonGcSiteNotCovered             (ERRLOG2_BASE + 87)
    /*
     * This Global Catalog server no longer automatically covers site '%1' for forest '%2'.
     */

#define NELOG_NetlogonFailedSpnUpdate              (ERRLOG2_BASE + 88)
    /*
     * Attempt to update HOST Service Principal Names (SPNs) of the computer
     * object in Active Directory failed. The updated values were '%1' and '%2'.
     * The following error occurred: %n%3
     */

#define NELOG_NetlogonFailedDnsHostNameUpdate      (ERRLOG2_BASE + 89)
    /*
     * Attempt to update DNS Host Name of the computer object
     * in Active Directory failed. The updated value was '%1'.
     * The following error occurred: %n%2
     */

#define NELOG_NetlogonAuthNoUplevelDomainController (ERRLOG2_BASE + 90)
    /*
     * No suitable Domain Controller is available for domain %1.
     * An NT4 or older domain controller is available but it cannot
     * be used for authentication purposes in the Windows 2000 or newer
     * domain that this computer is a member of.
     * The following error occurred:%n%2
     */

#define NELOG_NetlogonAuthDomainDowngraded         (ERRLOG2_BASE + 91)
    /*
     * The domain of this computer, %1 has been downgraded from Windows 2000
     * or newer to Windows NT4 or older. The computer cannot function properly
     * in this case for authentication purposes. This computer needs to rejoin
     * the domain.
     * The following error occurred:%n%2
     */

#define NELOG_NetlogonNdncSiteCovered                (ERRLOG2_BASE + 92)
    /*
     * Site '%2' does not have any LDAP servers for non-domain NC '%3'.
     * LDAP servers in site '%1' have been automatically selected to
     * cover site '%2' for non-domain NC '%3' based on configured
     * Directory Server replication costs.
     */

#define NELOG_NetlogonNdncSiteNotCovered             (ERRLOG2_BASE + 93)
    /*
     * This LDAP server no longer automatically covers site '%1' for non-domain NC '%2'.
     */

#define NELOG_NetlogonDcOldSiteCovered               (ERRLOG2_BASE + 94)
    /*
     * Site '%2' is no longer manually configured in the registry as
     * covered by this Domain Controller for domain '%3'. As a result,
     * site '%2' does not have any Domain Controllers for domain '%3'.
     * Domain Controllers in site '%1' have been automatically
     * selected to cover site '%2' for domain '%3' based on configured
     * Directory Server replication costs.
     */

#define NELOG_NetlogonDcSiteNotCoveredAuto           (ERRLOG2_BASE + 95)
    /*
     * This Domain Controller no longer automatically covers site '%1' for domain '%2'.
     * However, site '%1' is still (manually) covered by this Domain Controller for
     * domain '%2' since this site has been manually configured in the registry.
     */

#define NELOG_NetlogonGcOldSiteCovered               (ERRLOG2_BASE + 96)
    /*
     * Site '%2' is no longer manually configured in the registry as
     * covered by this Global Catalog server for forest '%3'. As a result,
     * site '%2' does not have any Global Catalog servers for forest '%3'.
     * Global Catalog servers in site '%1' have been automatically
     * selected to cover site '%2' for forest '%3' based on configured
     * Directory Server replication costs.
     */

#define NELOG_NetlogonGcSiteNotCoveredAuto           (ERRLOG2_BASE + 97)
    /*
     * This Global Catalog server no longer automatically covers site '%1' for forest '%2'.
     * However, site '%1' is still (manually) covered by this Global catalog for
     * forest '%2' since this site has been manually configured in the registry.
     */

#define NELOG_NetlogonNdncOldSiteCovered             (ERRLOG2_BASE + 98)
    /*
     * Site '%2' is no longer manually configured in the registry as
     * covered by this LDAP server for non-domain NC '%3'. As a result,
     * site '%2' does not have any LDAP servers for non-domain NC '%3'.
     * LDAP servers in site '%1' have been automatically
     * selected to cover site '%2' for non-domain NC '%3' based on
     * configured Directory Server replication costs.
     */

#define NELOG_NetlogonNdncSiteNotCoveredAuto         (ERRLOG2_BASE + 99)
    /*
     * This LDAP server no longer automatically covers site '%1' for non-domain NC '%2'.
     * However, site '%1' is still (manually) covered by this LDAP server for
     * non-domain NC '%2' since this site has been manually configured in the registry.
     */

#define NELOG_NetlogonSpnMultipleSamAccountNames     (ERRLOG2_BASE + 100)
    /*
     * Attempt to update DnsHostName and HOST Service Principal Name (SPN) attributes
     * of the computer object in Active Directory failed because the Domain Controller
     * '%1' had more than one account with the name '%2' corresponding to this computer.
     * Not having SPNs registered may result in authentication failures for this computer.
     * Contact your domain administrator who may need to manually resolve the account name
     * collision.
     */

#define NELOG_NetlogonSpnCrackNamesFailure           (ERRLOG2_BASE + 101)
    /*
     * Attempt to update DnsHostName and HOST Service Principal Name (SPN) attributes
     * of the computer object in Active Directory failed because this computer account
     * name, '%2' could not be mapped to the computer object on Domain Controller '%1'.
     * Not having SPNs registered may result in authentication failures for this computer.
     * Contact your domain administrator. The following technical information may be
     * useful for the resolution of this failure:%n
     * DsCrackNames status = 0x%3, crack error = 0x%4.
     */

#define NELOG_NetlogonNoAddressToSiteMapping         (ERRLOG2_BASE + 102)
    /*
     * None of the IP addresses (%2) of this Domain Controller map to the configured site '%1'.
     * While this may be a temporary situation due to IP address changes, it is generally
     * recommended that the IP address of the Domain Controller (accessible to machines in
     * its domain) maps to the Site which it services. If the above list of IP addresses is
     * stable, consider moving this server to a site (or create one if it does not already
     * exist) such that the above IP address maps to the selected site. This may require the
     * creation of a new subnet object (whose range includes the above IP address) which maps
     * to the selected site object.
     */

#define NELOG_NetlogonInvalidGenericParameterValue   (ERRLOG2_BASE + 103)
    /*
     * The following error occurred while reading a parameter '%2' in the
     * Netlogon %1 registry section:%n%3
     */

#define NELOG_NetlogonInvalidDwordParameterValue     (ERRLOG2_BASE + 104)
    /*
     * The Netlogon %1 registry key contains an invalid value 0x%2 for parameter '%3'.
     * The minimum and maximum values allowed for this parameter are 0x%4 and 0x%5, respectively.
     * The value of 0x%6 has been assigned to this parameter.
     */

#define NELOG_NetlogonServerAuthFailedNoAccount      (ERRLOG2_BASE + 105)
    /*
     * The session setup from the computer %1 failed to authenticate.
     * The following error occurred: %n%2
     */

#define NELOG_NetlogonNoSiteForClients               (ERRLOG2_BASE + 107)
    /*
     * During the past %1 hours there have been %2 connections to this Domain
     * Controller from client machines whose IP addresses don't map to any of
     * the existing sites in the enterprise. Those clients, therefore, have
     * undefined sites and may connect to any Domain Controller including
     * those that are in far distant locations from the clients. A client's site
     * is determined by the mapping of its subnet to one of the existing sites.
     * To move the above clients to one of the sites, please consider creating
     * subnet object(s) covering the above IP addresses with mapping to one of the
     * existing sites.  The names and IP addresses of the clients in question have
     * been logged on this computer in the following log file
     * '%SystemRoot%\debug\netlogon.log' and, potentially, in the log file
     * '%SystemRoot%\debug\netlogon.bak' created if the former log becomes full.
     * The log(s) may contain additional unrelated debugging information. To filter
     * out the needed information, please search for lines which contain text
     * 'NO_CLIENT_SITE:'. The first word after this string is the client name and
     * the second word is the client IP address. The maximum size of the log(s) is
     * controlled by the following registry DWORD value
     * 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters\LogFileMaxSize';
     * the default is %3 bytes.  The current maximum size is %4 bytes.  To set a
     * different maximum size, create the above registry value and set the desired
     * maximum size in bytes.
     */

#ifdef __cplusplus
}
#endif

#endif // _LMERRLOG_
