using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace ninki_net_core{
	public interface ISerialize
	{
		void Read(Stream s);
		void Write(Stream s);
		Byte[] ToBytes();
	}
}
