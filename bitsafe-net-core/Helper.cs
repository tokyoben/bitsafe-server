using System.Security.Cryptography;
using System.Text;
using System;
using System.Linq;
using System.IO;
using System.Numerics;
using System.Data.SqlClient;
using System.Data;
using Npgsql;
using NpgsqlTypes;

namespace ninki_net_core{

    public class Helper{
        public static string hashGuid(string guid)
        {
            SHA256 sha256 = SHA256.Create();
            byte[] unc = Encoding.ASCII.GetBytes(guid);
            return HexString.FromByteArray(sha256.ComputeHash(unc));
        }

        public static string hash512(string guid)
        {
            SHA512 sha512 = SHA512.Create();
            byte[] unc = Encoding.ASCII.GetBytes(guid);
            return HexString.FromByteArray(sha512.ComputeHash(unc));
        }

        public static string Encrypt(string clearText, ICSPRNGServer csprng)
        {

            byte[] salt = new byte[16];
            csprng.getRandomValues(salt);

            byte[] encBytes = null;

            byte[] clearBytes = Encoding.Unicode.GetBytes(clearText);
            using (Aes encryptor = Aes.Create())
            {
                encryptor.KeySize = 256;
                encryptor.BlockSize = 128;
                encryptor.Mode = CipherMode.CBC;
				encryptor.Padding = PaddingMode.PKCS7;
                Rfc2898DeriveBytes pdb = new Rfc2898DeriveBytes(csprng.Key(), salt, 1);
                encryptor.Key = pdb.GetBytes(32);
                encryptor.IV = pdb.GetBytes(16);

                using (MemoryStream ms = new MemoryStream())
                {
                    using (CryptoStream cs = new CryptoStream(ms, encryptor.CreateEncryptor(), CryptoStreamMode.Write))
                    {
                        cs.Write(clearBytes, 0, clearBytes.Length);
                    }
                    encBytes = ms.ToArray();
                }
            }

            byte[] saltAndCipher = salt.Concat(encBytes).ToArray();

            string saltAndCipherText = Convert.ToBase64String(saltAndCipher);

            return saltAndCipherText;
        }

        public static string Decrypt(string clearText, ICSPRNGServer csprng)
        {

            byte[] baseclear = Convert.FromBase64String(clearText);

            byte[] clearBytes = new byte[baseclear.Length - 16];

            for (int i = 0; i < clearBytes.Length; i++)
            {
                clearBytes[i] = baseclear[i + 16];
            }

            byte[] salt = baseclear.Take(16).ToArray();

            using (Aes encryptor = Aes.Create())
            {
                encryptor.KeySize = 256;
                encryptor.BlockSize = 128;
                encryptor.Mode = CipherMode.CBC;
				encryptor.Padding = PaddingMode.PKCS7;
                Rfc2898DeriveBytes pdb = new Rfc2898DeriveBytes(csprng.Key(), salt, 1);
                encryptor.Key = pdb.GetBytes(32);
                encryptor.IV = pdb.GetBytes(16);
                using (MemoryStream ms = new MemoryStream(clearBytes))
                {
                    using (CryptoStream cs = new CryptoStream(ms, encryptor.CreateDecryptor(), CryptoStreamMode.Read))
                    {

                        using (StreamReader srDecrypt = new StreamReader(cs))
                        {
                            clearText = srDecrypt.ReadToEnd();
                        }
                    }
                }
            }
            clearText = clearText.Replace("\0", "");
            return clearText;
        }

		public static bool IsCallerValid(string guid, string sharedid,string strWallet)
        {


            string encusertoken = hashGuid(sharedid);

            bool ret = false;
            NpgsqlConnection conn = new NpgsqlConnection(strWallet);
            conn.Open();
            try
            {
                NpgsqlCommand cmd = new NpgsqlCommand("sp_isCallerValid", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                cmd.Parameters.Add(new NpgsqlParameter("p_sharedid", encusertoken));
                NpgsqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SingleRow);
                if (reader.HasRows)
                {
                    ret = true;
                }
                reader.Dispose();
                cmd.Dispose();
 

            }
            catch (Exception ex)
            {
                ret = false;
            }
            finally
            {
                conn.Close();
            }

            return ret;

        }

