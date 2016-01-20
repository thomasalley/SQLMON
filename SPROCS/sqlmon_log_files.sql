/*

    Script      sqlmon_log_files.sql
    Description
        Log SQL server file stats. Requires hard-coding logging DB into proc, should change that.

*/
USE SQLMON;

IF OBJECTPROPERTY(OBJECT_ID(N'sqlmon_log_files'), 'IsProcedure') = 1 
    DROP PROCEDURE sqlmon_log_files;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE sqlmon_log_files
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @sqlstring NVARCHAR(MAX);
    DECLARE @DBName NVARCHAR(257);

    DECLARE DBCursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY
    FOR
        SELECT  QUOTENAME([name])
        FROM    [sys].[databases]
        WHERE   [state] = 0
        ORDER BY [name];

    BEGIN
        OPEN DBCursor;
        FETCH NEXT FROM DBCursor INTO @DBName;
        WHILE @@FETCH_STATUS <> -1 
            BEGIN
                SET @sqlstring = N'USE ' + @DBName + '
          ; INSERT INTO [SQLMON]..[sqlmon_files] (
          [db_name],
          [file_id],
          [Type],
          [drive],
          [logical_file_name],
          [physical_file_name],
          [size_mb],
          [space_used_MB],
          [free_space_MB],
          [max_size],
          [is_percent_growth],
          [Growth],
          [Timestamp]
          )
          SELECT ''' + REPLACE(REPLACE(@DBName,'[',''),']','')
                    + ''' 
          ,[file_id],
           [type],
          substring([physical_name],1,1),
          [name],
          [physical_name],
          CAST([size] as DECIMAL(38,0))/128., 
          CAST(FILEPROPERTY([name],''SpaceUsed'') AS DECIMAL(38,0))/128., 
          (CAST([size] as DECIMAL(38,0))/128) - (CAST(FILEPROPERTY([name],''SpaceUsed'') AS DECIMAL(38,0))/128.0),
          [max_size],
          [is_percent_growth],
          [growth],
          GETDATE()
              FROM [sys].[database_files];'
                EXEC (@sqlstring)
                FETCH NEXT FROM DBCursor INTO @DBName;
            END

        CLOSE DBCursor;
        DEALLOCATE DBCursor;
    END
END
GO