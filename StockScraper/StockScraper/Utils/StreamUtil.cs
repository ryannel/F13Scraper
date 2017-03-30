using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StockScraper.Utils
{
    class StreamUtil
    {
        public static TextReader SkipLines(TextReader reader, int lines)
        {
            for (var i = 0; i < lines; i++)
            {
                reader.ReadLine();
            }

            return reader;
        }

        public static string ReadText(Stream fileStream)
        {
            var reader = new StreamReader(fileStream);
            string data = reader.ReadToEnd();
            reader.Close();
            fileStream.Close();

            return data;
        }
    }
}
