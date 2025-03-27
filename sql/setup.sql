-- Step 1: Create AutoTest_SN27March database via stored procedure
USE master;
GO
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'CreateAutoTest_SN27March')
BEGIN
    DROP PROCEDURE CreateAutoTest_SN27March;
END
GO
CREATE PROCEDURE CreateAutoTest_SN27March
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'AutoTest_SN27March')
    BEGIN
        CREATE DATABASE AutoTest_SN27March;
        PRINT 'Database AutoTest_SN27March created.';
    END
    ELSE
        PRINT 'Database AutoTest_SN27March already exists.';
END;
GO
EXEC CreateAutoTest_SN27March;
GO

-- Step 2: Switch to AutoTest_SN27March
USE AutoTest_SN27March;
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
