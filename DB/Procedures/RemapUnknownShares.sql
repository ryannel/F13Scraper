IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.RemapUnknownShares') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  EXEC sp_Executesql N'CREATE PROCEDURE dbo.RemapUnknownShares AS SET NOCOUNT ON'
GO

ALTER PROCEDURE dbo.RemapUnknownShares
AS

SET NOCOUNT ON

BEGIN TRANSACTION RemapUnknownShares

BEGIN TRY

INSERT INTO 
	Share	
SELECT 
	UnknownShare.FilingId,
	SecurityMap.SecurityId,
	UnknownShare.Number,
	UnknownShare.Type,
	UnknownShare.Value
FROM 
	UnknownShare 
	INNER JOIN SecurityMap
		ON SecurityMap.Cusip = UnknownShare.Cusip

DELETE 
	UnknownShare
FROM 
	UnknownShare 
	INNER JOIN SecurityMap
		ON SecurityMap.Cusip = UnknownShare.Cusip

COMMIT TRANSACTION RemapUnknownShares

END TRY
BEGIN CATCH
  ROLLBACK TRANSACTION RemapUnknownShares
END CATCH  

GO