IF NOT EXISTS (SELECT * FROM sys.tables WHERE Name = 'SecurityMap')
BEGIN
    CREATE TABLE SecurityMap(
		SecurityMapId INT NOT NULL PRIMARY KEY IDENTITY(1,1),
        Name VARCHAR(255) NOT NULL,
        Cusip VARCHAR(255) NOT NULL UNIQUE,
        SecurityId INT,
        CONSTRAINT SecurityMap_Security FOREIGN KEY (SecurityId) REFERENCES Security(SecurityId)
    )
END
GO
