using StockScraper.Models;
using StockScraper.Utils;
using System;
using System.Linq;

namespace StockScraper.Parsers
{
    class MasterIndexRowParser
    {
        private readonly StockScraperEntities _db = StockScraperEntitiesContext.Get();

        internal void Parse(int masterIndexId, MasterIndexEntry indexEntry)
        {
            Console.WriteLine($"Processing {indexEntry.FormType} for {indexEntry.CompanyName}");
            var hedgeFund = AddHedgeFund(indexEntry);

            ProcessFiling(hedgeFund, indexEntry);
        }

        private HedgeFund AddHedgeFund(MasterIndexEntry indexEntry)
        {
            HedgeFund hedgeFund = _db.HedgeFunds.SingleOrDefault(h => h.Name == indexEntry.CompanyName);

            if (hedgeFund == null)
            {
                hedgeFund = new HedgeFund
                {
                    Name = indexEntry.CompanyName,
                };

                _db.HedgeFunds.Add(hedgeFund);
                _db.SaveChanges();
            }

            AddRegistration(hedgeFund, indexEntry.Cik);

            return hedgeFund;
        }

        private Registration AddRegistration(HedgeFund hedgeFund, string cik)
        {
            Registration registration = _db.Registrations.SingleOrDefault(r => r.Identifier == cik);

            if (registration == null)
            {
                int registrationAuthorityId = _db.RegistrationAuthorities.SingleOrDefault(r => r.Name == "Edgar").RegistrationAuthorityId;

                registration = new Registration
                {
                    RegistrationAuthorityId = registrationAuthorityId,
                    HedgeFund = hedgeFund,
                    Identifier = cik
                };

                _db.Registrations.Add(registration);
                _db.SaveChanges();
            }

            return registration;
        }

        private void ProcessFiling(HedgeFund hedgeFund, MasterIndexEntry indexEntry)
        {
            Filing filing = _db.Filings.SingleOrDefault(f => f.Url == indexEntry.Url);

            if (filing == null)
            {
                filing = AddFiling(hedgeFund, indexEntry);
                new F13FilingParser().Parse(filing, indexEntry.Url);
            }
            else
            {
                Console.WriteLine($"{indexEntry.FormType} filing for {indexEntry.CompanyName} has already been captured, moving on.");
                Console.WriteLine("");
            }
        }

        private Filing AddFiling(HedgeFund hedgeFund, MasterIndexEntry indexEntry)
        {
            Filing filing = _db.Filings.SingleOrDefault(r => r.Url == indexEntry.Url);

            if (filing == null)
            {
                FormType formType = _db.FormTypes.SingleOrDefault(f => f.Name == "13F-HR");

                filing = new Filing
                {
                    HedgeFund = hedgeFund,
                    FormType = formType,
                    Date = indexEntry.DateFiled, 
                    Url = indexEntry.Url,
                    MasterIndexId = indexEntry.MasterIndexId
                };

                _db.Filings.Add(filing);
                _db.SaveChanges();
            }

            return filing;
        }
    }
}
