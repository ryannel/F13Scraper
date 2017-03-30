IF NOT EXISTS (SELECT * FROM sys.tables WHERE Name = 'FormType')
BEGIN
    CREATE TABLE FormType(
        FormTypeId INT NOT NULL PRIMARY KEY IDENTITY(1,1),
        Name VARCHAR(255) NOT NULL UNIQUE, 
    )
END
GO

IF NOT EXISTS (SELECT * FROM FormType WHERE Name = '13F-HR')
BEGIN
    INSERT INTO FormType VALUES('13F-HR');
END
GO