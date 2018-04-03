using System.Security.Cryptography;
using System.Text;
using System;
using System.Linq;
using System.IO;
using System.Collections.Generic;

namespace ninki_net_core{

    public class BIP32
    {
        public const int BITCOIN_MAINNET_PUBLIC = 0x0488b21e;
        public const int BITCOIN_MAINNET_PRIVATE = 0x0488ade4;
        public const int BITCOIN_TESTNET_PUBLIC = 0x043587cf;
        public const int BITCOIN_TESTNET_PRIVATE = 0x04358394;

        private secp256k1Wrap secp256k1 = null;

        public BIP32()
        {

        }


        public BIP32(secp256k1Wrap psecp256k1)
        {
            secp256k1 = psecp256k1;
        }

        public string GetPassphraseHash(byte[] seedguid, int version)
        {

            //use as seed

            string hex = HexString.FromByteArray(seedguid);
            byte[] il = HexString.ToByteArray(hex.Substring(0, 64));
            byte[] ir = HexString.ToByteArray(hex.Substring(64, 64));

            var bip32 = new BIP32(secp256k1);
            try
            {
                bip32.eckey = new ECKeyPair(il,null,false,false,secp256k1);
                bip32.eckey.compress(true);

                bip32.chain_code = ir;
                bip32.child_index = 0;
                bip32.parent_fingerprint = HexString.ToByteArray("00000000");

                bip32.version = version;

                bip32.depth = 0;

                bip32.BuildExtendedPublicKey();
                bip32.BuildExtendedPrivateKey();
            }
            catch (Exception ex)
            {

            }

            return bip32.ExtendedPrivateKeyString("base58");

        }

        public BIP32(string privKey, string pubKey, secp256k1Wrap psecp256k1)
        {
            secp256k1 = psecp256k1;

            byte[] privKeyRaw = parseKey(privKey);
            byte[] pubKeyRaw = parseKey(pubKey);

            Initialise(privKeyRaw, pubKeyRaw);

            

        }

        private byte[] parseKey(string key)
        {
            SHA256 sha = SHA256.Create();

            byte[] decoded = Base58String.ToByteArray(key);

            if (decoded.Length != 82) throw new Exception("Not enough data");

            byte[] checksum = decoded.Skip(78).Take(4).ToArray();

            byte[] bytes = decoded.Take(78).ToArray();

            byte[] hash = sha.ComputeHash(sha.ComputeHash(bytes));

            if (hash[0] != checksum[0] || hash[1] != checksum[1] || hash[2] != checksum[2] || hash[3] != checksum[3])
            {
                throw new Exception("Invalid checksum");
            }

            return bytes;
        }


        public BIP32(string sKey, secp256k1Wrap psecp256k1 )
        {
            secp256k1 = psecp256k1;

            SHA256 sha = SHA256.Create();

            byte[] decoded = Base58String.ToByteArray(sKey);

            if (decoded.Length != 82) throw new Exception("Not enough data");

            byte[] checksum = decoded.Skip(78).Take(4).ToArray();

            byte[] bytes = decoded.Take(78).ToArray();

            byte[] hash = sha.ComputeHash(sha.ComputeHash(bytes));

            if (hash[0] != checksum[0] || hash[1] != checksum[1] || hash[2] != checksum[2] || hash[3] != checksum[3])
            {
                throw new Exception("Invalid checksum");
            }

            Initialise(bytes);
        }

        public int version;
        public int depth;
        public byte[] parent_fingerprint;
        public uint child_index;
        public byte[] chain_code;
        public ECKeyPair eckey;

