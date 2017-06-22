-- ====================================================
-- Baskerville API DB Release
-- 2017-04-07 15:25:09
-- ====================================================

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'GameMonitor') USE GameMonitor;
GO
IF (db_name() <> 'GameMonitor') RAISERROR('Error, ''USE GameMonitor'' failed!  Killing the SPID now.',22,127) WITH LOG;
SET NOCOUNT ON;

RAISERROR ('Update Started:', 10, 0) WITH NOWAIT;

-- =========================
-- File Path: ./DataBase\StockScraper.DB.sql
-- =========================

RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;
RAISERROR (' EXECUTING: ./DataBase\StockScraper.DB.sql', 10, 0) WITH NOWAIT;
RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;

USE master

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name='StockScraper')
	CREATE DATABASE StockScraper;

USE StockScraper

RAISERROR ('Update Complete. Please check for errors.', 10, 0) WITH NOWAIT;