        public static  bool IsSecretValid(string guid, string secret,string connstrWallet, ICSPRNGServer csprng)
        {

            string errorMessage = "";
            bool isError = false;
            bool loginSuccess = false;

            NpgsqlConnection conn = new NpgsqlConnection(connstrWallet);
            conn.Open();
            try
            {
                NpgsqlCommand cmd = new NpgsqlCommand("sp_payloadByAccount", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new NpgsqlParameter("p_guid", guid));
                NpgsqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SingleRow);
                if (reader.HasRows)
                {
                    reader.Read();

                    if (reader.IsDBNull(0))
                    {
                        isError = true;
                        errorMessage = "No payload has been saved";
                    }
                    else
                    {
                        string esecret = reader.GetString(3);
                        string dsecret = Decrypt(esecret,csprng);

                        if (dsecret == secret)
                        {
                            loginSuccess = true;

                        }
                    }

                }
                else
                {
                    isError = true;
                    errorMessage = "ErrAccount";
                }
                reader.Dispose();

            }
            catch (Exception ex)
            {
                isError = true;
                errorMessage = "ErrAccount";
            }
            finally
            {
                conn.Close();
            }

            return loginSuccess;

        }

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

		public static string FromByteArrayReversed(Byte[] b) {
			StringBuilder sb = new StringBuilder(b.Length * 2);
			foreach (Byte _b in b.Reverse())
			{
				sb.Append(_b.ToString("x2"));
			}
			return sb.ToString();
		}

	}

    public static class Base58CheckString
	{
		public static String FromByteArray(Byte[] b, Byte version) {
			SHA256 sha256 = SHA256.Create();
			b = (new Byte[] { version }).Concat(b).ToArray();
			Byte[] hash = sha256.ComputeHash(sha256.ComputeHash(b)).Take(4).ToArray();
			return Base58String.FromByteArray(b.Concat(hash).ToArray());
		}

		public static Byte[] ToByteArray(String s, out Byte version) {
			SHA256 sha256 = SHA256.Create();
			Byte[] b = Base58String.ToByteArray(s);
			Byte[] hash = sha256.ComputeHash(sha256.ComputeHash(b.Take(b.Length - 4).ToArray()));
			if (!hash.Take(4).SequenceEqual(b.Skip(b.Length - 4).Take(4)))
				throw new ArgumentException("Invalid Base58Check String");
			version = b.First();
			return b.Skip(1).Take(b.Length - 5).ToArray();
		}

		public static Byte[] ToByteArray(String s)
		{
			Byte b;
			return ToByteArray(s, out b);
		}
	}

    public static class Base58String
	{
		private const string base58chars = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";

		public static Byte[] ToByteArray(String s)
		{
			BigInteger bi = 0;
			// Decode base58
			foreach (Char c in s)
			{
				int charVal = base58chars.IndexOf(c);
				if (charVal >= 0)
				{
					bi *= 58;
					bi += charVal;
				}
			}
			Byte[] b = bi.ToByteArray();
			// Remove 0x00 sign byte if present.
			if (b[b.Length - 1] == 0x00)
				b = b.Take(b.Length - 1).ToArray();
			// Add leading 0x00 bytes
			int num0s = s.IndexOf(s.First(c => c != '1'));
			return b.Concat(new Byte[num0s]).Reverse().ToArray();
		}

		public static String FromByteArray(Byte[] b)
		{
			StringBuilder sb = new StringBuilder();
			BigInteger bi = new BigInteger(b.Reverse().Concat(new Byte[] {0x00}).ToArray()); // concat adds sign byte
			// Calc base58 representation
			while (bi > 0)
			{
				int mod = (int)(bi % 58);
				bi /= 58;
				sb.Insert(0, base58chars[mod]);
			}
			// Add 1s for leading 0x00 bytes
			for (int i = 0; i < b.Length && b[i] == 0x00; i++)
				sb.Insert(0, '1');
			return sb.ToString();
		}
	}

}