        public void Initialise(byte[] bytes, byte[] pubbytes = null)
        {

            if (bytes.Length != 78) throw new Exception("not enough data");

            var n = 0;
            for (var i = 0; i < bytes.Take(4).ToArray().Length; i++)
            {
                n *= 256;
                n += bytes.Take(4).ToArray()[i];
            }
            this.version = n;

            this.depth = BitConverter.ToInt16(bytes.Skip(4).Take(1).Concat(new Byte[] { 0x00, 0x00, 0x00 }).ToArray(), 0);
            this.parent_fingerprint = bytes.Skip(5).Take(4).ToArray();
            this.child_index = BitConverter.ToUInt32(bytes.Skip(9).Take(4).ToArray(), 0);
            this.chain_code = bytes.Skip(13).Take(32).ToArray();

            var key_bytes = bytes.Skip(45).Take(33).ToArray();

            var is_private =
                (this.version == BITCOIN_MAINNET_PRIVATE ||
                 this.version == BITCOIN_TESTNET_PRIVATE);

            var is_public =
                (this.version == BITCOIN_MAINNET_PUBLIC ||
                 this.version == BITCOIN_TESTNET_PUBLIC);


            if (is_private && key_bytes[0] == 0)
            {
                //if the key is a private key
                if (pubbytes == null)
                {
                    this.eckey = new ECKeyPair(key_bytes.Skip(1).Take(32).ToArray(), null, false, false, secp256k1);
                }
                else
                {
                    this.eckey = new ECKeyPair(key_bytes.Skip(1).Take(32).ToArray(), pubbytes.Skip(45).Take(33).ToArray(), false, false, secp256k1);
                }
            }
            else if (is_public && (key_bytes[0] == 0x02 || key_bytes[0] == 0x03))
            {
                //if the key is a public key
                this.eckey = new ECKeyPair(null, key_bytes, false, false, secp256k1);
            }
            else
            {
                throw new Exception("Invalid key");
            }



            this.eckey.compress(true);

            BuildExtendedPrivateKey();
            BuildExtendedPublicKey();
            //this.build_extended_public_key();
            //this.build_extended_private_key();


        }

        public byte[] extended_private_key;

        public void BuildExtendedPrivateKey()
        {

            using (MemoryStream ms = new MemoryStream())
            using (BinaryWriter bw = new BinaryWriter(ms))
            {

                if (eckey.privKey == null) return;
                var v = this.version;

                // Version
                bw.Write((byte)(v >> 24));
                bw.Write((byte)((v >> 16) & 0xff));
                bw.Write((byte)((v >> 8) & 0xff));
                bw.Write((byte)(v & 0xff));

                // Depth
                bw.Write((byte)this.depth);

                // Parent fingerprint
                bw.Write(this.parent_fingerprint);

                // Child index

                uint temp = (uint)this.child_index;
                bw.Write((byte)(temp >> 24));
                bw.Write((byte)((temp >> 16) & 0xff));
                bw.Write((byte)((temp >> 8) & 0xff));

                bw.Write((byte)((this.child_index) & 0xff));

                // Chain code
                bw.Write(this.chain_code);

                // Private key
                bw.Write((byte)0);
                //to byte array unsigned?
                bw.Write(this.eckey.privKey);


                extended_private_key = ms.ToArray();
            }
        }

        public string ExtendedPrivateKeyString(string format)
        {

            SHA256 sha = SHA256.Create();

            if (format == null || format == "base58")
            {
                byte[] hash = sha.ComputeHash(sha.ComputeHash(this.extended_private_key));
                byte[] checksum = hash.Take(4).ToArray();
                byte[] data = this.extended_private_key.Concat(checksum).ToArray();

                return Base58String.FromByteArray(data);

            }
            else if (format == "hex")
            {
                return HexString.FromByteArray(this.extended_private_key);
            }
            else
            {
                throw new Exception("bad format");
            }
        }

        public byte[] extended_public_key;

        public void BuildExtendedPublicKey()
        {
            if (eckey.pubKey != null)
            {

                int v;
                switch (this.version)
                {
                    case BITCOIN_MAINNET_PUBLIC:
                    case BITCOIN_MAINNET_PRIVATE:
                        v = BITCOIN_MAINNET_PUBLIC;
                        break;
                    case BITCOIN_TESTNET_PUBLIC:
                    case BITCOIN_TESTNET_PRIVATE:
                        v = BITCOIN_TESTNET_PUBLIC;
                        break;
                    default:
                        throw new Exception("Unknown version");
                }

                using (MemoryStream ms = new MemoryStream())
                using (BinaryWriter bw = new BinaryWriter(ms))
                {
                    // Version
                    bw.Write((byte)(v >> 24));
                    bw.Write((byte)((v >> 16) & 0xff));
                    bw.Write((byte)((v >> 8) & 0xff));
                    bw.Write((byte)(v & 0xff));



                    // Depth
                    bw.Write((byte)this.depth);
                    bw.Write(parent_fingerprint);
                    // Parent fingerprint

                    uint temp = (uint)this.child_index;
                    bw.Write((byte)(temp >> 24));
                    bw.Write((byte)((temp >> 16) & 0xff));
                    bw.Write((byte)((temp >> 8) & 0xff));
                    bw.Write((byte)((this.child_index) & 0xff));

                    // Chain code
                    bw.Write(this.chain_code);

                    bw.Write(eckey.pubKey);
                    //// Public key
                    this.extended_public_key = ms.ToArray();
                }
            }
        }

