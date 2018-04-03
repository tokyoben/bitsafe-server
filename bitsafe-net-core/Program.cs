using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Hosting;

namespace ninki_net_core
{
    public class Program
    {
        public static void Main(string[] args)
        {
            
           Console.WriteLine(Environment.GetEnvironmentVariable("PATH"));

            //DatabaseProcedure.TestPostgres();
            Console.WriteLine("Building...");
            var host = new WebHostBuilder()
                .UseKestrel()
                .UseContentRoot(Directory.GetCurrentDirectory())
                .UseIISIntegration()
                .UseStartup<Startup>()
                .UseUrls("http://*:5000/")
                .Build();
            Console.WriteLine("Running...");

            host.Run();

        }
    }
}
