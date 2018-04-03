
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
    public class CoreController : Controller
    {
        private ICSPRNGServer _csprng;
        private string _connstrWallet;
        private string _connstrRec;
        private string _connstrBlockchain;
        public CoreController(ICSPRNGServer csprng)
        {
            _csprng = csprng;
            _connstrWallet = Config.ConnWallet;
            _connstrRec = Config.ConnRec;
            _connstrBlockchain = Config.ConnBlockchain;
        }

        [HttpPost("[action]")]
        public IActionResult GetTimeline(string guid, string sharedid)
        {

            if (!Helper.IsCallerValid(guid, sharedid, _connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "ErrInvalid";
                ro.error = true;
                return Json(ro);
            }
            string errorMessage = "";
            bool isError = false;


            //get addresses
            //select unspent outputs
            //sum and return

            List<TimelineRecord> timeline = new List<TimelineRecord>();

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {

                NpgsqlCommand cmd = new NpgsqlCommand("sp_timelinebyuser", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                NpgsqlDataReader reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    TimelineRecord tr = new TimelineRecord();

                    tr.TimelineType = reader.GetString(0);
                    if (!reader.IsDBNull(1))
                    {
                        tr.TransactionId = reader.GetString(1);
                    }
                    tr.UserName = reader.GetString(2);
                    if (!reader.IsDBNull(3))
                    {
                        tr.InvoiceId = reader.GetInt32(3);
                    }
                    tr.TimelineDate = reader.GetDateTime(4);

                    if (!reader.IsDBNull(5))
                    {
                        tr.Amount = reader.GetInt64(5);
                    }

                    if (!reader.IsDBNull(6))
                    {
                        tr.BlockNumber = reader.GetInt32(6);
                    }

                    if (!reader.IsDBNull(7))
                    {
                        tr.UserNameImage = reader.GetString(7);
                    }

                    if (!reader.IsDBNull(8))
                    {
                        tr.InvoiceStatus = reader.GetInt32(8);
                    }

                    if (!reader.IsDBNull(9))
                    {
                        tr.InvoiceStatusR = reader.GetInt32(9);
                    }



                    timeline.Add(tr);

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



            NpgsqlConnection connBlk = new NpgsqlConnection(_connstrBlockchain);
            connBlk.Open();
            int lastBlock = 0;
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

            }
            catch (Exception ex)
            {

                isError = true;
                errorMessage = "Database related Error";
            }
            finally
            {
                connBlk.Close();
            }

            foreach (TimelineRecord record in timeline)
            {
                if (record.BlockNumber > 0)
                {
                    record.Confirmations = (lastBlock - record.BlockNumber) + 1;
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
                return Json(timeline);
            }


        }
        
        [HttpPost("[action]")]
        public IActionResult GetVersion()
        {

            bool walletConnErr = false;
            string walletConnectRes = WalletConnect(out walletConnErr);

            bool blockChainConnErr = false;
            int blockNumber = 0;
            DateTime lastUpd = DateTime.MinValue;
            string blockChainConnectRes = BlockchainConnect(out blockChainConnErr, out blockNumber, out lastUpd);

            string errorMessage = "";
            bool isError = false;

            if (isError)
            {
                ErrorObject ro = new ErrorObject();
                ro.message = errorMessage;
                ro.error = true;
                return Json(ro);
             }

            int memPool = 0;
            int donePool = 0;
            DateTime startTime = DateTime.Now;
            DateTime lastUpdated = DateTime.Now;
            string errListener = GetListenerStats(out memPool, out donePool, out startTime, out lastUpdated);


            DateTime notifierLastUpdated = DateTime.Now;
            string errNotifier = GetNotifierStats(out notifierLastUpdated);

            VersionInfo info = new VersionInfo();

            info.Version = "0.0.1";
            info.StartTime = startTime;
            info.WalletConnect =!walletConnErr;
            info.WalletConnectError = walletConnectRes;
            info.BlockchainConnect = !blockChainConnErr;
            info.BlockchainConnectError = blockChainConnectRes;
            info.BlockNumber = blockNumber;
            info.LastUpd = lastUpd;
            return Json(info);

        }

        public string GetListenerStats(out int memPool, out int donePool, out DateTime startTime, out DateTime lastUpdated)
        {

            string err = "";
            memPool = 0;
            donePool = 0;

            startTime = DateTime.Now;
            lastUpdated = DateTime.Now;

            return err;

        }


        public string GetNotifierStats(out DateTime lastUpdated)
        {

            lastUpdated = DateTime.Now;

            return "";

        }

        public string WalletConnect(out bool error)
        {

            string errorMessage = "";

            //test connection to database
            bool walletConnect = true;
            try
            {
                NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
                conn.Open();
                try
                {
                    NpgsqlCommand cmd = new NpgsqlCommand("sp_doesUserNameExist", conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new NpgsqlParameter("p_username", "NinkiBen"));
                    cmd.ExecuteNonQuery();

                }
                catch (Exception ex)
                {
                    walletConnect = false;
                    errorMessage = ex.Message;
                }
                finally
                {
                    conn.Close();
                }

            }
            catch (Exception ex)
            {
                walletConnect = false;
                errorMessage = ex.Message;
            }

            if (walletConnect)
            {
                error = false;
                return "ok";
            }
            else
            {
                error = true;
                return errorMessage;
            }

        }

        public string BlockchainConnect(out bool error, out int blockNumber, out DateTime lastUpd)
        {

            string errorMessage = "";

            //test connection to database
            bool blockchainConnect = true;
            blockNumber = 0;
            lastUpd = DateTime.MinValue;

            try
            {
                NpgsqlConnection conn = new NpgsqlConnection(_connstrBlockchain);
                conn.Open();
                try
                {
                    NpgsqlCommand cmd = new NpgsqlCommand("sp_getLastRead", conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    NpgsqlDataReader reader = cmd.ExecuteReader();
                    if (reader.HasRows)
                    {
                        reader.Read();
                        blockNumber = reader.GetInt32(0);
                        lastUpd = reader.GetDateTime(1);
                    }

                }
                catch (Exception ex)
                {
                    blockchainConnect = false;
                    errorMessage = ex.Message;
                }
                finally
                {
                    conn.Close();
                }

            }
            catch (Exception ex)
            {
                blockchainConnect = false;
                errorMessage = ex.Message;
            }

            if (blockchainConnect)
            {
                error = false;
                return "ok";
            }
            else
            {
                error = true;
                return errorMessage;
            }

        }
    }

}