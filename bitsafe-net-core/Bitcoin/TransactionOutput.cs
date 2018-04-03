using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ninki_net_core
{
    public class TransactionOutput
    {

        public long Amount = 0; 
        public string TransactionId = "";
        public int OutputIndex = 0;
        public string Address = "";
        public string NodeLevel = "";
        public bool IsPending = false;
        public string PK1 = "";
        public string PK2 = "";
        public string PK3 = "";
    }
}
