/*
 *      SQLMON jobs and schedules
 */

/*
    Job Category
*/
USE msdb ;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM syscategories
    WHERE name = 'SQLMON'
)
EXEC dbo.sp_add_category
    @class=N'JOB',
    @type=N'LOCAL',
    @name=N'SQLMON' ;
GO

/*
    SQLMON Log Performance Job and Schedule
*/
USE [msdb]
GO
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'SQLMON Log Performance', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'Log SQL Performance Counters', 
		@category_name=N'SQLMON', 
		@owner_login_name=N'SEOPACS\talley', @job_id = @jobId OUTPUT
select @jobId
GO
EXEC msdb.dbo.sp_add_jobserver @job_name=N'SQLMON Log Performance', @server_name = @@SERVERNAME
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'SQLMON Log Performance', @step_name=N'Run SPROC', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC sqlmon_log_performance 60;', 
		@database_name=N'SQLMON', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'SQLMON Log Performance', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'Log SQL Performance Counters', 
		@category_name=N'SQLMON',
		@owner_login_name=N'SEOPACS\talley', 
		@notify_email_operator_name=N'', 
		@notify_netsend_operator_name=N'', 
		@notify_page_operator_name=N''
GO
USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'SQLMON Log Performance', @name=N'SQLMON Every 5', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=5, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20150205, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO

/*
    SQLMON Log Files Job and Schedule
*/
USE [msdb]
GO
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'SQLMON Log Files', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'Log File Information', 
		@category_name=N'SQLMON', 
		@owner_login_name=N'SEOPACS\talley', @job_id = @jobId OUTPUT
select @jobId
GO
EXEC msdb.dbo.sp_add_jobserver @job_name=N'SQLMON Log Files', @server_name = @@SERVERNAME
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'SQLMON Log Files', @step_name=N'Run SPROC', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC sqlmon_log_files;', 
		@database_name=N'SQLMON', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'SQLMON Log Files', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'Log File Information', 
		@category_name=N'SQLMON', 
		@owner_login_name=N'SEOPACS\talley', 
		@notify_email_operator_name=N'', 
		@notify_netsend_operator_name=N'', 
		@notify_page_operator_name=N''
GO
USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'SQLMON Log Files', @name=N'SQLMON Half Hour', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20150205, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO

/*
    SQLMON Log Configuration Job and Schedule
*/
USE [msdb]
GO
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'SQLMON Log Configuration', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'Log Configuration Data Once Per Day', 
		@category_name=N'SQLMON', 
		@owner_login_name=N'SEOPACS\talley', @job_id = @jobId OUTPUT
select @jobId
GO
EXEC msdb.dbo.sp_add_jobserver @job_name=N'SQLMON Log Configuration', @server_name = @@SERVERNAME
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'SQLMON Log Configuration', @step_name=N'Run SPROC', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC sqlmon_log_configuration;', 
		@database_name=N'SQLMON', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'SQLMON Log Configuration', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'Log Configuration Data Once Per Day', 
		@category_name=N'SQLMON', 
		@owner_login_name=N'SEOPACS\talley', 
		@notify_email_operator_name=N'', 
		@notify_netsend_operator_name=N'', 
		@notify_page_operator_name=N''
GO
USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'SQLMON Log Configuration', @name=N'SQLMON Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20150205, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO

/*
    SQLMON Log DB Options
*/
USE [msdb]
GO
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'SQLMON Log DB Options', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'Log DB Options', 
		@category_name=N'SQLMON', 
		@owner_login_name=N'SEOPACS\talley', @job_id = @jobId OUTPUT
select @jobId
GO
EXEC msdb.dbo.sp_add_jobserver @job_name=N'SQLMON Log DB Options', @server_name = @@SERVERNAME
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'SQLMON Log DB Options', @step_name=N'Run SPROC', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC sqlmon_log_db_options;', 
		@database_name=N'SQLMON', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'SQLMON Log DB Options', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'Log DB Options', 
		@category_name=N'SQLMON', 
		@owner_login_name=N'SEOPACS\talley', 
		@notify_email_operator_name=N'', 
		@notify_netsend_operator_name=N'', 
		@notify_page_operator_name=N''
GO
USE [msdb]
GO
EXEC sp_attach_schedule
   @job_name = N'SQLMON Log DB Options',
   @schedule_name = N'SQLMON Daily';
GO

/*
    SQLMON Log IO Latency
*/          
USE [msdb]
GO
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'SQLMON Log IO Latency', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'Log IO Latency', 
		@category_name=N'SQLMON', 
		@owner_login_name=N'SEOPACS\talley', @job_id = @jobId OUTPUT
select @jobId
GO
EXEC msdb.dbo.sp_add_jobserver @job_name=N'SQLMON Log IO Latency', @server_name = @@SERVERNAME
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'SQLMON Log IO Latency', @step_name=N'Run SPROC', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC sqlmon_log_io_latency;', 
		@database_name=N'SQLMON', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'SQLMON Log IO Latency', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'Log IO Latency', 
		@category_name=N'SQLMON', 
		@owner_login_name=N'SEOPACS\talley', 
		@notify_email_operator_name=N'', 
		@notify_netsend_operator_name=N'', 
		@notify_page_operator_name=N''
GO
USE [msdb]
GO
EXEC sp_attach_schedule
   @job_name = N'SQLMON Log IO Latency',
   @schedule_name = N'SQLMON Every 5';
GO

/*
    SQLMON Log Performance Job and Schedule
*/
USE [msdb]
GO
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'SQLMON Log Waits', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'Log Wait Counters', 
		@category_name=N'SQLMON', 
		@owner_login_name=N'SEOPACS\talley', @job_id = @jobId OUTPUT
select @jobId
GO
EXEC msdb.dbo.sp_add_jobserver @job_name=N'SQLMON Log Waits', @server_name = @@SERVERNAME
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'SQLMON Log Waits', @step_name=N'Run SPROC', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC sqlmon_log_waits 60;', 
		@database_name=N'SQLMON', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'SQLMON Log Waits', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'Log Wait Counters', 
		@category_name=N'SQLMON', 
		@owner_login_name=N'SEOPACS\talley', 
		@notify_email_operator_name=N'', 
		@notify_netsend_operator_name=N'', 
		@notify_page_operator_name=N''
GO

EXEC sp_attach_schedule
   @job_name = N'SQLMON Log Waits',
   @schedule_name = N'SQLMON Every 5' ;
GO

/*
    SQLMON Purge Metrics
*/

USE [msdb]
GO
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'SQLMON Purge Metrics', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'Purge SQLMON Metrics', 
		@category_name=N'SQLMON', 
		@owner_login_name=N'SEOPACS\talley', @job_id = @jobId OUTPUT
select @jobId
GO
EXEC msdb.dbo.sp_add_jobserver @job_name=N'SQLMON Purge Metrics', @server_name = @@SERVERNAME
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'SQLMON Purge Metrics', @step_name=N'Run SPROC', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC sqlmon_purge;', 
		@database_name=N'SQLMON', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'SQLMON Purge Metrics', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'Purge SQLMON Metrics', 
		@category_name=N'SQLMON',
		@owner_login_name=N'SEOPACS\talley', 
		@notify_email_operator_name=N'', 
		@notify_netsend_operator_name=N'', 
		@notify_page_operator_name=N''
GO
USE [msdb]
GO
EXEC sp_attach_schedule
   @job_name = N'SQLMON Purge Metrics',
   @schedule_name = N'SQLMON Daily';
GO
