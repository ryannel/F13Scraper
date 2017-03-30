USE master

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name='StockScraper')
	CREATE DATABASE StockScraper;

USE StockScraper