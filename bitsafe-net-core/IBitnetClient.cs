// COPYRIGHT 2011 Konstantin Ineshin, Irkutsk, Russia.
// If you like this project please donate BTC 18TdCC4TwGN7PHyuRAm8XV88gcCmAHqGNs

using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;


namespace ninki_net_core
{
  interface IBitnetClient
  {


    Task<string> SendRawTransaction(string tran);
      /// <summary>
    /// Safely copies wallet.dat to destination, which can be a directory or a path with filename.
    /// </summary>
    /// <param name="a_destination"></param>
    /// 
    
  }
}
