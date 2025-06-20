USE [msdb];
GO

-- Drop job if it exists
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs WHERE name = N'@jobName')
BEGIN
    EXEC msdb.dbo.sp_delete_job @job_name = N'@jobName';
END
GO

-- Create new job
DECLARE @jobId UNIQUEIDENTIFIER;
EXEC msdb.dbo.sp_add_job 
    @job_name = N'@jobName',
    @enabled = 1,
    @notify_level_eventlog = 2,
    @description = N'SSIS job to run @jobName every 60 seconds',
    @category_name = N'[Uncategorized (Local)]',
    @owner_login_name = N'sa',
    @job_id = @jobId OUTPUT;
GO

-- Add job step
EXEC msdb.dbo.sp_add_jobstep 
    @job_name = N'@jobName',
    @step_name = N'Run SSIS Package',
    @subsystem = N'SSIS',
    @command = N'/ISSERVER "\SSISDB\TimesheetDeployedPackages\ProjectPackages\@jobName" /SERVER "LAPTOP-ATT0UPK9" /ENVREFERENCE 1',
    @on_success_action = 1,
    @on_fail_action = 2,
    @database_name = N'master',
    @output_file_name = N'C:\SSISLogs\@jobName.log';  -- Ensure Agent has access
GO

-- Add schedule (every 1 minute)
EXEC msdb.dbo.sp_add_jobschedule 
    @job_name = N'@jobName',
    @name = N'RunEveryMinute',
    @enabled = 1,
    @freq_type = 4,  -- Daily
    @freq_interval = 1,
    @freq_subday_type = 2,  -- Seconds
    @freq_subday_interval = 60,  -- Every 60s
    @active_start_time = 000000;
GO

-- Attach job to current server
EXEC msdb.dbo.sp_add_jobserver 
    @job_name = N'@jobName',
    @server_name = N'(LOCAL)';
GO
