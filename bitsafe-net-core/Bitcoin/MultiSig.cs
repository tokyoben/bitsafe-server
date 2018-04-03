using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Security.Cryptography;


namespace ninki_net_core
{
    public class MultiSig
    {

        public static string MultSigScript(object[] addresses)
        {
            return HexString.FromByteArray(ScriptTemplate.MultiSig(addresses).ToBytes());
        }


        public static string AppendSignatures(string[] sigs, string rawTransaction)
        {
            Transaction tran = new Transaction(HexString.ToByteArray(rawTransaction));
            int i = 0;
            foreach (TxIn input in tran.inputs)
            {
                //input.scriptSig

                Script orignal = new Script(input.scriptSig);

                byte[] userSig = orignal.elements[1].data;

                
                Script s = new Script(new Byte[] { 0x00 });
                //add the signatures to the script
                s.elements.Add(new ScriptElement(userSig));
                s.elements.Add(new ScriptElement(HexString.ToByteArray(sigs[i])));

                //add the original multisig script
                s.elements.Add(new ScriptElement(orignal.elements[2].data));

                //overwrite the script on the transaction with the new signatures + script
                input.scriptSig = s.ToBytes();
                i++;
            }

            return HexString.FromByteArray(tran.ToBytes());
        }

        //switched to user key pair directly

        public static bool VerifySignature(string key, string message, string sig)
        {
            PublicKey pk1 = new PublicKey(HexString.ToByteArray(key));
            return pk1.VerifySignature(HexString.ToByteArray(message), HexString.ToByteArray(sig));
        }


        public static string GetSignature2(string key, string hashForSigning, secp256k1Wrap secp256k1)
        {

            string sig = secp256k1.Sign(key, hashForSigning);

            byte[] b  = HexString.ToByteArray(sig);

            int slen = b[1];
            int srlen = b[3];
            int sslen = b[5 + srlen];
            int ssend = 6 + srlen + sslen;
            int pad = ((b.Length - ssend) *2);

            sig = sig.Remove(sig.Length - pad);
            sig = sig + "01";

            return sig;
         
        }


        public static string GetSignature(string key, string hashForSigning)
        {

            HashType hashType = HashType.SIGHASH_ALL;

            PrivateKey pk1 = new PrivateKey(HexString.ToByteArray(key));

            ECKeyPair ppk = new ECKeyPair(pk1.ToBytes(),null,false,true);

            Script s = new Script(new Byte[] { 0x00 });

            Byte[] sig = pk1.Sign(HexString.ToByteArray(hashForSigning));

            sig = sig.Concat(new Byte[] { (Byte)hashType }).ToArray();

            string ret = HexString.FromByteArray(sig);
            
            return ret;

        }
        


        public static string MultiSigHashForSigning3(string publickey1, string publickey2, string publickey3, int index, List<TransactionOutput> outputsToSpend, List<TransactionOutput> outputsToSend)
        {

            //get the hash to sign for a single input
            TxIn[] txins = new TxIn[outputsToSpend.Count];

            object[] addresses = new object[3];

            addresses[0] = publickey1;
            addresses[1] = publickey2;
            addresses[2] = publickey3;

            string mscript = MultSigScript(addresses);

            for (int i = 0; i < outputsToSpend.Count; i++)
            {
                if (i == index)
                    txins[i] = new TxIn(HexString.ToByteArrayReversed(outputsToSpend[i].TransactionId), (uint)outputsToSpend[i].OutputIndex, HexString.ToByteArray(mscript));
                else
                    txins[i] = new TxIn(HexString.ToByteArrayReversed(outputsToSpend[i].TransactionId), (uint)outputsToSpend[i].OutputIndex, new Byte[0]); ;
            }

            
            TxOut[] txouts = new TxOut[outputsToSend.Count];

            HashType hashType = HashType.SIGHASH_ALL;

            int j = 0;
            foreach (TransactionOutput outp in outputsToSend)
            {
                //PublicKey pkPayTo = new PublicKey(HexString.ToByteArray(outp.Address));
                Address addr = new Address(outp.Address);
                Script scPayTo = ScriptTemplate.PayToAddress(addr);

                TxOut toutSpend = new TxOut((ulong)outp.Amount, scPayTo.ToBytes());

                txouts[j] = toutSpend;
                j++;
            }


            //create the new transaction to spend the coins at the multisig address
            Transaction tx = new Transaction(1, txins, txouts, 0);

            //clone the transaction
            //Transaction txCopy = new Transaction(tx.ToBytes());

            SHA256 sha256 = SHA256.Create();

            //hash the transaction with some leading bytes
            Byte[] txHash = tx.ToBytes().Concat(new Byte[] { (Byte)hashType, 0x00, 0x00, 0x00 }).ToArray();
            txHash = sha256.ComputeHash(sha256.ComputeHash(txHash));

            return HexString.FromByteArray(txHash);

        }
        
