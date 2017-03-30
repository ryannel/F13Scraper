using HtmlAgilityPack;
using StockScraper.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace StockScraper.Helpers.WebSearch
{
    static class GoogleFinance
    {
        private static string _baseUrl = "https://www.google.com/finance";

        public static Security SearchByName(string name)
        {
            var doc = GetSearchResultPage(name);

            try
            {
                return ScrapeSecurityFromResultPage(doc);
            }
            catch (Exception)
            {
                return null;
            }
        }

        private static HtmlDocument GetSearchResultPage(string searchTerm)
        {
            string url = BuildUrl(searchTerm);
            HtmlDocument doc = PageLoad(url);

            return doc;
        }

        private static string BuildUrl(string term)
        {
            return string.Concat(_baseUrl, "?q=", term);
        }

        private static HtmlDocument PageLoad(string url)
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

        private static Security ScrapeSecurityFromResultPage(HtmlDocument resultPage)
        {
            Security security = null;

            var spellCorrectedSearchTerm = GetSpellingSuggestion(resultPage);

            if (spellCorrectedSearchTerm != null)
            {
                security = SearchByName(spellCorrectedSearchTerm);
            }
            else
            {
                security = GetStockDetailsFromResultPage(resultPage);
            }

            return security;
        }

        private static string GetSpellingSuggestion(HtmlDocument resultPage)
        {
            try
            {
                return resultPage.DocumentNode.SelectNodes("//*[@id='gf - viewc']/div/div[2]/font/a")[0].InnerText;
            }
            catch (Exception)
            {
                return null;
                throw;
            }
        }

        private static Security GetStockDetailsFromResultPage(HtmlDocument resultPage)
        {
            string name = resultPage.DocumentNode.SelectNodes("//*[@id='appbar']/div/div[2]/div[1]/span")[0].InnerText;
            string description = resultPage.DocumentNode.SelectNodes("//*[@id='appbar']/div/div[2]/div[2]/span")[0].InnerText;

            description = description.Replace(")", string.Empty);
            description = description.Replace("(", string.Empty);

            var split = description.Split(':');

            var security = new Security()
            {
                Exchange = split[0],
                Symbol = split[1],
                Name = name
            };
            return security;
        }
    }
}
