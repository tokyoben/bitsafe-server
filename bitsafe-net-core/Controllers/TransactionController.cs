#define Test

using System.Collections.Generic;
using System.Linq;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Text;
using Org.BouncyCastle.Crypto;
using Org.BouncyCastle.Crypto.Prng;
using Org.BouncyCastle.Crypto.Digests;
using Org.BouncyCastle.Crypto.Engines;
using Org.BouncyCastle.Bcpg.OpenPgp;
using Org.BouncyCastle.Bcpg;
using System.Data.SqlClient;
using System.Data;
using System.IO;
using System.Threading.Tasks;
using System.Net;
using Newtonsoft.Json.Linq;
using Npgsql;
using NpgsqlTypes;


namespace ninki_net_core.API.Controllers
{

    [Route("api/[controller]")]
    public class TransactionController : Controller
    {

        private ICSPRNGServer _csprng;
        private string _connstrWallet;
        private string _connstrRec;
        private string _connstrBlockchain;

        private string _connNode;
        public TransactionController(ICSPRNGServer csprng)
        {
            _csprng = csprng;
            _connstrWallet = Config.ConnWallet;
            _connstrRec = Config.ConnRec;
            _connstrBlockchain = Config.ConnBlockchain;
            _connNode = Config.ConnNode;
        }

