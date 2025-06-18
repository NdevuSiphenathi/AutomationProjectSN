-- ======================================
-- TimesheetDB Full Database and Tables Creation
-- =============================================

-- 🔁 Create Database (if not exists)
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'TimesheetDBTest')
BEGIN
    CREATE DATABASE [TimesheetDBTest];
END
GO

USE [TimesheetDBTest];
GO

-- =============================================
-- dbo.Activity
-- =============================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
CREATE TABLE [dbo].[Activity] (
    [ActivityID] INT IDENTITY(1,1) NOT NULL,
    [ActivityDescription] NVARCHAR(100) NOT NULL,
    PRIMARY KEY CLUSTERED ([ActivityID]),
    UNIQUE NONCLUSTERED ([ActivityDescription])
);
GO

-- =============================================
-- dbo.AuditLog
-- =============================================
CREATE TABLE [dbo].[AuditLog] (
    [AuditLogID] INT IDENTITY(1,1) NOT NULL,
    [PackageName] NVARCHAR(100) NOT NULL,
    [TaskName] NVARCHAR(100) NOT NULL,
    [TableName] NVARCHAR(100) NOT NULL,
    [RowsLoaded] INT NOT NULL,
    [RunDate] DATETIME2(7) NOT NULL DEFAULT (sysutcdatetime()),
    [ExecutedBy] NVARCHAR(100) NOT NULL,
    [EmployeeName] NVARCHAR(100) NULL,
    [FileName] NVARCHAR(260) NULL,
    CONSTRAINT [PK_AuditLog] PRIMARY KEY CLUSTERED ([AuditLogID])
);
GO

-- =============================================
-- dbo.BillableType
-- =============================================
CREATE TABLE [dbo].[BillableType] (
    [BillableTypeID] INT IDENTITY(1,1) NOT NULL,
    [BillableStatus] NVARCHAR(50) NOT NULL,
    PRIMARY KEY CLUSTERED ([BillableTypeID]),
    UNIQUE NONCLUSTERED ([BillableStatus])
);
GO

-- =============================================
-- dbo.Client
-- =============================================
CREATE TABLE [dbo].[Client] (
    [ClientID] INT IDENTITY(1,1) NOT NULL,
    [ClientName] NVARCHAR(255) NULL,
    PRIMARY KEY CLUSTERED ([ClientID]),
    UNIQUE NONCLUSTERED ([ClientName])
);
GO

-- =============================================
-- dbo.Employee
-- =============================================
CREATE TABLE [dbo].[Employee] (
    [EmployeeID] INT IDENTITY(1,1) NOT NULL,
    [ConsultantName] NVARCHAR(100) NOT NULL,
    PRIMARY KEY CLUSTERED ([EmployeeID]),
    UNIQUE NONCLUSTERED ([ConsultantName])
);
GO

-- =============================================
-- dbo.ErrorLog
-- =============================================
CREATE TABLE [dbo].[ErrorLog] (
    [ErrorLogID] INT IDENTITY(1,1) NOT NULL,
    [PackageName] VARCHAR(255) NULL,
    [TaskName] VARCHAR(255) NULL,
    [ErrorMessage] NVARCHAR(MAX) NULL,
    [ErrorTime] DATETIME NULL DEFAULT (GETUTCDATE()),
    [FileName] VARCHAR(255) NULL,
    [TableName] VARCHAR(255) NULL,
    [ExecutedBy] VARCHAR(255) NULL,
    PRIMARY KEY CLUSTERED ([ErrorLogID])
);
GO

