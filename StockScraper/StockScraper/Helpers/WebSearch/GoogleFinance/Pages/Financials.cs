using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using HtmlAgilityPack;
using StockScraper.Models;

namespace StockScraper.Helpers.WebSearch.GoogleFinance.Pages
{
    class Financials
    {
        internal static HtmlDocument Get(string searchTerm)
        {
            string url = Util.BuildBaseUrl(searchTerm) + "&fstype=ii";
            return Util.PageLoad(url);
        }

        private static string GetTotalEquity(HtmlDocument financialsPage)
        {
            return financialsPage.DocumentNode.SelectNodes("//*[@id='balinterimdiv']/[@id='fs-table']/tbody/tr[39]/td[2]")[0].InnerText;
        }
    }
}
