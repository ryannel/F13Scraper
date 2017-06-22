using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using HtmlAgilityPack;
using StockScraper.Helpers.WebSearch.YahooFinance.Pages;
using StockScraper.Models;

namespace StockScraper.Helpers.WebSearch.YahooFinance
{
    class Util
    {
        private static string _baseUrl = "https://www.finance.yahoo.com/quote/";

        internal static Security GetSecurity(HtmlDocument summaryPage, JsonApi.RootObject summayJson)
        {
            var security = new Security()
            {
                Exchange = Summary.GetExchange(summaryPage),
                Symbol = Summary.GetSymbol(summaryPage),
                Name = Summary.GetName(summaryPage),
                Industry = Summary.GetIndustry(summayJson),
                Sector = Summary.GetSector(summayJson)
            };
            return security;
        }

        internal static string BuildBaseUrl(string term)
        {
            return string.Concat(_baseUrl, term);
        }

        internal static HtmlDocument PageLoad(string url)
        {
            try
            {
                HtmlWeb web = new HtmlWeb()
                {
                    UserAgent = "Mozilla / 5.0(Windows NT 10.0; WOW64) AppleWebKit / 537.36(KHTML, like Gecko) Chrome / 49.0.2623.112 Safari / 537.36"
                };
                return web.Load(url);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Unable to reach Yahoo:");
                Console.WriteLine(ex.ToString());
                Console.WriteLine("");
                Console.WriteLine("Retrying in 60 seconds");
                Thread.Sleep(60000);

                return PageLoad(url);
            }
        }

        public static string BuildSummaryApiUrl(string searchTerm)
        {
            return $"https://query1.finance.yahoo.com/v10/finance/quoteSummary/{searchTerm}?formatted=true&lang=en-US&region=US&modules=summaryProfile%2CfinancialData%2CrecommendationTrend%2CupgradeDowngradeHistory%2Cearnings%2CdefaultKeyStatistics%2CcalendarEvents";
        }
    }
}