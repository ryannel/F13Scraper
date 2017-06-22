using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using HtmlAgilityPack;
using Newtonsoft.Json;
using StockScraper.Utils;

namespace StockScraper.Helpers.WebSearch.YahooFinance.Pages
{
    class Summary
    {
        internal static HtmlDocument Get(string searchTerm)
        {
            string url = Util.BuildBaseUrl(searchTerm);
            return Util.PageLoad(url);
        }

        public static JsonApi.RootObject GetJson(string searchTerm)
        {
            string url = Util.BuildSummaryApiUrl(searchTerm);

            string response = GetJsonString(url);
            return (response != null) ? JsonConvert.DeserializeObject<JsonApi.RootObject>(response) : null;
        }

        internal static string GetJsonString(string url)
        {
            string json = null;

            using (var webClient = new PersistantWebClient())
            {
                try
                {
                    json = webClient.DownloadString(url);
                }
                catch (WebException error)
                {
                    // 404 is expected, indicates that no results were found.
                    if (error.Status != WebExceptionStatus.ProtocolError)
                    {
                        throw;
                    }
                }
            }

            return json;
        }

        internal static string GetHeaderDescription(HtmlDocument summaryPage)
        {
            return summaryPage.DocumentNode.SelectNodes("//*[@id='quote-header-info']/div[1]/div[1]/div/h1")?[0].InnerText;
        }

        internal static string GetName(HtmlDocument summaryPage)
        {
            string description = GetHeaderDescription(summaryPage);
            return description?.Split('(')[0].Trim();
        }

        internal static string GetSymbol(HtmlDocument summaryPage)
        {
            string description = GetHeaderDescription(summaryPage);
            return description?.Split('(')[1].Replace(")", string.Empty).Trim();
        }

        internal static string GetExchange(HtmlDocument summaryPage)
        {
            string exchangeDescription = summaryPage.DocumentNode.SelectNodes("//*[@id='quote-header-info']/div[1]/div[1]/span/span")?[0].InnerText;
            return exchangeDescription?.Split('-')[0].Trim();
        }

        internal static string GetIndustry(JsonApi.RootObject summaryJson)
        {
            if (summaryJson?.quoteSummary.error != null) return null;

            string industry = summaryJson?.quoteSummary.result[0].summaryProfile?.industry;
            return string.IsNullOrEmpty(industry) ? null : industry;
        }

        internal static string GetSector(JsonApi.RootObject summaryJson)
        {
            if (summaryJson?.quoteSummary.error != null) return null;

            string sector = summaryJson?.quoteSummary.result[0].summaryProfile?.sector;
            return string.IsNullOrEmpty(sector) ? null : sector;
        }
    }
}
