/*

    Script      sqlmon_log_io_latency.sql
    Description
        Log server IO latencies.

*/
USE SQLMON;

IF OBJECTPROPERTY(OBJECT_ID(N'sqlmon_log_io_latency'), 'IsProcedure') = 1 
    DROP PROCEDURE sqlmon_log_io_latency;
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE sqlmon_log_io_latency
    @INTERVAL AS INT = 30
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @io_stats_1 TABLE
    (
        [database_id]               NVARCHAR(128),
        [name]                      NVARCHAR(128),
        [file_id]                   INT,
        [num_of_reads]              BIGINT,
        [num_of_bytes_read]         BIGINT,
        [io_stall_read_ms]          BIGINT,
        [num_of_writes]             BIGINT,
        [num_of_bytes_written]      BIGINT,
        [io_stall_write_ms]         BIGINT,
        [io_stall]                  BIGINT
    )

    DECLARE @io_stats_2 TABLE
    (
        [database_id]               NVARCHAR(128),
        [name]                      NVARCHAR(128),
        [file_id]                   INT,
        [num_of_reads]              BIGINT,
        [num_of_bytes_read]         BIGINT,
        [io_stall_read_ms]          BIGINT,
        [num_of_writes]             BIGINT,
        [num_of_bytes_written]      BIGINT,
        [io_stall_write_ms]         BIGINT,
        [io_stall]                  BIGINT
    )

    INSERT INTO @io_stats_1
    SELECT  [mf].[database_id],
            [mf].[name],
            [mf].[file_id],
            [vfs].[num_of_reads],
            [vfs].[num_of_bytes_read],
            [vfs].[io_stall_read_ms],
            [vfs].[num_of_writes],
            [vfs].[num_of_bytes_written],
            [vfs].[io_stall_write_ms],
            [vfs].[io_stall]
    FROM sys.dm_io_virtual_file_stats(null, null) [vfs]
    JOIN sys.master_files AS [mf]
                ON [vfs].[database_id] = [mf].[database_id]
                    AND [vfs].[file_id] = [mf].[file_id];

    DECLARE @FORMATTED_INTERVAL AS CHAR(8);
                SET @FORMATTED_INTERVAL = (
                    SELECT RIGHT('0' + CAST(@INTERVAL / 3600 AS VARCHAR),2) + ':' +
                        RIGHT('0' + CAST((@INTERVAL / 60) % 60 AS VARCHAR),2)  + ':' +
                            RIGHT('0' + CAST(@INTERVAL % 60 AS VARCHAR),2)
                    )
                WAITFOR DELAY @FORMATTED_INTERVAL;


    INSERT INTO @io_stats_2
    SELECT  [mf].[database_id],
            [mf].[name],
            [mf].[file_id],
            [vfs].[num_of_reads],
            [vfs].[num_of_bytes_read],
            [vfs].[io_stall_read_ms],
            [vfs].[num_of_writes],
            [vfs].[num_of_bytes_written],
            [vfs].[io_stall_write_ms],
            [vfs].[io_stall]
    FROM sys.dm_io_virtual_file_stats(null, null) [vfs]
    JOIN sys.master_files AS [mf]
                ON [vfs].[database_id] = [mf].[database_id]
                    AND [vfs].[file_id] = [mf].[file_id];

    INSERT INTO [sqlmon_io_latency]
    (
        [row_id],
        [db_id],
        [db_name],
        [file_id],
        [file_name],
        [sample_bytes_read],
        [sample_num_of_reads],
        [sample_avg_read_latency],
        [sample_num_of_writes],
        [sample_avg_write_latency],
        [sample_bytes_written],
        [sample_io_stall],
        [total_avg_read_latency],
        [total_avg_write_latency],
        [timestamp],
        [interval]
    )
    SELECT
        NEWID()                                                     AS [row_id],
        [io1].[database_id]                                         AS [db_id],
        DB_NAME([io1].[database_id])                                AS [db_name],
        [io1].[file_id]                                             AS [file_id],
        [io1].[name]                                                AS [file_name],
        [io2].[num_of_bytes_read] - [io1].[num_of_bytes_read]       AS [sample_bytes_read] ,
        [io2].[num_of_reads] - [io1].[num_of_reads]                 AS [sample_num_of_reads],
        CASE [io2].[num_of_reads] - [io1].[num_of_reads]            
            WHEN 0 THEN 0
            ELSE
                ([io2].[io_stall_read_ms] - [io1].[io_stall_read_ms])
                    / ([io2].[num_of_reads] - [io1].[num_of_reads])
        END                                                         AS [sample_avg_read_latency],
        [io2].[num_of_writes] - [io1].[num_of_writes]               AS [sample_num_of_writes],
        CASE [io2].[num_of_writes] - [io1].[num_of_writes]
            WHEN 0 THEN 0
            ELSE
                ([io2].[io_stall_write_ms] - [io1].[io_stall_write_ms])
                    / ([io2].[num_of_writes] - [io1].[num_of_writes])
        END                                                         AS [sample_avg_write_latency],
        [io2].[num_of_bytes_written] - [io1].[num_of_bytes_written] AS [sample_bytes_written],
        [io2].[io_stall] - [io1].[io_stall]                         AS [sample_io_stall],
        CASE [io2].[num_of_reads]
            WHEN 0 THEN 0
            ELSE
                ([io2].[io_stall_read_ms])
                    / ([io2].[num_of_reads])
        END                                                         AS [total_avg_read_latency],
        CASE [io2].[num_of_writes]
            WHEN 0 THEN 0
            ELSE
                ([io2].[io_stall_write_ms])
                    / ([io2].[num_of_writes])
        END                                                         AS [total_avg_write_latency],
        GETDATE()                                                   AS [timestamp],
        @INTERVAL                                                   AS [interval]
    FROM @io_stats_2 AS [io2]
        LEFT JOIN @io_stats_1 AS [io1]
            ON ([io2].database_id = [io1].database_id
            AND [io2].file_id = [io1].file_id);
END
GO