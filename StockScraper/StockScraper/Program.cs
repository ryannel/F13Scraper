using System;
using StockScraper.Parsers;

namespace StockScraper
{
    internal class Program
    {
        private static void Main(string[] args)
        {
            var startTime = DateTime.Now;
            PrintStartMessage();

            const string url = "https://www.sec.gov/Archives/edgar/full-index/2017/QTR2/master.zip";

            new MasterIndexParser().Parse(url); 

            PrintEndMessage(startTime);
        }

        private static void PrintStartMessage()
        {
            Console.WriteLine("App Starting");
        }

        private static void PrintEndMessage(DateTime startTime) 
        {
            var endTime = DateTime.Now;

            Console.WriteLine("");
            Console.WriteLine("");
            Console.WriteLine("============================");
            Console.WriteLine("App ended at: " + endTime.ToString("dd/MM/yyyy h:mm tt"));
            Console.WriteLine("Total runtime: " + endTime.Subtract(startTime).ToString());
            Console.WriteLine("");

            Console.ReadKey();
        }
    }
}