-- =============================================
-- dbo.Leave
-- =============================================
CREATE TABLE [dbo].[Leave] (
    [LeaveID] INT IDENTITY(1,1) NOT NULL,
    [EmployeeID] INT NOT NULL,
    [ActivityID] INT NOT NULL,
    [LeaveStart] DATE NOT NULL,
    [LeaveEnd] DATE NOT NULL,
    [NumberOfDays] DECIMAL(5,2) NOT NULL,
    [ApprovalFlag] CHAR(1) NULL,
    [HasSickNote] CHAR(1) NULL,
    [FileName] NVARCHAR(260) NOT NULL,
    [InsertedAt] DATETIME NOT NULL DEFAULT (GETDATE()),
    PRIMARY KEY CLUSTERED ([LeaveID])
);
ALTER TABLE [dbo].[Leave] ADD CONSTRAINT [FK_Leave_Activity] FOREIGN KEY ([ActivityID]) REFERENCES [dbo].[Activity] ([ActivityID]);
ALTER TABLE [dbo].[Leave] ADD CONSTRAINT [FK_Leave_Employee] FOREIGN KEY ([EmployeeID]) REFERENCES [dbo].[Employee] ([EmployeeID]);
GO

-- =============================================
-- dbo.LeaveStaging
-- =============================================
CREATE TABLE [dbo].[LeaveStaging] (
    [Consultant] NVARCHAR(100) NULL,
    [DateFrom] NVARCHAR(20) NULL,
    [DateTo] NVARCHAR(20) NULL,
    [LeaveType] NVARCHAR(50) NULL,
    [NumberOfDays] NVARCHAR(20) NULL,
    [ApprovalObtained] NVARCHAR(10) NULL,
    [SickNote] NVARCHAR(10) NULL,
    [Comments] NVARCHAR(MAX) NULL,
    [FileName] NVARCHAR(260) NOT NULL,
    [InsertedAt] DATETIME NOT NULL DEFAULT (GETDATE())
);
GO

-- =============================================
-- dbo.TimesheetStaging
-- =============================================
CREATE TABLE [dbo].[TimesheetStaging] (
    [EmployeeName] NVARCHAR(100) NULL,
    [ProjectName] NVARCHAR(100) NULL,
    [ActivityName] NVARCHAR(100) NULL,
    [BillableType] NVARCHAR(50) NULL,
    [WorkDate] DATE NULL,
    [DayOfWeek] NVARCHAR(20) NULL,
    [StartTime] NVARCHAR(50) NULL,
    [EndTime] NVARCHAR(50) NULL,
    [TotalHours] NVARCHAR(50) NULL,
    [Comments] NVARCHAR(MAX) NULL,
    [FileName] NVARCHAR(260) NOT NULL,
    [LoadedOnUtc] DATETIME2(7) NOT NULL DEFAULT (SYSUTCDATETIME()),
    [Description] NVARCHAR(500) NULL
);
GO

-- =============================================
-- dbo.Timesheet
-- =============================================
CREATE TABLE [dbo].[Timesheet] (
    [TimesheetID] INT IDENTITY(1,1) NOT NULL,
    [EmployeeID] INT NOT NULL,
    [WorkDate] DATE NOT NULL,
    [DayOfWeek] NVARCHAR(20) NULL,
    [StartTime] TIME(7) NOT NULL,
    [EndTime] TIME(7) NOT NULL,
    [TotalHours] DECIMAL(5,2) NOT NULL CHECK ([TotalHours] >= 0),
    [Comments] NVARCHAR(MAX) NULL,
    [FileName] NVARCHAR(MAX) NULL DEFAULT ('UnknownFileName'),
    [InsertedAt] DATETIME NOT NULL DEFAULT (GETDATE()),
    [ProjectName] NVARCHAR(100) NOT NULL DEFAULT (''),
    [ActivityName] NVARCHAR(100) NOT NULL DEFAULT (''),
    [BillableType] NVARCHAR(50) NOT NULL DEFAULT ('Non-Billable'),
    [Description] NVARCHAR(500) NULL,
    PRIMARY KEY CLUSTERED ([TimesheetID]),
    CONSTRAINT [FK_Timesheets_Employees] FOREIGN KEY ([EmployeeID]) REFERENCES [dbo].[Employee] ([EmployeeID]),
    CONSTRAINT [CK_TimeRange] CHECK ([StartTime] < [EndTime])
);
GO
