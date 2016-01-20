/*
    SQLMON Project table creations.
    WARNING: Contains Drops for tables that exist.
*/
USE SQLMON;

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

SET NOCOUNT ON

/*************************************************************************
 *      sqlmon_configuration
 *************************************************************************/ 
IF EXISTS
(
    SELECT  1
    FROM    [sys].[tables]
    WHERE   [name] = N'sqlmon_configuration'
) 
    DROP TABLE [dbo].[sqlmon_configuration] 

CREATE TABLE [dbo].[sqlmon_configuration]
(
    [row_id]            UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [config_id]         INT          NOT NULL ,
    [name]              NVARCHAR(35) NOT NULL ,
    [value]             SQL_VARIANT  NULL ,
    [value_in_use]        SQL_VARIANT  NULL ,
    [timestamp]         DATETIME
)
ON  [PRIMARY];
GO

CREATE NONCLUSTERED INDEX IX_sqlmon_configuration
ON [dbo].[sqlmon_configuration]
(
    [timestamp],
    [config_id]
) INCLUDE([Value]);

/*************************************************************************
 *      sqlmon_performance
 *************************************************************************/ 
IF EXISTS
(
    SELECT  1
    FROM    [sys].[tables]
    WHERE   [name] = N'sqlmon_performance'
) 
    DROP TABLE [dbo].[sqlmon_performance]

CREATE TABLE [dbo].[sqlmon_performance]
(
    [row_id]        UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [object]        NVARCHAR(300)   NOT NULL,
    [instance]      NVARCHAR(300)   NULL,
    [counter]       NVARCHAR(300)   NOT NULL,
    [type]          NVARCHAR(300)   NOT NULL,
    [value]         DECIMAL(38, 2)  NOT NULL,
    [interval]      INT,
    [timestamp]     DATETIME
)
ON  [PRIMARY];
GO

CREATE NONCLUSTERED INDEX IX_sqlmon_performance
ON [dbo].[sqlmon_performance]
(
    [counter],
    [timestamp]
) INCLUDE ([Value]);

/*************************************************************************
 *      sqlmon_files
 *************************************************************************/ 
IF EXISTS
(
    SELECT  1
    FROM    [sys].[tables]
    WHERE   [name] = N'sqlmon_files'
) 
    DROP TABLE [dbo].[sqlmon_files]

CREATE TABLE [dbo].[sqlmon_files]
    (
        [row_id]             UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        [db_name]            SYSNAME         NOT NULL,
        [file_id]            INT             NOT NULL,
        [type]               TINYINT         NOT NULL,
        [drive]              NVARCHAR(1)     NULL,
        [logical_file_name]  SYSNAME         NOT NULL,
        [physical_file_name] NVARCHAR(260)   NOT NULL,
        [size_MB]            DECIMAL(38, 2)  NULL,
        [space_used_MB]      DECIMAL(38, 2)  NULL,
        [free_space_MB]      DECIMAL(38, 2)  NULL,
        [max_size]           DECIMAL(38, 2)  NULL,
        [is_percent_growth]  BIT             NULL,
        [growth]             DECIMAL(38, 2)  NULL,
        [timestamp]          DATETIME        NOT NULL
    )
ON  [PRIMARY];
GO

/*************************************************************************
 *      sqlmon_waits
 *************************************************************************/ 
IF EXISTS
(
    SELECT  1
    FROM    [sys].[tables]
    WHERE   [name] = N'sqlmon_waits'
) 
    DROP TABLE [dbo].[sqlmon_waits]

CREATE TABLE [dbo].[sqlmon_waits]
(
        [row_id]                UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        [wait_type]             VARCHAR(64) NOT NULL,
        [wait_count]            BIGINT      NOT NULL,
        [total_wait_count]      BIGINT      NOT NULL,
        [max_wait_time_ms]      BIGINT      NOT NULL,
        [signal_wait_time_ms]   BIGINT      NOT NULL,
        [interval]              BIGINT      NOT NULL,
        [Timestamp]             DATETIME    NOT NULL DEFAULT GETDATE()
)
ON  [PRIMARY];
GO

CREATE NONCLUSTERED INDEX IX_sqlmon_waits
ON [dbo].[sqlmon_waits]
(
    [wait_type],
    [timestamp]
);

/*************************************************************************
 *      sqlmon_db_options
 *************************************************************************/ 
IF EXISTS
(
    SELECT  1
    FROM    [sys].[tables]
    WHERE   [name] = N'sqlmon_db_options'
)
    DROP TABLE [dbo].[sqlmon_db_options]

CREATE TABLE sqlmon_db_options
(
    [row_id]    UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [db_id]     INT         NOT NULL,
    [db_name]   VARCHAR(32) NOT NULL,
	[opt]       VARCHAR(64) NOT NULL,
	[value]     VARCHAR(64) NOT NULL,
	[timestamp] DATETIME    NOT NULL DEFAULT GETDATE()
)

CREATE NONCLUSTERED INDEX IX_sqlmon_db_options
ON [dbo].[sqlmon_db_options]
(
    [db_id],
    [opt],
    [timestamp]
) INCLUDE ([Value]);

/*************************************************************************
 *      sqlmon_io_latency
 *************************************************************************/ 
IF EXISTS
(
    SELECT  1
    FROM    [sys].[tables]
    WHERE   [name] = N'sqlmon_io_latency'
) 
    DROP TABLE [dbo].[sqlmon_io_latency] 

CREATE TABLE [dbo].[sqlmon_io_latency]
(
    [row_id]                    UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    [db_id]                     INT NOT NULL,
    [db_name]	                NVARCHAR(128) NOT NULL,
    [file_id]                   INT NOT NULL,
    [file_name]	                NVARCHAR(128) NOT NULL,
    [sample_bytes_read]	        BIGINT NOT NULL,
    [sample_num_of_writes]      BIGINT NOT NULL,
    [sample_avg_read_latency]	BIGINT NOT NULL,
    [sample_bytes_written]	    BIGINT NOT NULL,
    [sample_bytes_written]      BIGINT NOT NULL,
    [sample_avg_write_latency]	BIGINT NOT NULL,
    [sample_io_stall]	        BIGINT NOT NULL,
    [total_avg_read_latency]	BIGINT NOT NULL,
    [total_avg_write_latency]	BIGINT NOT NULL,
    [Timestamp]	                DATETIME NOT NULL,
    [Interval]                  INT NOT NULL
)
CREATE NONCLUSTERED INDEX IX_sqlmon_io_latency
ON [dbo].[sqlmon_io_latency]
(
    [db_name],
    [file_name],
    [timestamp]
) INCLUDE([sample_avg_read_latency], [sample_avg_write_latency]);

/*************************************************************************
 *      sqlmon_meta
 *************************************************************************/ 
IF EXISTS
(
    SELECT  1
    FROM    [sys].[tables]
    WHERE   [name] = N'sqlmon_meta'
) 
    DROP TABLE [dbo].[sqlmon_meta]

CREATE TABLE [dbo].[sqlmon_meta]
(
    [meta_name]     VARCHAR(128) NOT NULL,
    [meta_value]    VARCHAR(128) NOT NULL
)
INSERT INTO [sqlmon_meta]
(
    [meta_name],
    [meta_value]
)
VALUES 
(
    'version',
    '1.3.0'
);