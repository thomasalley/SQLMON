/*

    Script      sqlmon_log_performance.sql
    Description
        Log SQL OS performance monitor stats.

*/
USE SQLMON;

IF OBJECTPROPERTY(OBJECT_ID(N'sqlmon_log_performance'), 'IsProcedure') = 1 
    DROP PROCEDURE sqlmon_log_performance;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE sqlmon_log_performance
    @INTERVAL AS INT = 30
AS
BEGIN
    SET NOCOUNT ON;


    DECLARE @PerfCounters TABLE
        (
          [Object]          NVARCHAR(300),
          [Counter]         NVARCHAR(300),
          [Instance]        NVARCHAR(300),
          [CounterType]     INT,
          [FirstValue]      DECIMAL(38, 2),
          [FirstDateTime]   DATETIME,
          [SecondValue]     DECIMAL(38, 2),
          [SecondDateTime]  DATETIME,
          [ValueDiff]       AS ( [SecondValue] - [FirstValue] ),
          [TimeDiff]        AS ( DATEDIFF(SS, FirstDateTime, SecondDateTime) ),
          [CounterValue]    DECIMAL(38, 2)
        );

    INSERT  INTO @PerfCounters
    (
        [Object],
        [Counter],
        [Instance],
        [CounterType],
        [FirstValue],
        [FirstDateTime]
    )
        SELECT  [object_name],
                [counter_name],
                [instance_name],--RTRIM([object_name]) + N':' + RTRIM([counter_name]) + N':' + RTRIM([instance_name]) [counter],
                [cntr_type],
                [cntr_value],
                GETDATE()
        FROM    sys.dm_os_performance_counters
        WHERE   [counter_name] IN (
                                    N'Page life expectancy',
                                    N'Lazy writes/sec',
                                    N'Page reads/sec',
                                    N'Page writes/sec',
                                    N'Free Pages',
                                    N'Free list stalls/sec',
                                    N'User Connections',
                                    N'Lock Waits/sec',
                                    N'Number of Deadlocks/sec',
                                    N'Transactions/sec',
                                    N'Forwarded Records/sec',
                                    N'Index Searches/sec',
                                    N'Full Scans/sec',
                                    N'Batch Requests/sec',
                                    N'SQL Compilations/sec',
                                    N'SQL Re-Compilations/sec',
                                    N'Total Server Memory (KB)',
                                    N'Target Server Memory (KB)',
                                    N'Latch Waits/sec'
                                    )

    DECLARE @FORMATTED_INTERVAL AS CHAR(8);
    SET @FORMATTED_INTERVAL = (
        SELECT RIGHT('0' + CAST(@INTERVAL / 3600 AS VARCHAR),2) + ':' +
        RIGHT('0' + CAST((@INTERVAL / 60) % 60 AS VARCHAR),2)  + ':' +
        RIGHT('0' + CAST(@INTERVAL % 60 AS VARCHAR),2)
        )
    WAITFOR DELAY @FORMATTED_INTERVAL

    UPDATE  @PerfCounters
    SET     [SecondValue] = [cntr_value],
            [SecondDateTime] = GETDATE()
    FROM    sys.dm_os_performance_counters
    WHERE   [object] = object_name AND [Counter] = [counter_name] AND [Instance] = [instance_name]
            AND [counter_name] IN (
                                    N'Page life expectancy', 
                                    N'Lazy writes/sec',
                                    N'Page reads/sec', N'Page writes/sec',
                                    N'Free Pages', N'Free list stalls/sec',
                                    N'User Connections', N'Lock Waits/sec',
                                    N'Number of Deadlocks/sec',
                                    N'Transactions/sec',
                                    N'Forwarded Records/sec',
                                    N'Index Searches/sec', N'Full Scans/sec',
                                    N'Batch Requests/sec',
                                    N'SQL Compilations/sec',
                                    N'SQL Re-Compilations/sec',
                                    N'Total Server Memory (KB)',
                                    N'Target Server Memory (KB)',
                                    N'Latch Waits/sec'
                                    );

    UPDATE  @PerfCounters
    SET     [CounterValue] = [ValueDiff] / [TimeDiff]
    WHERE   [CounterType] = 272696576;

    UPDATE  @PerfCounters
    SET     [CounterValue] = [SecondValue]
    WHERE   [CounterType] <> 272696576;

    INSERT  INTO [sqlmon_performance]
    (
        [Object],
        [Instance],
        [Counter],
        [Type],
        [Value],
        [Timestamp],
        [Interval]
    )
        SELECT  RTRIM(LTRIM([Object])),
                RTRIM(LTRIM([Instance])),
                RTRIM(LTRIM([Counter])),
                [CounterType],
                [CounterValue],
                [SecondDateTime],
                @INTERVAL
        FROM    @PerfCounters;
END
GO