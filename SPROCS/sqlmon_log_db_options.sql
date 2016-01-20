/*
    Script      sqlmon_log_db_options.sql
    Description
        Logs SQL DB Configurations.
*/
USE SQLMON;

IF OBJECTPROPERTY(OBJECT_ID(N'sqlmon_log_db_options'), 'IsProcedure') = 1 
    DROP PROCEDURE sqlmon_log_db_options;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE sqlmon_log_db_options
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @options TABLE
    (
        [db_name]                               VARCHAR(64),
	    [db_id]                                 VARCHAR(64),
	    [owner]                                 VARCHAR(64),
	    [compatibility_level]                   VARCHAR(64),
	    [collation_name]                        VARCHAR(64),
	    [user_access_desc]                      VARCHAR(64),
	    [is_read_only]                          VARCHAR(64),
	    [is_auto_shrink_on]                     VARCHAR(64),
	    [state_desc]                            VARCHAR(64),
	    [is_in_standby]                         VARCHAR(64),
	    [is_cleanly_shutdown]                   VARCHAR(64), 
	    [is_supplemental_logging_enabled]       VARCHAR(64), 
	    [snapshot_isolation_state_desc]         VARCHAR(64), 
	    [is_read_committed_snapshot_on]         VARCHAR(64), 
	    [recovery_model_desc]                   VARCHAR(64), 
	    [page_verify_option_desc]               VARCHAR(64), 
	    [is_auto_create_stats_on]               VARCHAR(64), 
	    [is_auto_update_stats_on]               VARCHAR(64), 
	    [is_auto_update_stats_async_on]         VARCHAR(64), 
	    [is_recursive_triggers_on]              VARCHAR(64), 
	    [is_cursor_close_on_commit_on]          VARCHAR(64), 
	    [is_local_cursor_default]               VARCHAR(64), 
	    [is_parameterization_forced]            VARCHAR(64), 
	    [log_reuse_wait_desc]                   VARCHAR(64), 
	    [is_encrypted]                          VARCHAR(64)
    )

    INSERT INTO @options
    SELECT
	    [name]                      [db_name],
	    [database_id]               [db_id], 
	    suser_sname([owner_sid])    [owner],
	    [compatibility_level], 
	    [collation_name],
	    [user_access_desc],
	    CASE [is_read_only]
            WHEN 0 THEN 'NO'
            WHEN 1 THEN 'YES'
            ELSE        'ERR'
        END [is_read_only],
	    CASE [is_auto_shrink_on]
            WHEN 0 THEN 'NO'
            WHEN 1 THEN 'YES'
            ELSE        'ERR'
        END [is_auto_shrink_on],
	    [state_desc],
	    CASE [is_in_standby]
            WHEN 0 THEN 'NO'
            WHEN 1 THEN 'YES'
            ELSE        'ERR'
        END [is_in_standby],
	    CASE [is_cleanly_shutdown]
            WHEN 0 THEN 'NO'
            WHEN 1 THEN 'YES'
            ELSE        'ERR'
        END [is_cleanly_shutdown],
	    CASE [is_supplemental_logging_enabled]
            WHEN 0 THEN 'NO'
            WHEN 1 THEN 'YES'
            ELSE        'ERR'
        END [is_supplemental_logging_enabled],
	    [snapshot_isolation_state_desc],
	    CASE [is_read_committed_snapshot_on]
            WHEN 0 THEN 'NO'
            WHEN 1 THEN 'YES'
            ELSE        'ERR'
        END [is_read_committed_snapshot_on],
	    [recovery_model_desc], 
	    [page_verify_option_desc], 
	    CASE [is_auto_create_stats_on]
            WHEN 0 THEN 'NO'
            WHEN 1 THEN 'YES'
            ELSE        'ERR'
        END [is_auto_create_stats_on],
	    CASE [is_auto_update_stats_on]
            WHEN 0 THEN 'NO'
            WHEN 1 THEN 'YES'
            ELSE        'ERR'
        END [is_auto_update_stats_on],
	    CASE [is_auto_update_stats_async_on]
            WHEN 0 THEN 'NO'
            WHEN 1 THEN 'YES'
            ELSE        'ERR'
        END [is_auto_update_stats_async_on],
	    CASE [is_recursive_triggers_on]
            WHEN 0 THEN 'NO'
            WHEN 1 THEN 'YES'
            ELSE        'ERR'
        END [is_recursive_triggers_on],
	    CASE [is_cursor_close_on_commit_on]
            WHEN 0 THEN 'NO'
            WHEN 1 THEN 'YES'
            ELSE        'ERR'
        END [is_cursor_close_on_commit_on],
	    CASE [is_local_cursor_default]
            WHEN 0 THEN 'NO'
            WHEN 1 THEN 'YES'
            ELSE        'ERR'
        END [is_local_cursor_default],
	    CASE [is_parameterization_forced]
            WHEN 0 THEN 'NO'
            WHEN 1 THEN 'YES'
            ELSE        'ERR'
        END [is_parameterization_forced],
	    [log_reuse_wait_desc], 
	    CASE [is_encrypted]
            WHEN 0 THEN 'NO'
            WHEN 1 THEN 'YES'
            ELSE        'ERR'
        END [is_encrypted]
    FROM sys.databases

    INSERT INTO sqlmon_db_options
        (
            [db_name],
            [db_id],
            [opt],
            [value]
         )

        SELECT  [db_name],
                [db_id],
                [opt],
                [value]
        FROM @options
        UNPIVOT(
        value FOR opt IN (
	                        [owner],
	                        [compatibility_level], 
	                        [collation_name],
	                        [user_access_desc],
	                        [is_read_only],
	                        [is_auto_shrink_on], 
	                        [state_desc],
	                        [is_in_standby], 
	                        [is_cleanly_shutdown], 
	                        [is_supplemental_logging_enabled], 
	                        [snapshot_isolation_state_desc], 
	                        [is_read_committed_snapshot_on], 
	                        [recovery_model_desc], 
	                        [page_verify_option_desc], 
	                        [is_auto_create_stats_on], 
	                        [is_auto_update_stats_on], 
	                        [is_auto_update_stats_async_on], 
	                        [is_recursive_triggers_on], 
	                        [is_cursor_close_on_commit_on], 
	                        [is_local_cursor_default], 
	                        [is_parameterization_forced], 
	                        [log_reuse_wait_desc], 
	                        [is_encrypted]
                        )
        ) as unp
END
GO