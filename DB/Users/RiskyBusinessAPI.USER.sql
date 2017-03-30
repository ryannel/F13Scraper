IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'StockScraperUser')
BEGIN
	CREATE LOGIN StockScraperUser WITH PASSWORD = 'Test123'
	CREATE USER StockScraperUser FOR LOGIN StockScraperUser
	EXEC sp_addrolemember 'db_datareader', StockScraperUser
	EXEC sp_addrolemember 'db_datawriter', StockScraperUser
END
GO