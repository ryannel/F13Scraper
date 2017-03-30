-- ====================================================
-- Baskerville API DB Release
-- 2016-09-02 12:40:05
-- ====================================================

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'GameMonitor') USE GameMonitor;
GO
IF (db_name() <> 'GameMonitor') RAISERROR('Error, ''USE GameMonitor'' failed!  Killing the SPID now.',22,127) WITH LOG;
SET NOCOUNT ON;

RAISERROR ('Update Started:', 10, 0) WITH NOWAIT;

-- =========================
-- File Path: ./Tables\tb_FollowingPlayers.TAB.sql
-- =========================

RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;
RAISERROR (' EXECUTING: ./Tables\tb_FollowingPlayers.TAB.sql', 10, 0) WITH NOWAIT;
RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE Name = 'tb_FollowingPlayers')
BEGIN
    CREATE TABLE tb_FollowingPlayer(
		FollowingPlayerId INT NOT NULL PRIMARY KEY IDENTITY(1,1),
        PlayerAccountKey INT NOT NULL,
        ModuleId INT NOT NULL,
        StartDate SMALLDATETIME NOT NULL,
        StartReason VARCHAR(MAX),
        StartUser VARCHAR(255) NOT NULL,
        EndDate SMALLDATETIME, 
        EndReason VARCHAR(MAX),
        EndUser VARCHAR(255),
        CONSTRAINT fk_FollowingPlayers_PlayerAccount FOREIGN KEY (PlayerAccountKey) REFERENCES tb_Dim_PlayerAccount(PlayerAccountKey), 
        CONSTRAINT fk_FollowingPlayers_ModuleSpecification FOREIGN KEY (ModuleId) REFERENCES tb_Mon_ModuleSpecification(ModuleId)
    )
END
GO


-- =========================
-- File Path: ./Procedures\pr_AddFollowingPlayer.sql
-- =========================

RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;
RAISERROR (' EXECUTING: ./Procedures\pr_AddFollowingPlayer.sql', 10, 0) WITH NOWAIT;
RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.pr_AddFollowingPlayer') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  EXEC sp_Executesql N'CREATE PROCEDURE dbo.pr_AddFollowingPlayer AS SET NOCOUNT ON'
GO

ALTER PROCEDURE dbo.pr_AddFollowingPlayer @LoginName VARCHAR(255) = NULL, @RegistrationCasinoId INT = NULL, @ModuleId INT = NULL, @StartReason VARCHAR(max) = NULL, @StartUser VARCHAR(255) = NULL
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

DECLARE @PlayerAccountKey INT = NULL

SELECT @PlayerAccountKey = PlayerAccountKey FROM tb_Dim_PlayerAccount WHERE LoginName = @LoginName AND RegistrationCasinoId = @RegistrationCasinoId

INSERT INTO dbo.tb_FollowingPlayer 
    (PlayerAccountKey, ModuleId, StartDate, StartReason, StartUser) 
    VALUES(@PlayerAccountKey, @ModuleId, GETDATE(), @StartReason, @StartUser) 

GO

GRANT EXECUTE ON dbo.pr_AddFollowingPlayer TO GameMonitoringUser
GRANT EXECUTE ON dbo.pr_AddFollowingPlayer TO [iom\support services - Game Design] 
GRANT ALTER ON dbo.pr_AddFollowingPlayer TO [iom\support services - Game Design] 
GO

-- =========================
-- File Path: ./Procedures\pr_GetDailyModuleProfit.sql
-- =========================

RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;
RAISERROR (' EXECUTING: ./Procedures\pr_GetDailyModuleProfit.sql', 10, 0) WITH NOWAIT;
RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.pr_GetDailyModuleProfit') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  EXEC sp_Executesql N'CREATE PROCEDURE dbo.pr_GetDailyModuleProfit AS SET NOCOUNT ON'
GO

ALTER PROCEDURE dbo.pr_GetDailyModuleProfit @ModuleID INT = NULL, @GamingSystemId INT = NULL, @StartDate DATE = NULL, @EndDate DATE = NULL
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

SELECT 
	ModuleName, 
	casino.GamingSystemName, 
	Day,
  	SUM(NumGames) AS NumGames,
	CONVERT(DECIMAL(20, 2), (SUM(TotalReportCurrencyWager) - SUM(TotalReportCurrencyPayout)) / 100) AS NetProfit
FROM
	dbo.tb_MG_Wager_Day AS wager
	INNER JOIN dbo.tb_Dim_Game AS game
		ON game.GameKey = wager.GameKey
	INNER JOIN dbo.tb_Dim_Casino AS	casino
		ON casino.CasinoKey = wager.CasinoKey
WHERE
    wager.Day between ISNULL(@StartDate, wager.day) and ISNULL(@EndDate, GETDATE())
	AND game.ModuleId = @ModuleID
	AND casino.GamingSystemId = @GamingSystemId
GROUP BY
	ModuleName, 
	casino.GamingSystemName, 
	Day
ORDER BY
	Day;
    
GO

GRANT EXECUTE ON dbo.pr_GetDailyModuleProfit TO GameMonitoringUser
GRANT EXECUTE ON dbo.pr_GetDailyModuleProfit TO [iom\support services - Game Design] 
GRANT ALTER ON dbo.pr_GetDailyModuleProfit TO [iom\support services - Game Design] 
GO


-- =========================
-- File Path: ./Procedures\pr_GetDataIntegrity.sql
-- =========================

RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;
RAISERROR (' EXECUTING: ./Procedures\pr_GetDataIntegrity.sql', 10, 0) WITH NOWAIT;
RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.pr_GetDataIntegrity') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  EXEC sp_Executesql N'CREATE PROCEDURE dbo.pr_GetDataIntegrity AS SET NOCOUNT ON'
GO

ALTER PROCEDURE dbo.pr_GetDataIntegrity
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

SELECT 
	casino.GamingSystemName,
    CONVERT(date, HourMarker) AS Day,
    IIF(
		ISNULL(SUM(CAST(betlog.ArchNumGames AS DECIMAL(18,3))) / SUM(CAST(betlog.GMNumGames AS DECIMAL(18,3))), 0) > 1,
		100,
		CONVERT(DECIMAL(7,2),ISNULL(SUM(CAST(betlog.ArchNumGames AS DECIMAL(18,3))) / SUM(CAST(betlog.GMNumGames AS DECIMAL(18,3))), 0) * 100)
	) AS [OverallIntegrity],
	IIF(
		ISNULL(SUM(CAST(betlog.UpdatedArchNumGames AS DECIMAL(18,3))) / SUM(CAST(betlog.UpdatedGMNumGames AS DECIMAL(18,3))), 0) > 1, 
		100,
		CONVERT(DECIMAL(7,2), ISNULL(SUM(CAST(betlog.UpdatedArchNumGames AS DECIMAL(18,3))) / SUM(CAST(betlog.UpdatedGMNumGames AS DECIMAL(18,3))), 0) * 100)
	) AS [UpdatedIntegrity]