        //public static string MultiSigHashForSigning2(string publickey1, string publickey2, string publickey3, string transactionid, uint prevoutIndex, List<TransactionOutput> outputsToSend)
        //{

        //    //get the hash to sign for a single input
        //    TxIn[] txins = new TxIn[1];
        //    TxOut[] txouts = new TxOut[outputsToSend.Count];

        //    HashType hashType = HashType.SIGHASH_ALL;

        //    int i = 0;
        //    foreach (TransactionOutput outp in outputsToSend)
        //    {
        //        //PublicKey pkPayTo = new PublicKey(HexString.ToByteArray(outp.Address));
        //        Address addr = new Address(outp.Address);
        //        Script scPayTo = ScriptTemplate.PayToAddress(addr);

        //        TxOut toutSpend = new TxOut((ulong)outp.Amount, scPayTo.ToBytes());          

        //        txouts[i] = toutSpend;
        //        i++;
        //    }


        //    object[] addresses = new object[3];

        //    addresses[0] = publickey1;
        //    addresses[1] = publickey2;
        //    addresses[2] = publickey3;


            

        //    string mscript = MultSigScript(addresses);


        //    //create input based on previous output to spend
        //    //and the redeem script for the multi-sig address
        //    TxIn tin = new TxIn(HexString.ToByteArrayReversed(transactionid), prevoutIndex, HexString.ToByteArray(mscript));
        //    txins[0] = tin;

        //    Script multScript = ScriptTemplate.MultiSig(addresses);

        //    Address address = new Address(multScript.ToBytes(), Address.SCRIPT);

        //    Console.WriteLine(address.ToString());

        //    //basically the redeem script
        //    Script subScript = new Script(tin.scriptSig);

        //    //create the new transaction to spend the coins at the multisig address
        //    Transaction tx = new Transaction(1, txins, txouts, 0);

        //    //clone the transaction
        //    //Transaction txCopy = new Transaction(tx.ToBytes());

        //    SHA256 sha256 = new SHA256Managed();

        //    //hash the transaction with some leading bytes
        //    Byte[] txHash = tx.ToBytes().Concat(new Byte[] { (Byte)hashType, 0x00, 0x00, 0x00 }).ToArray();
        //    txHash = sha256.ComputeHash(sha256.ComputeHash(txHash));

        //    return HexString.FromByteArray(txHash);

        //}
        //public static string MultiSigHashForSigning(string publickey1, string publickey2, string publickey3, string transactionid, uint prevoutIndex, string toAddress, ulong amount)
        //{
        //    TxIn[] txins = new TxIn[1];
        //    TxOut[] txouts = new TxOut[1];

        //    byte version = 0;

        //    //PayToAddress
        //    HashType hashType = HashType.SIGHASH_ALL;

        //    PublicKey pk = new PublicKey(HexString.ToByteArray(toAddress));
        //    //Address add = new Address(pk.);

        //    //address to send coins to
        //    // string dec = HexString.FromByteArray(Base58CheckString.ToByteArray(add.ToString(), out version));


        //    //create address 

        //    //create script to pay to address
        //    Script sc = ScriptTemplate.PayToAddress(pk.address);

        //    //create transaction output
        //    TxOut tout = new TxOut(amount - 5, sc.ToBytes());
        //    txouts[0] = tout;

        //    object[] addresses = new object[3];

        //    addresses[0] = publickey1;
        //    addresses[1] = publickey2;
        //    addresses[2] = publickey3;

        //    string mscript = MultSigScript(addresses);


        //    //create input based on previous output to spend
        //    //and the redeem script for the multi-sig address
        //    TxIn tin = new TxIn(HexString.ToByteArrayReversed(transactionid), prevoutIndex, HexString.ToByteArray(mscript));
        //    txins[0] = tin;

        //    //basically the redeem script
        //    Script subScript = new Script(tin.scriptSig);

        //    //create the new transaction to spend the coins at the multisig address
        //    Transaction tx = new Transaction(1, txins, txouts, 0);

        //    //clone the transaction
        //    Transaction txCopy = new Transaction(tx.ToBytes());

        //    SHA256 sha256 = new SHA256Managed();

        //    //hash the transaction with some leading bytes
        //    Byte[] txHash = txCopy.ToBytes().Concat(new Byte[] { (Byte)hashType, 0x00, 0x00, 0x00 }).ToArray();
        //    txHash = sha256.ComputeHash(sha256.ComputeHash(txHash));

