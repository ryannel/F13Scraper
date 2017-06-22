using System;
using System.Dynamic;
using System.Web;
using System.Security.Policy;
using HtmlAgilityPack;
using StockScraper.Models;

namespace StockScraper.Helpers.WebSearch.GoogleFinance.Pages
{
    class Summary
    {
        internal static HtmlDocument Get(string searchTerm)
        {
            var url = Util.BuildBaseUrl(searchTerm);
            HtmlDocument summaryPage = Util.PageLoad(url);

            var spellCorrectedSearchTerm = GetSpellingSuggestion(summaryPage);

            if (spellCorrectedSearchTerm != null)
            {
                summaryPage = Get(spellCorrectedSearchTerm);
            }

            return (ValidateSummaryPage(summaryPage)) ? summaryPage: null;
        }

        private static string GetSpellingSuggestion(HtmlDocument summaryPage)
        {
            try
            {
                return summaryPage.DocumentNode.SelectNodes("//*[@id='gf - viewc']/div/div[2]/font/a")[0].InnerText;
            }
            catch (Exception)
            {
                return null;
            }
        }

        private static bool ValidateSummaryPage(HtmlDocument summaryPage)
        {
            bool isValid = true;
            try
            {
                GetHeaderDescription(summaryPage);
            }
            catch
            {
                isValid = false;
            }

            return isValid;
        }

        internal static string GetName(HtmlDocument summaryPage)
        {
            string result = summaryPage.DocumentNode.SelectNodes("//*[@id='appbar']/div/div[2]/div[1]/span")[0].InnerText;
            return HttpUtility.HtmlDecode(result);
        }

        internal static string GetSharePrice(HtmlDocument summaryPage)
        {
            return summaryPage.DocumentNode.SelectNodes("//*[@id='ref_554528_l']")[0].InnerText;
        }

        internal static string GetExchange(HtmlDocument summaryPage)
        {
            var headerDescription = GetHeaderDescription(summaryPage);
            return headerDescription.Split(':')[0];
        }

        internal static string GetSymbol(HtmlDocument summaryPage)
        {
            var headerDescription = GetHeaderDescription(summaryPage);
            return headerDescription.Split(':')[1];
        }

        internal static string GetHeaderDescription(HtmlDocument summaryPage)
        {
            string headerDescription = summaryPage.DocumentNode.SelectNodes("//*[@id='appbar']/div/div[2]/div[2]/span")[0].InnerText;
            headerDescription = headerDescription.Replace(")", string.Empty);
            return headerDescription.Replace("(", string.Empty);
        }

        internal static string GetPeRatio(HtmlDocument summaryPage)
        {
            return summaryPage.DocumentNode.SelectNodes("//*[@id='market-data-div']/div[2]/div[1]/table[1]/tbody/tr[6]/td[2]")[0].InnerText;
        }

        internal static string GetEpsRatio(HtmlDocument summaryPage)
        {
            return summaryPage.DocumentNode.SelectNodes("//*[@id='market - data - div']/div[2]/div[1]/table[2]/tbody/tr[2]/td[2]")[0].InnerText;
        }

        internal static string GetSector(HtmlDocument summaryPage)
        {
            string result = summaryPage.DocumentNode.SelectNodes("//*[@id='sector']")?[0].InnerText;
            return HttpUtility.HtmlDecode(result);
        }

        internal static string GetIndustry(HtmlDocument summaryPage)
        {
            string result = summaryPage.DocumentNode.SelectNodes("//*[@id='related']/div[4]/div/div[1]/a[2]")?[0].InnerText;
            return HttpUtility.HtmlDecode(result);
        }

    }
}
