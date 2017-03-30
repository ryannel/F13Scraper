IF NOT EXISTS (SELECT * FROM sys.tables WHERE Name = 'UnknownShare')
BEGIN
    CREATE TABLE UnknownShare(
		UnknownShareId INT NOT NULL PRIMARY KEY IDENTITY(1,1),
        FilingId INT NOT NULL,
        Number INT NOT NULL,
        Type VARCHAR(255) NOT NULL,
        Value DECIMAL(32, 4) NOT NULL,
        NameOfIssuer VARCHAR(255) NOT NULL,
        Cusip VARCHAR(255) NOT NULL UNIQUE,
        SecurityId INT,
        CONSTRAINT UnknownShare_Filing FOREIGN KEY (FilingId) REFERENCES Filing(FilingId)
    )
END
GO
