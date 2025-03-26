-- Step 1: Create the AutoTest db
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'AutoTest')
BEGIN
    CREATE DATABASE AutoTest;
    PRINT 'Database AutoTest created.';
END
ELSE
    PRINT 'Database AutoTest already exists.';

GO

-- Step 2: Switch to the AutoTest database
USE AutoTest;
GO

-- Step 3: Create the user table with Name, Surname, and Email fields
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

-- Step 4: Create or replace the InsertUser stored procedure
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'InsertUser')
BEGIN
    DROP PROCEDURE InsertUser;
    PRINT 'Existing InsertUser procedure dropped.';
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
    PRINT 'Data inserted via InsertUser: ' + @Name + ' ' + @Surname + ', ' + @Email;
END;
GO

PRINT 'Stored procedure InsertUser created.';

-- Step 5: Insert sample data using the stored procedure
EXEC InsertUser @Name = 'Siphenathi', @Surname = 'Ndevu', @Email = 'siph.do@example.com';
EXEC InsertUser @Name = 'Ndevu', @Surname = 'Siphe', @Email = 'siph.sth@example.com';
GO

-- Step 6: Verify the setup (optional, for debugging)
SELECT 'Verification: Contents of user table' AS Message;
SELECT * FROM [user];
GO
