
using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using System;
using Org.BouncyCastle.Crypto;
using Org.BouncyCastle.Crypto.Prng;
using Org.BouncyCastle.Crypto.Digests;
using Org.BouncyCastle.Crypto.Engines;
using System.Data.SqlClient;
using System.Data;
using Npgsql;
using NpgsqlTypes;

namespace ninki_net_core.API.Controllers
{

    [Route("api/[controller]")]
    public class InvoiceController : Controller
    {
        private ICSPRNGServer _csprng;
        private string _connstrWallet;
        private string _connstrRec;
        private string _connstrBlockchain;
        public InvoiceController(ICSPRNGServer csprng)
        {
            _csprng = csprng;
            _connstrWallet = Config.ConnWallet;
            _connstrRec = Config.ConnRec;
            _connstrBlockchain = Config.ConnBlockchain;
        }

        [HttpPost("[action]")]
        public IActionResult GetInvoicesByUser([FromForm] string guid, [FromForm] string sharedid)
        {

            if (!Helper.IsCallerValid(guid, sharedid, _connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "Invalid";
                ro.error = true;
                return Json(ro);
            }


            string errorMessage = "";
            bool isError = false;


            //get addresses
            //select unspent outputs
            //sum and return

            List<Invoice> ret = new List<Invoice>();
            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {
                string sql = "sp_getinvoicesbyuser";
                NpgsqlCommand cmd = new NpgsqlCommand(sql, conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                NpgsqlDataReader reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    Invoice inv = new Invoice();
                    inv.InvoiceFrom = reader.GetString(0);
                    inv.InvoiceId = reader.GetInt32(1);
                    inv.InvoiceDate = reader.GetDateTime(2);
                    inv.InvoiceStatus = reader.GetInt32(3);
                    if (!reader.IsDBNull(4))
                    {
                        inv.InvoicePaidDate = reader.GetDateTime(4);
                    }
                    if (!reader.IsDBNull(5))
                    {
                        inv.TransactionId = reader.GetString(5);
                    }
                    inv.Packet = reader.GetString(6);
                    ret.Add(inv);

                }


            }
            catch (Exception ex)
            {
                isError = true;
                errorMessage = "Database related Error";
            }
            finally
            {
                conn.Close();
            }


            if (isError)
            {
                ErrorObject ro = new ErrorObject();
                ro.message = errorMessage;
                ro.error = true;
                return Json(ro);
            }
            else
            {
                return Json(ret);
            }

        }


        [HttpPost("[action]")]
        public IActionResult GetInvoicesByUserNetwork([FromForm] string guid, [FromForm] string sharedid, [FromForm] string username)
        {

            if (!Helper.IsCallerValid(guid, sharedid, _connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "Invalid";
                ro.error = true;
                return Json(ro);
            }

            List<Invoice> ret = new List<Invoice>();

            string errorMessage = "";
            bool isError = false;



            //get addresses
            //select unspent outputs
            //sum and return


            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {
                string sql = "sp_getinvoicesbyusernetwork";
                NpgsqlCommand cmd = new NpgsqlCommand(sql, conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_username", username));
                NpgsqlDataReader reader = cmd.ExecuteReader();

                int counter = 0;
                while (reader.Read())
                {

                    Invoice inv = new Invoice();
                    inv.InvoiceFrom = reader.GetString(0);
                    inv.InvoiceId = reader.GetInt32(1);
                    inv.InvoiceDate = reader.GetDateTime(2);
                    inv.InvoiceStatus = reader.GetInt32(3);
                    if (!reader.IsDBNull(4))
                    {
                        inv.InvoicePaidDate = reader.GetDateTime(4);
                    }
                    if (!reader.IsDBNull(5))
                    {
                        inv.TransactionId = reader.GetString(5);
                    }
                    inv.Packet = reader.GetString(6);
                    ret.Add(inv);
                    counter++;

                }


            }
            catch (Exception ex)
            {
                isError = true;
                errorMessage = "Database related Error";
            }
            finally
            {
                conn.Close();
            }


            if (isError)
            {
                ErrorObject ro = new ErrorObject();
                ro.message = errorMessage;
                ro.error = true;
                return Json(ro);
            }
            else
            {
                return Json(ret);
            }


        }

        [HttpPost("[action]")]
        public IActionResult GetInvoicesToPay([FromForm] string guid, [FromForm] string sharedid)
        {

            if (!Helper.IsCallerValid(guid, sharedid, _connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "Invalid";
                ro.error = true;
                return Json(ro);
            }

            string errorMessage = "";
            bool isError = false;

            List<Invoice> ret = new List<Invoice>();
            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {
                string sql = "sp_getinvoicestopay";
                NpgsqlCommand cmd = new NpgsqlCommand(sql, conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                NpgsqlDataReader reader = cmd.ExecuteReader();



                while (reader.Read())
                {


                    Invoice inv = new Invoice();
                    inv.InvoiceFrom = reader.GetString(0);
                    inv.InvoiceId = reader.GetInt32(1);
                    inv.InvoiceDate = reader.GetDateTime(2);
                    inv.InvoiceStatus = reader.GetInt32(3);
                    if (!reader.IsDBNull(4))
                    {
                        inv.InvoicePaidDate = reader.GetDateTime(4);
                    }
                    if (!reader.IsDBNull(5))
                    {
                        inv.TransactionId = reader.GetString(5);
                    }
                    inv.Packet = reader.GetString(6);
                    ret.Add(inv);



                }


            }
            catch (Exception ex)
            {
                isError = true;
                errorMessage = "Database related Error";
            }
            finally
            {
                conn.Close();
            }


            if (isError)
            {
                ErrorObject ro = new ErrorObject();
                ro.message = errorMessage;
                ro.error = true;
                return Json(ro);
            }
            else
            {
                return Json(ret);
            }


        }

        [HttpPost("[action]")]
        public IActionResult GetInvoicesToPayNetwork([FromForm] string guid, [FromForm] string sharedid, [FromForm] string username)
        {

            if (!Helper.IsCallerValid(guid, sharedid, _connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "Invalid";
                ro.error = true;
                return Json(ro);
            }


            string errorMessage = "";
            bool isError = false;

            //get addresses
            //select unspent outputs
            //sum and return

            List<Invoice> ret = new List<Invoice>();
            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {
                string sql = "sp_getinvoicestopaynetwork";
                NpgsqlCommand cmd = new NpgsqlCommand(sql, conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_username", username));

                NpgsqlDataReader reader = cmd.ExecuteReader();


                while (reader.Read())
                {

                    Invoice inv = new Invoice();
                    inv.InvoiceFrom = reader.GetString(0);
                    inv.InvoiceId = reader.GetInt32(1);
                    inv.InvoiceDate = reader.GetDateTime(2);
                    inv.InvoiceStatus = reader.GetInt32(3);
                    if (!reader.IsDBNull(4))
                    {
                        inv.InvoicePaidDate = reader.GetDateTime(4);
                    }
                    if (!reader.IsDBNull(5))
                    {
                        inv.TransactionId = reader.GetString(5);
                    }
                    inv.Packet = reader.GetString(6);
                    ret.Add(inv);

                }


            }
            catch (Exception ex)
            {
                isError = true;
                errorMessage = "Database related Error";
            }
            finally
            {
                conn.Close();
            }


            if (isError)
            {
                ErrorObject ro = new ErrorObject();
                ro.message = errorMessage;
                ro.error = true;
                return Json(ro);
            }
            else
            {
                return Json(ret);
            }


        }


        [HttpPost("[action]")]
        public IActionResult CreateInvoice([FromForm] string guid, [FromForm] string sharedid, [FromForm] string UserName, [FromForm] string PacketForMe, [FromForm] string PacketForThem)
        {

            if (!Helper.IsCallerValid(guid, sharedid, _connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "Invalid";
                ro.error = true;
                return Json(ro);
            }


            string errorMessage = "";
            bool isError = false;
            string cacheKey = "";
            string cacheKeyNet1 = "";
            string cacheKeyNet2 = "";

            int invoiceId = 0;
            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();

            try
            {

                NpgsqlCommand cmd = new NpgsqlCommand("sp_createinvoice", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_username", UserName));
                cmd.Parameters.Add(new NpgsqlParameter("p_invoicedate", DateTime.Now));
                int tinvstat = 0;
                cmd.Parameters.Add(new NpgsqlParameter("p_invoicestatus", tinvstat));
                cmd.Parameters.Add(new NpgsqlParameter("p_invoicepaiddate", DBNull.Value));
                cmd.Parameters.Add(new NpgsqlParameter("p_transactionid", DBNull.Value));
                cmd.Parameters.Add(new NpgsqlParameter("p_packetforme", PacketForMe));
                cmd.Parameters.Add(new NpgsqlParameter("p_packetforthem", PacketForThem));

                NpgsqlDataReader reader = cmd.ExecuteReader();

                if (reader.HasRows)
                {
                    reader.Read();

                    //get the reverse cache key
                    //so cache can be invalidated / updated in the in memory cache
                    string theirWalletId = reader.GetString(0);
                    string myUserName = reader.GetString(1);

                    cacheKey = theirWalletId;
                    cacheKeyNet1 = Helper.hashGuid(theirWalletId + myUserName);


                }

                reader.Dispose();


            }
            catch (Exception ex)
            {
                isError = true;
                errorMessage = "ErrSystem";

            }
            finally
            {
                conn.Close();
            }

            if (isError)
            {
                ErrorObject err = new ErrorObject();
                err.message = errorMessage;
                err.error = true;
                return Json(err);
            }
            else
            {
                CreateInvoiceReturnObject ro = new CreateInvoiceReturnObject();
                ro.CacheKey = cacheKey;
                ro.CacheKeyNet = cacheKeyNet1;
                return Json(ro);
            }

        }

        [HttpPost("[action]")]
        public IActionResult UpdateInvoice([FromForm] string guid, [FromForm] string sharedid, [FromForm] string userName, [FromForm] int invoiceId, [FromForm] string transactionId, [FromForm] int status)
        {

            if (!Helper.IsCallerValid(guid, sharedid, _connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "Invalid";
                ro.error = true;
                return Json(ro);
            }

            if (transactionId == null){
                transactionId = "";
            }

            string errorMessage = "";
            bool isError = false;
            string cacheKey = "";
            string cacheKeyNet1 = "";

            string UserId = "";
            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {
                NpgsqlCommand cmd = new NpgsqlCommand("sp_updateinvoice", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_invoicestatus", status));

                cmd.Parameters.Add(new NpgsqlParameter("p_transactionid", transactionId));
                cmd.Parameters.Add(new NpgsqlParameter("p_invoicepaiddate", DateTime.Now));
                cmd.Parameters.Add(new NpgsqlParameter("p_username", userName));
                cmd.Parameters.Add(new NpgsqlParameter("p_invoiceid", invoiceId));

                NpgsqlDataReader reader = cmd.ExecuteReader();

                if (reader.HasRows)
                {
                    reader.Read();

                    //get the reverse cache key
                    //so cache can be invalidated / updated in the in memory cache

                    string theirWalletId = reader.GetString(0);
                    string myUserName = reader.GetString(1);

                    cacheKey = theirWalletId;
                    cacheKeyNet1 = Helper.hashGuid(theirWalletId + myUserName);
                }

                reader.Dispose();

            }
            catch (Exception ex)
            {
                isError = true;
                errorMessage = "ErrSystem";

            }
            finally
            {
                conn.Close();
            }


            if (isError)
            {
                ErrorObject err = new ErrorObject();
                err.message = errorMessage;
                err.error = true;
                return Json(err);
            }
            else
            {
                CreateInvoiceReturnObject ro = new CreateInvoiceReturnObject();
                ro.CacheKey = cacheKey;
                ro.CacheKeyNet = cacheKeyNet1;
                return Json(ro);
            }
        }



    }
}