/*

    Script      sqlmon_log_waits.sql
    Description
        Log server wait statistic deltas.

*/
USE SQLMON;

IF OBJECTPROPERTY(OBJECT_ID(N'sqlmon_log_waits'), 'IsProcedure') = 1 
    DROP PROCEDURE sqlmon_log_waits;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE sqlmon_log_waits
    @INTERVAL AS INT = 30
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @waitCounters TABLE
        (
            [wait_type]             VARCHAR(64),
            [waiting_tasks_count]   BIGINT,
            [wait_time_ms]          BIGINT,
            [max_wait_time_ms]      BIGINT,
            [signal_wait_time_ms]   BIGINT
        );

    INSERT INTO @waitCounters
        (
            [wait_type],
            [waiting_tasks_count],
            [wait_time_ms],
            [max_wait_time_ms],
            [signal_wait_time_ms]
        )
        SELECT  [wait_type],
                [waiting_tasks_count],
                [wait_time_ms],
                [max_wait_time_ms],
                [signal_wait_time_ms]
        FROM    sys.dm_os_wait_stats

            DECLARE @FORMATTED_INTERVAL AS CHAR(8);
            SET @FORMATTED_INTERVAL = (
                SELECT RIGHT('0' + CAST(@INTERVAL / 3600 AS VARCHAR),2) + ':' +
                    RIGHT('0' + CAST((@INTERVAL / 60) % 60 AS VARCHAR),2)  + ':' +
                        RIGHT('0' + CAST(@INTERVAL % 60 AS VARCHAR),2)
                )
            WAITFOR DELAY @FORMATTED_INTERVAL

    INSERT INTO sqlmon_waits
    (
        [wait_type],
        [wait_count],
        [total_wait_count],
        [max_wait_time_ms],
        [signal_wait_time_ms],
        [Interval],
        [timestamp]
    )
    SELECT  [W1].[wait_type]                            [wait_type],
            [W1].[waiting_tasks_count] -
                ISNULL([W2].[waiting_tasks_count], 0)   [wait_count],
            [W1].[waiting_tasks_count]                  [total_wait_count],
            [W1].[wait_time_ms]                         [max_wait_time_ms],
            [W1].[signal_wait_time_ms]                  [signal_wait_time_ms],
            @INTERVAL                                   [Interval],
            GETDATE()                                   [timestamp]
    FROM     @waitCounters W2
        LEFT JOIN sys.dm_os_wait_stats W1
            ON W1.wait_type = W2.wait_type
    WHERE [W2].[wait_type] IN (
                                'LCK_M_SCH_S',
                                'LCK_M_SCH_M',
                                'LCK_M_S',
                                'LCK_M_U',
                                'LCK_M_X',
                                'LCK_M_IS',
                                'LCK_M_IU',
                                'LCK_M_IX',
                                'LCK_M_SIU',
                                'LCK_M_SIX',
                                'LCK_M_UIX',
                                'LCK_M_BU',
                                'LCK_M_RS_S',
                                'LCK_M_RS_U',
                                'LCK_M_RIn_NL',
                                'LCK_M_RIn_S',
                                'LCK_M_RIn_U',
                                'LCK_M_RIn_X',
                                'LCK_M_RX_S',
                                'LCK_M_RX_U',
                                'LCK_M_RX_X',
                                'LATCH_SH',
                                'LATCH_UP',
                                'LATCH_EX',
                                'PAGELATCH_KP',
                                'PAGELATCH_SH',
                                'PAGELATCH_UP',
                                'PAGELATCH_EX',
                                'PAGEIOLATCH_SH',
                                'PAGEIOLATCH_UP',
                                'PAGEIOLATCH_EX',
                                'IO_COMPLETION',
                                'ASYNC_IO_COMPLETION',
                                'ASYNC_NETWORK_IO',
                                'CHKPT',
                                'OLEDB',
                                'ASYNC_DISKPOOL_LOCK',
                                'THREADPOOL',
                                'BROKER_RECEIVE_WAITFOR',
                                'SOS_SCHEDULER_YIELD',
                                'SOS_RESERVEDMEMBLOCKLIST',
                                'SOS_LOCALALLOCATORLIST',
                                'ONDEMAND_TASK_QUEUE',
                                'BACKUP',
                                'BACKUPBUFFER',
                                'BACKUPIO',
                                'BACKUPTHREAD',
                                'KSOURCE_WAKEUP',
                                'SQLTRACE_FILE_BUFFER',
                                'BROKER_TRANSMITTER',
                                'BROKER_MASTERSTART',
                                'FCB_REPLICA_WRITE',
                                'WRITELOG',
                                'CMEMTHREAD',
                                'CXPACKET',
                                'EXECSYNC',
                                'MSQL_XP',
                                'LOGBUFFER',
                                'RESOURCE_SEMAPHORE_MUTEX',
                                'SNI_CRITICAL_SECTION',
                                'SOS_SYNC_TASK_ENQUEUE_EVENT',
                                'SNI_TASK_COMPLETION',
                                'DAC_INIT',
                                'NODE_CACHE_MUTEX',
                                'CXROWSET_SYNC',
                                'PREEMPTIVE_OS_GENERICOPS',
                                'PREEMPTIVE_OS_AUTHENTICATIONOPS',
                                'PREEMPTIVE_OS_DECRYPTMESSAGE',
                                'PREEMPTIVE_OS_DELETESECURITYCONTEXT',
                                'PREEMPTIVE_OS_ENCRYPTMESSAGE',
                                'PREEMPTIVE_OS_AUTHORIZATIONOPS',
                                'PREEMPTIVE_OS_AUTHZGETINFORMATIONFROMCONTEXT',
                                'PREEMPTIVE_OS_AUTHZINITIALIZECONTEXTFROMSID',
                                'PREEMPTIVE_OS_AUTHZINITIALIZERESOURCEMANAGER',
                                'PREEMPTIVE_OS_LOOKUPACCOUNTSID',
                                'PREEMPTIVE_OS_REVERTTOSELF',
                                'PREEMPTIVE_OS_COMOPS',
                                'PREEMPTIVE_OS_CRYPTOPS',
                                'PREEMPTIVE_OS_CRYPTACQUIRECONTEXT',
                                'PREEMPTIVE_OS_CRYPTIMPORTKEY',
                                'PREEMPTIVE_OS_NETVALIDATEPASSWORDPOLICY',
                                'PREEMPTIVE_OS_NETVALIDATEPASSWORDPOLICYFREE',
                                'PREEMPTIVE_OS_DOMAINSERVICESOPS',
                                'PREEMPTIVE_OS_FILEOPS',
                                'PREEMPTIVE_OS_CLOSEHANDLE',
                                'PREEMPTIVE_OS_CREATEFILE',
                                'PREEMPTIVE_OS_DELETEFILE',
                                'PREEMPTIVE_OS_DEVICEIOCONTROL',
                                'PREEMPTIVE_FILESIZEGET',
                                'PREEMPTIVE_OS_FLUSHFILEBUFFERS',
                                'PREEMPTIVE_OS_GETDISKFREESPACE',
                                'PREEMPTIVE_OS_GETFILEATTRIBUTES',
                                'PREEMPTIVE_OS_GETVOLUMEPATHNAME',
                                'PREEMPTIVE_OS_GETVOLUMENAMEFORVOLUMEMOUNTPOINT',
                                'PREEMPTIVE_OS_SETFILEVALIDDATA',
                                'PREEMPTIVE_OS_WRITEFILE',
                                'PREEMPTIVE_OS_WRITEFILEGATHER',
                                'PREEMPTIVE_OS_LIBRARYOPS',
                                'PREEMPTIVE_OS_GETPROCADDRESS',
                                'PREEMPTIVE_OS_LOADLIBRARY',
                                'PREEMPTIVE_OLEDBOPS',
                                'PREEMPTIVE_OS_PIPEOPS',
                                'PREEMPTIVE_OS_DISCONNECTNAMEDPIPE',
                                'PREEMPTIVE_OS_REPORTEVENT',
                                'PREEMPTIVE_OS_WAITFORSINGLEOBJECT',
                                'PREEMPTIVE_OS_QUERYREGISTRY',
                                'PREEMPTIVE_OS_SQMLAUNCH',
                                'PREEMPTIVE_XE_CALLBACKEXECUTE',
                                'PREEMPTIVE_XE_DISPATCHER',
                                'PREEMPTIVE_XE_SESSIONCOMMIT',
                                'PREEMPTIVE_XE_TARGETINIT',
                                'PREEMPTIVE_XE_TIMERRUN',
                                'PREEMPTIVE_LOCKMONITOR',
                                'WRITE_COMPLETION',
                                'FT_IFTS_RWLOCK',
                                'FT_COMPROWSET_RWLOCK',
                                'FT_MASTER_MERGE',
                                'PERFORMANCE_COUNTERS_RWLOCK',
                                'SQLTRACE_FILE_WRITE_IO_COMPLETION',
                                'SQLTRACE_FILE_READ_IO_COMPLETION'
                              )
    ORDER BY wait_count desc;

END
GO