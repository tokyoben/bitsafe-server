using System;
using System.Linq;

using Org.BouncyCastle.Asn1;
using Org.BouncyCastle.Asn1.Sec;
using Org.BouncyCastle.Math;
using Org.BouncyCastle.Math.EC;
using Org.BouncyCastle.Crypto.Signers;

using Org.BouncyCastle.Crypto.Parameters;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace ninki_net_core
{
	public class ECKeyPair
	{
		ECDomainParameters ecParams = new ECDomainParameters(
			SecNamedCurves.GetByName("secp256k1").Curve, SecNamedCurves.GetByName("secp256k1").G, SecNamedCurves.GetByName("secp256k1").N);
		public Byte[] privKey { get; private set; }
		public Byte[] pubKey { get; private set; }
		public Boolean isCompressed { get; private set; }

        public ECKeyPair(Byte[] privKey, Byte[] pubKey = null, Boolean compressed = false, bool nopublickey = false, secp256k1Wrap secp256k1 = null)
		{
			this.privKey = privKey;
			if (pubKey != null)
			{
				this.pubKey = pubKey;
				this.isCompressed = pubKey.Length <= 33;
			}
			else
			{
                if (!nopublickey)
                {
                    calcPubKey(compressed, secp256k1);
                }
			}
		}

		public void compress(bool comp)
		{
			if (isCompressed == comp) return;
			ECPoint point = ecParams.Curve.DecodePoint(pubKey);
			if (comp)
				pubKey = compressPoint(point).GetEncoded();
			else
				pubKey = decompressPoint(point).GetEncoded();
			isCompressed = comp;
		}

		public Boolean verifySignature(Byte[] data, Byte[] sig)
		{
			ECDsaSigner signer = new ECDsaSigner();
			signer.Init(false, new ECPublicKeyParameters(ecParams.Curve.DecodePoint(pubKey), ecParams));
			using (Asn1InputStream asn1stream = new Asn1InputStream(sig))
			{
				Asn1Sequence seq = (Asn1Sequence)asn1stream.ReadObject();
				return signer.VerifySignature(data, ((DerInteger)seq[0]).PositiveValue, ((DerInteger)seq[1]).PositiveValue);
			}
		}



		public Byte[] signData(Byte[] data)
		{
			if (privKey == null)
				throw new InvalidOperationException();
			ECDsaSigner signer = new ECDsaSigner();
            
			signer.Init(true, new ECPrivateKeyParameters(new BigInteger(1, privKey), ecParams));
			BigInteger[] sig = signer.GenerateSignature(data);
			using (MemoryStream ms = new MemoryStream())
			using (Asn1OutputStream asn1stream = new Asn1OutputStream(ms))
			{
				DerSequenceGenerator seq = new DerSequenceGenerator(asn1stream);
				seq.AddObject(new DerInteger(sig[0]));

                BigInteger s = sig[1];

                string hexUpper = "7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0";

                BigInteger upper = new BigInteger(hexUpper, 16);

                if (s.CompareTo(upper) > 0)
                {
                    string hexOrder = "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141";
                    BigInteger order = new BigInteger(hexOrder, 16);
                    s = order.Subtract(sig[1]);

                    Console.WriteLine("Converted to low-s");
                    Console.WriteLine(sig[1].ToString(16));
                    Console.WriteLine(s.ToString(16));
                }

                seq.AddObject(new DerInteger(s));

                
				seq.Close();
				return ms.ToArray();
			}
		}
        private void calcPubKey(bool comp, secp256k1Wrap secp256k1)
        {
            
            //ECPoint point = ecParams.G.Multiply(new BigInteger(1, privKey));
            this.pubKey = HexString.ToByteArray(secp256k1.CreatePubKey(HexString.FromByteArray(privKey)));

			compress(comp);
		}

		private ECPoint compressPoint(ECPoint point)
		{
			return new FpPoint(ecParams.Curve, point.X, point.Y, true);
		}

		private ECPoint decompressPoint(ECPoint point)
		{
			return new FpPoint(ecParams.Curve, point.X, point.Y, false);
		}

        public static class HexString
        {
            public static Byte[] ToByteArray(String s)
            {
                if (s.Length % 2 != 0)
                    throw new ArgumentException();
                return Enumerable.Range(0, s.Length / 2)
                                 .Select(x => Byte.Parse(s.Substring(2 * x, 2), System.Globalization.NumberStyles.HexNumber))
                                 .ToArray();
            }

            public static Byte[] ToByteArrayReversed(String s)
            {
                if (s.Length % 2 != 0)
                    throw new ArgumentException();
                return Enumerable.Range(0, s.Length / 2)
                                 .Select(x => Byte.Parse(s.Substring(2 * x, 2), System.Globalization.NumberStyles.HexNumber))
                                 .Reverse()
                                 .ToArray();
            }

            public static String FromByteArray(Byte[] b)
            {
                StringBuilder sb = new StringBuilder(b.Length * 2);
                foreach (Byte _b in b)
                {
                    sb.Append(_b.ToString("x2"));
                }
                return sb.ToString();
            }

            public static String FromByteArrayReversed(Byte[] b)
            {
                StringBuilder sb = new StringBuilder(b.Length * 2);
                foreach (Byte _b in b.Reverse())
                {
                    sb.Append(_b.ToString("x2"));
                }
                return sb.ToString();
            }

        }
	}
}
