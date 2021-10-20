USE [master]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER TRIGGER [_Sys_tgr_BMSChina_restriction]
    ON ALL SERVER
	WITH EXECUTE AS 'sa'
    FOR DDL_DATABASE_EVENTS
AS
	BEGIN
		BEGIN TRY
			SET NOCOUNT ON;
			DECLARE @msg NVARCHAR(500),
					@cmd NVARCHAR(256),
					@user NVARCHAR(256),
					@ADGroup_restrict NVARCHAR(256) = 'OneLook_BMSChina_SQL_Admins',
					@ADGroups_exclude NVARCHAR(500) = 'OneLook_SQL_Admins, OneLook_SQL_RO, OneLook_SQL_RW, OneLook_SQL_Sysadmins'
			DECLARE @ADuser TABLE ([output] NVARCHAR(256))
			SET @user = EVENTDATA().value('(/EVENT_INSTANCE/LoginName)[1]','nvarchar(255)')
			SET @user = SUBSTRING(@user,CHARINDEX('\',@user)+1,LEN(@user))
			IF LEN(@user)>0
			BEGIN
				SET @cmd = 'powershell.exe "((Get-ADuser -Identity ' + @user + ' -Properties MemberOf).MemberOf | Get-ADGroup | Select-Object Name).Name"'
				INSERT INTO @ADuser EXEC master.dbo.xp_cmdshell @cmd
				IF EXISTS (SELECT TOP 1 1 FROM @ADuser WHERE [output] = @ADGroup_restrict) AND NOT EXISTS (SELECT TOP 1 1 FROM @ADuser WHERE [output] in (SELECT value FROM STRING_SPLIT(@ADGroups_exclude,',')))
				BEGIN
					IF EVENTDATA().value('(/EVENT_INSTANCE/DatabaseName)[1]','nvarchar(255)') not like 'BMSChina%' and EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]','nvarchar(255)') in ('CREATE_DATABASE')
					BEGIN
						set @msg = 'For this security level, the database name does not meet naming convension "BMSChina[0-9a-z]*" and cannot be created.'
						RAISERROR(@msg,10,1)
						ROLLBACK
					END
					ELSE
					IF EVENTDATA().value('(/EVENT_INSTANCE/DatabaseName)[1]','nvarchar(255)') not like 'BMSChina%' and EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]','nvarchar(255)') in ('DROP_DATABASE')
					BEGIN
						set @msg = 'For this security level, the database name does not meet naming convension "BMSChina[0-9a-z]*" and cannot be dropped.'
						RAISERROR(@msg,10,1)
						ROLLBACK
					END
				END

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

			END
		END TRY
		BEGIN CATCH
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
		END CATCH
	END
GO

ENABLE TRIGGER [_Sys_tgr_BMSChina_restriction] ON ALL SERVER
GO
