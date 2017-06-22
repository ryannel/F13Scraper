using HtmlAgilityPack;
using StockScraper.Models;
using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using StockScraper.Helpers.WebSearch.GoogleFinance.Pages;

namespace StockScraper.Helpers.WebSearch.GoogleFinance
{
    static class Api
    {
        public static Security SecuritySearch(string searchTerm)
        {
            var summaryPage = Summary.Get(searchTerm);
            return summaryPage != null ? Util.GetSecurity(summaryPage) : null;
        }

        //public static Security SearchFinancialStatistics(string exchange, string symbol)
        //{
        //    return Util.SeachFinancialStatistics();
        //}
       
    }
}