        [HttpPost("[action]")]
        public IActionResult GetBalance([FromForm] string guid, [FromForm] string sharedid)
        {

            DateTime start = DateTime.Now;

            if (!Helper.IsCallerValid(guid, sharedid, _connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "ErrInvalid";
                ro.error = true;
                return Json(ro);
            }

            double balance = 0;
            double unconfirmedBalance = 0;
            //get addresses
            //select unspent outputs
            //sum and return
            string errorMessage = "";
            bool isError = false;
            List<string> addresses = new List<string>();
            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {
                NpgsqlCommand cmd = new NpgsqlCommand("sp_addressesbyaccount", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                NpgsqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    addresses.Add(reader.GetString(0));
                }
                reader.Dispose();

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

            if (addresses.Count > 0)
            {
                conn = new NpgsqlConnection(_connstrBlockchain);
                conn.Open();

                try
                {
                    foreach (string address in addresses)
                    {
                        NpgsqlCommand cmd = new NpgsqlCommand("sp_amountsforaddress", conn);
                        cmd.CommandType = CommandType.StoredProcedure;
                        NpgsqlParameter param = new NpgsqlParameter();
                        param.ParameterName = "p_address";
                        param.NpgsqlDbType = NpgsqlDbType.Varchar;
                        param.Value = address;

                        cmd.Parameters.Add(param);
                        NpgsqlDataReader reader = cmd.ExecuteReader();
                        while (reader.Read())
                        {
                            balance += Decimal.ToDouble(reader.GetDecimal(0));
                        }
                        reader.Dispose();

                        cmd = new NpgsqlCommand("sp_amountsforaddressnoncon", conn);
                        cmd.CommandType = CommandType.StoredProcedure;
                        param = new NpgsqlParameter();
                        param.ParameterName = "p_address";
                        param.NpgsqlDbType = NpgsqlDbType.Varchar;
                        param.Value = address;

                        cmd.Parameters.Add(param);
                        reader = cmd.ExecuteReader();
                        while (reader.Read())
                        {
                            unconfirmedBalance += Decimal.ToDouble(reader.GetDecimal(0));
                        }
                        reader.Dispose();


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

                BalanceReturnObject bal = new BalanceReturnObject();
                bal.ConfirmedBalance = balance;
                bal.UnconfirmedBalance = unconfirmedBalance;
                bal.TotalBalance = balance + unconfirmedBalance;
                return Json(bal);
            }

        }

        [HttpPost("[action]")]
        public IActionResult GetTransactionFeed(string guid, string sharedid)
        {
            DateTime start = DateTime.Now;

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

            List<TransactionRecord> records = new List<TransactionRecord>();
            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {

                NpgsqlCommand cmd = new NpgsqlCommand("sp_transactionsforfeed", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                NpgsqlDataReader reader = cmd.ExecuteReader();


                //first get the transaction ids
                //then populate the block numbers the transaction was found in
                //calc the number of confirmations

                while (reader.Read())
                {
                    TransactionRecord tr = new TransactionRecord();
                    tr.TransactionId = reader.GetString(0);
                    tr.OutputIndex = reader.GetInt32(1);
                    tr.TransDateTime = reader.GetDateTime(2);
                    tr.Amount = reader.GetInt64(3);
                    tr.Address = reader.GetString(4);
                    tr.UserName = reader.GetString(5);
                    tr.TransType = reader.GetString(6);
                    tr.Status = reader.GetInt32(7);
                    if (reader.IsDBNull(8))
                    {
                        tr.BlockNumber = 0;
                    }
                    else
                    {
                        tr.BlockNumber = reader.GetInt32(8);
                    }
                    if (!reader.IsDBNull(9))
                    {
                        tr.InvoiceId = reader.GetInt32(9);
                    }

                    if (!reader.IsDBNull(10))
                    {
                        tr.UserNameImage = reader.GetString(10);
                    }

                    if (!reader.IsDBNull(11))
                    {
                        tr.MinersFee = reader.GetInt64(11);
                    }

                    records.Add(tr);


                }
                reader.Dispose();
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


            DateTime stop = DateTime.Now;
            Console.WriteLine("GetTransactionRecords - After Wallet");
            Console.WriteLine(stop.Subtract(start).TotalMilliseconds);


            int lastBlock = 0;


            //update the blockchain inputs as ispending to prevent them from being reused
            NpgsqlConnection connBlk = new NpgsqlConnection(_connstrBlockchain);
            connBlk.Open();

            stop = DateTime.Now;
            Console.WriteLine("GetTransactionRecords - After connect Blockchain");
            Console.WriteLine(stop.Subtract(start).TotalMilliseconds);
            try
            {
                //get the block number

                NpgsqlCommand cmdlr = new NpgsqlCommand("select RunningBlockIndex from LastRead", connBlk);
                NpgsqlDataReader rd = cmdlr.ExecuteReader();

                if (rd.Read())
                {
                    lastBlock = rd.GetInt32(0);
                }
                rd.Dispose();

                Console.WriteLine("GetTransactionRecords - After query Blockchain");
                Console.WriteLine(stop.Subtract(start).TotalMilliseconds);
            }
            catch
            {
                isError = true;
                errorMessage = "Database related Error";
            }
            finally
            {
                connBlk.Close();
            }


            stop = DateTime.Now;
            Console.WriteLine("GetTransactionRecords - After Blockchain");
            Console.WriteLine(stop.Subtract(start).TotalMilliseconds);

            if (!isError)
            {

                int counter = 0;
                long balance = 0;
                foreach (TransactionRecord record in records)
                {
                    record.Confirmations = lastBlock - record.BlockNumber;
                    // exclude RBF transactions
                    if (record.Status != 4 && (!(record.BlockNumber == 0 && record.Status == 3 && record.TransType == "R")))
                    {
                        if (record.BlockNumber == 0)
                        {
                            record.Confirmations = 0;
                        }
                        else
                        {
                            record.Confirmations = (lastBlock - record.BlockNumber) + 1;
                        }
                        counter++;

                    }
                }


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
                return Json(records);
            }

        }

        [HttpPost("[action]")]
        public IActionResult GetTransactionsForNetwork([FromForm] string guid,[FromForm]  string sharedid, [FromForm] string username)
        {
            DateTime start = DateTime.Now;

            if (!Helper.IsCallerValid(guid, sharedid, _connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "Invalid";
                ro.error = true;
                return Json(ro);
            }

            string errorMessage = "";
            bool isError = false;

            string json = "";

            //get addresses
            //select unspent outputs
            //sum and return

            List<TransactionRecord> records = new List<TransactionRecord>();
            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {

                NpgsqlCommand cmd = new NpgsqlCommand("sp_transactionsfornetwork", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_username", username));

                NpgsqlDataReader reader = cmd.ExecuteReader();


                //first get the transaction ids
                //then populate the block numbers the transaction was found in
                //calc the number of confirmations

                while (reader.Read())
                {
                    TransactionRecord tr = new TransactionRecord();
                    tr.TransactionId = reader.GetString(0);
                    tr.OutputIndex = reader.GetInt32(1);
                    tr.TransDateTime = reader.GetDateTime(2);
                    tr.Amount = reader.GetInt64(3);
                    tr.Address = reader.GetString(4);
                    tr.UserName = reader.GetString(5);
                    tr.TransType = reader.GetString(6);
                    tr.Status = reader.GetInt32(7);
                    if (reader.IsDBNull(8))
                    {
                        tr.BlockNumber = 0;
                    }
                    else
                    {
                        tr.BlockNumber = reader.GetInt32(8);
                    }
                    if (!reader.IsDBNull(9))
                    {
                        tr.InvoiceId = reader.GetInt32(9);
                    }

                    if (!reader.IsDBNull(10))
                    {
                        tr.MinersFee = reader.GetInt64(10);
                    }


                    records.Add(tr);
                }
                reader.Dispose();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                isError = true;
                errorMessage = "Database related Error";
            }
            finally
            {
                conn.Close();
            }


            DateTime stop = DateTime.Now;
            Console.WriteLine("GetTransactionRecords - After Wallet");
            Console.WriteLine(stop.Subtract(start).TotalMilliseconds);


            int lastBlock = 0;


            //update the blockchain inputs as ispending to prevent them from being reused
            NpgsqlConnection connBlk = new NpgsqlConnection(_connstrBlockchain);
            connBlk.Open();

            stop = DateTime.Now;
            Console.WriteLine("GetTransactionRecords - After connect Blockchain");
            Console.WriteLine(stop.Subtract(start).TotalMilliseconds);
            try
            {
                //get the block number

                NpgsqlCommand cmdlr = new NpgsqlCommand("select RunningBlockIndex from LastRead", connBlk);
                NpgsqlDataReader rd = cmdlr.ExecuteReader();

                if (rd.Read())
                {
                    lastBlock = rd.GetInt32(0);
                }
                rd.Dispose();

                Console.WriteLine("GetTransactionRecords - After query Blockchain");
                Console.WriteLine(stop.Subtract(start).TotalMilliseconds);
            }
            catch
            {
                isError = true;
                errorMessage = "Database related Error";
            }
            finally
            {
                connBlk.Close();
            }


            stop = DateTime.Now;
            Console.WriteLine("GetTransactionRecords - After Blockchain");
            Console.WriteLine(stop.Subtract(start).TotalMilliseconds);

            if (!isError)
            {

                foreach (TransactionRecord record in records)
                {
                    record.Confirmations = lastBlock - record.BlockNumber;
                    // exclude RBF transactions
                    if (record.Status != 4 && (!(record.BlockNumber == 0 && record.Status == 3 && record.TransType == "R")))
                    {
                        if (record.BlockNumber == 0)
                        {
                            record.Confirmations = 0;
                        }
                        else
                        {
                            record.Confirmations = (lastBlock - record.BlockNumber) + 1;
                        }
                    
                    }
                }

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
                return Json(records);
            }

        }


        [HttpPost("[action]")]
        public IActionResult PrepareTransaction([FromForm] string guid, [FromForm] string sharedid, [FromForm] long amount)
        {
            
            if (!Helper.IsCallerValid(guid, sharedid, _connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "Invalid";
                ro.error = true;
                return Json(ro);
            }

            DateTime dNow1hr = DateTime.Now.AddHours(-1);

            string userid = "";

            string errorMessage = "";
            bool isError = false;

            long DailyTransactionLimit = 0;
            long SingleTransactionLimit = 0;
            long NoOfTransactionsPerDay = 0;
            long NoOfTransactionsPerHour = 0;

            long tranamount = 0;
            long noTran24 = 0;
            long noTran1hr = 0;

            long feelow = 0;
            long feemed = 0;
            long feehigh = 0;

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {
                NpgsqlCommand cmd = new NpgsqlCommand("sp_accountlimitsbyaccount", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                NpgsqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SingleRow);
                if (reader.HasRows)
                {
                    reader.Read();
                    if (!reader.IsDBNull(0))
                    {
                        DailyTransactionLimit = reader.GetInt64(0);
                    }
                    if (!reader.IsDBNull(1))
                    {
                        SingleTransactionLimit = reader.GetInt64(1);
                    }
                    if (!reader.IsDBNull(2))
                    {
                        NoOfTransactionsPerDay = reader.GetInt32(2);
                    }
                    if (!reader.IsDBNull(3))
                    {
                        NoOfTransactionsPerHour = reader.GetInt32(3);
                    }

                }
                reader.Dispose();

                cmd = new NpgsqlCommand("sp_userIdByAccount", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    reader.Read();
                    userid = reader.GetString(0);

                }
                else
                {
                    isError = true;
                    errorMessage = "ErrAccount";
                }
                reader.Dispose();

                //check daily limits
                //need to think about the definition of a day-- lets do last 24 hours
                //index here?
                NpgsqlCommand cmdtran = new NpgsqlCommand("sp_transactionSendAfterDate", conn);
                cmdtran.CommandType = CommandType.StoredProcedure;
                cmdtran.Parameters.Add(new NpgsqlParameter("p_userid", userid));
                cmdtran.Parameters.Add(new NpgsqlParameter("p_transdatetime", DateTime.Now.AddDays(-1)));
                NpgsqlDataReader readerTran = cmdtran.ExecuteReader();

                if (readerTran.HasRows)
                {
                    while (readerTran.Read())
                    {
                        tranamount += readerTran.GetInt64(0);

                        if (readerTran.GetDateTime(1) > dNow1hr)
                        {
                            noTran1hr++;
                        }

                        noTran24++;
                    }
                }
                readerTran.Dispose();

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


            List<string> addresses = new List<string>();
            Dictionary<string, string> nodeLevels = new Dictionary<string, string>();

            conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {
                NpgsqlCommand cmd = new NpgsqlCommand("sp_addressesByAccount", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                NpgsqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    string add = reader.GetString(0);
                    addresses.Add(add);

                    if (!nodeLevels.ContainsKey(add))
                    {
                        nodeLevels.Add(add, reader.GetString(1));

                    }
                }
                reader.Dispose();
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



            List<TransactionOutput> unspentOutputs = new List<TransactionOutput>();
            List<TransactionOutput> unspentOutputsNc = new List<TransactionOutput>();

            if (addresses.Count > 0)
            {
                conn = new NpgsqlConnection(_connstrBlockchain);
                conn.Open();


                //jsonWriter.WriteStartArray();

                try
                {

                    foreach (string address in addresses)
                    {
                        NpgsqlCommand cmd = new NpgsqlCommand("sp_unspentOutputsForAddress", conn);
                        cmd.CommandType = CommandType.StoredProcedure;
                        NpgsqlParameter param = new NpgsqlParameter();
                        param.ParameterName = "p_address";
                        param.NpgsqlDbType = NpgsqlDbType.Varchar;
                        param.Value = address;
                        cmd.Parameters.Add(param);
                        NpgsqlDataReader reader = cmd.ExecuteReader();



                        while (reader.Read())
                        {


                            TransactionOutput tout = new TransactionOutput();
                            tout.TransactionId = reader.GetString(0);
                            tout.OutputIndex = reader.GetInt32(1);
                            tout.Amount = Decimal.ToInt64(reader.GetDecimal(2));
                            tout.Address = reader.GetString(3);
                            tout.NodeLevel = nodeLevels[tout.Address];
                            tout.IsPending = false;

                            bool ispending = false;
                            if (!reader.IsDBNull(4))
                            {
                                if (Convert.ToBoolean(reader.GetInt32(4)))
                                {
                                    ispending = true;
                                }
                            }

                            if (!ispending)
                            {
                                unspentOutputs.Add(tout);
                            }
                        }
                        reader.Dispose();



                        cmd = new NpgsqlCommand("sp_unspentNonConOutputsForAddress", conn);
                        cmd.CommandType = CommandType.StoredProcedure;
                        param = new NpgsqlParameter();
                        param.ParameterName = "p_address";
                        param.NpgsqlDbType = NpgsqlDbType.Varchar;
                        param.Value = address;
                        cmd.Parameters.Add(param);
                        reader = cmd.ExecuteReader();

                        while (reader.Read())
                        {

                            TransactionOutput toutnc = new TransactionOutput();
                            toutnc.TransactionId = reader.GetString(0);
                            toutnc.OutputIndex = reader.GetInt32(1);
                            toutnc.Amount = Decimal.ToInt64(reader.GetDecimal(2));
                            toutnc.Address = reader.GetString(3);
                            toutnc.NodeLevel = nodeLevels[toutnc.Address];
                            toutnc.IsPending = true;

                            //if (toutnc.NodeLevel.StartsWith("m/0/1"))
                            //{
                            unspentOutputsNc.Add(toutnc);
                            //}

                        }
                        reader.Dispose();



                        //select the current fee profile

                        //
                        cmd = new NpgsqlCommand("sp_getFees", conn);
                        cmd.CommandType = CommandType.StoredProcedure;
                        reader = cmd.ExecuteReader();

                        if (reader.HasRows)
                        {
                            if (reader.Read())
                            {

                                feelow = reader.GetInt64(0);
                                feemed = reader.GetInt64(1);
                                feehigh = reader.GetInt64(2);

                            }

                        }

                        reader.Dispose();

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

            }


            unspentOutputs = unspentOutputs.OrderBy(uo => uo.Amount).ToList();

            unspentOutputs.AddRange(unspentOutputsNc);

            long totsofar = 0;
            int noofouts = 0;
            foreach (TransactionOutput txo in unspentOutputs)
            {
                totsofar += txo.Amount;
                noofouts++;
                if (totsofar > amount)
                {
                    break;

                }
            }

            long slack = totsofar - amount;


            TransactionPrep prep = new TransactionPrep();
            prep.DailyTransactionLimit = DailyTransactionLimit;
            prep.SingleTransactionLimit = SingleTransactionLimit;
            prep.NoOfTransactionsPerDay = NoOfTransactionsPerDay;
            prep.NoOfTransactionsPerHour = NoOfTransactionsPerHour;
            prep.DailyTransactionLimitBreach = (tranamount >= DailyTransactionLimit);
            prep.NoOfTransactionsPerDayBreach = (noTran24 >= NoOfTransactionsPerDay);
            prep.NoOfTransactionsPerHourBreach = (noTran1hr >= NoOfTransactionsPerHour);
            prep.TotalAmount24hr = tranamount;
            prep.No24hr = noTran24;
            prep.No1hr = noTran1hr;
            prep.NoOfOuts = noofouts;
            prep.Slack = slack;
            prep.FeeLow = feelow;
            prep.FeeMed = feemed;
            prep.FeeHigh = feehigh;

            if (isError)
            {
                ErrorObject ro = new ErrorObject();
                ro.message = errorMessage;
                ro.error = true;
                return Json(ro);
            }
            else
            {
                return Json(prep);
            }
        }


        [HttpPost("[action]")]
        public IActionResult GetLimitStatus([FromForm] string guid, [FromForm] string sharedid)
        {

            DateTime dNow1hr = DateTime.Now.AddHours(-1);

            string userid = "";

            string errorMessage = "";
            bool isError = false;

            long DailyTransactionLimit = 0;
            long SingleTransactionLimit = 0;
            long NoOfTransactionsPerDay = 0;
            long NoOfTransactionsPerHour = 0;

            long tranamount = 0;
            long noTran24 = 0;
            long noTran1hr = 0;

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {
                NpgsqlCommand cmd = new NpgsqlCommand("sp_accountLimitsByAccount", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                NpgsqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SingleRow);
                if (reader.HasRows)
                {
                    reader.Read();
                    if (!reader.IsDBNull(0))
                    {
                        DailyTransactionLimit = reader.GetInt64(0);
                    }
                    if (!reader.IsDBNull(1))
                    {
                        SingleTransactionLimit = reader.GetInt64(1);
                    }
                    if (!reader.IsDBNull(2))
                    {
                        NoOfTransactionsPerDay = reader.GetInt32(2);
                    }
                    if (!reader.IsDBNull(3))
                    {
                        NoOfTransactionsPerHour = reader.GetInt32(3);
                    }

                }
                reader.Dispose();

                cmd = new NpgsqlCommand("sp_userIdByAccount", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                reader = cmd.ExecuteReader(CommandBehavior.SingleRow);
                if (reader.HasRows)
                {
                    reader.Read();
                    userid = reader.GetGuid(0).ToString();

                }
                else
                {
                    isError = true;
                    errorMessage = "ErrAccount";
                }
                reader.Dispose();

                //check daily limits
                //need to think about the definition of a day-- lets do last 24 hours
                //index here?
                NpgsqlCommand cmdtran = new NpgsqlCommand("sp_transactionSendAfterDate", conn);
                cmdtran.CommandType = CommandType.StoredProcedure;
                cmdtran.Parameters.Add(new NpgsqlParameter("p_userid", userid));
                cmdtran.Parameters.Add(new NpgsqlParameter("p_TransDateTime", DateTime.Now.AddDays(-1)));
                NpgsqlDataReader readerTran = cmdtran.ExecuteReader();

                if (readerTran.HasRows)
                {
                    while (readerTran.Read())
                    {
                        tranamount += readerTran.GetInt64(0);

                        if (readerTran.GetDateTime(1) > dNow1hr)
                        {
                            noTran1hr++;
                        }

                        noTran24++;
                    }
                }
                readerTran.Dispose();

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

            TransactionPrep prep = new TransactionPrep();
            prep.DailyTransactionLimit = DailyTransactionLimit;
            prep.SingleTransactionLimit = SingleTransactionLimit;
            prep.NoOfTransactionsPerDay = NoOfTransactionsPerDay;
            prep.NoOfTransactionsPerHour = NoOfTransactionsPerHour;
            prep.DailyTransactionLimitBreach = (tranamount >= DailyTransactionLimit);
            prep.NoOfTransactionsPerDayBreach = (noTran24 >= NoOfTransactionsPerDay);
            prep.NoOfTransactionsPerHourBreach = (noTran1hr >= NoOfTransactionsPerHour);
            prep.TotalAmount24hr = tranamount;
            prep.No24hr = noTran24;
            prep.No1hr = noTran1hr;
            

            if (isError)
            {
                return  Json(new ErrorObject(errorMessage));
            }
            else
            {
                return Json(prep);
            }
        }

        [HttpPost("[action]")]
        public IActionResult GetUnspentOutputs([FromForm] string guid, [FromForm] string sharedid)
        {


            if (!Helper.IsCallerValid(guid, sharedid, _connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "Invalid";
                ro.error = true;
                return Json(ro);
            }



            string json = "";


            //get addresses
            //select unspent outputs
            //sum and return
            string errorMessage = "";
            bool isError = false;
            List<string> addresses = new List<string>();
            Dictionary<string, string> nodeLevels = new Dictionary<string, string>();
            Dictionary<string, string> pk1 = new Dictionary<string, string>();
            Dictionary<string, string> pk2 = new Dictionary<string, string>();
            Dictionary<string, string> pk3 = new Dictionary<string, string>();

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {
                NpgsqlCommand cmd = new NpgsqlCommand("sp_addressesByAccount", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                NpgsqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    string add = reader.GetString(0);
                    addresses.Add(add);

                    if (!nodeLevels.ContainsKey(add))
                    {
                        nodeLevels.Add(add, reader.GetString(1));

                        if (!reader.IsDBNull(2))
                        {
                            pk1.Add(add, reader.GetString(2));
                            pk2.Add(add, reader.GetString(3));
                            pk3.Add(add, reader.GetString(4));
                        }
                    }
                }
                reader.Dispose();
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



            List<TransactionOutput> unspentOutputs = new List<TransactionOutput>();
            List<TransactionOutput> unspentOutputsNc = new List<TransactionOutput>();

            if (addresses.Count > 0)
            {
                conn = new NpgsqlConnection(_connstrBlockchain);
                conn.Open();


                //jsonWriter.WriteStartArray();

                try
                {

                    foreach (string address in addresses)
                    {
                        NpgsqlCommand cmd = new NpgsqlCommand("sp_unspentOutputsForAddress", conn);
                        cmd.CommandType = CommandType.StoredProcedure;
                        NpgsqlParameter param = new NpgsqlParameter();
                        param.ParameterName = "p_address";
                        param.NpgsqlDbType = NpgsqlDbType.Varchar;
                        param.Value = address;
                        cmd.Parameters.Add(param);
                        NpgsqlDataReader reader = cmd.ExecuteReader();



                        while (reader.Read())
                        {


                            TransactionOutput tout = new TransactionOutput();
                            tout.TransactionId = reader.GetString(0);
                            tout.OutputIndex = reader.GetInt32(1);
                            tout.Amount = Decimal.ToInt64(reader.GetDecimal(2));
                            tout.Address = reader.GetString(3);
                            tout.NodeLevel = nodeLevels[tout.Address];
                            tout.IsPending = false;
                            if (pk1.ContainsKey(tout.Address))
                            {
                                tout.PK1 = Helper.Decrypt(pk1[tout.Address],_csprng);
                                tout.PK2 = Helper.Decrypt(pk2[tout.Address],_csprng);
                                tout.PK3 = Helper.Decrypt(pk3[tout.Address],_csprng);
                            }

                            bool ispending = false;
                            if (!reader.IsDBNull(4))
                            {
                                if (reader.GetBoolean(4))
                                {
                                    ispending = true;
                                }
                            }

                            if (!ispending)
                            {
                                unspentOutputs.Add(tout);
                            }
                        }
                        reader.Dispose();



                        cmd = new NpgsqlCommand("sp_unspentNonConOutputsForAddress", conn);
                        cmd.CommandType = CommandType.StoredProcedure;
                        param = new NpgsqlParameter();
                        param.ParameterName = "p_address";
                        param.NpgsqlDbType = NpgsqlDbType.Varchar;
                        param.Value = address;
                        cmd.Parameters.Add(param);
                        reader = cmd.ExecuteReader();



                        while (reader.Read())
                        {


                            TransactionOutput toutnc = new TransactionOutput();
                            toutnc.TransactionId = reader.GetString(0);
                            toutnc.OutputIndex = reader.GetInt32(1);
                            toutnc.Amount = Decimal.ToInt64(reader.GetDecimal(2));
                            toutnc.Address = reader.GetString(3);
                            toutnc.NodeLevel = nodeLevels[toutnc.Address];
                            toutnc.IsPending = true;

                            if (pk1.ContainsKey(toutnc.Address))
                            {
                                toutnc.PK1 = Helper.Decrypt(pk1[toutnc.Address],_csprng);
                                toutnc.PK2 = Helper.Decrypt(pk2[toutnc.Address],_csprng);
                                toutnc.PK3 = Helper.Decrypt(pk3[toutnc.Address],_csprng);
                            }

                            //if (toutnc.NodeLevel.StartsWith("m/0/1") || guid == "a958134e68399ac9e9113747667c48a96498ed52c075ab7916c52fc7d5d21d10")
                            //{
                                unspentOutputsNc.Add(toutnc);
                           // }

                        }
                        reader.Dispose();


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

            }


            unspentOutputs = unspentOutputs.OrderBy(uo => uo.Amount).ToList();

            unspentOutputs.AddRange(unspentOutputsNc);

            if (isError)
            {
                ErrorObject ro = new ErrorObject();
                ro.message = errorMessage;
                ro.error = true;
                return Json(ro);
            }

            return Json(unspentOutputs);

        }

        [HttpPost("[action]")]
        public IActionResult SendTransaction([FromForm] string jsonPacket, [FromForm] string sharedid, [FromForm] string userName, [FromForm] bool twoFactor)
        {

            
            var jo = JObject.Parse(jsonPacket);

            string guid = jo["guid"].ToString();
            
            string[] hashesForSigning = jo["hashesForSigning"].ToObject<string[]>();
            string[] pathsToSignWith = jo["pathsToSignWith"].ToObject<string[]>();
            

            string rawTransaction = jo["rawTransaction"].ToString();


            if (!Helper.IsCallerValid(guid, sharedid, _connstrWallet))
            {
                return Json(new ErrorObject("Invalid"));
            }

            if(userName==null){
                userName = "";
            }

            string userid = "";
            string useridFriend = "";
            string walletidFriend = "";
            string errorMessage = "";
            string myUserName = "";
            bool isError = false;

            string theirPublicKey = "";

            long DailyTransactionLimit = 0;
            long SingleTransactionLimit = 0;
            long NoOfTransactionsPerDay = 0;
            long NoOfTransactionsPerHour = 0;

            bool doesRelationshipExist = false;
            bool hasRelationshipBeenVerified = false;
            string validationCode = "";

            bool isAddressValidForFriend = false;

            string addressToSendTo = "";
            string changeAddress = "";
            bool changeAddressValid = false;

            string addressToSendToNode = "";
            string changeAddressNode = "";

            ulong totalToSend = 0;
            long tranamount = 0;
            long noTran24 = 0;
            long noTran1hr = 0;

            bool isLocked = false;


            DateTime dNow1hr = DateTime.Now.AddHours(-1);

            Transaction tran = new Transaction(HexString.ToByteArray(rawTransaction));


            //**check removed - should detect non standard transactions...
            //if (tran.outputs.Length > 2)
            //{
            //    return new MemoryStream(Encoding.UTF8.GetBytes(getErrorJSON("ErrInvalidTransaction")));
            //}


            //get inputs from blockchain and validate miners fee


            //grok the miners fee
            //make sure it isn't over their limit


            //sp_unspentNonConOutputForInput
            //sp_unspentOutputForInput
            //@TransactionId varchar(128), @outputIndex int
            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);

            conn = new NpgsqlConnection(_connstrBlockchain);
            conn.Open();


            //jsonWriter.WriteStartArray();
            decimal totin = 0;
            decimal totout = 0;
            try
            {

                foreach (TxIn inp in tran.inputs)
                {
                    NpgsqlCommand cmd = new NpgsqlCommand("sp_unspentOutputForInput", conn);
                    cmd.CommandType = CommandType.StoredProcedure;

                    NpgsqlParameter param = new NpgsqlParameter();
                    param.ParameterName = "p_transactionid";
                    param.NpgsqlDbType = NpgsqlDbType.Varchar;

                    NpgsqlParameter param2 = new NpgsqlParameter();
                    param2.ParameterName = "p_outputindex";
                    param2.NpgsqlDbType = NpgsqlDbType.Integer;

                    param.Value = HexString.FromByteArray(inp.prevOut.hash.Reverse().ToArray());
                    param2.Value = inp.prevOutIndex;

                    cmd.Parameters.Add(param);
                    cmd.Parameters.Add(param2);

                    NpgsqlDataReader reader = cmd.ExecuteReader();

                    if (!reader.HasRows)
                    {

                        reader.Dispose();

                        cmd = new NpgsqlCommand("sp_unspentNonConOutputForInput", conn);
                        cmd.CommandType = CommandType.StoredProcedure;

                        param = new NpgsqlParameter();
                        param.ParameterName = "p_transactionid";
                        param.NpgsqlDbType = NpgsqlDbType.Varchar;

                        param2 = new NpgsqlParameter();
                        param2.ParameterName = "p_outputindex";
                        param2.NpgsqlDbType = NpgsqlDbType.Integer;

                        param.Value = HexString.FromByteArray(inp.prevOut.hash.Reverse().ToArray());
                        param2.Value = inp.prevOutIndex;

                        cmd.Parameters.Add(param);
                        cmd.Parameters.Add(param2);

                        reader = cmd.ExecuteReader();

                        if (reader.Read())
                        {

                            totin += reader.GetDecimal(0);
                        }

                        reader.Dispose();

                    }
                    else
                    {

                        if (reader.Read())
                        {

                            totin += reader.GetDecimal(0);
                        }

                        reader.Dispose();
                    }

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


            foreach (TxOut ops in tran.outputs)
            {
                totout += ops.value;
            }



            long minersFee = (long)(totin - totout);

            if (minersFee > 200000)
            {
                return Json(new ErrorObject("ErrFeeTooHigh"));
            }


            //later add invoice only send rules
            //get the miner fee limit here

            conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {
                NpgsqlCommand cmd = new NpgsqlCommand("sp_accountLimitsByAccount", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                NpgsqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SingleRow);
                if (reader.HasRows)
                {
                    reader.Read();
                    if (!reader.IsDBNull(0))
                    {
                        DailyTransactionLimit = reader.GetInt64(0);
                    }
                    if (!reader.IsDBNull(1))
                    {
                        SingleTransactionLimit = reader.GetInt64(1);
                    }
                    if (!reader.IsDBNull(2))
                    {
                        NoOfTransactionsPerDay = reader.GetInt32(2);
                    }
                    if (!reader.IsDBNull(3))
                    {
                        NoOfTransactionsPerHour = reader.GetInt32(3);
                    }

                }
                reader.Dispose();

                cmd = new NpgsqlCommand("sp_userIdByAccount", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                reader = cmd.ExecuteReader(CommandBehavior.SingleRow);
                if (reader.HasRows)
                {
                    reader.Read();
                    userid = reader.GetString(0);
                    myUserName = reader.GetString(1);
                }
                else
                {
                    isError = true;
                    errorMessage = "ErrAccount";
                }
                reader.Dispose();




                if (userName.Length > 0)
                {

                    cmd = new NpgsqlCommand("sp_userDetailsByUserName", conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new NpgsqlParameter("p_username", userName));
                    reader = cmd.ExecuteReader(CommandBehavior.SingleRow);
                    if (reader.HasRows)
                    {
                        reader.Read();
                        useridFriend = reader.GetString(0);
                        walletidFriend = reader.GetString(1);
                        theirPublicKey = reader.GetString(2);
                    }
                    else
                    {
                        isError = true;
                        errorMessage = "ErrAccount";
                    }
                    reader.Dispose();


                    //make sure the user account is not locked

                    //sp_getAccountLocked
                    //get the public key fingerprint the sender used to verify his friend
                    cmd = new NpgsqlCommand("sp_getAccountLocked", conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new NpgsqlParameter("p_guid", walletidFriend));
                    reader = cmd.ExecuteReader();
                    if (reader.HasRows)
                    {
                        reader.Read();
                        if (!reader.IsDBNull(0))
                        {
                            if (reader.GetInt32(0) == 1)
                            {
                                isLocked = true;
                            }
                        }
                    }

                    reader.Dispose();


                    //get the public key fingerprint the sender used to verify his friend
                    cmd = new NpgsqlCommand("sp_validationHashForFriend", conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new NpgsqlParameter("p_userid", useridFriend));
                    cmd.Parameters.Add(new NpgsqlParameter("p_useridfriend", userid));
                    reader = cmd.ExecuteReader();
                    if (reader.HasRows)
                    {
                        doesRelationshipExist = true;

                        reader.Read();
                        if (!reader.IsDBNull(0))
                        {
                            validationCode = reader.GetString(0);
                        }
                        else
                        {
                            isError = true;
                        }

                    }
                    else
                    {
                        isError = true;
                    }
                    reader.Dispose();

                }

                foreach (TxOut output in tran.outputs)
                {
                    //now check the address table for the next leaf
                    //do do this we have to look up the wallet if of the friend we are deriving the address for
                    cmd = new NpgsqlCommand("sp_addressesByAccountAddress", conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                    cmd.Parameters.Add(new NpgsqlParameter("p_address", output.GetAddress()));
                    reader = cmd.ExecuteReader(CommandBehavior.SingleResult);
                    if (!reader.HasRows)
                    {
                        totalToSend += output.value;
                        addressToSendTo = output.GetAddress();
                    }
                    else
                    {
                        reader.Read();
                        changeAddress = output.GetAddress();
                        changeAddressNode = reader.GetString(1);
                        changeAddressValid = true;
                    }
                    reader.Dispose();
                }
                if (tran.outputs.Length == 2)
                {
                    if (!changeAddressValid)
                    {
                        return Json(new ErrorObject("ErrInvalidTransaction"));
                    }
                }

                //if (!addressToSendTo.StartsWith("1") && !addressToSendTo.StartsWith("3"))
                //{
                //    return new MemoryStream(Encoding.UTF8.GetBytes(getErrorJSON("ErrInvalidTransaction")));
                //}


                if (userName.Length > 0)
                {
                    foreach (TxOut output in tran.outputs)
                    {
                        //now check the address table for the next leaf
                        //do do this we have to look up the wallet of of the friend we are deriving the address for
                        //
                        cmd = new NpgsqlCommand("sp_addressesByAccountAddress", conn);
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add(new NpgsqlParameter("p_guid", walletidFriend));
                        cmd.Parameters.Add(new NpgsqlParameter("p_address", output.GetAddress()));
                        reader = cmd.ExecuteReader();
                        if (reader.HasRows)
                        {
                            reader.Read();
                            addressToSendTo = output.GetAddress();
                            addressToSendToNode = reader.GetString(1);
                            isAddressValidForFriend = true;
                        }
                        reader.Dispose();
                    }
                }
                else
                {
                    isAddressValidForFriend = true;
                    //make sure the address isn't a ninki user address
                    //if it is then reject the transaction as someone is putting a
                    //ninki address into the send to anyone box
                    //foreach (TxOut output in tran.outputs)
                    //{
                    //    //now check the address table for the next leaf
                    //    //do do this we have to look up the wallet of of the friend we are deriving the address for
                    //    //
                    //    cmd = new NpgsqlCommand("sp_accountByAddress", conn);
                    //    cmd.CommandType = CommandType.StoredProcedure;
                    //    cmd.Parameters.Add(new NpgsqlParameter("p_address", output.Address()));
                    //    reader = cmd.ExecuteReader(CommandBehavior.SingleResult);
                    //    if (reader.HasRows)
                    //    {
                    //        reader.Read();
                    //        string testWalletid = reader.GetString(0);
                    //        string testBranch = reader.GetString(1);
                    //        if (testWalletid == guid && (testBranch == "m/0/1" || testBranch == "m/0/0"))
                    //        {
                    //            //this is ok and is the change address
                    //        }
                    //        else
                    //        {
                    //            //this is not good, one of the addresses is a ninki address but no userName has been supplied
                    //            isAddressValidForFriend = false;
                    //        }
                    //    }
                    //    reader.Close();
                    //}

                }


                //check daily limits
                //need to think about the definition of a day-- lets do last 24 hours
                //index here?
                NpgsqlCommand cmdtran = new NpgsqlCommand("sp_transactionSendAfterDate", conn);
                cmdtran.CommandType = CommandType.StoredProcedure;
                cmdtran.Parameters.Add(new NpgsqlParameter("p_userid", userid));
                cmdtran.Parameters.Add(new NpgsqlParameter("p_transdatetime", DateTime.Now.AddDays(-1)));
                NpgsqlDataReader readerTran = cmdtran.ExecuteReader();

                if (readerTran.HasRows)
                {
                    while (readerTran.Read())
                    {
                        tranamount += readerTran.GetInt64(0);

                        if (readerTran.GetDateTime(1) > dNow1hr)
                        {
                            noTran1hr++;
                        }

                        noTran24++;
                    }
                }
                readerTran.Dispose();

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


            //if the system state matches the request then continue
            if (isError)
            {
                return Json(new ErrorObject("ErrInvalidTransaction"));
            }

            if (isLocked)
            {
                return Json(new ErrorObject("ErrLocked"));
                
            }

            if (!isAddressValidForFriend)
            {
                return Json(new ErrorObject("ErrInvalidTransaction"));
            }

            //if this is a ninki network transaction
            //verify the relationship

            hasRelationshipBeenVerified = false;

            //publicKeyFriend
            if (userName.Length > 0)
            {

                if (validationCode == "")
                {
                    return Json(new ErrorObject("ErrInvalidTransaction"));
                    
                }

                //string salt = hashGuid(userName);

                theirPublicKey = Helper.Decrypt(theirPublicKey,_csprng);
                //RSA rsa = System.Security.Cryptography.RSA.Create();
                //pgppub.txt

                Stream strpub = new MemoryStream(Encoding.UTF8.GetBytes(theirPublicKey));

                string fingerprint = "";

                using (Stream inputStream = PgpUtilities.GetDecoderStream(strpub))
                {
                    PgpPublicKeyRingBundle publicKeyRingBundle = new PgpPublicKeyRingBundle(inputStream);
                    PgpPublicKey foundKey = GetFirstPublicKey(publicKeyRingBundle);
                    fingerprint = HexString.FromByteArray(foundKey.GetFingerprint());
                }


                strpub.Dispose();

                if (validationCode != fingerprint)
                {
                    return Json(new ErrorObject("ErrInvalidTransaction"));
                }


            }

            //skip this if a 2fa code has been provided

            if (!twoFactor)
            {
                if (totalToSend > (ulong)SingleTransactionLimit)
                {
                    return Json(new ErrorObject("ErrSingleTransactionLimit"));
                }

                if (tranamount >= DailyTransactionLimit)
                {
                    return Json(new ErrorObject("ErrDailyTransactionLimit"));
                }

                if (noTran24 >= NoOfTransactionsPerDay)
                {
                    return Json(new ErrorObject("ErrTransactionsPerDayLimit"));
                    
                }

                if (noTran1hr >= NoOfTransactionsPerHour)
                {
                    return Json(new ErrorObject("ErrTransactionsPerHourLimit"));
                }
            }

            Console.WriteLine("Enter Send Transaction");

            DateTime start = DateTime.Now;

            string[] sigs = new string[pathsToSignWith.Length];

            try
            {
                for (int i = 0; i < pathsToSignWith.Length; i++)
                {
                    string path = pathsToSignWith[i];

                    start = DateTime.Now;
                    //ECKeyPair key = GetDerivedPrivateKey(guid, path);
                    string key = GetDerivedPrivateKey(guid, path);

                    Console.WriteLine("Derive Key: " + start.Subtract(DateTime.Now).TotalMilliseconds);

                    start = DateTime.Now;
                    //string sigt = MultiSig.GetSignature(key, hashesForSigning[i]);
                    string sig = MultiSig.GetSignature2(key, hashesForSigning[i], _csprng.Getsecp256k1());

                    Console.WriteLine("Sign hash: " + start.Subtract(DateTime.Now).TotalMilliseconds);

                    sigs[i] = sig;
                }
            }
            catch (Exception ex)
            {
                return Json(new ErrorObject("ErrSignature"));
            }


            //should probably use a database transaction here....
            try
            {

                //low-S the signatures
                //sigs[0] = LowSSigs(sigs[0]);

                rawTransaction = convertTxUserSigToLowS(rawTransaction);

                string rawTran = MultiSig.AppendSignatures(sigs, rawTransaction);

                Console.WriteLine("Process tran: " + start.Subtract(DateTime.Now).TotalMilliseconds);
                Console.WriteLine("http://" + _connNode + ":18332");
                BitnetClient bc = new BitnetClient("http://" + _connNode + ":18332");
                bc.Credentials = new NetworkCredential("bitcoinrpc", "Czo7zcwL3ruNH7TH2w4ZHqqmEjzo6DqjPLek6pYE3eAQ");

                //JObject newadd = bc.CreateMultiSigAddress("", 2, addr);

                string btcret = "";

                try
                {
                    start = DateTime.Now;
                    Task<string>  result =  bc.SendRawTransaction(rawTran);
                    result.Wait();
                    btcret = result.Result;
                    Console.WriteLine("Send tran: " + start.Subtract(DateTime.Now).TotalMilliseconds);
                }
                catch (Exception ex)
                {

                    Console.WriteLine("Broadcast failed");

                    Console.WriteLine(ex.Message);

                    return Json(new ErrorObject("ErrBroadcastFailed"));
                }





                if (btcret.Length == 64)
                {

                    List<string> conflictedTransactions = new List<string>();

                    string taguser = "External";
                    if (userName.Length > 0)
                    {
                        taguser = userName;

                    }


                    //update the blockchain inputs as ispending to prevent them from being reused
                    conn = new NpgsqlConnection(_connstrBlockchain);
                    conn.Open();


                    //jsonWriter.WriteStartArray();

                    try
                    {

                        foreach (TxIn inp in tran.inputs)
                        {

                            string inputtxid = HexString.FromByteArray(inp.prevOut.hash.Reverse().ToArray());

                            NpgsqlCommand cmd = new NpgsqlCommand("sp_setOutputsPending", conn);
                            cmd.CommandType = CommandType.StoredProcedure;

                            NpgsqlParameter param = new NpgsqlParameter();
                            param.ParameterName = "p_transactionid";
                            param.NpgsqlDbType = NpgsqlDbType.Varchar;

                            NpgsqlParameter param2 = new NpgsqlParameter();
                            param2.ParameterName = "p_index";
                            param2.NpgsqlDbType = NpgsqlDbType.Integer;

                            NpgsqlParameter param3 = new NpgsqlParameter();
                            param3.ParameterName = "p_mastertransactionid";
                            param3.NpgsqlDbType = NpgsqlDbType.Varchar;

                            param.Value = inputtxid;
                            param2.Value = inp.prevOutIndex;
                            param3.Value = btcret;

                            cmd.Parameters.Add(param);
                            cmd.Parameters.Add(param2);
                            cmd.Parameters.Add(param3);
                            cmd.ExecuteNonQuery();


                            NpgsqlCommand cmdTransInputs = new NpgsqlCommand("SELECT TransactionId FROM TranInputsNonCon where PrevTransactionId = @PrevTransactionId and PrevTransOutputIndex = @PrevTransOutputIndex", conn);
                            cmdTransInputs.Parameters.Add(new NpgsqlParameter("@PrevTransactionId", inputtxid));
                            cmdTransInputs.Parameters.Add(new NpgsqlParameter("@PrevTransOutputIndex", (long)inp.prevOutIndex));
                            NpgsqlDataReader tireader = cmdTransInputs.ExecuteReader();

                            if (tireader.HasRows)
                            {
                                while (tireader.Read())
                                {
                                    string titxid = tireader.GetString(0);
                                    if (titxid != btcret)
                                    {
                                        conflictedTransactions.Add(titxid);
                                    }

                                }
                            }

                            tireader.Dispose();

                        }

                        //possible that they have been invlaidated by a RBF but no guarantee that they won't be confirmed
                        foreach (string conflictedTransaction in conflictedTransactions)
                        {
                            NpgsqlCommand cmdTransInputs = new NpgsqlCommand("update TranOutputs_NonCon set IsSpent = 2 where TransactionId = @TransactionId ", conn);
                            cmdTransInputs.Parameters.Add(new NpgsqlParameter("@TransactionId", conflictedTransaction));
                            cmdTransInputs.ExecuteNonQuery();
                        }



                        int j = 0;
                        foreach (TxOut ops in tran.outputs)
                        {

                            NpgsqlCommand cmdTransOutputs = new NpgsqlCommand("sp_createTranOutputs_NonCon", conn);
                            cmdTransOutputs.CommandType = CommandType.StoredProcedure;
                            cmdTransOutputs.Parameters.Add(new NpgsqlParameter("p_transactionid", btcret));
                            cmdTransOutputs.Parameters.Add(new NpgsqlParameter("p_outputindex", j));
                            cmdTransOutputs.Parameters.Add(new NpgsqlParameter("p_amount", (long)ops.value));
                            cmdTransOutputs.Parameters.Add(new NpgsqlParameter("p_address", ops.GetAddress()));
                            cmdTransOutputs.ExecuteNonQuery();
                            j++;
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

                    //really really need to merge these databases :(
                    NpgsqlConnection connWallet = new NpgsqlConnection(_connstrWallet);
                    connWallet.Open();
                    try
                    {
                        NpgsqlCommand com = new NpgsqlCommand("sp_createTransactionRecord", connWallet);

                        NpgsqlParameter param = new NpgsqlParameter();
                        param.ParameterName = "p_outputindex";
                        param.DbType = DbType.Int32;
                        param.Value = 0;

                        com.CommandType = CommandType.StoredProcedure;
                        com.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                        com.Parameters.Add(new NpgsqlParameter("p_username", taguser));
                        com.Parameters.Add(new NpgsqlParameter("p_transactionid", btcret));
                        com.Parameters.Add(param);
                        com.Parameters.Add(new NpgsqlParameter("p_transdatetime", DateTime.Now));
                        com.Parameters.Add(new NpgsqlParameter("p_amount", (long)totalToSend));
                        com.Parameters.Add(new NpgsqlParameter("p_address", addressToSendTo));
                        int tmp = 0;
                        com.Parameters.Add(new NpgsqlParameter("p_notified", tmp));
                        com.Parameters.Add(new NpgsqlParameter("p_blocknumber", tmp));
                        com.Parameters.Add(new NpgsqlParameter("p_minersfee", minersFee));

                        //activate change addresses and sendto addresses for network sends
                        int i = 0;
                        foreach (TxOut ops in tran.outputs)
                        {
                            NpgsqlCommand cmdTransOutputs = new NpgsqlCommand("update AccountAddress set IsActive = 1 where RefAddress = @Address", connWallet);
                            cmdTransOutputs.CommandType = CommandType.Text;
                            cmdTransOutputs.Parameters.Add(new NpgsqlParameter("@Address", ops.GetAddress()));
                            cmdTransOutputs.ExecuteNonQuery();
                            i++;
                        }

                        com.ExecuteNonQuery();

                        foreach (string conflictedTransaction in conflictedTransactions)
                        {


                            //set transaction to RBF status
                            //this could be undone if another transaction in the RBF set is confirmed
                            NpgsqlCommand cmdTransInputs = new NpgsqlCommand("update UserTransactions set Status = 3 where TransactionId = @TransactionId and TransType = 'S'", connWallet);
                            cmdTransInputs.Parameters.Add(new NpgsqlParameter("@TransactionId", conflictedTransaction));
                            cmdTransInputs.ExecuteNonQuery();
                        }


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

                }



                string nettrankey = "";

                if (walletidFriend.Length > 0)
                {
                    nettrankey = Helper.hashGuid(walletidFriend + myUserName);
                }


                SendTransactionReturnObject ret =  new SendTransactionReturnObject();
                ret.TransactionId = btcret;
                ret.CacheKey = walletidFriend;
                ret.NetCacheKey = nettrankey;


                Console.WriteLine("Exit Send Transaction");
                return Json(ret);
            }
            catch (Exception ex)
            {
                return Json(new ErrorObject("ErrFailed"));
            }

        }

        private string GetDerivedPrivateKey(string guid, string path, string type = "eckey")
        {

            DateTime start = DateTime.Now;

            string errorMessage = "";
            bool isError = false;
            //verify path
            foreach (char item in path)
            {
                if (!(Char.IsDigit(item) || item == '/' || item == 'm'))
                {
                    return "";
                }
            }


            string[] spath = path.Split('/');
            string root = "";
            for (int i = 0; i < spath.Length - 1; i++)
            {
                root += spath[i] + '/';
            }
            root = root.Substring(0, root.Length - 1);
            string NinkiMasterPrivateKey = "";
            string NinkiMasterPublicKey = "";

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {
                NpgsqlCommand cmd = new NpgsqlCommand("sp_keyCacheByAccount", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_nodelevel", root));
                NpgsqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SingleRow);
                if (reader.HasRows)
                {
                    reader.Read();
                    NinkiMasterPrivateKey = reader.GetString(0);
                    NinkiMasterPublicKey = reader.GetString(1);
                }
                else
                {
                    isError = true;
                    errorMessage = "ErrAccount";
                }

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

            start = DateTime.Now;
            string NinkiMasterPrivateKeyDecrypt = Helper.Decrypt(NinkiMasterPrivateKey,_csprng);
            NinkiMasterPublicKey = Helper.Decrypt(NinkiMasterPublicKey,_csprng);
            Console.WriteLine("NinkiMasterPrivateKeyDecrypt: " + DateTime.Now.Subtract(start).TotalMilliseconds);


            if (isError)
            {
                // return errorMessage;
            }

            string derivedNinki = null;

            try
            {


                start = DateTime.Now;
                //pass in both keys for the performance gain of not having to derive the public key
                BIP32 bip321 = new BIP32(NinkiMasterPrivateKeyDecrypt, NinkiMasterPublicKey, _csprng.Getsecp256k1());//BIP32 bip3211 = bip321.DerivePrivate(path);

                Console.WriteLine("Ninki Master Create BIP32 Total" + DateTime.Now.Subtract(start).TotalMilliseconds);

                start = DateTime.Now;

                string leaf = spath[spath.Length - 1];

                //this is actually deriving m/0/0/0 as we have started from the cached key
                BIP32 bip3211 = bip321.DerivePrivate("m/" + leaf);
                Console.WriteLine("BIP32 Derive Total:" + DateTime.Now.Subtract(start).TotalMilliseconds);

                if (type == "eckey")
                {
                    derivedNinki = HexString.FromByteArray(bip3211.eckey.privKey);
                }
                else
                {
                    bip3211.BuildExtendedPrivateKey();
                    derivedNinki = bip3211.ExtendedPrivateKeyString(null);
                }


                if (isError)
                {
                    return null;
                }
            }
            catch (Exception ex)
            {
                errorMessage = "ErrSystem";
                return null;
            }


            return derivedNinki;
        }

        private PgpPublicKey GetFirstPublicKey(PgpPublicKeyRingBundle publicKeyRingBundle)
        {
            foreach (PgpPublicKeyRing kRing in publicKeyRingBundle.GetKeyRings())
            {
                PgpPublicKey key = kRing.GetPublicKeys()
                    .Cast<PgpPublicKey>()
                    .Where(k => k.IsEncryptionKey)
                    .FirstOrDefault();
                if (key != null)
                    return key;
            }
            return null;
        }

        private string convertTxUserSigToLowS(string tx)
        {

            Transaction tran = new Transaction(HexString.ToByteArray(tx));
            int i = 0;
            foreach (TxIn input in tran.inputs)
            {
                //input.scriptSig

                Script orignal = new Script(input.scriptSig);

                byte[] userSig = orignal.elements[1].data;


                //convert sig to low-s if necessary
                userSig = LowSSigs(userSig);

                Script s = new Script(new Byte[] { 0x00 });
                //add the signatures to the script
                s.elements.Add(new ScriptElement(userSig));

                //add the original multisig script
                s.elements.Add(new ScriptElement(orignal.elements[2].data));

                //overwrite the script on the transaction with the new signatures + script
                input.scriptSig = s.ToBytes();
                i++;
            }

            return HexString.FromByteArray(tran.ToBytes());

        }


        private byte[] LowSSigs(byte[] dersig)
        {

            //0x30 [total-length] 0x02 [R-length] [R] 0x02 [S-length] [S] [sighash-type]


            var t30 = dersig[0];
            var totalLength = dersig[1];
            var t02 = dersig[2];
            var rlength = dersig[3];

            var r = dersig.Skip(4).Take(rlength).ToArray();

            var t02a = dersig[rlength + 4];
            var slength = dersig[rlength + 5];

            var s = dersig.Skip(rlength + 6).Take(slength).ToArray();

            byte[] ret = dersig;

            if (s[0] == 0)
            {

                string hexHighS = HexString.FromByteArray(s);
                hexHighS = hexHighS.Substring(2);
                //string hexOrder = "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141";

                //BigInteger order = new BigInteger(hexOrder, 16);
                //BigInteger highs = new BigInteger(hexHighS, 16);
                //BigInteger lows = order.Subtract(highs);

                string tlows = _csprng.Getsecp256k1().Negate(hexHighS);

                byte[] blows = HexString.ToByteArray(tlows);

                int diff = s.Length - blows.Length;

                int newlen = totalLength + diff;

                byte[] newder = new byte[1];
                newder[0] = t30;

                newder = newder.Concat(new byte[] { (byte)newlen }).ToArray();
                newder = newder.Concat(new byte[] { (byte)t02 }).ToArray();
                newder = newder.Concat(new byte[] { (byte)rlength }).ToArray();
                newder = newder.Concat(r).ToArray();
                newder = newder.Concat(new byte[] { (byte)t02 }).ToArray();
                newder = newder.Concat(new byte[] { (byte)blows.Length }).ToArray();
                newder = newder.Concat(blows).ToArray();
                newder = newder.Concat(new byte[] { (byte)1 }).ToArray();
                //set the new sig length to exclude the 30, length byte itself and hashtype on the end
                newder[1] = (byte)(newder.Length - 3);
                ret = newder;

                Console.WriteLine("Converted user sig to low-s");
                Console.WriteLine(HexString.FromByteArray(dersig));
                Console.WriteLine(HexString.FromByteArray(newder));

            }

            return ret;

        }

    }

}