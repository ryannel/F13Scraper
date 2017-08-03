USE StockScraper

----
-- Compare Hedgefund portfolio, quarter on quarter 
----

DECLARE @FirstMasterIndex VARCHAR(15) = '2016 - QTR4'
DECLARE @SecondMasterIndex VARCHAR(15) = '2016 - QTR3'

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

;WITH Movement AS (
	SELECT
		Security.Name AS Security,
		Security.Exchange,
		Security.Symbol,
		Security.Industry,
		Security.Sector,
		SUM(IIF(MasterIndex.Name = @FirstMasterIndex, CAST(share.Number AS BIGINT), 0)) AS FirstQuarter,
		SUM(IIF(MasterIndex.Name = @SecondMasterIndex, CAST(share.Number AS BIGINT), 0)) AS SecondQuarter,
		SUM(IIF(MasterIndex.Name = @FirstMasterIndex, CAST(share.Number AS BIGINT), 0)) AS NumberOfShares,
		SUM(IIF(MasterIndex.Name = @FirstMasterIndex, CAST(share.value AS BIGINT), 0)) * 1000 AS TotalValue
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
		MasterIndex.Name IN (@FirstMasterIndex, @SecondMasterIndex)
	GROUP BY
		Security.Name,
		Security.Exchange,
		Security.Symbol,
		Security.Industry,
		Security.Sector,
		HedgeFund.HedgeFundId
)

SELECT
	Movement.Security,
	Movement.Exchange,
	Movement.Symbol,
	Movement.Industry,
	Movement.Sector,
	FORMAT(SUM(IIF(Movement.FirstQuarter > Movement.SecondQuarter AND Movement.SecondQuarter != 0, 1, 0)), '#,##0') AS HedgeFundsIncreasing,
	FORMAT(SUM(IIF(Movement.FirstQuarter < Movement.SecondQuarter, 1, 0)), '#,##0') AS HedgeFundsDecreasing,
	FORMAT(SUM(IIF(Movement.FirstQuarter > 0 AND Movement.SecondQuarter = 0, 1, 0)), '#,##0') AS HedgeFundsEntering,
	FORMAT(SUM(IIF(Movement.FirstQuarter = Movement.SecondQuarter, 1, 0)), '#,##0') AS HedgeFundsHolding,
	FORMAT(SUM(Movement.NumberOfShares), '$ #,##0.00') AS TotalNumberOfShares,
	FORMAT(SUM(Movement.TotalValue), '$ #,##0.00') AS TotalValue
FROM 
	Movement
GROUP BY
	Movement.Security,
	Movement.Exchange,
	Movement.Symbol,
	Movement.Industry,
	Movement.Sector
ORDER BY
	SUM(IIF(Movement.FirstQuarter < Movement.SecondQuarter, 1, 0)) DESC