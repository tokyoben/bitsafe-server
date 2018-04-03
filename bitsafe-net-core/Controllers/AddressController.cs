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
    public class AddressController : Controller
    {
        private ICSPRNGServer _csprng;
        private string _connstrWallet;
        private string _connstrRec;
        private string _connstrBlockchain;
        public AddressController(ICSPRNGServer csprng)
        {
            _csprng = csprng;
            _connstrWallet = Config.ConnWallet;
            _connstrRec = Config.ConnRec;
            _connstrBlockchain = Config.ConnBlockchain;
        }


        private bool IsAddressValid(string guid, string path, string address)
        {

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            string errorMessage = "";
            bool isError = false;

            string userHotKey = "";
            string userColdKey = "";
            string userNinkiKey = "";

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
                        userHotKey = reader.GetString(0);
                        userColdKey = reader.GetString(1);
                        userNinkiKey = reader.GetString(2);
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

            if (isError)
            {
                return false;
            }


            userHotKey = Helper.Decrypt(userHotKey,_csprng);
            userColdKey = Helper.Decrypt(userColdKey,_csprng);
            userNinkiKey = Helper.Decrypt(userNinkiKey,_csprng);

            string checkAddress = GetAddress(userHotKey, userColdKey, userNinkiKey, path);
            return (checkAddress == address);

        }

        private string GetAddress(string UserMasterPublicKeyHot, string UserMasterPublicKeyCold, string NinkiMasterPublicKey, string path)
        {

            string[] errorMessage = new string[1];
            bool isError = false;
            //verify path
            foreach (char item in path)
            {
                if (!(Char.IsDigit(item) || item == '/' || item == 'm'))
                {
                    isError = true;
                }
            }

            string retaddress = "";

            string[] keys = new string[3];
            try
            {

                Console.WriteLine(UserMasterPublicKeyHot);

                BIP32 bip322 = new BIP32(UserMasterPublicKeyHot, _csprng.Getsecp256k1());

                BIP32 bip3221 = bip322.Derive(path);
                string derivedKey2 = HexString.FromByteArray(bip3221.eckey.pubKey);

                Console.WriteLine(UserMasterPublicKeyCold);

                BIP32 bip323 = new BIP32(UserMasterPublicKeyCold, _csprng.Getsecp256k1());
                BIP32 bip3231 = bip323.Derive(path);
                string derivedKey3 = HexString.FromByteArray(bip3231.eckey.pubKey);

                Console.WriteLine(NinkiMasterPublicKey);

                BIP32 bip321 = new BIP32(NinkiMasterPublicKey, _csprng.Getsecp256k1());
                BIP32 bip3211 = bip321.Derive(path);
                string derivedNinki = HexString.FromByteArray(bip3211.eckey.pubKey);

                retaddress = GetMultiSig2Of3Address(derivedKey2, derivedKey3, derivedNinki);

                keys[0] = derivedKey2;
                keys[1] = derivedKey3;
                keys[2] = derivedNinki;

                if (isError)
                {
                    return "ErrInvalid";
                }
            }
            catch (Exception ex)
            {
                errorMessage[0] = "ErrSystem";
                return "ErrInvalid";
            }

            return retaddress;
        }

        private string GetMultiSig2Of3Address(string key1, string key2, string key3)
        {

            //BIP32 bip321 = new BIP32(key1);
            //string hexKey1 = HexString.FromByteArray(bip321.eckey.pubKey);

            //BIP32 bip322 = new BIP32(key2);
            //string hexKey2 = HexString.FromByteArray(bip322.eckey.pubKey);

            //BIP32 bip323 = new BIP32(key3);
            //string hexKey3 = HexString.FromByteArray(bip323.eckey.pubKey);

            object[] addr = new object[3];
            addr[0] = key1;
            addr[1] = key2;
            addr[2] = key3;

            //string multsig = MultiSig.MultSigScript(addr);

            Script multScript = ScriptTemplate.MultiSig(addr);

            Address address = new Address(multScript.ToBytes(), Address.SCRIPT);

            byte[] test = multScript.ToBytes();

            return address.ToString();
        }


        [HttpPost("[action]")]
        public IActionResult CreateAddressForFriend([FromForm] string guid,[FromForm] string sharedid, [FromForm] string username, [FromForm] string address, [FromForm] int leaf, [FromForm] string pk1, [FromForm] string pk2,[FromForm]  string pk3)
        {

            if (!Helper.IsCallerValid(guid, sharedid, _connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "ErrInvalid";
                ro.error = true;
                return Json(ro);
            }

            bool isError = false;
            string errorMessage = "";
            string pathToUse = "";
            string userid = "";
            string useridFriend = "";
            string walletIdFriend = "";
            string path = "";

            pk1 = Helper.Encrypt(pk1,_csprng);
            pk2 = Helper.Encrypt(pk2,_csprng);
            pk3 = Helper.Encrypt(pk3,_csprng);


            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();

            try
            {
                NpgsqlCommand cmd = new NpgsqlCommand("sp_nodeforfriend", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_username", username));
                NpgsqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SingleResult);
                if (reader.Read())
                {
                    if (!reader.IsDBNull(0))
                    {
                        pathToUse = reader.GetString(0);
                        walletIdFriend = reader.GetString(1);
                    }
                }
                reader.Dispose();

                path = pathToUse + '/' + leaf.ToString();

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

            if (!isError)
            {
                if (!IsAddressValid(walletIdFriend, path, address))
                {
                    isError = true;
                    errorMessage = "ErrInvalidRequest";
                }
                else
                {

                    conn.Open();
                    try
                    {
                        NpgsqlCommand com = new NpgsqlCommand("sp_createaccountaddress", conn);
                        com.CommandType = CommandType.StoredProcedure;
                        com.Parameters.Add(new NpgsqlParameter("p_guid", walletIdFriend));
                        com.Parameters.Add(new NpgsqlParameter("p_path", path));
                        com.Parameters.Add(new NpgsqlParameter("p_address", address));
                        com.Parameters.Add(new NpgsqlParameter("p_branch", pathToUse));
                        com.Parameters.Add(new NpgsqlParameter("p_leaf", leaf));
                        com.Parameters.Add(new NpgsqlParameter("p_pk1", pk1));
                        com.Parameters.Add(new NpgsqlParameter("p_pk2", pk2));
                        com.Parameters.Add(new NpgsqlParameter("p_pk3", pk3));
                        com.ExecuteNonQuery();
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
            }

            if (isError)
            {
                ErrorObject ro = new ErrorObject();
                ro.message = errorMessage;
                ro.error = true;
                return Json(ro); }
            else
            {
                //return new MemoryStream(Encoding.UTF8.GetBytes(getReturnJSON("ok")));
                ReturnObject ro = new ReturnObject();
                ro.error = false;
                ro.message = "ok";
                return Json(ro);
            }


        }

        [HttpPost("[action]")]
        public IActionResult CreateAddress([FromForm] string guid, [FromForm] string sharedid, [FromForm] string path, [FromForm] string address, [FromForm] string pk1, [FromForm] string pk2, [FromForm] string pk3)
        {
            if (!Helper.IsCallerValid(guid, sharedid, _connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "ErrInvalid";
                ro.error = true;
                return Json(ro);
            }

            string[] spath = path.Split('/');

            //verify path
            foreach (char item in path)
            {
                if (!(Char.IsDigit(item) || item == '/' || item == 'm'))
                {
                    ErrorObject ro = new ErrorObject();
                    ro.message = "ErrInvalid";
                    ro.error = true;
                    return Json(ro);
                }
            }

            string errorMessage = "";
            bool isError = false;

            //change address to be used as part of a transaction
            //so validate
            //--all addresses are validated
            //--malware could conceivably register a false address with the server

            //**can provide a secondary check that nothing has gone wrong with the address gen process though...

            //if (spath[2] == "1")
            //{
            if (!IsAddressValid(guid, path, address))
            {
                isError = true;
                errorMessage = "ErrInvalidRequest";
            }
            //}


            if (!isError)
            {
                pk1 = Helper.Encrypt(pk1,_csprng);
                pk2 = Helper.Encrypt(pk2,_csprng);
                pk3 = Helper.Encrypt(pk3,_csprng);


                NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
                conn.Open();
                try
                {

                    string sleaf = spath[spath.Length - 1];
                    int leaf = int.Parse(sleaf);
                    string branch = path.Remove(path.Length - (sleaf.Length + 1), sleaf.Length + 1);

                    NpgsqlCommand com = new NpgsqlCommand("sp_createaccountaddress", conn);
                    com.CommandType = CommandType.StoredProcedure;
                    com.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                    com.Parameters.Add(new NpgsqlParameter("p_path", path));
                    com.Parameters.Add(new NpgsqlParameter("p_address", address));
                    com.Parameters.Add(new NpgsqlParameter("p_branch", branch));
                    com.Parameters.Add(new NpgsqlParameter("p_leaf", leaf));
                    com.Parameters.Add(new NpgsqlParameter("p_pk1", pk1));
                    com.Parameters.Add(new NpgsqlParameter("p_pk2", pk2));
                    com.Parameters.Add(new NpgsqlParameter("p_pk3", pk3));
                    com.ExecuteNonQuery();
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
            }

            if (isError)
            {
                ErrorObject ro = new ErrorObject();
                ro.message = errorMessage;
                ro.error = true;
                return Json(ro); }
            else
            {
                //return new MemoryStream(Encoding.UTF8.GetBytes(getReturnJSON("ok")));
                ReturnObject ro = new ReturnObject();
                ro.error = false;
                ro.message = "ok";
                return Json(ro);
            }


            //put some bitcoins in the aacount for testing
            //this is for testing purposes only
            //try
            //{
            //    BitnetClient bc = new BitnetClient("http://localhost:8332");
            //    bc.Credentials = new NetworkCredential("bitcoinrpc", "Czo7zcwL3ruNH7TH2w4ZHqqmEjzo6DqjPLek6pYE3eAQ");

            //    //JObject newadd = bc.CreateMultiSigAddress("", 2, addr);

            //    //bc.SendToAddress(address, 1, "", "");

            //}
            //catch (Exception ex)
            //{
            //    Console.WriteLine(ex.Message);
            //}



        }


        [HttpPost("[action]")]
        public IActionResult GetNextLeafForFriend([FromForm] string guid,[FromForm] string sharedid, [FromForm] string username)
        {

            if (!Helper.IsCallerValid(guid, sharedid, _connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "ErrInvalid";
                ro.error = true;
                return Json(ro);
            }

            //this function is used to get a path to derive an address for a friend so you can send them money

            //the guid will resolve to the friend in this case
            //and the username is the primary user


            bool isError = false;
            string errorMessage = "";


            //we can always reserver nodes further up the stack for other purposes

            int nextLeaf = 0;

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();

            try
            {

                NpgsqlCommand cmd = new NpgsqlCommand("sp_getnextleafforfriend", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_username", username));
                NpgsqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SingleResult);
                if (reader.Read())
                {
                    if (!reader.IsDBNull(0))
                    {
                        nextLeaf = reader.GetInt32(0);
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
                ro.error = false;
                ro.message = nextLeaf.ToString();
                return Json(ro);
            }

            //derive the root key for the node for each public key


            //packetToVerify

        }


        [HttpPost("[action]")]
        public IActionResult GetNextLeaf([FromForm] string guid, [FromForm] string sharedid, [FromForm] string pathToUse)
        {

            if (!Helper.IsCallerValid(guid, sharedid, _connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "ErrInvalid";
                ro.error = true;
                return Json(ro);
            }


            bool isError = false;
            string errorMessage = "";

            //rules for node use
            //main wallet m/0/0/0..n

            //reserve up to 1000 nodes for user

            //friend1 m/0/1000/0..n
            //friend2 m/0/1001/0..n

            //we can always reserver nodes further up the stack for other purposes

            //string pathToUse = "m/0/0";


            int nextLeaf = 0;

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();

            try
            {
                //now check the address table for the next leaf
                //do do this we have to look up the wallet if of the friend we are deriving the address for
                NpgsqlCommand cmd = new NpgsqlCommand("sp_getnextleaf", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_pathtouse", pathToUse));
                NpgsqlDataReader reader = cmd.ExecuteReader();
                if (reader.Read())
                {
                    if (!reader.IsDBNull(0))
                    {
                        nextLeaf = reader.GetInt32(0);
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
                ro.error = false;
                ro.message = nextLeaf.ToString();
                return Json(ro);
                
            }

        }

        [HttpPost("[action]")]
        public IActionResult  GetNextNodeForFriend([FromForm] string guid, [FromForm] string sharedid, [FromForm] string username)
        {

            if (!Helper.IsCallerValid(guid, sharedid,_connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "ErrInvalid";
                ro.error = true;
                return Json(ro);    
            }

            bool isError = false;
            string errorMessage = "";

            //rules for node use
            //main wallet m/0/0/0..n

            //reserve up to 1000 nodes for user

            //friend1 m/0/1000/0..n
            //friend2 m/0/1001/0..n

            //we can always reserver nodes further up the stack for other purposes

            int nodeToUse = 1000;


            string userid = "";
            string friendid = "";
            string pathToUse = "";

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();

            try
            {
                //must reserve the node in the database at this point
                //using a transaction

                NpgsqlCommand cmd2 = new NpgsqlCommand("sp_getnextnodeforfriend", conn);
                cmd2.CommandType = CommandType.StoredProcedure;
                cmd2.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                cmd2.Parameters.Add(new NpgsqlParameter("p_username", username));
                cmd2.Parameters.Add(new NpgsqlParameter("p_nodebranch", "m/0"));

                NpgsqlDataReader reader = cmd2.ExecuteReader();
                if (reader.HasRows)
                {
                    reader.Read();
                    nodeToUse = reader.GetInt32(0);
                }
                else
                {
                    isError = true;

                }
                reader.Dispose();
                //friendid
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

            pathToUse = "m/0/" + nodeToUse.ToString();

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
                ro.message = pathToUse;
                return Json(ro);
            }

        }
    }
}