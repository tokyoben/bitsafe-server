// COPYRIGHT 2011 Konstantin Ineshin, Irkutsk, Russia.
// If you like this project please donate BTC 18TdCC4TwGN7PHyuRAm8XV88gcCmAHqGNs

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;
using System.IO;
using System.Threading.Tasks;

using Newtonsoft.Json;
using Newtonsoft.Json.Linq;


namespace ninki_net_core
{
    public class BitnetClient : IBitnetClient
    {
        public BitnetClient()
        {
        }

        public BitnetClient(string a_sUri)
        {
            Url = new Uri(a_sUri);
        }

        public Uri Url;

        public ICredentials Credentials;

        public async Task<JObject> InvokeMethod(string a_sMethod, params object[] a_params)
        {
            HttpWebRequest webRequest = (HttpWebRequest)WebRequest.Create(Url);

            webRequest.Credentials = Credentials;

            webRequest.ContentType = "application/json-rpc";
            webRequest.Method = "POST";
            //webRequest.AllowAutoRedirect = true;

            JObject joe = new JObject();
            joe["jsonrpc"] = "2.0";
            joe["method"] = a_sMethod;

            if (a_params != null)
            {
                if (a_params.Length > 0)
                {
                    JArray props = new JArray();
                    foreach (var p in a_params)
                    {
                        props.Add(p);
                    }
                    joe.Add(new JProperty("params", props));
                }
            }


            joe["id"] = 0;

            string s = JsonConvert.SerializeObject(joe);
            //s = "{\"jsonrpc\":\"2.0\",\"method\":\"getinfo\",\"params\": [],\"id\":1}";

            // serialize json for the request
            byte[] byteArray = Encoding.UTF8.GetBytes(s);

            using (Stream dataStream = await webRequest.GetRequestStreamAsync())
            {
                dataStream.Write(byteArray, 0, byteArray.Length);
                try
                {
                    using (var webResponse = (HttpWebResponse)await webRequest.GetResponseAsync())
                    {
                        using (Stream str = webResponse.GetResponseStream())
                        {
                            using (StreamReader sr = new StreamReader(str))
                            {

                                //string test = sr.ReadToEnd();

                                return JsonConvert.DeserializeObject<JObject>(sr.ReadToEnd());

                            }
                        }
                    }

                }
                catch (Exception ex)
                {
                    //return JsonConvert.DeserializeObject<JObject>(ex.Message);
                    throw ex;
                }
            }

        }

        public async Task<string> SendRawTransaction(string tran)
        {
            JObject ret =  await InvokeMethod("sendrawtransaction", tran);
            string res = ret["result"].ToString();
            return res;

        }
        //sendrawtransaction

        
    }
}