        //    return HexString.FromByteArray(txHash);
        //}
        public static string MultiSig2Of3Transaction(string[] ninkiSigs, string[] userSigs,List<string[]> publicKeys, List<TransactionOutput> outputsToSpend, List<TransactionOutput> outputsToSend)
        {
            TxIn[] txins = new TxIn[outputsToSpend.Count];
            TxOut[] txouts = new TxOut[outputsToSend.Count];
            Transaction tx = new Transaction(1, txins, txouts, 0);

            int i = 0;
            foreach (TransactionOutput outSpend in outputsToSpend)
            {
                string[] pubkeys = publicKeys[i];
                string mscript = MultSigScript(pubkeys);
                //create input based on previous output to spend
                //and the redeem script for the multi-sig address
                TxIn tin = new TxIn(HexString.ToByteArrayReversed(outSpend.TransactionId), (uint)outSpend.OutputIndex, HexString.ToByteArray(mscript));
                txins[i] = tin;

                Script s = new Script(new Byte[] { 0x00 });
                //add the signatures to the script

                //this check is to support returning transactions for testing
                if (ninkiSigs != null)
                {
                    s.elements.Add(new ScriptElement(HexString.ToByteArray(ninkiSigs[i])));
                }
                if (userSigs != null)
                {
                    s.elements.Add(new ScriptElement(HexString.ToByteArray(userSigs[i])));
                }
                

                //txtResult.Text = HexString.FromByteArray(tx.ToBytes());

                //add the original multisig script
                s.elements.Add(new ScriptElement(tin.scriptSig));

                //overwrite the script on the transaction with the new signatures + script
                tin.scriptSig = s.ToBytes();

                i++;
            }

            i = 0;
            foreach (TransactionOutput outSend in outputsToSend)
            {
                Address add = new Address(outSend.Address);
                Script sc = ScriptTemplate.PayToAddress(add);
                //create transaction output
                TxOut tout = new TxOut((ulong)outSend.Amount, sc.ToBytes());
                txouts[i] = tout;
                i++;
            }

            return HexString.FromByteArray(tx.ToBytes());
        }
        public static string MultiSig2Of3TransactionForTesting(string publickey1, string publickey2, string publickey3, string privKey1, string privKey2, string transactionid, uint prevoutIndex, string toAddress, ulong amount)
        {
            TxIn[] txins = new TxIn[1];
            TxOut[] txouts = new TxOut[1];

            byte version = 0;

            //PayToAddress
            HashType hashType = HashType.SIGHASH_ALL;

            PublicKey pk = new PublicKey(HexString.ToByteArray(toAddress));
            //Address add = new Address(pk.);

            //address to send coins to
           // string dec = HexString.FromByteArray(Base58CheckString.ToByteArray(add.ToString(), out version));


            //create address 
            
            //create script to pay to address
            Script sc = ScriptTemplate.PayToAddress(pk.address);

            //create transaction output
            TxOut tout = new TxOut(amount-5, sc.ToBytes());
            txouts[0] = tout;

            object[] addresses = new object[3];

            addresses[0] = publickey1;
            addresses[1] = publickey2;
            addresses[2] = publickey3;

            string mscript = MultSigScript(addresses);


            //create input based on previous output to spend
            //and the redeem script for the multi-sig address
            TxIn tin = new TxIn(HexString.ToByteArrayReversed(transactionid), prevoutIndex, HexString.ToByteArray(mscript));
            txins[0] = tin;

            //basically the redeem script
            Script subScript = new Script(tin.scriptSig);

            //create the new transaction to spend the coins at the multisig address
            Transaction tx = new Transaction(1, txins, txouts, 0);

            //clone the transaction
            Transaction txCopy = new Transaction(tx.ToBytes());

            SHA256 sha256 =  SHA256.Create();

            //hash the transaction with some leading bytes
            Byte[] txHash = txCopy.ToBytes().Concat(new Byte[] { (Byte)hashType, 0x00, 0x00, 0x00 }).ToArray();
            txHash = sha256.ComputeHash(sha256.ComputeHash(txHash));

            //get the private keys bytes 1-33 and base58
            byte[] test58 = Base58String.ToByteArray(privKey1).Skip(1).Take(32).ToArray();
            ECKeyPair key1 = new ECKeyPair(test58, null, false);
            PrivateKey pk1 = new PrivateKey(key1);

            byte[] test582 = Base58String.ToByteArray(privKey2).Skip(1).Take(32).ToArray();
            ECKeyPair key2 = new ECKeyPair(test582, null, false);
            PrivateKey pk2 = new PrivateKey(key2);


            
            //Script scriptSig = new Script(tin.scriptSig);

            //sign the transaction hash
            Byte[] sig = pk1.Sign(txHash).Concat(new Byte[] { (Byte)hashType }).ToArray();
            Byte[] sig2 = pk2.Sign(txHash).Concat(new Byte[] { (Byte)hashType }).ToArray();
            
            //create a new script to sign 
            Script s = new Script(new Byte[] { 0x00 });
            //add the signatures to the script
            s.elements.Add(new ScriptElement(sig));
            s.elements.Add(new ScriptElement(sig2));

            //txtResult.Text = HexString.FromByteArray(tx.ToBytes());

            //add the original multisig script
            s.elements.Add(new ScriptElement(tin.scriptSig));

            //overwrite the script on the transaction with the new signatures + script
            tin.scriptSig = s.ToBytes();
            
            return HexString.FromByteArray(tx.ToBytes());
        }

    }
}
