USE msdb;
GO

-- Delete existing job if it exists
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs WHERE name = N'DeploySSISPackageJob')
    EXEC msdb.dbo.sp_delete_job @job_name = N'DeploySSISPackageJob';
GO

-- Create new job
EXEC msdb.dbo.sp_add_job
    @job_name = N'DeploySSISPackageJob',
    @enabled = 1,
    @description = N'Job to run SSIS package ProjectPackages',
    @owner_login_name = N'sa';
GO

-- Add job step to execute SSIS package
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'DeploySSISPackageJob',
    @step_name = N'Execute SSIS Package',
    @subsystem = N'SSIS',
    @command = N'/ISSERVER "\SSISDB\TimesheetDeployedPackages\ProjectPackages\ProjectPackages.dtsx" /SERVER "LAPTOP-ATT0UPK9\MSSQLSERVER04"',
    @database_name = N'master';
GO

-- Add job schedule (e.g., every 30 seconds - Note: Minimum interval is 1 minute, adjusted to 1 minute)
EXEC msdb.dbo.sp_add_jobschedule
    @job_name = N'DeploySSISPackageJob',
    @name = N'DailySchedule',
    @enabled = 1,
    @freq_type = 4, -- Daily
    @freq_interval = 1,
    @freq_subday_type = 2, -- Minutes
    @freq_subday_interval = 1, -- Every 1 minute (closest to 30 seconds due to SQL Server Agent limitation)
    @active_start_time = 020000; -- 2:00 AM
GO

-- Add job to server
EXEC msdb.dbo.sp_add_jobserver
    @job_name = N'DeploySSISPackageJob',
    @server_name = N'(local)';
GO
