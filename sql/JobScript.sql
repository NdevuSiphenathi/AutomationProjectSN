USE msdb;
GO

DECLARE @jobName NVARCHAR(128) = 'SamplePackage'; -- Replace with your package name

-- Delete existing job if it exists
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs WHERE name = @jobName)
    EXEC msdb.dbo.sp_delete_job @job_name = @jobName;

-- Create new job
EXEC msdb.dbo.sp_add_job
    @job_name = @jobName,
    @enabled = 1,
    @description = N'Job to run SSIS package ' + @jobName,
    @owner_login_name = N'sa';

-- Add job step to execute SSIS package
EXEC msdb.dbo.sp_add_jobstep
    @job_name = @jobName,
    @step_name = N'Execute SSIS Package',
    @subsystem = N'SSIS',
    @command = N'/ISSERVER "\SSISDB\TimesheetDeployedPackages\' + @jobName + '\Package.dtsx" /SERVER "LAPTOP-ATT0UPK9"', -- Replace LAPTOP-ATT0UPK9 with your DB_SERVER
    @database_name = N'master';

-- Add job schedule (e.g., daily at 2 AM)
EXEC msdb.dbo.sp_add_jobschedule
    @job_name = @jobName,
    @name = N'DailySchedule',
    @enabled = 1,
    @freq_type = 4, -- Daily
    @freq_interval = 1,
    @active_start_time = 020000; -- 2:00 AM

-- Add job to server
EXEC msdb.dbo.sp_add_jobserver
    @job_name = @jobName,
    @server_name = N'(local)';
GO