        public string ExtendedPublicKeyString(string format)
        {

            SHA256 sha = SHA256.Create();

            if (format == null || format == "base58")
            {
                byte[] hash = sha.ComputeHash(sha.ComputeHash(this.extended_public_key));
                byte[] checksum = hash.Take(4).ToArray();
                byte[] data = this.extended_public_key.Concat(checksum).ToArray();

                return Base58String.FromByteArray(data);

            }
            else if (format == "hex")
            {
                return HexString.FromByteArray(this.extended_public_key);
            }
            else
            {
                throw new Exception("bad format");
            }

        }

        public BIP32 Derive(string path)
        {

            Console.WriteLine("Derive path=" + path);

            string[] e = path.Split('/');

            //// Special cases:
            if (path == "m" || path == "M" || path == "m\'" || path == "M\'") return this;

            var bip32 = this;
            for (int i = 0; i < e.Length; i++)
            {
                string c = e[i];

                if (i == 0)
                {
                    if (c != "m") throw new Exception("invalid path");
                    continue;
                }

                var use_private = (c.Length > 1) && (c[c.Length - 1] == '\'');
                uint child_index;

                if (use_private)
                {
                    child_index = uint.Parse(c.Take(c.Length - 1).ToString()) & 0x7fffffff;
                }
                else
                {
                    child_index = uint.Parse(c) & 0x7fffffff;
                }

                if (use_private)
                    child_index += 0x80000000;

                bip32 = bip32.DeriveChild(child_index);

            }

            return bip32;

        }

        public BIP32 DeriveChild(uint i)
        {
            DateTime start = DateTime.Now;

            BIP32 ret = new BIP32(secp256k1);

            byte[] ib;

            using (MemoryStream ms = new MemoryStream())
            using (BinaryWriter bw = new BinaryWriter(ms))
            {
                bw.Write((byte)((i >> 24) & 0xff));
                bw.Write((byte)((i >> 16) & 0xff));
                bw.Write((byte)((i >> 8) & 0xff));
                bw.Write((byte)(i & 0xff));
                ib = ms.ToArray();
            }


            bool use_private = (i & 0x80000000) != 0;

            bool is_private =
                (this.version == BITCOIN_MAINNET_PRIVATE ||
                 this.version == BITCOIN_TESTNET_PRIVATE);

            if (use_private && (this.eckey.privKey == null || !is_private)) throw new Exception("Cannot do private key derivation without private key");


            if (this.eckey.privKey != null)
            {
                byte[] data = null;
                using (MemoryStream ms = new MemoryStream())
                using (BinaryWriter bw = new BinaryWriter(ms))
                {
                    if (use_private)
                    {
                        bw.Write((byte)0);
                        bw.Write(this.eckey.privKey);
                        bw.Write(ib);
                        data = ms.ToArray();
                    }
                    else
                    {
                        //bw.Write((byte)0);
                        bw.Write(this.eckey.pubKey);
                        bw.Write(ib);
                        data = ms.ToArray();
                    }
                }



                HMACSHA512 hmacsha = new HMACSHA512(this.chain_code);
                byte[] hash = hmacsha.ComputeHash(data);

                string hhash = HexString.FromByteArray(hash);

                byte[] ir = HexString.ToByteArray(hhash.Substring(64, 64));

                string ilb = hhash.Substring(0, 64);
                string pkb = HexString.FromByteArray(this.eckey.privKey);

                string k = secp256k1.AddPrivate(pkb, ilb);

                ret.chain_code = ir;

                byte[] derkey = HexString.ToByteArray(k);

                if (derkey.Length == 31)
                {
                    List<byte> tmp = derkey.ToList();
                    tmp.Insert(0, (byte)0);
                    derkey = tmp.ToArray();
                }

                ret.eckey = new ECKeyPair(derkey, null, false, false, secp256k1);
                ret.eckey.compress(true);
      
            }
            else
            {

                byte[] data = null;
                using (MemoryStream ms = new MemoryStream())
                using (BinaryWriter bw = new BinaryWriter(ms))
                {
                    if (use_private)
                    {
                        bw.Write((byte)0);
                        bw.Write(this.eckey.privKey);
                        bw.Write(ib);
                        data = ms.ToArray();
                    }
                    else
                    {
                        //bw.Write((byte)3);
                        bw.Write(this.eckey.pubKey);
                        bw.Write(ib);
                        data = ms.ToArray();
                    }
                }

                HMACSHA512 hmacsha = new HMACSHA512(this.chain_code);
                byte[] hash = hmacsha.ComputeHash(data);

                string test = HexString.FromByteArray(hash);

                byte[] ir = HexString.ToByteArray(test.Substring(64, 64));

                string bil = test.Substring(0, 64);
                string bpub = HexString.FromByteArray(this.eckey.pubKey);
                string point = secp256k1.AddPublic(bpub, bil);
                
                ret.chain_code = ir;
                ret.eckey = new ECKeyPair(null, HexString.ToByteArray(point));
 
                ret.eckey.compress(true);
            }

            ret.child_index = i;

            //this is why we need the pub key hash
            //for the fingerprint
            start = DateTime.Now;
            Address add = new Address(this.eckey.pubKey);
            Console.WriteLine("New Address:" + DateTime.Now.Subtract(start).TotalMilliseconds);


            ret.parent_fingerprint = add.PubKeyHash.hash.Take(4).ToArray();

            ret.version = this.version;
            ret.depth = this.depth + 1;

            ret.BuildExtendedPublicKey();
            ret.BuildExtendedPrivateKey();

            return ret;

        }


