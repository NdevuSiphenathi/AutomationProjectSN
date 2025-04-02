-- Step 1: Create AutoTestSiphenathi database
USE master;
GO
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'AutoTestSiphenathi')
BEGIN
    CREATE DATABASE AutoTestSiphenathi;
    PRINT 'Database AutoTestSiphenathi created.';
END
ELSE
    PRINT 'Database AutoTestSiphenathi already exists.';
GO

-- Step 2: Switch to AutoTestSiphenathi
USE AutoTestSiphenathi;
GO

-- Step 3: Create user table
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
GO

-- Step 4: Create InsertUser stored procedure
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'InsertUser')
BEGIN
    DROP PROCEDURE InsertUser;
END
GO
CREATE PROCEDURE InsertUser
    @Name VARCHAR(50),
    @Surname VARCHAR(50),
    @Email VARCHAR(100)
AS
BEGIN
    INSERT INTO [user] (Name, Surname, Email)
    VALUES (@Name, @Surname, @Email);
    PRINT 'Inserted: ' + @Name + ' ' + @Surname + ', ' + @Email;
END;
GO

-- Step 5: Insert initial data
EXEC InsertUser @Name = 'Siphenathi', @Surname = 'Ndevu', @Email = 'siphenathi@example.com';
EXEC InsertUser @Name = 'Partner', @Surname = 'One', @Email = 'partner@example.com';
GO

-- Step 6: Verify
SELECT 'Verification: user table contents' AS Message;
SELECT * FROM [user];
GO
