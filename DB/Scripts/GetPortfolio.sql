----
-- Get all the securities owned by a HedgeFund for a Quarter
----

DECLARE @HedgeFundId VARCHAR(255) = 'AJO, LP'
DECLARE @MasterIndex VARCHAR(15) = '2017 - QTR1'

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

select
	HedgeFund.Name AS HedgeFundName,
	Security.Name AS Security,
	Security.Exchange,
	Security.Symbol,
	'$ ' + FORMAT(SUM(share.value), 'N2') AS Value
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
	HedgeFund.Name = @HedgeFundId
	AND MasterIndex.Name = @MasterIndex
GROUP BY
	HedgeFund.Name,
	Security.Name,
	Security.Exchange,
	Security.Symbol
ORDER BY
	SUM(share.value) DESC