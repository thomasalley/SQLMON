/*

    Script      sqlmon_log_configuration.sql
    Description
        Logs SQL Server Configuration.

*/
USE SQLMON;

IF OBJECTPROPERTY(OBJECT_ID(N'sqlmon_log_configuration'), 'IsProcedure') = 1 
    DROP PROCEDURE sqlmon_log_configuration;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE sqlmon_log_configuration
AS
BEGIN
    SET NOCOUNT ON;

    INSERT  INTO [sqlmon_configuration]
    (
        [config_id] ,
        [Name] ,
        [Value] ,
        [value_in_use] ,
        [Timestamp]
    )
    SELECT  [configuration_id],
            [name],
            [value],
            [value_in_use],
            GETDATE()
    FROM    [sys].[configurations];
END
GO