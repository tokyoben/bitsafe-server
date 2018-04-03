﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.IO;

namespace ninki_net_core
{
	public class TxOut : ISerialize
	{
		public UInt64 value;
		public VarInt scriptPubKeyLen { get { return new VarInt(scriptPubKey.Length); } }
		public Byte[] scriptPubKey;

		protected TxOut()
		{
		}

        public string GetAddress()
        {

            Address btcadd = Address.FromScript(scriptPubKey);
            return btcadd.ToString();

        }

		public TxOut(UInt64 value, Byte[] scriptPubKey)
		{
			this.value = value;
			this.scriptPubKey = scriptPubKey;
		}

		public TxOut(Byte[] b)
		{
			using (MemoryStream ms = new MemoryStream(b))
				Read(ms);
		}

		public void Read(Stream s)
		{
			BinaryReader br = new BinaryReader(s);
			value = br.ReadUInt64();
			scriptPubKey = br.ReadBytes(VarInt.FromStream(s).intValue);
		}

		public void Write(Stream s)
		{
			BinaryWriter bw = new BinaryWriter(s);
			bw.Write((UInt64)value);
			scriptPubKeyLen.Write(s);
			bw.Write(scriptPubKey, 0, scriptPubKey.Length);
		}

		public Byte[] ToBytes()
		{
			using (MemoryStream ms = new MemoryStream())
			{
				Write(ms);
				return ms.ToArray();
			}
		}

		public static TxOut FromStream(Stream s)
		{
			TxOut x = new TxOut();
			x.Read(s);
			return x;
		}
	}
}
