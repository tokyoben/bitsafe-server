using System;

namespace ninki_net_core
{
    public class ReturnObject
    {
        public string message { get; set; }
        public bool error { get; set; }
        public ReturnObject(){

        }
        public ReturnObject(string mess){
            message = mess;
        }
    }

    public class ErrorObject
    {
        public ErrorObject(){

        }
        public ErrorObject(string err){
            message = err;
        }
        public string message ;
        public bool error  = true;
    }

    public class CreateAccountReturnObject
    {
        public string UserToken = "";
        public string NinkiMasterPublicKey = "";
        public string Secret = "";
    }

    public class DoesAccountExistReturnObject
    {
        public bool EmailExists = false;
        public bool UserExists = false;
    }

    public class GetTwoFactorSecretReturnObject
    {

        public string guid = "";
        public string GoogleAuthSecret = "";
        public bool TwoFactorOnLogin = false;


    }

    public class GetUserDataReturnObject
    {


        public string Nickname = "";
        public string ProfileImage = "";
        public string Status = "";
        public decimal Tax = 0.10M;
        public string Payload = "";
        public string IV = "";

        public SettingsReturnObject Settings = new SettingsReturnObject();


    }

    public class SettingsReturnObject
    {

        public string guid = "";
        public int Inactivity = 20;

        public int MinersFee = 10000;

        public bool AutoEmailBackup = false;
        public string Email = "";
        public bool EmailVerified = false;
        public string Phone = "";
        public bool PhoneVerified = false;
        public string Language = "EN";
        public string LocalCurrency = "USD";
        public string CoinUnit = "";
        public bool EmailNotification = false;
        public bool PhoneNotification = false;
        public string PasswordHint = "";
        public bool TwoFactor = false;
        public string TwoFactorType = "";
        public long DailyTransactionLimit = 100000000;
        public long SingleTransactionLimit = 50000000;
        public int NoOfTransactionsPerDay = 10;
        public int NoOfTransactionsPerHour = 4;
        public bool HasBackupCodes = false;
        public int BackupIndex = 0;


    }


    public class GetWelcomeDetailsReturnObject
    {

        public string Email = "";
        public string Nickname = "";
        public string NinkiPubKey = "";
        public string Token = "";


    }

    public class BalanceReturnObject
    {

        public bool error = false;
        public double ConfirmedBalance = 0;
        public double UnconfirmedBalance = 0;
        public double TotalBalance = 0;

    }

    public class GetRecoveryPacketReturnObject
    {

        public string packet = "";
        public string IV = "";
        public bool Beta1 = false;


    }

    public class ValidateSecretReturnObject
    {

        public string guid = "";
        public bool TwoFactorOnLogin = true;
        public int Locked = 0;
        public bool HasBackupCodes = false;
        public int BackupIndex = 0;

    }

    public class GetAccountDetailsReturnObject
    {


        public string guid = "";
        public string Payload = "";
        public string IV = "";
        public bool TwoFactorOnLogin = false;


    }

    public class GetTwoFactorTokenReturnObject
    {
        public string Token = "";
    }

    public class TimelineRecord
    {

        public string TimelineType = "";
        public string TransactionId = "";
        public string UserName = "";
        public int InvoiceId = 0;
        public DateTime TimelineDate = DateTime.MinValue;
        public long Amount = 0;
        public int BlockNumber = 0;
        public string UserNameImage = "";
        public int InvoiceStatus = 0;
        public int InvoiceStatusR = 0;

        public int Confirmations = 0;
    }

    public class TransactionRecord
    {
        public string TransactionId;
        public int OutputIndex;
        public DateTime TransDateTime;
        public long Amount;
        public string Address;
        public string UserName;
        public string TransType;
        public int Status;
        public int BlockNumber;
        public int Confirmations;
        public int InvoiceId = 0;
        public string UserNameImage = "";
        public long MinersFee = 0;
    }

    public class DeviceReturnObject
    {

        public string DeviceName = "";
        public string DeviceModel = "";

        public string DeviceId = "";

        public bool IsPaired = false;


    }

    public class Friend
    {
        public string userName = "";
        public string userId = "";
        public bool ICanSend = false;
        public bool ICanRecieve = false;
        public string packet = "";
        public string category = "";
        public string profileImage = "";
        public string status = "";
        public bool validated = false;
    }

    public class Invoice
    {
        public string InvoiceFrom = "";
        public int InvoiceId = 0;
        public DateTime InvoiceDate = DateTime.MinValue;
        public int InvoiceStatus = 0;
        public DateTime InvoicePaidDate = DateTime.MinValue;
        public string TransactionId = "";
        public string Packet = "";
    }

    public class AccountSetting
    {
        public int Inactivity = 20;
        public int MinersFee = 10000;
        public bool AutoEmailBackup = false;
        public string Email = "";
        public bool EmailVerified = false;
        public string Phone = "";
        public bool PhoneVerified = false;
        public string Language = "EN";
        public string LocalCurrency = "USD";
        public string CoinUnit = "";
        public bool EmailNotification = false;
        public bool PhoneNotification = false;
        public string PasswordHint = "";
        public bool TwoFactor = false;
        public string TwoFactorType = "";
        public long DailyTransactionLimit = 100000000;
        public long SingleTransactionLimit = 50000000;
        public int NoOfTransactionsPerDay = 10;
        public int NoOfTransactionsPerHour = 4;
        public bool hasBackupCodes = false;
        public int backupIndex = 0;
    }

    public class NetworkCategory
    {
        public int CategoryId = 0;
        public string Category = "";
    }

    public class VersionInfo{


        public string Version = "";
        public DateTime StartTime;

        public bool WalletConnect;

        public string WalletConnectError;

        public bool BlockchainConnect;

        public string BlockchainConnectError;

        public int BlockNumber;

        public DateTime LastUpd;

        public bool ListenerError;

        public string ListenerErrorMessage;
        public DateTime ListenerStartTime;

        public DateTime ListenerLastUpd;

        public bool NotifierError;

        public string NotifierErrorMessage;

        public DateTime NotifierLastUpd;


    }

    public class TransactionPrep
    {

            public long DailyTransactionLimit = 0;
            public long SingleTransactionLimit = 0;
            public long NoOfTransactionsPerDay = 0;
            public long NoOfTransactionsPerHour = 0;
            public long TotalAmount24hr = 0;
            public long No24hr = 0;
            public long No1hr = 0;
            public long FeeLow = 0;
            public long FeeMed = 0;
            public long FeeHigh = 0;

            public long NoOfOuts = 0;
            public long Slack =  0;

            public bool DailyTransactionLimitBreach;
            public bool NoOfTransactionsPerDayBreach;
            public bool NoOfTransactionsPerHourBreach;


    }

    public class NetworkExists{
        public bool message = false;
        public bool error = false;
    }

    public class CreateFriendReturnObject{
        public string CacheKey = "";
        public bool error = false;
    }

    public class RecoveryInfo
    {
        public string guid = "";
        public string email = "";

    }


    public class SendTransactionReturnObject
    {
        public string TransactionId;
        public string CacheKey;
        public string NetCacheKey;
    }

    public class CreateInvoiceReturnObject
    {
        public string CacheKey = "";
        public string CacheKeyNet = "";

    }

    public class CreateMessageReturnObject
    {
        public string MessageCacheKey = "";
        public string TimelineCacheKey = "";

    }

    public class Message{

        public int MessageId = 0;
        public string UserName = "";

        public string PacketForMe = "";

        public string PacketForThem = "";

        public DateTime CreateDate;

        public string TransactionId = "";

    }

}