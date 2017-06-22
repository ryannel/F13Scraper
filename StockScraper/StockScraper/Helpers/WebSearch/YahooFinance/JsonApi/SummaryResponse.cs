using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StockScraper.Helpers.WebSearch.YahooFinance.JsonApi
{
    public class Trend
    {
        public string period { get; set; }
        public int strongBuy { get; set; }
        public int buy { get; set; }
        public int hold { get; set; }
        public int sell { get; set; }
        public int strongSell { get; set; }
    }

    public class RecommendationTrend
    {
        public List<Trend> trend { get; set; }
        public int maxAge { get; set; }
    }

    public class EarningsDate
    {
        public int raw { get; set; }
        public string fmt { get; set; }
    }

    public class EarningsAverage
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class EarningsLow
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class EarningsHigh
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class RevenueAverage
    {
        public long raw { get; set; }
        public string fmt { get; set; }
        public string longFmt { get; set; }
    }

    public class RevenueLow
    {
        public long raw { get; set; }
        public string fmt { get; set; }
        public string longFmt { get; set; }
    }

    public class RevenueHigh
    {
        public long raw { get; set; }
        public string fmt { get; set; }
        public string longFmt { get; set; }
    }

    public class Earnings
    {
        public List<EarningsDate> earningsDate { get; set; }
        public EarningsAverage earningsAverage { get; set; }
        public EarningsLow earningsLow { get; set; }
        public EarningsHigh earningsHigh { get; set; }
        public RevenueAverage revenueAverage { get; set; }
        public RevenueLow revenueLow { get; set; }
        public RevenueHigh revenueHigh { get; set; }
    }

    public class ExDividendDate
    {
    }

    public class DividendDate
    {
        public int raw { get; set; }
        public string fmt { get; set; }
    }

    public class CalendarEvents
    {
        public int maxAge { get; set; }
        public Earnings earnings { get; set; }
        public ExDividendDate exDividendDate { get; set; }
        public DividendDate dividendDate { get; set; }
    }

    public class Actual
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class Estimate
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class Quarterly
    {
        public string date { get; set; }
        public Actual actual { get; set; }
        public Estimate estimate { get; set; }
    }

    public class CurrentQuarterEstimate
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class EarningsChart
    {
        public List<Quarterly> quarterly { get; set; }
        public CurrentQuarterEstimate currentQuarterEstimate { get; set; }
        public string currentQuarterEstimateDate { get; set; }
        public int currentQuarterEstimateYear { get; set; }
    }

    public class Revenue
    {
        public object raw { get; set; }
        public string fmt { get; set; }
        public string longFmt { get; set; }
    }

    public class Earnings3
    {
        public long raw { get; set; }
        public string fmt { get; set; }
        public string longFmt { get; set; }
    }

    public class Yearly
    {
        public int date { get; set; }
        public Revenue revenue { get; set; }
        public Earnings3 earnings { get; set; }
    }

    public class Revenue2
    {
        public object raw { get; set; }
        public string fmt { get; set; }
        public string longFmt { get; set; }
    }

    public class Earnings4
    {
        public long raw { get; set; }
        public string fmt { get; set; }
        public string longFmt { get; set; }
    }

    public class Quarterly2
    {
        public string date { get; set; }
        public Revenue2 revenue { get; set; }
        public Earnings4 earnings { get; set; }
    }

    public class FinancialsChart
    {
        public List<Yearly> yearly { get; set; }
        public List<Quarterly2> quarterly { get; set; }
    }

    public class Earnings2
    {
        public int maxAge { get; set; }
        public EarningsChart earningsChart { get; set; }
        public FinancialsChart financialsChart { get; set; }
    }

    public class History
    {
        public int epochGradeDate { get; set; }
        public string firm { get; set; }
        public string toGrade { get; set; }
        public string fromGrade { get; set; }
        public string action { get; set; }
    }

    public class UpgradeDowngradeHistory
    {
        public List<History> history { get; set; }
        public int maxAge { get; set; }
    }

    public class EnterpriseValue
    {
        public long raw { get; set; }
        public string fmt { get; set; }
        public string longFmt { get; set; }
    }

    public class ForwardPE
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class ProfitMargins
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class FloatShares
    {
        public long raw { get; set; }
        public string fmt { get; set; }
        public string longFmt { get; set; }
    }

    public class SharesOutstanding
    {
        public long raw { get; set; }
        public string fmt { get; set; }
        public string longFmt { get; set; }
    }

    public class SharesShort
    {
        public long raw { get; set; }
        public string fmt { get; set; }
        public string longFmt { get; set; }
    }

    public class SharesShortPriorMonth
    {
        public long raw { get; set; }
        public string fmt { get; set; }
        public string longFmt { get; set; }
    }

    public class HeldPercentInsiders
    {
    }

    public class HeldPercentInstitutions
    {
    }

    public class ShortRatio
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class ShortPercentOfFloat
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class Beta
    {
    }

    public class MorningStarOverallRating
    {
    }

    public class MorningStarRiskRating
    {
    }

    public class BookValue
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class PriceToBook
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class AnnualReportExpenseRatio
    {
    }

    public class YtdReturn
    {
    }

    public class Beta3Year
    {
    }

    public class TotalAssets
    {
    }

    public class Yield
    {
    }

    public class FundInceptionDate
    {
    }

    public class ThreeYearAverageReturn
    {
    }

    public class FiveYearAverageReturn
    {
    }

    public class PriceToSalesTrailing12Months
    {
    }

    public class LastFiscalYearEnd
    {
        public int raw { get; set; }
        public string fmt { get; set; }
    }

    public class NextFiscalYearEnd
    {
        public int raw { get; set; }
        public string fmt { get; set; }
    }

    public class MostRecentQuarter
    {
        public int raw { get; set; }
        public string fmt { get; set; }
    }

    public class EarningsQuarterlyGrowth
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class RevenueQuarterlyGrowth
    {
    }

    public class NetIncomeToCommon
    {
        public long raw { get; set; }
        public string fmt { get; set; }
        public string longFmt { get; set; }
    }

    public class TrailingEps
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class ForwardEps
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class PegRatio
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class LastSplitDate
    {
        public int raw { get; set; }
        public string fmt { get; set; }
    }

    public class EnterpriseToRevenue
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class EnterpriseToEbitda
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class __invalid_type__52WeekChange
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class SandP52WeekChange
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class LastDividendValue
    {
    }

    public class LastCapGain
    {
    }

    public class AnnualHoldingsTurnover
    {
    }

    public class DefaultKeyStatistics
    {
        public int maxAge { get; set; }
        public EnterpriseValue enterpriseValue { get; set; }
        public ForwardPE forwardPE { get; set; }
        public ProfitMargins profitMargins { get; set; }
        public FloatShares floatShares { get; set; }
        public SharesOutstanding sharesOutstanding { get; set; }
        public SharesShort sharesShort { get; set; }
        public SharesShortPriorMonth sharesShortPriorMonth { get; set; }
        public HeldPercentInsiders heldPercentInsiders { get; set; }
        public HeldPercentInstitutions heldPercentInstitutions { get; set; }
        public ShortRatio shortRatio { get; set; }
        public ShortPercentOfFloat shortPercentOfFloat { get; set; }
        public Beta beta { get; set; }
        public MorningStarOverallRating morningStarOverallRating { get; set; }
        public MorningStarRiskRating morningStarRiskRating { get; set; }
        public object category { get; set; }
        public BookValue bookValue { get; set; }
        public PriceToBook priceToBook { get; set; }
        public AnnualReportExpenseRatio annualReportExpenseRatio { get; set; }
        public YtdReturn ytdReturn { get; set; }
        public Beta3Year beta3Year { get; set; }
        public TotalAssets totalAssets { get; set; }
        public Yield yield { get; set; }
        public object fundFamily { get; set; }
        public FundInceptionDate fundInceptionDate { get; set; }
        public object legalType { get; set; }
        public ThreeYearAverageReturn threeYearAverageReturn { get; set; }
        public FiveYearAverageReturn fiveYearAverageReturn { get; set; }
        public PriceToSalesTrailing12Months priceToSalesTrailing12Months { get; set; }
        public LastFiscalYearEnd lastFiscalYearEnd { get; set; }
        public NextFiscalYearEnd nextFiscalYearEnd { get; set; }
        public MostRecentQuarter mostRecentQuarter { get; set; }
        public EarningsQuarterlyGrowth earningsQuarterlyGrowth { get; set; }
        public RevenueQuarterlyGrowth revenueQuarterlyGrowth { get; set; }
        public NetIncomeToCommon netIncomeToCommon { get; set; }
        public TrailingEps trailingEps { get; set; }
        public ForwardEps forwardEps { get; set; }
        public PegRatio pegRatio { get; set; }
        public string lastSplitFactor { get; set; }
        public LastSplitDate lastSplitDate { get; set; }
        public EnterpriseToRevenue enterpriseToRevenue { get; set; }
        public EnterpriseToEbitda enterpriseToEbitda { get; set; }
        public __invalid_type__52WeekChange __invalid_name__52WeekChange { get; set; }
        public SandP52WeekChange SandP52WeekChange { get; set; }
        public LastDividendValue lastDividendValue { get; set; }
        public LastCapGain lastCapGain { get; set; }
        public AnnualHoldingsTurnover annualHoldingsTurnover { get; set; }
    }

    public class SummaryProfile
    {
        public string address1 { get; set; }
        public string city { get; set; }
        public string zip { get; set; }
        public string country { get; set; }
        public string phone { get; set; }
        public string website { get; set; }
        public string industry { get; set; }
        public string sector { get; set; }
        public string longBusinessSummary { get; set; }
        public int fullTimeEmployees { get; set; }
        public List<object> companyOfficers { get; set; }
        public int maxAge { get; set; }
    }

    public class CurrentPrice
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class TargetHighPrice
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class TargetLowPrice
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class TargetMeanPrice
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class TargetMedianPrice
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class RecommendationMean
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class NumberOfAnalystOpinions
    {
        public int raw { get; set; }
        public string fmt { get; set; }
        public string longFmt { get; set; }
    }

    public class TotalCash
    {
        public long raw { get; set; }
        public string fmt { get; set; }
        public string longFmt { get; set; }
    }

    public class TotalCashPerShare
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class Ebitda
    {
        public long raw { get; set; }
        public string fmt { get; set; }
        public string longFmt { get; set; }
    }

    public class TotalDebt
    {
        public long raw { get; set; }
        public string fmt { get; set; }
        public string longFmt { get; set; }
    }

    public class QuickRatio
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class CurrentRatio
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class TotalRevenue
    {
        public long raw { get; set; }
        public string fmt { get; set; }
        public string longFmt { get; set; }
    }

    public class DebtToEquity
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class RevenuePerShare
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class ReturnOnAssets
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class ReturnOnEquity
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class GrossProfits
    {
        public long raw { get; set; }
        public string fmt { get; set; }
        public string longFmt { get; set; }
    }

    public class FreeCashflow
    {
        public long raw { get; set; }
        public string fmt { get; set; }
        public string longFmt { get; set; }
    }

    public class OperatingCashflow
    {
        public long raw { get; set; }
        public string fmt { get; set; }
        public string longFmt { get; set; }
    }

    public class EarningsGrowth
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class RevenueGrowth
    {
    }

    public class GrossMargins
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class EbitdaMargins
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class OperatingMargins
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class ProfitMargins2
    {
        public double raw { get; set; }
        public string fmt { get; set; }
    }

    public class FinancialData
    {
        public int maxAge { get; set; }
        public CurrentPrice currentPrice { get; set; }
        public TargetHighPrice targetHighPrice { get; set; }
        public TargetLowPrice targetLowPrice { get; set; }
        public TargetMeanPrice targetMeanPrice { get; set; }
        public TargetMedianPrice targetMedianPrice { get; set; }
        public RecommendationMean recommendationMean { get; set; }
        public string recommendationKey { get; set; }
        public NumberOfAnalystOpinions numberOfAnalystOpinions { get; set; }
        public TotalCash totalCash { get; set; }
        public TotalCashPerShare totalCashPerShare { get; set; }
        public Ebitda ebitda { get; set; }
        public TotalDebt totalDebt { get; set; }
        public QuickRatio quickRatio { get; set; }
        public CurrentRatio currentRatio { get; set; }
        public TotalRevenue totalRevenue { get; set; }
        public DebtToEquity debtToEquity { get; set; }
        public RevenuePerShare revenuePerShare { get; set; }
        public ReturnOnAssets returnOnAssets { get; set; }
        public ReturnOnEquity returnOnEquity { get; set; }
        public GrossProfits grossProfits { get; set; }
        public FreeCashflow freeCashflow { get; set; }
        public OperatingCashflow operatingCashflow { get; set; }
        public EarningsGrowth earningsGrowth { get; set; }
        public RevenueGrowth revenueGrowth { get; set; }
        public GrossMargins grossMargins { get; set; }
        public EbitdaMargins ebitdaMargins { get; set; }
        public OperatingMargins operatingMargins { get; set; }
        public ProfitMargins2 profitMargins { get; set; }
    }

    public class Result
    {
        public RecommendationTrend recommendationTrend { get; set; }
        public CalendarEvents calendarEvents { get; set; }
        public Earnings2 earnings { get; set; }
        public UpgradeDowngradeHistory upgradeDowngradeHistory { get; set; }
        public DefaultKeyStatistics defaultKeyStatistics { get; set; }
        public SummaryProfile summaryProfile { get; set; }
        public FinancialData financialData { get; set; }
    }

    public class QuoteSummary
    {
        public List<Result> result { get; set; }
        public object error { get; set; }
    }

    public class RootObject
    {
        public QuoteSummary quoteSummary { get; set; }
    }
}
