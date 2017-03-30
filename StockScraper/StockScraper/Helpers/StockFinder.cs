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

            return security;
        }

        public static Security NameLookup(string name)
        {
            Console.WriteLine($"Searching for {name} on Google Finance.");
            return WebSearch.GoogleFinance.SearchByName(name);
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
