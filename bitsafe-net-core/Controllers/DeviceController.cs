
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
    public class DeviceController : Controller
    {
        private ICSPRNGServer _csprng;
        private string _connstrWallet;
        private string _connstrRec;
        private string _connstrBlockchain;
        public DeviceController(ICSPRNGServer csprng)
        {
            _csprng = csprng;
            _connstrWallet = Config.ConnWallet;
            _connstrRec = Config.ConnRec;
            _connstrBlockchain = Config.ConnBlockchain;
        }

        [HttpPost("[action]")]
        public IActionResult GetDevices([FromForm] string guid, [FromForm] string sharedid)
        {

            string errorMessage = "";
            bool isError = false;
            List<DeviceReturnObject> ret = new List<DeviceReturnObject>();

            if (!Helper.IsCallerValid(guid, sharedid, _connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "Invalid";
                ro.error = true;
                return Json(ro);
            }

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);

            conn.Open();
            try
            {

                NpgsqlCommand cmd = new NpgsqlCommand("sp_getdevices", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                NpgsqlDataReader reader = cmd.ExecuteReader();


                while (reader.Read())
                {

                    DeviceReturnObject dev = new DeviceReturnObject();
                    dev.DeviceName = reader.GetString(0);

                    if (!reader.IsDBNull(1))
                    {

                        dev.DeviceModel = reader.GetString(1);
                    }

                    if (!reader.IsDBNull(2))
                    {
                        dev.DeviceId = reader.GetString(2);

                    }

                    if (!reader.IsDBNull(3))
                    {
                        dev.IsPaired = true;
                    }
                    else
                    {
                        dev.IsPaired = false;
                    }

                    ret.Add(dev);


                }

                reader.Dispose();


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
        public IActionResult CreateDevice(string guid, string sharedid, string deviceName)
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

                NpgsqlCommand cmd = new NpgsqlCommand("sp_createdevice", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_devicename", deviceName));
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
        public IActionResult RegisterDevice([FromForm] string guid, [FromForm] string deviceName, [FromForm] string deviceId, [FromForm]  string deviceModel, [FromForm] string devicePIN, [FromForm] string regToken, [FromForm] string secret)
        {

            //sp_getDevice
            string errorMessage = "";
            bool isError = false;

            string dbsecret = "";

            bool deviceExists = false;
            string hexkey = "";
            DateTime dateKeyCreated = DateTime.MinValue;

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);

            conn.Open();
            try
            {

                NpgsqlCommand cmd = new NpgsqlCommand("sp_payloadbyaccount", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                NpgsqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SingleRow);

                if (reader.HasRows)
                {
                    reader.Read();
                    dbsecret = reader.GetString(3);
                }
                reader.Dispose();

                cmd = new NpgsqlCommand("sp_getdevice", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_devicename", deviceName));


                //verify that the pin isn't set

                reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    reader.Read();
                    //if PIN has not been set
                    if (reader.IsDBNull(4) && !reader.IsDBNull(5))
                    {
                        deviceExists = true;
                        hexkey = reader.GetString(5);
                        if (!reader.IsDBNull(8))
                        {
                            dateKeyCreated = reader.GetDateTime(8);
                            double exp = DateTime.Now.Subtract(dateKeyCreated).TotalSeconds;
                            if (exp > 1200)
                            {
                                deviceExists = false;
                            }
                        }
                    }
                }
                reader.Dispose();

                if (deviceExists)
                {

                    cmd = new NpgsqlCommand("sp_updatedevice", conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                    cmd.Parameters.Add(new NpgsqlParameter("p_devicename", deviceName));
                    cmd.Parameters.Add(new NpgsqlParameter("p_deviceid", deviceId));
                    cmd.Parameters.Add(new NpgsqlParameter("p_devicemodel", deviceModel));
                    cmd.Parameters.Add(new NpgsqlParameter("p_devicepin", devicePIN));
                    cmd.Parameters.Add(new NpgsqlParameter("p_regtoken", regToken));
                    cmd.ExecuteNonQuery();
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


            dbsecret = Helper.Decrypt(dbsecret, _csprng);

            if (dbsecret == secret)
            {

                if (deviceExists)
                {
                    hexkey = Helper.Decrypt(hexkey, _csprng);
                }

            }



            if (isError)
            {
                return Json(new ErrorObject(errorMessage));
            }
            else
            {
                dynamic ret = new System.Dynamic.ExpandoObject();
                ret.DeviceKey = hexkey;
                return Json(ret);
            }



        }


        [HttpPost("[action]")]
        public IActionResult DestroyDevice([FromForm] string guid, [FromForm] string regToken)
        {

            string errorMessage = "";
            bool isError = false;

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);

            conn.Open();
            try
            {

                NpgsqlCommand cmd = new NpgsqlCommand("sp_destroydevice", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_regtoken", regToken));
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
        public IActionResult DestroyDevice2fa([FromForm] string guid, [FromForm] string sharedid, [FromForm] string deviceName)
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
            string tokenToDelete = "";
            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);

            conn.Open();
            try
            {

                NpgsqlCommand cmd = new NpgsqlCommand("sp_destroydevice2", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_devicename", deviceName));
                NpgsqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    reader.Read();
                    tokenToDelete = reader.GetString(0);

                }
                reader.Dispose();
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
                return Json(new ReturnObject(tokenToDelete));
            }

        }

        [HttpPost("[action]")]
        public IActionResult GetDeviceKey([FromForm] string guid, [FromForm] string devicePIN, [FromForm] string regToken)
        {

            //sp_getDevice
            string errorMessage = "";
            bool isError = false;


            string deviceKey = "";


            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);

            conn.Open();
            try
            {

                NpgsqlCommand cmd = new NpgsqlCommand("sp_getdevicekey", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_devicepin", devicePIN));
                cmd.Parameters.Add(new NpgsqlParameter("p_regtoken", regToken));
                //
                NpgsqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    reader.Read();
                    deviceKey = reader.GetString(0);
                }
                reader.Dispose();


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


            if (deviceKey != "")
            {
                deviceKey = Helper.Decrypt(deviceKey, _csprng);
            }


            if (isError)
            {
                return Json(new ErrorObject(errorMessage));
            }
            else
            {
                dynamic ret = new System.Dynamic.ExpandoObject();
                ret.DeviceKey = deviceKey;
                return Json(ret);
            }



        }


       


        [HttpPost("[action]")]
        public IActionResult GetDeviceToken([FromForm] string guid, [FromForm] string sharedid, [FromForm] string deviceName)
        {

            if (!Helper.IsCallerValid(guid, sharedid, _connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "Invalid";
                ro.error = true;
                return Json(ro);
            }

            //sp_getDevice
            string errorMessage = "";
            bool isError = false;

            //always generate new tokens here
            //so every pair request generates a new set
            //of tokens that invalidate the previous set

            byte[] devkey = new byte[32];

            _csprng.getRandomValues(devkey);

            string deviceKey = HexString.FromByteArray(devkey);

            string enckey = Helper.Encrypt(deviceKey, _csprng);


            //two factor token
            byte[] tft = new byte[32];

            _csprng.getRandomValues(tft);

            string deviceToken = HexString.FromByteArray(tft);


            byte[] bregToken = new byte[32];

            _csprng.getRandomValues(bregToken);

            string regToken = HexString.FromByteArray(bregToken);


            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);

            conn.Open();
            try
            {

                DateTime expiry = DateTime.Now.AddYears(20);

                NpgsqlCommand cmd = new NpgsqlCommand("sp_createemailtoken", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_emailvalidationtoken", deviceToken));
                cmd.Parameters.Add(new NpgsqlParameter("p_walletid", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_emailaddress", ""));
                cmd.Parameters.Add(new NpgsqlParameter("p_expirydate", expiry));
                int tmpused = 0;
                cmd.Parameters.Add(new NpgsqlParameter("p_isused", tmpused));
                cmd.Parameters.Add(new NpgsqlParameter("p_tokentype", 3));
                cmd.ExecuteNonQuery();


                cmd = new NpgsqlCommand("sp_updatedevicetoken", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_devicename", deviceName));
                cmd.Parameters.Add(new NpgsqlParameter("p_devicekey", enckey));
                cmd.Parameters.Add(new NpgsqlParameter("p_twofactortoken", deviceToken));
                cmd.Parameters.Add(new NpgsqlParameter("p_regtoken", regToken));
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

            //deviceKey = Decrypt(deviceKey);

            if (isError)
            {
                return Json(new ErrorObject(errorMessage));
            }
            else
            {
                dynamic ret = new System.Dynamic.ExpandoObject();
                ret.DeviceToken = deviceToken;
                ret.DeviceKey = deviceKey;
                ret.RegToken = regToken;
                return Json(ret);
            }

        }

        

        [HttpPost("[action]")]
        public IActionResult GetDeviceTokenRestore([FromForm] string guid, [FromForm] string deviceName, [FromForm] string secret, [FromForm]  string challenge, [FromForm] string signaturecold)
        {

            dynamic ret = new System.Dynamic.ExpandoObject();
            string errorMessage = "";
            bool isError = false;

            if (Helper.IsSecretValid(guid, secret,_connstrWallet,_csprng))
            {


                if (signaturecold == "")
                {

                    isError = true;
                }

                if (!isError)
                {

                    //get the users public hot and cold key
                    //verify the signature on the message

                    //if both signatures match then reset 2fa

                    //get hot and cold public keys from the database

                    NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);

                    string userHotKey = "";
                    string userColdKey = "";

                    //validate that the address handed to us is valid
                    conn.Open();
                    try
                    {


                        NpgsqlCommand cmd = new NpgsqlCommand("sp_pubKeyByAccount", conn);
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
                                userHotKey = reader.GetString(0);
                                userColdKey = reader.GetString(1);
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
                        errorMessage = "ErrInvalid";
                    }
                    finally
                    {
                        conn.Close();
                    }

                    userColdKey = Helper.Decrypt(userColdKey, _csprng);

                    BIP32 bipCold = new BIP32(userColdKey, _csprng.Getsecp256k1());
                    string mcold = HexString.FromByteArray(bipCold.eckey.pubKey);

                    bool coldvalid = bipCold.eckey.verifySignature(HexString.ToByteArray(challenge), HexString.ToByteArray(signaturecold));


                    if (coldvalid)
                    {

                        //sp_resetTwoFactor
                        //reset 2 factor
                        //always generate new tokens here
                        //so every pair request generates a new set
                        //of tokens that invalidate the previous set

                        byte[] devkey = new byte[32];

                        _csprng.getRandomValues(devkey);

                        string deviceKey = HexString.FromByteArray(devkey);

                        string enckey = Helper.Encrypt(deviceKey, _csprng);


                        //two factor token
                        byte[] tft = new byte[32];

                        _csprng.getRandomValues(tft);

                        string deviceToken = HexString.FromByteArray(tft);


                        byte[] bregToken = new byte[32];

                        _csprng.getRandomValues(bregToken);

                        string regToken = HexString.FromByteArray(bregToken);


                        conn = new NpgsqlConnection(_connstrWallet);

                        conn.Open();
                        try
                        {

                            DateTime expiry = DateTime.Now.AddYears(20);

                            NpgsqlCommand cmd = new NpgsqlCommand("sp_createemailtoken", conn);
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.Add(new NpgsqlParameter("p_emailvalidationtoken", deviceToken));
                            cmd.Parameters.Add(new NpgsqlParameter("p_walletid", guid));
                            cmd.Parameters.Add(new NpgsqlParameter("p_emailaddress", ""));
                            cmd.Parameters.Add(new NpgsqlParameter("p_expirydate", expiry));
                            int tmpisused = 0;
                            cmd.Parameters.Add(new NpgsqlParameter("p_isused", tmpisused));
                            cmd.Parameters.Add(new NpgsqlParameter("p_tokentype", 3));
                            cmd.ExecuteNonQuery();


                            cmd = new NpgsqlCommand("sp_updatedevicetoken", conn);
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                            cmd.Parameters.Add(new NpgsqlParameter("p_devicename", deviceName));
                            cmd.Parameters.Add(new NpgsqlParameter("p_devicekey", enckey));
                            cmd.Parameters.Add(new NpgsqlParameter("p_twofactortoken", deviceToken));
                            cmd.Parameters.Add(new NpgsqlParameter("p_regtoken", regToken));
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

                        //deviceKey = Decrypt(deviceKey);



                        ret.DeviceToken = deviceToken;
                        ret.DeviceKey = deviceKey;
                        ret.RegToken = regToken;

                    }
                    else
                    {
                        isError = true;
                        errorMessage = "ErrInvalidSignature";
                    }

                }
            }
            else
            {
                isError = true;
                errorMessage = "ErrInvalid";

            }


            if (isError)
            {
                return Json(new ErrorObject(errorMessage));
            }
            else
            {
                return Json(ret);
            }

        }

        //make this function more generic
        [HttpPost("[action]")]
        public IActionResult GetTwoFactorToken([FromForm] string guid, [FromForm] string sharedid)
        {



            string errorMessage = "";
            bool isError = false;

            //string oguid = guid;
            // guid = hashGuid(guid);
            byte[] devkey = new byte[32];

            _csprng.getRandomValues(devkey);

            string tok = HexString.FromByteArray(devkey);

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
                int tmpused = 0;
                cmd.Parameters.Add(new NpgsqlParameter("p_isused", tmpused));
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


            if (isError)
            {
                return Json(new ErrorObject(errorMessage));
            }
            else
            {
                dynamic ret = new System.Dynamic.ExpandoObject();
                ret.Token = tok;
                return Json(ret);
            }


        }


        //a token to allow migration from mobile app
        //to the chrome app
        //required to allow override of getaccountdetails and setuptwofactor
        [HttpPost("[action]")]
        public IActionResult GetDevMigTwoFactorToken([FromForm] string guid, [FromForm]  string sharedid, [FromForm] string twoFactorToken)
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
                string sql = "sp_getemailtoken";
                NpgsqlCommand cmd = new NpgsqlCommand(sql, conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_walletid", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_emailvalidationtoken", twoFactorToken));
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
                    byte[] devkey = new byte[32];

                    _csprng.getRandomValues(devkey);

                    tok = HexString.FromByteArray(devkey);
                    tok = Helper.hashGuid(tok);

                    cmd = new NpgsqlCommand("sp_createemailtoken", conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new NpgsqlParameter("p_emailvalidationtoken", tok));
                    cmd.Parameters.Add(new NpgsqlParameter("p_walletid", guid));
                    cmd.Parameters.Add(new NpgsqlParameter("p_emailaddress", ""));
                    cmd.Parameters.Add(new NpgsqlParameter("p_expirydate", DateTime.Now.AddMinutes(10)));
                    int tmpisu = 0;
                    cmd.Parameters.Add(new NpgsqlParameter("p_isused", tmpisu));
                    cmd.Parameters.Add(new NpgsqlParameter("p_tokentype", 6));
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
                dynamic ret = new System.Dynamic.ExpandoObject();
                ret.message = tok;
                return Json(ret);
            }


        }



    }
}