----
-- Delete all records except for Securities and SecurityMaps
----

USE StockScraper

truncate table Registration;
truncate table UnknownShare;
truncate table Share;
DELETE FROM HedgeFund;

DELETE FROM Filing;
DELETE FROM MasterIndex;

DBCC CHECKIDENT ('[Registration]', RESEED, 0);
DBCC CHECKIDENT ('[UnknownShare]', RESEED, 0);
DBCC CHECKIDENT ('[Share]', RESEED, 0);
DBCC CHECKIDENT ('[HedgeFund]', RESEED, 0);
DBCC CHECKIDENT ('[Filing]', RESEED, 0);
DBCC CHECKIDENT ('[MasterIndex]', RESEED, 0);
