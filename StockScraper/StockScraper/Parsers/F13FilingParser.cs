using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using StockScraper.Models;
using StockScraper.Utils;
using System.IO;
using System.Xml.Linq;
using System.Globalization;
using StockScraper.Helpers;

namespace StockScraper.Parsers
{
    internal class Bounds
    {
        public int Start { get; set; }
        public int End { get; set; }
        public int Length { get; set; }
    }

    internal class InfoTableItem
    {
        public string NameOfIssuer { get; set; }
        public string Cusip { get; set; }
        public decimal Value { get; set; }
        public int NumberOfShares { get; set; }
        public string TypeOfShares { get; set; }

        public InfoTableItem (XElement infoTableElement, string nameSpace)
        {
            NameOfIssuer = infoTableElement.Element(nameSpace + "nameOfIssuer").Value;
            Cusip = infoTableElement.Element(nameSpace + "cusip").Value;
            Value = Convert.ToDecimal(Math.Floor(Convert.ToDouble(infoTableElement.Element(nameSpace + "value").Value, CultureInfo.InvariantCulture)));
            NumberOfShares = (int)Math.Floor(Convert.ToDouble(infoTableElement.Element(nameSpace + "shrsOrPrnAmt").Elements().FirstOrDefault().Value, CultureInfo.InvariantCulture));
            TypeOfShares = infoTableElement.Element(nameSpace + "shrsOrPrnAmt").Elements().LastOrDefault().Value;
        }
    }

    class F13FilingParser
    {
        private readonly StockScraperEntities _db = StockScraperEntitiesContext.Get();

        internal void Parse(Filing filing, string url)
        {
            Stream fileStream = Ftp.GetFileStream(url);
            var xmlString = StreamUtil.ReadText(fileStream);

            XDocument infoTable = GetInfoTable(xmlString);

            if (infoTable == null)
            {
                Console.WriteLine($"No Info table found for F13 Filing at {url}");
            };

            ProcessInfoTable(infoTable, filing);
        }

        private static XDocument GetInfoTable(string xmlString)
        {
            Bounds infoTableBounds = GetBoundsOfInfoTable(xmlString);
            if (infoTableBounds == null) return null;

            xmlString = xmlString.Substring(infoTableBounds.Start, infoTableBounds.Length);

            xmlString = $"<?xml version=\"1.0\" encoding=\"UTF - 8\"?>{xmlString}";

            return XDocument.Parse(xmlString);
        }

        private static Bounds GetBoundsOfInfoTable(string xmlString)
        {
            // There are two XML docs in the file, the info table is in the second one. 
            int informationTableXmlTag = xmlString.IndexOf("<XML>", xmlString.IndexOf("<XML>") + 1);

            // No info table in document.
            if (informationTableXmlTag == -1) return null;

            int infoTableIndex = xmlString.IndexOf("informationTable", informationTableXmlTag);
            string prefix = "";

            int i = 1;
            while (xmlString[infoTableIndex - i] != '<')
            {
                prefix = xmlString[infoTableIndex - i] + prefix;
                i++;
            }

            int start = infoTableIndex - i;
            int end = xmlString.IndexOf("</" + prefix + "informationTable>") + ("</" + prefix + "informationTable>").Length;

            return new Bounds { Start = start, End = end, Length = end - start };
        }

        private void ProcessInfoTable(XDocument infoTable, Filing filing)
        {
            string nameSpace = "{" + infoTable.Root.Elements().FirstOrDefault().Name.NamespaceName + "}";

            IEnumerable<XElement> infoTableElements = infoTable.Root.Elements();
            infoTableElements = infoTableElements as XElement[] ?? infoTableElements.ToArray();

            Console.WriteLine($"Processing: {infoTableElements.Count()} elements");

            int i = 0;
            int parts = 8;

            var splits = from item in infoTableElements.AsParallel()
                         group item by i++ % parts into part
                         select part.AsEnumerable();

            Task[] tasks = splits.Select(elements => Task.Factory.StartNew(() => ProcessShareBatch(elements, nameSpace, filing))).ToArray();

            Task.WaitAll(tasks);

            Console.WriteLine("Finished writing to DB");
            Console.WriteLine("");
        }

        private void ProcessShareBatch(IEnumerable<XElement> elements, string nameSpace, Filing filing)
        {
            foreach (XElement element in elements)
            {
                var infoTableItem = new InfoTableItem(element, nameSpace);
                ProccessShare(infoTableItem, filing);
            }
        }

        private Share ProccessShare(InfoTableItem infoTableItem, Filing filing)
        {
            Share share = null;
            var securityHelper = new SecurityHelper();
            Security security = FindSecurity(infoTableItem.NameOfIssuer, infoTableItem.Cusip);

            if (security != null)
            {
                security = securityHelper.SaveSecurity(security);
                securityHelper.SaveSecurityMap(security, infoTableItem.Cusip);
                share = AddShare(infoTableItem, filing.FilingId, security.SecurityId);
            }
            else
            {
                securityHelper.AddUnknownShare(infoTableItem, filing.FilingId);
            }

            return share;
        }

        private Share AddShare(InfoTableItem infoTableItem, int filingId, int securityId)
        {
            var db = new StockScraperEntities();

            var share = new Share
            {
                FilingId = filingId,
                Number = infoTableItem.NumberOfShares,
                Type = infoTableItem.TypeOfShares,
                Value = infoTableItem.Value,
                SecurityId = securityId
            };

            db.Shares.Add(share);
            db.SaveChanges();

            return share;
        }

        private Security FindSecurity(string name, string cusip)
        {
            var securityHelper = new SecurityHelper();
            return securityHelper.CusipLookup(cusip) ?? securityHelper.NameLookup(name);
        }
    }
}
