----
-- View the Movement of Hedge Fund Investments per Security
----

DECLARE @StartMasterIndex VARCHAR(15) = '2016 - QTR3'
DECLARE @EndMasterIndex VARCHAR(15) = '2016 - QTR4'

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @NumHedgeFunds INT;

SELECT 
	@NumHedgeFunds = COUNT(*) 
FROM 
	HedgeFund 
	INNER JOIN Filing
		ON Filing.HedgeFundId = HedgeFund.HedgeFundId
	INNER JOIN MasterIndex
		ON MasterIndex.MasterIndexId = Filing.MasterIndexId
WHERE 
	MasterIndex.Name = @StartMasterIndex

;WITH Movement AS (
	SELECT
		Security.Name AS Security,
		Security.Exchange,
		Security.Symbol,
		SUM(IIF(MasterIndex.Name = @EndMasterIndex, CAST(share.Number AS BIGINT), 0)) AS FirstQuarter,
		SUM(IIF(MasterIndex.Name = @StartMasterIndex, CAST(share.Number AS BIGINT), 0)) AS SecondQuarter,
		SUM(IIF(MasterIndex.Name = @EndMasterIndex, CAST(share.Number AS BIGINT), 0)) AS NumberOfShares,
		SUM(IIF(MasterIndex.Name = @EndMasterIndex, CAST(share.value AS BIGINT), 0)) * 1000 AS TotalValue
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
		MasterIndex.Name IN (@EndMasterIndex, @StartMasterIndex)
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
	SUM(Movement.TotalValue) AS TotalValue,
	CAST(SUM(IIF(Movement.FirstQuarter > 0 AND Movement.SecondQuarter = 0, 1, 0)) * 1.0 / @NumHedgeFunds * 100 AS DECIMAL(6,4)) AS PercentOfHedgeFundsEntering
FROM 
	Movement
GROUP BY
	Movement.Security,
	Movement.Exchange,
	Movement.Symbol
ORDER BY
	HedgeFundsEntering DESC