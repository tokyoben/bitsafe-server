using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using System;
using Org.BouncyCastle.Crypto;
using Org.BouncyCastle.Crypto.Prng;
using Org.BouncyCastle.Crypto.Digests;
using Org.BouncyCastle.Crypto.Engines;
using System.Data.SqlClient;
using System.Data;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;
using Npgsql;
using NpgsqlTypes;

namespace ninki_net_core.API.Controllers
{

    [Route("api/[controller]")]
    public class SettingsController : Controller
    {

        private ICSPRNGServer _csprng;
        private string _connstrWallet;
        private string _connstrRec;
        private string _connstrBlockchain;
        public SettingsController(ICSPRNGServer csprng)
        {
            _csprng = csprng;
            _connstrWallet = Config.ConnWallet;
            _connstrRec = Config.ConnRec;
            _connstrBlockchain = Config.ConnBlockchain;
        }

        [HttpPost("[action]")]
        public IActionResult GetAccountSettings([FromForm] string guid, [FromForm] string sharedid)
        {

            if (!Helper.IsCallerValid(guid, sharedid, _connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "ErrInvalid";
                ro.error = true;
                return Json(ro);
            }

            //retrieves the payload and returns to the client
            //payload is encrypted and only the client knows how to decrypt
            //payload contains all public keys and user hot private key

            string errorMessage = "";
            bool isError = false;

            AccountSetting settings = new AccountSetting();

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {
                NpgsqlCommand cmd = new NpgsqlCommand("sp_accountsettings", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                NpgsqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SingleRow);
                if (reader.HasRows)
                {
                    reader.Read();
                    if (!reader.IsDBNull(1))
                    {
                        settings.Inactivity = reader.GetInt32(1);
                    }
                    if (!reader.IsDBNull(2))
                    {
                        settings.MinersFee = reader.GetInt32(2);
                    }
                    if (!reader.IsDBNull(3))
                    {
                        settings.AutoEmailBackup = Convert.ToBoolean(reader.GetInt32(3));
                    }
                    if (!reader.IsDBNull(4))
                    {
                        settings.Email = reader.GetString(4);
                    }
                    if (!reader.IsDBNull(5))
                    {
                        settings.EmailVerified = Convert.ToBoolean(reader.GetInt32(5));
                    }
                    if (!reader.IsDBNull(6))
                    {
                        settings.Phone = reader.GetString(6);
                    }
                    if (!reader.IsDBNull(7))
                    {
                        settings.PhoneVerified = Convert.ToBoolean(reader.GetInt32(7));
                    }
                    if (!reader.IsDBNull(8))
                    {
                        settings.Language = reader.GetString(8);
                    }
                    if (!reader.IsDBNull(9))
                    {
                        settings.LocalCurrency = reader.GetString(9);
                    }
                    if (!reader.IsDBNull(10))
                    {
                        settings.CoinUnit = reader.GetString(10);
                    }
                    if (!reader.IsDBNull(11))
                    {
                        settings.EmailNotification = Convert.ToBoolean(reader.GetInt32(11));
                    }
                    if (!reader.IsDBNull(12))
                    {
                        settings.PhoneNotification = Convert.ToBoolean(reader.GetInt32(12));
                    }
                    if (!reader.IsDBNull(13))
                    {
                        settings.PasswordHint = reader.GetString(13);
                    }
                    if (!reader.IsDBNull(14))
                    {
                        settings.TwoFactor = Convert.ToBoolean(reader.GetInt32(14));
                    }
                    if (!reader.IsDBNull(15))
                    {
                        settings.TwoFactorType = reader.GetString(15);
                    }
                    if (!reader.IsDBNull(16))
                    {
                        settings.DailyTransactionLimit = reader.GetInt64(16);
                    }
                    if (!reader.IsDBNull(17))
                    {
                        settings.SingleTransactionLimit = reader.GetInt64(17);
                    }
                    if (!reader.IsDBNull(18))
                    {
                        settings.NoOfTransactionsPerDay = reader.GetInt32(18);
                    }
                    if (!reader.IsDBNull(19))
                    {
                        settings.NoOfTransactionsPerHour = reader.GetInt32(19);
                    }

                }
                reader.Dispose();

                int set = 0;
                NpgsqlCommand com = new NpgsqlCommand("sp_getnextbackupindex", conn);
                com.CommandType = CommandType.StoredProcedure;
                com.Parameters.Add(new NpgsqlParameter("p_guid", guid));

                reader = com.ExecuteReader(CommandBehavior.SingleResult);
                if (reader.HasRows)
                {
                    reader.Read();
                    set = reader.GetInt32(0);
                    settings.backupIndex = reader.GetInt32(1);
                }
                reader.Dispose();

                if (set > 0)
                {
                    settings.hasBackupCodes = true;
                }
                //sp_getNextBackupSet

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
                ErrorObject ro = new ErrorObject();
                ro.message = errorMessage;
                ro.error = true;
                return Json(ro);
            }

            return Json(settings);

        }


        [HttpPost("[action]")]
        public IActionResult UpdateAccountSettings([FromForm] string guid, [FromForm] string sharedid, [FromForm] string jsonPacket, [FromForm] bool isAuth)
        {

            var jo = JObject.Parse(jsonPacket);

            AccountSetting settings = JsonConvert.DeserializeObject<AccountSetting>(jsonPacket);
            //AccountSetting settings = (AccountSetting)js.Deserialize(jsonPacket, typeof(WalletSettings));

            if (!Helper.IsCallerValid(guid, sharedid, _connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "ErrInvalid";
                ro.error = true;
                return Json(ro);
            }

            string errorMessage = "";
            bool isError = false;

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {
                NpgsqlCommand cmd = new NpgsqlCommand("sp_updateaccountsettings", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_walletid", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_inactivity", settings.Inactivity));
                cmd.Parameters.Add(new NpgsqlParameter("p_minersfee", settings.MinersFee));
                cmd.Parameters.Add(new NpgsqlParameter("p_autoemailbackup", Convert.ToInt32(settings.AutoEmailBackup)));
                cmd.Parameters.Add(new NpgsqlParameter("p_email", settings.Email));
                cmd.Parameters.Add(new NpgsqlParameter("p_phoneverified", Convert.ToInt32(settings.PhoneVerified)));
                cmd.Parameters.Add(new NpgsqlParameter("p_coinunit", settings.CoinUnit));
                cmd.Parameters.Add(new NpgsqlParameter("p_emailnotification", Convert.ToInt32(settings.EmailNotification)));
                cmd.Parameters.Add(new NpgsqlParameter("p_phonenotification", Convert.ToInt32(settings.PhoneNotification)));
                cmd.Parameters.Add(new NpgsqlParameter("p_localcurrency", settings.LocalCurrency));

                //only update if 2fa has happened
                if (isAuth)
                {
                    cmd.Parameters.Add(new NpgsqlParameter("p_dailytransactionlimit", settings.DailyTransactionLimit));
                    cmd.Parameters.Add(new NpgsqlParameter("p_singletransactionlimit", settings.SingleTransactionLimit));
                    cmd.Parameters.Add(new NpgsqlParameter("p_nooftransactionsperday", settings.NoOfTransactionsPerDay));
                    cmd.Parameters.Add(new NpgsqlParameter("p_nooftransactionsperhour", settings.NoOfTransactionsPerHour));
                }
                else
                {
                    cmd.Parameters.Add(new NpgsqlParameter("p_dailytransactionlimit", 100000000));
                    cmd.Parameters.Add(new NpgsqlParameter("p_singletransactionlimit", 10000000));
                    cmd.Parameters.Add(new NpgsqlParameter("p_nooftransactionsperday", 10));
                    cmd.Parameters.Add(new NpgsqlParameter("p_nooftransactionsperhour", 4));
                }


                cmd.ExecuteNonQuery();


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
                return Json(new ErrorObject(errorMessage));

            }
            else
            {
                return Json(new ReturnObject("ok"));
            }
        }

    }

}