using Newtonsoft.Json;
using StockScraper.Models;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using StockScraper.Utils;

namespace StockScraper.Helpers.WebSearch
{
    static class Vanguard
    {
        private class Result
        {
            public string Symbol { get; set; }
            public string Type { get; set; }
            public string ExchangeName { get; set; }
            public string LongName { get; set; }
            public string FundId { get; set; }
            public string ManagementType { get; set; }
            public bool IsEtf { get; set; }
        }

        private class RootObject
        {
            public string Type { get; set; }
            public List<Result> Results { get; set; }
        }

        private static string _baseUrl = "https://api.vanguard.com/rs/sae/search/securities.jsonp?q=";

        public static Security SearchByCusip(string cusip)
        {
            try
            {
                return GetStockDetailsFromResultPage(cusip);
            }
            catch (Exception)
            {
                return null;
            }
        }

        private static Result GetQueryResponse(string cusip)
        {
            string url = BuildUrl(cusip);
            return GetJson(url);
        }

        private static string BuildUrl(string cusip)
        {
            return string.Concat(_baseUrl, cusip);
        }

        private static Result GetJson(string url)
        {
            //HttpWebRequest httpWebRequest = (HttpWebRequest)WebRequest.Create(url);
            //httpWebRequest.Method = WebRequestMethods.Http.Get;
            //httpWebRequest.Accept = "application/json";

            //var response = (HttpWebResponse)httpWebRequest.GetResponse();

            //StreamReader streamReader = new StreamReader(response.GetResponseStream());
            //String responseData = streamReader.ReadToEnd();

            //responseData = responseData.Replace("callback(", String.Empty);
            //responseData = responseData.Replace("})", "}");

            //return JsonConvert.DeserializeObject<RootObject>(responseData).Results[0];

            using (var webClient = new PersistantWebClient())
            {
                string responseData = webClient.DownloadString(url);
                responseData = responseData.Replace("callback(", String.Empty);
                responseData = responseData.Replace("})", "}");
                RootObject json = JsonConvert.DeserializeObject<RootObject>(responseData);
                return json.Results[0];
            }
        }

        private static Security GetStockDetailsFromResultPage(string cusip)
        {
            Result result = GetQueryResponse(cusip);

            var security = new Security()
            {
                Name = result.LongName,
                Symbol = result.Symbol,
                Exchange = Regex.Replace(result.ExchangeName, @"\s+", "").ToUpper()
            };

            security.Symbol = security.Symbol.Replace("_pd", "");
            security.Symbol = security.Symbol.Replace("_t", "");
            security.Symbol = security.Symbol.Replace("_p", "");

            if (security.Symbol.EndsWith("a")) security.Symbol = security.Symbol.Substring(0, security.Symbol.Length - 1) + ".A";

            security.Exchange = security.Exchange.Replace("NASDOTCBULLETINBOARDMARKET", "OTCBB");
            security.Exchange = security.Exchange.Replace("BATSEXCHANGE", "BZX");
            security.Exchange = security.Exchange.Replace("NEWYORKSTOCKEXCHANGE", "NYSE");
            security.Exchange = security.Exchange.Replace("NASDAQCAPITALMARKET(FROMNASDAQSMALL", "NASDAQ");
            security.Exchange = security.Exchange.Replace("NASDAQSTOCKEXCHANGEGLOBALSELECTMARK", "NASDAQ");
            security.Exchange = security.Exchange.Replace("NASDAQSTOCKMARKETEXCHANGELARGECAP(", "NASDAQ");
            security.Exchange = security.Exchange.Replace("OVERTHECOUNTERMARKETS", "OTCMKTS");
            security.Exchange = security.Exchange.Replace("US'OTHEROTC'(PINKSHEETS)", "OTCMKTS");
            security.Exchange = security.Exchange.Replace("US\u0092OTHEROTC\u0092(PINKSHEETS)", "OTCMKTS");
            security.Exchange = security.Exchange.Replace("AMERICANSTOCKEXCHANGE", "AMEX");

            return security;
        }
    }
}
