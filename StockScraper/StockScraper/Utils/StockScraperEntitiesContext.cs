using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using StockScraper.Models;

namespace StockScraper.Utils
{
    class StockScraperEntitiesContext
    {
        private static readonly StockScraperEntities StockScraperEntities = new StockScraperEntities();

        public static StockScraperEntities Get()
        {
            return new StockScraperEntities(); 
        }
    }
}