FROM
    dbo.tb_GMM_BetLogHourlyHistory AS betlog
	INNER JOIN
		dbo.vw_GamingSystem AS casino 
			ON casino.GamingSystemId = betlog.GamingServerID
WHERE
    betlog.HourMarker >= DATEADD(MONTH, -1, GETDATE()) 
	AND betlog.HourMarker < CAST(GETDATE() AS DATE)
    AND casino.GamingSystemId NOT IN (531)
GROUP BY
    casino.GamingSystemName, CONVERT(date, betlog.HourMarker)
ORDER BY
    Day,
    casino.GamingSystemName
	
GO

GRANT EXECUTE ON dbo.pr_GetDataIntegrity TO GameMonitoringUser
GRANT EXECUTE ON dbo.pr_GetDataIntegrity TO [iom\support services - Game Design] 
GRANT ALTER ON dbo.pr_GetDataIntegrity TO [iom\support services - Game Design] 
GO

-- =========================
-- File Path: ./Procedures\pr_GetFollowingPlayers.sql
-- =========================

RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;
RAISERROR (' EXECUTING: ./Procedures\pr_GetFollowingPlayers.sql', 10, 0) WITH NOWAIT;
RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.pr_GetFollowingPlayers') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  EXEC sp_Executesql N'CREATE PROCEDURE dbo.pr_GetFollowingPlayers AS SET NOCOUNT ON'
GO

ALTER PROCEDURE dbo.pr_GetFollowingPlayers
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

SELECT
	followingPlayer.FollowingPlayerId,
	player.PlayerAccountKey,
	player.RegistrationCasinoId,
    player.LoginName,
	module.ModuleId,
	module.ModuleName
FROM
    dbo.tb_FollowingPlayer AS followingPlayer
	INNER JOIN tb_Dim_PlayerAccount AS player
		ON followingPlayer.PlayerAccountKey = player.PlayerAccountKey
	INNER JOIN tb_Mon_ModuleSpecification AS module
		ON followingPlayer.ModuleId = module.ModuleId
WHERE
    EndDate IS NULL

GO

GRANT EXECUTE ON dbo.pr_GetFollowingPlayers TO GameMonitoringUser
GRANT EXECUTE ON dbo.pr_GetFollowingPlayers TO [iom\support services - Game Design] 
GRANT ALTER ON dbo.pr_GetFollowingPlayers TO [iom\support services - Game Design] 
GO

-- =========================
-- File Path: ./Procedures\pr_GetGameStreaks.sql
-- =========================

RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;
RAISERROR (' EXECUTING: ./Procedures\pr_GetGameStreaks.sql', 10, 0) WITH NOWAIT;
RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;

-- -----------------------
-- Get current streaks where the streak is longer than @minStreak 
-- and the game has lost more than @minLoss during the streak.
-- -----------------------

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.pr_GetGameStreaks') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  EXEC sp_Executesql N'CREATE PROCEDURE dbo.pr_GetGameStreaks AS SET NOCOUNT ON'
GO

ALTER PROCEDURE dbo.pr_GetGameStreaks @minStreak INT = NULL, @minLoss INT = NULL
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

IF OBJECT_ID('tempdb..#dailyGames') IS NOT NULL 
BEGIN
    DROP TABLE #dailyGames
END

;WITH lostMoneyYesterday AS (
    SELECT DISTINCT
        casino.GamingSystemId, 
        casino.SessionCasinoId, 
        game.ModuleId,
        game.ClientId,
        game.ModuleVersion
    FROM 
        dbo.tb_MG_Wager_Game AS wager
        INNER JOIN dbo.tb_Dim_Game AS game
            ON wager.GameKey = game.GameKey
        INNER JOIN dbo.tb_Dim_Casino AS casino 
            ON wager.CasinoKey = casino.CasinoKey
    WHERE
        CAST(wager.Day AS DATE) = CAST(DATEADD(day, -1, current_timestamp) AS Date)
    GROUP BY
        casino.GamingSystemId, 
        casino.SessionCasinoId,
        game.ModuleId,
        game.ClientId,
        game.ModuleVersion
    HAVING
        SUM(TotalReportCurrencyPayout) > SUM(TotalReportCurrencyWager)
)

SELECT        
    DENSE_RANK() OVER (ORDER BY casino.GamingSystemId, casino.SessionCasinoId, game.ClientId, game.ModuleId, game.ModuleVersion) as [key],
    casino.GamingSystemId, 
    casino.SessionCasinoId, 
	casino.GamingSystemName,
	game.clientName,
    game.ClientId,
    game.ModuleId,
    game.ModuleVersion,
    wager.Day,
    IIF(SUM(wager.TotalReportCurrencyPayout) >= SUM(wager.TotalReportCurrencyWager), 0, 1) AS profitable,
	SUM(wager.TotalReportCurrencyWager) AS TotalWager,
	SUM(wager.TotalReportCurrencyPayout) AS TotalPayout,
	module.TheoreticalPayoutPercentage AS PayoutPercentage,
	module.StandardDeviation AS StandardDeviation,
	SUM(wager.NumGames) AS NumGames
INTO
    #dailyGames
FROM
    dbo.tb_MG_Wager_Game  AS wager
    INNER JOIN dbo.tb_Dim_Casino AS casino 
        ON wager.CasinoKey = casino.CasinoKey
    INNER JOIN dbo.tb_Dim_Game AS game
        ON wager.GameKey = game.GameKey
    INNER JOIN lostMoneyYesterday
        ON game.ModuleId = lostMoneyYesterday.ModuleId
        AND game.ClientId = lostMoneyYesterday.ClientId
        AND game.ModuleVersion = lostMoneyYesterday.ModuleVersion
        AND casino.GamingSystemId = lostMoneyYesterday.GamingSystemId
        AND casino.SessionCasinoId = lostMoneyYesterday.SessionCasinoId
    INNER JOIN dbo.tb_Mon_ModuleSpecification AS module
		ON game.ModuleId = module.ModuleId
WHERE
    CAST(wager.Day AS DATE) BETWEEN CAST(DATEADD(DAY, -40, GETDATE()) AS DATE) AND CAST(GETDATE() AS Date)
