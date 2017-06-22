using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace StockScraper.Utils
{
    public class PersistantWebClient : WebClient
    {
        protected override WebRequest GetWebRequest(Uri uri)
        {
            WebRequest webRequest = base.GetWebRequest(uri);
            webRequest.Timeout = 30 * 60 * 1000; // 30 min
            return webRequest;
        }

        public string PersistantDownloadString(string url, int retry = 1)
        {
            string response;
            try
            {
                response = this.DownloadString(url);
            }
            catch (Exception error)
            {
                if (retry <= 10)
                {
                    Console.WriteLine("");
                    Console.WriteLine("Download failed");
                    Console.WriteLine(error);
                    Console.WriteLine($"Sleping for {retry * 60} seconds before retry.");
                    Thread.Sleep(retry * 60 * 1000);
                    Console.WriteLine($"Retrying, attempt: {retry + 1}");
                    response = PersistantDownloadString(url, retry + 1);
                }
                else
                {
                    Console.WriteLine(error);
                    throw;
                }
            }

            return response;
        }
    }
}
