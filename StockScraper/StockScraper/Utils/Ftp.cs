using System;
using System.IO;
using System.Linq;
using System.Net;
using System.IO.Compression;
using System.Threading;

namespace StockScraper.Utils
{
    public static class Ftp
    {
        public static Stream GetZippedFile(string url)
        {
            var fileStream = GetFileStream(url);
            return UnzipFileStream(fileStream);
        }

        public static Stream GetFileStream(string url)
        {
            Console.WriteLine($"Downloading file from: {url}");
            var request = WebRequest.Create(url);
            request.UseDefaultCredentials = true;
            request.Proxy.Credentials = request.Credentials;

            try
            {
                return request.GetResponse().GetResponseStream();
            }
            catch
            {
                Console.WriteLine("Downloading file failed, retrying in 60 seconds");
                Thread.Sleep(60000);
                return GetFileStream(url);
            }
        }

        public static Stream UnzipFileStream(Stream zippedFileStream)
        {
            Console.WriteLine("Unzipping...");
            var archive = new ZipArchive(zippedFileStream);
            var unzippedData = archive.Entries.First(entry => entry.FullName.EndsWith(".idx", StringComparison.OrdinalIgnoreCase)).Open();
            return unzippedData;
        }
    }
}
