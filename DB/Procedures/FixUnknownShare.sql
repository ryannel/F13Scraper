USE StockScraper

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.FixUnknownShare') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  EXEC sp_Executesql N'CREATE PROCEDURE dbo.FixUnknownShare AS SET NOCOUNT ON'
GO

ALTER PROCEDURE dbo.FixUnknownShare
	@cusip varchar(255) = NULL,
	@name varchar(255) = NULL,
	@symbol varchar(255) = NULL,
	@exchange VARCHAR(255) = NULL
AS

DECLARE @securityId INT

BEGIN TRANSACTION FixUnknownShare
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
SET NOCOUNT ON

BEGIN TRY

-- Get Security ID if existing, else add one
SELECT @securityId = SecurityId FROM Security WHERE Symbol = @symbol AND Exchange = @exchange

IF @securityId IS NULL 
BEGIN
	INSERT INTO Security VALUES(@name, @symbol, @exchange)
	SELECT @securityId = SCOPE_IDENTITY()
END

-- If no Security Map exists for this Cusip and Security ID, add one. 
IF NOT EXISTS (SELECT * FROM SecurityMap Where Cusip = @cusip)
BEGIN
	INSERT INTO SecurityMap VALUES (@name, @cusip, @securityId)
END

-- Add the shares from the Unknown table
INSERT INTO 
	Share 
SELECT 
	FilingId, 
	@securityId, 
	Number, 
	Type, 
	Value 
FROM 
	UnknownShare 
WHERE 
	Cusip = @cusip

-- Delete 
DELETE FROM 
	UnknownShare
WHERE 
	cusip = @cusip

COMMIT TRANSACTION FixUnknownShare

END TRY
BEGIN CATCH
  ROLLBACK TRANSACTION FixUnknownShare
END CATCH  

GO