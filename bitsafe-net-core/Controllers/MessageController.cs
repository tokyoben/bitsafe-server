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
    public class MessageController : Controller
    {
        private ICSPRNGServer _csprng;
        private string _connstrWallet;
        private string _connstrRec;
        private string _connstrBlockchain;
        public MessageController(ICSPRNGServer csprng)
        {
            _csprng = csprng;
            _connstrWallet = Config.ConnWallet;
            _connstrRec = Config.ConnRec;
            _connstrBlockchain = Config.ConnBlockchain;
        }

        [HttpPost("[action]")]
        public IActionResult  CreateMessage([FromForm] string guid, [FromForm] string sharedid, [FromForm] string UserName, [FromForm] string PacketForMe, [FromForm] string PacketForThem, [FromForm] string TransactionId)
        {

            if (!Helper.IsCallerValid(guid, sharedid, _connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "Invalid";
                ro.error = true;
                return Json(ro);
            }

            if (TransactionId==null){
                TransactionId = "";
            }

            string errorMessage = "";
            bool isError = false;

            int invoiceId = 0;
            string cacheKey = "";
            string theirWalletId = "";

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();

            try
            {

                NpgsqlCommand cmd = new NpgsqlCommand("sp_createmessage", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_username", UserName));
                cmd.Parameters.Add(new NpgsqlParameter("p_packetforme", PacketForMe));
                cmd.Parameters.Add(new NpgsqlParameter("p_packetforthem", PacketForThem));
                cmd.Parameters.Add(new NpgsqlParameter("p_transactionid", TransactionId));
                NpgsqlDataReader reader = cmd.ExecuteReader();

                if (reader.HasRows)
                {
                    reader.Read();

                    //get the reverse cache key
                    //so cache can be invalidated / updated in the in memory cache
                    theirWalletId = reader.GetString(0);
                    string myUserName = reader.GetString(1);
                    cacheKey = Helper.hashGuid(theirWalletId + myUserName);
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
                CreateMessageReturnObject ro = new CreateMessageReturnObject();
                ro.MessageCacheKey = cacheKey;
                ro.TimelineCacheKey = theirWalletId;
                return Json(ro);
            }

        }


        [HttpPost("[action]")]
        public IActionResult  GetMessagesByUserNetwork([FromForm] string guid, [FromForm] string sharedid, [FromForm] string username)
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

            List<Message> ret =  new List<Message>();

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {
                string sql = "sp_getmessagesbyusernetwork";
                NpgsqlCommand cmd = new NpgsqlCommand(sql, conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_username", username));
                NpgsqlDataReader reader = cmd.ExecuteReader();

                

                while (reader.Read())
                {

                    
                    Message mess = new Message();

                    mess.MessageId = reader.GetInt32(0);
                    mess.UserName = reader.GetString(1);
                    mess.PacketForMe = reader.GetString(2);
                    mess.PacketForThem = reader.GetString(3);
                    mess.CreateDate = reader.GetDateTime(4);

                    if (!reader.IsDBNull(5))
                    {
                        mess.TransactionId = reader.GetString(5);
                    }
                    else
                    {
                        mess.TransactionId = "";
                    }

                    ret.Add(mess);

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


            if (isError)
            {
                ErrorObject err = new ErrorObject();
                err.message = errorMessage;
                err.error = true;
                return Json(err);
            }
            else
            {

                return Json(ret);
            }


        }

    }

}