GROUP BY
    casino.GamingSystemId, 
    casino.SessionCasinoId, 
    wager.Day,
    game.ClientId,
    game.ModuleId,
    game.ModuleVersion,
	casino.GamingSystemName,
	game.clientName,
	module.TheoreticalPayoutPercentage,
    module.StandardDeviation

CREATE CLUSTERED INDEX ix_temp_dailyGames ON #dailyGames([key], Day, profitable)

SELECT 
	ClientName,
    ModuleId,
    ModuleVersion,
	GamingSystemName,
    GamingSystemId,
    SessionCasinoId, 
    ClientId,
	SUM(TotalWager) AS Wager,
	SUM(TotalPayout) AS Payout,
    COUNT(DISTINCT DAY) AS streakLength,
    CONVERT(DECIMAL(20,2), (SUM(TotalWager) - SUM(TotalPayout)) / 100.0) AS StreakProfit,
	CONVERT(DECIMAL(20,2), (SUM(TotalPayout) / SUM(TotalWager)) * 100.0) AS StreakRTP,
    CONVERT(DECIMAL(20,2), ((PayoutPercentage / 100) + StandardDeviation*1.96/sqrt(SUM(NumGames))) * 100) As UpperBound95
FROM 
    #dailyGames
    INNER JOIN (
        SELECT 
            [key],
            MAX(Day) AS last_profitable
        FROM 
            #dailyGames
        WHERE 
            profitable = 1
        GROUP BY
            [key]
    ) as streak ON streak.[key] = #dailyGames.[key]
WHERE
    Day > last_profitable
GROUP BY
    GamingSystemId, 
    SessionCasinoId, 
    ClientId,
    ModuleId,
    ModuleVersion,
	GamingSystemName,
	ClientName,
	PayoutPercentage,
	StandardDeviation
HAVING 
    (SUM(TotalWager) - SUM(TotalPayout)) / 100 <= @minLoss
    AND COUNT(DISTINCT DAY) >= @minStreak
ORDER BY
    ModuleId

DROP TABLE #dailyGames

GO

GRANT EXECUTE ON dbo.pr_GetGameStreaks TO GameMonitoringUser
GRANT EXECUTE ON dbo.pr_GetGameStreaks TO [iom\support services - Game Design] 
GRANT ALTER ON dbo.pr_GetGameStreaks TO [iom\support services - Game Design] 
GO

-- =========================
-- File Path: ./Procedures\pr_GetLosingGames.sql
-- =========================

RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;
RAISERROR (' EXECUTING: ./Procedures\pr_GetLosingGames.sql', 10, 0) WITH NOWAIT;
RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.pr_GetLosingGames') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  EXEC sp_Executesql N'CREATE PROCEDURE dbo.pr_GetLosingGames AS SET NOCOUNT ON'
GO

ALTER PROCEDURE dbo.pr_GetLosingGames @ProfitThreshold INT = NULL
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

SELECT 
	game.ModuleName, 
	game.ModuleId,
	game.ModuleVersion, 
	SUM(wager.NumGames) AS NumGames,
	SUM(wager.NumGamesWithPayout) AS NumGamesWithPayout,
	CONVERT(DECIMAL(20,2), (SUM(wager.TotalReportCurrencyWager) - SUM(wager.TotalReportCurrencyPayout)) / 100) AS Profit,
	CONVERT(DECIMAL(5,2), health.Health) as Health
FROM 
	tb_dim_game AS game
	INNER JOIN tb_MG_Wager_Game AS wager 
		ON wager.GameKey = game.GameKey
	INNER JOIN tb_Mon_ModuleHealth AS health 
		ON game.ModuleId = health.ModuleId 
		AND game.ModuleVersion = health.ModuleVersion
WHERE
	CAST(wager.Day AS DATE) > ( SELECT TOP 1 Day FROM dbo.tb_Mon_MinReportDate )
GROUP BY
	game.ModuleName, 
	game.ModuleId,
	game.ModuleVersion, 
	health.Health
HAVING
	(SUM(wager.TotalReportCurrencyWager) - SUM(wager.TotalReportCurrencyPayout)) / 100 < @ProfitThreshold
	
GO

GRANT EXECUTE ON dbo.pr_GetLosingGames TO GameMonitoringUser
GRANT EXECUTE ON dbo.pr_GetLosingGames TO [iom\support services - Game Design] 
GRANT ALTER ON dbo.pr_GetLosingGames TO [iom\support services - Game Design] 
GO

-- =========================
-- File Path: ./Procedures\pr_GetLowHealthGames.sql
-- =========================

RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;
RAISERROR (' EXECUTING: ./Procedures\pr_GetLowHealthGames.sql', 10, 0) WITH NOWAIT;
RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.pr_GetLowHealthGames') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  EXEC sp_Executesql N'CREATE PROCEDURE dbo.pr_GetLowHealthGames AS SET NOCOUNT ON'
GO

ALTER PROCEDURE dbo.pr_GetLowHealthGames @HealthThreshold INT = NULL
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

SELECT 
	ModuleName, 
	game.ModuleId,
	game.ModuleVersion, 
	SUM(wager.NumGames) AS NumGames,
	SUM(wager.NumGamesWithPayout) AS NumGamesWithPayout,
	CONVERT(DECIMAL(20,2), (SUM(wager.TotalReportCurrencyWager) - SUM(wager.TotalReportCurrencyPayout)) / 100) AS Profit,
	CONVERT(DECIMAL(5,2), health.Health) AS Health
FROM 
	tb_dim_game AS game WITH (NOLOCK)
	INNER JOIN tb_MG_Wager_Game AS wager 
		ON wager.GameKey = game.GameKey
	INNER JOIN tb_Mon_ModuleHealth AS health  
		ON game.ModuleId = health.ModuleId AND game.ModuleVersion = health.ModuleVersion
WHERE 
	wager.Day > ( SELECT TOP 1 Day FROM dbo.tb_Mon_MinReportDate )
	AND health.Health <= @HealthThreshold
GROUP BY 
	game.ModuleName, 
	game.ModuleId,
	game.ModuleVersion, 
	health.Health
HAVING 
	SUM(wager.NumGames) > 1000

GO

GRANT EXECUTE ON dbo.pr_GetLowHealthGames TO GameMonitoringUser
GRANT EXECUTE ON dbo.pr_GetLowHealthGames TO [iom\support services - Game Design] 
GRANT ALTER ON dbo.pr_GetLowHealthGames TO [iom\support services - Game Design] 
GO

