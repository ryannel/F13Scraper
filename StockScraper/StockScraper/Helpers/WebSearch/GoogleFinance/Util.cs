using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using HtmlAgilityPack;
using StockScraper.Helpers.WebSearch.GoogleFinance.Pages;
using StockScraper.Models;

namespace StockScraper.Helpers.WebSearch.GoogleFinance
{
    internal static class Util
    {
        private static string _baseUrl = "https://www.google.com/finance";

        internal static Security GetSecurity(HtmlDocument summaryPage)
        {
            var security = new Security()
            {
                Exchange = Summary.GetExchange(summaryPage),
                Symbol = Summary.GetSymbol(summaryPage),
                Name = Summary.GetName(summaryPage),
                Industry = Summary.GetIndustry(summaryPage),
                Sector = Summary.GetSector(summaryPage)
            };
            return security;
        }

        //internal static FinancialStatistics SeachFinancialStatistics()
        //{
            
        //}

        internal static string BuildBaseUrl(string term)
        {
            return string.Concat(_baseUrl, "?q=", term);
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
                Console.WriteLine("Unable to reach google:");
                Console.WriteLine(ex.ToString());
                Console.WriteLine("");
                Console.WriteLine("Retrying in 60 seconds");
                Thread.Sleep(60000);

                return PageLoad(url);
            }
        }
    }
}
