IF NOT EXISTS (SELECT * FROM sys.tables WHERE Name = 'RegistrationAuthority')
BEGIN
    CREATE TABLE RegistrationAuthority(
        RegistrationAuthorityId INT NOT NULL PRIMARY KEY IDENTITY(1,1),
        Name VARCHAR(255) NOT NULL UNIQUE,
    )
END

IF NOT EXISTS (SELECT * FROM RegistrationAuthority WHERE Name = 'Edgar')
BEGIN
    INSERT INTO RegistrationAuthority VALUES('Edgar');
END
GO