-- =========================
-- File Path: ./Procedures\pr_GetPlayerPerformance.sql
-- =========================

RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;
RAISERROR (' EXECUTING: ./Procedures\pr_GetPlayerPerformance.sql', 10, 0) WITH NOWAIT;
RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.pr_GetPlayerPerformance') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  EXEC sp_Executesql N'CREATE PROCEDURE dbo.pr_GetPlayerPerformance AS SET NOCOUNT ON'
GO

ALTER PROCEDURE dbo.pr_GetPlayerPerformance @LoginName NVARCHAR(512) = NULL, @CasinoId INT = NULL, @ModuleID INT = NULL
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

DECLARE @StartDate SMALLDATETIME = CAST(DATEADD(DAY, -90, GETDATE()) AS DATE)
DECLARE @EndDate SMALLDATETIME = CAST(GETDATE() AS DATE)

DECLARE @PlayerAccountKey INT = (SELECT TOP 1 PlayerAccountKey FROM dbo.tb_Dim_PlayerAccount WHERE LoginName = @LoginName AND RegistrationCasinoID = @CasinoId)

;WITH dateRange AS (
	SELECT 
		CAST(DATEADD(DAY, numbers.number+1, @StartDate) AS SMALLDATETIME) AS Date
	From 
		master..spt_values AS numbers
	WHERE 
		numbers.TYPE = 'p'
		AND DATEADD(DAY, numbers.number+1, @StartDate) <= @EndDate
),

deposits AS (
	SELECT 
		dateRange.Date AS Day,
		CONVERT(DECIMAL(20,2), SUM(ISNULL(ReportCurrencyAmount, 0)) / 100) AS deposit
	FROM
		dateRange
		LEFT JOIN tb_PlayerPurchases as deposit
			ON CAST(CAST(deposit.UTCPurchaseTime AS DATE) AS SMALLDATETIME) = dateRange.Date
			AND PlayerAccountKey = @PlayerAccountKey
	GROUP BY
		dateRange.Date
),

cashinRequests AS (
	SELECT 
		dateRange.Date AS Day,
		CONVERT(DECIMAL(20,2), SUM(ISNULL(ReportCurrencyChangeAmount, 0)) / 100) AS cashinRequest
	FROM
		dateRange
		LEFT JOIN tb_PlayerCashinLog AS cashinRequest
			ON CAST(CAST(cashinRequest.PendingCashinUTCTime AS DATE) AS SMALLDATETIME) = dateRange.Date
			AND PlayerAccountKey = @PlayerAccountKey
	GROUP BY
		dateRange.Date
),

processedCashins AS (
	SELECT 
		dateRange.Date AS Day,
		CONVERT(DECIMAL(20,2), SUM(ISNULL(processedCashin.ReportCurrencyChangeAmount, 0)) / 100) AS processedCashin
	FROM
		dateRange
		LEFT JOIN tb_PlayerProcessedCashins AS processedCashin
			ON CAST(CAST(processedCashin.UTCTIME AS DATE) AS SMALLDATETIME) = dateRange.Date
			AND PlayerAccountKey = @PlayerAccountKey
	GROUP BY
		dateRange.Date
),

wagers AS (
	SELECT 
		dateRange.Date AS Day,
		SUM(ISNULL(wager.NumGames, 0)) AS NumGames,
		CONVERT(DECIMAL(20, 2), SUM(ISNULL(wager.TotalReportCurrencyWager, 0)) / 100) AS Wager,
		CONVERT(DECIMAL(20, 2), SUM(ISNULL(wager.TotalReportCurrencyPayout,0)) / SUM(ISNULL(wager.TotalReportCurrencyWager, 1))) * 100 AS RTP,
		CONVERT(DECIMAL(20, 2), (SUM(SUM(ISNULL(wager.TotalReportCurrencyPayout,0))) OVER(ORDER BY dateRange.Date) - SUM(SUM(ISNULL(wager.TotalReportCurrencyWager, 0))) OVER(ORDER BY dateRange.Date)) / 100) AS CumulativeProfit,
		IIF (
			SUM(ISNULL(wager.TotalReportCurrencyPayout,0)) - SUM(ISNULL(wager.TotalReportCurrencyWager, 0)) < 0,
			0.00,
			CONVERT(DECIMAL(20, 2), (SUM(ISNULL(wager.TotalReportCurrencyPayout,0)) - SUM(ISNULL(wager.TotalReportCurrencyWager, 0))) / 100)
		) AS Profit,
		IIF (
			SUM(ISNULL(wager.TotalReportCurrencyPayout,0)) - SUM(ISNULL(wager.TotalReportCurrencyWager, 0)) > 0,
			0.00,
			CONVERT(DECIMAL(20, 2), (SUM(ISNULL(wager.TotalReportCurrencyPayout,0)) - SUM(ISNULL(wager.TotalReportCurrencyWager, 0))) / 100)
		) AS Loss
	FROM 
		dateRange
		LEFT JOIN dbo.tb_MG_Wager_Day AS wager
			ON dateRange.Date = wager.Day 
			AND wager.PlayerAccountKey = @PlayerAccountKey
		LEFT JOIN dbo.tb_Dim_Game AS game 
			ON game.GameKey = wager.GameKey
	WHERE 
		game.ModuleID = @ModuleID 
		OR game.ModuleID IS NULL
	GROUP BY
		dateRange.Date
)

SELECT
	@PlayerAccountKey AS PlayerAccountKey,
	@LoginName AS LoginName,
	@ModuleID AS ModuleId,
	wagers.Day,
	wagers.NumGames,
	wagers.Wager,
	wagers.RTP,
	wagers.CumulativeProfit,
	wagers.Profit,
	wagers.Loss,
	cashinRequests.CashinRequest,
	processedCashins.ProcessedCashin,
	deposits.Deposit
FROM
	wagers
	INNER JOIN processedCashins
		ON processedCashins.Day = wagers.Day
	INNER JOIN cashinRequests
		ON cashinRequests.Day = wagers.Day
	INNER JOIN deposits
		ON deposits.Day = wagers.Day

GO

GRANT EXECUTE ON dbo.pr_GetPlayerPerformance TO GameMonitoringUser
GRANT EXECUTE ON dbo.pr_GetPlayerPerformance TO [iom\support services - Game Design] 
GRANT ALTER ON dbo.pr_GetPlayerPerformance TO [iom\support services - Game Design] 
GO

-- =========================
-- File Path: ./Procedures\pr_GetPlayerStreaks.sql
-- =========================

RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;
RAISERROR (' EXECUTING: ./Procedures\pr_GetPlayerStreaks.sql', 10, 0) WITH NOWAIT;
RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.pr_GetPlayerStreaks') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  EXEC sp_Executesql N'CREATE PROCEDURE dbo.pr_GetPlayerStreaks AS SET NOCOUNT ON'
GO

ALTER PROCEDURE dbo.pr_GetPlayerStreaks @minStreak INT = NULL, @minProfit INT = NULL
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

IF OBJECT_ID('tempdb..#madeMoneyYesterday') IS NOT NULL 
BEGIN
    DROP TABLE #madeMoneyYesterday
END

IF OBJECT_ID('tempdb..#dailyGames') IS NOT NULL 
BEGIN
    DROP TABLE #dailyGames
END

SELECT
	wager.PlayerAccountKey,
	game.ModuleId,
	game.ClientId,
	game.ModuleVersion
INTO 
	#madeMoneyYesterday
FROM
	dbo.tb_MG_Wager_Day	as wager
	INNER JOIN dbo.tb_Dim_Game AS game
		ON game.GameKey	= wager.GameKey
WHERE
	CAST(wager.Day AS DATE) = CAST(DATEADD(DAY, -1, GETDATE()) AS DATE)
GROUP BY
	wager.DAY,
	wager.PlayerAccountKey,
	game.ModuleId,
	game.ModuleVersion,
	game.ClientId
HAVING
	SUM(wager.TotalPayout) >= SUM(wager.TotalWager)

CREATE CLUSTERED INDEX ix_temp_madeMoneyYesterday ON #madeMoneyYesterday(ModuleId, ClientId, ModuleVersion, PlayerAccountKey);

SELECT
	DENSE_RANK() OVER (ORDER BY player.PlayerAccountKey, game.ModuleId, game.ModuleVersion, game.ClientId) as [Key],
	wager.DAY,
	player.LoginName,
	casino.GamingSystemName,
	game.ClientName,
	game.ClientId,
	SUM(wager.TotalReportCurrencyPayout) AS Payout,
	SUM(wager.TotalReportCurrencyWager) AS Wager,
	(SUM(wager.TotalReportCurrencyPayout) - SUM(wager.TotalReportCurrencyWager)) / 100.0 AS Profit,
    IIF(SUM(wager.TotalReportCurrencyPayout) >= SUM(wager.TotalReportCurrencyWager), 1, 0) AS Profitable,
	SUM(wager.NumGames) as numGames
INTO 
	#dailyGames
FROM 
	dbo.tb_MG_Wager_Day	as wager
	INNER JOIN dbo.tb_Dim_Game AS game
		ON wager.GameKey =	game.GameKey
	INNER JOIN #madeMoneyYesterday
		ON wager.PlayerAccountKey = #madeMoneyYesterday.PlayerAccountKey
		AND game.ModuleId = #madeMoneyYesterday.ModuleId
		AND game.ClientId = #madeMoneyYesterday.ClientId
		AND game.ModuleVersion = #madeMoneyYesterday.ModuleVersion
	INNER JOIN dbo.tb_Dim_PlayerAccount AS player
        ON player.PlayerAccountKey = #madeMoneyYesterday.PlayerAccountKey
	INNER JOIN dbo.tb_Dim_Casino AS	casino
        ON casino.CasinoKey = wager.CasinoKey
WHERE
	CAST(wager.Day AS DATE) BETWEEN CAST(DATEADD(DAY, -40, GETDATE()) AS DATE) AND CAST(DATEADD(DAY, -1, GETDATE()) AS Date)
GROUP BY
	wager.DAY,
	player.PlayerAccountKey,
	player.LoginName,
	game.ClientName,
	casino.GamingSystemName,
	game.ModuleId, 
	game.ModuleVersion, 
	game.ClientId

CREATE CLUSTERED INDEX ix_temp_dailyGames ON #dailyGames([key], Day, profitable);

SELECT 
    LoginName,
    GamingSystemName,
	ClientName,
	ClientId,
	COUNT(DISTINCT DAY) AS StreakLength,
    CONVERT(DECIMAL(12,2), SUM(profit)) AS StreakProfit,
	CONVERT(DECIMAL(12,2), SUM(wager)) AS SumWager,
	SUM(numGames) as NumGames,
	LastLoss AS LastLoss
FROM 
    #dailyGames
    INNER JOIN (
        SELECT 
            [Key],
            MAX(Day) AS LastLoss
        FROM 
            #dailyGames
        WHERE 
            profitable = 0
        GROUP BY
            [key]
    ) as streak ON streak.[Key] = #dailyGames.[Key]
WHERE
    Day > lastLoss
GROUP BY
    LoginName, 
    GamingSystemName, 
    ClientName,
	lastLoss,
	ClientId
HAVING 
    SUM(profit) >= @minProfit
    AND COUNT(DISTINCT DAY) >= @minStreak
ORDER BY
	SUM(profit) DESC
    
DROP TABLE #madeMoneyYesterday
DROP TABLE #dailyGames
    
GO

GRANT EXECUTE ON dbo.pr_GetPlayerStreaks TO GameMonitoringUser
GRANT EXECUTE ON dbo.pr_GetPlayerStreaks TO [iom\support services - Game Design] 
GRANT ALTER ON dbo.pr_GetPlayerStreaks TO [iom\support services - Game Design] 
GO

-- =========================
-- File Path: ./Procedures\pr_GetPlayersWithLargestProfit.sql
-- =========================

RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;
RAISERROR (' EXECUTING: ./Procedures\pr_GetPlayersWithLargestProfit.sql', 10, 0) WITH NOWAIT;
RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.pr_GetPlayersWithLargestProfit') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  EXEC sp_Executesql N'CREATE PROCEDURE dbo.pr_GetPlayersWithLargestProfit AS SET NOCOUNT ON'
GO

ALTER PROCEDURE dbo.pr_GetPlayersWithLargestProfit @StartDate SMALLDATETIME = NULL, @EndDate SMALLDATETIME = NULL
AS

SELECT @endDate = ISNULL(@EndDate, CAST(GETDATE() -1 AS SMALLDATETIME))

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

;WITH WorstPlayers AS (
    SELECT TOP 10
        PlayerAccountKey
    FROM
        dbo.tb_MG_Wager_Day
    WHERE
    	Day >= @StartDate
    GROUP BY
    	PlayerAccountKey, 
        CasinoKey,
        GameKey
    ORDER BY
	    (SUM(TotalReportCurrencyWager) - SUM(TotalReportCurrencyPayout))
)

