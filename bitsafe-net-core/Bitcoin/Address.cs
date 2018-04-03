#define Test

using System;
using System.Security.Cryptography;
using System.Linq;

using Org.BouncyCastle.Crypto;
using Org.BouncyCastle.Crypto.Digests;

namespace ninki_net_core
{

  
	public class Address
	{


//0	1	Bitcoin pubkey hash	17VZNX1SN5NtKa8UQFxwQbFeFc3iqRYhem
//5	3	Bitcoin script hash	3EktnHQD7RiAE6uzMj2ZifT9YgRrkSgzQX
//48	L	Litecoin pubkey hash	LhK2kQwiaAvhjWY799cZvMyYwnQAcxkarr
//52	M or N	Namecoin pubkey hash	NATX6zEUNfxfvgVwz8qVnnw3hLhhYXhgQn
//111	m or n	Bitcoin testnet pubkey hash	mipcBbFg9gMiCh81Kj8tqqdgoZub1ZJRfn
//128	5	Bitcoin Private key	5Hwgr3u458GLafKBgxtssHSPqJnYoGrSzgQsPwLFhLNYskDPyyA
//196	2	Testnet script hash	
//239	9	Testnet Private key	92Pg46rUhgTT7romnV7iGW6W1gbGdeezqdbJCzShkCsYNzyyNcc



#if Test
		public const Byte PUBKEYHASH = 111;
        public const Byte SCRIPTHASH = 0xC4;
        public const Byte PRIVKEYHASH = 239;
#else
        public const Byte PUBKEYHASH = 0;
        public const Byte SCRIPTHASH = 5;
        public const Byte PRIVKEYHASH = 128;
#endif
        public const Byte PUBKEY = 0xFE;
        public const Byte SCRIPT = 0xFF;

		private String address = null;
		private Hash pubKeyHash = null;
		private Hash scriptHash = null;
		private Byte? type = null;

		public Hash PubKeyHash
		{
			get
			{
				if (pubKeyHash == null && calcHash() != PUBKEYHASH)
					throw new InvalidOperationException("Address is not a public key hash.");
				return pubKeyHash;
			}
		}

		public Hash ScriptHash
		{
			get
			{
				if (pubKeyHash == null && calcHash() != SCRIPTHASH)
					throw new InvalidOperationException("Address is not a script hash.");
				return scriptHash;
			}
		}

		public Hash EitherHash
		{
			get
			{
				if (pubKeyHash == null && scriptHash == null)
					calcHash();
				if (pubKeyHash != null)
					return pubKeyHash;
				if (scriptHash != null)
					return scriptHash;
				return null;
			}
		}

		public Byte Type
		{
			get
			{
				if (type == null)
					calcHash();
				return type.Value;
			}
		}

		public Address(Byte[] data, Byte version = PUBKEY)
		{
			SHA256 sha256 =  SHA256.Create();
			IDigest ripemd160 = new RipeMD160Digest();

			switch (version)
			{
				case PUBKEY:
					byte[] pubKeySHA256Res = sha256.ComputeHash(data);
					ripemd160.BlockUpdate(pubKeySHA256Res, 0, pubKeySHA256Res.Length);
					byte[] pubKeyResult = new byte[ripemd160.GetDigestSize()];
					ripemd160.DoFinal(pubKeyResult, 0);
					pubKeyHash = pubKeyResult;
					version = PUBKEYHASH;
					break;
				case SCRIPT:
					byte[] scriptSHA256Res = sha256.ComputeHash(data);
					ripemd160.BlockUpdate(scriptSHA256Res, 0, scriptSHA256Res.Length);
					byte[] scriptResult = new byte[ripemd160.GetDigestSize()];
					ripemd160.DoFinal(scriptResult, 0);
					scriptHash = scriptResult;
					version = SCRIPTHASH;
					break;
				case PUBKEYHASH:
					pubKeyHash = data;
					break;
				case SCRIPTHASH:
					scriptHash = data;
					break;
			}
			this.type = version;
		}

		public Address(String address)
		{
			this.address = address;
		}

		private Byte calcHash()
		{
			Byte version;
			Byte[] hash = Base58CheckString.ToByteArray(this.ToString(), out version);
			switch (version)
			{
				case PUBKEYHASH:
					pubKeyHash = hash;
					break;
				case SCRIPTHASH:
					scriptHash = hash;
					break;
			}
			type = version;
			return version;
		}

		private void calcBase58()
		{
			if (pubKeyHash != null)
				this.address = Base58CheckString.FromByteArray(pubKeyHash, PUBKEYHASH);
			else if (scriptHash != null)
				this.address = Base58CheckString.FromByteArray(scriptHash, SCRIPTHASH);
			else
				throw new InvalidOperationException("Address is not a public key or script hash!");
		}

		public static Address FromScript(Byte[] b)
		{
			Script s = new Script(b);
			if (s.IsPayToPubKeyHash())
				return new Address(s.elements[s.elements.Count - 3].data, PUBKEYHASH);
			if (s.IsPayToScriptHash())
				return new Address(s.elements[s.elements.Count - 2].data, SCRIPTHASH);
			if (s.IsPayToPublicKey())
				return new Address(s.elements[s.elements.Count - 2].data, PUBKEY);
			return null;
		}

		public override bool Equals(object obj)
		{
			if (obj == null || !(obj is Address))
				return false;
			if (this.EitherHash == null || ((Address)obj).EitherHash == null)
				return false;
			return this.EitherHash.hash.SequenceEqual(((Address)obj).EitherHash.hash);
		}

		public override int GetHashCode()
		{
			return this.EitherHash.GetHashCode();
		}

		public override String ToString()
		{
			if (address == null)
				calcBase58();
			return address;
		}
	}
}
