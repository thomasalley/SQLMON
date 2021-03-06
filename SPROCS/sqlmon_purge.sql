/*
    
    Script      sqlmon_purge.sql
    Description
        Purge sproc for sqlmon project. Clears out log tables based on input.

*/
USE OTN;

IF OBJECTPROPERTY(OBJECT_ID(N'sqlmon_purge'), 'IsProcedure') = 1 
    DROP PROCEDURE sqlmon_purge;
GO

CREATE PROCEDURE sqlmon_purge
    (
      @PurgeConfig      SMALLINT    = 90,   -- Days to Keep Configuration logs
      @PurgeFiles       SMALLINT    = 90,   -- Days to keep Files logs
      @PurgeCounters    SMALLINT    = 90    -- Days to keep Counters logs
    )
AS 
BEGIN;
    SET NOCOUNT ON
    IF @PurgeConfig IS NULL
    OR @PurgeCounters IS NULL 
    BEGIN;
        RAISERROR(N'Input parameters cannot be NULL', 16, 1);
        RETURN;
    END;

    DELETE  FROM [sqlmon_configuration]
    WHERE   [Timestamp] < GETDATE() - @PurgeConfig;

    DELETE FROM [sqlmon_db_options]
    WHERE   [Timestamp] < GETDATE() - @PurgeCounters;
    
    DELETE FROM [sqlmon_files]
    WHERE   [Timestamp] < GETDATE() - @PurgeFiles;

    DELETE  FROM [sqlmon_performance]
    WHERE   [Timestamp] < GETDATE() - @PurgeCounters;

    DELETE FROM [sqlmon_waits]
    WHERE   [Timestamp] < GETDATE() - @PurgeCounters;

    DELETE FROM [sqlmon_io_latency]
    WHERE   [Timestamp] < GETDATE() - @PurgeCounters;
END;