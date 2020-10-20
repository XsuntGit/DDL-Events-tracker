USE [master]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [_Sys_tgr_DDL_Events]
    ON ALL SERVER
    WITH EXECUTE AS 'sa'
    AFTER DDL_EVENTS
AS
	BEGIN
		DECLARE @restoreXACT_ABORT bit = 16384 & (SELECT @@OPTIONS);
		SET XACT_ABORT OFF
		DECLARE @restoreANSI_PADDING bit = 16 & (SELECT @@OPTIONS);
		SET ANSI_PADDING ON
		DECLARE @restoreANSI_WARNINGS bit = 8 & (SELECT @@OPTIONS);
		SET ANSI_WARNINGS ON
		DECLARE @restoreCONCAT_NULL_YIELDS_NULL bit = 4096 & (SELECT @@OPTIONS);
		SET CONCAT_NULL_YIELDS_NULL ON
		DECLARE @restoreNUMERIC_ROUNDABORT bit = 8192 & (SELECT @@OPTIONS);
		SET NUMERIC_ROUNDABORT OFF
		DECLARE @restoreNOCOUNT bit = 512 & (SELECT @@OPTIONS);
		SET NOCOUNT ON

		BEGIN TRY
			DECLARE @eventdata XML = EVENTDATA();
			INSERT INTO [XsuntAdmin].[dbo].[Sys_DDL_Events]
			(
				[PostTime],
				[transaction_id],
				[spid],
				[Options],
				[DatabaseName],
				[SchemaName],
				[ObjectName],
				[EventType],
				[client_net_address],
				[LoginName],
				[AppName],
				[EventData]
			)
			VALUES  (
				TODATETIMEOFFSET(CONVERT(varchar(23), @eventdata.query('data(/EVENT_INSTANCE/PostTime)')), DATEPART(tz, SYSDATETIMEOFFSET())),
				(SELECT transaction_id from sys.dm_tran_current_transaction),
				@@SPID,
				@@OPTIONS,
                CONVERT(varchar(255), @eventdata.query('data(/EVENT_INSTANCE/DatabaseName)')),
                CONVERT(varchar(255), @eventdata.query('data(/EVENT_INSTANCE/SchemaName)')),
                CONVERT(varchar(255), @eventdata.query('data(/EVENT_INSTANCE/ObjectName)')),
                CONVERT(varchar(100), @eventdata.query('data(/EVENT_INSTANCE/EventType)')),
				CONVERT(varchar(48), CONNECTIONPROPERTY('client_net_address')),
                CONVERT(varchar(255), @eventdata.query('data(/EVENT_INSTANCE/LoginName)')),
				APP_NAME(),
				@eventdata
				)

		END TRY
		BEGIN CATCH
			BEGIN TRY
				DECLARE @errmsg nvarchar(2048) = error_message(),
					@severity tinyint = error_severity(),
					@state tinyint = error_state(),
					@errno int = error_number(),
					@proc sysname = error_procedure(),
					@lineno int = error_line()

				IF @errmsg NOT LIKE '***%'
				BEGIN
					SELECT @errmsg = '*** ' + coalesce(quotename(@proc), '<dynamic SQL>') + ', Line ' + ltrim(str(@lineno)) + '. Errno ' + ltrim(str(@errno)) + ': ' + @errmsg
				END

			END TRY
			BEGIN CATCH
				-- Left intentionally blank :(
			END CATCH
		END CATCH

		IF @restoreXACT_ABORT = 1
		BEGIN
			SET XACT_ABORT ON
		END
		IF @restoreANSI_PADDING = 0
		BEGIN
			SET ANSI_PADDING OFF
		END
		IF @restoreANSI_WARNINGS = 0
		BEGIN
			SET ANSI_WARNINGS OFF
		END
		IF @restoreCONCAT_NULL_YIELDS_NULL = 0
		BEGIN
			SET CONCAT_NULL_YIELDS_NULL OFF
		END
		IF @restoreNUMERIC_ROUNDABORT = 1
		BEGIN
			SET NUMERIC_ROUNDABORT ON
		END
		IF @restoreNOCOUNT = 0
		BEGIN
			SET NOCOUNT OFF
		END
	END
GO

ENABLE TRIGGER [_Sys_tgr_DDL_Events] ON ALL SERVER
GO
