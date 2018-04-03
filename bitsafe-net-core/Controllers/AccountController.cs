#define Test

using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Security.Cryptography;
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
    public class AccountController : Controller
    {

        private ICSPRNGServer _csprng;
        private string _connstrWallet;
        private string _connstrRec;
        private string _connstrBlockchain;
        public AccountController(ICSPRNGServer csprng)
        {
            _csprng = csprng;
            _connstrWallet = Config.ConnWallet;
            _connstrRec = Config.ConnRec;
            _connstrBlockchain = Config.ConnBlockchain;

        }


        [Route("[action]/{id}")]
        public IActionResult TestAccount(string id)
        {

            byte[] seedarray = new byte[512];
            Sha512Digest digest = new Sha512Digest();

            byte[] b1 = new byte[1];
            _csprng.getRandomValues(b1);
            int check = _csprng.getInstanceCheck();
            string deviceKey = BitConverter.ToString(b1);

            ReturnObject ro = new ReturnObject();
            ro.message = id;
            ro.error = false;
            return Json(ro);

        }

        [HttpPost("[action]")]
        public IActionResult CreateAccount([FromForm] string guid)
        {

            guid = Helper.hashGuid(guid);

            string errorMessage = "";
            bool isError = false;

            byte[] seedarray = new byte[512];
            _csprng.getRandomValues(seedarray);

            byte[] secret = new byte[256];
            _csprng.getRandomValues(secret);

            string hexSecret = HexString.FromByteArray(secret);
            hexSecret = Helper.hashGuid(hexSecret);

            BIP32 bip32Seed = new BIP32(_csprng.Getsecp256k1());

            int network = BIP32.BITCOIN_MAINNET_PRIVATE;
#if Test
            network = BIP32.BITCOIN_TESTNET_PRIVATE;
#endif

            string seed = bip32Seed.GetPassphraseHash(seedarray, network);

            //use as seed
            BIP32 bip32 = new BIP32(seed, _csprng.Getsecp256k1());
            bip32.Derive("m");

            BIP32 bip32d = bip32.Derive("m/0/0");
            //generate master private key
            //encrypt using password?

            // Create an Aes object 
            // with the specified key and IV. 

            string privateKeyEncrypted = Helper.Encrypt(bip32.ExtendedPrivateKeyString(null), _csprng);
            string publicKey = Helper.Encrypt(bip32.ExtendedPublicKeyString(null), _csprng);

            string publicKeyCache = Helper.Encrypt(bip32d.ExtendedPublicKeyString(null), _csprng);
            string privateKeyCacheEncrypted = Helper.Encrypt(bip32d.ExtendedPrivateKeyString(null), _csprng);


            BIP32 bip32d1 = bip32.Derive("m/0/1");
            //generate master private key
            //encrypt using password?

            // Create an Aes object 
            // with the specified key and IV. 


            string publicKeyCache1 = Helper.Encrypt(bip32d1.ExtendedPublicKeyString(null), _csprng);
            string privateKeyCacheEncrypted1 = Helper.Encrypt(bip32d1.ExtendedPrivateKeyString(null), _csprng);

            string usertoken = Guid.NewGuid().ToString();
            string encusertoken = Helper.hashGuid(usertoken);

            string encsecret = Helper.Encrypt(hexSecret, _csprng);

            
            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {
                NpgsqlCommand com = new NpgsqlCommand("sp_createaccount_v2", conn);
                com.CommandType = CommandType.StoredProcedure;
                com.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                com.Parameters.Add(new NpgsqlParameter("p_ninkipk", privateKeyEncrypted));
                com.Parameters.Add(new NpgsqlParameter("p_ninkipub", publicKey));
                com.Parameters.Add(new NpgsqlParameter("p_usertoken", encusertoken));
                com.Parameters.Add(new NpgsqlParameter("p_ninkipubc0", publicKeyCache));
                com.Parameters.Add(new NpgsqlParameter("p_ninkipkc0", privateKeyCacheEncrypted));
                com.Parameters.Add(new NpgsqlParameter("p_ninkipubc1", publicKeyCache1));
                com.Parameters.Add(new NpgsqlParameter("p_ninkipkc1", privateKeyCacheEncrypted1));
                com.Parameters.Add(new NpgsqlParameter("p_secret", encsecret));

                com.ExecuteNonQuery();
                com.Dispose();

            }
            catch (Exception ex)
            {
                isError = true;
                errorMessage = "ErrCreateAccount";

            }
            finally
            {
                conn.Close();
            }

            //m

            if (isError)
            {
                {
                    ErrorObject ro = new ErrorObject();
                    ro.message = errorMessage;
                    ro.error = true;
                    return Json(ro);
                }
            }
            else
            {

                CreateAccountReturnObject ret = new CreateAccountReturnObject();
                ret.UserToken = usertoken;
                ret.NinkiMasterPublicKey = bip32.ExtendedPublicKeyString(null);
                ret.Secret = hexSecret;
                return Json(ret);
            }
        }


        [HttpPost("[action]")]
        public IActionResult CreateAccountSecPub([FromForm] string guid, [FromForm] string sharedid, [FromForm] string secretPub)
        {

            guid = Helper.hashGuid(guid);

           if (!Helper.IsCallerValid(guid, sharedid, _connstrWallet))
            {
                return Json(new ErrorObject("ErrInvalid"));
            }


            string errorMessage = "";
            bool isError = false;



            string encsecretPub = Helper.Encrypt(secretPub,_csprng);


            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {
                NpgsqlCommand com = new NpgsqlCommand("sp_createaccountsecpub", conn);
                com.CommandType = CommandType.StoredProcedure;
                com.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                com.Parameters.Add(new NpgsqlParameter("p_secretpub", encsecretPub));

                com.ExecuteNonQuery();

            }
            catch (Exception ex)
            {
                isError = true;
                errorMessage = "ErrCreateSecPub";

            }
            finally
            {
                conn.Close();
            }

            if (isError)
            {
                return Json(new ErrorObject("ErrInvalid"));
            }
            else
            {
                return Json(new ReturnObject("ok"));
            }

        }


        [HttpPost("[action]")]
        public IActionResult DoesAccountExist([FromForm] string username, [FromForm] string email)
        {

            Console.WriteLine("Calling DoesUsernameExist");

            bool userExists = false;
            bool emailExists = false;

            string errorMessage = "";
            bool isError = false;

            NpgsqlConnection conn = new NpgsqlConnection(_connstrRec);
            conn.Open();
            try
            {

                NpgsqlCommand cmd = new NpgsqlCommand("sp_getrecbyun", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                NpgsqlParameter p_Un = new NpgsqlParameter("p_un", username);
                p_Un.NpgsqlDbType = NpgsqlDbType.Varchar;
                cmd.Parameters.Add(p_Un);
                var reader = cmd.ExecuteReader(CommandBehavior.SingleRow);
                if (reader.HasRows)
                {
                    userExists = true;
                }
                else
                {
                    errorMessage = "ErrAccount";
                }
                reader.Dispose();
                cmd.Dispose();

                cmd = new NpgsqlCommand("sp_getrecbyem", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                NpgsqlParameter param = new NpgsqlParameter("p_em", email);
                param.NpgsqlDbType = NpgsqlDbType.Varchar;
                cmd.Parameters.Add(param);
                reader = cmd.ExecuteReader(CommandBehavior.SingleRow);
                if (reader.HasRows)
                {
                    emailExists = true;
                }
                else
                {
                    errorMessage = "ErrAccount";
                }
                reader.Dispose();
                cmd.Dispose();
            }
            catch (Exception ex)
            {

                errorMessage = "ErrSystem";
                isError = true;
            }
            finally
            {
                conn.Close();
            }

            DoesAccountExistReturnObject ret = new DoesAccountExistReturnObject();
            ret.EmailExists = emailExists;
            ret.UserExists = userExists;

            return Json(ret);


        }

        [HttpPost("[action]")]
        public IActionResult CreateAccount2([FromForm] string guid, [FromForm] string sharedid, [FromForm] string payload, [FromForm] string hotPublicKey, [FromForm] string coldPublicKey, [FromForm] string googleAuthSecret, [FromForm] string nickName, [FromForm] string emailAddress, [FromForm] string userPublicKey, [FromForm] string userPayload, [FromForm] string secret, [FromForm] string IVA, [FromForm] string IVR, [FromForm] string IVU, [FromForm] string recPacket, [FromForm] string recPacketIV)
        {

            //at this stage register the guid with the recovery database
            string errorMessage = "";
            bool isError = false;

            string oguid = guid;
            guid = Helper.hashGuid(guid);

            string mpkh = Helper.hashGuid(hotPublicKey);


            string hguid = Helper.hash512(oguid);

            if (!Helper.IsCallerValid(guid, sharedid, _connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "ErrInvalid";
                ro.error = true;
                return Json(ro);

            }

            if(emailAddress==null){
                emailAddress = "";
            }


            string tok = Guid.NewGuid().ToString();
            tok = Helper.hashGuid(tok);

            string salt = Helper.hashGuid(nickName);

            string recguid = Helper.Encrypt(oguid, _csprng);

            NpgsqlConnection connRec = new NpgsqlConnection(_connstrRec);
            connRec.Open();
            try
            {

                //TO DO: hash of the nickname

                //secret = Encrypt(secret, salt);

                NpgsqlCommand com = new NpgsqlCommand("sp_createrec", connRec);
                com.CommandType = CommandType.StoredProcedure;
                com.Parameters.Add(new NpgsqlParameter("p_pk", recguid));
                com.Parameters.Add(new NpgsqlParameter("p_un", nickName));
                com.Parameters.Add(new NpgsqlParameter("p_em", emailAddress));
                com.Parameters.Add(new NpgsqlParameter("p_ph", ""));
                com.Parameters.Add(new NpgsqlParameter("p_vc", ""));
                com.Parameters.Add(new NpgsqlParameter("p_pkh", hguid));
                com.Parameters.Add(new NpgsqlParameter("p_mpkh", mpkh));


                com.ExecuteNonQuery();
                com.Dispose();
            }
            catch (Exception ex)
            {
                isError = true;
                errorMessage = "ErrFail";
            }
            finally
            {
                connRec.Close();
            }

            if (!isError)
            {

                //encrypt the master ppublic keys before saving
                hotPublicKey = Helper.Encrypt(hotPublicKey, _csprng);
                coldPublicKey = Helper.Encrypt(coldPublicKey, _csprng);

                string userid = Guid.NewGuid().ToString();

                userPublicKey = Helper.Encrypt(userPublicKey, _csprng);

                NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);


                conn.Open();
                NpgsqlTransaction trans = conn.BeginTransaction();
                
                try
                {
                    NpgsqlCommand com = new NpgsqlCommand("sp_createaccount2", conn);
                    com.Transaction = trans;
                    com.CommandType = CommandType.StoredProcedure;
                    com.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                    com.Parameters.Add(new NpgsqlParameter("p_payload", payload));
                    com.Parameters.Add(new NpgsqlParameter("p_iv", IVA));
                    com.Parameters.Add(new NpgsqlParameter("p_hotmasterpublickey", hotPublicKey));
                    com.Parameters.Add(new NpgsqlParameter("p_coldmasterpublickey", coldPublicKey));
                    com.Parameters.Add(new NpgsqlParameter("p_vc", secret));
                    com.Parameters.Add(new NpgsqlParameter("p_ivr", IVR));
                    com.Parameters.Add(new NpgsqlParameter("p_recpacket", recPacket));
                    com.Parameters.Add(new NpgsqlParameter("p_recpacketiv", recPacketIV));


                    com.ExecuteNonQuery();
                    com.Dispose();

                    com = new NpgsqlCommand("sp_createuser", conn);
                    com.Transaction = trans;
                    com.CommandType = CommandType.StoredProcedure;
                    com.Parameters.Add(new NpgsqlParameter("p_userid", userid));
                    com.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                    com.Parameters.Add(new NpgsqlParameter("p_nickname", nickName));
                    com.Parameters.Add(new NpgsqlParameter("p_firstname", ""));
                    com.Parameters.Add(new NpgsqlParameter("p_lastname", ""));
                    com.Parameters.Add(new NpgsqlParameter("p_userpublickey", userPublicKey));
                    com.Parameters.Add(new NpgsqlParameter("p_userpayload", userPayload));
                    com.Parameters.Add(new NpgsqlParameter("p_iv", IVU));
                    com.ExecuteNonQuery();

                    com.Dispose();

                    com = new NpgsqlCommand("sp_updateaccountsettingsemail", conn);
                    com.Transaction = trans;
                    com.CommandType = CommandType.StoredProcedure;
                    com.Parameters.Add(new NpgsqlParameter("p_walletid", guid));
                    com.Parameters.Add(new NpgsqlParameter("p_email", emailAddress));
                    int ev = 0;
                    com.Parameters.Add(new NpgsqlParameter("p_emailverified", ev));
                    com.ExecuteNonQuery();

                    com.Dispose();

                    if (emailAddress.Length > 0)
                    {
                        com = new NpgsqlCommand("sp_createemailtoken", conn);
                        com.Transaction = trans;
                        com.CommandType = CommandType.StoredProcedure;
                        com.Parameters.Add(new NpgsqlParameter("p_emailvalidationtoken", tok));
                        com.Parameters.Add(new NpgsqlParameter("p_walletid", guid));
                        com.Parameters.Add(new NpgsqlParameter("p_emailaddress", emailAddress));
                        com.Parameters.Add(new NpgsqlParameter("p_expirydate", DateTime.Now.AddDays(1)));
                        int pu = 0;
                        com.Parameters.Add(new NpgsqlParameter("p_isused", pu));
                        com.Parameters.Add(new NpgsqlParameter("p_tokentype", 1));
                        com.ExecuteNonQuery();
                        com.Dispose();
                    }

                    

                    trans.Commit();
                }
                catch (Exception ex)
                {
                    trans.Rollback();
                    isError = true;
                    errorMessage = "ErrFail";
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

                ReturnObject ro = new ReturnObject();
                ro.message = tok;
                ro.error = false;
                return Json(ro);
            }


        }

        [HttpPost("[action]")]
        public IActionResult  GetAccountSecPub([FromForm] string guid, [FromForm] string sharedid)
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

            string encsecretPub = "";


            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {
                NpgsqlCommand com = new NpgsqlCommand("sp_getaccountsecpub", conn);
                com.CommandType = CommandType.StoredProcedure;
                com.Parameters.Add(new NpgsqlParameter("p_guid", guid));

                NpgsqlDataReader reader = com.ExecuteReader(CommandBehavior.SingleRow);

                if (reader.HasRows)
                {
                    reader.Read();
                    if (!reader.IsDBNull(0))
                    {
                        encsecretPub = reader.GetString(0);
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


            }
            catch (Exception ex)
            {
                isError = true;
                errorMessage = "ErrGetSecPub";

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
                encsecretPub = Helper.Decrypt(encsecretPub,_csprng);
                return Json(new ReturnObject(encsecretPub));
            }

        }

        [HttpPost("[action]")]
        public IActionResult RemoveAccountSecPub(string guid, string sharedid)
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

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {
                NpgsqlCommand com = new NpgsqlCommand("sp_removeaccountsecpub", conn);
                com.CommandType = CommandType.StoredProcedure;
                com.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                com.ExecuteNonQuery();

            }
            catch (Exception ex)
            {
                isError = true;
                errorMessage = "ErrRemoveSecPub";

            }
            finally
            {
                conn.Close();
            }

            if (isError)
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "ErrInvalid";
                ro.error = true;
                return Json(ro);
            }
            else
            {
                ReturnObject ro = new ReturnObject();
                ro.message = "ok";
                ro.error = false;
                return Json(ro);
            }

        }

        [HttpPost("[action]")]
        public IActionResult UpdateTwoFactorSecret([FromForm] string guid, [FromForm] string sharedid, [FromForm] string secret, [FromForm] bool twoFactorOnLogin)
        {

            if (guid.Contains("-"))
            {
                guid = Helper.hashGuid(guid);
            }


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
                string proc = "sp_updatetwofactorsecret";
                if (twoFactorOnLogin || secret.Length == 0)
                {
                    proc = "sp_updatetwofactor";
                }

                NpgsqlCommand com = new NpgsqlCommand(proc, conn);
                com.CommandType = CommandType.StoredProcedure;
                com.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                if (secret.Length > 0)
                {
                    com.Parameters.Add(new NpgsqlParameter("p_googleauthsecret", Helper.Encrypt(secret, _csprng)));
                }
                else
                {
                    int tfl = 0;
                    com.Parameters.Add(new NpgsqlParameter("p_twofactoronlogin", tfl));
                    com.Parameters.Add(new NpgsqlParameter("p_googleauthsecret", null));
                }
                com.ExecuteNonQuery();
                //if the account has been created with google authenticator enabled
                //update the account settings with TwoFactorTrue and TwoFactorType = GOOG
                //
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
                ro.message = "ErrInvalid";
                ro.error = true;
                return Json(ro);
            }
            else
            {
                ReturnObject ro = new ReturnObject();
                ro.message = "ok";
                ro.error = false;
                return Json(ro);
            }


        }


        [HttpPost("[action]")]
        public IActionResult UpdateExistingTwoFactorSecret([FromForm] string guid,[FromForm]  string sharedid, [FromForm] string secret)
        {

            if (guid.Contains("-"))
            {
                guid = Helper.hashGuid(guid);
            }

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
                NpgsqlCommand com = new NpgsqlCommand("sp_updateexistingtwofactor", conn);
                com.CommandType = CommandType.StoredProcedure;
                com.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                if (secret.Length > 0)
                {
                    com.Parameters.Add(new NpgsqlParameter("p_googleauthsecret", Helper.Encrypt(secret,_csprng)));
                }
                else
                {
                    int tmptwof = 0;
                    com.Parameters.Add(new NpgsqlParameter("p_twofactoronlogin", tmptwof));
                    com.Parameters.Add(new NpgsqlParameter("p_googleauthsecret", null));
                }
                com.ExecuteNonQuery();
                //if the account has been created with google authenticator enabled
                //update the account settings with TwoFactorTrue and TwoFactorType = GOOG
                //
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
                ro.message = "ErrInvalid";
                ro.error = true;
                return Json(ro);
            }
            else
            {
                ReturnObject ro = new ReturnObject();
                ro.message = "ok";
                ro.error = false;
                return Json(ro);
            }


        }


        [HttpPost("[action]")]
        public IActionResult GetTwoFactorSecret([FromForm] string guid)
        {

            string errorMessage = "";
            bool isError = false;

            string GoogleAuthSecret = "";
            bool TwoFactorOnLogin = false;

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {
                NpgsqlCommand cmd = new NpgsqlCommand("sp_authsecretbyaccount", conn);
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                cmd.CommandType = CommandType.StoredProcedure;
                NpgsqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SingleRow);
                if (reader.HasRows)
                {
                    reader.Read();

                    if (reader.IsDBNull(0))
                    {
                        GoogleAuthSecret = "";
                    }
                    else
                    {
                        GoogleAuthSecret = reader.GetString(0);
                    }

                    if (!reader.IsDBNull(1))
                    {
                        TwoFactorOnLogin = Convert.ToBoolean(reader.GetInt32(1));
                    }


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


            if (isError)
            {
                ErrorObject ro = new ErrorObject();
                ro.message = errorMessage;
                ro.error = true;
                return Json(ro);
            }

            if (GoogleAuthSecret != "")
            {
                GoogleAuthSecret = Helper.Decrypt(GoogleAuthSecret, _csprng);
            }

            GetTwoFactorSecretReturnObject ret = new GetTwoFactorSecretReturnObject();
            ret.guid = guid;
            ret.GoogleAuthSecret = GoogleAuthSecret;
            ret.TwoFactorOnLogin = TwoFactorOnLogin;

            return Json(ret);

        }

        [HttpPost("[action]")]
        public IActionResult GetUserData([FromForm] string guid, [FromForm] string sharedid)
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

            string ProfileImage = "";
            string Status = "";
            decimal tax = 0.10M;
            string packet = "";
            string IV = "";
            string nickname = "";
            int Inactivity = 20;
            int MinersFee = 10000;
            bool AutoEmailBackup = false;
            string Email = "";
            bool EmailVerified = false;
            string Phone = "";
            bool PhoneVerified = false;
            string Language = "EN";
            string LocalCurrency = "USD";
            string CoinUnit = "";
            bool EmailNotification = false;
            bool PhoneNotification = false;
            string PasswordHint = "";
            bool TwoFactor = false;
            string TwoFactorType = "";
            long DailyTransactionLimit = 100000000;
            long SingleTransactionLimit = 50000000;
            int NoOfTransactionsPerDay = 10;
            int NoOfTransactionsPerHour = 4;
            bool hasBackupCodes = false;
            int backupIndex = 0;

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {
                NpgsqlCommand cmd = new NpgsqlCommand("sp_getuserprofile", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                NpgsqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SingleRow);
                if (reader.HasRows)
                {
                    reader.Read();

                    if (!reader.IsDBNull(0))
                    {
                        ProfileImage = reader.GetString(0);
                    }
                    if (!reader.IsDBNull(1))
                    {
                        Status = reader.GetString(1);
                    }

                    if (!reader.IsDBNull(2))
                    {
                        tax = reader.GetDecimal(2);
                    }
                }
                reader.Dispose();


                cmd = new NpgsqlCommand("sp_getuserpacket", conn);
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                cmd.CommandType = CommandType.StoredProcedure;

                reader = cmd.ExecuteReader(CommandBehavior.SingleResult);
                if (reader.HasRows)
                {
                    reader.Read();
                    packet = reader.GetString(0);
                    IV = reader.GetString(1);
                }
                reader.Dispose();


                cmd = new NpgsqlCommand("sp_getnickname", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                reader = cmd.ExecuteReader(CommandBehavior.SingleRow);
                if (reader.HasRows)
                {
                    reader.Read();
                    nickname = reader.GetString(0);
                }
                else
                {
                    isError = true;
                    errorMessage = "ErrAccount";
                }
                reader.Dispose();


                cmd = new NpgsqlCommand("sp_accountsettings", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                reader = cmd.ExecuteReader(CommandBehavior.SingleRow);
                if (reader.HasRows)
                {
                    reader.Read();
                    if (!reader.IsDBNull(1))
                    {
                        Inactivity = reader.GetInt32(1);
                    }
                    if (!reader.IsDBNull(2))
                    {
                        MinersFee = reader.GetInt32(2);
                    }
                    if (!reader.IsDBNull(3))
                    {
                        AutoEmailBackup = Convert.ToBoolean(reader.GetInt32(3));
                    }
                    if (!reader.IsDBNull(4))
                    {
                        Email = reader.GetString(4);
                    }
                    if (!reader.IsDBNull(5))
                    {
                        EmailVerified = Convert.ToBoolean(reader.GetInt32(5));
                    }
                    if (!reader.IsDBNull(6))
                    {
                        Phone = reader.GetString(6);
                    }
                    if (!reader.IsDBNull(7))
                    {
                        PhoneVerified = Convert.ToBoolean(reader.GetInt32(7));
                    }
                    if (!reader.IsDBNull(8))
                    {
                        Language = reader.GetString(8);
                    }
                    if (!reader.IsDBNull(9))
                    {
                        LocalCurrency = reader.GetString(9);
                    }
                    if (!reader.IsDBNull(10))
                    {
                        CoinUnit = reader.GetString(10);
                    }
                    if (!reader.IsDBNull(11))
                    {
                        EmailNotification = Convert.ToBoolean(reader.GetInt32(11));
                    }
                    if (!reader.IsDBNull(12))
                    {
                        PhoneNotification = Convert.ToBoolean(reader.GetInt32(12));
                    }
                    if (!reader.IsDBNull(13))
                    {
                        PasswordHint = reader.GetString(13);
                    }
                    if (!reader.IsDBNull(14))
                    {
                        TwoFactor = Convert.ToBoolean(reader.GetInt32(14));
                    }
                    if (!reader.IsDBNull(15))
                    {
                        TwoFactorType = reader.GetString(15);
                    }
                    if (!reader.IsDBNull(16))
                    {
                        DailyTransactionLimit = reader.GetInt64(16);
                    }
                    if (!reader.IsDBNull(17))
                    {
                        SingleTransactionLimit = reader.GetInt64(17);
                    }
                    if (!reader.IsDBNull(18))
                    {
                        NoOfTransactionsPerDay = reader.GetInt32(18);
                    }
                    if (!reader.IsDBNull(19))
                    {
                        NoOfTransactionsPerHour = reader.GetInt32(19);
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
                    backupIndex = reader.GetInt32(1);
                }

                reader.Dispose();


                if (set > 0)
                {
                    hasBackupCodes = true;
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

            if (isError)
            {

                ErrorObject ro = new ErrorObject();
                ro.message = errorMessage;
                ro.error = true;
                return Json(ro);
            }
            else
            {
                GetUserDataReturnObject ret = new GetUserDataReturnObject();

                ret.Nickname = nickname;
                ret.ProfileImage = ProfileImage;
                ret.Status = Status;
                ret.Tax = tax;
                ret.Payload = packet;
                ret.IV = IV;
                ret.Settings.guid = guid;
                ret.Settings.Inactivity = Inactivity;
                ret.Settings.MinersFee = MinersFee;
                ret.Settings.AutoEmailBackup = AutoEmailBackup;
                ret.Settings.Email = Email;
                ret.Settings.EmailVerified = EmailVerified;
                ret.Settings.Phone = Phone;
                ret.Settings.PhoneVerified = PhoneVerified;
                ret.Settings.Language = Language;
                ret.Settings.LocalCurrency = LocalCurrency;
                ret.Settings.CoinUnit = CoinUnit;
                ret.Settings.EmailNotification = EmailNotification;
                ret.Settings.PhoneNotification = PhoneNotification;
                ret.Settings.PasswordHint = PasswordHint;
                ret.Settings.TwoFactor = TwoFactor;
                ret.Settings.TwoFactorType = TwoFactorType;
                ret.Settings.DailyTransactionLimit = DailyTransactionLimit;
                ret.Settings.SingleTransactionLimit = SingleTransactionLimit;
                ret.Settings.NoOfTransactionsPerDay = NoOfTransactionsPerDay;
                ret.Settings.NoOfTransactionsPerHour = NoOfTransactionsPerHour;
                ret.Settings.HasBackupCodes = hasBackupCodes;
                ret.Settings.BackupIndex = backupIndex;

                return Json(ret);
            }

        }

        [HttpPost("[action]")]
        public IActionResult GetUserPacket([FromForm] string guid, [FromForm] string sharedid)
        {

            if (!Helper.IsCallerValid(guid, sharedid,_connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "ErrInvalid";
                ro.error = true;
                return Json(ro);
            }


            string packet = "";
            string IV = "";
            string userid = "";

            bool isError = false;
            string errorMessage = "";
            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {

                NpgsqlCommand com = new NpgsqlCommand("sp_getUserPacket", conn);
                com.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                com.CommandType = CommandType.StoredProcedure;

                NpgsqlDataReader reader = com.ExecuteReader(CommandBehavior.SingleResult);
                if (reader.HasRows)
                {
                    reader.Read();
                    packet = reader.GetString(0);
                    IV = reader.GetString(1);
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
                ErrorObject ro = new ErrorObject();
                ro.message = "ErrInvalid";
                ro.error = true;
                return Json(ro);
            }
            else
            {
                dynamic ret = new System.Dynamic.ExpandoObject();
                ret.Payload = packet;
                ret.IV = IV;
                return Json(ret);
            }
        }

        [HttpPost("[action]")]
        public IActionResult  UpdateEmailAddress([FromForm] string guid,[FromForm]  string sharedid, [FromForm] string emailAddress)
        {

            string oguid = guid;
            guid = Helper.hashGuid(guid);


            if (!Helper.IsCallerValid(guid, sharedid,_connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "ErrInvalid";
                ro.error = true;
                return Json(ro);
            }

            //get original guid
            //hash and compare
            //update by hash

            string errorMessage = "";
            bool isError = false;


            NpgsqlConnection connRec = new NpgsqlConnection(_connstrRec);
            connRec.Open();
            try
            {

                //TO DO: hash of the nickname
                string recguid = Helper.Encrypt(oguid,_csprng);
                //secret = Encrypt(secret, salt);

                NpgsqlCommand com = new NpgsqlCommand("sp_updaterecemail", connRec);
                com.CommandType = CommandType.StoredProcedure;
                com.Parameters.Add(new NpgsqlParameter("p_pk", recguid));
                com.Parameters.Add(new NpgsqlParameter("p_em", emailAddress));

                com.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                isError = true;
                errorMessage = "ErrFail";
            }
            finally
            {
                connRec.Close();
            }


            if (emailAddress.Length > 0)
            {


                NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);


                conn.Open();
                NpgsqlTransaction trans = conn.BeginTransaction();
                try
                {
                    NpgsqlCommand com = new NpgsqlCommand("sp_updateaccountsettingsemail", conn);
                    com.Transaction = trans;
                    com.CommandType = CommandType.StoredProcedure;
                    com.Parameters.Add(new NpgsqlParameter("p_walletid", guid));
                    com.Parameters.Add(new NpgsqlParameter("p_email", emailAddress));
                    int tmpev = 0;
                    com.Parameters.Add(new NpgsqlParameter("p_emailverified", tmpev));
                    com.ExecuteNonQuery();

                    trans.Commit();
                }
                catch (Exception ex)
                {
                    trans.Rollback();
                    isError = true;
                    errorMessage = "ErrFail";
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
                ReturnObject reto = new ReturnObject();
                reto.message = "ok";
                reto.error = false;
                return Json(reto);
            }

        }

        [HttpPost("[action]")]
        public IActionResult GetEmailValidation([FromForm] string guid,[FromForm] string sharedid, [FromForm] string token)
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
            string ret = "Invalid";
            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {
                string sql = "sp_getemailtoken";
                NpgsqlCommand cmd = new NpgsqlCommand(sql, conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_walletid", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_emailvalidationtoken", token));
                NpgsqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    reader.Read();
                    DateTime expiry = reader.GetDateTime(0);
                    int tokenType = reader.GetInt32(1);

                    if (expiry > DateTime.Now && tokenType == 1)
                    {
                        ret = "Valid";
                    }
                    else
                    {
                        ret = "Expired";
                    }
                }
                reader.Dispose();
                if (ret == "Valid")
                {
                    //update emailvalidated in account and token table
                    cmd = new NpgsqlCommand("sp_updateemailverified", conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new NpgsqlParameter("p_walletid", guid));
                    cmd.Parameters.Add(new NpgsqlParameter("p_emailvalidationtoken", token));
                    cmd.ExecuteNonQuery();
                }

            }
            catch (Exception ex)
            {
                isError = true;
                errorMessage = "ErrFail";
            }
            finally
            {
                conn.Close();
            }

            if (isError)
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "ErrInvalid";
                ro.error = true;
                return Json(ro);
            }
            else
            {
                ReturnObject reto = new ReturnObject();
                reto.message = ret;
                reto.error = false;
                return Json(reto);
            }

        }

        [HttpPost("[action]")]
        public IActionResult GetWelcomeDetails([FromForm] string guid,[FromForm]  string sharedid)
        {

            string errorMessage = "";
            bool isError = false;

            //string oguid = guid;
            // guid = hashGuid(guid);

            if (!Helper.IsCallerValid(guid, sharedid,_connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "ErrInvalid";
                ro.error = true;
                return Json(ro);
            }

            string tok = Guid.NewGuid().ToString();
            tok = Helper.hashGuid(tok);

            string userNinkiKey = "";
            string nickname = "";
            string emailAddress = "";

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);

            //validate that the address handed to us is valid
            conn.Open();
            try
            {
                NpgsqlCommand cmd = new NpgsqlCommand("sp_pubkeybyaccount", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                NpgsqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SingleRow);
                if (reader.HasRows)
                {
                    reader.Read();

                    if (reader.IsDBNull(0))
                    {
                        isError = true;
                        errorMessage = "ErrInvalid";
                    }
                    else
                    {
                        userNinkiKey = reader.GetString(2);
                    }
                }
                else
                {
                    isError = true;
                    errorMessage = "ErrAccount";
                }
                reader.Dispose();

                cmd = new NpgsqlCommand("sp_getnickname", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                reader = cmd.ExecuteReader(CommandBehavior.SingleRow);
                if (reader.HasRows)
                {
                    reader.Read();
                    nickname = reader.GetString(0);
                }
                else
                {
                    isError = true;
                    errorMessage = "ErrAccount";
                }
                reader.Dispose();

                cmd = new NpgsqlCommand("sp_accountsettings", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                reader = cmd.ExecuteReader(CommandBehavior.SingleRow);
                if (reader.HasRows)
                {
                    reader.Read();
                    emailAddress = reader.GetString(4);
                }
                else
                {
                    isError = true;
                    errorMessage = "ErrAccount";
                }
                reader.Dispose();

                cmd = new NpgsqlCommand("sp_createemailtoken", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_emailvalidationtoken", tok));
                cmd.Parameters.Add(new NpgsqlParameter("p_walletid", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_emailaddress", emailAddress));
                cmd.Parameters.Add(new NpgsqlParameter("p_expirydate", DateTime.Now.AddDays(1)));
                int tIsUsed = 0;
                cmd.Parameters.Add(new NpgsqlParameter("p_isused", tIsUsed));
                cmd.Parameters.Add(new NpgsqlParameter("p_tokentype", 1));
                cmd.ExecuteNonQuery();

            }
            catch (Exception ex)
            {
                isError = true;
                errorMessage = "ErrInvalid";
            }
            finally
            {
                conn.Close();
            }

            userNinkiKey = Helper.Decrypt(userNinkiKey,_csprng);


            GetWelcomeDetailsReturnObject ret = new GetWelcomeDetailsReturnObject();
            ret.Email = emailAddress;
            ret.Nickname = nickname;
            ret.NinkiPubKey = userNinkiKey;
            ret.Token = tok;

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
        public IActionResult UpdatePackets([FromForm] string guid,[FromForm] string sharedid,[FromForm] string accountPacket,[FromForm] string userPacket,[FromForm] string verifyPacket,[FromForm] string passPacket,[FromForm] string IVA,[FromForm] string IVU,[FromForm] string IVR, [FromForm] string PIV)
        {


            if (!Helper.IsCallerValid(guid, sharedid,_connstrWallet))
            {
                return Json(new ErrorObject("ErrInvalid"));
            }

            //
            string errorMessage = "";
            bool isError = false;


            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {
                NpgsqlCommand cmd = new NpgsqlCommand("sp_updatepackets", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_payload", accountPacket));
                cmd.Parameters.Add(new NpgsqlParameter("p_userpayload", userPacket));
                cmd.Parameters.Add(new NpgsqlParameter("p_vc", verifyPacket));
                cmd.Parameters.Add(new NpgsqlParameter("p_iva", IVA));
                cmd.Parameters.Add(new NpgsqlParameter("p_ivu", IVU));
                cmd.Parameters.Add(new NpgsqlParameter("p_ivr", IVR));
                cmd.Parameters.Add(new NpgsqlParameter("p_recpacket", passPacket));
                cmd.Parameters.Add(new NpgsqlParameter("p_recpacketiv", PIV));
                // 

                object result = cmd.ExecuteScalar();
                // if (int.Parse(result.ToString()) == -1)
                // {
                //     isError = true;
                // }

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
                return Json(new ErrorObject(errorMessage));   
            }
            else
            {
                return Json(new ReturnObject("ok"));
            }

        }

        [HttpPost("[action]")]
        public IActionResult GetRecoveryPacket([FromForm] string guid, [FromForm] string username)
        {

            bool isBeta1Wallet = false;
            bool isBeta12fa = false;
            string errorMessage = "";
            bool isError = false;


            if (guid.Contains("-"))
            {
                guid = Helper.hashGuid(guid);
            }
            //string dguid = Encrypt(guid, salt);
            string packet = "";
            string IV = "";
            Console.WriteLine(_connstrWallet);
            NpgsqlConnection connWall = new NpgsqlConnection(_connstrWallet);
            connWall.Open();
            try
            {
                NpgsqlCommand com = new NpgsqlCommand("sp_getrecoverypacket", connWall);
                com.CommandType = CommandType.StoredProcedure;
                com.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                NpgsqlDataReader rdr = com.ExecuteReader(CommandBehavior.SingleRow);

                //Vc,IVR,Secret,TwoFactorOnLogin 

                if (rdr.HasRows)
                {
                    rdr.Read();

                    if (rdr.IsDBNull(0))
                    {
                        isBeta1Wallet = true;
                        if (!rdr.IsDBNull(3))
                        {
                            isBeta12fa = rdr.GetBoolean(3);
                        }
                    }
                    else
                    {
                        packet = rdr.GetString(0);
                        IV = rdr.GetString(1);
                    }
                }


                rdr.Dispose();

            }
            catch (Exception ex)
            {
                isError = true;
                errorMessage = "ErrFail";
            }
            finally
            {
                connWall.Close();
            }

            GetRecoveryPacketReturnObject ret =  new  GetRecoveryPacketReturnObject();
            ret.packet = packet;
            ret.IV = IV;
            
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
        public IActionResult ValidateSecret([FromForm] string guid, [FromForm] string secret)
        {
            //payload is encrypted and only the client knows how to decrypt
            //payload contains all public keys and user hot private key

            string errorMessage = "";
            bool isError = false;

            bool TwoFactorOnLogin = false;
            bool loginSuccess = false;
            int locked = 0;
            int backupIndex = 0;
            bool hasBackupCodes = false;

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {

                //get secret from db
                //decrypt and compare
                //if secret matches then return packet


                NpgsqlCommand cmd = new NpgsqlCommand("sp_payloadbyaccount", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                NpgsqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SingleRow);
                if (reader.HasRows)
                {
                    reader.Read();

                    if (reader.IsDBNull(0))
                    {
                        isError = true;
                        errorMessage = "No payload has been saved";
                    }
                    else
                    {


                        if (!reader.IsDBNull(5))
                        {
                            locked = reader.GetInt32(5);
                        }

                        if (locked == 0)
                        {
                            string esecret = reader.GetString(3);
                            string dsecret = Helper.Decrypt(esecret,_csprng);

                            if (dsecret == secret)
                            {
                                loginSuccess = true;
                                if (!reader.IsDBNull(1))
                                {
                                    TwoFactorOnLogin = Convert.ToBoolean(reader.GetInt32(1));
                                }
                            }
                            else
                            {
                                isError = true;
                                errorMessage = "ErrAccount";
                            }
                        }
                        else
                        {

                            isError = true;
                            errorMessage = "ErrLocked";
                        }
                    }

                }
                else
                {
                    isError = true;
                    errorMessage = "ErrAccount";
                }
                reader.Dispose();


                if (locked == 0)
                {
                    cmd = new NpgsqlCommand("sp_createaccountlog", conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                    cmd.Parameters.Add(new NpgsqlParameter("p_logtype", "Login"));

                    if (isError)
                    {
                        int tsucc = 0;
                        cmd.Parameters.Add(new NpgsqlParameter("p_success", tsucc));
                    }
                    else
                    {
                        cmd.Parameters.Add(new NpgsqlParameter("p_success", 1));
                    }
                    cmd.ExecuteNonQuery();

                    if (!loginSuccess)
                    {

                        //if the login is unsuccessful
                        //check to see how many attempts have been made
                        //since the last successful login in the last x hours/mins?

                        //if > 4 lock the account
                        //generate an email token for notifier to send out
                        //or do we delegate this to a security guard component?
                        //probably best to do the locking here

                    }
                }

                int set = 0;
                NpgsqlCommand com = new NpgsqlCommand("sp_getnextbackupindex", conn);
                com.CommandType = CommandType.StoredProcedure;
                com.Parameters.Add(new NpgsqlParameter("p_guid", guid));

                reader = com.ExecuteReader(CommandBehavior.SingleResult);
                if (reader.HasRows)
                {
                    reader.Read();
                    set = reader.GetInt32(0);
                    backupIndex = reader.GetInt32(1);
                }
                reader.Dispose();

                if (set > 0)
                {
                    hasBackupCodes = true;
                }

            }
            catch (Exception ex)
            {
                isError = true;
                errorMessage = "ErrAccount";
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


            ValidateSecretReturnObject ret = new ValidateSecretReturnObject();
            ret.guid = guid;
            ret.TwoFactorOnLogin = TwoFactorOnLogin;
            ret.Locked = locked;
            ret.HasBackupCodes = hasBackupCodes;
            ret.BackupIndex = backupIndex;
            return Json(ret);

            
        }

        [HttpPost("[action]")]
        public IActionResult  GetAccountDetails(string guid, string secret)
        {


            //retrieves the payload and returns to the client
            //payload is encrypted and only the client knows how to decrypt
            //payload contains all public keys and user hot private key

            string errorMessage = "";
            bool isError = false;

            string Payload = "";
            string IV = "";
            bool TwoFactorOnLogin = false;
            int locked = 0;

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {

                //get secret from db
                //decrypt and compare
                //if secret matches then return packet


                NpgsqlCommand cmd = new NpgsqlCommand("sp_payloadbyaccount", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                NpgsqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SingleRow);
                if (reader.HasRows)
                {
                    reader.Read();

                    if (reader.IsDBNull(0))
                    {
                        isError = true;
                        errorMessage = "No payload has been saved";
                    }
                    else
                    {
                        if (!reader.IsDBNull(5))
                        {
                            locked = reader.GetInt32(5);
                        }

                        //don't check for the secret
                        //check for the secret encrypted packet
                        //this is the only way to tell if the account has been migrated
                        if (locked == 0)
                        {
                            if (reader.IsDBNull(4))
                            {
                                //migration
                                //tactical fix, can be removed once all beta accounts are migrated
                                //or dormant
                                Payload = reader.GetString(0);
                                IV = reader.GetString(2);

                                //we are migrating an account from beta
                                if (!reader.IsDBNull(1))
                                {
                                    TwoFactorOnLogin = Convert.ToBoolean(reader.GetInt32(1));
                                }

                            }
                            else
                            {
                                string esecret = reader.GetString(3);
                                string dsecret = Helper.Decrypt(esecret,_csprng);

                                if (dsecret == secret)
                                {
                                    Payload = reader.GetString(0);
                                    IV = reader.GetString(2);
                                }
                                else
                                {
                                    isError = true;
                                    errorMessage = "ErrAccount";
                                }

                                //we are migrating an account from beta
                                if (!reader.IsDBNull(1))
                                {
                                    TwoFactorOnLogin = Convert.ToBoolean(reader.GetInt32(1));
                                }

                            }
                        }
                        else
                        {
                            isError = true;
                            errorMessage = "ErrLocked";
                        }

                    }

                }
                else
                {
                    isError = true;
                    errorMessage = "ErrAccount";
                }
                reader.Dispose();


            }
            catch (Exception ex)
            {
                isError = true;
                errorMessage = "ErrAccount";
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

            GetAccountDetailsReturnObject ret = new GetAccountDetailsReturnObject();
            
            ret.guid = guid;
            ret.Payload = Payload;
            ret.IV = IV;
            ret.TwoFactorOnLogin = TwoFactorOnLogin;
            
            return Json(ret);
        }

        [HttpPost("[action]")]
        public IActionResult GetTwoFactorToken(string guid, string sharedid)
        {



            string errorMessage = "";
            bool isError = false;

            //string oguid = guid;
            // guid = hashGuid(guid);

            byte[] vals = new byte[32];
            _csprng.getRandomValues(vals);

            string tok = HexString.FromByteArray(vals);
            tok = Helper.hashGuid(tok);

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);

            conn.Open();
            try
            {
                NpgsqlCommand cmd = new NpgsqlCommand("sp_createemailtoken", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_emailvalidationtoken", tok));
                cmd.Parameters.Add(new NpgsqlParameter("p_walletid", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_emailaddress", ""));
                cmd.Parameters.Add(new NpgsqlParameter("p_expirydate", DateTime.Now.AddYears(1)));
                int tused = 0;
                cmd.Parameters.Add(new NpgsqlParameter("p_isused", tused));
                cmd.Parameters.Add(new NpgsqlParameter("p_tokentype", 3));
                cmd.ExecuteNonQuery();

            }
            catch (Exception ex)
            {
                isError = true;
                errorMessage = "ErrInvalid";
            }
            finally
            {
                conn.Close();
            }


            GetTwoFactorTokenReturnObject ret = new GetTwoFactorTokenReturnObject();
            ret.Token = tok;

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
        public IActionResult VerifyToken(string guid, string token)
        {

            if (guid.Contains("-"))
            {
                guid = Helper.hashGuid(guid);
            }

            string errorMessage = "";
            bool isError = false;
            string ret = "Invalid";
            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {
                string sql = "sp_getemailtoken";
                NpgsqlCommand cmd = new NpgsqlCommand(sql, conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_walletid", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_emailvalidationtoken", token));
                NpgsqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    reader.Read();
                    DateTime expiry = reader.GetDateTime(0);
                    int tokenType = reader.GetInt32(1);

                    if (expiry > DateTime.Now)
                    {
                        ret = "Valid";

                        if (tokenType == 6)
                        {
                            ret = "ValidForTwoFactor";

                        }

                    }
                    else
                    {
                        ret = "Expired";
                    }
                }
                else
                {
                    ret = "Expired";

                }
                reader.Dispose();

            }
            catch (Exception ex)
            {
                isError = true;
                errorMessage = "ErrFail";
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
                ReturnObject ro = new ReturnObject();
                ro.message = ret;
                ro.error = false;
                return Json(ro);
            }

        }

        

        [HttpPost("[action]")]
        public IActionResult  GetRecoveryInfoByUsername([FromForm] string username)
        {

            string errorMessage = "";
            bool isError = false;

            string guid = "";
            string email = "";
            bool isFound = false;

            NpgsqlConnection connRec = new NpgsqlConnection(_connstrRec);
            connRec.Open();
            try
            {

                NpgsqlCommand com = new NpgsqlCommand("sp_GetRecByUser", connRec);
                com.CommandType = CommandType.StoredProcedure;
                com.Parameters.Add(new NpgsqlParameter("p_userName", username));

                NpgsqlDataReader rdr = com.ExecuteReader(CommandBehavior.SingleRow);

                if (rdr.HasRows)
                {
                    isFound = true;
                    rdr.Read();
                    guid = rdr.GetString(0);
                    email = rdr.GetString(1);

                }

                rdr.Dispose();

            }
            catch (Exception ex)
            {
                isError = true;
                errorMessage = "ErrFail";
            }
            finally
            {
                connRec.Close();
            }

            if (isFound)
            {

                //string salt = hashGuid(username);
                guid = Helper.Decrypt(guid,_csprng);

                if (isError)
                {
                    ErrorObject ro = new ErrorObject();
                    ro.message = errorMessage;
                    ro.error = true;
                    return Json(ro);
                }
                else
                {
                    RecoveryInfo ri =  new RecoveryInfo();
                    ri.guid = guid;
                    ri.email = email;
                    return Json(ri);
                }

            }
            else
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "ErrFail";
                ro.error = true;
                return Json(ro);}

        }


        [HttpPost("[action]")]
        public IActionResult UseBackupCode([FromForm] string guid,[FromForm]  string sharedid, [FromForm] string usercode)
        {

            //
            string code = "";
            bool isError = false;
            string errorMessage = "";
            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {


                NpgsqlCommand com = new NpgsqlCommand("sp_useNextBackupIndex", conn);
                com.CommandType = CommandType.StoredProcedure;
                com.Parameters.Add(new NpgsqlParameter("p_guid", guid));

                NpgsqlDataReader reader = com.ExecuteReader(CommandBehavior.SingleResult);
                if (reader.HasRows)
                {
                    reader.Read();
                    code = reader.GetString(0);
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
                return Json(new ErrorObject(errorMessage));
            }

            code = Helper.Decrypt(code,_csprng);

            if (code == usercode)
            {
                dynamic ret = new System.Dynamic.ExpandoObject();
                ret.message = true;
                return Json(ret);

            }
            else
            {
                return Json(new ErrorObject("ErrInvalidCode"));
            }

        }

        [HttpPost("[action]")]
        public IActionResult CreateBackupCodes([FromForm] string guid, [FromForm] string sharedid)
        {

            if (!Helper.IsCallerValid(guid, sharedid,_connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "ErrInvalid";
                ro.error = true;
                return Json(ro);
            }
            //generate a set of 10 8 digit codes

            List<System.Dynamic.ExpandoObject> bcodes =  new List<System.Dynamic.ExpandoObject>();

            List<string> codes = new List<string>();
            List<string> enccodes = new List<string>();
            for (int i = 0; i < 10; i++)
            {
                string cd = Get8Digits();
                codes.Add(cd);
                enccodes.Add(Helper.Encrypt(cd,_csprng));
            }


            //get next set
            //sp_getNextBackupSet


            int set = 0;
            bool isError = false;
            string errorMessage = "";
            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {

                NpgsqlCommand com = new NpgsqlCommand("sp_getnextbackupset", conn);
                com.CommandType = CommandType.StoredProcedure;
                com.Parameters.Add(new NpgsqlParameter("p_guid", guid));

                NpgsqlDataReader reader = com.ExecuteReader(CommandBehavior.SingleResult);
                if (reader.HasRows)
                {
                    reader.Read();
                    set = reader.GetInt32(0);
                }
                reader.Dispose();

                //transaction here?

                com = new NpgsqlCommand("sp_createbackupcode", conn);
                com.CommandType = CommandType.StoredProcedure;

                for (int i = 0; i < 10; i++)
                {
                    com.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                    com.Parameters.Add(new NpgsqlParameter("p_backupset", set));
                    com.Parameters.Add(new NpgsqlParameter("p_backupindex", i + 1));
                    com.Parameters.Add(new NpgsqlParameter("p_backupcode", enccodes[i]));
                    com.ExecuteNonQuery();
                    com.Parameters.Clear();
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


            if (isError)
            {
                ErrorObject ro = new ErrorObject();
                ro.message = errorMessage;
                ro.error = true;
                return Json(ro);
            }
            else
            {

                for (int i = 0; i < 10; i++)
                {

                    dynamic bcode = new System.Dynamic.ExpandoObject();
                    bcode.Index = i;
                    bcode.Code = codes[i];
                    bcodes.Add(bcode);

                }
                    

                 return Json(bcodes);
            }


        }
        public string Get8Digits()
        {
            var bytes = new byte[4];
            var rng = RandomNumberGenerator.Create();
            rng.GetBytes(bytes);
            uint random = BitConverter.ToUInt32(bytes, 0) % 100000000;
            return String.Format("{0:D8}", random);
        }


        [HttpPost("[action]")]
        public IActionResult GetGUIDByMPKH([FromForm] string MPKH)
        {

            string errorMessage = "";
            bool isError = false;

            string guid = "";
            bool isFound = false;

            NpgsqlConnection connRec = new NpgsqlConnection(_connstrRec);
            connRec.Open();
            try
            {

                NpgsqlCommand com = new NpgsqlCommand("sp_getrecbympkh", connRec);
                com.CommandType = CommandType.StoredProcedure;
                com.Parameters.Add(new NpgsqlParameter("p_mpkh", MPKH));

                NpgsqlDataReader rdr = com.ExecuteReader(CommandBehavior.SingleRow);

                if (rdr.HasRows)
                {
                    isFound = true;
                    rdr.Read();
                    guid = rdr.GetString(0);

                }

                rdr.Dispose();

            }
            catch (Exception ex)
            {
                isError = true;
                errorMessage = "ErrFail";
            }
            finally
            {
                connRec.Close();
            }

            if (isFound)
            {

                //string salt = hashGuid(username);
                guid = Helper.Decrypt(guid,_csprng);


                if (isError)
                {
                    return Json(new ErrorObject(errorMessage));
                }
                else
                {
                    return Json(new ReturnObject(guid));
                }

            }
            else
            {
                return Json(new ErrorObject("ErrFail"));
            }

        }


        [HttpPost("[action]")]
        public IActionResult GetSigChallenge([FromForm] string guid, [FromForm] string secret)
        {
            bool isError = false;
            string errmessage = "";
            string ret = "";
            try
            {
                if (Helper.IsSecretValid(guid, secret,_connstrWallet,_csprng))
                {

                    byte[] challenge = new byte[32];

                    _csprng.getRandomValues(challenge);

                    ret = HexString.FromByteArray(challenge);


                }
                else
                {
                    errmessage = "ErrInvalid";
                    isError = true;
                }

            }
            catch (Exception ex)
            {
                errmessage = "ErrChallenge";
                isError = true;

            }


            if (isError)
            {
                return Json(new ErrorObject(errmessage));
            }
            else
            {
                return Json(new ReturnObject(ret));
            }

        }


        [HttpPost("[action]")]
        public IActionResult GetDevMigTwoFactorToken([FromForm] string guid, [FromForm] string sharedid, [FromForm] string twoFactorToken)
        {

            string errorMessage = "";
            bool isError = false;

            //string oguid = guid;
            // guid = hashGuid(guid);


            //validate regToken

            bool isTokenValid = false;

            string tok = "";

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);

            conn.Open();
            try
            {

                //first validate the token provided
                //to autorise the temporary device token
                string sql = "sp_getEmailToken";
                NpgsqlCommand cmd = new NpgsqlCommand(sql, conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_WalletId", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_EmailValidationToken", twoFactorToken));
                NpgsqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    reader.Read();
                    DateTime expiry = reader.GetDateTime(0);
                    int tokenType = reader.GetInt32(1);

                    if (expiry > DateTime.Now)
                    {
                        isTokenValid = true;


                    }

                }
                reader.Dispose();

                if (isTokenValid)
                {
                    byte[] vals = new byte[32];
                    _csprng.getRandomValues(vals);

                    tok = HexString.FromByteArray(vals);
                    tok = Helper.hashGuid(tok);

                    cmd = new NpgsqlCommand("sp_createEmailToken", conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new NpgsqlParameter("p_EmailValidationToken", tok));
                    cmd.Parameters.Add(new NpgsqlParameter("p_WalletId", guid));
                    cmd.Parameters.Add(new NpgsqlParameter("p_EmailAddress", ""));
                    cmd.Parameters.Add(new NpgsqlParameter("p_ExpiryDate", DateTime.Now.AddMinutes(10)));
                    cmd.Parameters.Add(new NpgsqlParameter("p_IsUsed", "0"));
                    cmd.Parameters.Add(new NpgsqlParameter("p_TokenType", 6));
                    cmd.ExecuteNonQuery();
                }
                else
                {
                    isError = true;
                    errorMessage = "ErrInvalid";

                }

            }
            catch (Exception ex)
            {
                isError = true;
                errorMessage = "ErrInvalid";
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
                return Json(new ReturnObject(tok));
            }


        }


        [HttpPost("[action]")]
        public IActionResult GetUserProfile([FromForm] string guid,[FromForm]  string sharedid)
        {

            if (!Helper.IsCallerValid(guid, sharedid,_connstrWallet))
            {
                return Json(new ErrorObject("ErrInvalid"));
            }

            string errorMessage = "";
            bool isError = false;

            bool hasRecord = false;

            string ProfileImage = "";
            string Status = "";
            decimal tax = 0.10M;
            int OfflineKeyBackup = 0;

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {
                NpgsqlCommand cmd = new NpgsqlCommand("sp_getUserProfile", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                NpgsqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SingleRow);
                if (reader.HasRows)
                {
                    reader.Read();
                    if (!reader.IsDBNull(0))
                    {
                        ProfileImage = reader.GetString(0);
                    }
                    if (!reader.IsDBNull(1))
                    {
                        Status = reader.GetString(1);
                    }
                    if (!reader.IsDBNull(2))
                    {
                        tax = reader.GetDecimal(2);
                    }
                    if (!reader.IsDBNull(3))
                    {
                        OfflineKeyBackup = 1;
                    }

                    hasRecord = true;
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

            dynamic ret = new System.Dynamic.ExpandoObject();
            ret.ProfileImage = ProfileImage;
            ret.Status = Status;
            ret.Tax = tax;
            ret.OfflineKeyBackup = (OfflineKeyBackup==1);

    
            if (isError)
            {
                return Json(new ErrorObject(errorMessage));
            }
            else
            {
                return Json(ret);
            }


        }

       [HttpPost("[action]")]
        public IActionResult UpdateUserProfile([FromForm] string guid,[FromForm]  string sharedid, [FromForm] string profileImage, [FromForm] string status, [FromForm] decimal invoiceTax)
        {

            if (!Helper.IsCallerValid(guid, sharedid,_connstrWallet))
            {
                return Json(new ErrorObject("ErrInvalid"));
            }

            string errorMessage = "";
            bool isError = false;

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {
                NpgsqlCommand cmd = new NpgsqlCommand("sp_updateUserProfile", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_profileImage", profileImage));
                cmd.Parameters.Add(new NpgsqlParameter("p_status", status));
                cmd.Parameters.Add(new NpgsqlParameter("p_invoicetax", invoiceTax));
                cmd.ExecuteNonQuery();
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
                return Json(new ErrorObject(errorMessage));
            }
            else
            {
                return Json(new ReturnObject("ok"));
            }

        }

    }

}