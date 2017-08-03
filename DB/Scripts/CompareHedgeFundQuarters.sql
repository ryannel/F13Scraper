----
-- Compare Hedgefund portfolio, quarter on quarter 
----

DECLARE @HedgeFundName VARCHAR(255) = 'Appaloosa LP'
DECLARE @FirstMasterIndex VARCHAR(15) = '2016 - QTR4'
DECLARE @SecondMasterIndex VARCHAR(15) = '2016 - QTR3'

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT
	HedgeFund.Name AS HedgeFundName,
	Security.Name AS Security,
	Security.Exchange,
	Security.Symbol,
	SUM(IIF(MasterIndex.Name = @FirstMasterIndex, share.Number, '0')) AS NumberFirstQuater,
	SUM(IIF(MasterIndex.Name = @SecondMasterIndex, share.Number, '0')) AS NumberSecondQuater,
	SUM(IIF(MasterIndex.Name = @FirstMasterIndex, share.Number, '0')) - SUM(IIF(MasterIndex.Name = @SecondMasterIndex, share.Number, '0')) AS NumberMovement,
	'$ ' + FORMAT(SUM(IIF(MasterIndex.Name = @FirstMasterIndex, share.value, '0')) * 1000, 'N2') AS ValueFirstQuater,
	'$ ' + FORMAT(SUM(IIF(MasterIndex.Name = @SecondMasterIndex, share.value, '0')) * 1000, 'N2') AS ValueSecondQuater,
	'$ ' + FORMAT((SUM(IIF(MasterIndex.Name = @FirstMasterIndex, share.value, '0')) - SUM(IIF(MasterIndex.Name = @SecondMasterIndex, share.value, '0'))) * 1000, 'N2') AS ValueMovement
FROM 
	HedgeFund
	INNER JOIN Filing
		ON Filing.HedgeFundId = HedgeFund.HedgeFundId
	INNER JOIN Share
		ON Filing.FilingId = Share.FilingId
	INNER JOIN Security
		ON Share.SecurityId = Security.SecurityId
	INNER JOIN MasterIndex
		ON MasterIndex.MasterIndexId = Filing.MasterIndexId
WHERE
	HedgeFund.Name = @HedgeFundName
	AND MasterIndex.Name IN (@FirstMasterIndex, @SecondMasterIndex)
GROUP BY
	HedgeFund.Name,
	Security.Name,
	Security.Exchange,
	Security.Symbol
ORDER BY
	SUM(IIF(MasterIndex.Name = @FirstMasterIndex, share.value, '0')) - SUM(IIF(MasterIndex.Name = @SecondMasterIndex, share.value, '0')) DESC