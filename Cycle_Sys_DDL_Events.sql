USE [XsuntAdmin]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[Cycle_Sys_DDL_Events]
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		DISABLE TRIGGER [_Sys_tgr_DDL_Events] ON ALL SERVER;

		DECLARE @Sys_DDL_Events_PK_New_Name SYSNAME;
		SET @Sys_DDL_Events_PK_New_Name = 'PK_Sys_DDL_Events_ID_' + REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR,GETDATE(),121),'-','_'),' ' , '_'),':',''),'.','_');

		exec sp_rename 'dbo.PK_Sys_DDL_Events_ID', @Sys_DDL_Events_PK_New_Name;

		DECLARE @Sys_DDL_Events_New_Name SYSNAME;
		SET @Sys_DDL_Events_New_Name = 'Sys_DDL_Events_' + REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR,GETDATE(),121),'-','_'),' ' , '_'),':',''),'.','_');

		exec sp_rename 'dbo.Sys_DDL_Events', @Sys_DDL_Events_New_Name;

		CREATE TABLE [XsuntAdmin].[dbo].[Sys_DDL_Events](
			[Id] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
			[PostTime] [datetimeoffset](7) NULL,
			[transaction_id] [bigint] NULL,
			[spid] [smallint] NULL,
			[Options] [int] NULL,
			[DatabaseName] [nvarchar](255) NULL,
			[SchemaName] [nvarchar](255) NULL,
			[ObjectName] [nvarchar](255) NULL,
			[EventType] [nvarchar](100) NULL,
			[client_net_address] [varchar](48) NULL,
			[LoginName] [nvarchar](255) NULL,
			[AppName] [nvarchar](128) NULL,
			[EventData] [xml] NULL,
		 CONSTRAINT [PK_Sys_DDL_Events_ID] PRIMARY KEY CLUSTERED
		(
			[Id] DESC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
		) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];

		ENABLE TRIGGER [_Sys_tgr_DDL_Events] ON ALL SERVER

	END TRY
	BEGIN CATCH

		DECLARE @errmsg   nvarchar(2048),
				@severity tinyint,
				@state    tinyint,
				@errno    int,
				@proc     sysname,
				@lineno   int

		SELECT @errmsg = error_message(), @severity = error_severity(),
				@state  = error_state(), @errno = error_number(),
				@proc   = error_procedure(), @lineno = error_line()

		IF @errmsg NOT LIKE '***%'
		BEGIN
			SELECT @errmsg = '*** ' + coalesce(quotename(@proc), '<dynamic SQL>') +
							', Line ' + ltrim(str(@lineno)) + '. Errno ' +
							ltrim(str(@errno)) + ': ' + @errmsg
		END
		RAISERROR('%s', @severity, @state, @errmsg)

	END CATCH

END
GO
