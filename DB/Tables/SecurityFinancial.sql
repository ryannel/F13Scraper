IF NOT EXISTS (SELECT * FROM sys.tables WHERE Name = 'SecurityFinancial')
BEGIN
    CREATE TABLE SecurityFinancial(
		SecurityFinancialId INT NOT NULL PRIMARY KEY IDENTITY(1,1),
        SecurityId INT NOT NULL,
        Price DECIMAL(10,2) NOT NULL,
        PeRatio DECIMAL(6,2) NOT NULL,
        PbRatio DECIMAL(6,2) NOT NULL,
        DateTime SMALLDATETIME NOT NULL,
        CONSTRAINT SecurityFinancial_Security FOREIGN KEY (SecurityId) REFERENCES Security(SecurityId)
    )
END
GO
