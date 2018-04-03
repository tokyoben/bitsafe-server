using System;
using Org.BouncyCastle.Crypto;
using Org.BouncyCastle.Crypto.Prng;
using Org.BouncyCastle.Crypto.Digests;
using Org.BouncyCastle.Crypto.Engines;
using System.Collections.Generic;
using System.IO;

namespace ninki_net_core
{
    public interface ICSPRNGServer
    {
        void getRandomValues(byte[] seedarray);
        int getInstanceCheck();

        secp256k1Wrap Getsecp256k1();

        byte[] Key();

    }
    public class CSPRNGServer : ICSPRNGServer
    {
        private static CSPRNGServer instance = null;
        private Sha512Digest digest = null;
        private DigestRandomGenerator gen = null;
        private byte[] dkey = null;
        private string dbkey = null;
        private int instcheck = 0;
        private secp256k1Wrap secp256k1 = null;

        private Dictionary<string,string> databaseCommands = new Dictionary<string,string>();

        public CSPRNGServer()
        {


            Console.WriteLine(Directory.GetCurrentDirectory());

            //the CSPRNG is seeded using a thread based seed generator in BC
            byte[] seedarray = new byte[512];
            digest = new Sha512Digest();
            gen = new DigestRandomGenerator(digest);

            
            //add some additional entropy to the seed
            for (int i = 0; i < 48; i++)
            {
                gen.AddSeedMaterial(DateTime.Now.Ticks);
            }

            int threadId = System.Threading.Thread.CurrentThread.ManagedThreadId;
            gen.AddSeedMaterial(threadId);

            instcheck++;

            secp256k1 = new secp256k1Wrap();


            //load database commands from files

            

        }

        public Dictionary<string,string> DatabaseCommands(){

            return databaseCommands;
        }

        public secp256k1Wrap Getsecp256k1()
        {
            return secp256k1;
        }

        public int getInstanceCheck()
        {
            return instcheck;
        }

        public void getRandomValues(byte[] seedarray)
        {
            gen.NextBytes(seedarray);
        }

        public byte[] Key()
        {
            //WARNING: temporary for migration purposes
            //Key management system needs to be migrated to net core
            byte[] key = new byte[64];
            return key;
        }


    }

}