        //test function



        public BIP32 DerivePrivate(string path)
        {

            Console.WriteLine("Derive path=" + path);

            string[] e = path.Split('/');

            //// Special cases:
            if (path == "m" || path == "M" || path == "m\'" || path == "M\'") return this;

            var bip32 = this;
            for (int i = 0; i < e.Length; i++)
            {
                string c = e[i];

                if (i == 0)
                {
                    if (c != "m") throw new Exception("invalid path");
                    continue;
                }

                var use_private = (c.Length > 1) && (c[c.Length - 1] == '\'');
                uint child_index;

                if (use_private)
                {
                    child_index = uint.Parse(c.Take(c.Length - 1).ToString()) & 0x7fffffff;
                }
                else
                {
                    child_index = uint.Parse(c) & 0x7fffffff;
                }

                if (use_private)
                    child_index += 0x80000000;

                Console.WriteLine("Deriving child=" + child_index);
                bip32 = bip32.DeriveChildPrivateOnly(child_index);
            }

            return bip32;

        }


        public BIP32 DeriveChildPrivateOnly(uint i)
        {
            DateTime start = DateTime.Now;

            BIP32 ret = new BIP32(secp256k1);

            byte[] ib;

            using (MemoryStream ms = new MemoryStream())
            using (BinaryWriter bw = new BinaryWriter(ms))
            {
                bw.Write((byte)((i >> 24) & 0xff));
                bw.Write((byte)((i >> 16) & 0xff));
                bw.Write((byte)((i >> 8) & 0xff));
                bw.Write((byte)(i & 0xff));
                ib = ms.ToArray();
            }


            bool use_private = (i & 0x80000000) != 0;

            bool is_private =
                (this.version == BITCOIN_MAINNET_PRIVATE ||
                 this.version == BITCOIN_TESTNET_PRIVATE);

            if (use_private && (this.eckey.privKey == null || !is_private)) throw new Exception("Cannot do private key derivation without private key");


            if (this.eckey.privKey != null)
            {
                byte[] data = null;
                using (MemoryStream ms = new MemoryStream())
                using (BinaryWriter bw = new BinaryWriter(ms))
                {
                    if (use_private)
                    {
                        bw.Write((byte)0);
                        bw.Write(this.eckey.privKey);
                        bw.Write(ib);
                        data = ms.ToArray();
                    }
                    else
                    {
                        //bw.Write((byte)0);
                        bw.Write(this.eckey.pubKey);
                        bw.Write(ib);
                        data = ms.ToArray();
                    }
                }

                HMACSHA512 hmacsha = new HMACSHA512(this.chain_code);
                byte[] hash = hmacsha.ComputeHash(data);

                string hhash = HexString.FromByteArray(hash);

                byte[] ir = HexString.ToByteArray(hhash.Substring(64, 64));

                string ilb = hhash.Substring(0, 64);
                string pkb = HexString.FromByteArray(this.eckey.privKey);
               
                string k = secp256k1.AddPrivate(pkb, ilb);

                ret.chain_code = ir;
                ret.eckey = new ECKeyPair(HexString.ToByteArray(k),null,false,true);

            }
            else
            {

            }

            ret.child_index = i;

            //this is why we need the pub key hash
            //for the fingerprint

            Address add = new Address(this.eckey.pubKey);
            ret.parent_fingerprint = add.PubKeyHash.hash.Take(4).ToArray();

            ret.version = this.version;
            ret.depth = this.depth + 1;

            ret.BuildExtendedPublicKey();
            return ret;

        }


    }
}