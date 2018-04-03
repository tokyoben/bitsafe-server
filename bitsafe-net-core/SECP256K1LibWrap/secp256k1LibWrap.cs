using System;
using System.Runtime.InteropServices;
using System.IO;

namespace ninki_net_core
{
    public class secp256k1Wrap
    {
        public secp256k1Wrap()
        {
            
            pTestClass = CreateTestClass();
        }

        [DllImport("/app/secp256k1Lib.o", CallingConvention = CallingConvention.Cdecl)]
        static private extern void DisposeTestClass(IntPtr pTestClassObject);

        [DllImport("/app/secp256k1Lib.o", CallingConvention = CallingConvention.Cdecl)]
        static private extern IntPtr CreateTestClass();

        [DllImport("/app/secp256k1Lib.o", EntryPoint = "_ZN12secp256k1Lib4SignEPcS0_",
            CallingConvention = CallingConvention.ThisCall, CharSet = CharSet.Ansi)]
        static private extern string Sign(IntPtr pClassObject, string key, string message);
        private IntPtr pTestClass = IntPtr.Zero;


        [DllImport("/app/secp256k1Lib.o",
            EntryPoint = "_ZN12secp256k1Lib12CreatePubKeyEPc",
            CallingConvention = CallingConvention.ThisCall, CharSet = CharSet.Ansi)]
        static private extern string CreatePubKey(IntPtr pClassObject, string key);

        [DllImport("/app/secp256k1Lib.o",
            EntryPoint = "_ZN12secp256k1Lib10AddPrivateEPcS0_",
            CallingConvention = CallingConvention.ThisCall, CharSet = CharSet.Ansi)]
        static private extern string AddPrivate(IntPtr pClassObject, string a, string b);


        [DllImport("/app/secp256k1Lib.o",
            EntryPoint = "_ZN12secp256k1Lib9AddPublicEPcS0_",
            CallingConvention = CallingConvention.ThisCall, CharSet = CharSet.Ansi)]
        static private extern string AddPublic(IntPtr pClassObject, string a, string b);


        [DllImport("/app/secp256k1Lib.o",
            EntryPoint = "_ZN12secp256k1Lib4MultEPcS0_",
            CallingConvention = CallingConvention.ThisCall, CharSet = CharSet.Ansi)]
        static private extern string Mult(IntPtr pClassObject, string a, string b);

        [DllImport("/app/secp256k1Lib.o",
            EntryPoint = "_ZN12secp256k1Lib6NegateEPc",
            CallingConvention = CallingConvention.ThisCall, CharSet = CharSet.Ansi)]
        static private extern string Negate(IntPtr pClassObject, string a);

        public string Sign(string key, string message)
        {
            return Sign(pTestClass, key, message);
        }

        public string CreatePubKey(string key)
        {
            return CreatePubKey(pTestClass, key);
        }

        public string AddPublic(string a, string b)
        {
            return AddPublic(pTestClass, a, b);
        }

        public string AddPrivate(string a, string b)
        {
            return AddPrivate(pTestClass, a, b);
        }

        public string Mult(string a, string b)
        {
            return Mult(pTestClass, a, b);
        }

        public string Negate(string a)
        {
            return Negate(pTestClass, a);
        }

        public void dispose()
        {
            DisposeTestClass(pTestClass);
        }


    }
}