using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using StockScraper.Utils;
using StockScraper.Models;

namespace StockScraper.Parsers
{
    public class MasterIndexParser
    {
        private readonly StockScraperEntities _db = StockScraperEntitiesContext.Get();

        public void Parse(string url)
        {
            MasterIndex masterIndex = AddMasterIndex(url);
            Stream masterIndexStream = Ftp.GetZippedFile(url);
            ParseMasterIndexStream(masterIndex.MasterIndexId, masterIndexStream);
        }

        private MasterIndex AddMasterIndex(string url)
        {
            MasterIndex masterIndex = _db.MasterIndexes.FirstOrDefault(m => m.Url == url);

            if (masterIndex == null)
            {
                masterIndex = GetMasterIndexFromUrl(url);
                Console.WriteLine($"Adding new MasterIndex for {masterIndex.Name}");

                _db.MasterIndexes.Add(masterIndex);
                _db.SaveChanges();
            }
            else
            {
                Console.WriteLine($"MasterIndex {masterIndex.Name} already exists, continuing.");
            }

            return masterIndex;
        }

        private MasterIndex GetMasterIndexFromUrl(string url)
        {
            string[] splitUrl = url.Split('/');

            return new MasterIndex()
            {
                Name = $"{splitUrl[6]} - {splitUrl[7]}",
                Url = url
            };
        }

        private void ParseMasterIndexStream(int masterIndexId, Stream mainIndexStream)
        {
            TextReader masterIndexReader = new StreamReader(mainIndexStream);

            // Skip the first 10 lines of the file to get past the text header.
            masterIndexReader = StreamUtil.SkipLines(masterIndexReader, 10);
            ParseF13FilingsFromMainIndex(masterIndexId, masterIndexReader);
        }

        private void ParseF13FilingsFromMainIndex(int masterIndexId, TextReader mainIndexReader)
        {
            Console.WriteLine("Processing Master Index File");
            string line;

            while ((line = mainIndexReader.ReadLine()) != null)
            {
                if (line.Contains("13F-HR"))
                {
                    var indexEntry = new MasterIndexEntry(masterIndexId, line);
                    new MasterIndexRowParser().Parse(indexEntry);
                }
            }

            mainIndexReader.Close();
        }
    }
}
