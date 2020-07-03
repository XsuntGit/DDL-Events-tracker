USE [master]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Sys_DDL_Events](
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 75) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