SELECT top 10
	player.LoginName,
	casino.GamingSystemName,
	game.ModuleId,
    game.ModuleVersion,
    game.ClientId,
	game.ClientName,
    player.RegistrationCasinoId AS CasinoId,
    
	CONVERT(DECIMAL(20, 2), SUM(
        IIF (
            wager.Day = CAST(GETDATE() -1 AS DATE),
            wager.TotalReportCurrencyWager - wager.TotalReportCurrencyPayout,
            0
        )
    ) / 100) AS ProfitYesterday,
    
    CONVERT(DECIMAL(20, 2), SUM(
        IIF(
            wager.Day BETWEEN CAST(GETDATE() -8 AS DATE) AND GETDATE(),
            wager.TotalReportCurrencyWager - wager.TotalReportCurrencyPayout,
            0
        )
    ) / 100) AS ProfitLastWeek,
    
    CONVERT(DECIMAL(20, 2), SUM(
        IIF(
            wager.Day BETWEEN CAST(GETDATE() -31 AS DATE) AND GETDATE(),
            wager.TotalReportCurrencyWager - wager.TotalReportCurrencyPayout,
            0
        )
    ) / 100) AS ProfitLastMonth,
    
    CONVERT(DECIMAL(20, 2), (SUM(TotalReportCurrencyWager) - SUM(TotalReportCurrencyPayout)) / 100) AS ProfitLifeTime
FROM
    dbo.tb_MG_Wager_Day	AS wager
	INNER JOIN tb_Dim_PlayerAccount AS player
		ON wager.PlayerAccountKey = player.PlayerAccountKey
	INNER JOIN tb_Dim_Game AS game
		ON game.GameKey = wager.GameKey
	INNER JOIN tb_Dim_Casino AS casino
		ON casino.CasinoKey = wager.CasinoKey
    INNER JOIN WorstPlayers
        ON WorstPlayers.PlayerAccountKey = wager.PlayerAccountKey
GROUP BY
	wager.PlayerAccountKey, 
	player.LoginName,
	casino.GamingSystemName,
	game.ModuleId,
	game.ClientName,
	game.ClientId,
    game.ModuleVersion,
    player.RegistrationCasinoId
ORDER BY
	ProfitLastWeek;
 
GO

GRANT EXECUTE ON dbo.pr_GetPlayersWithLargestProfit TO GameMonitoringUser
GRANT EXECUTE ON dbo.pr_GetPlayersWithLargestProfit TO [iom\support services - Game Design] 
GRANT ALTER ON dbo.pr_GetPlayersWithLargestProfit TO [iom\support services - Game Design] 
GO

-- =========================
-- File Path: ./Procedures\pr_GetProgressivePayouts.sql
-- =========================

RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;
RAISERROR (' EXECUTING: ./Procedures\pr_GetProgressivePayouts.sql', 10, 0) WITH NOWAIT;
RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.pr_GetProgressivePayouts') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  EXEC sp_Executesql N'CREATE PROCEDURE dbo.pr_GetProgressivePayouts AS SET NOCOUNT ON'
GO

ALTER PROCEDURE dbo.pr_GetProgressivePayouts @ModuleId INT = NULL, @GamePayId INT = NULL
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON
DECLARE @CEPDay date = '2012-01-01'

;WITH cepMaxBet AS (
	SELECT DISTINCT 
		wager.Day, 
		wager.CurrencyKey,
		(CASE WHEN cep.MaxBet IS NULL 
			OR NOT (
                    (curr.ISOCurrency IN ('THB') AND wager.Day >= '2016/4/12')
                    OR (curr.ISOCurrency IN ('SEK') AND wager.Day >= '2016/3/22')
                    OR (curr.ISOCurrency IN ('CNY') AND wager.Day >= '2016/4/14')
                    OR (curr.ISOCurrency IN ('NOK') AND wager.Day >= '2016/3/15')
                    OR (curr.ISOCurrency IN ('RUB') AND wager.Day >= '2016/4/19')
                    OR (curr.ISOCurrency IN ('PLN','UAH','RSD','CZK','BRL','ARS','HUF','AMD','RON','MYR') AND wager.Day >= '2016/4/28')
                    OR (curr.ISOCurrency IN ('MXN','JPY','GEL','KES','NAD','INR','DKK','TRY','ZAR','PHP') AND wager.Day >= '2016/5/5')
                    OR (curr.ISOCurrency IN ('NGN','KRW','BWP','XAF','IDR','VND','LTL','GHS','BGN') AND wager.Day >= '2016/5/3')
            )
            THEN spec.MaxBet 
            ELSE cep.MaxBet END
		) as MaxBet
	FROM tb_MG_ProgressiveWager wager 
		INNER JOIN tb_Dim_Game AS game 
			ON wager.GameKey = game.GameKey
		INNER JOIN tb_Dim_Casino AS casino 
			ON wager.CasinoKey = casino.CasinoKey
		INNER JOIN tb_Dim_Currency AS curr 
			ON wager.CurrencyKey = curr.CurrencyKey
		INNER JOIN tb_Mon_ProgressiveSpecification AS spec
			ON spec.ModuleId = game.ModuleId 
			AND spec.GamePayID = @GamePayId
		LEFT JOIN tb_CurrencyEquivalentProgressiveBetSetting AS cep
			ON cep.GamingSystemID = casino.GamingSystemID 
			AND cep.ModuleID = game.ModuleID 
			AND cep.CurrencyKey = wager.CurrencyKey
	WHERE 
		game.ModuleId = @ModuleId
		AND wager.Day >= @CEPDay
),

