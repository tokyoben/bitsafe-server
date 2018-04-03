
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
    public class NetworkController : Controller
    {
        private ICSPRNGServer _csprng;
        private string _connstrWallet;
        private string _connstrRec;
        private string _connstrBlockchain;
        public NetworkController(ICSPRNGServer csprng)
        {
            _csprng = csprng;
            _connstrWallet = Config.ConnWallet;
            _connstrRec = Config.ConnRec;
            _connstrBlockchain = Config.ConnBlockchain;
        }


        [HttpPost("[action]")]
        public IActionResult GetUserNetwork([FromForm] string guid, [FromForm] string sharedid)
        {


            List<Friend> ret = new List<Friend>();

            if (!Helper.IsCallerValid(guid, sharedid, _connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "Invalid";
                ro.error = true;
                return Json(ro);
            }

            //retrieves the payload and returns to the client
            //payload is encrypted and only the client knows how to decrypt
            //payload contains all public keys and user hot private key

            string errorMessage = "";
            bool isError = false;

            string userid = "";


            List<Friend> friendsReceive = new List<Friend>();
            List<Friend> friendsSend = new List<Friend>();
            List<Friend> mergeList = new List<Friend>();

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {

                NpgsqlCommand cmd = new NpgsqlCommand("sp_getusernetworkreceive", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_status", 1));
                NpgsqlDataReader reader = cmd.ExecuteReader();

                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        Friend frnd = new Friend();
                        frnd.userName = reader.GetString(0);
                        frnd.userId = reader.GetString(1).ToString();
                        frnd.ICanRecieve = true;
                        if (!reader.IsDBNull(2))
                        {
                            frnd.category = reader.GetString(2);
                        }
                        frnd.profileImage = reader.GetString(3);
                        frnd.status = reader.GetString(4);
                        friendsReceive.Add(frnd);
                    }
                }
                else
                {
                    //isError = true;
                    errorMessage = "[]";
                }
                reader.Dispose();


                cmd = new NpgsqlCommand("sp_getusernetworksend", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_status", 1));
                reader = cmd.ExecuteReader();

                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        Friend frnd = new Friend();
                        frnd.userName = reader.GetString(0);
                        frnd.userId = reader.GetString(1).ToString();
                        frnd.ICanSend = true;
                        //frnd.packet = reader.GetString(2);
                        frnd.category = reader.GetString(2);
                        frnd.profileImage = reader.GetString(3);
                        frnd.status = reader.GetString(4);

                        string valhash = reader.GetString(5);
                        if (valhash.Length > 0)
                        {
                            frnd.validated = true;
                        }
                        friendsSend.Add(frnd);
                    }
                }
                else
                {
                    //isError = true;
                    errorMessage = "[]";
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


            for (int j = 0; j < friendsReceive.Count; j++)
            {
                for (int k = 0; k < friendsSend.Count; k++)
                {
                    if (friendsReceive[j].userName == friendsSend[k].userName)
                    {
                        friendsReceive[j].ICanSend = true;
                        friendsReceive[j].validated = friendsSend[k].validated;
                        friendsReceive[j].packet = friendsSend[k].packet;
                        mergeList.Add(friendsReceive[j]);
                    }
                }
            }
            for (int k = 0; k < friendsSend.Count; k++)
            {
                if (!friendsReceive.Exists(m => m.userName == friendsSend[k].userName))
                {
                    mergeList.Add(friendsSend[k]);
                }
            }
            for (int k = 0; k < friendsReceive.Count; k++)
            {
                if (!friendsSend.Exists(m => m.userName == friendsReceive[k].userName))
                {
                    mergeList.Add(friendsReceive[k]);
                }
            }

            // mergeList = mergeList.OrderBy(us => us.userName).ToList();



            int i = 0;
            foreach (Friend item in mergeList)
            {
                if (item.category == "")
                {
                    item.category = "Contacts";
                }

                i++;
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
                return Json(mergeList);
            }

        }

        [HttpPost("[action]")]
        public IActionResult GetFriendRequests([FromForm] string guid, [FromForm] string sharedid)
        {

            if (!Helper.IsCallerValid(guid, sharedid, _connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "Invalid";
                ro.error = true;
                return Json(ro);
            }


            //get the friend requests for the guid

            string errorMessage = "";
            bool isError = false;

            string userid = "";


            List<Friend> friendRequests = new List<Friend>();

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {


                //if (status == 1)
                //{

                NpgsqlCommand cmd = new NpgsqlCommand("sp_getfriendrequests", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                NpgsqlParameter param = new NpgsqlParameter();
                param.ParameterName = "p_status";
                param.DbType = DbType.Int32;
                param.Value = 0;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                cmd.Parameters.Add(param);
                NpgsqlDataReader reader = cmd.ExecuteReader();

                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        Friend frnd = new Friend();
                        frnd.userName = reader.GetString(0);
                        frnd.userId = reader.GetString(1).ToString();
                        frnd.ICanSend = true;
                        friendRequests.Add(frnd);
                    }
                }
                else
                {
                    //isError = true;
                    errorMessage = "[]";
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
            return Json(friendRequests);
        }

        [HttpPost("[action]")]
        public IActionResult GetPendingUserRequests([FromForm] string guid, [FromForm] string sharedid)
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



            List<Friend> friendsReceive = new List<Friend>();

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {

                NpgsqlCommand cmd = new NpgsqlCommand("sp_getUserNetworkReceive", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                NpgsqlParameter param = new NpgsqlParameter();
                param.ParameterName = "p_status";
                param.Value = 0;
                param.DbType = DbType.Int32;

                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                cmd.Parameters.Add(param);
                NpgsqlDataReader reader = cmd.ExecuteReader();

                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        Friend frnd = new Friend();
                        frnd.userName = reader.GetString(0);
                        frnd.userId = reader.GetString(1).ToString();
                        frnd.ICanRecieve = true;
                        friendsReceive.Add(frnd);
                    }
                }
                else
                {
                    //isError = true;
                    errorMessage = "[]";
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



            return Json(friendsReceive);
        }


        [HttpPost("[action]")]
        public IActionResult GetUserNetworkCategory()
        {

            // sp_getUserNetworkCategory


            string errorMessage = "";
            bool isError = false;
            List<NetworkCategory> cats =  new List<NetworkCategory>();
            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {
                NpgsqlCommand cmd = new NpgsqlCommand("sp_getusernetworkcategory", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                NpgsqlDataReader reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    NetworkCategory nc = new NetworkCategory();

                    nc.CategoryId  = reader.GetInt32(0);
                    nc.Category  = reader.GetString(1);
                    cats.Add(nc);
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

            return Json(cats);

        }


        [HttpPost("[action]")]
        public IActionResult DoesNetworkExist([FromForm] string guid, [FromForm] string sharedid, [FromForm] string username)
        {

            if (!Helper.IsCallerValid(guid, sharedid,_connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "ErrInvalid";
                ro.error = true;
                return Json(ro);
            }

            bool networkExists = false;
            string errorMessage = "";
            bool isError = false;
            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {

                NpgsqlCommand com = new NpgsqlCommand("sp_doesnetworkexist", conn);
                com.CommandType = CommandType.StoredProcedure;
                com.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                com.Parameters.Add(new NpgsqlParameter("p_username", username));

                NpgsqlDataReader reader = com.ExecuteReader(CommandBehavior.SingleResult);
                if (reader.HasRows)
                {
                    networkExists = true;
                }
                else
                {
                    networkExists = false;
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
                NetworkExists ne = new NetworkExists();
                ne.message = networkExists;
                return Json(ne);
            }
        }

        [HttpPost("[action]")]
        public IActionResult GetRSAKey([FromForm] string guid, [FromForm] string sharedid, [FromForm] string username)
        {

            if (!Helper.IsCallerValid(guid, sharedid,_connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "ErrInvalid";
                ro.error = true;
                return Json(ro);
            }


            string errorMessage = "";
            bool isError = false;
            string publicKey = "";

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {
                NpgsqlCommand cmd = new NpgsqlCommand("sp_getrsakey", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_username", username));
                NpgsqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SingleRow);
                if (reader.HasRows)
                {
                    reader.Read();
                    publicKey = reader.GetString(0);
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
                errorMessage = "ErrSystem";
            }
            finally
            {
                conn.Close();
            }
            try
            {
                string salt = Helper.hashGuid(username);
                publicKey = Helper.Decrypt(publicKey,_csprng);
            }
            catch (Exception ex)
            {
                isError = true;
                errorMessage = "ErrSystem";
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
                ro.message = publicKey;
                return Json(ro);
            }
        }

        [HttpPost("[action]")]
        public IActionResult CreateFriend([FromForm] string guid, [FromForm] string sharedid, [FromForm] string username, [FromForm] string node, [FromForm] string packetForFriend, [FromForm] string validationHash)
        {



            //add a db transaction to this function

            if (!Helper.IsCallerValid(guid, sharedid,_connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "ErrInvalid";
                ro.error = true;
                return Json(ro);
            }

            if(validationHash == null){
                validationHash = "";
            }

            string errorMessage = "";
            bool isError = false;
            string cacheKey = "";


            string[] spnode = node.Split('/');

            int nodeLeaf = int.Parse(spnode[spnode.Length - 1]);

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();

            NpgsqlTransaction tran = conn.BeginTransaction();

            try
            {

                NpgsqlCommand com = new NpgsqlCommand("sp_createfriend", conn);
                com.Transaction = tran;
                com.CommandType = CommandType.StoredProcedure;
                com.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                com.Parameters.Add(new NpgsqlParameter("p_username", username));
                com.Parameters.Add(new NpgsqlParameter("p_packetforfriend", packetForFriend));
                com.Parameters.Add(new NpgsqlParameter("p_validationhash", validationHash));

                NpgsqlDataReader fread = com.ExecuteReader();

                if (fread.HasRows)
                {
                    if (fread.Read())
                    {

                        cacheKey = fread.GetString(0);

                    }

                }
                fread.Dispose();
                //walletidFriend

                //if there is a recipricol rejected request
                //reactivate the request to give the user the opportunity to accept


                //of course we have to derive from scratch here
                string ninkiPrivateKey = "";

                NpgsqlCommand cmd = new NpgsqlCommand("sp_getmasterkey", conn);
                cmd.Transaction = tran;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                NpgsqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SingleRow);
                if (reader.HasRows)
                {
                    reader.Read();
                    ninkiPrivateKey = reader.GetString(0);
                }
                else
                {
                    isError = true;
                    errorMessage = "ErrAccount";
                }
                reader.Dispose();


                ninkiPrivateKey = Helper.Decrypt(ninkiPrivateKey,_csprng);

                //use as seed
                BIP32 bip32 = new BIP32(ninkiPrivateKey, _csprng.Getsecp256k1());
                BIP32 bip321 = bip32.Derive("m/0/" + nodeLeaf.ToString());

                string publicKeyCache = Helper.Encrypt(bip321.ExtendedPublicKeyString(null),_csprng);
                string privateKeyCacheEncrypted = Helper.Encrypt(bip321.ExtendedPrivateKeyString(null),_csprng);

                NpgsqlCommand cmd2 = new NpgsqlCommand("sp_createnodecache", conn);
                cmd2.Transaction = tran;
                cmd2.CommandType = CommandType.StoredProcedure;
                //com.Transaction = tran;
                cmd2.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                cmd2.Parameters.Add(new NpgsqlParameter("p_nodelevel", node));
                cmd2.Parameters.Add(new NpgsqlParameter("p_ninkipub", publicKeyCache));
                cmd2.Parameters.Add(new NpgsqlParameter("p_ninkipk", privateKeyCacheEncrypted));
                cmd2.ExecuteNonQuery();

                tran.Commit();
                //derive the root ninki keys and cache in the NodeKeyCache table


            }
            catch (Exception ex)
            {
                tran.Rollback();
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
                CreateFriendReturnObject ret =  new CreateFriendReturnObject();
                ret.CacheKey = cacheKey;
                return Json(ret);
            }


        }

        [HttpPost("[action]")]
        public IActionResult GetFriendRequestPacket([FromForm] string guid, [FromForm] string sharedid, [FromForm] string username)
        {

            if (!Helper.IsCallerValid(guid, sharedid,_connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "ErrInvalid";
                ro.error = true;
                return Json(ro);
            }

            //here i am getting a friend request packet that username left for me
            string packet = ""; ;
            bool isError = false;
            string errorMessage = "";
            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {

                NpgsqlCommand com = new NpgsqlCommand("sp_getfriendrequestpacket", conn);
                com.CommandType = CommandType.StoredProcedure;
                com.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                com.Parameters.Add(new NpgsqlParameter("p_username", username));

                NpgsqlDataReader reader = com.ExecuteReader();
                if (reader.HasRows)
                {
                    reader.Read();
                    packet = reader.GetString(0);
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
                ro.message = errorMessage;
                ro.error = true;
                return Json(ro);
            }
            else
            {
                ReturnObject ret =  new ReturnObject();
                ret.message = packet;
                return Json(ret);
            }
        }

        [HttpPost("[action]")]
        public IActionResult UpdateFriend([FromForm] string guid, [FromForm]string sharedid, [FromForm]string username, [FromForm] string packet, [FromForm] string validationHash)
        {

            if (!Helper.IsCallerValid(guid, sharedid,_connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "ErrInvalid";
                ro.error = true;
                return Json(ro);
            }

            if(validationHash==null){
                validationHash = "";
            }

            string errorMessage = "";
            bool isError = false;
            string userid = "";
            string useridFriend = "";
            string cacheKey = "";

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {

                NpgsqlCommand com = new NpgsqlCommand("sp_updatefriend", conn);
                com.CommandType = CommandType.StoredProcedure;
                //here we update the request with our own packet
                //in this context I Ben am Bobs friend
                com.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                com.Parameters.Add(new NpgsqlParameter("p_username", username));
                com.Parameters.Add(new NpgsqlParameter("p_addressset", packet));
                com.Parameters.Add(new NpgsqlParameter("p_validationhash", validationHash));

                NpgsqlDataReader reader = com.ExecuteReader();

                if (reader.HasRows)
                {
                    reader.Read();

                    //get the reverse cache key
                    //so cache can be invalidated / updated in the in memory cache

                    string theirWalletId = reader.GetString(0);

                    cacheKey = theirWalletId;
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
                ro.message = errorMessage;
                ro.error = true;
                return Json(ro);
            }
            else
            {
               ReturnObject ret  = new ReturnObject();
               ret.message = cacheKey;
               return Json(ret);
            }
        }

        [HttpPost("[action]")]
        public IActionResult GetFriend([FromForm] string guid,[FromForm] string sharedid,[FromForm] string username)
        {

            if (!Helper.IsCallerValid(guid, sharedid,_connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "ErrInvalid";
                ro.error = true;
                return Json(ro);
            }


            string errorMessage = "";
            bool isError = false;

            Friend item = new Friend();

            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {

                NpgsqlCommand cmd = new NpgsqlCommand("sp_getfriend", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_username", username));
                NpgsqlDataReader reader = cmd.ExecuteReader();

                if (reader.HasRows)
                {
                    reader.Read();
                    item.userName = username;
                    item.category = reader.GetString(0);
                    item.profileImage = reader.GetString(1);
                    item.status = reader.GetString(2);

                    int sendStatus = reader.GetInt32(3);
                    int receiveStatus = reader.GetInt32(4);

                    if (sendStatus == 1)
                    {
                        item.ICanSend = true;
                    }

                    if (receiveStatus == 1)
                    {
                        item.ICanRecieve = true;
                    }

                    string valhash = reader.GetString(5);
                    if (valhash.Length > 0)
                    {
                        item.validated = true;
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

            if (item.category == "")
            {
                item.category = "Contacts";
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

               return Json(item);
            }

        }

        [HttpPost("[action]")]
        public IActionResult GetFriendPacket([FromForm] string guid, [FromForm] string sharedid, [FromForm] string username)
        {

            if (!Helper.IsCallerValid(guid, sharedid,_connstrWallet))
            {
                ErrorObject ro = new ErrorObject();
                ro.message = "ErrInvalid";
                ro.error = true;
                return Json(ro);
            }

            string packet = "";
            bool isError = false;
            string errorMessage = "";
            NpgsqlConnection conn = new NpgsqlConnection(_connstrWallet);
            conn.Open();
            try
            {

                NpgsqlCommand com = new NpgsqlCommand("sp_getfriendpacket", conn);
                com.CommandType = CommandType.StoredProcedure;
                com.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                com.Parameters.Add(new NpgsqlParameter("p_username", username));

                NpgsqlDataReader reader = com.ExecuteReader(CommandBehavior.SingleResult);
                if (reader.HasRows)
                {
                    reader.Read();
                    packet = reader.GetString(0);
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
                ro.message = errorMessage;
                ro.error = true;
                return Json(ro);
            }
            else
            {
               ReturnObject ret  = new ReturnObject();
               ret.message = packet;
               return Json(ret);
            }
        }

    }
}