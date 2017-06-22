----
-- View the Movement of Hedge Fund Investments per Security
----

DECLARE @FirstMasterIndex VARCHAR(15) = '2017 - QTR1'
DECLARE @SecondMasterIndex VARCHAR(15) = '2016 - QTR4'

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

;WITH Movement AS (
	SELECT
		Security.Name AS Security,
		Security.Exchange,
		Security.Symbol,
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
		HedgeFund.HedgeFundId
)

SELECT
	Movement.Security,
	Movement.Exchange,
	Movement.Symbol,
	SUM(IIF(Movement.FirstQuarter > Movement.SecondQuarter AND Movement.SecondQuarter != 0, 1, 0)) AS HedgeFundsIncreasing,
	SUM(IIF(Movement.FirstQuarter < Movement.SecondQuarter, 1, 0)) AS HedgeFundsDecreasing,
	SUM(IIF(Movement.FirstQuarter > 0 AND Movement.SecondQuarter = 0, 1, 0)) AS HedgeFundsEntering,
	SUM(IIF(Movement.FirstQuarter = Movement.SecondQuarter, 1, 0)) AS HedgeFundsHolding,
	SUM(Movement.NumberOfShares) AS TotalNumberOfShares,
	SUM(Movement.TotalValue) AS TotalValue
FROM 
	Movement
GROUP BY
	Movement.Security,
	Movement.Exchange,
	Movement.Symbol
ORDER BY
	HedgeFundsIncreasing DESC