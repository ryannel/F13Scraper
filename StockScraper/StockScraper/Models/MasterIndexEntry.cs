using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StockScraper.Models
{
    class MasterIndexEntry
    {
        public string Cik { get; set; }
        public string CompanyName { get; set; }
        public string FormType { get; set; }
        public DateTime DateFiled { get; set; }
        public string Url { get; set; }
        public int MasterIndexId { get; set; }

        public MasterIndexEntry(int masterIndexId, string line)
        {
            string[] splitLine = line.Split('|');

            MasterIndexId = masterIndexId;
            Cik = splitLine[0];
            CompanyName = splitLine[1];
            FormType = splitLine[2];
            DateFiled = DateTime.Parse(splitLine[3]);
            Url = $"https://www.sec.gov/Archives/{splitLine[4]}";
        }
    }
}
