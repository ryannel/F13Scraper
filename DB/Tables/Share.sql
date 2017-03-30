IF NOT EXISTS (SELECT * FROM sys.tables WHERE Name = 'Share')
BEGIN
    CREATE TABLE Share(
		ShareId INT NOT NULL PRIMARY KEY IDENTITY(1,1),
        FilingId INT NOT NULL,
        SecurityId INT NOT NULL,
        Number INT NOT NULL,
        Type VARCHAR(255) NOT NULL,
        Value DECIMAL(32, 4) NOT NULL
        CONSTRAINT Share_Filing FOREIGN KEY (FilingId) REFERENCES Filing(FilingId),
        CONSTRAINT Share_Security FOREIGN KEY (SecurityId) REFERENCES Security(SecurityId),
    )
END
GO
