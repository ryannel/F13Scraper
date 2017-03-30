IF NOT EXISTS (SELECT * FROM sys.tables WHERE Name = 'Security')
BEGIN
    CREATE TABLE Security(
		SecurityId INT NOT NULL PRIMARY KEY IDENTITY(1,1),
        Name VARCHAR(255) NOT NULL,
        Symbol VARCHAR(15) NOT NULL,
        Exchange VARCHAR(15) NOT NULL,
        CONSTRAINT UNIQUE_Security UNIQUE(Symbol, Exchange)
    )
END
GO
