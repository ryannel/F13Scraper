using StockScraper.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StockScraper.Helpers
{
    static class StockFinder
    {
        public static Security CusipLookup(string cusip)
        {
            Console.WriteLine($"Searching for Cusip {cusip} on Vanguard.");
            Security security = WebSearch.Vanguard.SearchByCusip(cusip);

            if (security == null)
            {
                Console.WriteLine($"Not found, searching for cusip {cusip} on Fidelity.");
                security = FidelitySearch(cusip);
            }

            return security != null ? NameLookup($"{security.Exchange}:{security.Symbol}") : null;
        }

        public static Security NameLookup(string name)
        {
            Console.WriteLine($"Searching for {name} on Google Finance.");
            Security security = WebSearch.GoogleFinance.Api.SecuritySearch(name);

            if (security?.Symbol != null && (security.Sector == null || security.Industry == null))
            {
                Security yahooSecurity = WebSearch.YahooFinance.Api.SecuritySearch(security.Symbol);
                if (yahooSecurity.Industry != null) security.Industry = yahooSecurity.Industry;
                if (yahooSecurity.Sector != null) security.Sector = yahooSecurity.Sector;
            }

            return security;
        }

        private static Security FidelitySearch(string cusip)
        {
            Security security = WebSearch.Fidelity.SearchByCusip(cusip);

            if (security != null)
            {
                security = NameLookup(string.Concat(security.Name, ":", security.Symbol));
            }

            return security;
        }
    }
}
