IF NOT EXISTS (SELECT * FROM sys.tables WHERE Name = 'Registration')
BEGIN
    CREATE TABLE Registration(
		RegistrationId INT NOT NULL PRIMARY KEY IDENTITY(1,1),
        HedgeFundId INT NOT NULL,
        RegistrationAuthorityId INT NOT NULL,
        Identifier VARCHAR(255) NOT NULL,
        CONSTRAINT Registration_HedgeFund FOREIGN KEY (HedgeFundId) REFERENCES HedgeFund(HedgeFundId),
        CONSTRAINT Registration_RegistrationAuthority FOREIGN KEY (RegistrationAuthorityId) REFERENCES RegistrationAuthority(RegistrationAuthorityId),
    )
END
GO
