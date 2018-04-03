using System.Security.Cryptography;
using System.Text;
using System;
using System.Linq;
using System.IO;
using System.Numerics;
using System.Data.SqlClient;
using System.Data;
using Npgsql;


namespace ninki_net_core
{

    public static class DatabaseProcedure
    {

        public static void TestPostgres()
        {
            
            using (var conn = new NpgsqlConnection("Host=postgserv;Port=5432;User Id=postgres;Password=notsafe123;Database=bitsafe"))
            {
                try {
                conn.Open();
                using (var cmd = new NpgsqlCommand())
                {
                    cmd.Connection = conn;

                    cmd.CommandText = "sp_accountByAddress";
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new NpgsqlParameter("p_address", "refaddress"));
                    try
                    {
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                Console.WriteLine(reader.GetString(0));
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine(ex.Message);
                    }
                }
               
                conn.Close();
                }
                 catch(Exception ex){
                      Console.WriteLine(ex.Message);
                 }
            }
        }

    }

}