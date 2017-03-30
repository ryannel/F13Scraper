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
    static class Fidelity
    {
        private static string _baseUrl = "http://quotes.fidelity.com/mmnet/SymLookup.phtml?reqforlookup=REQUESTFORLOOKUP&for=stock&by=cusip&criteria=";

        public static Security SearchByCusip(string cusip)
        {
            var doc = GetSearchResultPage(cusip);

            try
            {
                return GetStockDetailsFromResultPage(doc);
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
            return string.Concat(_baseUrl, term);
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
                Console.WriteLine("Unable to reach fidelity:");
                Console.WriteLine(ex.ToString());
                Console.WriteLine("");
                Console.WriteLine("Retrying in 60 seconds");
                Thread.Sleep(60000);

                return PageLoad(url);
            }
        }

        private static Security GetStockDetailsFromResultPage(HtmlDocument resultPage)
        {
            string name = resultPage.DocumentNode.SelectNodes("/html/body/table/tr/td[2]/table[3]/tr/td[2]/table/tr[3]/td/font")[0].InnerText;
            string symbol = resultPage.DocumentNode.SelectNodes("/html/body/table/tr/td[2]/table[3]/tr/td[2]/table/tr[3]/td[2]/font/a")[0].InnerText;

            return new Security()
            {
                Symbol = symbol,
                Name = name
            };
        }
    }
}
