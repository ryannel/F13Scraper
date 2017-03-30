IF NOT EXISTS (SELECT * FROM sys.tables WHERE Name = 'Filing')
BEGIN
    CREATE TABLE Filing(
		FilingId INT NOT NULL PRIMARY KEY IDENTITY(1,1),
        HedgeFundId INT NOT NULL,
        FormTypeId INT NOT NULL,
        MasterIndexId INT NOT NULL,
        Date DATETIME NOT NULL,
        Url VARCHAR(255) NOT NULL UNIQUE,
        CONSTRAINT Filing_HedgeFund FOREIGN KEY (HedgeFundId) REFERENCES HedgeFund(HedgeFundId),
        CONSTRAINT Filing_FormType FOREIGN KEY (FormTypeId) REFERENCES FormType(FormTypeId),
        CONSTRAINT Filing_MasterIndex FOREIGN KEY (MasterIndexId) REFERENCES MasterIndex(MasterIndexId)
    )
END
GO