wager as (
	SELECT
		game.ClientName,
		wager.Day,
		wager.CurrencyKey,
		game.ModuleVersion,
		SUM(NumEligibleGames) AS EligibleGames,
		SUM(TotalWager) AS TotalWager,
		SUM(wins.NumHits) AS NumHits,
		cep.MaxBet AS MaxBet,
		spec.NumTriggerGames AS NumTriggerGames,
		spec.ProbabilityScalingRule,
		IIF(
			ProbabilityScalingRule = -1, 
			(SUM(SUM(wager.TotalWager)) OVER (PARTITION BY wager.CurrencyKey, game.ModuleVersion ORDER BY wager.Day) * 1.0 /
				SUM(SUM(wager.NumEligibleGames)) OVER (PARTITION BY wager.CurrencyKey, game.ModuleVersion ORDER BY wager.Day)) * 1.0 /
				cep.MaxBet,
				1
		) AS WagerScale
	FROM 
		tb_MG_ProgressiveWager AS wager 
		INNER JOIN tb_Dim_Game AS game 
			ON wager.GameKey = game.GameKey
		INNER JOIN tb_Dim_Casino AS casino 
			ON wager.CasinoKey = casino.CasinoKey
		LEFT JOIN (
			SELECT 
				prog.ProgressiveWagerKey,
				COUNT(prog.PayoutAmount) AS NumHits,
				SUM(CAST(prog.PayoutAmount AS BIGINT)) AS PayoutAmount
			FROM 
				[dbo].[tb_MG_ProgressiveWin] AS prog 
			WHERE 
				GamePayID = @GamePayId
			GROUP BY 
				prog.ProgressiveWagerKey
		) wins 
			ON wins.ProgressiveWagerKey = wager.ProgressiveWagerKey
		INNER JOIN tb_Mon_ProgressiveSpecification AS spec
			ON spec.ModuleId = game.ModuleId AND spec.GamePayID = @GamePayId
		INNER JOIN cepMaxBet AS cep
			ON cep.Day = wager.Day 
			AND cep.CurrencyKey = wager.CurrencyKey
	WHERE 
		game.ModuleID = @ModuleId
		AND wager.Day >= @CEPDay
	GROUP BY 
		game.ClientName,
		wager.Day,
		wager.CurrencyKey,
		game.ModuleVersion,
		cep.MaxBet,
		spec.NumTriggerGames,
		spec.ProbabilityScalingRule
),

currencies AS (
	SELECT
		Day,
		ClientName,
		SUM(SUM(EligibleGames)) OVER (ORDER BY Day) As CumulativeEligibleGames,
		SUM(SUM(TotalWager)) OVER (ORDER BY Day) AS CumulativeTotalWager,
		SUM(SUM(EligibleGames * WagerScale / NumTriggerGames)) OVER (ORDER BY Day) as PredictedWins,
		SUM(SUM(NumHits)) OVER (ORDER BY Day) AS ActualWins,
		CAST(SUM(SUM(EligibleGames * WagerScale / NumTriggerGames)) OVER (ORDER BY Day) AS DECIMAL(25, 20)) / SUM(SUM(EligibleGames)) OVER (ORDER BY Day) AS WinRatio
	FROM 
		wager
	GROUP BY 
		Day,
		ClientName
)

SELECT
	ClientName,
    @ModuleId AS ModuleId,
    @GamePayId AS GamePayId,
	Day,
	CumulativeEligibleGames AS NumGames,
	CONVERT(DECIMAL(20,5), PredictedWins) AS PredictedWins,
	ISNULL(ActualWins, 0) AS ActualWins,
	CONVERT(DECIMAL(20,5), CONVERT(DECIMAL(20,2), CumulativeTotalWager) / 100) AS TotalWager,
    CONVERT(DECIMAL(20,5), CumulativeEligibleGames * (WinRatio - (1.96 * SQRT(CAST((WinRatio * (1 - WinRatio)) AS DECIMAL(38, 20)) / CumulativeEligibleGames)))) AS LowerBound95,
    CONVERT(DECIMAL(20,5), CumulativeEligibleGames * (WinRatio + (1.96 * SQRT(CAST((WinRatio * (1 - WinRatio)) AS DECIMAL(38, 20)) / CumulativeEligibleGames)))) AS UpperBound95,
    CONVERT(DECIMAL(20,5), CumulativeEligibleGames * (WinRatio - (2.57 * SQRT(CAST((WinRatio * (1 - WinRatio)) AS DECIMAL(38, 20)) / CumulativeEligibleGames)))) AS LowerBound99,
    CONVERT(DECIMAL(20,5), CumulativeEligibleGames * (WinRatio + (2.57 * SQRT(CAST((WinRatio * (1 - WinRatio)) AS DECIMAL(38, 20)) / CumulativeEligibleGames)))) AS UpperBound99
FROM 
       currencies
ORDER BY 
	Day

GO

GRANT EXECUTE ON dbo.pr_GetProgressivePayouts TO GameMonitoringUser
GRANT EXECUTE ON dbo.pr_GetProgressivePayouts TO [iom\support services - Game Design] 
GRANT ALTER ON dbo.pr_GetProgressivePayouts TO [iom\support services - Game Design] 
GO

-- =========================
-- File Path: ./Procedures\pr_GetProgressivesByIdOrPayoutThreshold.sql
-- =========================

RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;
RAISERROR (' EXECUTING: ./Procedures\pr_GetProgressivesByIdOrPayoutThreshold.sql', 10, 0) WITH NOWAIT;
RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.pr_GetProgressivesByIdOrPayoutThreshold') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  EXEC sp_Executesql N'CREATE PROCEDURE dbo.pr_GetProgressivesByIdOrPayoutThreshold AS SET NOCOUNT ON'
GO

ALTER PROCEDURE dbo.pr_GetProgressivesByIdOrPayoutThreshold @PayoutThreshold INT = NULL, @GamePayId INT = NULL
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

SELECT 
    player.LoginName,
    win.PayoutUTCTime AS Time, 
    game.ClientName AS Progressive, 
    game.ModuleId, 
    win.GamePayId, 
    CONVERT(DECIMAL(20,2), win.ReportCurrencyPayoutAmount / 100) AS Payout 
FROM
    tb_MG_ProgressiveWin AS win
    INNER JOIN tb_MG_ProgressiveWager AS wager 
        ON win.ProgressiveWagerKey = wager.ProgressiveWagerKey
    INNER JOIN tb_Dim_Game AS game 
        ON	wager.GameKey = game.GameKey
	INNER JOIN dbo.tb_Dim_PlayerAccount AS player 
        ON wager.PlayerAccountKey = player.PlayerAccountKey
WHERE
	(
        win.GamePayId = 0 
        OR win.ReportCurrencyPayoutAmount / 100 > @PayoutThreshold
    )
	AND	win.PayoutUTCTime > DateAdd(DAY, -3, GETDATE())
ORDER BY
	win.PayoutUTCTime DESC;
    
GO

GRANT EXECUTE ON dbo.pr_GetProgressivesByIdOrPayoutThreshold TO GameMonitoringUser
GRANT EXECUTE ON dbo.pr_GetProgressivesByIdOrPayoutThreshold TO [iom\support services - Game Design] 
GRANT ALTER ON dbo.pr_GetProgressivesByIdOrPayoutThreshold TO [iom\support services - Game Design] 
GO

-- =========================
-- File Path: ./Procedures\pr_GetProgressivesForPlayer.sql
-- =========================

RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;
RAISERROR (' EXECUTING: ./Procedures\pr_GetProgressivesForPlayer.sql', 10, 0) WITH NOWAIT;
RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.pr_GetProgressivesForPlayer') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  EXEC sp_Executesql N'CREATE PROCEDURE dbo.pr_GetProgressivesForPlayer AS SET NOCOUNT ON'
GO

ALTER PROCEDURE dbo.pr_GetProgressivesForPlayer @LoginName VARCHAR(8000) = NULL
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

SELECT 
    LoginName, 
    ClientName AS Progressive, 
    GamePayId, 
    COUNT(*) AS NumWins, 
    CONVERT(DECIMAL(20,2), SUM(ReportCurrencyPayoutAmount) / 100) AS Payout
FROM
    tb_MG_ProgressiveWin AS win  
	INNER JOIN tb_MG_ProgressiveWager AS wager
	    ON win.ProgressiveWagerKey = wager.ProgressiveWagerKey
	INNER JOIN tb_Dim_Game AS game	
	    ON wager.GameKey = game.GameKey
	INNER JOIN dbo.tb_Dim_PlayerAccount AS player
	    ON wager.PlayerAccountKey =	player.PlayerAccountKey
WHERE
	PayoutUTCTime <= DateAdd(WEEK, -1, GETDATE())
	AND	LoginName IN (SELECT Value FROM fn_Split(@LoginName, ','))
	AND GamePayId >= 1
GROUP BY
	ClientName, GamePayId, LoginName
ORDER BY
	LoginName, Payout DESC
    
GO

GRANT EXECUTE ON dbo.pr_GetProgressivesForPlayer TO GameMonitoringUser
GRANT EXECUTE ON dbo.pr_GetProgressivesForPlayer TO [iom\support services - Game Design] 
GRANT ALTER ON dbo.pr_GetProgressivesForPlayer TO [iom\support services - Game Design] 
GO

-- =========================
-- File Path: ./Procedures\pr_GetWorstPerformingGames.sql
-- =========================

RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;
RAISERROR (' EXECUTING: ./Procedures\pr_GetWorstPerformingGames.sql', 10, 0) WITH NOWAIT;
RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.pr_GetWorstPerformingGames') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  EXEC sp_Executesql N'CREATE PROCEDURE dbo.pr_GetWorstPerformingGames AS SET NOCOUNT ON'
GO

ALTER PROCEDURE dbo.pr_GetWorstPerformingGames @limit int = NULL, @StartDate SMALLDATETIME = NULL, @EndDate SMALLDATETIME = NULL
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

SELECT TOP (@limit)
	game.ModuleId,
	game.ModuleName,
	game.ModuleVersion,
	casino.GamingSystemId,
	casino.GamingSystemName,
  	SUM(wager.NumGames) AS NumGames,
	CONVERT(DECIMAL(20,2), (SUM(wager.TotalReportCurrencyWager) - SUM(wager.TotalReportCurrencyPayout)) / 100) AS NetProfit,
	CONVERT(DECIMAL(20,2), (SUM(wager.TotalReportCurrencyPayout) / SUM(wager.TotalReportCurrencyWager)) * 100) AS RTP,
	CONVERT(DECIMAL(20,2), module.TheoreticalPayoutPercentage) AS Game_RTP,
	CONVERT(DECIMAL(20,4), (module.TheoreticalPayoutPercentage / 100) + module.StandardDeviation*1.96/sqrt(SUM(wager.NumGames)) * 100) As UpperBound95,
	CONVERT(DECIMAL(20,4), (module.TheoreticalPayoutPercentage / 100) + module.StandardDeviation*2.576/sqrt(SUM(wager.NumGames)) * 100) As UpperBound99
FROM
	dbo.tb_MG_Wager_Day	AS wager                      
	INNER JOIN dbo.tb_Dim_Game AS game 
		ON game.GameKey = wager.GameKey
	INNER JOIN dbo.tb_Dim_Casino AS	casino                     
		ON casino.CasinoKey = wager.CasinoKey
	INNER JOIN dbo.tb_Mon_ModuleSpecification AS module
		ON game.ModuleId =	module.ModuleId
WHERE
	CAST(wager.Day AS DATE) BETWEEN ISNULL(@StartDate, wager.day) AND ISNULL(@EndDate, GETDATE())
GROUP BY
	game.ModuleId, 
	game.ModuleVersion,
	casino.GamingSystemName,
	game.ModuleName,
	module.TheoreticalPayoutPercentage,
	module.StandardDeviation,
	GamingSystemId
ORDER BY
	NetProfit
OPTION(RECOMPILE)
	
GO

GRANT EXECUTE ON dbo.pr_GetWorstPerformingGames TO GameMonitoringUser
GRANT EXECUTE ON dbo.pr_GetWorstPerformingGames TO [iom\support services - Game Design] 
GRANT ALTER ON dbo.pr_GetWorstPerformingGames TO [iom\support services - Game Design] 
GO

-- =========================
-- File Path: ./Procedures\pr_RemoveFollowingPlayer.sql
-- =========================

RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;
RAISERROR (' EXECUTING: ./Procedures\pr_RemoveFollowingPlayer.sql', 10, 0) WITH NOWAIT;
RAISERROR ('-------------------------------------------------------------------------------', 10, 0) WITH NOWAIT;

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.pr_RemoveFollowingPlayer') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  EXEC sp_Executesql N'CREATE PROCEDURE dbo.pr_RemoveFollowingPlayer AS SET NOCOUNT ON'
GO

ALTER PROCEDURE dbo.pr_RemoveFollowingPlayer @FollowingPlayerId INT = NULL, @EndReason VARCHAR(max) = NULL, @EndUser VARCHAR(255) = NULL
AS

SET NOCOUNT ON

IF (SELECT EndDate FROM dbo.tb_FollowingPlayer WHERE FollowingPlayerId = @FollowingPlayerId) IS NOT NULL
BEGIN
	RAISERROR('Player has already been removed', 18, 1)
	RETURN -1
END

UPDATE dbo.tb_FollowingPlayer SET
	EndDate = GETDATE(),
	EndReason = @EndReason,
    EndUser = @EndUser
WHERE 
	FollowingPlayerId = @FollowingPlayerId

GO

GRANT EXECUTE ON dbo.pr_RemoveFollowingPlayer TO GameMonitoringUser
GRANT EXECUTE ON dbo.pr_RemoveFollowingPlayer TO [iom\support services - Game Design] 
GRANT ALTER ON dbo.pr_RemoveFollowingPlayer TO [iom\support services - Game Design] 
GO

RAISERROR ('Update Complete. Please check for errors.', 10, 0) WITH NOWAIT;