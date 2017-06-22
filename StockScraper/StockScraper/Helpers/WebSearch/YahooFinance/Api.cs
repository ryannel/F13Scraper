using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using StockScraper.Helpers.WebSearch.YahooFinance.Pages;
using StockScraper.Models;

namespace StockScraper.Helpers.WebSearch.YahooFinance
{
    class Api
    {
        public static Security SecuritySearch(string searchTerm)
        {
            searchTerm = searchTerm.Split('-')[0];
            searchTerm = searchTerm.Split('.')[0];
            searchTerm = searchTerm.Replace("*", string.Empty);

            var summaryPage = Summary.Get(searchTerm);
            var summaryJson = Summary.GetJson(searchTerm);
            return Util.GetSecurity(summaryPage, summaryJson);
        }
    }
}
