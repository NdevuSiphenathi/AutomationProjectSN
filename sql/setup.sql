------  Create AutoTestSiphenathi database-------
BEGIN TRY
    USE master;
    IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'AutoTestSiphenathi')
    BEGIN
        CREATE DATABASE AutoTestSiphenathi;
        PRINT 'Database AutoTestSiphenathi created.';
    END
    ELSE
        PRINT 'Database AutoTestSiphenathi already exists.';
END TRY
BEGIN CATCH
    PRINT 'Error creating database AutoTestSiphenathi!';
    PRINT ERROR_MESSAGE();
END CATCH;
GO

--  Switch to AutoTestSiphenathi
BEGIN TRY
    USE AutoTestSiphenathi;
    PRINT 'Switched to database AutoTestSiphenathi.';
END TRY
BEGIN CATCH
    PRINT 'Error switching to AutoTestSiphenathi!';
    PRINT ERROR_MESSAGE();
END CATCH;
GO

--  Create user table
BEGIN TRY
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'user')
    BEGIN
        CREATE TABLE [user] (
            Name VARCHAR(50),
            Surname VARCHAR(50),
            Email VARCHAR(100)
        );
        PRINT 'Table [user] created.';
    END
    ELSE
        PRINT 'Table [user] already exists.';
END TRY
BEGIN CATCH
    PRINT 'Error creating table [user]!';
    PRINT ERROR_MESSAGE();
END CATCH;
GO

--  Create InsertUser stored procedure
BEGIN TRY
    IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'InsertUser')
    BEGIN
        DROP PROCEDURE InsertUser;
    END;
    
    EXEC('
    CREATE PROCEDURE InsertUser
        @Name VARCHAR(50),
        @Surname VARCHAR(50),
        @Email VARCHAR(100)
    AS
    BEGIN
        BEGIN TRY
            INSERT INTO [user] (Name, Surname, Email)
            VALUES (@Name, @Surname, @Email);
            PRINT ''Inserted: '' + @Name + '' '' + @Surname + '', '' + @Email;
        END TRY
        BEGIN CATCH
            PRINT ''Error inserting user: '' + ERROR_MESSAGE();
        END CATCH
    END;
    ');

    PRINT 'Stored procedure InsertUser created.';
END TRY
BEGIN CATCH
    PRINT 'Error creating stored procedure InsertUser!';
    PRINT ERROR_MESSAGE();
END CATCH;
GO

--  Insert initial data
BEGIN TRY
    EXEC InsertUser @Name = 'Siphenathi', @Surname = 'Ndevu', @Email = 'siphenathi@example.com';
    EXEC InsertUser @Name = 'Partner', @Surname = 'One', @Email = 'partner@example.com';
    PRINT 'Initial data inserted.';
END TRY
BEGIN CATCH
    PRINT 'Error inserting initial data!';
    PRINT ERROR_MESSAGE();
END CATCH;
GO

-- : Verify
BEGIN TRY
    IF EXISTS (SELECT 1 FROM [user])
        PRINT 'Verification successful: Data exists.';
    ELSE
        PRINT 'Verification failed: No data found.';
END TRY
BEGIN CATCH
    PRINT 'Error verifying user table!';
    PRINT ERROR_MESSAGE();
END CATCH;
GO
