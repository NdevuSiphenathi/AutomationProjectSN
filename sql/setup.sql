USE [msdb];
GO

-- Remove existing job
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs WHERE name = N'@jobName')
BEGIN
    EXEC msdb.dbo.sp_delete_job @job_name = N'@jobName';
END
GO

-- Create job
DECLARE @jobId BINARY(16);
EXEC msdb.dbo.sp_add_job 
    @job_name = N'@jobName',
    @enabled = 1,
    @notify_level_eventlog = 2,
    @delete_level = 0,
    @description = N'Scheduled job to execute SSIS package: @jobName every 1 minute',
    @category_name = N'[Uncategorized (Local)]',
    @owner_login_name = N'$env:DB_USER', -- Use workflow env variable
    @job_id = @jobId OUTPUT;
GO

-- Add job step to run SSIS package
EXEC msdb.dbo.sp_add_jobstep 
    @job_name = N'@jobName',
    @step_name = N'Run SSIS Package',
    @subsystem = N'SSIS',
    @command = N'/ISSERVER "\SSISDB\TimesheetDeployedPackages\ProjectPackages\@jobName.dtsx" /SERVER "$env:DB_SERVER" /ENVREFERENCE 0 /ISSERVER',
    @database_name = N'master',
    @on_success_action = 1,
    @on_fail_action = 2;
GO

-- First schedule: starts at 00:00:00
EXEC msdb.dbo.sp_add_jobschedule 
    @job_name = N'@jobName',
    @name = N'RunEveryMinute_0',
    @enabled = 1,
    @freq_type = 4,  -- daily
    @freq_interval = 1,
    @freq_subday_type = 4, -- minutes (corrected from seconds)
    @freq_subday_interval = 1, -- every 1 minute
    @active_start_time = 000000;
GO

-- Second schedule: starts at 00:00:30 (optional, but limited to 1-minute minimum)
EXEC msdb.dbo.sp_add_jobschedule 
    @job_name = N'@jobName',
    @name = N'RunEveryMinute_30',
    @enabled = 1,
    @freq_type = 4,  -- daily
    @freq_interval = 1,
    @freq_subday_type = 4, -- minutes
    @freq_subday_interval = 1, -- every 1 minute
    @active_start_time = 000030;
GO

-- Attach job to current server
EXEC msdb.dbo.sp_add_jobserver 
    @job_name = N'@jobName',
    @server_name = N'(LOCAL)';
GO
