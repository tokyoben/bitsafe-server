
--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 9.6.3

-- Started on 2017-06-14 13:50:05 JST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 1 (class 3079 OID 12655)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2708 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 221 (class 1255 OID 16522)
-- Name: sp_accountbyaddress(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_accountbyaddress(p_address character varying) RETURNS TABLE(walletid character varying, nodebranch character varying)
    LANGUAGE plpgsql
    AS $$


BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
    RETURN QUERY 
	select AccountAddress.WalletId, AccountAddress.NodeBranch from AccountAddress where RefAddress = p_address;

END;

$$;


ALTER FUNCTION public.sp_accountbyaddress(p_address character varying) OWNER TO postgres;

--
-- TOC entry 298 (class 1255 OID 16847)
-- Name: sp_accountlimitsbyaccount(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_accountlimitsbyaccount(p_guid character varying) RETURNS TABLE(dailytransactionlimit bigint, singletransactionlimit bigint, nooftransactionsperday integer, nooftransactionsperhour integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	
    RETURN QUERY
	select 
    accountsettings.DailyTransactionLimit,
    accountsettings.SingleTransactionLimit,
    accountsettings.NoOfTransactionsPerDay,
    accountsettings.NoOfTransactionsPerHour 
    from accountsettings 
    where accountsettings.WalletId = p_guid;
END;
$$;


ALTER FUNCTION public.sp_accountlimitsbyaccount(p_guid character varying) OWNER TO postgres;

--
-- TOC entry 247 (class 1255 OID 16619)
-- Name: sp_accountsettings(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_accountsettings(p_guid character varying) RETURNS TABLE(walletid character varying, inactivity integer, minersfee integer, autoemailbackup integer, email character varying, emailverified integer, phone character varying, phoneverified integer, language character varying, localcurrency character varying, coinunit character varying, emailnotification integer, phonenotification integer, passwordhint character varying, twofactor integer, twofactortype character varying, dailytransactionlimit bigint, singletransactionlimit bigint, nooftransactionsperday integer, nooftransactionsperhour integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
select accountsettings.WalletId,
accountsettings.Inactivity,
accountsettings.MinersFee,
accountsettings.AutoEmailBackup,
accountsettings.Email,
accountsettings.EmailVerified,
accountsettings.Phone,
accountsettings.PhoneVerified,
accountsettings.Language,
accountsettings.LocalCurrency,
accountsettings.CoinUnit,
accountsettings.EmailNotification,
accountsettings.PhoneNotification,
accountsettings.PasswordHint,
accountsettings.TwoFactor,
accountsettings.TwoFactorType,
accountsettings.DailyTransactionLimit,
accountsettings.SingleTransactionLimit,
accountsettings.NoOfTransactionsPerDay,
accountsettings.NoOfTransactionsPerHour 
from accountsettings where accountsettings.WalletId = p_guid;

END;
$$;


ALTER FUNCTION public.sp_accountsettings(p_guid character varying) OWNER TO postgres;

--
-- TOC entry 254 (class 1255 OID 16722)
-- Name: sp_addressesbyaccount(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_addressesbyaccount(p_guid character varying) RETURNS TABLE(refaddress character varying, nodelevel character varying, pk1 character varying, pk2 character varying, pk3 character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	RETURN QUERY
	select accountaddress.RefAddress,accountaddress.NodeLevel, accountaddress.pk1, accountaddress.pk2, accountaddress.pk3 from accountaddress where accountaddress.WalletId = p_guid
	and IsActive = 1;
END;
$$;


ALTER FUNCTION public.sp_addressesbyaccount(p_guid character varying) OWNER TO postgres;

--
-- TOC entry 280 (class 1255 OID 16869)
-- Name: sp_addressesbyaccountaddress(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_addressesbyaccountaddress(p_guid character varying, p_address character varying) RETURNS TABLE(refaddress character varying, nodelevel character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	RETURN QUERY
	select accountaddress.RefAddress,accountaddress.NodeLevel from accountaddress where accountaddress.WalletId = p_guid and accountaddress.RefAddress = p_address;
END;
$$;


ALTER FUNCTION public.sp_addressesbyaccountaddress(p_guid character varying, p_address character varying) OWNER TO postgres;

--
-- TOC entry 256 (class 1255 OID 16724)
-- Name: sp_amountsforaddress(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_amountsforaddress(p_address character varying) RETURNS TABLE(amount numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT tranoutputs.amount from tranoutputs where tranoutputs.Address = p_address and tranoutputs.IsSpent = 0 and (tranoutputs.IsPending is null or tranoutputs.IsPending = 0);
END;
$$;


ALTER FUNCTION public.sp_amountsforaddress(p_address character varying) OWNER TO postgres;

--
-- TOC entry 255 (class 1255 OID 16725)
-- Name: sp_amountsforaddressnoncon(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_amountsforaddressnoncon(p_address character varying) RETURNS TABLE(amount numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT tranoutputs_noncon.amount from tranoutputs_noncon where tranoutputs_noncon.Address = p_address and tranoutputs_noncon.IsSpent = 0;
END;
$$;


ALTER FUNCTION public.sp_amountsforaddressnoncon(p_address character varying) OWNER TO postgres;

--
-- TOC entry 240 (class 1255 OID 16594)
-- Name: sp_authsecretbyaccount(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_authsecretbyaccount(p_guid character varying) RETURNS TABLE(googleauthsecret character varying, twofactoronlogin integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
    RETURN QUERY
	select account.GoogleAuthSecret, account.TwoFactorOnLogin from account where account.WalletId = p_guid;
END;
$$;


ALTER FUNCTION public.sp_authsecretbyaccount(p_guid character varying) OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 16560)
-- Name: sp_createaccount2(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_createaccount2(p_guid character varying, p_payload character varying, p_hotmasterpublickey character varying, p_coldmasterpublickey character varying, p_iv character varying, p_vc character varying, p_ivr character varying, p_recpacket character varying, p_recpacketiv character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
update Account set Payload = p_payload, IV = p_IV, HotMasterPublicKey = p_HotMasterPublicKey, ColdMasterPublicKey = p_ColdMasterPublicKey, Vc = p_Vc, IVR = p_IVR, RecPacket = p_RecPacket, RecPacketIV = p_RecPacketIV where WalletId = p_guid;

END;
$$;


ALTER FUNCTION public.sp_createaccount2(p_guid character varying, p_payload character varying, p_hotmasterpublickey character varying, p_coldmasterpublickey character varying, p_iv character varying, p_vc character varying, p_ivr character varying, p_recpacket character varying, p_recpacketiv character varying) OWNER TO postgres;

--
-- TOC entry 234 (class 1255 OID 16541)
-- Name: sp_createaccount_v2(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_createaccount_v2(p_guid character varying, p_ninkipk character varying, p_ninkipub character varying, p_usertoken character varying, p_ninkipubc0 character varying, p_ninkipkc0 character varying, p_ninkipubc1 character varying, p_ninkipkc1 character varying, p_secret character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here

insert into account (WalletId,Payload,NinkiMasterPrivateKey,NinkiMasterPublicKey,UserToken,Secret,TwoFactorOnLogin) values (p_guid,null,p_ninkipk,p_ninkipub,p_usertoken,p_secret, 1);
insert into nodekeycache values (p_guid,'m/0/0',p_ninkipubc0,p_ninkipkc0);
insert into nodekeycache values (p_guid,'m/0/1',p_ninkipubc1,p_ninkipkc1);
insert into accountsettings (WalletId,Inactivity,MinersFee,Language,LocalCurrency,DailyTransactionLimit,SingleTransactionLimit,NoOfTransactionsPerDay,NoOfTransactionsPerHour,CoinUnit) values (p_guid,10,10000,'EN','USD',100000000,50000000,10,4,'BTC');


END;
$$;


ALTER FUNCTION public.sp_createaccount_v2(p_guid character varying, p_ninkipk character varying, p_ninkipub character varying, p_usertoken character varying, p_ninkipubc0 character varying, p_ninkipkc0 character varying, p_ninkipubc1 character varying, p_ninkipkc1 character varying, p_secret character varying) OWNER TO postgres;

--
-- TOC entry 285 (class 1255 OID 16755)
-- Name: sp_createaccountaddress(character varying, character varying, character varying, character varying, integer, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_createaccountaddress(p_guid character varying, p_path character varying, p_address character varying, p_branch character varying, p_leaf integer, p_pk1 character varying, p_pk2 character varying, p_pk3 character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN

	insert into AccountAddress values (p_guid,p_path,p_address,p_branch,p_leaf,p_pk1,p_pk2,p_pk3, 1);
END;
$$;


ALTER FUNCTION public.sp_createaccountaddress(p_guid character varying, p_path character varying, p_address character varying, p_branch character varying, p_leaf integer, p_pk1 character varying, p_pk2 character varying, p_pk3 character varying) OWNER TO postgres;

--
-- TOC entry 252 (class 1255 OID 16665)
-- Name: sp_createaccountlog(character varying, integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_createaccountlog(p_guid character varying, p_success integer, p_logtype character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
	insert into accountlog (WalletId,LogDate,Success,LogType) values (p_guid,NOW(),p_success,p_logType);

END;
$$;


ALTER FUNCTION public.sp_createaccountlog(p_guid character varying, p_success integer, p_logtype character varying) OWNER TO postgres;

--
-- TOC entry 260 (class 1255 OID 16814)
-- Name: sp_createaccountsecpub(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_createaccountsecpub(p_guid character varying, p_secretpub character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
INSERT INTO AccountSecPub
           (WalletId
           ,SecretPub,CreateDate,UpdateDate)
     VALUES
           (p_guid, p_SecretPub,NOW(),NOW());

END;
$$;


ALTER FUNCTION public.sp_createaccountsecpub(p_guid character varying, p_secretpub character varying) OWNER TO postgres;

--
-- TOC entry 259 (class 1255 OID 16813)
-- Name: sp_createbackupcode(character varying, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_createbackupcode(p_guid character varying, p_backupset integer, p_backupindex integer, p_backupcode character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN

INSERT INTO AccountBackupCode
           (WalletId,
           BackupSet,
           BackupIndex,
           BackupCode,
           Used,
           DateUsed)
     VALUES
           (p_guid,
            p_BackupSet,
            p_BackupIndex,
            p_BackupCode,
            0,
            NOW());

END;
$$;


ALTER FUNCTION public.sp_createbackupcode(p_guid character varying, p_backupset integer, p_backupindex integer, p_backupcode character varying) OWNER TO postgres;

--
-- TOC entry 316 (class 1255 OID 16794)
-- Name: sp_createdevice(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_createdevice(p_guid character varying, p_devicename character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN

	insert into AccountDevice (WalletId, DeviceName) values (p_guid, p_deviceName);
END;
$$;


ALTER FUNCTION public.sp_createdevice(p_guid character varying, p_devicename character varying) OWNER TO postgres;

--
-- TOC entry 239 (class 1255 OID 16581)
-- Name: sp_createemailtoken(character varying, character varying, character varying, timestamp without time zone, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_createemailtoken(p_emailvalidationtoken character varying, p_walletid character varying, p_emailaddress character varying, p_expirydate timestamp without time zone, p_isused integer, p_tokentype integer) RETURNS void
    LANGUAGE plpgsql
    AS $$

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
	insert into EmailToken (EmailValidationToken,WalletId,EmailAddress,ExpiryDate,IsUsed,TokenType)
	values(p_EmailValidationToken,p_WalletId,p_EmailAddress,p_ExpiryDate,p_IsUsed,p_TokenType);
END;

$$;


ALTER FUNCTION public.sp_createemailtoken(p_emailvalidationtoken character varying, p_walletid character varying, p_emailaddress character varying, p_expirydate timestamp without time zone, p_isused integer, p_tokentype integer) OWNER TO postgres;

--
-- TOC entry 293 (class 1255 OID 16765)
-- Name: sp_createfriend(character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_createfriend(p_guid character varying, p_username character varying, p_packetforfriend character varying, p_validationhash character varying) RETURNS TABLE(walletid character varying)
    LANGUAGE plpgsql
    AS $$

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
    declare v_UserId char(36);
    v_myUserName varchar(50);
    v_UserIdFriend char(36);
    v_theirWalletid varchar(64);
BEGIN

    select users.UserId, users.UserName into v_UserId, v_myUserName from users where users.WalletId = p_guid;

    select users.UserId, users.WalletId into v_UserIdFriend, v_theirWalletid from users where users.username = p_username;

	update usernetwork set PacketForFriend = p_PacketForFriend, Status = 0, ValidationHash = p_ValidationHash where UserId = v_UserId and UserIdFriend = v_UserIdFriend;

	insert into UserTimeline
	(UserId,TimelineType,TransactionId,InvoiceId,UserName,TimelineDate) values
	(v_UserId ,'FRS', null,0,p_username,NOW());
	insert into UserTimeline
	(UserId,TimelineType,TransactionId,InvoiceId,UserName,TimelineDate) values
	(v_UserIdFriend,'FRR', null,0,v_myUserName,NOW());

	RETURN QUERY
	select v_theirWalletid;

END;

$$;


ALTER FUNCTION public.sp_createfriend(p_guid character varying, p_username character varying, p_packetforfriend character varying, p_validationhash character varying) OWNER TO postgres;

--
-- TOC entry 304 (class 1255 OID 16786)
-- Name: sp_createinvoice(character varying, character varying, timestamp without time zone, integer, timestamp without time zone, character varying, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_createinvoice(p_guid character varying, p_username character varying, p_invoicedate timestamp without time zone, p_invoicestatus integer, p_invoicepaiddate timestamp without time zone, p_transactionid character varying, p_packetforme text, p_packetforthem text) RETURNS TABLE(walletid character varying, username character varying)
    LANGUAGE plpgsql
    AS $$
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
declare  v_UserId char(36);
  v_theirUserId  char(36);
  v_theirWalletId  varchar(64);
 v_myUserName varchar(100);
 v_InvoiceId int;
 
 BEGIN

select users.UserId, users.UserName into v_UserId, v_myUserName from users where users.WalletId = p_guid;
select users.UserId, users.WalletId into v_theirUserId, v_theirWalletId from users where users.username = p_UserName;

select max(userinvoices.InvoiceId)+1 into v_InvoiceId from userinvoices where userinvoices.UserId = v_UserId;
if v_InvoiceId is null
then
v_InvoiceId := 1;
end if;
INSERT INTO userinvoices (UserId,InvoiceId,UserName,InvoiceDate,InvoiceStatus,InvoicePaidDate,TransactionId,PacketForMe,PacketForThem) VALUES(v_UserId,v_InvoiceId,p_UserName,p_InvoiceDate,p_InvoiceStatus,p_InvoicePaidDate,p_TransactionId,p_PacketForMe,p_PacketForThem);

insert into UserTimeline
(UserId,TimelineType,TransactionId,InvoiceId,UserName,TimelineDate) values (
v_UserId ,'IS', null,v_InvoiceId,p_UserName,NOW());

insert into UserTimeline (UserId,TimelineType,TransactionId,InvoiceId,UserName,TimelineDate) values
(v_theirUserId  ,'IR', null,v_InvoiceId,v_myUserName, NOW());

RETURN QUERY
select v_theirWalletId, v_myUserName;

END;
$$;


ALTER FUNCTION public.sp_createinvoice(p_guid character varying, p_username character varying, p_invoicedate timestamp without time zone, p_invoicestatus integer, p_invoicepaiddate timestamp without time zone, p_transactionid character varying, p_packetforme text, p_packetforthem text) OWNER TO postgres;

--
-- TOC entry 305 (class 1255 OID 16787)
-- Name: sp_createmessage(character varying, character varying, text, text, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_createmessage(p_guid character varying, p_username character varying, p_packetforme text, p_packetforthem text, p_transactionid character varying) RETURNS TABLE(walletid character varying, username character varying)
    LANGUAGE plpgsql
    AS $$
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
declare  v_UserId char(36);
 v_MyUserName varchar(50);
  v_theirWalletId  varchar(64);
  v_theirUserId  char(36);
 v_MessageId int;
  v_ismess char(36);
 
 BEGIN

select users.UserId, users.Username into v_UserId, v_MyUserName from users where users.WalletId = p_guid;
select users.UserId, users.WalletId into v_theirUserId, v_theirWalletId from users where users.username = p_UserName;

select max(usermessage.MessageId)+1 into v_MessageId from usermessage where usermessage.UserId = v_UserId;
if v_MessageId is null
then
v_MessageId := 1;
end if;

INSERT INTO UserMessage (UserId,MessageId,UserName,PacketForMe,PacketForThem,CreateDate,TransactionId) VALUES(v_UserId,v_MessageId,p_UserName,p_PacketForMe,p_PacketForThem, NOW(),p_TransactionId);


select usertimeline.UserId into v_ismess from usertimeline where usertimeline.UserId = v_theirUserId and usertimeline.TimelineType = 'MS' and usertimeline.UserName = v_MyUserName;

if v_ismess is null
then
insert into UserTimeline (UserId,TimelineType,TransactionId,InvoiceId,UserName,TimelineDate) values
(v_theirUserId  ,'MS', null,null,v_MyUserName, NOW());

else
update UserTimeline set TimelineDate = NOW() where UserTimeline.UserId = v_theirUserId and UserTimeline.TimelineType = 'MS' and UserTimeline.UserName = v_MyUserName;
end if;

RETURN QUERY
select v_theirWalletId, v_MyUserName;

END;
$$;


ALTER FUNCTION public.sp_createmessage(p_guid character varying, p_username character varying, p_packetforme text, p_packetforthem text, p_transactionid character varying) OWNER TO postgres;

--
-- TOC entry 292 (class 1255 OID 16767)
-- Name: sp_createnodecache(character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_createnodecache(p_guid character varying, p_nodelevel character varying, p_ninkipub character varying, p_ninkipk character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
	insert into NodeKeyCache values (p_guid,p_nodelevel,p_ninkipub,p_ninkipk);
END;
$$;


ALTER FUNCTION public.sp_createnodecache(p_guid character varying, p_nodelevel character varying, p_ninkipub character varying, p_ninkipk character varying) OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 16558)
-- Name: sp_createrec(character varying, character varying, character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_createrec(p_pk character varying, p_un character varying, p_em character varying, p_ph character varying, p_vc character varying, p_pkh character varying, p_mpkh character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
INSERT INTO Recs
           (Pk
           ,Un
           ,Em
           ,Ph
           ,Vc
           ,PkH
           ,MPKH
           ,CreateDate)
     VALUES
           (p_Pk,
            p_Un,
            p_Em,
            p_Ph,
            p_Vc,
            p_PkH,
            p_MPKH,
           CURRENT_DATE);

END;

$$;


ALTER FUNCTION public.sp_createrec(p_pk character varying, p_un character varying, p_em character varying, p_ph character varying, p_vc character varying, p_pkh character varying, p_mpkh character varying) OWNER TO postgres;

--
-- TOC entry 282 (class 1255 OID 16880)
-- Name: sp_createtranoutputs_noncon(character varying, integer, numeric, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_createtranoutputs_noncon(p_transactionid character varying, p_outputindex integer, p_amount numeric, p_address character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
    declare v_transtest varchar(64);
BEGIN

    select transactionId into v_transtest from TranOutputs_NonCon where TransactionId = p_transactionId and outputIndex = p_outputIndex;
    
    if v_transtest is null 
    then
	insert into TranOutputs_NonCon values (p_transactionId, p_outputIndex, p_amount, p_address,0);
	end if;
	
	
END;
$$;


ALTER FUNCTION public.sp_createtranoutputs_noncon(p_transactionid character varying, p_outputindex integer, p_amount numeric, p_address character varying) OWNER TO postgres;

--
-- TOC entry 319 (class 1255 OID 16881)
-- Name: sp_createtransactionrecord(character varying, character varying, character varying, integer, timestamp without time zone, bigint, character varying, integer, integer, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_createtransactionrecord(p_guid character varying, p_username character varying, p_transactionid character varying, p_outputindex integer, p_transdatetime timestamp without time zone, p_amount bigint, p_address character varying, p_notified integer, p_blocknumber integer, p_minersfee bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
declare v_myUserId char(36); v_myUserName varchar(50); v_theirUserId char(36);BEGIN

select UserId, UserName into v_myUserId, v_myUserName from Users where WalletId = p_guid;
select UserId into v_theirUserId from Users where username = p_username;

insert into UserTransactions (UserId, TransactionId, OutputIndex, TransDateTime, Amount, Address, UserName, TransType, Status, Notified, BlockNumber,MinersFee) values (v_myUserId, p_transactionId, p_outputIndex, p_transDateTime, p_amount, p_address,p_username, 'S', 0,p_notified ,p_blocknumber, p_minersFee);
insert into UserTimeline (UserId,TimelineType,TransactionId,InvoiceId,UserName,TimelineDate) values (v_myUserId,'TS', p_transactionId,null,p_username,NOW());

if v_theirUserId is not null
then
insert into UserTransactions (UserId, TransactionId, OutputIndex, TransDateTime, Amount, Address, UserName, TransType, Status, Notified, BlockNumber,MinersFee) values (v_theirUserId, p_transactionId, p_outputIndex, p_transDateTime, p_amount, p_address,v_myUserName,'R',0,p_notified ,p_blocknumber, p_minersFee);
insert into UserTimeline (UserId,TimelineType,TransactionId,InvoiceId,UserName,TimelineDate) values (v_theirUserId,'TR', p_transactionId,null, v_myUserName,NOW());
end if;
END;
$$;


ALTER FUNCTION public.sp_createtransactionrecord(p_guid character varying, p_username character varying, p_transactionid character varying, p_outputindex integer, p_transdatetime timestamp without time zone, p_amount bigint, p_address character varying, p_notified integer, p_blocknumber integer, p_minersfee bigint) OWNER TO postgres;

--
-- TOC entry 306 (class 1255 OID 16852)
-- Name: sp_createtransactionrecordexternal(character, character varying, integer, timestamp without time zone, bigint, character varying, integer, integer, bigint, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_createtransactionrecordexternal(p_userid character, p_transactionid character varying, p_outputindex integer, p_transdatetime timestamp without time zone, p_amount bigint, p_address character varying, p_notified integer, p_blocknumber integer, p_minersfee bigint, p_status integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN

insert into UserTransactions
(UserId, TransactionId, OutputIndex, TransDateTime, Amount, Address, UserName, TransType, Status, Notified, BlockNumber, MinersFee) values
(p_userid, p_transactionId, p_outputIndex, p_transDateTime, p_amount,p_address,'External', 'R', p_status,p_notified ,p_blocknumber, p_minersFee);

insert into UserTimeline (UserId,TimelineType,TransactionId,InvoiceId,UserName,TimelineDate) values (p_userid,'TR', p_transactionId,null,'External',NOW());
END;
$$;


ALTER FUNCTION public.sp_createtransactionrecordexternal(p_userid character, p_transactionid character varying, p_outputindex integer, p_transdatetime timestamp without time zone, p_amount bigint, p_address character varying, p_notified integer, p_blocknumber integer, p_minersfee bigint, p_status integer) OWNER TO postgres;

--
-- TOC entry 236 (class 1255 OID 16561)
-- Name: sp_createuser(character, character varying, character varying, character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_createuser(p_userid character, p_guid character varying, p_nickname character varying, p_firstname character varying, p_lastname character varying, p_userpublickey character varying, p_userpayload character varying, p_iv character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
	insert into Users (UserId
           ,WalletId
           ,Username
           ,FirstName
           ,LastName
           ,UserPublicKey
           ,UserPayload
           ,IV) values
           (p_userid,p_guid,p_nickName,p_firstName,p_lastName,p_userPublicKey,p_userPayload,p_IV);
END;
$$;


ALTER FUNCTION public.sp_createuser(p_userid character, p_guid character varying, p_nickname character varying, p_firstname character varying, p_lastname character varying, p_userpublickey character varying, p_userpayload character varying, p_iv character varying) OWNER TO postgres;

--
-- TOC entry 296 (class 1255 OID 16845)
-- Name: sp_destroydevice(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_destroydevice(p_guid character varying, p_regtoken character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$

    declare v_tft varchar(64);
BEGIN

    select TwoFactorToken into v_tft from AccountDevice where WalletId = p_guid and RegToken = p_RegToken;

	update AccountDevice set DevicePIN = null, DeviceKey = null, TwoFactorToken = null , RegToken = null where WalletId = p_guid and RegToken = p_RegToken;

	update EmailToken set ExpiryDate = NOW() where WalletId = p_guid and EmailValidationToken = v_tft;

END;
$$;


ALTER FUNCTION public.sp_destroydevice(p_guid character varying, p_regtoken character varying) OWNER TO postgres;

--
-- TOC entry 297 (class 1255 OID 16846)
-- Name: sp_destroydevice2(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_destroydevice2(p_guid character varying, p_devicename character varying) RETURNS TABLE(regtoken character varying)
    LANGUAGE plpgsql
    AS $$
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
    declare v_tft varchar(64);
    v_regtoken varchar(64);
BEGIN

    select TwoFactorToken, RegToken into v_tft, v_regtoken from AccountDevice where WalletId = p_guid and DeviceName = p_deviceName;

	update AccountDevice set DevicePIN = null, DeviceKey = null, TwoFactorToken = null , RegToken = null where WalletId = p_guid and DeviceName = p_deviceName;

	update EmailToken set ExpiryDate = NOW() where WalletId = p_guid and EmailValidationToken = v_tft;
	RETURN QUERY
	select v_regtoken;

END;
$$;


ALTER FUNCTION public.sp_destroydevice2(p_guid character varying, p_devicename character varying) OWNER TO postgres;

--
-- TOC entry 286 (class 1255 OID 16760)
-- Name: sp_doesnetworkexist(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_doesnetworkexist(p_guid character varying, p_username character varying) RETURNS TABLE(addressset character varying)
    LANGUAGE plpgsql
    AS $$
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	 declare v_UserId char(36);
    v_UserIdFriend char(36);
    BEGIN

    select users.UserId into v_UserId from users where users.WalletId = p_guid;
    select users.UserId into v_UserIdFriend from users where users.username = p_username;
	RETURN QUERY
    select usernetwork.AddressSet from usernetwork where usernetwork.UserId = v_UserId and usernetwork.UserIdFriend = v_UserIdFriend;
END;
$$;


ALTER FUNCTION public.sp_doesnetworkexist(p_guid character varying, p_username character varying) OWNER TO postgres;

--
-- TOC entry 323 (class 1255 OID 16934)
-- Name: sp_getaccountlocked(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getaccountlocked(p_guid character varying) RETURNS TABLE(locked integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	select account.Locked from account where account.WalletId = p_guid;

END;
$$;


ALTER FUNCTION public.sp_getaccountlocked(p_guid character varying) OWNER TO postgres;

--
-- TOC entry 270 (class 1255 OID 16827)
-- Name: sp_getaccountsecpub(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getaccountsecpub(p_guid character varying) RETURNS TABLE(secretpub character varying)
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN QUERY
Select accountsecpub.SecretPub from accountsecpub where accountsecpub.WalletId = p_guid;

END;

$$;


ALTER FUNCTION public.sp_getaccountsecpub(p_guid character varying) OWNER TO postgres;

--
-- TOC entry 262 (class 1255 OID 16820)
-- Name: sp_getdevice(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getdevice(p_guid character varying, p_devicename character varying) RETURNS TABLE(walletid character varying, devicename character varying, deviceid character varying, devicemodel character varying, devicepin character varying, devicekey character varying, twofactortoken character varying, regtoken character varying, keydate timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
RETURN QUERY
SELECT accountdevice.WalletId
      ,accountdevice.DeviceName
      ,accountdevice.DeviceId
      ,accountdevice.DeviceModel
      ,accountdevice.DevicePIN
      ,accountdevice.DeviceKey
      ,accountdevice.TwoFactorToken
      ,accountdevice.RegToken
      ,accountdevice.KeyDate
  FROM accountdevice
  Where accountdevice.WalletId = p_guid and accountdevice.DeviceName = p_deviceName;
END;
$$;


ALTER FUNCTION public.sp_getdevice(p_guid character varying, p_devicename character varying) OWNER TO postgres;

--
-- TOC entry 263 (class 1255 OID 16824)
-- Name: sp_getdevicekey(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getdevicekey(p_guid character varying, p_devicepin character varying, p_regtoken character varying) RETURNS TABLE(devicekey character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN

RETURN QUERY
SELECT accountdevice.DeviceKey
  FROM accountdevice
  Where accountdevice.WalletId = p_guid and accountdevice.DevicePIN = p_DevicePIN and accountdevice.RegToken = p_regToken;
END;
$$;


ALTER FUNCTION public.sp_getdevicekey(p_guid character varying, p_devicepin character varying, p_regtoken character varying) OWNER TO postgres;

--
-- TOC entry 274 (class 1255 OID 16746)
-- Name: sp_getdevices(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getdevices(p_guid character varying) RETURNS TABLE(devicename character varying, devicemodel character varying, deviceid character varying, devicepin character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	select 
    accountdevice.DeviceName, 
    accountdevice.DeviceModel, 
    accountdevice.DeviceId, 
    accountdevice.DevicePIN 
    from accountdevice where accountdevice.WalletId = p_guid;
END;

$$;


ALTER FUNCTION public.sp_getdevices(p_guid character varying) OWNER TO postgres;

--
-- TOC entry 251 (class 1255 OID 16648)
-- Name: sp_getemailtoken(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getemailtoken(p_emailvalidationtoken character varying, p_walletid character varying) RETURNS TABLE(expirydate timestamp without time zone, tokentype integer)
    LANGUAGE plpgsql
    AS $$

BEGIN

    RETURN QUERY
	select emailtoken.ExpiryDate, emailtoken.TokenType from emailtoken where emailtoken.WalletId = p_WalletId and emailtoken.EmailValidationToken = p_EmailValidationToken and emailtoken.isused = 0;
END;

$$;


ALTER FUNCTION public.sp_getemailtoken(p_emailvalidationtoken character varying, p_walletid character varying) OWNER TO postgres;

--
-- TOC entry 310 (class 1255 OID 16866)
-- Name: sp_getfees(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getfees() RETURNS TABLE(low bigint, med bigint, high bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN

    RETURN QUERY
	Select fees.Low, fees.Med, fees.High from fees where feeid = 1;
END;
$$;


ALTER FUNCTION public.sp_getfees() OWNER TO postgres;

--
-- TOC entry 302 (class 1255 OID 16777)
-- Name: sp_getfriend(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getfriend(p_guid character varying, p_username character varying) RETURNS TABLE(category character varying, profileimage character varying, status character varying, cansend integer, canreceive integer, validationhash character varying)
    LANGUAGE plpgsql
    AS $$
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
declare v_UserId char(36);

BEGIN

select users.UserId into v_UserId from users where users.WalletId = p_guid;
    -- Insert statements for procedure here
RETURN QUERY
 select coalesce(un2.category,'') as category,
 coalesce(up.ProfileImage,'') as ProfileImage ,
 coalesce(up.Status,'I love Ninki!') as Status,
 un1.Status as CanSend, 
 un2.Status as CanReceive, 
 un1.ValidationHash 
 from UserNetwork un1
inner join UserNetwork un2 on un2.UserId = un1.UserIdFriend and un2.useridfriend = un1.UserId
inner join users on users.userid = un1.userid
left join UserProfile up on up.userid = users.userid
where un1.useridfriend = v_UserId and users.Username = p_username;
END;
$$;


ALTER FUNCTION public.sp_getfriend(p_guid character varying, p_username character varying) OWNER TO postgres;

--
-- TOC entry 303 (class 1255 OID 16781)
-- Name: sp_getfriendpacket(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getfriendpacket(p_guid character varying, p_username character varying) RETURNS TABLE(addressset character varying)
    LANGUAGE plpgsql
    AS $$
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
    declare v_UserId char(36);
    declare v_UserIdFriend char(36);
    BEGIN

    select users.UserId into v_UserId from users where users.WalletId = p_guid;
    select users.UserId into v_UserIdFriend from users where users.username = p_username;
	RETURN QUERY
    select usernetwork.AddressSet from usernetwork where usernetwork.UserIdFriend = v_UserId and usernetwork.UserId = v_UserIdFriend;
END;
$$;


ALTER FUNCTION public.sp_getfriendpacket(p_guid character varying, p_username character varying) OWNER TO postgres;

--
-- TOC entry 295 (class 1255 OID 16769)
-- Name: sp_getfriendrequestpacket(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getfriendrequestpacket(p_guid character varying, p_username character varying) RETURNS TABLE(packetforfriend character varying)
    LANGUAGE plpgsql
    AS $$
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
    declare v_UserId char(36);
    v_UserIdFriend char(36);
    
    BEGIN
    select users.UserId into v_UserId from users where WalletId = p_guid;
    select users.UserId into v_UserIdFriend from users where username = p_username;
    RETURN QUERY
	select usernetwork.PacketForFriend from usernetwork where usernetwork.userid = v_UserIdFriend and  usernetwork.UserIdFriend = v_UserId;
END;
$$;


ALTER FUNCTION public.sp_getfriendrequestpacket(p_guid character varying, p_username character varying) OWNER TO postgres;

--
-- TOC entry 283 (class 1255 OID 16752)
-- Name: sp_getfriendrequests(character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getfriendrequests(p_guid character varying, p_status integer) RETURNS TABLE(username character varying, useridfriend character, addressset character varying, dummy character varying, profileimage character varying, status character varying)
    LANGUAGE plpgsql
    AS $$
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
declare v_UserId char(36);

BEGIN

select users.UserId into v_UserId from users where users.WalletId = p_guid;
    -- Insert statements for procedure here

RETURN QUERY
select 
users.username, 
un1.useridfriend, 
un1.AddressSet ,
users.username as Dummy,
coalesce(up.ProfileImage,'') as ProfileImage ,
coalesce(up.Status,'I love Ninki!') as Status 
from usernetwork un1
inner join users on users.userid = un1.userid
left join userprofile up on up.userid = users.userid
where un1.useridfriend = v_UserId and un1.status = p_status;


END;
$$;


ALTER FUNCTION public.sp_getfriendrequests(p_guid character varying, p_status integer) OWNER TO postgres;

--
-- TOC entry 266 (class 1255 OID 16737)
-- Name: sp_getinvoicesbyuser(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getinvoicesbyuser(p_guid character varying) RETURNS TABLE(username character varying, invoiceid integer, invoicedate timestamp without time zone, invoicestatus integer, invoicepaiddate timestamp without time zone, transactionid character varying, packetforme text)
    LANGUAGE plpgsql
    AS $$

    declare v_UserId varchar(50);
BEGIN

    select users.UserId into v_UserId from users where users.WalletId = p_guid;
    RETURN QUERY
	SELECT userinvoices.UserName,
    userinvoices.InvoiceId,
    userinvoices.InvoiceDate,
    userinvoices.InvoiceStatus,
    userinvoices.InvoicePaidDate,
    userinvoices.TransactionId,
    userinvoices.PacketForMe 
    FROM userinvoices 
    where userinvoices.UserId = v_UserId and userinvoices.InvoiceStatus in (0,1,2) 
    order by userinvoices.InvoiceDate desc;
END;

$$;


ALTER FUNCTION public.sp_getinvoicesbyuser(p_guid character varying) OWNER TO postgres;

--
-- TOC entry 267 (class 1255 OID 16738)
-- Name: sp_getinvoicesbyusernetwork(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getinvoicesbyusernetwork(p_guid character varying, p_username character varying) RETURNS TABLE(username character varying, invoiceid integer, invoicedate timestamp without time zone, invoicestatus integer, invoicepaiddate timestamp without time zone, transactionid character varying, packetforme text)
    LANGUAGE plpgsql
    AS $$

    declare v_UserId varchar(50);
BEGIN

    select users.UserId into v_UserId from users where users.WalletId = p_guid;
	RETURN QUERY
    SELECT userinvoices.UserName,userinvoices.InvoiceId,
    userinvoices.InvoiceDate,userinvoices.InvoiceStatus,
    userinvoices.InvoicePaidDate,
    userinvoices.TransactionId,
    userinvoices.PacketForMe FROM userinvoices 
    where userinvoices.UserId = v_UserId 
    and userinvoices.UserName = p_username and 
    userinvoices.InvoiceStatus in (0,1,2) order by userinvoices.InvoiceDate desc;
END;

$$;


ALTER FUNCTION public.sp_getinvoicesbyusernetwork(p_guid character varying, p_username character varying) OWNER TO postgres;

--
-- TOC entry 273 (class 1255 OID 16739)
-- Name: sp_getinvoicestopay(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getinvoicestopay(p_guid character varying) RETURNS TABLE(username character varying, invoiceid integer, invoicedate timestamp without time zone, invoicestatus integer, invoicepaiddate timestamp without time zone, transactionid character varying, packetforme text)
    LANGUAGE plpgsql
    AS $$

    declare v_UserName varchar(50);
BEGIN

    select users.UserName into v_UserName from users where users.WalletId = p_guid;
	RETURN QUERY
    SELECT 
    users.UserName,
    userinvoices.InvoiceId,
    userinvoices.InvoiceDate,
    userinvoices.InvoiceStatus,
    userinvoices.InvoicePaidDate,
    userinvoices.TransactionId,
    userinvoices.PacketForThem 
    FROM userinvoices Inner Join 
    users on users.UserId = UserInvoices.UserId  
    where userinvoices.UserName = v_UserName 
    and userinvoices.InvoiceStatus in (0,1,2) 
    order by userinvoices.InvoiceDate desc;
END;
$$;


ALTER FUNCTION public.sp_getinvoicestopay(p_guid character varying) OWNER TO postgres;

--
-- TOC entry 300 (class 1255 OID 16775)
-- Name: sp_getinvoicestopaynetwork(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getinvoicestopaynetwork(p_guid character varying, p_username character varying) RETURNS TABLE(username character varying, invoiceid integer, invoicedate timestamp without time zone, invoicestatus integer, invoicepaiddate timestamp without time zone, transactionid character varying, packetforthem text)
    LANGUAGE plpgsql
    AS $$
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	declare v_userid char(36);
    declare v_myUserName varchar(50);
    BEGIN

	select users.UserId into v_userid from users where users.UserName = p_username;

    
    select users.UserName into v_myUserName from users where users.WalletId = p_guid;
	RETURN QUERY
	SELECT p_username,userinvoices.InvoiceId,userinvoices.InvoiceDate,userinvoices.InvoiceStatus,userinvoices.InvoicePaidDate,userinvoices.TransactionId,userinvoices.PacketForThem
	FROM userinvoices
	where userinvoices.UserName = v_myUserName and userinvoices.UserId = v_userid  and userinvoices.InvoiceStatus in (0,1,2)
	order by userinvoices.InvoiceDate desc;
END;
$$;


ALTER FUNCTION public.sp_getinvoicestopaynetwork(p_guid character varying, p_username character varying) OWNER TO postgres;

--
-- TOC entry 291 (class 1255 OID 16766)
-- Name: sp_getmasterkey(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getmasterkey(p_guid character varying) RETURNS TABLE(ninkimasterprivatekey character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
    RETURN QUERY
	select account.NinkiMasterPrivateKey from account where account.WalletId = p_guid;
END;
$$;


ALTER FUNCTION public.sp_getmasterkey(p_guid character varying) OWNER TO postgres;

--
-- TOC entry 313 (class 1255 OID 16790)
-- Name: sp_getmessagesbyusernetwork(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getmessagesbyusernetwork(p_guid character varying, p_username character varying) RETURNS TABLE(messageid integer, username character, packetforme character varying, packetforthem character varying, createdate timestamp without time zone, transactionid character varying, invoiceuserid integer, invoiceid integer)
    LANGUAGE plpgsql
    AS $$
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    declare v_UserId varchar(50);
    v_FriendUserId varchar(50);
    v_MyUsername varchar(50);
BEGIN

    select users.UserId, users.Username into v_UserId, v_MyUsername from users where users.WalletId = p_guid;
    select users.UserId into v_FriendUserId from users where users.UserName = p_username;

	RETURN QUERY
	SELECT usermessage.MessageId,
    usermessage.UserName,
    usermessage.PacketForMe,
    usermessage.PacketForThem,
    usermessage.CreateDate,
    usermessage.TransactionId,
    usermessage.InvoiceUserId,
    usermessage.InvoiceId
	FROM usermessage
	where (usermessage.UserId = v_UserId and UserName = p_username)
	or (usermessage.UserId = v_FriendUserId and UserName = v_MyUsername)
	order by usermessage.CreateDate desc;
END;




$$;


ALTER FUNCTION public.sp_getmessagesbyusernetwork(p_guid character varying, p_username character varying) OWNER TO postgres;

--
-- TOC entry 248 (class 1255 OID 16621)
-- Name: sp_getnextbackupindex(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getnextbackupindex(p_guid character varying) RETURNS TABLE(v_set integer, v_index integer)
    LANGUAGE plpgsql
    AS $$

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
declare v_set int;
declare v_index   int;


BEGIN

select MAX(BackupSet) into v_set from accountbackupcode where WalletId = p_guid;

if v_set is null
then
v_set := 0;
end if;

select MAX(BackupIndex)+1 into v_index from AccountBackupCode where WalletId = p_guid
and BackupSet = v_set and Used = 1;

if v_index is null
then
v_index := 1;
end if;

if v_index = 11
then
v_index := 0;
v_set := 0;
end if;


RETURN QUERY
select v_set as v_set, v_index as v_index;

END;

$$;


ALTER FUNCTION public.sp_getnextbackupindex(p_guid character varying) OWNER TO postgres;

--
-- TOC entry 258 (class 1255 OID 16812)
-- Name: sp_getnextbackupset(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getnextbackupset(p_guid character varying) RETURNS TABLE(nextset integer)
    LANGUAGE plpgsql
    AS $$
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
declare v_nextset int;BEGIN


select MAX(BackupSet) into v_nextset from AccountBackupCode where WalletId = p_guid;

if v_nextset is null
then
v_nextset := 1;
else
v_nextset := v_nextset + 1;
end if;

RETURN QUERY
select v_nextset;

END;
$$;


ALTER FUNCTION public.sp_getnextbackupset(p_guid character varying) OWNER TO postgres;

--
-- TOC entry 284 (class 1255 OID 16753)
-- Name: sp_getnextleaf(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getnextleaf(p_guid character varying, p_pathtouse character varying) RETURNS TABLE(nodeleaf integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	select Max(accountaddress.NodeLeaf) + 1 from accountaddress 
    where accountaddress.WalletId = p_guid and accountaddress.NodeBranch = p_pathToUse;
END;
$$;


ALTER FUNCTION public.sp_getnextleaf(p_guid character varying, p_pathtouse character varying) OWNER TO postgres;

--
-- TOC entry 289 (class 1255 OID 16843)
-- Name: sp_getnextleafforfriend(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getnextleafforfriend(p_guid character varying, p_username character varying) RETURNS TABLE(nodeleaf integer)
    LANGUAGE plpgsql
    AS $$
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
    declare v_UserId char(36);
    v_UserIdFriend char(36);
    v_WalletIdFriend varchar(64);
    v_nodeleaf int;
    v_pathToUse varchar(50);
BEGIN

    -- Insert statements for procedure here
    select users.UserId into v_UserId from users where users.WalletId = p_guid;
    select users.UserId, users.WalletId into v_UserIdFriend, v_WalletIdFriend from users where users.username = p_username;
    select usernetwork.NodeLevel into v_pathToUse from usernetwork where usernetwork.UseridFriend = v_UserId and usernetwork.Userid = v_UserIdFriend;
	RETURN QUERY
    select Max(accountaddress.NodeLeaf) + 1 from accountaddress where accountaddress.WalletId = v_WalletIdFriend and accountaddress.NodeBranch = v_pathToUse;
END;
$$;


ALTER FUNCTION public.sp_getnextleafforfriend(p_guid character varying, p_username character varying) OWNER TO postgres;

--
-- TOC entry 287 (class 1255 OID 16762)
-- Name: sp_getnextnodeforfriend(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getnextnodeforfriend(p_guid character varying, p_username character varying, p_nodebranch character varying) RETURNS TABLE(nodeleaf integer)
    LANGUAGE plpgsql
    AS $$
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
    declare v_UserId char(36);
    declare v_nodeLevel varchar(50);
    v_UserIdFriend char(36);
    v_nodeleaf int;
    
    BEGIN

    select users.UserId into v_UserId from users where users.WalletId = p_guid;
    select users.UserId into v_UserIdFriend from users where users.username = p_username;

    select Max(usernetwork.NodeLeaf) + 1 into v_nodeleaf from usernetwork where usernetwork.UserId = v_UserId;

    if v_nodeleaf  is null
    then
		v_nodeleaf := 1000;
    end if;

    
    v_nodeLevel := p_nodeBranch || '/' || v_nodeleaf::text;
	insert into UserNetwork values (v_UserId, v_UserIdFriend, v_nodeLevel, p_nodeBranch, v_nodeleaf, null, -1, null,null,null,1,NOW(),NOW());
	RETURN QUERY
    select v_nodeleaf as NodeLeaf;
END;
$$;


ALTER FUNCTION public.sp_getnextnodeforfriend(p_guid character varying, p_username character varying, p_nodebranch character varying) OWNER TO postgres;

--
-- TOC entry 246 (class 1255 OID 16618)
-- Name: sp_getnickname(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getnickname(p_guid character varying) RETURNS TABLE(username character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	select users.Username from users where users.WalletId = p_guid;
END;
$$;


ALTER FUNCTION public.sp_getnickname(p_guid character varying) OWNER TO postgres;

--
-- TOC entry 299 (class 1255 OID 16849)
-- Name: sp_getoutputsnoncon(character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getoutputsnoncon(p_transactionid character varying, p_outputindex integer) RETURNS TABLE(isspent integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	select tranoutputs_noncon.IsSpent from tranoutputs_noncon where tranoutputs_noncon.transactionid = p_TransactionId and tranoutputs_noncon.OutputIndex = p_OutputIndex;
END;
$$;


ALTER FUNCTION public.sp_getoutputsnoncon(p_transactionid character varying, p_outputindex integer) OWNER TO postgres;

--
-- TOC entry 269 (class 1255 OID 16535)
-- Name: sp_getrecbyem(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getrecbyem(p_em character varying) RETURNS TABLE(em character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN

	select recs.Em from recs where recs.Em = p_Em;
END;
$$;


ALTER FUNCTION public.sp_getrecbyem(p_em character varying) OWNER TO postgres;

--
-- TOC entry 278 (class 1255 OID 16829)
-- Name: sp_getrecbympkh(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getrecbympkh(p_mpkh character varying) RETURNS TABLE(pk character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	select recs.Pk from recs where recs.MPKH = p_MPKH;
END;
$$;


ALTER FUNCTION public.sp_getrecbympkh(p_mpkh character varying) OWNER TO postgres;

--
-- TOC entry 218 (class 1255 OID 16534)
-- Name: sp_getrecbyun(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getrecbyun(p_un character varying) RETURNS TABLE(un character varying)
    LANGUAGE plpgsql
    AS $$

BEGIN
    RETURN QUERY 
	select recs.un from recs where recs.un = p_un;
END;

$$;


ALTER FUNCTION public.sp_getrecbyun(p_un character varying) OWNER TO postgres;

--
-- TOC entry 220 (class 1255 OID 16661)
-- Name: sp_getrecoverypacket(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getrecoverypacket(p_guid character varying) RETURNS TABLE(vc character varying, ivr character varying, secret character varying, twofactoronlogin integer)
    LANGUAGE plpgsql
    AS $$

BEGIN
	RETURN QUERY
	SELECT account.Vc,account.IVR,account.Secret,account.TwoFactorOnLogin from account where account.WalletId = p_guid;

END;
$$;


ALTER FUNCTION public.sp_getrecoverypacket(p_guid character varying) OWNER TO postgres;

--
-- TOC entry 288 (class 1255 OID 16763)
-- Name: sp_getrsakey(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getrsakey(p_username character varying) RETURNS TABLE(userpublickey character varying)
    LANGUAGE plpgsql
    AS $$

BEGIN
RETURN QUERY
select users.UserPublicKey from users where users.username = p_username;
END;

$$;


ALTER FUNCTION public.sp_getrsakey(p_username character varying) OWNER TO postgres;

--
-- TOC entry 312 (class 1255 OID 16878)
-- Name: sp_gettransactionbyusertransaction(character varying, integer, character); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_gettransactionbyusertransaction(p_transactionid character varying, p_outputindex integer, p_userid character) RETURNS TABLE(userid character)
    LANGUAGE plpgsql
    AS $$

BEGIN

RETURN QUERY
select usertransactions.UserId from usertransactions
where
usertransactions.TransactionId = p_TransactionId and
usertransactions.OutputIndex = p_OutputIndex and
usertransactions.UserId = p_UserId;

END;

$$;


ALTER FUNCTION public.sp_gettransactionbyusertransaction(p_transactionid character varying, p_outputindex integer, p_userid character) OWNER TO postgres;

--
-- TOC entry 294 (class 1255 OID 16768)
-- Name: sp_getusernetworkcategory(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getusernetworkcategory() RETURNS TABLE(categoryid integer, name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	select usernetworkcategory.CategoryId, usernetworkcategory.Name from usernetworkcategory;
END;
$$;


ALTER FUNCTION public.sp_getusernetworkcategory() OWNER TO postgres;

--
-- TOC entry 275 (class 1255 OID 16741)
-- Name: sp_getusernetworkreceive(character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getusernetworkreceive(p_guid character varying, p_status integer) RETURNS TABLE(username character varying, userid character, category character varying, profileimage character varying, status character varying)
    LANGUAGE plpgsql
    AS $$
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
declare v_UserId char(36);BEGIN

select users.UserId into v_UserId from users where users.WalletId = p_guid;
    -- Insert statements for procedure here
RETURN QUERY
select users.username, 
usernetwork.userid, 
usernetwork.Category, 
coalesce(up.ProfileImage,'') as ProfileImage ,
coalesce(up.Status,'I love Ninki!') as Status 
from usernetwork
inner join users on users.userid = usernetwork.useridfriend
left join userprofile up on up.userid = users.userid
where usernetwork.userid = v_UserId and 
usernetwork.status  = p_status;
END;
$$;


ALTER FUNCTION public.sp_getusernetworkreceive(p_guid character varying, p_status integer) OWNER TO postgres;

--
-- TOC entry 276 (class 1255 OID 16744)
-- Name: sp_getusernetworksend(character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getusernetworksend(p_guid character varying, p_status integer) RETURNS TABLE(username character varying, userid character, category character varying, profileimage character varying, status character varying, validationhash character varying)
    LANGUAGE plpgsql
    AS $$

declare v_UserId char(36);

BEGIN

select users.UserId into v_UserId from users where users.WalletId = p_guid;

RETURN QUERY
 select 
 users.username, 
 un1.useridfriend,
 coalesce(un2.category,'') as category,
 coalesce(up.ProfileImage,'') as ProfileImage ,
 coalesce(up.Status,'I love Ninki!') as Status, 
 un1.ValidationHash from UserNetwork un1
inner join usernetwork un2 on un2.UserId = un1.UserIdFriend 
and un2.useridfriend = un1.UserId
inner join users on users.userid = un1.userid
left join userprofile up on up.userid = users.userid
where un1.useridfriend = v_UserId and un1.status = p_status;
END
$$;


ALTER FUNCTION public.sp_getusernetworksend(p_guid character varying, p_status integer) OWNER TO postgres;

--
-- TOC entry 245 (class 1255 OID 16617)
-- Name: sp_getuserpacket(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getuserpacket(p_guid character varying) RETURNS TABLE(userpayload character varying, iv character varying)
    LANGUAGE plpgsql
    AS $$

BEGIN
    RETURN QUERY
	select users.UserPayload, users.IV from users where users.WalletId = p_guid;
END
$$;


ALTER FUNCTION public.sp_getuserpacket(p_guid character varying) OWNER TO postgres;

--
-- TOC entry 244 (class 1255 OID 16606)
-- Name: sp_getuserprofile(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_getuserprofile(p_guid character varying) RETURNS TABLE(profileimage character varying, status character varying, invoicetax numeric, offlinekeybackup integer)
    LANGUAGE plpgsql
    AS $$
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
    -- Insert statements for procedure here
Declare v_UserId char(36);

BEGIN

select UserId into v_UserId from users where WalletId = p_guid;
RETURN QUERY
select userprofile.ProfileImage, userprofile.Status, userprofile.InvoiceTax, userprofile.OfflineKeyBackup from userprofile where userprofile.UserId = v_UserId;
END;
$$;


ALTER FUNCTION public.sp_getuserprofile(p_guid character varying) OWNER TO postgres;

--
-- TOC entry 237 (class 1255 OID 16565)
-- Name: sp_iscallervalid(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_iscallervalid(p_guid character varying, p_sharedid character varying) RETURNS TABLE(walletid character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
    RETURN QUERY 
	select account.walletid from account where account.walletid = p_guid and usertoken = p_sharedid;
END;
$$;


ALTER FUNCTION public.sp_iscallervalid(p_guid character varying, p_sharedid character varying) OWNER TO postgres;

--
-- TOC entry 281 (class 1255 OID 16870)
-- Name: sp_keycachebyaccount(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_keycachebyaccount(p_guid character varying, p_nodelevel character varying) RETURNS TABLE(ninkiderivedprivatekey character varying, ninkiderivedpublickey character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
    RETURN QUERY
	select 
    nodekeycache.NinkiDerivedPrivateKey, 
    nodekeycache.NinkiDerivedPublicKey 
    from nodekeycache 
    where nodekeycache.WalletId = p_guid 
    and nodekeycache.NodeLevel = p_nodelevel;
END;
$$;


ALTER FUNCTION public.sp_keycachebyaccount(p_guid character varying, p_nodelevel character varying) OWNER TO postgres;

--
-- TOC entry 321 (class 1255 OID 16841)
-- Name: sp_nodeforfriend(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_nodeforfriend(p_guid character varying, p_username character varying) RETURNS TABLE(nodelevel character varying, walletid character varying)
    LANGUAGE plpgsql
    AS $$

declare v_userid char(36);
 v_useridFriend char(36);
 v_nodeLevel varchar(50);
 v_walletId varchar(64);
BEGIN

select users.UserId into v_userid from users where users.WalletId = p_guid;
select users.UserId, users.WalletId into v_useridFriend, v_walletId from users where username = p_username;
select usernetwork.NodeLevel into v_nodeLevel from usernetwork where UseridFriend = v_userid and Userid = v_useridFriend;

RETURN QUERY
select v_nodeLevel, v_walletId;

END;

$$;


ALTER FUNCTION public.sp_nodeforfriend(p_guid character varying, p_username character varying) OWNER TO postgres;

--
-- TOC entry 253 (class 1255 OID 16662)
-- Name: sp_payloadbyaccount(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_payloadbyaccount(p_guid character varying) RETURNS TABLE(payload character varying, twofactoronlogin integer, iv character varying, secret character varying, vc character varying, locked integer)
    LANGUAGE plpgsql
    AS $$

BEGIN
	RETURN QUERY
	select account.Payload, account.TwoFactorOnLogin, account.IV, account.Secret, account.Vc, account.Locked from account where account.WalletId = p_guid;
END;

$$;


ALTER FUNCTION public.sp_payloadbyaccount(p_guid character varying) OWNER TO postgres;

--
-- TOC entry 249 (class 1255 OID 16646)
-- Name: sp_pubkeybyaccount(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_pubkeybyaccount(p_guid character varying) RETURNS TABLE(hotmasterpublickey character varying, coldmasterpublickey character varying, ninkimasterpublickey character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	select account.HotMasterPublicKey, account.ColdMasterPublicKey, account.NinkiMasterPublicKey from account where account.WalletId = p_guid;
END;
$$;


ALTER FUNCTION public.sp_pubkeybyaccount(p_guid character varying) OWNER TO postgres;

--
-- TOC entry 268 (class 1255 OID 16826)
-- Name: sp_removeaccountsecpub(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_removeaccountsecpub(p_guid character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
 	Declare v_UserId char(36);
    Declare v_profUserId char(36);



    
    BEGIN
UPDATE AccountSecPub
   SET SecretPub = null
      ,UpdateDate = NOW()
 WHERE WalletId = p_guid;
	select UserId into v_UserId from Users where WalletId = p_guid;



	select UserId into v_profUserId from UserProfile where UserId = v_UserId;
	if v_profUserId  is null
	then
	insert into UserProfile (UserId, OfflineKeyBackup) values(v_UserId,1);
	else
	update UserProfile Set OfflineKeyBackup = 1 where UserId = v_UserId;
	end if;

END;
$$;


ALTER FUNCTION public.sp_removeaccountsecpub(p_guid character varying) OWNER TO postgres;

--
-- TOC entry 320 (class 1255 OID 16879)
-- Name: sp_setoutputspending(character varying, integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_setoutputspending(p_transactionid character varying, p_index integer, p_mastertransactionid character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	declare v_transys integer;
BEGIN

	
	select TranSysId into v_transys from Trans where TransactionId = p_transactionId;
    -- Insert statements for procedure here
	update TranOutputs set IsPending = 1 where TranSysId = v_transys and OutputIndex = p_index;
	update TranOutputs_NonCon set IsSpent = 1 where TransactionId = p_transactionId and OutputIndex = p_index;
	insert into TranInputsNonCon values (p_masterTransactionId, p_transactionId, p_index);
	
END;

$$;


ALTER FUNCTION public.sp_setoutputspending(p_transactionid character varying, p_index integer, p_mastertransactionid character varying) OWNER TO postgres;

--
-- TOC entry 264 (class 1255 OID 16729)
-- Name: sp_timelinebyuser(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_timelinebyuser(p_guid character varying) RETURNS TABLE(timelinetype character varying, transactionid character varying, username character varying, invoiceid integer, timelinedate timestamp without time zone, amount bigint, blocknumber integer, profileimage character varying, invoicestatus integer, invoicestatusr integer)
    LANGUAGE plpgsql
    AS $$
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

declare v_userid char(36);
 v_myUserName varchar(100);
BEGIN

select users.UserId, users.UserName into v_userid, v_myUserName from users where users.WalletId = p_guid;

RETURN QUERY
SELECT usertimeline.TimelineType
      ,usertimeline.TransactionId
      ,usertimeline.UserName
      ,usertimeline.InvoiceId
      ,usertimeline.TimelineDate
      ,usertransactions.Amount
      ,usertransactions.BlockNumber
      ,userprofile.ProfileImage
      ,userinvoices.InvoiceStatus
      ,u2.InvoiceStatus as InvoiceStatusR
  FROM usertimeline
  Left Join usertransactions on usertransactions.TransactionId = usertransactions.TransactionId and usertransactions.UserId = usertimeline.UserId
  Left Join userinvoices on userinvoices.InvoiceId = usertimeline.InvoiceId and userinvoices.UserId = usertimeline.UserId and usertimeline.TimelineType = 'IS'
  left join users on users.Username = usertimeline.UserName
  Left Join userinvoices u2 on u2.InvoiceId = usertimeline.InvoiceId and u2.UserId = users.UserId and usertimeline.TimelineType = 'IR'
  left join userprofile on userprofile.UserId = users.UserId
  Where usertimeline.UserId = v_userid and (usertimeline.TransactionId is null or (usertransactions.Status <> 4 and (not (usertransactions.BlockNumber = 0 and usertransactions.Status = 3 and usertransactions.TransType = 'R'))))

  order by usertimeline.TimelineDate desc;
  END;
$$;


ALTER FUNCTION public.sp_timelinebyuser(p_guid character varying) OWNER TO postgres;

--
-- TOC entry 272 (class 1255 OID 16862)
-- Name: sp_transactionsendafterdate(character, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_transactionsendafterdate(p_userid character, p_transdatetime timestamp without time zone) RETURNS TABLE(amount bigint, transdatetime timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	select usertransactions.Amount, usertransactions.TransDateTime from usertransactions where usertransactions.UserId = p_userid and usertransactions.TransType = 'S' and usertransactions.TransDateTime > p_TransDateTime;
END;
$$;


ALTER FUNCTION public.sp_transactionsendafterdate(p_userid character, p_transdatetime timestamp without time zone) OWNER TO postgres;

--
-- TOC entry 265 (class 1255 OID 16730)
-- Name: sp_transactionsforfeed(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_transactionsforfeed(p_guid character varying) RETURNS TABLE(transactionid character varying, outputindex integer, transdatetime timestamp without time zone, amount bigint, address character varying, username character varying, transtype character varying, status integer, blocknumber integer, invoiceid integer, profileimage character varying, minersfee bigint)
    LANGUAGE plpgsql
    AS $$

  declare v_userid char(36);
  
  BEGIN

  select users.UserId into v_userid from users where users.WalletId = p_guid;
      
  RETURN QUERY
  select usertransactions.TransactionId, 
  usertransactions.OutputIndex, 
  usertransactions.TransDateTime, 
  usertransactions.Amount, 
  usertransactions.Address, 
  usertransactions.UserName, 
  usertransactions.TransType, 
  usertransactions.Status, 
  usertransactions.BlockNumber, 
  userinvoices.InvoiceId, 
  userprofile.ProfileImage,
  usertransactions.MinersFee
  from usertransactions
  left join userinvoices on userinvoices.TransactionId = usertransactions.TransactionId
  left join users on users.UserName = usertransactions.UserName
  left join userprofile on userprofile.UserId = users.UserId
  where usertransactions.UserId = v_userid
  order by usertransactions.TransDateTime desc;

END;
  $$;


ALTER FUNCTION public.sp_transactionsforfeed(p_guid character varying) OWNER TO postgres;

--
-- TOC entry 301 (class 1255 OID 16773)
-- Name: sp_transactionsfornetwork(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_transactionsfornetwork(p_guid character varying, p_username character varying) RETURNS TABLE(transactionid character varying, outputindex integer, transdatetime timestamp without time zone, amount bigint, address character varying, username character varying, transtype character varying, status integer, blocknumber integer, invoiceid integer, minersfee bigint)
    LANGUAGE plpgsql
    AS $$

declare v_userid char(36);

BEGIN

select users.UserId into v_userid from users where users.WalletId = p_guid;
    -- Insert statements for procedure here
RETURN QUERY
select  usertransactions.TransactionId, 
usertransactions.OutputIndex, 
usertransactions.TransDateTime, 
usertransactions.Amount, 
usertransactions.Address, 
usertransactions.UserName, 
usertransactions.TransType, 
usertransactions.Status, 
usertransactions.BlockNumber, 
userinvoices.InvoiceId, 
usertransactions.MinersFee
from usertransactions
left join userinvoices on userinvoices.TransactionId = usertransactions.TransactionId
where usertransactions.UserId = v_userid and usertransactions.UserName = p_username
order by usertransactions.TransDateTime desc;

END;

$$;


ALTER FUNCTION public.sp_transactionsfornetwork(p_guid character varying, p_username character varying) OWNER TO postgres;

--
-- TOC entry 311 (class 1255 OID 16868)
-- Name: sp_unspentnonconoutputforinput(character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_unspentnonconoutputforinput(p_transactionid character varying, p_outputindex integer) RETURNS TABLE(amount numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN


    RETURN QUERY
	select  tranoutputs_noncon.Amount 
    from tranoutputs_noncon  
    where tranoutputs_noncon.TransactionId = p_TransactionId 
    and tranoutputs_noncon.OutputIndex = p_outputIndex  and tranoutputs_noncon.IsSpent = 0;
END;
$$;


ALTER FUNCTION public.sp_unspentnonconoutputforinput(p_transactionid character varying, p_outputindex integer) OWNER TO postgres;

--
-- TOC entry 309 (class 1255 OID 16865)
-- Name: sp_unspentnonconoutputsforaddress(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_unspentnonconoutputsforaddress(p_address character varying) RETURNS TABLE(transactionid character varying, outputindex integer, amount numeric, address character varying, pending integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	select  tranoutputs_noncon.TransactionId, 
    tranoutputs_noncon.OutputIndex, 
    tranoutputs_noncon.Amount, tranoutputs_noncon.Address,0 
    from tranoutputs_noncon  
    where tranoutputs_noncon.Address = p_address 
    and tranoutputs_noncon.isspent <> 1;
END;
$$;


ALTER FUNCTION public.sp_unspentnonconoutputsforaddress(p_address character varying) OWNER TO postgres;

--
-- TOC entry 279 (class 1255 OID 16867)
-- Name: sp_unspentoutputforinput(character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_unspentoutputforinput(p_transactionid character varying, p_outputindex integer) RETURNS TABLE(amount numeric)
    LANGUAGE plpgsql
    AS $$

BEGIN

	RETURN QUERY
	select  tranoutputs.Amount 
    from tranoutputs 
    inner join trans 
    on trans.TranSysId = tranoutputs.TranSysId 
    where trans.TransactionId = p_TransactionId 
    and tranoutputs.OutputIndex = p_outputIndex  
    and tranoutputs.IsSpent = 0;
END;

$$;


ALTER FUNCTION public.sp_unspentoutputforinput(p_transactionid character varying, p_outputindex integer) OWNER TO postgres;

--
-- TOC entry 308 (class 1255 OID 16864)
-- Name: sp_unspentoutputsforaddress(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_unspentoutputsforaddress(p_address character varying) RETURNS TABLE(transactionid character varying, outputindex integer, amount numeric, address character varying, ispending integer)
    LANGUAGE plpgsql
    AS $$

BEGIN
	RETURN QUERY
	select trans.TransactionId, 
    		tranoutputs.OutputIndex, 
            tranoutputs.Amount, 
            tranoutputs.Address,
            tranoutputs.IsPending 
    from tranoutputs 
    inner join trans on trans.TranSysId = tranoutputs.TranSysId  where tranoutputs.Address = p_address and tranoutputs.IsSpent = 0;
END;

$$;


ALTER FUNCTION public.sp_unspentoutputsforaddress(p_address character varying) OWNER TO postgres;

--
-- TOC entry 314 (class 1255 OID 16792)
-- Name: sp_updateaccountsettings(character varying, integer, integer, boolean, character varying, boolean, character varying, boolean, boolean, character varying, bigint, bigint, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_updateaccountsettings(p_walletid character varying, p_inactivity integer, p_minersfee integer, p_autoemailbackup boolean, p_email character varying, p_phoneverified boolean, p_coinunit character varying, p_emailnotification boolean, p_phonenotification boolean, p_localcurrency character varying, p_dailytransactionlimit bigint, p_singletransactionlimit bigint, p_nooftransactionsperday integer, p_nooftransactionsperhour integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
update AccountSettings set Inactivity = p_Inactivity,MinersFee = p_MinersFee,AutoEmailBackup = p_AutoEmailBackup,PhoneVerified = p_PhoneVerified,CoinUnit = p_CoinUnit,EmailNotification = p_EmailNotification,PhoneNotification = p_PhoneNotification,LocalCurrency = p_LocalCurrency, DailyTransactionLimit = p_DailyTransactionLimit,SingleTransactionLimit = p_SingleTransactionLimit,NoOfTransactionsPerDay = p_NoOfTransactionsPerDay,NoOfTransactionsPerHour = p_NoOfTransactionsPerHour where WalletId = p_WalletId;
END;
$$;


ALTER FUNCTION public.sp_updateaccountsettings(p_walletid character varying, p_inactivity integer, p_minersfee integer, p_autoemailbackup boolean, p_email character varying, p_phoneverified boolean, p_coinunit character varying, p_emailnotification boolean, p_phonenotification boolean, p_localcurrency character varying, p_dailytransactionlimit bigint, p_singletransactionlimit bigint, p_nooftransactionsperday integer, p_nooftransactionsperhour integer) OWNER TO postgres;

--
-- TOC entry 315 (class 1255 OID 16793)
-- Name: sp_updateaccountsettings(character varying, integer, integer, integer, character varying, integer, character varying, integer, integer, character varying, bigint, bigint, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_updateaccountsettings(p_walletid character varying, p_inactivity integer, p_minersfee integer, p_autoemailbackup integer, p_email character varying, p_phoneverified integer, p_coinunit character varying, p_emailnotification integer, p_phonenotification integer, p_localcurrency character varying, p_dailytransactionlimit bigint, p_singletransactionlimit bigint, p_nooftransactionsperday integer, p_nooftransactionsperhour integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
update AccountSettings set Inactivity = p_Inactivity,MinersFee = p_MinersFee,AutoEmailBackup = p_AutoEmailBackup,PhoneVerified = p_PhoneVerified,CoinUnit = p_CoinUnit,EmailNotification = p_EmailNotification,PhoneNotification = p_PhoneNotification,LocalCurrency = p_LocalCurrency, DailyTransactionLimit = p_DailyTransactionLimit,SingleTransactionLimit = p_SingleTransactionLimit,NoOfTransactionsPerDay = p_NoOfTransactionsPerDay,NoOfTransactionsPerHour = p_NoOfTransactionsPerHour where WalletId = p_WalletId;
END;
$$;


ALTER FUNCTION public.sp_updateaccountsettings(p_walletid character varying, p_inactivity integer, p_minersfee integer, p_autoemailbackup integer, p_email character varying, p_phoneverified integer, p_coinunit character varying, p_emailnotification integer, p_phonenotification integer, p_localcurrency character varying, p_dailytransactionlimit bigint, p_singletransactionlimit bigint, p_nooftransactionsperday integer, p_nooftransactionsperhour integer) OWNER TO postgres;

--
-- TOC entry 242 (class 1255 OID 16562)
-- Name: sp_updateaccountsettingsemail(character varying, character varying, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_updateaccountsettingsemail(p_walletid character varying, p_email character varying, p_emailverified boolean) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN

update AccountSettings set Email = p_Email,EmailVerified = p_EmailVerified where WalletId = p_WalletId;

END;
$$;


ALTER FUNCTION public.sp_updateaccountsettingsemail(p_walletid character varying, p_email character varying, p_emailverified boolean) OWNER TO postgres;

--
-- TOC entry 219 (class 1255 OID 16580)
-- Name: sp_updateaccountsettingsemail(character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_updateaccountsettingsemail(p_walletid character varying, p_email character varying, p_emailverified integer) RETURNS void
    LANGUAGE plpgsql
    AS $$

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
update AccountSettings set Email = p_Email,EmailVerified = p_EmailVerified where WalletId = p_WalletId;

END;

$$;


ALTER FUNCTION public.sp_updateaccountsettingsemail(p_walletid character varying, p_email character varying, p_emailverified integer) OWNER TO postgres;

--
-- TOC entry 261 (class 1255 OID 16819)
-- Name: sp_updatedevice(character varying, character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_updatedevice(p_guid character varying, p_devicename character varying, p_deviceid character varying, p_devicemodel character varying, p_devicepin character varying, p_regtoken character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
	update AccountDevice set DeviceId = p_deviceId, DeviceModel = p_deviceModel, DevicePIN = p_devicePIN where WalletId = p_guid and DeviceName = p_deviceName and RegToken = p_RegToken and DevicePIN is null;
END;
$$;


ALTER FUNCTION public.sp_updatedevice(p_guid character varying, p_devicename character varying, p_deviceid character varying, p_devicemodel character varying, p_devicepin character varying, p_regtoken character varying) OWNER TO postgres;

--
-- TOC entry 317 (class 1255 OID 16795)
-- Name: sp_updatedevicetoken(character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_updatedevicetoken(p_guid character varying, p_devicename character varying, p_devicekey character varying, p_twofactortoken character varying, p_regtoken character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
	update AccountDevice set DevicePIN = null, DeviceId = null, DeviceModel = null, DeviceKey = p_deviceKey, TwoFactorToken = p_TwoFactorToken, RegToken = p_RegToken, KeyDate = NOW()  where WalletId = p_guid and DeviceName = p_deviceName;
    

END;
$$;


ALTER FUNCTION public.sp_updatedevicetoken(p_guid character varying, p_devicename character varying, p_devicekey character varying, p_twofactortoken character varying, p_regtoken character varying) OWNER TO postgres;

--
-- TOC entry 250 (class 1255 OID 16645)
-- Name: sp_updateemailverified(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_updateemailverified(p_emailvalidationtoken character varying, p_walletid character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	declare v_GoogleAuthSecret varchar(1000);
BEGIN

	select GoogleAuthSecret into v_GoogleAuthSecret from account where WalletId = p_WalletId;
	update EmailToken set IsUsed = 1 where emailvalidationtoken = p_EmailValidationToken;
	update AccountSettings set EmailVerified = 1 where WalletId = p_WalletId;
	if  v_GoogleAuthSecret is not null
	then
		update Account set TwoFactorOnLogin = 1 where WalletId = p_WalletId;
	end if;

END;

$$;


ALTER FUNCTION public.sp_updateemailverified(p_emailvalidationtoken character varying, p_walletid character varying) OWNER TO postgres;

--
-- TOC entry 257 (class 1255 OID 16811)
-- Name: sp_updateexistingtwofactor(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_updateexistingtwofactor(p_guid character varying, p_googleauthsecret character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
	update Account set GoogleAuthSecret = p_googleAuthSecret where WalletId = p_guid;

	if length(p_googleAuthSecret) > 0
	then
	update AccountSettings set TwoFactorType = 'GOOG'  where WalletId = p_guid;
	end if;

END;
$$;


ALTER FUNCTION public.sp_updateexistingtwofactor(p_guid character varying, p_googleauthsecret character varying) OWNER TO postgres;

--
-- TOC entry 290 (class 1255 OID 16770)
-- Name: sp_updatefriend(character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_updatefriend(p_guid character varying, p_username character varying, p_addressset character varying, p_validationhash character varying) RETURNS TABLE(friendwalletid character varying)
    LANGUAGE plpgsql
    AS $$
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
    declare v_UserId char(36);
    v_UserIdFriend char(36);
    v_FriendWalletId varchar(64);
BEGIN

    select users.UserId into v_UserId from users where users.WalletId = p_guid;
    select users.UserId, users.WalletId into v_UserIdFriend, v_FriendWalletId  from users where users.username = p_username;
	update UserNetwork set AddressSet = p_AddressSet, Status = 1, ValidationHash = p_ValidationHash, Notify = 1, UpdatedDate = NOW() where userid = v_UserIdFriend and UserIdFriend = v_UserId;
	RETURN QUERY
    select v_FriendWalletId;

END;
$$;


ALTER FUNCTION public.sp_updatefriend(p_guid character varying, p_username character varying, p_addressset character varying, p_validationhash character varying) OWNER TO postgres;

--
-- TOC entry 307 (class 1255 OID 16788)
-- Name: sp_updateinvoice(character varying, integer, integer, timestamp without time zone, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_updateinvoice(p_username character varying, p_invoiceid integer, p_invoicestatus integer, p_invoicepaiddate timestamp without time zone, p_transactionid character varying) RETURNS TABLE(walletid character varying, username character varying)
    LANGUAGE plpgsql
    AS $$
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
    declare v_UserId char(36);
    v_myUserName varchar(100);
    v_WalletId varchar(64);
BEGIN

    select users.UserId, users.WalletId into v_UserId, v_WalletId from users where users.UserName = p_userName;
	update UserInvoices set InvoiceStatus = p_InvoiceStatus, InvoicePaidDate = p_InvoicePaidDate, TransactionId = p_TransactionId where UserId = v_UserId and InvoiceId = p_InvoiceId;

	update usertimeline set TimelineDate = now() where usertimeline.UserId = v_UserId and usertimeline.InvoiceId = p_InvoiceId;
	update usertimeline set TimelineDate = now() where usertimeline.UserName = p_userName  and usertimeline.InvoiceId = p_InvoiceId;
	RETURN QUERY
	select v_WalletId,userinvoices.UserName from userinvoices where userinvoices.UserId = v_UserId and userinvoices.InvoiceId = p_InvoiceId;
END;
$$;


ALTER FUNCTION public.sp_updateinvoice(p_username character varying, p_invoiceid integer, p_invoicestatus integer, p_invoicepaiddate timestamp without time zone, p_transactionid character varying) OWNER TO postgres;

--
-- TOC entry 318 (class 1255 OID 16796)
-- Name: sp_updatepackets(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_updatepackets(p_guid character varying, p_payload character varying, p_userpayload character varying, p_vc character varying, p_recpacket character varying, p_iva character varying, p_ivu character varying, p_ivr character varying, p_recpacketiv character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.


	update Account set Payload = p_payload, IV = p_IVA, Vc = p_Vc, IVR = p_IVR, RecPacket = p_RecPacket,RecPacketIV = p_RecPacketIV where WalletId = p_guid;
	update Users set UserPayload = p_userpayload, IV = p_IVU where WalletId = p_guid;

END;
$$;


ALTER FUNCTION public.sp_updatepackets(p_guid character varying, p_payload character varying, p_userpayload character varying, p_vc character varying, p_recpacket character varying, p_iva character varying, p_ivu character varying, p_ivr character varying, p_recpacketiv character varying) OWNER TO postgres;

--
-- TOC entry 277 (class 1255 OID 16828)
-- Name: sp_updaterecemail(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_updaterecemail(p_pk character varying, p_em character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$



BEGIN

	update recs set Em = p_em where Pk = p_pk;

END;

$$;


ALTER FUNCTION public.sp_updaterecemail(p_pk character varying, p_em character varying) OWNER TO postgres;

--
-- TOC entry 241 (class 1255 OID 16593)
-- Name: sp_updatetwofactor(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_updatetwofactor(p_guid character varying, p_googleauthsecret character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
	update Account set GoogleAuthSecret = p_googleAuthSecret, TwoFactorOnLogin = 1 where WalletId = p_guid
	and (TwoFactorOnLogin = 0 or TwoFactorOnLogin is null);

	if length(p_googleAuthSecret) > 0
	then
	update AccountSettings set TwoFactor = 1,  TwoFactorType = 'GOOG'  where WalletId = p_guid;
	end if;

END;

$$;


ALTER FUNCTION public.sp_updatetwofactor(p_guid character varying, p_googleauthsecret character varying) OWNER TO postgres;

--
-- TOC entry 243 (class 1255 OID 16592)
-- Name: sp_updatetwofactorsecret(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_updatetwofactorsecret(p_guid character varying, p_googleauthsecret character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
	update Account set GoogleAuthSecret = p_googleAuthSecret where WalletId = p_guid
	and (GoogleAuthSecret is null or TwoFactorOnLogin is null or TwoFactorOnLogin = 0);

	if length(p_googleAuthSecret) > 0 then
	update AccountSettings set TwoFactorType = 'GOOG'  where WalletId = p_guid;
	end if;

END;

$$;


ALTER FUNCTION public.sp_updatetwofactorsecret(p_guid character varying, p_googleauthsecret character varying) OWNER TO postgres;

--
-- TOC entry 322 (class 1255 OID 16933)
-- Name: sp_userdetailsbyusername(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_userdetailsbyusername(p_username character varying) RETURNS TABLE(userid character, walletid character varying, userpublickey character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	select users.UserId, users.WalletId, users.UserPublicKey from users where users.username = p_username;
END;
$$;


ALTER FUNCTION public.sp_userdetailsbyusername(p_username character varying) OWNER TO postgres;

--
-- TOC entry 271 (class 1255 OID 16861)
-- Name: sp_useridbyaccount(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_useridbyaccount(p_guid character varying) RETURNS TABLE(userid character, username character varying)
    LANGUAGE plpgsql
    AS $$

BEGIN
	RETURN QUERY
	select users.UserId, users.UserName from users where users.WalletId = p_guid;

END;

$$;


ALTER FUNCTION public.sp_useridbyaccount(p_guid character varying) OWNER TO postgres;

--
-- TOC entry 324 (class 1255 OID 16935)
-- Name: sp_validationhashforfriend(character, character); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_validationhashforfriend(p_userid character, p_useridfriend character) RETURNS TABLE(validationhash character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	select usernetwork.ValidationHash from usernetwork where usernetwork.UserId = p_UserId and usernetwork.UserIdFriend = p_UserIdFriend;
END;
$$;


ALTER FUNCTION public.sp_validationhashforfriend(p_userid character, p_useridfriend character) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 205 (class 1259 OID 16549)
-- Name: account; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE account (
    walletid character varying(64) NOT NULL,
    payload character varying(2000),
    ninkimasterprivatekey character varying(1000) NOT NULL,
    ninkimasterpublickey character varying(1000),
    hotmasterpublickey character varying(1000),
    coldmasterpublickey character varying(1000),
    usertoken character varying(1000),
    twofactoronlogin integer,
    googleauthsecret character varying(1000),
    iv character varying(300),
    vc character varying(2000),
    ivr character varying(300),
    secret character varying(300),
    recpacket character varying(2000),
    recpacketiv character varying(300),
    locked integer
);


ALTER TABLE account OWNER TO postgres;

--
-- TOC entry 185 (class 1259 OID 16394)
-- Name: accountaddress; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE accountaddress (
    walletid character varying(64) NOT NULL,
    nodelevel character varying(50) NOT NULL,
    refaddress character varying(255) NOT NULL,
    nodebranch character varying(50),
    nodeleaf integer,
    pk1 character varying(300),
    pk2 character varying(300),
    pk3 character varying(300),
    isactive integer
);


ALTER TABLE accountaddress OWNER TO postgres;

--
-- TOC entry 186 (class 1259 OID 16402)
-- Name: accountbackupcode; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE accountbackupcode (
    walletid character varying(64) NOT NULL,
    backupset integer NOT NULL,
    backupindex integer NOT NULL,
    backupcode character varying(1000) NOT NULL,
    used integer NOT NULL,
    dateused timestamp(3) without time zone NOT NULL
);


ALTER TABLE accountbackupcode OWNER TO postgres;

--
-- TOC entry 187 (class 1259 OID 16410)
-- Name: accountdevice; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE accountdevice (
    walletid character varying(64) NOT NULL,
    devicename character varying(50) NOT NULL,
    deviceid character varying(50),
    devicemodel character varying(100),
    devicepin character varying(64),
    devicekey character varying(1000),
    twofactortoken character varying(64),
    regtoken character varying(64),
    keydate timestamp(3) without time zone
);


ALTER TABLE accountdevice OWNER TO postgres;

--
-- TOC entry 188 (class 1259 OID 16418)
-- Name: accountlog_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE accountlog_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE accountlog_seq OWNER TO postgres;

--
-- TOC entry 189 (class 1259 OID 16420)
-- Name: accountlog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE accountlog (
    logid bigint DEFAULT nextval('accountlog_seq'::regclass) NOT NULL,
    walletid character varying(64) NOT NULL,
    logdate timestamp(3) without time zone NOT NULL,
    success integer NOT NULL,
    logtype character varying(50) NOT NULL
);


ALTER TABLE accountlog OWNER TO postgres;

--
-- TOC entry 190 (class 1259 OID 16426)
-- Name: accountsecpub; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE accountsecpub (
    walletid character varying(64) NOT NULL,
    secretpub character varying(2000),
    createdate timestamp(3) without time zone NOT NULL,
    updatedate timestamp(3) without time zone NOT NULL
);


ALTER TABLE accountsecpub OWNER TO postgres;

--
-- TOC entry 206 (class 1259 OID 16572)
-- Name: accountsettings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE accountsettings (
    walletid character varying(64) NOT NULL,
    inactivity integer,
    minersfee integer,
    autoemailbackup integer,
    email character varying(100),
    emailverified integer,
    phone character varying(50),
    phoneverified integer,
    language character varying(50),
    localcurrency character varying(50),
    coinunit character varying(50),
    emailnotification integer,
    phonenotification integer,
    passwordhint character varying(300),
    twofactor integer,
    twofactortype character varying(50),
    dailytransactionlimit bigint,
    singletransactionlimit bigint,
    nooftransactionsperday integer,
    nooftransactionsperhour integer
);


ALTER TABLE accountsettings OWNER TO postgres;

--
-- TOC entry 191 (class 1259 OID 16442)
-- Name: accounttransactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE accounttransactions (
    walletid character varying(64) NOT NULL,
    transactionid character varying(128) NOT NULL,
    transdatetime timestamp(6) without time zone NOT NULL,
    totalamount bigint NOT NULL,
    sendtoaddress character varying(50),
    status integer NOT NULL,
    blocknumber integer
);


ALTER TABLE accounttransactions OWNER TO postgres;

--
-- TOC entry 208 (class 1259 OID 16666)
-- Name: block; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE block (
    blocknumber integer NOT NULL,
    blockhash character varying(64) NOT NULL,
    prevhash character varying(64) NOT NULL,
    "timestamp" integer NOT NULL
);


ALTER TABLE block OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 16582)
-- Name: emailtoken; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE emailtoken (
    emailvalidationtoken character varying(64) NOT NULL,
    walletid character varying(64) NOT NULL,
    emailaddress character varying(100) NOT NULL,
    expirydate timestamp(3) without time zone NOT NULL,
    isused integer NOT NULL,
    tokentype integer
);


ALTER TABLE emailtoken OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 16671)
-- Name: fees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE fees (
    feeid integer NOT NULL,
    low bigint NOT NULL,
    med bigint NOT NULL,
    high bigint NOT NULL
);


ALTER TABLE fees OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 16676)
-- Name: lastread; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE lastread (
    id integer NOT NULL,
    transactionid character varying(128) NOT NULL,
    blockfile character varying(50) NOT NULL,
    blockindex integer NOT NULL,
    bytesread bigint,
    runningblockindex integer,
    lastupddate timestamp(3) without time zone
);


ALTER TABLE lastread OWNER TO postgres;

--
-- TOC entry 192 (class 1259 OID 16452)
-- Name: nodekeycache; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE nodekeycache (
    walletid character varying(64) NOT NULL,
    nodelevel character varying(50) NOT NULL,
    ninkiderivedpublickey character varying(1000) NOT NULL,
    ninkiderivedprivatekey character varying(1000) NOT NULL
);


ALTER TABLE nodekeycache OWNER TO postgres;

--
-- TOC entry 203 (class 1259 OID 16523)
-- Name: recs_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE recs_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE recs_seq OWNER TO postgres;

--
-- TOC entry 204 (class 1259 OID 16525)
-- Name: recs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE recs (
    id bigint DEFAULT nextval('recs_seq'::regclass) NOT NULL,
    pk character varying(2000) NOT NULL,
    un character varying(50) NOT NULL,
    em character varying(100),
    ph character varying(100),
    vc character varying(2000),
    iv character varying(300),
    pkh character varying(128),
    mpkh character varying(128),
    createdate timestamp(3) without time zone NOT NULL
);


ALTER TABLE recs OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 16681)
-- Name: traninputs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE traninputs (
    transysid integer NOT NULL,
    inputindex integer NOT NULL,
    rawstring text,
    prevtransactionid character varying(128) NOT NULL,
    prevtransoutputindex integer NOT NULL
);


ALTER TABLE traninputs OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 16689)
-- Name: traninputsnoncon; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE traninputsnoncon (
    transactionid character varying(128) NOT NULL,
    prevtransactionid character varying(128) NOT NULL,
    prevtransoutputindex integer NOT NULL
);


ALTER TABLE traninputsnoncon OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16853)
-- Name: tranoutputs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE tranoutputs (
    transysid integer NOT NULL,
    outputindex integer NOT NULL,
    rawstring text,
    amount numeric(32,2) NOT NULL,
    address character varying(128) NOT NULL,
    isspent integer,
    ispending integer
);


ALTER TABLE tranoutputs OWNER TO postgres;

--
-- TOC entry 213 (class 1259 OID 16700)
-- Name: tranoutputs_noncon; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE tranoutputs_noncon (
    transactionid character varying(128) NOT NULL,
    outputindex integer NOT NULL,
    amount numeric(32,2) NOT NULL,
    address character varying(128) NOT NULL,
    isspent integer
);


ALTER TABLE tranoutputs_noncon OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 16705)
-- Name: trans_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE trans_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE trans_seq OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 16707)
-- Name: trans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE trans (
    transysid integer DEFAULT nextval('trans_seq'::regclass) NOT NULL,
    transactionid character varying(128) NOT NULL,
    rawstring text,
    blockdate timestamp(3) without time zone NOT NULL,
    blockfile character varying(50) NOT NULL,
    blockindex integer NOT NULL,
    blockbytestart integer NOT NULL,
    isspent boolean,
    blocknumber integer NOT NULL,
    blockhash character varying(128)
);


ALTER TABLE trans OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 16716)
-- Name: transnoncon; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE transnoncon (
    transactionid character varying(128) NOT NULL,
    datecreated timestamp(3) without time zone NOT NULL
);


ALTER TABLE transnoncon OWNER TO postgres;

--
-- TOC entry 193 (class 1259 OID 16460)
-- Name: userinvoices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE userinvoices (
    userid character(36) NOT NULL,
    invoiceid integer NOT NULL,
    username character varying(50) NOT NULL,
    invoicedate timestamp(3) without time zone NOT NULL,
    invoicestatus integer NOT NULL,
    invoicepaiddate timestamp(3) without time zone,
    transactionid character varying(128),
    packetforme text NOT NULL,
    packetforthem text NOT NULL
);


ALTER TABLE userinvoices OWNER TO postgres;

--
-- TOC entry 194 (class 1259 OID 16468)
-- Name: usermessage; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE usermessage (
    userid character(36) NOT NULL,
    messageid integer NOT NULL,
    username character varying(50) NOT NULL,
    packetforme text NOT NULL,
    packetforthem text NOT NULL,
    createdate timestamp(3) without time zone NOT NULL,
    transactionid character varying(128),
    invoiceuserid character(36),
    invoiceid integer
);


ALTER TABLE usermessage OWNER TO postgres;

--
-- TOC entry 195 (class 1259 OID 16476)
-- Name: usernetwork; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE usernetwork (
    userid character(36) NOT NULL,
    useridfriend character(36) NOT NULL,
    nodelevel character varying(50) NOT NULL,
    nodebranch character varying(50) NOT NULL,
    nodeleaf integer NOT NULL,
    packetforfriend character varying(2000),
    status integer,
    addressset character varying(5000),
    validationhash character varying(256),
    category character varying(50),
    notify integer,
    createdate timestamp(3) without time zone,
    updateddate timestamp(3) without time zone
);


ALTER TABLE usernetwork OWNER TO postgres;

--
-- TOC entry 196 (class 1259 OID 16484)
-- Name: usernetworkcategory_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE usernetworkcategory_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE usernetworkcategory_seq OWNER TO postgres;

--
-- TOC entry 197 (class 1259 OID 16486)
-- Name: usernetworkcategory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE usernetworkcategory (
    categoryid integer DEFAULT nextval('usernetworkcategory_seq'::regclass) NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE usernetworkcategory OWNER TO postgres;

--
-- TOC entry 198 (class 1259 OID 16492)
-- Name: userprofile; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE userprofile (
    userid character(36) NOT NULL,
    profileimage character varying(50),
    status character varying(50),
    invoicetax numeric(9,2),
    offlinekeybackup integer,
    seclevel integer
);


ALTER TABLE userprofile OWNER TO postgres;

--
-- TOC entry 199 (class 1259 OID 16497)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE users (
    userid character(36) NOT NULL,
    walletid character varying(64) NOT NULL,
    username character varying(50) NOT NULL,
    firstname character varying(100),
    lastname character varying(100),
    userpublickey character varying(5000) NOT NULL,
    userpayload character varying(5000) NOT NULL,
    iv character varying(300)
);


ALTER TABLE users OWNER TO postgres;

--
-- TOC entry 200 (class 1259 OID 16505)
-- Name: usertimeline_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE usertimeline_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE usertimeline_seq OWNER TO postgres;

--
-- TOC entry 201 (class 1259 OID 16507)
-- Name: usertimeline; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE usertimeline (
    timelineid bigint DEFAULT nextval('usertimeline_seq'::regclass) NOT NULL,
    userid character(36) NOT NULL,
    timelinetype character varying(10) NOT NULL,
    transactionid character varying(128),
    username character varying(50),
    invoiceid integer,
    timelinedate timestamp(3) without time zone
);


ALTER TABLE usertimeline OWNER TO postgres;

--
-- TOC entry 202 (class 1259 OID 16513)
-- Name: usertransactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE usertransactions (
    userid character(36) NOT NULL,
    transactionid character varying(128) NOT NULL,
    outputindex integer NOT NULL,
    transdatetime timestamp(3) without time zone NOT NULL,
    amount bigint NOT NULL,
    address character varying(50),
    username character varying(50),
    transtype character varying(50) NOT NULL,
    status integer NOT NULL,
    notified integer,
    blocknumber integer,
    minersfee bigint
);


ALTER TABLE usertransactions OWNER TO postgres;

--
-- TOC entry 2689 (class 0 OID 16549)
-- Dependencies: 205
-- Data for Name: account; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY account (walletid, payload, ninkimasterprivatekey, ninkimasterpublickey, hotmasterpublickey, coldmasterpublickey, usertoken, twofactoronlogin, googleauthsecret, iv, vc, ivr, secret, recpacket, recpacketiv, locked) FROM stdin;
5f71576f22d08696facede03a7f67f982a6ce75ec7d8b2dc9de86e8d75db10dc	\N	rL1Q2cZPHQ2QxncwSCrFpkl1eUaI+7cQYaHhsBZGRCnAs9hCNIkmlKCv7AKIOeBhSAzTdBzSgiKfa91oBaO5O2abob7TeWrTyWVs7tPgbiZ3XTBGSQgPLgur7EDq810c7e4YXeQkDs+CW5tW8fvg5xB+5W5ckMGhgS4TN89dApE8/IUwt0QCYAvbTpQRPrtFuYOYSYFhJ1SI6Ww/z1Kfv0wMZRWZ4hFTZ7UbsZec8HtJ3nmzKr6xC+1CJsvKrueGX1vknwKETnVH76GEebd4miuTwTBmTm71A7UN/TafM/dAHi7Pynozc0KAgpUj3bJd	Y9UljzszjpWU4Z0U48Ith9nqenJZgo38hX+blSNY0G646zoDEo+DL5m/k1Z3hwaI6aKxa48x2JZMx2gt2DoS/2RJactw96mjIcmqT9jPgnzn1t+Eq/uvyArfT16C9TL9b2GEQ4UIeVzfzLRMboEzjQvM9HtquwKXt5FEdZOz6qXPBR3JAHaNPJouk8dKGHwbJmSh5iKZBP3BTVyEpVlTFjQtLtZ+0SvuxtEqHBvGwjt4irecJWERWP+ybnf/VcBzDYMRcu2r5Xvc1UbBC6Fd0JVJHhPZ2ObReHOdEPSMRUSVJHI7q74X+/TRaLVJ1hDB	\N	\N	d81f7b3925d8f9e1e98c79eccc951418cbc2c15c25679d62be2fa058a07b5622	1	\N	\N	\N	\N	EeAUm/CqXbQ3zUldbPZtS6YXr+RBfIGddGC939wo47sQR3h5MdS2/bR2dNyMnoIlYho/521jn/Zr0ss2ZqVKXiTeBOi+fStyqkNhSsFPPwcxLhFYM4wjrFycZ43uTy+lItcGEl84uFATORpJe0wJEiurFPo2GCf/QOgUxhcI2I36hWmuPBUIXBft3P8rEbR9Rr71SBWNmAmPuwVt1uWH9A==	\N	\N	\N
e57f8cb6644cb7321185c1d3b579e18201f50d2fb25237c56f7f7dd5f07d3f9f	\N	ekO9vj3MxIl6CL2kLbGeGD8pHPZq/6VxJtf2QhWiB8B4ej9jzeoE5IW5NEo2Vnegx9T9Ea7kwuiD8JgIbVwKXN68o8+bvK7UdoGSsq4jtQmdMBvyeZnpeYIS/eKtEFapmiEUIfxVgCkz87jVtsnGgsEGO0XFg5WWiICUmF6DvI5lXWDZ5iq+fb9kZ4Q5eK85c3U68GElqBJjI0GUKu740ElpHnLzFrXfoxqbrTB6NkBV899lmWmw93Nunz8Hn26ANr2j6VpBOdqwsYMEBqDES9ReZdfIzniRODVGAwed5Y69wpNEbwVwso+WVxcc4xuz	EG2XvnASzARNOJ09QX0G04Bvd0d+bVuEDRJkyEySyfOIZETlsh2cfFGakJZjuMHVGd1rJDVal5uV9Ix2PfxTRvOkbfSUJZL9ACGYBkB4lm5wv6n4WZwiIVm3fPgcDFUVn6p7A7js+Of+Dra/sGPSkFY6UEiNoobXT9AcXqMnLHaYHssj5hASUQ8HJSZ+mnVt6twC/0U0QvZFeyq9LTMRmnRN9EVAr34jIZcYY7RedNR6Cect3UDXaI4BJUzZ3F3qW85b+Uu+C3ZVtSDJGMQ8231mARgiHppxEtH/YcUwQtD7sHh7E1w2fo+UX9Ei8Dqc	\N	\N	c90ada906f5c4be7ef30435f3fde5e1955904ad67d472926e0baacc59496a6a3	1	\N	\N	\N	\N	7cZT7/58OOhBUTJaWy8ofrQBjjcQPma3CumPEuEfIN7hSw6+GwWQcn8pWiVLhPTqZUfsyzaokJxzK1yL5HtL6EtKTzBLuJKMhjciaMPpb3y942NXFg+prPKQsmXBUrkRaNrOedoFnih3TiC1+v3VU76T6pblfQRa8xywMOFgvpLI0Ch32VOwl/SqxEWOriOGbSiaO4sCdkF1RfE1ILCA1w==	\N	\N	\N
460b6252e93001d1e80ccfae2312ef92ba225e24ceb4dcabea9e7783a72a8b6c	\N	JqVu4jjaMKLvQl4aO1ihCdjTZRuGwrwlZLoOtaqfVtjix7Goo6AwUVgOPDrf50W7O1Kn9ebnAIyhp5kNfEYmomffTfuGOPDDC5lIfg6jG8cHtEGf1e8cuc/aWgCW/NLxT/cRDSC2iqmLmP9KYAAf6DUA4cTKS7O0NIQbbbE35xzOK5yp7lOyzv6PNQujtiUmxQq2o7AxwBhCYQw171B07hx7Eu1jY1zFaY0jR0tJNq+6RobunDkrR3sU6VwGuq7/YGctmUfP8OLvOiP/dJvlvR3qRKK7peRHQgYO7SNOL1WYn7JEsrHAJvRH+hT5kzNU	ybb31GizkbzsmciRqruWqGZICgJTvl+ahyXyAY4tR4ftfc75QSDJZczY7hq/wpneXL0xPxmffHeMVFSim/2pHUDxhjUOiYnp3vMKEUon9daqGRuQNOg2weMHLXuw86CvV1a7ygU1RkA9FQZHhk/nvIMNMBGPM+ud/OihvArbiIQmM/cwCfvuVpTl7llWCQbdqghpF5NiPdCFvXog2fNtTn+FNhD3yg8yeMZFzKpitwDZ0C19WhlOh3dnT8hyHbxzTXld204qp0nubAfeHLIH7LkusizTpGt9PIq8VMTwrOd9dXQ3VNI7IA17U4BjWlCT	\N	\N	b10d6f9fec8f8bb85ee98e117ffc2160cd6c2fb88152ad04215c3e17d7e7e805	1	\N	\N	\N	\N	/F66CAs8riWXNV7iHoNbyEcrz74dnPz5Ij3CTRHmtQJfcGBiJNUoZ2X3/zTMdZCFrvdGk/ID4ga29VLf5I+K6wy+BAslow19U3cnw1s+b1Gfr4dzy+wxGLDKvCHFQwg+os2CG2RQxcq2xr2WqcGTL/IhwukQcI65/1U7ZS9vQscYyo67/Pz9SU0TREArVGVPspe9F7MjtGNSJmYquo2jPQ==	\N	\N	\N
81325dd0e4e2a1c966480d54345f7ce8e1cfee9be2c67e13593771b0e89da215	\N	vEM4NhhwHuDHYKk4GLrPC8ObzJISISgztyrBuWhV75VrSu9I5daJs7XhAPZ3pzt+T22vUyhNKzVAPSjCR15W3C7LWSiyRAJ0Sf8A0iK28n652a0orm9OVl8cZrhxkl6Wa98qNpQFUcM1xkjWJkeKQFeMYa0KCi10++aPOXUCv7ZFBWX8WObnY3OOfynCworPYUSD3BSMYQFbVntwu7mKWYBJFwuCJFbqUwo76WE3tTTSy0YxseY1pX92eROrtWAav6tBA1vYhTMBA5NfTjSD4f13iXtgd8cBcbr8R+ahQw6Eg/wlEEnM47tBapsmp//R	qsPmYX+2rXgtIkBm8V0iq397NE5xvdbMk/KYsj7UyZmAjP7bFwuu/zo/DKmAvq20rHsjfD5W7JH2nY0ZVh7SULbcRyKFLGw6H31+ZMwud3OnSGXZAfQo6rXiW40AiQZlISFnelY702NWqoKwtrSfmd5X12UiMpmf9w+B7Ebn87wueiwXrOXwQcF9s1wl6+9ukCir1LGj+VaGKV++lixk/qOKPVGsMFYP4U7BfONqEq9P6yRwq1BS5sMr579AXxYSqeXwOEfhK6BLkicNc99QoOmb4XjemJW/DuISO7Z3Nx5K/LdtZjDYj3Z1jw/bEqvA	\N	\N	721a93ed7a719578f90f89856cf5d0edfe62377f36cc8966d174c6dab76b8fed	1	\N	\N	\N	\N	TWf1SMVDXFw5X6eRc8rmJm2hwF7rTV8ZGLarKAhI6VQl/fOg7DCfxP1GB0lkyMMy0u/ByKh15U3+S+AwEUWvbJ0gHxGx/o0ubOkyiWs9MdXm5/6u1ej1vDo5lMQTwiEl5uH5/NC9iNJsGm3eebR9lnPulp//o8V9kU2eZeQu+ad7HPPWq17xnAUKNALkJHm++Uk7hXJrz/NvklqtVe5VZw==	\N	\N	\N
ad2fbaae488baa0a3ad271eb9fc6427bc4ebf34b05a8e0b57adea7039e5d2fbc	\N	6/0sQBvDl5rrxa/3M1/SwZ1enmt8jr7r2AI+le7ZFIxjTVdtOVdMX1FK+1wbB/F5cr21yXMvy7mqn8Gfqs0xSr/sK9/HTPxvgolBoR0PPzNSETnS5HuPfti+FpzU48VNjte3VrqXLixVhjg9mcdzZEUtpAjtWRML1dZbefyszlrqzIGhfp3RwHNwSwRzyAMztXVbkNq7qqIWkEGPt7ceAzfWoXzrcIa8ZkobgFQb43djzX8itdklSZkyQy7wMrXEXUU/vIHRqBPvXxNvPmXy1b8oAeVtqs9JgsxIMWxDL9C3i56jdml8X+Td7Mo8l94m	IJ7gH5tOwlRXH4W81V0l0r7CJT5QL7HdVzrG3egojsAjMYo12dYUFdFGQwMMczFUdpj/+tzjN/+GiY2uylo1EPY+Di1YNIaqMuIRoQT7ht1aGE3Eudarps5RIiv4xZZbNkW8x3cQBF3pItmUcjkrPMm2mFLMje354lyzDhjWAV/BF1BciVBMki54kLz5d+nEiX6TCro4ad0kbI1ByiZXdIT56BUv6Us8HXuxoR9KqSzHr1uFOWaloxF/Db7LIaEyt1l0sfkzS+qhwEkMpSZi8f43Ys+SkHPc8EVWi8aLPaC/JqZFJc0C5U5KQ62eloWP	\N	\N	c81edaf3b3b587fb980192e9ad60a1aaaa3960f98e61350b3077becd2b50e40e	1	\N	\N	\N	\N	nxCXnWNS9oIAp1BfESA4lwxb+np2fH9+TGIN/gpJONQgtDRE1on2NE3H9sOseAZ5r1LfxdXPkRXgjqYfHGEBwYQ5hYDgbQwfvtLADceC0p6bf+ymHYT/cAh3pSB6xjLiL0BdnQaw4eJVN9DGRizIJVOu3fcPIT5M5HY8LmRhUzlHGALnUoEkv8uN4sOXz299oqJYwbPXMKO3aP1hurRG5Q==	\N	\N	\N
e837ababeddec68d1638cab8497bb0bfec6a3b39d2ca4c9f4cab8ad2846d3a87	\N	N6RqZuZNwgTHZ3szgFQtl7zIEIVkplmVmcx3l4u+lxmgRdAQyhMnbj4v3Q3MBehOFOsWptOp3s6ldhet99v8/U/J+setCY0bij0/9WQTzV5CYg58Y9ZXzpcWrNV5zavIjgbda/iEkmOJNeNwF+9lCu7YxjxS+K/3Gy2r61b0DPQd/B8pwoGkQA89rkex8QH2UNj0Hv/bUlIsGzEdUZZbTDebwzVWDQxAT9gtYeCH+w+cXMLgzdOAbcYxm1QiY8MXk4TcV+cpjXvI68VjfYrNYH0GL5e1Htim21CaZt/P0GLjxgLj6/Ol5tkuOk4+eOF6	2uAVdD+pp2dNneJ1gANmClaKfjf3SeM7vLs1PLyNE4fDu6dHDknXmEpcYUd7gMt2cM51YtyoVskTCMkt34NrSlrGCuAO2jmCWBSQrAtP9Y0NgVUtoVLSrEOSmAm7QiucqUXzYjlrr+NsZ+FGLYVNZgQAUyd7o6KFm8qiMxfNJwgkTe+0qJv1Lgg2LdSpG+ImoUiEbfX25PDmqRmlgF5B3VFqOrSMgNvjlfLbCHRGNHI8ny+ZZuERDNCZrIFpxUfqIgS/kHJjztlQF2VBOifwHEnBRZLrsRMg6opyqGeWrgxmxRtKZUvzkaDhrFHIlo5W	\N	\N	d7d9912897d33cc0f04d19ee6c57cd701fa4a22e9aafcb88c4c2c8d73f7a70c4	1	\N	\N	\N	\N	/nLf8BeptyjL1elsPuaKg+nNmCyFrsG5oP2kC7nM8+RSOpDLPdUml+k6sdRvtPVvmMNTsf/e9ah9w86NrZVhIyqCesWdbmKcn3nDZt1utkvyuqPmsPRF9lrdVqm17RLataLZWzFVnAVdMt/rQ7fbg2KyKq4sywhMhwnPAoZlzR1xFFmPNKEdL0Xu5ejxAcmnSASiJ2Tne1HR7M3KlYPZoQ==	\N	\N	\N
e4871053c9d4b92f3081a298b670b9264a7683033c3e89d2a7eddf2be46637e1	\N	KEDfE3gI8N9xPzO4ObEOE4sWBtzdg/1LZ5ClbYP3DYar6k3pmpNzExQMkMq7lLT5Lw/U2qn0riEuxho4tZQuJ8OFBuwrTUSG/HVWzuFgE0wD202DTAGXLp3+2yLHNYITMNygdXhpU8twplyr27nlTkAqPNaJ19hr19XoLfZJAtjhZYNnvj8NIuBa2i/sDcDqtHSVqchJHZPFC1Tujf4RNJM9yvfsZlRpYst7BQcUjk7wOInTOzdNS4HK+/G6mZzuRwAQgxYRV3/PBEGY+S/zvht0JfQbB/s9zWk+JFKq78SQl245mxa8zYcF6k62LW7I	pu1GWI78psji1VOmYRrfMuPDtfty35HUC1vP0XeG7r29s/hFrWB4H7p4HfbEOSWq0SLc855vdndEKVCulRpjBYPqD68QLLqnS0rY04HyO40OhotNc9qJk6QNIy1OxRl7GTPXhdNUAoC013QkSdTsrSiJdKOs1S19cYdSqy/R3dyCQZtOyzXik6peEqRCLwI6Sl9LLP564ZpZt34pA/WwKea26wxNouo80BqvPNvLIPIHgREIhryhzvFxucbNKLlel2qhrTu21wGKVGKS6sUc8CKdpH7eiWGFCu0ej8QKyv6GeXFB2oh0hhDHgXsFo7RR	\N	\N	95577797efef3ddc7eecc4bc5a55a6fc48daed7a03348ed2e97af66d4ea3c6f7	1	\N	\N	\N	\N	amd7r18tpeK1X8P7PEKis1BIpsRiMoplGU/ph5BJ8QueOVvJwss5Jw6zEw2LxCOwVs4AmX8xMntoq7LplTQVmHToIPvtJMeyT+7p+UUIW5jZY6LhG8MKwzzVKHmqmofDpzz1YCeuNYG2tZINL45TFsiirF0PgcOK3Y+XpKzasfYiBE80qHqX7B5JFhUewM3HWnsalAo9l/wngNWETxPtcw==	\N	\N	\N
4883cad8c5fe52cac539adc9b48121e2da9cdffc99cc62b8a9fb6b9f68be7e89	\N	m8BzH5o5XPLJPef49l16W4Os/x7xnpM7oes7Gebxliwl4HetPvUM9e9IYlI0VOpj9QUUfyERQTl1zkCqPLVBKv6tl7Noz47H1+RKkst1X4LE8nKfqrk8FTkSlGayK0OaAp5UCSUOGuemz1taNzDPgQRCTxk5SfQWcsjFQ7wG8uykiK74ekbHKML0PROxDB//cDlK9qEl055l0FTdNmr04GquAQBVwaiTsBDgLmQ3Vbf3e9JZ8SolL6bHY326q1pX1/7D4y/bkR8n4jdFA31fqdhhbnJH2fh2mU6W8VthYRjCeM+EbCQRpLqq9jBPxlUG	dKUXh0lhIJRmQa3ESCr/TQaodKKzaMjO8MK3FpAGJWWsCZzTZsJPPhXf8umaQnItcxA6SaKcDB3yAZI5OojjjYolGWhGGvweDA1QQhYlAIQVrxgiVRIvTs1zr/bEr+LfoUJMI8/qetvu3DIqG95rDMBpQ8OtfxlJQZ23TNlYepSbFH8lGHl95/wP35rHB68lMwL/Cro/44sOyE7tVU4mvsK15Uu3zbD9HHaCg6df0L3xiabWe4Xvp0mRQZhkp3r66d3/LPS3ZOF0cgbLTOMrtpiBL7XevEPVQWvoegDolt++oU3hcELvGs37nPKlHSXj	\N	\N	35c8afbcd31d900badfee444a7a4a99c3f2fc493e796ffb08fe3f6ed8b0ccbdb	1	\N	\N	\N	\N	80aEkK0KMJAGgNn8BLVHVuA75SkI7D4Ntf3Q+JahMALNmB5rMd81ugC6Y//OJp6PIMu/E5cE9mSqrjv0cpVULS4V9bL69keW6AI01RobOFdBcoIJE5ZO2jxQlPezzhjJfgFtv4FJBo+hWfz+JUWZg9ruKCVLCTf0HL8xEPKvmMr6ZNpE6dRk0/F0M0C9/dIdkfL9S/pYaNQcxllzf20CMg==	\N	\N	\N
8af802932bd0f045f5534f55f7020390e0e48ba5cc8f538c22748dcf20dcf5b5	\N	SP6475U2cDyY/qk/k6tM1DF0g2TOJ7T6WSU4WtCOccmW+AHpNaoaKrARFY2u8spI1wjVWDdzQP3pmJGzlp6PJZzmeOLtoXBuwdDN19ZhZ+EesxYBWQ4xTB54x8bR7y8zH/NUpxerYXzDNGdCVj9vBjeACoyrgwyiE+utkse7UuKr+u84ClnfIeYi6JrgnsRe5tyjdS0xDfyp5qYW+oMfSNdh6wk7EdHMwO7bjRfC0F2XVSHzo7/sH4pGYHoCMm6zzOkMMpJg1x34qNJaP2RIlHpD5DY1n0A1JfAlt115HSh391QymiJLl0IYcVY/8ARC	IM0BdLP3WBAM40dc83157NWoOHGeI64Jfdc4oWsJoP3vUOwqE+PpPg0sBhwVJ12MTTXZH4KN7raTFFI59GQDf9cLnB93Jsf3p+GjXFU8aX4RGrDy2IyrbQZad38hzr+ijKFYmGrDT0Z4SXSS4ogxgVEwxyp+7kX3JH/F4B1l6V4oBNvxn5ZpcG8fpdp0rjwho3XNy5wFNu1LntCayLQt5aPuVIKgBpGQXErghwgLBsCU0bvSLQVk2firs8YMRNYUHZxeEBBpEhlDk12Gm6XEjGSTmPUpzjHG7YpnG2dlenJi7lieCqc47RZ7TJ88/vnB	\N	\N	1bce984346c6f1638d17c07dc1a85e8a00885770f63ab790a7b06d1d68d2b509	1	\N	\N	\N	\N	aTdnYoex1yDhJ/YdE++oYHVNfa2SmaVZ9sUMP4ydXFJ+4UKThQ8OzZa6UQbza2TrhfOL8TwfpDIXl/7sRnaaTGpAhHWCFXUMjYYERB4AzDLGWsxF+RjTve+M8KO6omrF86Gzndz0XwDVQtnRmgFoB+S273Je46XBxQvr8XGt9dPf5Tgx6k3ur+RZvkSEMWiv6ZGB20MD05+F694WdfSVWA==	\N	\N	\N
af0e6eb3e3277f4f626bab0bce0e309283f228f3f4edcafb9b09f894620c028f	\N	tnSowTSWkaZSN8trzNBVaJcateACDaFnnCapLLP4KiIg7B35gre2vYf2ymM0lbxC9Q3EDFfSgaTZu76RJrffdf2lvvrPTKcblzhGSFzeCAGaYlzXCL4AP0K1VzpPNPezKMOUh9HWMH8sLNUtP7fT96LvIs6ONdbTS9nc9UmOlDVQh3RrWOtm4Ue28fvjDVk9R0k7zzljvvqGAPFSCZqzWe1OLgoUXIxu52w3MjxdNXVbAl4ExU53VMG5Mol/5rwPRbBtspsps50ah5gdSOHwqKT0SEmJq63pZTAQRB+NTJAUAEQjjJwsv3OEhzd3NPWy	AyNV4nJy9vuconCWWw7Ry72G7L2dcNa5obl33DbV+TYIFOxVNhcKuY4KLXJe3RtcZjlyO1Srg86jzQh6bKNgau88Qdxmlo6SCgS5O3oUKf0UDgvfnBBLGhpZSbbUngclsHnXZFk1GA82400zbbkW2FMa0jCOadkQ/2KPuN48jo+02MTjAcH3Y7wruZu/CeGnPDEUtXB575UhANJDXlsr2MHOiwK7q+E6Vr9yCiSRDaXQxMUly8986MqX1ISRmADCkimVZTxFqzkJahY+jGVVfS4HEtSiQ7W4xZzNnGzWEaLIDqR41YZokeWEtr4P0sk9	\N	\N	2afb8578ce32d31b222dfb3661b2e5de9c2d9ed22553f36401e5347c1448b6e1	1	\N	\N	\N	\N	eZAu2HZPILWswgbnOTt+XIcxmNoyI2P8JfaWKizmBkax/cejCnj66kPHeFfyOcF9H0ygtQoCdhc5Ad5wwO2P1Ly/QebukjARQHi5Dm4PXSioPi9GQI/OHh39HFar4ZOcZEZgtF8ju6DPzb08CDDlOG/9FwFNIsgv1AgmJpXnV0urSFehTnxc+ZBeDpvoKEHRb1osO5pWkTsu+XIVmMHzoQ==	\N	\N	\N
98ea460da226e52f25e2e6ab837e79535a55cb18da425007ba5df77d759161a5	\N	+AIghC6D//3S5XgQtsHb49WPdDVVV8EtLJ7iZZOFFTZ/h9BwUrrCQzBC4R/r+pLiAwCm0UjOb+N2gZpLfyQ0oXCY8X9UhAW7lWAcrvAhjvRrMJQosMmOLeDNtQ/foIL6QsL+PhKd4/x/si3EYBvRFgF/TcfWLIYxeNvRRjjNwjyR93qFMf+H51yoPnkkEUeytyhmdsTW56SUs2Gq/DdRv/IbcVO28gzxvoz7SD0E6JnyLnuj+zkTYrTsBq6OCItj/MlDe5uapCG2DHxALPCWULYmhM5MwV+rt0cOdFHB7toGGZsHETeA6GuhXi4LwzaE	J0la72xoc9eDfrfAu5Fp1mZykbAVLVRVu+CIkGAhIuLLdl/G0R+htL9PpqMozEUHLIVAtsyamHXiU8WbdnnhAtgBtYr92kmwx52y6b0sj0xLV2rAktIsJnA6cGOQShhXb4HIuy6i/SH3/4M1/eoI6dz3Qnw4xo2vtGaoILk5u7C+7b6BoC4JdeDYyK9YRP7eypvZ2mCzfdY9mOtLpDS3Qpk04OeafpN6t+HQpimuVTYPL+CRqUHNux3T5jUh0V9hjuO4mpflEfXdF9G5LrVNA9qu+yCcG8D2UUOLzvfrUZuXVXtPGbMXxM5l+9ZYPau5	\N	\N	1d00ea65f6259f8f3328b00f8dcd9a2f5eda33f9240a2ae746a9d08464381cb3	1	\N	\N	\N	\N	x+5X5QzmL2jPveo22tDsSjPL2/kVKfDAR3oKZOeF7lgiJYaHDEVxFDM8bTnGPzqF8eRXCJjlOEvLyQ1uWphepwBxpcHdorzqc32vWJFAKeqy2yx0JouFStmwSs8qVI0QljX+WUhGZ6+8QrOiHfMiBa4HaVjQI9NFgyXX3Yb/SHYnaxMBiT+tR88J7CE8tlklId1nFrBmvgJzK+cDkoqcXQ==	\N	\N	\N
5634f05be7c4877b24c9f6f4d054c8e024fdd40616edc80b08749418c3eca65b	\N	mH1pmET+F6WdEHfDZzRR+cWOTicam7TuTdSweremZN3GeT6vDU+cIOBS84b5SjsqFspubTpc10gysoJp8Eg0gAk0tKSEgKq8o9C1jDNumtTFXXU4WgwNsUsHqKYYkcQyGZQbx7yufaPGvCskvNuMNKuflE8im9AXzmCTV0386E8ZijaJQfOZrgK0tnzlH/W/XYnpenSgGw68zp3x0FCsmRX4j5vbmtiJ4p1t2MSuI4wsAZNz5RyNcaShgjZt51m6F97YTHHgYJ85H/ikzROoUi1I0FDyzSD7seo/FUhcma0VVTutWuc5gl3ZdLVu3g5Q	nl704HE6J9vnCcd3J+yJnqcig9fE3+LWbPG70gk1FsvRdeQlumzXs45MnemFMt1LQ+B993m+h7LNwudYgdhV9jxB+cvjgSCppRRu9bsL4QmsdppLg5AGcDt1HdV4l1AtZT2X+t6CYQoyyucTPZDBzfSP2FNYE8UydS7vgNWS5ivJIWZtOHQGDLcYGQOljLcdZa+DBdBunnvRkeyOuFyx8KkRbTUJXjqFzxoHPtIbpJe/ifQUNRjnr3GHTL2Kb3YiqEkH6Uw4LzBMYvqgbrIMJQVd1RXGaTG3KXuMly6Ij2FqfXuq/1mDNsYocyC3uu1H	\N	\N	8543f45bcea29cca10df345b731ce9bf15fc5eda2e4676620aa8313f5e39f0f1	1	\N	\N	\N	\N	RHkG6CEX10VNl4vnWJgVq713kDPtmMfv56yDqUK2hPKK1h9BCE5Cja1xtZeKDcGzutaN9hw4D9GeVA7m0L0RKAcMln9iTEXvu5pNUg8T+4lAVLFN5BpUyg6/747Mupmq2f+h9BAQzlIRS029Y1rd2MHJy6kA/IYsDx4/PJQyPY0hXOPehuOnF7OLKQNv0+HXjDGtXx6BVhJwgx/HezJGIw==	\N	\N	\N
b5c826469c124e2ce20f64714f0165fc5ad85c83cdc4ec23a7103cdf046d46d0	\N	RrHn4igSqkj7bhuBeAsP4lZnTUiH+Y0x3RTddQnwWLeGqhCjvjb2ARRbKyyMXLS8OhyxV7vx3rHeDbeAESDKpmOjLJ0Yl+DuCwaDCmsN/7bxkT3F0LWwZsvuQGcV89niycQFrp6lJnEcfysdiFZc5wMs1eR9YWI9HqmkA8SsilYTqbvF9T61c8NJbd5l03reEOapqrj32hLN0tt9pS4CU8mtA6PSrsYrQO4q366pJwu25o8JwR/g6ikeX+gqc3oB4m8vg0rtsjSgBjE0ZvAsH18UXGLj2tq8FqldwXgMg2In3Nt1wFXD3dI13qjQN9GS	aAD5C9hy0lpvElBFGNmVlqqkBgz7VN8ultb05a4njqD3r71f5ae1AkhdIyhs4jdkki2P/tpr6JkEnI5GrFQt8QAXby49MH7oAIMNglVPexD0cr5DVJWUcjNsV4clwhWA0NRp/UnPUr39pkvduEGCHyLfDudk8euT7E9WOGrZpr2+YGw5lZG11r0rInKqCUNzwefYauUWfavQfTwNqyCVCsIz76lPCFj/b7n6BfflvnoGtjMbX3Tn2W9VLRKKuJYP0pRuodECaMyTqvlGws+pPtHuQXayZwmWM/aYwJet4hd4WXsSAjSaWh2c1bKDZoe6	\N	\N	12c5fd6fb2a61977ceba67cd455437ffedc554c2984f0305e2123592b8cc4963	1	\N	\N	\N	\N	sS4AqxdX/8hgrIfL2vYRelAPIsyYOngNU2N0r/PuUnvRZjef+//WB4SzJGpKJ5To1zgifoiLYlwQPAD0YYg8IK7eDhmaeoszCXiIHD7WUAqW18DmkBl66UD4pYRT+4Qyg1/n7nnIbNsUtjxzcidnjrWzA8Ye8rZW5vRvQQ5y0u0Y9KHW7pJU2L1QryVVslI58xLc5mhnk5RXMqRb52mxdA==	\N	\N	\N
798c8705baf4378f3e0a6a190cd0b1c73713f9049a73a6d9a29a49d840639f11	\N	bubdXAPDAFZGyQnz+009R9sNVuAlfLaDRfwtBuJtbh8zFuIG0xKTJU1ulr/z3fZCntsqO3X7R5kYihRtOb53VOVh+pkB6kVYHmuY7/XdvA4w45IQGQvD04+5hz85uCKhGzCB0CcGCPHsSlDOPJj5JPsS4nhGO0KvEbcGRU2HBWwCUN2+vk3aAyhdK500QnS4zmFT2XW0kyYo9wkRmH5B2dNf2ihCQrRzXMEbxtQFx7K2yhtjdlvqs1E4soFTayL1rrzT4hW110A5IEFUwrIcQYq+uSD1G3bWUVbWanWR/+R+PgpDXmTRX1kbyelx4SlT	9IzkPtCfEShkgcwmjTQJLxcwks1B9aZ6KykcDoV0V16bYMOmvOMhkCbpD7DsJV8zodfuzM4h2Mb/m4By6OtRmrNyXYlBYSulOA/88/5wiqPf/lgVrqFv3BO34Hu02JlmCAjIa+uVNOX37GJCw1td5Am55t6MxQSRHLy5+Pf63W7cdYvmDp6l6Kl1RkoukYNN8AwqTldJhWw5Je7FmrBD1QgeE60gBMOG4zfD8VJ2A8WWoutHbifCEfTWn+tMcwz78zcNe5GXkHz8taWTCHd/3W7EfZI4xGPxG8ojcJYTEeTvb0XFBqsLTmxcxHPR7/RB	\N	\N	fc8da2f543c48892fc39920b68dd2ced3a1c82422973d48d937841144f2e7c20	1	\N	\N	\N	\N	kOqIgPnte5AK9eBGT2QYNXpR2ng8tp35xsTl0S6h5OH8eFw74EsxB8a+/4O1J2CssO6pFw1ZoQNH4uG+dGMKyYYqYfM1deWBtRuxvbUfYutpMYhGAKt77iPqV0pklEIu4TW7J/Vyv/mUICHRss6mDTYGoLhlCA4eGCgwsYmXlWnzG3nGN5fvUsFINV8zK9tCO2T6eonCOr04vIEkYsoWOw==	\N	\N	\N
e9085d06848bec6961134a2eac85fee7787bf6620a796314340c2989093a87f6	\N	hcW0UJj205fE6CJCYpnAYe0F8i9+1EzdpaZIreL8hSSJ3N74imXUHeXJcnfHw8TwfonLNSDnoShZXosW1UJebTEFnyEiLUgNodu9/9GXsBiS4pzcroNwHws2ayca2xOxMckxMhPm/33dAcnQgN2hxFdKs+ZBqsDEuTOBYDEusNHZ6GUPQLcW1TzH6o12i2SxzDt5+Kcgg+NCNd/lntBdtSSLgQR3YZmK4WlTBCXktJzQp8yxk4snCV5UAGr0AwR1FyaJ2vnbRkqGC9TbyFQ6/ymoNBsseqZoTbLBojYasF0tqF7F1LxE3gk0WS50hylj	uswC3TY9ImPboZX6vEP74EEax7uUMnglIBXrLx12JIxixNIDisi9nxYc1s8HVlPVp+oPKUUcLdoFpQ99tDssyCG39Bl/4tXYC6/Ep1ivwSO00gi4XHi4W2uMV7XoEr35+Np3UPqoNuQ6zThXas/PoaOKhMluEr20+u42wKQoS8l6kAoLGujFoTRCFCfmlVJP4LQIrMivKRxcBCCxSKQdVm/qLxdxryVTx6b3nheLm5hiEeDwGahMTjiS7AkCVNXhapUii7WqhIDUjGk1M4mYtYuyK90SX9TokJhzA4CWZenODn/9OKbErsmTYpU0AHXc	\N	\N	27b973079a018ffc0bef5471303858cd1b1cf7e065a213bb22352c9addfbe412	1	\N	\N	\N	\N	VWYMgRogMN3yrOuJhAYlq1MT6XYO8Ifa7C4QUxM15AZkd3Ifh1QQ2hV7XKw0FyLQZ0FRu9vAoLQqlDlIhApxmZIgxyKjxKsNx2ijqOlq+/9nTsejunsSDods2znNaF0e4MKthq810Rjh8IIIzTTVDyNKrz3zZfCeK2GH2KINcSSEFX62YZ1hPBUkId0ohNoOPoOmsLz4IYT7GAdwiXlpeA==	\N	\N	\N
40472bf49352eb4d6dbd5b0a501fdced0f99df82ea4550693a34dd19d71680af	\N	1exaVJt8GnY0nEtKCPHNn90brNSPLMoeONuHpqyYgXzCq1/NrzAM4E/3nth22LNkEEjhdqVXYhy6hzgEuelAd/VPQAeK9/mtUGLiTM1k9FWW0xnKa1UzRy7uqAS72QLVvThg6NjHvLDsDtyBd3PzThSKfERiieD48KSc9PKSGSks2w45OFRDJyFMdVvZqEKADvHI4kAzZGSTx3TamWM7C++VCzRB2x9Be423ZSdoZVUAjJ64IEHXWZaj4R+aMJCKeEulmJZVZyq4DZDs4N0cI3lCbZ5nT3dyqHvP/NtUWvXtF1N27W3US1glxh664pf7	f/5Jwtq4RPpfTvUQl0Ia6KXgVlnJULEQbnr7CgNsopH1EU0vy2LpMhOdIqLHM4HPhrSaQLwZz0C4oYrjIuRNjCcie8Qalc6JRIM1LB1etCvN5oR72aNGDqIcV4ybnc7ZfxnGxE2NmIWttHYg1519iu5dTOlp417U1yow5gUwBF2edx2/MG7xjmLI/HHquI9dS+xA0kytdNR6Yzo7N/55Y1TZ2pGh/IEacrc8GZ2xskHqDi+EfvWv2Bouzou3pgnG1rN0L9F/IYqBfQFByi4JtW7RwvTGWeRTmtbfiTz8VXmv1m/udR2QCVPGacLJztJC	\N	\N	bfb21ec7b182dc0166b96b71ccfee97e952534c82f03294fafc41e5b9a86d79d	1	\N	\N	\N	\N	efholCh07LRb8SAFJYUNHWdpNDiaTzhiNfH8/ryOSGLEhczDLZE/FzaxC3SrzAW4q6pm6S0MwOlOMo1wWwllUsRY1bKbMpsVoZtd8YsGO1CEISA1z1JPdrTqLbhhjTc36+xmXTyMmCyMqc7YfhRXC5n6lZVAJ3iwVrmJiYoF3mZxks0u+aERRNpvcpTnnJPAw6k9nIPULG69oonhv+d9CQ==	\N	\N	\N
ffafdec2a94670306bd98349d659933946d5dc419c337975892422800ac8dc6e	\N	IEh6kxNi1ThH9BsPAf+wS88dbO6a1ZbuM0hBsJ87w9VgxNFfJOAHQuCzoxMiAMln8d79ITk+8y4XtBh49Zsn1BEUM+DVMseYa4eaGBMn4UoPvZljI6Hz9cQWOJ5i4ixnS9fduJ2/4nZhCsJfQvI98D3v800/t23mE82/8kBz18v/h2Y08eO/LuezXKq8RHmjnUDAQboYcWMu/exmnv21ytTNzI+OzniXE8akDAxWQoT/QP30QJ81imQj9jOeJqQZmwC3zwAllu44kpXHhOV4D6gHpOfhZB+Rcc13fWfisCx6FLMh2yYZydjNzBMnDyFr	WT3b2ruQUdw7Jec21s6hjxsjNb3EvsvwZ8LdJJbSj7pu/cpXnobJLOSrX7zGRVn/H57hE4H0W2yMygQ5iFIik6ZcWwKBBvopZ8Kobd3Tvn2++eQ9//wHJjjaAmEpTGt4m5n/cORxNpM/oe9AHlbOZPnbQqVOfsA9d+tKHSEskX1d025+ANQnLd7JnGdpE9OT+w8KP76hWiFhSrPRx+0heWbRu4r3+qqtoPmx/zAVWpsP2BK+ngIVkGtnK/4fzmg3ALBafqBu5ObPT/AhzxwBF+xOVxoUj411/In8My87ZinT46lWLmqW3afVrOPrX4Ka	\N	\N	3127969d1341dd61c5ca445e2507a443d97e7a616f7d2c59df5018f55b9bf30d	1	\N	\N	\N	\N	DOf+7sKHzb078tkvcz62KtrXUBYp/KcHdJTAt3U5B0VtdLR5Bajvf4PZlgUE4/flIGvVq+Cux3LdY0TZmlhSaIr9HBDhGiVY6FZcWhlzf4+TXHWBVukJdDltnqUViOQWiaeSkfiqkm8pKZXXZA9qMoS+QRmgquecW0Ipl/q63UU1hdEfSSeo8Al0bFsObZKl2J0mPGBqHLVn0/Wf6c7bWQ==	\N	\N	\N
0af18ebca0a49b3267e20cfbb7bcc685d59d3be0d16817bd637777933c8be6be	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	10f15d6ce7b27f5db654babcf95fe42ff4e4c129144ce338698313e38626fdc1	1	\N	25f7218c79972361ecab16d845b999707548f4bee0da28c3e532205dbe2175ce	eWtYcXqHmeuVXJsx0W99VbtmSBQB/Kd2f/QEblNJ0dA=	b52a2d0f09dff73ea59c25812f8acc449d16509f299ed5a2c97f46c9a89de139	Kgubly1AZE1MDgis/TAVGux9cMy8GMmSoTW4c7YwNz5qrH4nf6IFm+1xGX+ldTlB1MRVzuzig14Tgo1gEvfc+ZNKeT7ym6A6WPlvXS7nasXzcSa8aM2bVCEMR6d+XoG0e9jShIvFDOuM8iVO2PGQ1YbCFGEHqy/AkSDCbercyGwt4SyuWW+d1iRwAFFAtmjCzsTxBg5YQEuGBHSqT5rntg==	RfPXEXMGZ2eBS/zxoHvh1l43LFZ5wUVQVpyfEfJdkw8=	0fa61349e40be6970f3dedf77921b7f77aa9aee67ee34ac9dd8ce0a16a59db55	\N
0d91c8a668791d7605d2067c307926bd56a9d07c9f492632d499c2b9ba5ad853	KTKI6j5E0eqq103Mk+p/89H3nRWsoyyUB4aERmjWsOKt+V5LJOqzncOxkZp1QkqZAomA6k5iyvVvmjFY9z+dFo5tjFjboHTvGlsHL3H1jAWavg+HOaxNplSigmRMrL90I016kWEzmpTp29QwrzBUQmXUhmrTzkOKlBX1EAFs3VnEXd7w6v2svZAOhHXgoMmpcwQ2Q3qS3kCEIPpg4FZsHFz6xp9zMJig245XSoJTWeeVIAjDwC/QMIaknftfKYeIQq0MykhHtWTwEkAghHmYtpf3vtEezfEIceITYx9sxmJQ/hbo9Z4OF0AVuP3A7CQIrU6MGF2SzoZunBjuZQ1ssoFR78x7cxl5GrDUXcDxMduMOpaqjFxQx5hgixv2GQwjlymC46W95rAAYLf1HvIMSUc03FDUSPXBWf01CTh5eT/d47aOHrAs6hbS3mlvxF0q6btMXEPLndrCQu8t5W9FbfdOOGoCBneVhXpqMFzCi/Ds931UUSFT6o9Cdt4Lmg9dcVzytF/P0gbr2/NPrz2dqTcLVAARwIRLQkvITnhyAz3SbJ61rgjm1sYhe8uwm2++yEvsRWwGqYYT3Mv8ahuoLan6AYMP7EiMFZtKVY5sVzmnGjY66WAI7fMtptah/fehgFuUJAjR9KNocr5LczRF7FsujjX0MdcRhchKrNPp9MFq+7/a5rSpROHntsDHqghZPRqhaYGagqtOuWOvM8VW/Q==	lcWGkzkGcw47+obaGHUc/DIeCSUUl0FwrRu0rfn8GatZY/5EnZfRDtiRwjtORSzENt2CWL00ypzec7XtcMycND9OOma2Wxn4paqcz5HMy/AO5xtuZhPl4k6qTzGYSr+fuj9emkmMmOxM3hX61W2yE3EHmImGBYj03PtOm1BQAw4bi7Ri0Trq2LBUnP+6ubxdPCp0oItzL35yahIUp3YH34lQr5638KHgEM+04/7dA8Moi0kxOi5fpP0lY8dQ3odSeDP33uLDWvZB/eTuShCkUK8ISEc/SSKk3K08uRleEKhFQY5sCFNPUZrxZrDGjCdY	EpZ44VB4MfDkaz8bIdcdP/5tS2kvGwTP/s8niyqqljNebwAxH8rX4XCLZMEaeCkhHa64hF3Q7iMBSh/iiCEBzLPDkGJxRxZWTfw4oFkFQjxPyJE5vDqgEMP5jL5PM+JexdB03DOLcMZ6Mz8Ar9vfjcCgGess+Dbm383Vga6ikOfTFYVwR5FJjXSOAyQxyWXZU0FmlQNx+7NtmJ4DbUnIiSnD9G0LKmjCrClEQN0u8NSrztLVB8rv2s2Z1PylIgSmxrRoDthpUnYfgGF4ivpQ8E4tPrU/BFMMYCxFlyLWwoLfQ60bTsO44huqtmLulDRC	r3sivCWzkYQhXlRYZUdQMfiUt2MngrKUBKw7zrIsE2fgOOCUIa/gUfhAU0MYmJxUUsIOxyobJ7/dCJIGnkljk55IOj+4XGW64oizin3BYINBhW+C7FUTSFFfB5wL13RzhxtlfUmr4RCvpM5gRXNqvgjJzG59hMw1MniIdbI18MQvpokzkKHOexyLThe1OFOEfm70q0C0g+cNIGq+UtO+nSXNvoZ+gFW86fu0LRMX+iNtjo4QpdBGE3NKNqrjQ8/RFcWru0bwfPFB4i07GtALy4jkCuTM98991gQGkWVRWmtMPbD+/o+NOBfrDk3owEBh	KbOF47O9RZCr4YBGs1rap1HZw8KQ9062FR66xH4SrR2FPZ7kYHRaJ3SuFIVl+3wNvvoAPeEnH0AR+qhuX+gi1YK+tYZhOteZquo3luHmuTd10+EBDuV7be0edmbcuwf6NBMW9Vhl5mIMJ3x9d41i2e9yMpiztNsjbaWYrETnkQD81K/ylbgE70DMwfgkU0b+OTEZBnwwsIHvdElwQIX6/m4RfEsdO0/XfKIlzRo+kxFE2Mk6BvSd9Rlj8k5lIoeQhcHhZ6GCEFAD60fzET+h3ETsweTp0Nby6xFLyzOZ73DVWxYFJ5zhkoZh+Dcda1rU	dfa0c62d98adc55429728932aaf3be6ccc24bde16681b90e83a1955a05f4b1f3	1	\N	d96df80aac42a7a1c3dfc13c3999a3d91d03da14465487c84406c6c3cbc870a7	I48cMHKcX7urZWbS2NmYg84lCefAmrNk4DcAWe3n2KI=	390e96c8de0ccfd47d8eb0f3d4340589f22b50998871cc3875e4c13062f2c819	9BwKY+S9U5J8LoSNFjHW4OJ58XLXDCaYVlvVGBLFMbuyIVKlbWTivGwnmbGvbT505BdTg2iMPoxVqYs7wZEzwBELBasjS8wDwj9ta32sxZPnHfs5ibZ536b8QqMRga9LSCw3fVHoz8pWvY4Co3aUdsPBMCdLRQU2/tKyXDO+U2EI6KdqNbIBeAtMfZOBN5i80VqH5PbFegL/4MyiF/w8CQ==	k7neECdLFiVUfzAkCzBOgYqL1i5oBCUb86HEIvdNjV4=	ecc695369691077001eaae41d6b594b6517cf91458e2fbf0b396d2146084cd87	\N
3039ea9cf03f90aead7b772a8fd327ae4188741759575d2c9eef0cb8df702912	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	0ad327bdadc9e3736673e430f73e775fb7cfa2af280960445735c25ed336e88a	1	\N	b05ce3b3e1b85231d8e2d17352167486c5ff553f7eba45accb1bd84d7bd2d1d4	YJnrfaINiezzFuH6cerKqG2v0KS7jYnMshbTjkHvkc8=	a2d91e608b6caeeba4139ccacae699a483449023dbac835c9e019404bcb2bc03	FN5MvNZ3Ouk/fZtuoni5pktkX4XqqH7mdeRSk8bGqx0ybttj94ouydXCY2X2MDtXDAaNGyzFYEXmnSl4ZKMxnqypJvEjvs5dMb6UtaRWrih0fbR2BmWTFWFx1fD0Y5XF3gPwQgjpTDnaLrsq3UU1xH4TDLYfs+JO8HhLJQWsnQHKMkt1JvVNyPVpHpV55JCtM8DKDKqHIeT1dAusdzVPJg==	QSwwokaB8OWpmZ6xaZKrLXKT1mJfrQedHT7Cv+QV9Zs=	bdbd1874a86fbf9ab871ff2c30e1f581434b92fa08d072b906ae41b68403ed69	\N
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	773c0f54e0c26839d8d3822f265fec28faba6e3d41449c0587255189b36df54a	1	Higync9Xm+KJBuukDDCc0J3Ju+ARGcIeS9KNRNxg9RRY2KgyVO26hwFvnFxkbOSw+FoeoKMNPrHSV0O5TnTWBYxgUuPxlxrIc20tdMxDi+qVgETZXTfjgwropOhHNoE7	e41e83d97a0d06978bb8df84bf7d1e8461a39dae054006d65771a8e52638b5aa	iA7I74a0cP0EuvuumygEVlYBmJ8AT1ez06dMhN5jAw0=	b440c662ed71fd68e25da9e951e2dff1016380262c0bb070b8e14d29f9ff692a	rjO4KZ75Wn5/+ZqOsVxX+AYXsRlB2E8vJp+r5h9hoVWeKu/Cvmxkx3ruakQ9M4C7a7eP4xqQYT0HGbZFz4F1amMR7l7eD/7orCo5FIsA3WE56UNN2HutjJP6LpnhjXyVB3KbqPsrcSNVmEwoW4n2o60YZ27zFCOBTpPkqGjWuW7lJV/VEpIv8SUjGXudjed2unaYnWKrZqh9F06t5/RWZg==	CUMqmjQfqZrGTwM2lijrIbDnF6RT6GqhIglfPEgSRdE=	a25401390ddb8bc67efd18d170daa535d4eb677967f7de5ad4fed003cb6c60f2	\N
c10bd4f03324f9139fd748f09241b8444266c789c946e023c606c595a30f3819	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	1ebe8fd95e9b85b3399c197b40d1a76643ad40a6b182cd3f648b00b1a81a4870	1	\N	4fab1a01643685168de7ea4b2a2c53b74b46ea40bc136f502e83a1c8f0798622	2ATEb9QpQ4iq0rUbstZpTxHYLr6xNP3BjhUYmGjsFgE=	c5f970382bcc8231cff1c590527fa973985869c747c74bfb7887d35cc49ef11f	zxX+LvE0yY870S6k8Nc2xDOoGm5huVfsNl9cUphlLnSUTMTCcX2snft34b7TBeR2YJFAQOq8Vb2aAc3Te2W6G96UJLbD8Hizo5CLz8K5DRUrokJLlyIhVctv27FOsAhBxpM3hyXrbLJGOM+s/83sf7y4naOfcFjiTQQUd/+HGpK2jefrTkQML+jh2IWz7TfePVAAq5LVHoauR6UgaG0b0g==	+cj2NPx4DuBh97eLoMtOXZB/7qPzRhdHRZ5JYHLLZZY=	86e746e9fc967396f9eb0e6a670c538011aa6bad3a56e890cac7449a41a41731	\N
03dc241270d18341948e0b57b14a74f7809206839a1bde2b6936d5ca7cbceadc	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	f8adf13659a101b2b3911f4fe007e1dc3fad0c6a92162a27381ce43a4649b8ab	1	7Jq7PGORe7LJ2jz3k4o6A7iOa0gtRm+ij2Rdp2e6fo6lhlcQqGIpObIQ3XynMcOj5Dk6zST8xbcT8QpgMDbsqKidVGPdzDoWDW15K2BLGZ5Upm73cHcML7dVjIlI7ytK	f84e06c55f1da46f098a60f940050487578bf59705b3371da08ee66d4499fc6c	+l6sKYqvpi4PdJIdnSgMyq/WAYM5InG82JHK0PBoZa8=	6024d19de9756ef03f1818b0a3052f015354b5ead32d34a84bfe66cd6fe67ea9	6GqX0Rvxo1G/W3Y2TC1SMQS5yyOv1X7hnAeGCbza7GILxnEWWJCM1utrRH6CEoE/90oDngeqqsrVNP7ipArzmf+yg7EkX5RO1nyL+geekRyjDynOJsTYZpufbZi1js/1WEXaRTQ9himI1kwUnbPs2mBo5WX/kUQpLyrHSDiT+sTKgi4KdYmlB/bi/iyRMsDC2bqfwVaf20Pj01nseU1PIg==	WBYZqFs8PFeHtqtpecaTpr8o1LJ5U/br8anZEEmUmZ0=	66f12ae95386b2c1eb1b9b4e20bef18c10fd44aef1835a8b427b5382368e48c9	\N
6e58e78302664bfa2bab1a6ea1516c6ff3c8576db2bccbd067efe4071bfe9358	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	775ec636a9bd8ee200d2729f432fae3d776b1f2fc885a398cf398d35ecbdfe1e	1	kXGBXq4iMJHXOkGG8eiv0KbYhoPP/OmG7DbF3BtRjN5N9JbucStXwATYJhKLI2An9JlLHtuAQl2TxJ2M97vyyB2DstukwcUHtPLTe3VnzUHf0HlCnUsTDGDppwjKgE3a	b269d7425ae473a4c6eb9edbd187fe67c632f0b9f53f80d6b960278d4bcb8f33	INsvSLIXI9DNhMwY62wrvZhotY1YEvkWpm8+GHunYzc=	74020c007c59fc92b33829b4c7d8a0556c8a4f881fa90f3a650bcfdb950725c5	NLa+QSxo1nJywyV9q+M2RfP/hV+UwhrOZefggCXEM9SVriL5PYJR8jsxvywvsGNF+7bt4nLXdyM638tMc4neE7omaDwq59NH23rDGGbG1z9bG5zmmdRK5T3xJP6vUwUDR0n57pkQJe9GVWJPKzldqPIbdL3BEc6r03xbem3cA8/ImLpPPDLJWa+JaM4Euz4hEZEFZP1yhJH3LQ08paeJag==	a8Smk/Ax/8m7K13qPwgERg5Wy+TnW7g/3fD5QWoH5Oc=	1ab7a229dbed771f2fa38febbfa4a578b39428df726da1ed4853d5579332e01a	\N
d11210844e7b24c78de54b254b008d33b82e06303bdd2ac6449717f4a8bed844	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	e7ec50b1c33a7ce84fa2511682b0777ce49c6129d523b0dcf5837e12b104327a	1	UYgHuzGBNHC9Zd3uGz1bKuzvDBqssvHjGROILMjLu4oYQ+cqwrG1czb6UAkaM/YqZ5OMZElF+aMq2tPynlzcDCv5ouhyVomtG/zC2D6wnv7yVOs+q1Kr7rkbFmlEilIc	ae57aa7286d530f8a929a67c4d05f34b41b4c8a02ea3a11c2424764ae6d18866	2voCUzz9+JjWChQ0gydvXGHvZKN3W6U4fHImntPHkuQ=	2cf6e2f2fca71e526fe554488d2e9de2bb10b511247d59db5b0f3c86335f3bdb	DPJ8PcoU6rrDRGq2niMUCXcGAGOyO1Pp6bJlLFs/T37fB2I8UsFttjh4WK0BkSwcShyd/LqRRjLMKFP0BtzPvMOYrfjZcdWdcXeNT1CgxNH0UNYyX6KpZsEUM9dctGk+ysZsvoQw3A/kRagbM3VlCaGJkM/jgthlBlFYE1i/Dr2fs/uctzKEH35l1Hw1Q9tRjrhcGdnQY5z0x/WX+LAM6A==	QoOIxfs8UJobXJcJ450a4FSrIqcVeJVSaYF8LBF0PUs=	dc3599b8c011b89b63a793f836c94409102d146f13c6ac72d4cb8336bcaa1b45	\N
4298111cb827f99d8ed41047ef20df4cccb5affde2a20140b028ae112d8fd1d4	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	622ec6952673c59bccd1afd2c1abbc2042d72edfebf94f806b75439b8f73df61	1	sOfc4bf8o47JSPLc5RS868PjB2WMaIDtYSskyYocVtmLR0as8wsP6602VwGxzHbmDDLq2v+b83qDJRBLeFWdCt5SEiYw0+jkGyq1xR91KWx/8Hgqk64RYbLabOFxXDIy	4dda90d73045d03333711c23ce4fb31c0230f13a932c94451296e775d4764d44	ZocfUjQZMGUZgq7AViVbzqxGBmt/9OyI9zPhoOIxJb0=	1dc9a65dce1e2424251ae5ffd0c8bf88eaf64dfae935e42860c16da5767c1b76	j24MxwFAaRS68BoIpL7DKLVyJHQG5VO3iJ1ZrvPKnaVAYBr9csilO1JjAQrMUiMyXxX1tX7U2EvB2p2kpSwioVqcTXbPWNRZN9cY0jxNeaJum1dD80NU3/iAWnF4X33pfTn8j1PJJPWiAt+9ZCg34W//Yws7LRsviy1quW9bICMthcDf/4ygNmt2B/hCIMt6UMfU8BcRs2aQERmwmN9p8g==	+wG2jbphHUnpQ/sGWJLaRrd/DCcaKxkZ6G/WNW2JA2Y=	ae6c98790058290286b1768dc0e408a32e8a8ad3be0ada1760dce1456bda98b0	\N
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	1	yEro7Apiook1Vo+8dOFxVZqxtzGLYgMkWdOpDXP1afwrdiCERySuxiBg9tdAGN1+5m9qI9eJgHBJN0zn3RO2GDGhcUcOzOn3H0hz2usMUSBDcpWv3K2oJlAC7hv48rcl	9fd5f14fd95ef685f33e8720adff9b2001e369b01a91f2b6d561611d5e334a08	fkcU+hp/DCGf5Cj2kNvqk9LfpCYekGLeJkc6udNZPyU=	a0dbe03f365bac352db4c0968f7c64f320b0c505a30c45ca4be95e3b2fb46ae3	CZhuD5szPP+EpAUnr97P34GyhTh/l1d1Qel5EFwiykgiQdowsYNh15EMt+Vzwv+oYgFMsUmefBfI8j0B0nlXcnJ8UpB+DtXVPHvX9fSKu0dcg4JtrrJERObfgjgq4xm74WVY/03S+6ITPtgePBwnqY85pEY+pvyShQGjtPgI1rvet3TAaX2YOECsWGPs7+rIdxMfRoRc8onzTJkbvIMuDw==	XWftwHp1dP1RWBR4N/4TvUT3phLA/c1oI9lEMcx9oG0=	c4975ecc1db6cccc4e23314de4bdf5f1a0df23a88fb60aebd615330a281ae234	\N
f952b7ccf52fbebb04859d482474ef46fb37d4f5e63f546f563c5811828096bf	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	554c0b7a2fd82c2d63547fbd5fd6e2139607c69f803f8cc109e34c80e4705a1a	1	2dX5nehDGy7c1Fi7XSUjvMGJeYUiP24DFZk0hhF7SQpkavNuKM5jaOvz0DZC506KlOACeTu0lqwOZDF4JqGi496i9sik9BuoS0QDJOC240mZk1U8Uzo0vQhqa4gFrME0	ac50dfed95a5e0cd4dca8e22e42a1ba907f58af54a92c7702fab2481e1a0c734	IdF4r3OZbY7WuvX+mSsHXAY0PXGSDUfWsRm86q7w+sA=	339c8c8c7cf654f8f2d9c18f7310823bda181a6ea78ac3d2979b515422168a03	KoW8wBYPKrubrgKOYe4hr+R+0ULLUK+Oah2bvjUGSOrFwR8Iq2QgvfXi2wuyn9wGhYKLX3vqSX6ceOBFDcccMTVwxuSzQzfXNZegA8Zl/Owu/BXSwq/g4K5t0BE5L1e/264njoBfOYRQ28ZHPjpomzMJ6+rvKLBA4vw4D9OWkSiehQ9Frxpl4dFShG+uz2KKp7J8HI/K4v/8vtbvZzHx4w==	o9alMJnuGMCvL+/dTACszm0/Dxq2zRjx3KXaHwMLC8k=	cdae13b22514872dad0d1d99383125b6c839e96e25938050955d162fa8e7fc49	\N
1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	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	b75ae0e74f21ffd376ce1ee409fb2c260b6eb7b47066f7762005677c12753786	1	MUd4CZcQIzPNcZRSDXfP291a7Yf6lys2gIsH07PMov9Zw6w1x8gexj0NKYZRcS2zb5AaRrbAqsVtsefHrR5R2HwZmQ67EgE/DVq8m4PxyUv6ZEtWg0qRnSIXpYkEaWdA	476adb816647559df40cc8fc4f8fcea3bc888488cfa0be1bec8d371c9b30568d	dyx9GRAcJnXA+2hjj4ztSZo6ZogjWm0yrTdAWxP7oaE=	18d5ed5870ec787fe49e95330dc9e35b0a5f4ae420c110e8df05a41a90dfa53a	IcCWWPlL4dkNpbyJpqFoJdW2gx56HIt7PFV15gzTK3anp9Zh1rQ2fgQED7NmS0e6GiV6V3qA6o4nVCxu/97FIGiXc6aYTcKeHtXYiAOYP8Lx19TVL6BqYfhhKWrCL52/PRMzKYTjMEAyAmV4yujvkUfnZeLoUHKJw5GRCf5u058Wjz9SS9iYq8SEFM5WaFW7HSDFrZ8leY3Qwjl+kANgjg==	FjvqRBej6nDWluUD0uHJzoPC6rEf9idEL8j/A5QZYI0=	105808b8688b30d7381a335d9c47070274a906baade08b5cba128d69dae33398	\N
3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	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	bc02551fdf5ac29b0de7f4dd3197279ab2f8e7115bce9b97add50f6343657831	1	Sh3/M9x8cgcNTHoxadiexE6+VuypQ6L+Dp//CfqDCPs8S9OSNTOIqJwP+AmWbb6obB4rRXn9lAwI1MT/PKa1NkGAmfzNCQhiGEn4p5t2+w3SSDj9Ggt9W7+UdX412OPo	3555159942bc4262f175503a358937e8a3fdcd25e56cc7cdb79eb3660ebe9cfe	DvIfYjFT3+xtZYINZDx7xaABB808s720dwrP71Wpc6Y=	d192e22b51e0dccc3b5388f95522121c737b5ff09e763316f5ce5d9045a69617	k81BYQZCeW/yAMxNWDu+fTxx/NRj4APYKoeeuPOkaiRWphiHJZAqdzJHp8/q6Wfrv1zouoi33nnyyehQWdoLPGbn8OX02+QTsNfngCt0OisW1Y43rnO+zmR5+MSRc74HBj1b9TYaTo2YBdwDh8bj7Mg9A8O89VtKp4oSXl0p6XV6+4vFaBqyRTZt3l0i6clPE1uBi6x2+FyI/84h6xttSA==	58PKbPnNuEZM8vKkDi8xEBFWXu5oXJ16cXasFM948Yw=	06a1bc149d81369baad4f4f523521c86c75004090a81deb127df99a31a026ae2	\N
090386f5401a8e48b63b19d4c8981e230efe71d2d3f28307f98c0424e6d93f9b	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	cd69ad5eaac7d50cf9a054e511452166581c19bd13653f6b9d2db6b025f9b379	1	KJ1ANQMXjH/RA+W3gHaCzpl0hwkK0eXNMbbl6tDaGkfxCgtPmeVRKa2vjjyO1fwzO6uPtsz+5FX1EXhlP7U36PMWO9wzxmuecQyjnpNnNYHa8CqmEX6X7nsJZ75gcnHp	89d41b9d564b2c33032b4feba357793b38ca2eeb3dffad2499db5ef74187a242	DBg37cEpColbot/hEv7WI8lkStgaEc7KBUXArdsEHp8=	8e8938ca1a99c5ebc1d42595d2351f9cc02fb08792dd8ec74b47f5d2b3c50a2e	6JKErgAWSyGwzmltWaIDkg10fpeLD429D+wcLhYf1M9qHa9JoYYhsCa/g0/qBisl2No06n9GgtOl8fPLttnEMZk3U0odNqpWFj3ZGjU6a0G4Wh6tREqqpBwsw7Y7OkeVyGBICAOVOyHK2bS1pg8xCc2Bk77vo1Oj1S2bftqu9pdosK8u6Vf+9yqYIU2UTbV9OAxhyFJmCLhlxUUUi2eAcg==	Vxf0bcvhnd9VV4a6PQkLebA9fLne9fSnrLVV15YN450=	08f3b055847ead5a37a2587e06ee8c40c8717b4d4754171cd7595135e3b3fede	\N
43dc22055016c54a2ad7599b113fffa52bd90ea199c2fd31e4d11eb2bd536991	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	1	p7Qjq6rAw7yfSvlr/QYvfwQ3dSxDAStM/89yfbU4CKdZ71/ADMXAeKVyOtO9bX0FJIV9UlddzggKFU5FUx0wWOl7ZP6mxMboRSB3rxPowFkwTcUXlIV1EAlOPY3URX4E	39bc49d520444d695efa79cbbc32c66c82cb209caf0aaba1ea3cea10fbf57a7a	6fc38i0ap4yVY7rjEQSo5sJCzFZYX7KPxO+3kxYTJJ4=	f9a84320db54f39766cf809aa366204dd88135932d85c1ab6f1750e677003b1c	TDrrtzErIA+3lKWk/Eq+jnZhWLkXU+oJr6w/6QTRh9bfnAb/L32buQeyUZZkFhkvHxkdh8hqwZKzMOry7IvpUis0RPKCyDSxldiKI8OCgrhVbhBPyG9E8XrLJsBSDvT96GfbjSJ/Pbr+iYJrlCxgj48HiU46Qi5Jw+21+9efsgmgMbcbLbmqTnFRnJKxy8iIsGBc3qE7HXjYRR37u3kUpA==	9AFBfSrDE7bjWDSiyuWdqx0S0DnVbs5jTkI6xPN1qQU=	1bd030f6c83c09078fe2b7b2cdcfe818b57d8d4acc21cb35637822f89d672f8f	\N
5c6c611876ddfd3f128a4bc79219ce75add68653a4dd5db61c2b536d082c6103	\N	jVvrMp6goHKXfPZFEt51btOGzxp2yfwxCgp8o7EbmPO0ctHhkLEkl6GQWBpwohpLr8b8/dkCvF/NobvBHtXa74qQItyRDhDwC2IjaJkXNdsMUMlCsi89T8C9N9h+9HE8qjWvF0ubDyPKnhFOwH0aF5VNe3dhGrGmwdIExpNvuEwBJIlr6JgD66NKhckTHWh5aFWxo4KvQHqrkbrOGkqqr87t7kkcnCV5WrLHji59tSFiJfT3T7M3U1Qncn+mpIeuJSdDFPh8Se2LIiLb0SrXk8fTOyIpbw7AaDnIeVw2xQ+NOREZAE4gy4OoiSm7BB5G	d6QOPC1lMz9DPKThrPUEWg6USIzQeWkcNMH6+QddwcOtpmAArG+hPrNN4JkZOxjejqDh+hEGPEB83H89qyGMiIvoEISwYGoLWgYdgZRv7FKGbdfGdt7z3I8zELfNmyUAW5l7cV6evhxJsH80quxXg6bLMjAgahfshK4g9JrYCBW4afvQh6WhVgYLYF9bRNu7ssgGxXyPTGc6QWB4511mz/5WSkvEzGUZ8ztZJ1MlJ2Nl4mTIHN7KHRV/nGUVOrrsdvnPKq+P5OQIJp0CYtDDwaDpI4pd/p7GrjgjamsndPQOmHqx2num9YfqGQpPsJuA	\N	\N	d20502d7eeda4ed654db68afaf33a783aa33e0541951c0b82f96a9dcbb1c9f4c	1	\N	\N	\N	\N	MLPH1M3kFN9zJBcoV3cBOudrp1czkTEhhoGLT4IdWSqT9QZEXmabaplqpNCbporwIE1dGGz/BkkPqp5EZfQIPJoUpYLq5cnfoV14vUy/mSwYR5FJq9xOEY5xupv3sqTaVNhEqXBpl3EMueLpuwa9pjt19QOSUOPr6k2txNVc8FCc8edewAVqzIEngQA4OrngGuYgIEBaBjsQa6AMCtT9yA==	\N	\N	\N
3dc8e60592e1fd4d430ac77eb3a0cfff91405e6652051256c87adde0943d66bc	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	dcbec3071fe5b1def087720ef664bf73eee60211fc9e718c2def8ad65a4792fe	1	\N	1c09ef115e73586aae136413e373f77626adb7d57c72d803f9a71c764776f507	V/dEZ1pmXSTRCkTW42pe88c4znu92q6CzZp93piYZ7A=	057cd01612678817d98e77193916ec41402cc0b341e84bc3cf07b746b4b15ffa	CTYn5AUnegBKuV+oVlpB/mYE3cCOFwCvigA2xJHFtjnNWm3dIuhBgX4dWBvxKDtlXtRfcLmKRvvx3SWaq+tDxKn7+23XaUrtRROxbjc62s8GzsaGdrq+CXU3+JzCOVUiIyonGTPzbAgsdeNwSi/VSPV9eweJjT5+jxVV1UX3M+U5RN/ONPA5jqYm8oOTk7Pj+SZpW82Dz2zVMRf0bpmcQQ==	il6dNkP8UkZ/X4A/ytzQmo8GjmwJoBww3VslvxZmpOo=	935e90f2ff7b9bc9f1b2ef6c808dced75a02633aa07eedd9542f0de87c12301a	\N
873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	cRhFNuzPsmVmrgOBmTxWjQhZtB334zKjx5JdBbb3NqdSeDrFf0bjUY/viGC4+mwsXipFASFAgxTdnfsHQB6y1YpX4K1fGnoYiAUT2IYxdbdftQmyF8DgLTy3Nh2+ghscwg6ubWK3BipInAH+IBPcm2c1i1haWMyarVi3hCfWMbFvcdhhYrvInXCZbiXmEngPk0ja2L7gMMVKTEy/POOA8mFodtOxeQuyjSMkUJ3zDXCBC9hyqCSoz8A3f+eEWjHizY+qJ0m3TyoG5beJKkmCydEtH8vR8vhXdHzW+CXRgz8fagprhBDP1Y6gsfra/ahQV/ZKf2IScZSYsgNY9XMMCyQoks9QWlVDqIINI4TNA0oBPow2n5umemK9kh9IZdyyOA4k80zCmxHsUsso4oplaAo9D3DeUAzNtlPR2x79K/izr7hEqTa+qnAh40T+viLyZO6rNL7PQ5ONX2RL1L3j25kwMYzXUZ1tMXF0Sybl/gH3yFcbnnabYr90M37p4xcytJRGnDbjr1IUOMh5OYIlapnXSP6OcOo+sEL7+ZfTfiWB7q7yR0UlKDbtCZCZ7rVtxtAMz3qRxfM11yEFs3Z5eDrpZVr5eD53eWj3051ER/1FKKelhloa2cagSQ4cXT+1UWsYiu6aoGcCoONZ/+WfXMamRUfhyu54d5gzepNRoW+B3GO2Dfnw+fJlj+XPx+QFivIvOg7TFxF19l0Cu9yNTQ==	5EEuULJd62tQn9TCpBvoZTGgtVDnvvkik/hZ1tp57GQeuU4GVI4iYK5omDSo2Qp1n3+9URI1EAdwqWJvh3uW3U/R4t7GGnQwuaDiW+JUSTfcwdehTZSmrT4V0UfrWM3UCkGg1qb3FEkjIkVPDOjP/Y6kJP9WxmVtvaKativQVyOf8Z8iopoIQBC+si/cLbl8d1dWvBPv2foMAIQETh/1f17qaysqW62UEFXo2XZ98vbtFtdGTmYrp1K8KJZutr+/HFwy+oEu7Az2Fwnq3qXh5EBDPDB6lDBe7HaRyJO4U6TEwshZXgdq54RpKy6n+zmY	OqlJQyyN03PVDV5Vg+4zDUZZZRoe8oUBbDoVK1x0aJoyQUrlrXXg84TF1SUhExde4dYNMa1p/u29qdiqXoo4KrFqSaTKbJ+2dCwBN6lAEyXhKDtjZFS0VE6v6jjBl5Kfkt1sDVBvu34aqFlaUOHpnhJB1KUclrMv8aeavFPvlWIVCmI883uTKvgoDf80Y4WYwXwMr3spTNJjvdgmygE+CYc8zcgm82WAe8FHsRjQjzi/NDBv0CYfxzOrMFUhVI8DzML/dO+JCCBhcbDQP99Jt8sks0Ih4BgWsGlHeNK78VmFb5UWPohLUo3ff69eqc8A	PVKRmQyypzosGve+uq/++8v6aweskFZyokt6fkkLZZzSW/oMBt2aLbC3If/CSjF1EmlSFUxMc1R7C4H2RWpmrBiqf6P3bgm9vV15IQwRcV8//si13VWXrD2wfuTdmPkyDfKAA0yQqP+sj7y0fWTWhqnWjEqcs9VJaV247BrjHwuM2hIgPXd8a2I0QEhe2yJ7B6VUb71Z/W9fGxAiCGdKNtGTKnNoXzoR4Loe7cRAK57gDKpMAzpQZkVv6XsA75NBXXflFcQqu+x4352jqyQKHfKUvJ6Y7PRYSGaqtQIpXjnDBtOjPr/SACiwJ34HedEX	FwHl4q+yRhYmHRTeBiAme2tEgWPzUPrBDVDLGqt/dmQ2aDOIqfZC6v86Y6J/wkj3DKiMqFT2xwxAUrPzmBtdmE/cibIKZZzgJFmiOvOGh1bUtuIMNopjOvKDGSAcSMOHs5thwi/z78xhQEKRIoyLnCLOxIoJL/C6t+Bwcq2CgaAG5KE/lGj77lpf3vCnGc/TMsnr5dQKMH91/AxVC4qScIiY1K541JUQGKm7ekRtlLibTUHsVPQHpegpMicq/hY+1zuPvpBNMTvlgH0wEjk3mZqvdXaOIC5dMhz5Z+UdoQnecUYkhQc04bmVI54fF3bO	ce80f9f3233261c3d50b353cdf28eddd1a0ce99f0b91de0655fa2d016a941504	1	\N	a2d63848ad069bd44e6a1048d32e11c310865aa056feec7a82ceabefaefdffa4	FcMSOeeNqgvrGxtxEfO1jE27B47uN5E4PPlQUIqqFbg=	3c8b0dbfcb7908d4c78039f254d5f46f793b5fa503eb9dc2cfa70387527b6e21	6yY7jFKaOAWo6YVGOfjqSjnrzvjgqZSaUJE3S10ZQnRE8Ll10eXi44eyI3MKqYSTkuHDtqLWkXorGSNBpTpBy5wG4wse1fOy9h1+MYEnSeGbE44DXuyz3n64aJDoLydnofvZ/ZsINqgKVzRg/e0iBLkbhZomaZjMFLtjBYnEqW/8ibBS7hhkzFjTzplh+mlTicgkcrPl8t4/m3NUfWTP+g==	S9D68Wm6vHRSXOimdz1L+GtxA1ng4cinLOPAen3Qm/4=	c4ab949d778f36e718609b31f1beb2598b4929dd87630b7c5acb791d34e2b18b	\N
1b70ecebc36f3c185d22fb87f3c192917e5d84151f6072d82fa6564254e30211	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	47c61b297cbfea31c1f9efb820e70ec4e07b2dc1255011a4b86d608e00fad59e	1	oTA3dEIXT8oV3lAgelLdebbP1x+uHRWv9vfiH5Z2TWnMBEP4Rxi42v4hgM5ZrXofZdJRq/8MRz0CevxfL4bBxEgWzPbwUZyVhgCeItHB6GCH2d9fTlCfJBjXhUqJ4BAa	b8b89cb3aeaa4d06fb4a46bd5fc241394f36ecea156e8743491b188aa327b8b9	YWOZF7chYtbAtsmguSIbN8Qf0iTgxKkVRkK7DjYoXoo=	939b5a38a729981bcd02de414ec6638bff3e8576c2561a6e1a6d7d2eac99a0c9	Mwync5JKaCvhOERQMqkPOPR1aXZHqyqxkMl7+ouhjl2oJVU9Zhgm2NS5bm9d6T/Mm69FJP2z3tb0YEjPXNkLiXGR/SXPRWIydyY025PEOvWpORKNr83aDlJx7qRaL8422wP40wbSSMpr+Qo/fTqWxZ/g+YGcWieE/mUBuh/tlXJf1MlHQm/7IJhy2W8Mg0R8vywQvrw5WsR+PTZHXXFxQA==	M72BSoIpcTyQqYOb5/gYZ+/jk3QkMIqSdrgrGE3Q4NI=	a5255510dec1afcd82ece0bdc1a592d24b54397d71e76bcdd7eef8e8ee2df999	\N
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	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	88a048c60bf7132862809e88b5a9cfc5227ffc0cb084ce98809a0c90498d5b7f	1	Lv02HBuFt9ZBUaS71f1IP0aNZG75+2lmAjOUNbQUVSflCRbv2NTUaTexD0vpmg7xsLHXdRuAlZsZHvh1UxT2rVpJewrkf/ab3DAUueF7orZJ96hAH4vnsfN5McnCYrWI	19f6729e425bff201ba4b473bc5ed5d0d47786bd0b705d00db5d496a833cdefb	+46AnyXlMvB283/nI79Iq+dCpcyiIJ2qrZUD2KZ2v8E=	320d48b426fb8bca98c71257cb6ddcf2552f858f27a93ffe26bafcf7d79b5090	uHd6RqYS8vG7Ad7JAjAPUp5CkgVp9UCXehGyr8/QpUob5mNWQXkvDkCa33j00xc5Htt6Gw0fHzZYnnlvxNPzBFDXAy5wNim5mGhN0CYn8f64qfy60GiVuA0f2wuW61Ch7Sm1v/AoaioFEIs8+gZC5AmwYXYGhlIDAwR7muNaAyLZQ2yhb2QRqe/qpn2jNUGJtvxs+fGMmV9BAER/FJBBEw==	3WwwU+zbIvtihQ4jiySaxtw95DB2hoXHUxG/jdJtyhA=	3b54bf016bd5801e4fdf52566cc68a48c623d82ccb5c7631c82b80374e2e7418	\N
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	b0530477067892479f98fac864de9165c4b52510a7c9fe7a578064faabdb2469	1	TUFyzcJCtLAzjPecKTQjzBngwGk+ysebsEyve0bcFAPXQOU/t3DRcZuyPMY6bgJ3z9sXy9vTG3fcjfI7SbQhY2CPjokwF1lxNru7zMsCX/rPhZ0rLYw5gZDxwltbDn9a	51f2f4bbf3945f8734e769d6e1adfb0fea35a96112e4736245b1073be3cc8a37	mARRFQJaZP2jmp4vp+boF/YXNT7GB7GkLRm8ISRwoQc=	349925418f8465e95ed06086831db218f41f355786540f55705f8edbbfda9f33	YmZGrdDm/hQHKPfJu083ZxS7wEnrZOsEcD9h5eaknKUrqsCT0jtsmbVZW8V7T4+beSRO9iO3BzBQH5bCwWcpbFC0afcR7/a4xFDVvYU0twBxytvsKKdoR+sC0g1CnLzvf9qMKiSaPKg/pIdRONJD76HmD2o7Fe4/YCfPvNi1r2kQNeiRpteQVYnmW2mYncwAs9UJ2Lhea7L3SIeA01fwaQ==	LfX5yBjByYLOpgydQ1pcXDha4h1bd8v7R9GHYmqd+ZY=	59a84431bd7de905fe9aad29f20c2925bdb9394015d7b90c5f788cf90a600e19	\N
1be888d0f72e1dd4cf9830224618251944a749be1760835da9da7c22bae70c11	Yh+wcaVEpkk/J3/yWAkI4f++12HV7mrJwCYeMctr3aDnzzMJpHZNrvKJ5Diu2CkdH7nivo5jC41AznI4KTGL3JZKxnMzQPZqLYOZ+FQVBdnDRmHQ6vaH4OSjKSlwMsE/269kJLDLuxeLlEJeGHNEHMEZlrhU7B7RE/ieoL3al4LTnTLeFWWj1CzDWuf5CIKPUIMVP2eU4mxyGSCiR6CxH0KKm+0UvTZDqxPpQ2v2x+3TBeOA/FdpijGseADMOlxZO7kxwmvNxA5V/XEUV9QLia0WkclRbwjXZxlZe/WjiJA6pNhZPU3hmrCvtr1zdvhbznUvyCGOdqlO4xQr5U+Rcxs13mJ6GAS5fcCKilmHkk+LS3yBcNdpHpEvZdOFg98+HVNqVa+we1USIuYb47gTcWmqyrklPRGdSavG0OdElceDZF/lANQn0AdJ6A3pxjAYtAzhpJnHumULLP6DDxtUx7jv0sqnjsxpV+TNi6hIH/NBH9s9DLnUcPsp9IH6CfEnNnzkntvv8fRuafqzh3lhvlnj/7uxAKPJ5UHT9wSl5JUFsCDD/CxxH0zoi8lnjXwgiZ4WD29dDrZiYSscoFG4euRtlLUPpoqiviLlCCQ4JqEbmt+K0dIuNq/KUqNGjGcKhoSSlEMsguvcemDv5XdRLoBhQX75qb57nrefaGbU2lz4c23pFY8Qnr/YQRXY5EE/t9spTEN68i/I5c0QCE/7+g==	zz8gi30mmFa0MP7TEXO3GO14I0LD64+RFXfLg0OnXo7zc4EcSZiobHeW+lWST5BckCGGRRjDGTFWf4NZMq0I/HgShrQiCm0KUOHxxLhEs+yofdCzmaYyEOpw1Nusp//MdNf8Ie5ONAiDdLT+pejQx/tMTmsRKeee5T/8nhLmgDbHK6ZIdTVdUVw9QHoiy+WLDcu03c8OyVW+iNINJK8hJUoTsW7fBHDzt5HLu5NqKfpcn69pdYBq6CKl58tMf+3exFWZoetc0HgpJXf5Srnln/G50OfShFHAmYkIGtiT8277xQz275qb+FNSrLHYyj9K	ZQDQqczBkaicGqc6se/6kQX8nT240JJo18nLw+7scZEIE+wcOUr4+Gu/a3nVa9/KNeQmQaL4O/zfOuj3Imhk5FYYfoN3BcJStM76Rz4EYEZwwGyLOz2P0MNlJ9KocRRKyRJmU7tSMgvgKSTvX8gqN2Q1bFFqpNc4P1oPi+coZBplZDV4CKvVTOA0HDZeJddvkiAopJ5yRkgeJv/aW4HlqbjBnOnG1jUUu9DR0UwUufRInk3gIr39InE42kDLhNp4T+xNVMI174qr0sMHKFtehCUJFo9rCL8Dh44mHr2pS/SFprbjL8IOyiGIDnofHlQo	0CddsQJDsGE/ft7aD0oeSXdREa30I8qvA4HiNYvN0SoPI4bjyZFDz033wZTKo9Soqmcf9FzO+8xAPUyxP35M/9b2Bc1FW12Wyy+C83oCwfmWsNYv+giEYwz9QAcyIcKWtvnU8mWWQwIlNF6K3gJa+0zDo8lFn0jgLx1NtDCBc7SWpp91FZMfyKYt4oLINnP7zhbl57RwfmJejGvTqTzmWhCj/Cgd51INtd2viw/DIyYe/8n2kjWC790nVU6gf7b0tnXMQg3gUZsDUVlM/uq7wADsfbLz7zc6/m7CPdUYuZtVY/oN83lLDd9Tpvq8IA0g	GP0Z/RRwWfPVlfghBiyW00YyifJk4qmxKpmDUcL5XsSIUTaafTuKDZeS0shPUIRZYTmvFhw1Clje1XHUod2j5jz24JH70P54WNNNCxACRoWqBkF5+43kR2DrOPo1tgckffJ9By9CiQkUJJOBkWiNmdHXrhF5EOck9OH8M6W4zeEF7KTJUWnviMnihx59vdIMTk55bcFZhzigFxP1lq4B3xtfpZ4+kvSZVib6cX3VBH8lXHNI4IByuFaZD/4gpndDegNkA3JIkkv/lX6wZ/++1mncQCs68gy1Tmj+WxuSiKQt0NOaHn6umaOsiciEWUYn	43431d024e05b4dd1197c44440e16516c5f3c7aaf552bd71381b27812b07ae9f	1	9Wdgm6ko/SCixQ+FnlW6waADFJgElmY9Nx2O06zYxD8YRxcNZN1CQZ3DnZ426FGgpu9ElczyrzQp4AADirAgcqd+agZC4EqZRb+gwE/wp/ZUiJxdO4UnkzIiz9xQvGrh	9cda6b071a866aa9f1fce302f851a251238a1f5f0fcbfad66f273f959f189a26	ZAEvb+W+1142sI8nEND6nQ2kpeY8XY2XDek+teoKL3Q=	f08622bee06c3da141fe9298cff09ff1e3ca03601498208048e9200699cca2ca	qRES++I7xCRe6tRpB94gXZVleiHfHOz7eCKvLAlv7WRMSWcsZOFpLSO8NtD+PiJchYmDAG4DrfWf3IDQx4h8pmVcB+S0BqHCobEdYY0Cfo+BZkJruCoUYcaYiXPq/FqOkzKvi1RjAPPj/jST4bjGjzO757dchj755q2gyuzwwSznQbGlyRt10TYERnGqM6bwm71+51XLBHXDF3mToVvu6w==	B+MiTNaFFbQDb+6481McL5JptAWcw7xIfgKsJZpBinU=	9ba334dfb50b4f07d0d59e94e7169163c4a139937ed9f41d266fb0d884ee1372	\N
2c9fcb17f3e35a5d2c17ac695b7d6b331f6b2220693ee524b8b202ba0ace358e	iTQkB7XWSklvfsrMwlGJClvkeQBl6b9SEQQ43FJWd0ewsKp2Lr8Ep5h+bqbWY3Xa8Rk9PUDbRY+qIzXbW9TBLzL6u9H2zqXEL3jdExlhZJiE+Z0bm/zFtak/p2gSCX3vFZ1zFIZ54+yRUzuiP8yy1J53s3ilUhcDINaFsM2+mIjaexD6ZxkoQoRITlnEPzMEYWkPQ1LxxRqhqD/+4yD4PXB3Y5b14w5S2c3k7RGJFHLLtwivxWpiqou+57zyL+3zI3T9ix5pCwjSvCuypyYUNeSsLUGERKXFd+HSzr96YNckDrpCKGOzRnxUI+cfx//ZOGDXUvaGqLIk+0ssoZ5VvTDcuYmKo9+WU5ELSjBik1BTfxmAIDFE/7wOmap/vKTVXkHfTmlb+M8u2FiVXqajyOlYMiuj1/AlSqL+2dQSvupMf5TjyYcPRIQpERZUTwXiUW23eOgF6204Uni2VJol/VS2GQsaF2fOME52xFpnHW6EUomzmmsP51KW+iqiKYJVxZpX7YQEnWDhNn1uVJT4kYnklzNk6eqrx545m+BIgS+tYC8tJZ9mhnLbBd5qp3Qdh3h6lH12cOErIWDbMqp8Wvdzx5wXf2p/YwUQPsXzEDr5zHFe0dTnPH+fuwgQs1eV7Tinltdf1UcgUzmof2/4B53H/SRKn0IZOzd9vC/KP085zGDq6vW5qj7ac7ILtz0ZiOhhDkmkDjxDOcrsUhc7eA==	15k6kW16gyvfTIQ05z3Wk7PG7GGgDMU7cPy6ckhubZVp/3AzoExS6tsQf27FmFNL2ff9MktQjsMZ4FOCUKuh9/IEWqdZz9YBhuEaKyvkstWX2TKNoyCf8NDZ0Wqs9cbAuItSMQmHKaCA6YGRJV6zstVb/pncdcGvTa941YONbwQ4aaveauDZuTl7v8wOzHRGdwtIla0+C/Z/AIqcBJxtFUF8blDsiV65Dj2uAx/wQg1Z13x8eouuROCNqRM7IoMNMXFcMtg8nqwLMdc+gwkunFlSswstbODm5b6/+ZVKxE8ehxjyOMPR+Jd57VxK7qJm	ipQHU1W0QKoMKYY2P/oZP4ibmZQfxFz3oA78C1OnUW8P6gk3v3LLL8JpFmn0UAiv/kMUnQHKUJEm8kBlFDa+FKRw9mt6lty1aKw6iIaR4qe5R9F3S+0qPN7gzPIDYbypIXdzw6y9cYq0/wNF0hSewYagkCe6Qk3cOPDCStVnx+eVkMZJ7q/JwwP6MAYc1TzRrn/acXP5nSm5xyUREEuErKyIQefycEKA7gbptqjVioxSOet01t3uIL3gpaQMYM9bLgbZDMIx3+aSIo4dc3tc9biXQkCJUknhdM6jSjeKVIvNFws5qshoSdmRxvmoaP5K	GeOKXmoxpInbyO0/zgTkYtmNjq1mHZr7+S0W/kagDOjP5uZmF5RQLarpBBPzzVVZki2Dh5i0/oILm3jnvNjD2BSjLfuQnEB4vbwc8aMYvbbLhCxXYRMvi83RTBd7y5FJC7HGxRNZULlrkfzy0Xlqeryz4g2kB3IlmxKeIGgXhmGO2UiM3NbfSeZ7vPrrhiGHYUaF9QZ/lKdtf1sn7X+x6s/vJXB7AVzN6OnzUVtGy37ytXq7A1Izrmmzm1YPtJLCs5//kmavVNeZRYJ3gT4d1P/4u+HoLLJVxoEjUfVl4cp/nA0fPQ8vuF6042DQ65x4	A8a9nuLIsfyNYuNoVOnt9KCI73AW8a3Sh0UiPqLwPhQDO7GV4In8gSPX2yZj74cUPtRXw29SF0VyMXAAxTvjkfbRcreP92U1uUXhHzUZo6uXdFPQe8tHG7uvj3hwXsNA0EL8AAmGLLHdJo1vqoZNs4YuMsA8qjAtPjlRdiURehsORGA3eou+Y/jx2W/sOV8k/bd9oE5TrUV9dRrcquvoSvZsRweh1SJA5qW//wyA3zkVgrLxEcMDGUQlaoExd6T3/sn2X9aTlEcMCd9UgEhv7opWUFRbm3Kfm5V6ek7XA8pcTFNQijhBmiLu1oIw38tt	708dfce1b14d4f00386adb3a70900268f42ef8c407eed645ed92e3fc352e94db	1	v5NdjdbHDF/pFpT7syZ1jQNXiIZKu3iCJkuHSn9hfKaqqQmP7ExErezPdb2KupVdKl6D9mStPUu+1F+5B4/upn3OGQOB2NoRv6kDsMvxI0Ra5d9wA4lUy0sX7coAI57S	3fa046292f2c101ec1f42df5cb820d5c5dcd69bd742ca5ebb20afc3fbb30464f	Im6zn1mQhnVcJEv1XWXGvtHNPz/1B+SbCooLpbHI4mI=	03e331a02e572a3b8ee2a76dca331fb19024e04fb197526e7fd04372908b4536	yaH5kP0yOoX3YTs1n8IJBm9Ikj2pphVOKeepl6aMlhzzgz/nijOX86phZwVGSOpvv8lxNOYbDhyP7x+VOlYqi5Yg8hXL/HZjAuYYxqmIHOcQUYpJ7XEG/f+VF4DMpi8jpgstoqJYNulc1GOAdMrwvdTwidPhQQFzhdZ7T7Vl9utd6ZGGQtEkCLwhTDGMkJ/6fpwvEtipp31mkRyCwj3duA==	cp9AORfwUPO/EnRCNS/e4DsWIZNgFQYBt0EnzrhS/d4=	d36630b04d4259d7fa1476b929dfa153f5544973b249f2bae59c19aa8f56a3d9	\N
1b40f08fd133ac1c9e745de021bc15f880b58aeb13b3ebc908a42cd4141767e6	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	c21f1ac9808ef246f9c91227e2bca4fb57f6b751dbb96850139d133d4cecddbc	1	IsMDMlqBKlxuwodKEvMDKsgVxlcCAAN6qqDft9OB9yb9gjqvFLz0ZN6z+Zy7P2uaQzcW5kzyScjLWqqoHe0sd4uupOPT+7hpmx53rkoBSU97c4rtIa6DtxBs7QJUTfQw	3d02fd56772306e14cc4d276cc6f5a262f8a43685e29b2b6e32f11a179bf907a	dIDNZczYsfOebTxQ6EX0cyl2EhjSPAXgCyEgM45XZ14=	aff6b9433368e43f84ea9ee906ae95b47cb1532f54adf1a1db9789dda3261082	lw2f5eAOqEi333HUGHOY9MFHgqOHM0Yfw3j4JQkCfpx5WDMet13hnCUBjLMT1odLJoOkDtTkIVgcXLy+u8MkMx+e5ORnhTqIRJErldsij+iVolZZEklFY/S+TO3kFPGH7UvpI5l6kvWrhZ4VpQbNpG1BNJ7ONo++Y8pw5c5OngWLV6+t9cBCcCZozLpI6udJAebUbM3+M5V/HO7qCCgfUQ==	rKK/YxujZkzi2zvWsbbuuGKIcuyMu+0HwZc8DhhgG/A=	23d367bfba7f076349b400107e9337fb9f0fedeccf2317c20b5edb42b4e753fa	\N
6b3a29cfe7ac1554621493d4971db7abc2f75e3c859d2715ec362058a9c9c3ff	tEEdnHkWiiXwP08vOynrLUYFUJBolYyolYvT1XBrd9N0oVNwy/vPNO0+lzgPXkN4o9RR5GtJGbrKCyNSTl+FOaKou871qQhNNNkzs+PnutrktCMOvqT5xyeIvfH/J0Ix1LOoqZeHRZLGnQKU7LwFAMCtfSXLBbiVqTe3dQma4ukVjKRYewTrC3dTDW0K7dTe3TQGv/v/AyWUuQvmYYKgethp0+EM8PcztG95ESw7yGw1jIEmwtFSadSZm/SABINnomISIK1K+nQLzqeY0P2dM8OnqPB9FBle4RWG28SkyaWYvtw18iatXhIOh8HDIjGByuPvJtSVFU1KQVX9nxf9+a2n/UT+A2VBlAWVAbn/ZXg7odo6hHtljkbV1uRhcjewfScJqU+ZIX/j8G/MRUrhUmdTn68xckYpoKDzW/JtvjO4cWe0ZkWR6RKExa88r6yztkBTrA5NYy7RCIpnENQUxqq/9YMUb2AUx1w5QnAA+m4JEIvRM/iPxyb9jclDJMpluCgpLsf7jeFjheQZZiCmSHpmndK0ri/gkY4jnhvl8Vh54OGbEjT2VXdqV8eMFpVR7E1p3zB94gckQil0Z7xUT9UA96NZ6t9p/oWsWLrkikAn5sGFHyFPZj+ivFMREVg2O69MJWCH91t4QE+MMiiXmuUEpd5AXDa4M2vk7bb8D8JxL5lKSGZlInoIX0u55XIYHX2QYv+P/t9C+BiA7g6iPw==	YBEqFCwPtTJU20vo8/x0aEVVy1dSqKyrY6egan2G8qnytQsQd94LYKhpoCc0VaJMIduKoEBIH390Fs7kzGnV2qDcTomyEAOm1WKjRBPaqGs02jO7QwKMLYzToHxLddPTeB75+1M0m9mz3f0L8id/nFWyZfne1h7R8nCbDzTEgD40C4EM43uuXquORUv2pYYpHFBKIly/weA6CDgxTSV4aWokSCeRmlVRPi8ET3W+8EkmZlJ4hhTHQtc2doWEk2puROEPQLmPzQLwOSnmnrHZ5iMXBZT4sWNMsihU1Bfgkl7uDHU9TVtW3IUqyP/NAo4u	Q0gE6fdPmYME5Yq8hyNHohtPYfzndgBsqOVr9shAZTyKlW4cydmykmYuMzrdQdAcqgrURdZWQDK82fE8T2tnW6cRkQY7/oNX55Xr4aMgTUdItrcIXy1hx4FGMAz+huG4kr05u5F94sa5bVVEvHWcz5FJiEMDd0WsJGbU2OzCZZssqm5psFbIdh02Tgh9SbBLmPDOjUk8+sO9OixmYQYnBRCjzfK+nkAW8PRXJLQtayliY+oNdgP8T2VkdYzZxfuANmLiidXnjCeQFr9dRPM/XKvBWT+Ggy2MEJHPGhUZo9oISROC3b9m1atYpjrh0s7U	irvmtIPg+u6fVg/+gdtBoMu0FQZq5nh5Rq29cysc7NQSz804PBPpSKW2Xo3cyFeQZQGJ7RcufmDVqgwpLBi85AbszbXfH8lqHqHSehYeWklUHFyoCEdIPT1EzJWRTGrwxiERDmgdRBre5NM4mCNXyOyfaFlGgs+fei/miydoAgmNA/aBHPOeq6aSEbmLNPfU23JPyWrbdgYwXip1Fi9Dbb8ilOc1SEDZz/PhbzwIBxP7L8OiJDdM2fjHhSEtPg9UwjEzt2aAmBlahSKGnt8mZSdqTFbHF+ReWlaLQXzoqtrnD2+gInQJvBU8CrYcn1H/	3/nLsOu2fLPidVG4CBkK5OFPa9zcm9hL2dMeacC0P9ZFgwoSbgCf3/eQxty9CbXY9DMt2YScyH8OQjPibYoUjPaXl3IXkANqtYfjpl0aW7ELGyEbwSUKE+cz3gPSXS9Q+I+xoHFJEhHfXcF9KpmoikwxXVn5GUyZ/U548yV+kY/vmcZI8HM8kBqxYvTICa6I9n3BBN9yoELTo6mLxHvelrIKEAEiPdeCfp+zwAgQcDS94qNTFuc9bSzu9VPDF9zn4Odxvbj3dGadG3NVB/hxZof8+SdL3rADXU/aVrxbXM+VzIs1DS2XKKK6IAx8fv8r	0d4347bc208bc022b871949bb159e2595a21efa16d3610e6b91399bd74d272bb	1	\N	5d52b30da5b388a0c1d4899806e583b61246fead15484c408c0b68de16df6054	syEHnykoRS54/81S3E8WnN6L6YMAneK534vdIoBOMts=	8037466e502b9a5aea6114db3b99944c811948ff73a237cf6e12a10c10e0fa7e	7oLBPhd5jZLYM+HI9AqO39W/xTpNwRbfb9x6urWhETYY/F8SGQWa68TUcuUIPSojXXLImli1E+6ZSOKtUToafurqRge574NqlFWP2z5Bvr75e40j6uXOTdLHYg+nAKduvW3qQ1P1HCspPpK6vDqk7ctj7wbDb3RR+F+cMzuNYd20PQX8NIVUBxRjplQ38x3D6Y+uTna6IhHT9QpBcDIrHQ==	orFYRZUot0SAtNd92UYf9MJn8Xupm7G4GoMVjbctino=	d713e08c4d054b029db1e8b36b0e7d57046628bca1e1bd6ebc1dd8ce29f59c3e	\N
ad7025c7040d1bf11df14afa54bac054c8fa37362d61f6dbee50605aa2ea801d	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	42ed32b9529650d434c5375e529c65b1367dd7a6e5c14200241581e6b99d9073	1	PSLkc7ghoykKbbSuTgpbU3/2kqp/twBFoyyIhfty6qSnL7uju4HICsp+oExs50aGh/8TOTSauz8iyMj4Fs9gt+tOFZVcuTjwGBxzZB+g2576+S3ih6ccY9WIBxKDY3aR	db723e2a9c1712548ecef5c3cd17b866268bb33754184ecee76f8441d3cf34d7	UN6tWqXx7wehOdvN8GkoKsdo25jxSlp6YTIba6VZztw=	c0476958a19069b08131fd625c28a6af9769df5d010b7b362e3820723fdb65ed	y5/Q9D+qCj7UxloYO8QXtr+tAXv/9hZvHnkdt/92Qq2uzwBpiaq6d3Mv1OyHV8HYDhNHW9TWCs3Ml/S8SajxRJdXJzcslqS2w5TWC3ZLd+yZ6xXCNBEsqWQpI9cnmIKM7bhQ3qYtsWRTsswzE8g6478ngMl0f5fHmitSnLwaWQGB2dSjHOCdFW4RX6VrIvG9ickeHhNwgYqtH8v6CO6hpA==	nnPUCfijzHDjJbCZFd8HP3UKXUWE8iT4Qgx33E1/PKw=	968d1fc8c041af3373fcbb3870b9941f53e5a9cb10c477844b4340cafe7398d0	\N
9627105a92bc0de742b59643c811781ee9fc1c10d8b7c7dbdbece3fdf55ebd17	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	bfb4cae7e6ba40f9300bde2989f74284f7bec970d2c5e93e33b26553e22f6f47	1	isgNhbEnot8XGIiliEI+zqAijfS2ULiR3FhETLLvnsaT1Ra2ieuvuxbHYDhvakAcfnS1ulGhW9UfFeksXGgiQVjKeyAYb495EbKXXSIAmpYr2IVSqqwKviRYzpFwqiNT	d7ade8fc766ead53c3990785a5c6f59fc2a86c486d279f1f8a388a315de2737e	pGE1jTgcfFSJiSQmbfX8BTUs25yskMKdoePp1CmMkvU=	c22a8cdadbf08d81dc27b83a1ab1b56240d2d6bf099220933e3e201686ce13d4	iLwzmXMyKYNVCBBizGyUjLpxFMDON3BFFLhN8TEYXG55giKFITyre0XMn5RKn03n4pM7Tjs4QM4k/1+KtY2T3KY4QuBGHThBy7OmLPOBNQ2iKaiO1aAQKslVdmUDEdleCcqfuipJSvXZzn5nGArboevpmXPSzlqThNZrJ9zTHT8bhwKZQf520KSoHbCaHTnDQu5HYoKuLyIbUGYOnGjCpQ==	zlj+yDhsq9Dku78kDBwVxHaDW2x6tmLwN8B/o0Qqrjo=	b387003f7cbc5279358dc9f14a594a718c0126492b8d8ccdd12b3cf5e492df33	\N
8361b4d1cb16d9ba6b4f6a430c33009b37d23610f4023ba450ee0240c6d55bbe	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	cbb9c819aaabe9faa1a28d6e6c3bde4c0f017082741b8204ee756ed0bec558dc	1	RuuSaEAKNfTWZlmP7pfaK89kL99haFHTM910+0NTjsQLmcAdhUYKGoq2SV00zrFXP3xvt1IBoy79F0zutrsjGt/k/GSOCFBHAcYIzZBRFMvCj7BGLegix9M0ZtUZWEtx	c44f178741aeca1a24c9d448b8621477da04cc8503462ada216416e1c5fcc488	e4YXiBOoibJTCQKSWd4IO1c94Couqg2dK9iMyihDqeg=	512c12b53191d939f8f24b9f0bec355628f670c7f59dd919c8f1b14a8eaa809e	NN9axMAJ9Y7tvWoQBJwjInPFgzxQ8pFpesQ5LaGmhYKfWsHIH4fyxVRWR8R9c6yP+DCCwukOsC7AGJ6q0ul7WGNzw+sIFU6t+abXz8FiRILtHFxCYV7JJwBzcVRHAJp52iJBFg/AUlrLoF5HzI4hVk8hZqRTXLsGqETEoiG4M7wkdzZmCtAWv8a2QrD1RlmkAgBgmWfTiRq0JuAZd9PfDA==	sSnVpNSwLnw7wDlAQvEvsbG140iqH/h8JtwLIOmCfDE=	1c5b41a20a0ac74dc699ca88752df7bd7b19091a994e468b652167b118579eae	\N
13f9f3b2c5e85e2e4c204d5895902e1a32fcf391daf4d8712b7ac6ec2de41d7a	c61ZXPQVfkdtsapYlSG6ZF3VfLYWwaUPeHJLWL7BdbbOp5mIJO1JYgC1WJqcD7fmdV+PXA8omU+6e1LvSqd49rTbS7PDMuql34EmpO8NGsnkVbL58NBhfRJKK/X+uAx6m5wD0hMRQEQy+If8gQvPw9YPnyg2P3TDX7qipAkqfITskId3sLuVmRsGrij5bmt/B6BDy6k4qSYTTfhHwQZT9KlqyuNLlRBAyGFm073MDEp7zaQSwPJdHhkncyeW1y5WmThxrqqiVJrepbL5o7XHhtwpwAOanWGLsggUVKD6a6f65yqU/uu6YGn+zeeOxxXSe6fczJHA6hUlxxnc4h8S8jepyna9axO/bQaSwtdOIfugPX0loMdN1o53tJF9M83nqFe6YVN30Cwq+jx3yUiSvl2nCtjtKL6x/kHbWEXJx5UrlLHqKbEQ1KQsUusTroMm/1KhXcKnwaGhRIG9Mi3vNJfeNY2ZNLYjmzeTYhSKtBqOfSNs38hLnyDM+lrUBw1tclr31Yao16WD9lzmvDx7Dko0BkLGYxZz/g00gFISceQTDQ/uOPtSriSSwOZTyL77nLQhwJTThQ5GGvwd/6tACxWaYzHqNmzmKLrjOU7MWfoHc+90IkuVSYDUCUc/LiLeOzme9vfRZ++V6YIwAHCB3LVLCd/sTElDNiW8xHBp5QDNAUaeVGAv+dHfHb/b+QpRw/JTfvl4vnfWY/wAAo5k3Q==	SVZIeeY/5dXDfnUSy6Y39nnCmdIVuI+Zcnt+4D4RFl0Bdrv6GnFgaQr6kfmU8oRb58gDLHNSQF3P2H/HyTWXNq/ilOLy/borh6XppQ9K40cfkMWW7q2UPlGHShQUp2qnSLJ6+K2b2lvlrcEtXtwSApDA9gi0pF7LNvPXfzBG7lBzHqY1Z8f1Ge7nrT/TppzmBooWQwxW86JpH4fvpjN3prYk48bMhR18hAV9ZtLZ+sC0OF6dJOcpZOAdrJs8tkvtT54MBxu9XT9U8CSRrXEKP0pHAejuSh5+eb/NcDbphOjl/MoTAlaUwG3JiJqJCp45	YzIUU5ib7a5x6QCTmTJFxa/ZcW9KEzgCNUOHHdtpxo8RZkjGpDpW6kNLuv8pJ0znPfZn8ub6bxA+a4cemlX91ZjaNGXFerAtSsPJ/Z9r+7nPxAYGp3qJ0+SG1cBby1j3DRYLuyjoC6CAovY2tc4ZgNVCMmCp5wZzRoPhOq+KWkxQL8Au2MDrfPN6QT8XkjgQghYh1fH8IBZWDmQYNJBQW1SCBAkMGP+lMDWNIP2jUlD2iDkMwQFUEsnl3O1SUcB4ggUhKoTshiPkDo8ZUWa1y07c0UK5zAumcANmpqgd+G4Nio1/XhV9/BjLZMtNyF4R	08QikT3tMHdHkkVX33kKbOCHd15iq2Y4gIYSdYxiEYldmtKOCL54saPy+uxTmVmUl7icdJVngpRVVo96w1Z1KDUaWzGZsM9HczV+qmge+bhbr3FjqCxuTbx/XT9OOxsM1rtLmH3euT3auiZO2i/uehWY217YdP6Q1WP69IsrK3HKLoztwIt5i34clgzroU9UMDMo37XvIqQOrJSnLTCLJnD9aj6okJ4gZCtkrIsTztggU4cWrTxKlD8aQfxZ9pn0mRyvRe4r8fRNEtd53P484Fqd0D9dxJ3nNCN+FXbyD2spsE1UT9c7Bau1FL7qmsv4	Ep0JvCRxTNTq95QMWJBDmdFqgQ4xvJYiQ2lEJF3duNm73TA3p+JXyOgYPnA0BjIfEXsivjPSq/vWlafcPc8wRRaT2SHSqtAs/B/ewjyzmtoQh5thBtiFQ687eFeKYZRGubs6i7ZC2YK5Bw9MEJaw5nyQYY45DzHdgsjMEsZDZ3Pu3qZazfGic+EyyHAJHVIs24tEk168MBU+1Fk6ZpnR5Xrk425x4TxWFPE9pBgYc1LMts7k3kIpYu9+bHbhC5StKdfTprznWK7DYuvWNEsxMKD7rAcHWAQA8orFMd5QHe4/ern1l0rBW5eTOOyTYXAD	a6060965ecc958b983f485787e5a1081f4885c50d7fb1a5ca6a9ad56fe283bf3	1	zqAjRFThSqAbb9qmN7wM8yX9oxeD+yctlwLHSnbqq19kWzK6XqA+nb7FD6zd6Vi94WANCjfDxgnaLhyAIojAA/+eUGwvyac9G2vVTp7CzRh+s4XH+5CKa3o23WuFzsyL	2765355a5e100881799c9333b9b67e1b03c89650ef8933657e24932eefe454bf	qCGNMRcS9Wb3d1nfn7WHprpYNspSHWwVn0ZNy9YftSg=	2b5595e10716eb4f73fa4bc8c0b20adefdd117389cc2bd7a13f1593e31ab58cd	qpGLI9pct1yWY+ie1lMY7/sFap7ajTXYruIPGVxNwPLeYsuNOp5CdmThGPK/xV70hIg4RSnwRlMlvchpXrYOt4TAfI87Rnv9+pCSGlwSIs1oGPvCMsr9G39W0HS4DWzJmm8QaVXNLU7wZtsKGt91eIXju47NhjJMi4/5AI77/Wf4Q2Gewcz8nqO7kr1so1bBTINn+G8j3p9VFWV0yzT/lw==	mhOGKgBPZ39Tfj2HPKpOLNczxrG7wZR2af9HWKl1cpI=	7420850eddafe2c4b26c7f848587f56519b15d391a6fc5eeded035fd32e98b1f	\N
\.


--
-- TOC entry 2669 (class 0 OID 16394)
-- Dependencies: 185
-- Data for Name: accountaddress; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY accountaddress (walletid, nodelevel, refaddress, nodebranch, nodeleaf, pk1, pk2, pk3, isactive) FROM stdin;
chcgshdsf	nodelevel	refaddress	nodebranch	0	pk1	pk2	pk3	0
1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	m/0/0/0	2N7hK9MzvWDJqaoWhhSoJRuX6RwKbN11nPt	m/0/0	0	9auWPSNtBRuI1rCr5LbT/XAwCvBfIMKH78sLMBxtKDVu7HG/H2mc0EuZ54zNkpIbRBwDWuBnkWgr+gxkEiiQtwd0q/q5bG2iIdpsTU4yM64rIJ6sgn4UK+lxyApRq9lJVSNZ3IBLUJ9sM5QQULZjZZe9RL5hkJIMoRBJrtadoTLbJwMuotZQK/U1X2G6pYx+FIZAXpR+ekNDG5bJQ74PCA==	GHBaGo1KV0aHaloViA/g19GkMOnLxmdE9qMtDNxCE0Tmc+SHRWZ4P+N1qIijmPBCg8RYd7V4ukIDmHS99o7FVYW3UhsKyI+Yq2kOYTm9h4RYTBGwoF27W3Zn8N1BRl0DsD2FPxM+IMC0765lbQLa2A89+cH7KZmNsZv2cHRqDDt1dG/zjr+XpN6DaP9flqsdczzz2AXdbdK/yM+QBD3bxw==	th0hW9XPz6+ui3xdxB4FF3QpfYtc/qjsBRuNUQoV5btnWJ18MpUn3F4b33PVWUACcCvvskJdoJs36QKqlCDw7+BrFr45ae9T/PM7O6Q3U6iqE/zVXBUD1tLlir9XRYRrPxzTUzHJvDeoWPXmxW4M7IHHYEzYDHN2BUiqNELPzli01Wslfyz1QKEHRGu8MtjZmq2rAl6NxD1sZK08+PNWHg==	1
1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	m/0/0/1	2NBbrTWJQ72f7iL6FStKxSXTYDVrXKteffj	m/0/0	1	hr1N8JyYeRF8SnrGd5EDBwpdAtX8FC4eabl6v5UrVtu5F+Z/H+cYO8BD2H8WKUMo/x0uJDOXvudTE3BrolsRZ+ii2iM0suZs58jy31sfRW10hVX5C2OG3WqWP6hgLdMRheZTTPT5NuNr27BMX1/sYwD/5doNruqQITjh3Itjq/hH41PaHakta/hrZilvidRLRCIESQDtO/AhxfRCg37OkA==	arBe65Yw8U6d83OK1wwhXtnMSMYiE8PoGKnBtNzrnn5cWVOnhpDrK7egzP8Z0bIK7rr71LTSJCoNOj9Ub+owK9CJpp4nHyTyqrCQg+D9G7iie7xe7R6WeKIC627UfUpFQ+4kfPEimsZKpJMziNB9nk6sINj5MKvN1Dmyrdj5Cx7RBA1uZPH/SsUEiJdTX/djpBS4VW799Jsjtx1vEUlP1A==	T8GqjaYnnmX1kSQz5MA+k/C0cU8/ocTPnH3oxZA3RIa29ef7n8475ohYSffwoZuabRrXNOF/XNPtZ94zqSmgcRPn+Oqb50Bj74zI1yVuqp90QvhtuUE2jLL8Xvo4FPKbV8RxXQ1dIXoCR5GaP5L7ybyTQRiRzZTnX+T/X1h6zzBOUd+1GN8QJUxbupDW4n+mtlxsr6hyEvSJZpZb4NZ7Ng==	1
1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	m/0/0/2	2N2FQ9pfos6hEHLtX6vQonj5QJS37Hb7YYd	m/0/0	2	oE9n/5ZEv9qX4XhYZFZayw9pa5EXI2izoTvYKNgYfNpN9maZxxJw5spMjjeLNUsYDRA8tCzbDr9cZ5cjPfiBPdjVtXcjQwvRzOW1qP8zZ1TWE+Gc5EC/9/BVy3LJ4CbEV1MfTFXzCy2k9uzRLqkorl0fVRvV94/x7iiD3tGNK78G7uO/XBIgElV237Mfima6tBi7zJbOyb1+3n+22o9i2g==	CsUDdEvVwQQCxCDslSLk0v1C4Mt8K1id7Ohw5fSM0fz1wC7/VJE+iM2qeI0F3nD7sdSFlVNzhkWRfxO8GIpb0QZn3YFU/tZr5Rfg/iYOIwO17gU69e3Q4iKmaBiwZE/EkEu21ezcqFbOKEkZYGPUvP9ehI4W2GOIcHmWEZYY7HyWzeKBncaNM74NGRDlbvHmXHfvssgcNs7K3GBgKvRxdg==	rgvJRTR6RuH3zItwb2onobq/7wBA1aUlax7XcX3Zolb0Z1h0KmnB4F1AzXqtVoVdRh+zN/IR5g6fhHLDgCB92rnVHeWAMyMbpShxB42xBTT64TVB0zVOM1PhyLGypJi3thGTraleqizHK9Qwlf9iyFM1gtLZmwHdh2W24baEoV6quo+Fb8+Wo/ASGfzK9YLQsxYs6DU1FytAiCfUI94x7w==	1
1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	m/0/0/3	2NCL8gZ4zQVBhbV5Jtn5Mjv171UCwf185nA	m/0/0	3	uumgPM7VwEAZcbteQCks6RFNGzvorGkcXiedg6sjSvXc9NNBh3TFUMqZh3kJGuXRJt8MkLUz3I3/Wk05nflnzNfluY+c205+0iDIfFdL2hFentwRZ2WhR7khFS6uJGK+/fppf/sGTBIEDxP6CDss2mLDbs8tq7PwH1qFk+46O9VhW3I/7krnVsvl9RHEVqL3gtx4cEIgin/ixoJh7ZZJMw==	vcXzUQL3/K7rKYrgq1ktzQs7cV1a6PLqDUEE00Ej/Jgy6crrCrIy57MMkFItweumO/l2OiFIcZy1iV0+TeyUgJiZimzC1fUbCPoPRluXYCSkNf3lJia3C+2WqNuEcngO4LPV9t9LRsFGCjzg8TNRw9It2g5pZwSs/AYu769SzZkn5+JqhFz+NQn+UJe+WqJmpifQ2cSjQCJIhPVGY8n3mQ==	bfgbvr3BFHibPsV34sguSLH1TXDdzXbEuu4AhdUeX640kIxm4qq45b59y9eq9m1wjCDA/A9BSs4OHrUS1SfrgxFun61OA2iCFS9x0MT9wlfibEgDa4zWNNdKNfQIdiSB0lAR95sl1aszFHpVcVruInRppEUE/cpWaHUVZZJx6DfQXyacCATxmkWIEdH1YU1deYgl4uZYqIfkyTeE04nJsQ==	1
1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	m/0/0/4	2N78L7K9axDq9ZkvUrUx3C2gypHPtq6u17X	m/0/0	4	AvaHAsg4ROo5btJ2YCXGFImk16UysNc9VOLMDFZWFJki4ZjkA2NrcY9Ncx+ePGtvcXsZkqzRwFsQyeONwcm2d8SFEMo9JHBZns0zvxVNDjcNUvTE41+aQ7EQWYas5T4QUJ/A1luFyXF1Z5iyFbiNxeD09CuyewBROdThlZTpWVVyPdp+JrYlpN1qdothMDyTrkeScWqI4DeGEqS3nggY8A==	pf3GgA56nHMdRcmGwHHIZW6i/P+RlncUuGLDohyZGfL9DgAZ/FmEjrIPjVoa5bCMTkjzQcUt1jDJsyG1AgxY3tBMcf/4LE1MHn4QQysZHhKzoeNWwuV9hWA4w6V7D9PfDBGTAzrJm8FULOHwz0HMcp6jjdHMurD4UOEUd6DtfEKwamGa6WpZ9/7PthAzrBxL4+NjGK9CdxKMc8AV52ryJQ==	phPomze1wf1IGzfC6fPwpMysY1tjD4K1Y8P2lXe6LbyBHm10zgubqsEZ0QX7awhcr64xhndlhcbE4JQgjfaQRVWhVwwpSMrXXJIpJP16WrHdIOj5Gbr7lqRT/sKEPjRp0Tj62PFxxpDoV/fKuH0legRhi8JrnwLd3Ik/HpD9CperN7QTGDO2jW5HEhUb7yBdFuqcBdXIA8GS+qrfR7qw6w==	1
1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	m/0/0/5	2MxcSr9A5hPRoCYbp8VfdEeMVGTKn9vXUd6	m/0/0	5	nNggfCu3CEc2M9rExJ2dPrZ8/KZHun+V/IV0F41PSZtTbhMT69Xr/LdzxwNplbvanpM17c1TsVNPjP/tMi0i6zTNOneI6QZv4zPi2ixwhdUHX20dnQxuUym0sMWw3NYf3bnFm7qO0j8JxP8MSOPekqLciD+agOOH41T85v7wYAwPGtlZwsm2zIQcUYV6wCYkJ7H9zWxMuaNpBPuf18VkLg==	79T53ukS2meXKrNJ5CSyfXV/6mzSwsunANEu9M09pU1vwtwyPmziHLfJUuJTa2D9+VvDQYBdiVGxX602NUNYOAeGzRUf/FoJSG6hWFA+gActZDtUiQ7V4IrgeqELGIAoCWdpdle1maipIa5lEIdJpgAin7AeEdaYkMjpb80HJu87d4bhk73rxPI9ZmxpAa3e8wE4+YgmBHWY/pwaaHwRhw==	Jti5SnOGtLPHHE48ge8L5/7hYh1dLYDa2TrfhC9MPZFinXN8uUIZbLt5A+Sx51MLwe5A6+WsJ6ws4ihs7hRltcUT9c03eP+X16tPLClqsHlaVVsGrQ+FOyDHhYcTPGnO4qNyHQyd2oiL2HhOeuhDS+FSAG/KHWyWiwEAboi283N0YF682qZOY13Lb//StO+nbIwLZ3M3G0YIBt/7HeAsTg==	1
1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	m/0/0/6	2N6ZEVhnJLgF8muQs5v9d3LVtVHCtoFNkxn	m/0/0	6	85GjHhVGjJ6NP0jFy5M1vShNyUPfA7IWE+f0bqpUrdNvWNuBF5pDFa7paLiyfQQzWOpnhUp0oyuAwqAjzXwvVGnvJSybZ63WUTUeCaMpR8HNOZtQ4reSGZQHfseXZz0TGZNtuKP325qDYiY7iR4ePn42hU6LPpdvmcts1n1HOKDuziYvkzyJI5RPRn9RHN8QWDKmA1q9BeJyY5JpRsWsEQ==	xeJpunYJ/XnoKvAKRj8mkZVBA5CT0gUhuRRU6emCMqINUtWz92Gjc1vRQBP94jQ/VI9dP05R4uB+tIqgOBjCIzAHb+IPnwFHUz1pWrLX/SJcc/PdaNuRhBRiemE0KBlIt7/l+a2xacXwuMJLrA1z3eGH1pJFjflB0qNm1TY9ydspV1aWufBiDdZcy7qcyE7gA7Hvuy0YuccKhY+IQcVs5g==	JVfFuyXk45I6RVxIHLktE20ncMnzfXuCGmQPoaRCtJmuKGfM0YPRzXzH3iPw4YD/Lq4YtGzIeqAO4u7jTZrhQF6z0P/qF1C08ZmjuTZjOQJjpvgJ+e+VX2g2TgIC39qagM9KZ0H/J4Fq64EbfpQMDpWJyX81IatuZ713fOPtBl8eEkc9Xcv2hUhnHjEjeGferOo0vavzZem0l+pam3Eajw==	1
1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	m/0/0/7	2NDN54PKXp1Dwvb1fuSUcBhUPwwsos5Bmuq	m/0/0	7	6667c4SF7HMc9yjcUHRE3I8LPbuxtfMpEjezU5kJZEHdvRrvLwi/vgMgOEKXQ7efjcPJJtHECQcShq9u+KhJA62WIcL5DprTgvtU3/HHuHtWEj2fdejgqnxIob4jaHHvOPDxxM4mB7vFzmHP77o9K6B7eGrW9HyL/9h4cLGL8aTXdijgjkjF3klHJlGN5/50AQnDqZQ7d93c/r7QJirSPw==	qQqbN2VsfXzYygd5Us8r8kSaQ5aQUpa8RmQetZnPrBAy+P4abC6PY1h850wv92WbVoCIRIi/ioyqsZASFiWFxQkICJHlzyzRqG3hH1QBvYorIaWnxGK1yGSyYgClBsx4eJeH6EcYgugvUa3DD0etLpU6MM1kqRmUi8M4rCscfFKp/dXAPsxIixGHKsl7WNkRwy0eXji6cxXNsm/RUNPkGA==	UQQhXp4BWnwZhLTtDRK0JhieNsTNUgiqIdt3rGR10NPXEpg+5cJiNP2JjWjOjN68aakLaVHC/nRxkDs7cjqyCKxYZFcqJfRG5D47sFsyOMN4pxpEpBMQAzs741ZksYkHgQfjUsaVxyrbNLzirA+rZQptgtuDsuLpoxSmNI/Gg0xtu/dm/s/yQk//NiH+zRTeR7YQUL2tVrdesAaSINRqiQ==	1
1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	m/0/0/8	2Mu7ETuLcyEL6QvLVn2MzUS7EAr4xR9CZ2x	m/0/0	8	+ZG3lLJx9gMCBZs02uTTOayhByk5lyZ1v01scXhZgP2zYZP6wDnpXPgvDDBhv+vZvHuaQ8gnU0xYSqhLxXDtjpL3blkGO+o6nfOn1U2Kxu0W9rAK+7QuFCQc2+8pWol9OvDTFOwn9UmlKLNSc+qYT6firCV+DczSqnNjk6B1er/kS9gvRBreAXoSx4MikuObGG/rWQ5hRHr/2XrF0k81PA==	/SMbnJEnbEmrBaErP/EJHHp2xr/fRKfAjI5eJRcLV93qCvzEAm11InKIzWZG0Sj0KP8hWseXWQyO61oJReMDxezKCs2Q0RsMVLP371EzsfGKEj7dm44bwVxpmg68b1nKYvQii3Cu1wfSlq8TXo4aJWVyeXZBI6od+nTlWwbGirtpRYxEJaPqAbBf5iyy5vC+pkaPJti043NpjDoItbAktA==	r7kVWO0rr5nRt/KKPSaECy9S82Vm3DBGvkknxCjBCNXxurKwoYf0ZjyqDpbKZK7ScncyXTo+dPxiTaLzyZB4hzyUTJdUD/yh5xZYcoSA4WEVvbnwNxbzdCHcDIePKccF/z8kaJToDmz+9xXY4HjUCet9pBzY7r9UWueiMrv/4bJRp5WKm0tWPs+fzbMf1ver5Vf4732EaP2VECNKSvz4tg==	1
1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	m/0/0/9	2MyKBvapRGwc1UsNQywVJ62CDDEmMMG5JTo	m/0/0	9	o33WdYTw0zwKlzq8cZWjqk/XfDtYNVs67Ly5UysxnkWcTaR+C48Gn+Qx7/gOrU8S7K+JjrEZuHFLa6xsRQKub6g1RLlFkghEX7s0uocFsHOGXMRSlZO00a6HZbp8QUQAUTYwNr0Qfads/DkDQTvNAewLPCwBXRiiOd4nUdMbDMWszFfV1/zWdPNWZbwj6fQpKIppOTCroK5ABR/Jxtbd7A==	KiJvEYKrGo71YVVS1s4RUbtZ6bjvks4RmQKk6LzkVf8mfEEoDLdyMwnVMDCY1TwvHhejK2pbz9ipoyD/NLLKGrK2H7W88G6aiF3GRfewOP64ecqOqVJXgGHgrAG4JihreSKqZRHpl8sgUKChHNAAyvxu/wfv9Hw3CruU8hFcHU5wPnUDV+/hdWzuKqXbSY+OJJgv28XaaqdqWW9Dq+GUig==	UhGQaGBuuWFMCx0kyax56FSzu/CYUgM35NFqr+jOiZuCdn7cYcK1dlI3i1u/15VPX//9KNxbSNA00rAv2ggXp+oE/a/N4YY/FqIh1oee4aPjJ5o7wwBOQzOX8PB59FcBh6l6QayNcNBMIVI7qX5oAzKdnrX7W1WLaYfpI/UAryrsJ//Jg5ws4HvJTwb/Hn0Od8wGRVYhg87tWMNAOZlScA==	1
1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	m/0/0/10	2Mv4sxrDgnt56evQiQDx6LRHUNJwKNV2uAv	m/0/0	10	0ue8BfFGLlDife78uIxfxXtInf7+NzsuRz1FMMdqqPdgRHGn82EAAo3KIvDPYcOcESAIzW3s16vbq9J1n1ycxfKHHxdHToj1ZYqEimnKgVNWKGCakM0Z8iarwimzVrxgCH7iD0WOqZywt1SKbWSbNmKjsoZQcncG6v6KNglM7xxaH+bpuilAS9F3idtyJhKhVDJuvFtuxumwW5f1rXwRjg==	nnZtx/0T8f9G7ookUcEn2RqeKf8BUJyMFZCMKgIqhVlw0X/6PSPBwcAxWGvqz3z2PL1+fg/408DPmHCawj0Gw1iE1xrpIBtSDMY9VL9Ija5dnkLhf60Oy8hHUR/DAO63/ByuL+5xTqR/07ljptw9eO58mXudvaYAY7iGb/e+b0ouBTK0bb5+6d01mDEcwDCGToEr8KcoRDbtBdelkb3Lrw==	3TL4vxqWkC1tOr4eIhDgOkJehmJIQsQYOROsLUa7k6klNaSaGAMdlYwWjI2dor4tCZ0+WeM1sACpp7Z/76FqWR6yIctUmtEwud+HedNtYGEa+GWf8crDMa+i7r/CooXSOvvdKXoameBB9Aq8BaRvi5bfgj+kPBhR+gzPliNYZOkQt9k7kzPrmRg0QvBd3XNxG3a2GxeW3gjSDBwv0t0ftA==	1
1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	m/0/0/11	2N3e2d7UWU1VzRLAsHNT2b9Rf8pnF4CPMFw	m/0/0	11	13uP11bVSil2G7rNtVBGJbd7MjIt8/Hl2enEiLyOpUDn37fcOFIBO41IGzl9JP5Ch6NK1pEsKjeK2wzpwIQ9lvU4VNSATVqyQMsd6XA4lfkbaa8vN1IBL3hU3Kyy+T+LzFA4iFAJIcwjRCG+XwY4LTtCySF0hbxFZJb/F/H4G979l1rmbb8IilZZYMR8o1TRnTqlaA3kirZ4LXmNO2BcWQ==	jBsWuPLEuyG3o/lDMYCjVyUAMVTWgwSxtVgV/xJvtMucVqREHt+7kCDusJ7EyvxG8qqo+1VzwFf6R4X2uGiFO2dirbZxx9+EF4YGV3aavyNszKLM4PqTLiTaK9gn8pq5aOG09oSMERDcxRSCAYm05bl69+t1iOeRt+yLLbDQZPcoLGvJH626WwsSgKnKYxUQNUjl3MwRu0tOkhS/7V60xg==	8Txxg/T265SiRe2I1V1QS6qTT8ejklT8Ed5boEhSXwn0e3s3d1eN53zXipLzWaqfQePFOz39LRlUTlqd1dceJPzjLnnpWoscZWnJQ+iZWiwoUfPJDG0810xK5CgFcTVebBakzQBd+90fGdcDz6Os4YNQVggxOiQxuN6TNg6tOcGjR9fAV0vEVXvQTo1HgfEzsxPw6hmmGXbTdSU63xgqPw==	1
1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	m/0/0/12	2MwvxgM1eauyKDFMdnn9ExpSJB73XY7AhPY	m/0/0	12	m4JZtKaYGRpGcBX0saFmDMAUfPfMWIaJGDR6CxVz8sITLplmG0dmazG6RRgpKHTlVN3bO6kLlypdu8U/FKYi6PXJ7jGl9uUptNBJKjgbmDSuiesUJsB/OA76/tv/j0Xzr1crLm00pKkNi6R3OoFqmxjnRwAk/ok5bq1Ps/6FAI9uka+aOVR0a8jZ72dUhBxtpFo1Y3jqQPm6JNvGwHs8aA==	JO2oZ3Q0l78V441xY04RWksFEW9Yb2bG0FKuAHga5093atDkdFEWVfexqn6WIVNd+biEoir4o66EJ/X6BlY2Ff7HA8SrpRxHcy4UpRrrQWRtAy/DxO+1G7JRSvpJyp7Srma2axx6uMZSCCQXVxbkMuiJHtcOHKybNIF0u/YaFXtNRJwaI0wbVHDqfTBu5QTlR82nIHSap37ZX2rR6+Omvw==	PZihF+9sXeXsT1dLPyZs5e5GC1A8rmMzRzcbDjlB+wOH3gtgZVUGdj7aWvTUsBEiY8pj7XUY/g/znQ0beVqwgoCzhmbAK5fHSfrf7cVhulazhI3FKktMpzsCcH/R4MgRZnFIruDUnFP9Pwgll7v3JQlNQ7dzbM4joQDw5bV6Ver4cW85tyGS5NpgN39X7ZU51GpqR3kZKcD+ijTJfrgbDg==	1
1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	m/0/0/13	2N984m5EJU6353JhacVi64jtjNQrbUxt1Ah	m/0/0	13	rmHpUYHw2JsVafydHpDKTfi5VCIonWJzjYPsf+ieX1W6DM7xqvrpnNf+ek4mxtZ8ThOaBgRFB7ibD6H2cPQ15EWQjPqbvjYnGQfrk4SDArpjC9oin1DCpWovAQGZuDwaFF/8RQd7wS6QyAy6K2o6iHasXfDGizZ/5kAlFKQN2fO3VzpMg6TcnOX/lIqT3aRlCP4dp9CwvPhDcRqUSa8ryw==	sOYjfq2u6beF6dyFdqcqugmoW6eTghzJPOs1rATwJ2pzQXUMTJmWwQux+/AeLc0DGOTU8DiyotlzxYx3h5dSmKMCubp3a7tQyqkgjafX/ryDLRTjTHq1tuQl3Eokh1a3gMN7r1nKwIoMXTWLiAK8zfgv0lO9Knle6AJsu+xYtPXnJcIhHLCLKsDOpPEr+ca3VJho8o1kOQhR69UB5itpNw==	ns3grWRG8KC6z2jJoOvA+I5fNT2zqovux+L2zYHBjBqB2J8SCkYClBcAp8Pxc88S5RNjW562kDMsgmcZxWkfdBOzBFhX+xK05tmmBqf5g8E//ciAQZERSnD6TGHpHoj4Yl9taMpCt9CU1ocXgK5ihV7CWNx/5eaSaDCC9O5PD/VLAgtUtHJxdktfsryMrzyf24QwxshpWmHzhIuqmhkK6g==	1
1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	m/0/0/14	2N7xVMEkXPkynxDx9V9CK6MbTDYtfQJPBij	m/0/0	14	ZmdoHPPyDhgEO1WLXyBg97z+0ZIsUAkRifeyww1rbv2AWS8F9Bn7tx7zhgmOKSeNcUBYeHgqHErjmRywUtpWHj4jom9RymRophLDeqmc1IRU02FnvkSx+7i/0LCDdJ2AyxNLlk3PaRmPqLx5Os/RbeR/1peFoYoB+p1GPZ6d6nLxaotyOIx0MdA71pJ0pfIxa3RI9x4i2p9O7Go9oROjlA==	hflO6fk1rsbPlIfWuFH+QsHSOsG5m6nABuGHsZHL+pdLECQFkYF+c8hNuSigmhSidLg+1xLAbc9kJcxQ8W4q63+T3EC1XrbFBAjvDAOmSPL7R/AQXxhnHrF4wylLj3zVq6RMUFv9X6XlxVZO2eReOQ5sKzZvh4x6fQAinQwTlq+h2esAa5zV5r5VM/O8CrDsQfouL6wqEumllW+R5HqTTw==	ZsBQr0yFfu6YcppGcMFlSKBIUOXhWW3uQdqFsxBykC5yhz/bZWPaCEgi7NjvqODAxD8J5fXYpjQU+gpN3BeZIWOgor7ZD4rw6dw+H448OU7zUDL/+FF8SvcOsPofo1oBQcfXBiBjBIClEaEE0q30uumFcLiYul0rhgo8WNi3gKj1o4134mqYpF8+Hj3fFuV3S6BgTQIVEWnzyaKFIBaP1Q==	1
1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	m/0/0/15	2NGBA8tPQbZFC5j8zd72xsQTp4Vxm5Maf1B	m/0/0	15	t7Vr/jAoM3x2efRWr+a7ClU/aaFtuKVvZLPQ4AlFb6eArWyuPP32zTJJCUFcecnI704ShRKLA+5heczZTWrXfi3dJ2qT4stZTKOc4YH7MxEVYG2H/0LQIIrjSe/ZkhPFiRhmTs/ONhCrwrm6dXHdV/IkfHUnJ7T7FOLtFxIpdZtnoNkA0ozHdFzrj3hGGxP57aWUPvdWFpmBX5rUgzDRlQ==	ys6DnTKJHDN3wScGqXEFLvWkodhnqIbr9axjYFGtidBVK7y6zotZgwv8vpjWc1r9FfhKH1a/xCmT3XoB5wbQqKOPTDY1p+AHQkaZXd0fKdGJCW55JsESClFnLSjNcy3StdUjwFFDwPCuh19uQifpmL2/X/7SWqN4w/AZ7KqZHxSjG+nrUwO3cxq55rqcBEtItU8lbgVh/k8ZU3E06hQLhg==	dMLOQEHQLxGAO5TT4RRtASSe6rCb9/JCjC0AweV+fQSRdLS/xxXGdUrfXW1DrwEybemAnbTKzWSFEcNIwzU8V6wqUSPjFiXnJZvVnhp6nJ8PViHkoe5fS0a3ia0kNk8YHnllf3MGvb2imewR2So4c9faWhmfOf/EbyifT7rW0ooDBjb0U68mbVVAnSz2uMULyL1dutcywpD3f20+rB3Z3A==	1
1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	m/0/0/16	2MwFQf5kQ81dUxUaTq3KAHgoXAvDuLiAshB	m/0/0	16	CZN9Z8q+TAQRCSIuZicetGeflCWHgOC9T/cY3bmkd/RwJuTGEvt0eyOmt3HkUs5vTmAU3zVZqJ7tVnndh8RG11rtxv3N6UIXHV6bGzWYX63MuSS3vq5XHRNbJgK3RlGQzvSDfWbPriLn9BL8+v2kkKNtPv3eGdmrfvJQvmzfa2MskCjv7Z+wTw6JQlnLcH0UlRcpPEcKLk+D2/vbgfYxWQ==	sKzKqdfooafIDMc8yFMP+c4GKbPfEyIXcm8S3vk/cc7agPRlUXy8V4/xFn+bGr0+syHM/uHvuG9gMksgyH2gk+CfBOxsz3jLM8cxpeio0WjuWMAY8hLfKWhy0nR9c1dn7yNqXiBCJ1CQ114/YP8af5a9h2wv1oQFxRpQJz9TcBgXJ9udqIm2FdoKJ5kdjav11+gK/qx0L8oc88bl7V6uIg==	+GX9GCwb6VkjDyg0Z6CuSbT/Rf+Z8ECUNW7B7G5OUlqNCEGYK5hAaD0R+pt0TCPhkilFbcyTHAauKbDwm+wrWbU4eg9wg9oObPGU7DajnD+XyvY6e8fVilAEdwION9SsQyP7I9Oo8UMy6+Yh/khRzr80iynYdkFh048dGS4nV2GkYGWmxhbixZ4jKiuZ5x29I0c/pOTQ/+z1BDkVQARAlg==	1
090386f5401a8e48b63b19d4c8981e230efe71d2d3f28307f98c0424e6d93f9b	m/0/0/0	2NE9bLYMxvxwaHCsa3eDDD22awnehPUMmqs	m/0/0	0	WFbmoMmyOXt2gA9djX2RN6SDeKG18LDBO19tFMZYmnZNGjfmQHjMqe14EVt33Gv5gt3Yx3O/bGhuL8uwHr4WFgvwEFc9o2AQ8fSdft7mqABGe632BC6g3PZe9GWllR7Sx+DHM4XRU8PrZCuUQYIi50m40t1r8Wowfo68odq02febDJ8rURD7jS7ZdY1iBIC8RLUl6qG6GSy9tJ3WP01Vpg==	8cjsE8tT9ecJ1CQpZLSNpRqpB2oRXr3l0cdnnCLHlETGE+UM6Hihw6OP5Uy+Z6f2l00nXtB5URmhJexfnxnLhQuOgnOvnv6HVE1Z4YpNGV2b6xL3jEfIFNsfpWZpJpiqh27/AAX2mbhjEFlKeLdzondApFRr8j7tz19mtZm3taHQVWEI7O4t2CDzFFbABD+N1+YkJR1YVcY9efpNk7XXvg==	+raNDtOy+nVwxm7lA7x6KCHQ7OpOZ+cG8ps6E7XssBy6ADQvgwopOHUlkZPqKAoVAfLBpwDtm+9s2G3WnTytdVN42LAxQX8pJRg6Yvm8ZC8f6d/8fpU6+ynOBtk4Bw0GQXifc2dQvIgyzGHkGMzq1CehxfdnrslR3dOaSFsw0frCQI6QUGQWeC77VPhJKLXKVLp88LSqseKKs5So7D9auQ==	1
43dc22055016c54a2ad7599b113fffa52bd90ea199c2fd31e4d11eb2bd536991	m/0/0/0	2N1C6YRakmT1amymsGdZ8C5kjEhsLmLt1mH	m/0/0	0	Vi2ek97GLu1n1KwLFMHWUTPiK+7mxNlkMG8Y9fRsMJ+wx1lcjxIYfmtba/3kvTS5tAgUfL48J2WXp5CD60Zkbu1zhkxiD7JzvuqsiMX413t7tbgTCroecAtWJ9r4T5Z70mPaVLh9jtrhC8F9biFa7n5drsaoxkvrBsAPJwgxK8prgkpOe4rXWNm1i5ZAxSQ3FixVx538EAWpZxTqSSjmfA==	T13IHTpyXug0JCkET49YiMbkKO9mvXeynN/9/ZTsD/9X0WY3cox2F8y7aYsnZ4zhBiE8tXELXIMQiR3tJR4u6FlnRPnN8a8a2nsDm8FkeFUycsKZl3mUXE1DM0+O3QfXYqMDv/Dej2ig1lNjR4Q172c/Z/uF0C7sNecoSvwS25P3RO0DOCcMZsv0ldFmcJHNqmW8K6Rhf+/knCdgyUWduQ==	VWBA5XCIPo8uY6mPSIjeNY0oGpJrkHlmK6BLKbsRNW0LMdZFB2Wh9+EwGT4mXO8Eueqc6p/0EPS4AvCoSIdi3Gr8Ot0JESx01qdv9kdk4nONkjaWSQPEPTI9ZRurOp+g5pPK3Eib/rFzv3MfylyGrr/kfVt8ZPBZzD3XMPh1Sgg9lPe5aBueUi4gQzuTyh57eFxfWDVy2CKa34Qe+kulPg==	1
873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	m/0/0/0	2N9obQEiByywNDFEgYvtoG2KeEK1qBct6UG	m/0/0	0	JGAr6N6L8gtDKXykIugh/bhbjmUzn6b2dzQnuJUGoe85aOBVq4G9POtShcvlcxCV9s85zEtOkSAQcinNfIPvQ8u7pmviyTDZoAM9KdfC+Zi64aTy4y3XHjOAIABLG3HsWEFKuldxZk6mFX9dnQkLoA5b3b4IT+yXmRLQeOYZIC4Ju+tiRaTLtQf15AWNhDO+ad36Sob1+Tja6w/leXV1IA==	TKWnHsByVeOVtCO3tjwnVYMdySILAtLj5+FmmfI1ZcdBiqYehW30nlD8FDH2FsYmBgvwToh/vu4UQC/zSW8SGnzu1OERRwK1vFip2C+bkKHgMx5D4RB1Cufs6WNUkHVo19bmWj+L9H53o+CihDpiB2ZxBmR4p53GjmBHtM5Wv6w/DdqzBkuNCMl6CHkzc9xX8e/nxmsnPYFKrrUHeIKaaw==	tV1r3m9Jrpg93DYZuheDnTXpS9PJLsJTai3Qu2XTF1UdbNI8V+ew//5MyjYp9D/Dk+8BuwCyHBVb4yeOoXPL0Y8XAC5kAOZS3+6m01GLUvnXZleBQo1iwFDvk7g0VO79CUnPZg9XqQbnTtr3Gu6k44B52zzKHONfo9yiBTQGQNsDdRRxZ0WRit75nVYIGGxwtDP3aRbZRXUEuAXbDuWE+Q==	1
1b70ecebc36f3c185d22fb87f3c192917e5d84151f6072d82fa6564254e30211	m/0/0/0	2NBYouvByX329A98EhpfLB5WEr1UFDUkEc3	m/0/0	0	Qg5TK5mQWDjuG2Ko9A90hjP2UgOcNk6onDUZYckEC+upZUtygK3IkgFO2q5Ex1m8o1MjLkuncZn5Pj4QTTCnNeaT7djBZhNRw1ntbF+EL/8VDdK3n8P/TYV7oAJ0+Y15J2osgFDhD+s8WrY7KyE2LtEB1Ib5TyzOqQNnFAfhNhy4zByWp2RsvG4Uho8JVT1XR+E96T28jrwJMyTCD2erSA==	BAAKuIHd8InZtwZjDhUvsENfBdiQpJ4PtcKkF1XTtyCef6KPMxGyBdgoKWcFGWKNEHBqTyikeZGEHUxgfLfTdeMOE6pEsYLUqUxcHmJk3zNbsYog1/TNLHmDxM3i7Q7Auk3jpqZAC9J5AL6H4xKq8gee8UMqdZJsnlu2LqwAj8Yv8Koq/+kpxUffCRQ+1jIahhgkOjflptzIN4M0XMDAdA==	s4KMtNOlXfSdKkNovdG6dh68t/blSQ/jWAYMtt1uiCyfJ7TRe3GBWUEoXCEVUMDclZ9gV8nzg+KrcX0nOyHcCzXvrC8xPcldXonmRomeFR7ll+1kJzWGbcMSa8mjEmemjDjtGdZUb0iXhU+9AYe7DtTWhRWU7j2yBRGIuFR8VHB+BeAuWFwm6f3W8zODiebRA5eB6K0HNJVylssgx64KZw==	1
1b70ecebc36f3c185d22fb87f3c192917e5d84151f6072d82fa6564254e30211	m/0/0/1	2NBtQuJtXUyoeip4TB9Rszx69kgo6JJafxC	m/0/0	1	qsfXa0KwWwGO6H4oT4j2/oJ2qI191g0gS3j0jcGa6a5FSJIt2VAejRFUMsbUN5BDV9g+kG5M1DOlRhqep0dVlyuaFdNFyWUEN6UHs21eDzkCPPOUnOqvin4hBUAOJRm7Up2e1Eiyn8shue+dbNFO13aB/EOcu26n9qkiOa83gz2t4tYqM65F/Esnh1thTXKwh2K7kDSgAw4KttbrIS8/Gw==	rl/mEX7dPVERcZ3vx7mx2MfzTScMQ1xL8ObVXTi2KML/qr8B3RPWWrgicGwM34f+RXiId6QkQRAjJ6BHvL3A6Q+38BiHsiv2yffyY6XvLU205nlQoYAjt0CARBIWsN8tHtpZ5Mi+pr0wkvfb0zuAxD+l7FpyB88ebK2O/0zbO3dtO3srAiM3ghStt4Fb8sclF6sLs8bI74dVXd3PhLt4mg==	3R4SbiSLbuuSYticRpA2zcc2ZUl/S8VS5IE2fQ4CIlb7gaNIO0iKr8I+o44qPC7Z3cp6UavMb5IbPugW4jaXxDuc1sa0RbcEwF2qa8Av6gYjsS39gYIlvEPp3Z6JYTT91wZw8JmMlS5s2e/M6Wsk2Zgrq0GQIKNrZn/GIyz0pyydFqgF0OGTYyoWZy0/dDD2Ottg1QS6NC3Pc7AJQcBEYw==	1
1b70ecebc36f3c185d22fb87f3c192917e5d84151f6072d82fa6564254e30211	m/0/0/2	2MuLg4vrEWxcG58qfXoBPE3u8QGyhWaDwVa	m/0/0	2	tlplqg+JT/WsNkr2pduOO0ZDpAEbURQBKflZBA5AQJsAVQTmcpZfgu6Ri/s4O4oZGIytj1ac6B745iARjBZ+RCUslucN48qCDv+qRfaily8TCglpH6c5ia2nXxwwys1bgbHmZulpz5gZ2xWsyvL2Q2ucZhxrQ5iQnNVl+CdDmLCZ1WXPDdNHEGEspL0RM3YIvkowv9mSGzs21/0o00+kvw==	U17wpwYt6RpZQvWgmT9KIx5xmuO1+lB8+jzH37oJFY0JXuLdaePU8vXftBORxSRlnk9Q5rDwT4hiUg87WxXwY9j2HClyOujduY6hFj3JNbciKPj/VtidILDyArKCR03V1xik6T7nFkhkjVFejeU3i9v1gmPj8u4uP5QdpvPlZKgiSyjEzuhsrFNnhZqiQoCC6niXyezbwh4pGtoE4jt2/w==	Ue7+hKsZ/f0FzTM8mYa2WN87jIiy+U+h9QvzU/mlMs9TlRXy6stKVW7V/NOYNX3y29tsxiq7BwZYpoegC8oian/AGZF2Cu5Gk6qP1WXKnMfj5cBTW10FSDVcopyr8BeZavrExMNrhzkbFBiET76qYTyyDsCKm5H/MfvMWIaC7bVB0m/uajp8lEx36OtJpKIL1CeUYAJAcEeRjJWaARhHBQ==	1
1b70ecebc36f3c185d22fb87f3c192917e5d84151f6072d82fa6564254e30211	m/0/0/3	2N8TNvPpD63pDUsGEwncTtJEkLYpEuedCfx	m/0/0	3	AMEuKk0OgjUPrzDfkX4Ty8uHH+YImC5vDDvpC4V8U55YQ65/m7NpR7FhJWrBhHfbneEogsscoytRAaN34XHEHUxqvGkPJ5Vgri+D4b7gfTu3msJ/XidAdijqmwJGf61C5Kuo08S4tfbuuXgQSFxa9oRrhUkYL8RXdUfzPf4VNlBuGeJC26ce2lZTyUODJJ2wRzmw1OZD3CohKxsE83metA==	NscyTIqtY+/t/pCFssSlhQg6noR/R3iIjmML+ES07P1NhtPKDiZIREL/BJnceZZpExW4Ia+4qUUKNPPQHZ5zy28nPEKqW0/xuk9xiBv94130tbUPJOk6zdDOu1Ry2/zLshT72SsZLdu2xhYw4sZu9pUMN320W4umb6lYLKP0nXZwpawyJVfj8Ns4Lo8oLKw//YMUZsMT+rBZ/oGK58aGAw==	pJQ9fb00WHOgbXtk2qc5nmu704N+S+I74fveskqOL+OAVwu5pVsLF3CBfp74L+eItLexDwQrWHNtTVpQh1g+AAqC0SnLPvZU2qpN1lYFRyc12KNd906rXXGoEgUGK9O0FxQNRHE/1rLUjBCVzxvOboGH1HJR4G09IM+VZBx6Pe1IhqqnkX3kDoeZsEDMBJvZ/TQDrFLjUmPCx3+Qf4Hr6w==	1
1b70ecebc36f3c185d22fb87f3c192917e5d84151f6072d82fa6564254e30211	m/0/0/4	2N3pyGvvqcrNW9fLtnqSNRTKuRF5YwfZWTb	m/0/0	4	e02/oa3CblkMd+jUiZJEjev/0Frhm36fUm1sruYmpIwZIQS18hwsvs1mR6oJwHgWAPIk6Af4Qkadp4pcUtrwmkX5mGy6j4RqrpopEDXLGdhjGZ2ArNSmkX2BP0TLKz0AlO0Rn4vlxGowlV3FEgIuYR7GlMg0n0xVp6nM0N1xbEnoCvDnqq3XsCl0wkQpAZDrA3mgPtTMd8hVonbQlqsTsQ==	4GzjiSqSnpStiqnuBv+yD/oFkj5wkK2oC6IQHr0s8HXRJnCYAtTaffg5uKomZYjqqVHNLnXommFpptx1Zm+JXzNpCYNE+mzBY02ZpuhYikkhEvrIft5HEzk/brOD8CS89iLjF5eP6olL/ixBxoyU2t7KHAza9YMgD+y4H8CALUPkYCEPJEXiT676SBU4oKHKnOy36o6qsdcKOFq7Ppr6Ag==	Rxo3G+047zz43GmDtnzv0RitkHuIo9E6SBY4u+wc0Gk7E3tthB2m366a+0wuuqfR9RNQr/ReNb5DvR98/qEqI/Y8yN9SKP8/lY4MbFlDYRQuU0olWQueMaetg2zl9LcouPr0FUs1nSNtehvzKnkZNrK8DZsVmNTeY9fxNcbPhtBz1op4CH2TTNNzY3hwSw5H2uUYGRV12dpYJqRMhyrlnQ==	1
1b70ecebc36f3c185d22fb87f3c192917e5d84151f6072d82fa6564254e30211	m/0/0/5	2Mw6zuJCgDG5hzJQ8KZ6hxmpsQU1MT54YMK	m/0/0	5	kKSWR7p7AHNx0Nb4t+zcPW1KHqiKxqeP4EmkwnkCeT84xhsvQe+cSnb0mnh6ItDkb2cpvzpeJvhsL5iFT9LJqR7YFqB1cgibWGNSprGfYzAFqRP+3BtcSeFTDNQxQYI6KwyLfCW5Kb2H/lf+zbhl3cq/Fesla9AATcJrjLXJ8FlkfiTnYVTOTu7XoWiS/clBU7oFMSn3Uct8I3QeAg/Wlw==	2zDcj1jUvLm1GTAkDv06Oal+IIV/L69ofLH0FowaZmfviLJZ1Mk/Sf5sGFxVa1JR1O2nJTlQalzZ1g9X/dHH+UomvdQ9k9Jw0AMFglmcZLZASwTh7QlicARyxmeDKVd17PLH0cifLklyVBHJo9GEZ/59g9Xj30DYpPtBKrJ90h/o1yT/WA8xwnolfx8CxsGuVuArxsRxscxJXYOkyc2ehg==	PuA82ibYpVYDa4qFreJsLP1DhvO+vesT9h8r9r+h/jocZYw9WGFlPhJhp54LbXXiHKR+qaR+yUGnjMAnnkUFwP05ro+2VxaN/v4sS7OX6veJMziJ19raWtknmAsiZgaJWJ89EPyFsILrjQPu++hoSTYH24IK19WNJVcew9bFL2oK/MRupVz5cddUbkyv4YTZXy/acZloDJVsNqJkqsB+WA==	1
1b70ecebc36f3c185d22fb87f3c192917e5d84151f6072d82fa6564254e30211	m/0/0/6	2NAwAHffm97uuKFW1budYEhvZLx9gWEUw6a	m/0/0	6	uE6vw0uMpNAGyzO4Uof1XgBrXvbg8dopPtK2TnZtdK29lzCp/ctPE/tYnLXcaqrfRaqeqsqtiAJkAqDkWjvbMGRpbDFZXiveAGWe7gSrKYl9v/VDDayTjkRM2BavcvDUnvfF5oLGIBthrPdaRWSY9q8Wk7qDf73p0MoMgfcxlkY1lFSXTfW0Z2QZ5KBuzz8evpk0FKhjxYfXSxv6sH/HQQ==	ZnS7JLeqNDK7TcZBskeeFKT6loMshgvcJCf76a2d8e9e2q6cx45rV5s6RyJ3lgSL/mLPq0Gzx8Gf+Qo/6qHa2KGKtjvXy+vFVCrzlC3bAwHMQ2JeNa5phohqRm1BpeMBtIHuv2sw1iVT2tKLsppvjIFqotA+MqDDsH9QqQ4ERALGLQrwcZbhk+TyMLPU9JDTUx4lOEs43mwhZCBn2BlVEA==	tfqipomEwvcpteRhWBkEKc8ktc+Nh6iLzxcTHfGDNjjFboa46f9e/z3ghnDNR9V/xjNa/7u2rkXdZ+ZkDRd5Ks5PBxlcOi8hZteRc2l23AWbv8y766MSav1vy4uiKsTPRF8XA0XjB0fh7KQZvkkCZSl8ob6NEXgn+XncJo7F/0WSCa2E9zkW2BOhkNxzPeWCMBdAj9x1OpmRsXnHOKPdbg==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/0/0	2NBNLkbciudb95Red5EB9UvnyThbHf5VQJx	m/0/0	0	shmCH3qie7Eb/J9cB582vLJxcct2eWKBaJsO2q5tt22hQHQ9vZVGjLkXb7bk/GY9CczHPlS2zwTAvppNp9ebMjPwScZiWJorj57mnhNLwO6QnkPkW8CcGAkbw5CccR5KGEf+hiZbxf4uhtVmsy+mhV1oKzhF6QUdDmRbWpkiMLedEeG9VAE8WtJK9rB7TBnxJB9kI0Ofk8RfwQ59AqqmEg==	AgtO93SSihib312p2kBffqyknwK0GFM6YpDDKQYOd+kU2H7KW28FvXDG6P2c79uiP3y2Mq4vTLRKUGD1hGkGUSFO0db0rNLCeKN63PnfJTaPCI1++l/3KvNPu9Ahq/SYQsdRtPUkazw8K1W6Nn7+F0DCIEPW9HvkbWQSRN07cRlNEyxqg5gJVMVs6uRriwiyPMFy5m+eE7e1sJV/K4/DPg==	0kjStUllLCBXIOUVEHZ5ChYtzTpVnwpWB2BFEdykfm0YJiDf9Jy6xCObpPL9q1HjcBTS5qajeHGjxZMsGAQe2BNRirpJYgXYL3HKMtapCWzNFMDjSQuWyzh5Ep95ySPZCQttm0xlkHVFLI4XuXL/SmmaLJmXl5WWvaGUFR2DILUaCOOWGedjNYTUu5G3gv1CfAcrSL1Sgy5P5ZZoFs12nQ==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/0/1	2Mv1gHzmbNjgo3TMYt2WZg23MCc3SJDhLzf	m/0/0	1	bjaZBl8ppkeGmQ0AJgmxNM/eACm4rF0kroFIpSXTgVYi3Ma4UFvHjZu9ZM6ioVPuM1KXvPCh6TaUtyKXgk14r/4HjPTYSFb3hfTCfCH75KGP5AC6kSWPsJTeIgv4Wz/KRBBUTSg0jKYpCzGAn7Fma5VGhcbVOenyYP3RGDbffvs2q9hjMiBigQSgCv0FGdUwHqbfgqWl9P7eixb6J5AI1w==	3Zsj7mFbjr1a83b9gD6wwt/By9VvR/XZ84U/HcQRrHhqT85Is8X6CuSdmijDrYj763+UCb/VdnbBxgz2VtxL386PnmYpPv30yNE8taJ5+87zbn6VRMtqS+LglJxoOrbYxKCXpUO6WyXqBteNjkyrc7QlzahwtPv3wDTE7WQiI0a10WmP0UE5QzBxVeTY4XuZX8DMi2O/zXNrywz9PG99Jw==	55xVLJBoW868OPv8AQgHggv/v1J0dfgfSxkiGXQZCLFQynGCKrCIk/2XWQ+SPQjr+UlnBxUKtOWdyZoMM+WQSjOxZr/gtJCmXXfTCX2IEIkHjC5H3YPGF/Q8VueORNqh69e/DmIj8B5nMQy2ZyYhiG+9OpKXXZ8fsPZDgfJQieTvRgVz+idtAegVRcid2EK3ijBtsA/5VwsI6tso4Q04fA==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/0/2	2N4nk4zaXnkVpHs4JQXfBF65oX8f1LjEV52	m/0/0	2	N0lQts1r/OtRIvHTA9p6wOTxT2p8NJUn/LaDJF2mkVgzPJJ3VupCVDM3+oLNHu1ZJOLcScMqLqWIZh1dsHnu4O/v2VIknl0nJIm9VquUcFCt1EhXXt/vnrEZQWIw0uetOP5cgbsDakCrTaBT9CLoSoZkJEizr1HXEJrtBYxePIl5bW96v7nojGEGacSepAvYk4P8zBgY+yRfvwVtN3tj7Q==	/jxHDakUf8Z+5523mp6fwHDnCoSAeoJKillYd7zlm4mmR/N+/Nna1sCk/i8vUAIth1TyYUGMKmIWNgBkCoQq96RajvlwAPWOESBfPKdqJa3uFIOn3G37HO1b71wI0w0f60Y6YDk5y9NAG+cNbNW1HTEFRPABKy3RSScLr1tqvmFR74zCAKrCb9pxKIlTnd1oT3rUNJMbalZDocCMWLsvFQ==	vU/FeQowT6GRqU+2+xiy5EkgpV6eCCAekENQFTF/LXNil8hFQWH7nxYwb0GPqNaia0KB6u4CLGq2viROmmzfb3OUmzj6tB4SpMqcPN6jo9EXXDVAtRs6TiQ78aqgn0YdzzkyXWNaaUvHzNkqsSZk0fWwEXcQhLoFG+I5LBt+HonHKi2q5bfjYjfUr083ZRm01NyzGyOXFtYAX2HMTkl8mA==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/0/3	2MxMALiZWyDzD7jKFJtwFAULBKLsqbXN7wP	m/0/0	3	hINw1uz9ajnDOIgKYyZRMXv9vl2SSzf9yxIfCN8rl/7fX9czaXEiwYPcDY+g+XWM9ifzGp+t4ZhHKikeMPxi1L3Umva/0zf6g7CgUEnFs5LSYLRmSv1rigf4LWeQTF2f69DnNlghs5XhhLdQnLAgHFE3CEFZgZ3tuktsh/Gxg3OKTv39QjupBPkt+3L4C6M0w/7Yb38YEcjlMqIG3zOCQA==	D6WJ9Elvm3Ukx+PJMtBpVidrIsjGLaFhHeP39iW+s4JltTVik2+wLohSPl8DyvSW9v4pkrPUDoHJrEA+eTKUTn9RJmeNZstfn/p2bBb+HMcnEpqbiArdXBBcDsdvbZ0zYOH3NXx9hn+91nRc8I82QEdh8SLCqXqgzMvdx5KQPJq7oBne1O4e/ni7qskmKc9b8pHhYt/3QmO4o2f2/bSSXQ==	Tji1gGjJ7thVSNGlP8ZaNqdqUvS1AykaV4BCq6oGGW28stC/cV6UzJBGvMRODgR3ks4g8GFfRoiTCKo5N4l7UopdI4d21UiROdMMxaXF7vq5N5Icj+JUknwBDJ9X8SmMCA8yCl9yG8e6BcFZ/Ig4icn+IWde5Pv2GS+bUG4ywf6Q+0vbtdlnxTamOB5AasqPXyb3+/KHs4w9cjji/4DyZw==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1/0	2N9WnWP8fuRbDoYKegBbnPrCjA9WQ4yWEvv	m/0/1	0	WL3X2brzpleXb20odsZM/J22Nqukc0YEZ0H0HOlNZeu9VBIb8A2PcYOoEWdmrXPydeDpGDo4+k6iG4LG1knsu4poOaDi2RM3ZZepK8+jvw4iRvx5qpjkiAQ0968CkoDURSCbRldsvzfPDH2SO6/l9kunDz7tJ0pJcySutDBS5z/yegzLeX5fHRdr35whRgnWqlZC9HSRb0WraDKCWoQmPQ==	H+M0NANHj+pgDE70Au1B8QwOmSifYchBOQ7vjsAJWsW4l37zQlSqhRULdMAJT62KdOqBdfjMhDkW+dVS1VnhDpS27n+Cg/vg6XqA8IQgpSGv/nYe0+OD/VlZjIBd4vDc2e/Ll8xZs9y5lbXkQCWIkK4RUToDdIvYa3vXQjxTvCvP+sgzMk6P5wzGNGzidBBzBoxKppdJx9FpnBvr0r+2HQ==	tFJQDPobPeeqX3cTxMPUw5CTCaNRE+q/YMB1vgfuPth23Pw6CjJkYLL5SrYVsKWO7HGuGkVq0XPcynelNbegIcoH469OqKJGr6SuN0Xa149peHqrrYA7NCi5AFHXugNGlhdEYL8LqCxrDv5pROjYDhOWYDKJEAL2cu5LicTRy9rHWdZoSJm+k+p0k8Tf8F4wSwsAigNYeDK+4+8FFmqyGw==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1/1	2MuzPyXD59dNWhs1oKzbVnuJDpLaNEGeP5F	m/0/1	1	D0/vLtXl3F5nvO1Rwn7ihAnVld86y3aKRCAFy4i2IGFy8eU4AtaXl7cd/ow3YbtgYpxgKIc/1JKCkjQx+EQpmUuL2OQTa+Ou+iV8Qx3PTi/BhL8yzHuV40K/hD/8jtSag3ZqTjnyUVlfcOayKG5A7oEmr0snN3dywTKab8nWNGa4IxA9WJkaoVoahLFLn9v85FlGePOWVa0Z6AIkjdCBeQ==	9bqGMZLFDjYofiT9KNWG7LTLcFx7tM2jA5q0Vj5Uqufh8dQQuS8SdmNhZNmzv6vfW03GJ8d7UwUjmG8p1tHT2i94RoyIHwO+9b18+AMcVUh1S94s5euXN/7KuX1txKiB55DlnjFDGhG5eDa0xw4+1643RrLkYmPyAhIlSGK94erpu6SmmMSDjSPhJcDq/OOIAKVGXOJM3hcXS8Zd9g7s9Q==	ksn7TM/SGa5fx7vSQvOuAqdNeC8MCV4sjn1lHJAsVBEkbp1ULyiX5LMIWlkoCq35DYgWiDLBP+vXfZ4ON92uJLRemnEgNYDCqn+pP5OrEeoS1qJtF+vR05Qiw9Sb3a3HQDJFFuLxZSfDIAqQUwo1fK3XBNFoqf862EWy8hGcEO0sFW6IBo8+XrNMSIqf4rcdAk6Q72r9Xn2LDxDGAum/1Q==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1/2	2MyKimgYtiBjff1iri2AJjVmfusg1fD1mhH	m/0/1	2	U30BY6Vuq2N1zqkldwcBvS4Igq7ch8mPJvhQPycrbgkcRFFiZCJL+PuxaphNqA2SqJKV+qi7bK7suwnrBiYxtIrhyQ3X99JiGw0va/hrRVL7mrk13MESyBMkCC/7bMRHjYRyHHlwA+VIaZP4AJ/KQ06rsI0KqUo7S/w6hnDd4HhlXuco8O1h7NwXY38+U9BP10OWRNyWyoxQJDxcNjV42g==	yaKT41JhyJJelCwDX7fau9CoWmZwhaO/hcoTNxLGFUKXODpOFsUq9AXcfmAOOEd0LA6+/AFB+5yI0t4Ru3ssdafs2+tv40U1h5g3aF4kPcL6pKjinXtHHYyX1PDNK23w4y46pdC4x5JSdYTPPxb+kYyF7JciewA3U649a3nJtORT1IvGcI/ka0w2qpsmesfgu1LPOb2wr6gm9fDhnMj+hw==	zJFAaqVhxbd+7tpWUq1yOExpU/PwYpyh6zxzV5ewFP/xL55sBCOw6cjnyjOq0RZaWDafkGkViCFIk1/A3o/9zKmDdEPEtDMwe+kZFHvJC+5E5IboXoUYGBEB2D3lET5gXGmF2cg3EjK1cizqr/mTppA2ouA6QMLIlZkFibcez71GPUi0trdusmJwHQloYsLY0mQmKU6R1In1bwRYymG7NA==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1/3	2MxTV43DnwkBmZjwyYroVTVxcKGTw5WcTbu	m/0/1	3	6RkzGXh9bYtjpVOuOQnJ8GF4Pv0JTA9Sg18oUbgwv1rxlh8IJ9XPL/f0QHF0veDxv7J16nOdWaZLv6Ldu0z9Uoeh6aPOPSmfW0OYnj4c+wRr5qTALDkmBRD7pwbzafYaXKPiW4Fw+QJMKTA0TGM95a81aiwKO682zSO+UXARUE4iUHzkB0tZ+5uYe/+rsyJ7cw/UWSyB1uYcWwqgGm2uRg==	LHCWoJOjYtEiW6I6QXRHJppvFwQlgLDxv8gCnhp2Hbr1jEBMr5Zc1WxwahPtAHxOGP1qRcQv8uqUJ11SFmjXP1PKWUubK+zrlnWDIJKUpqiVzpLp0LQ7ZAyDtI3/SmBTgHHSb/yQM+BMNzkpugkG8JBCJILI0penP9IIKZK4ltXlJOiWM4xMV5Lt9Qw3cf+Nh2z/Nu5rWJrofiY1Uwah/g==	9bOAH5JTJ2er6YhuMsrDNoQUu7l4EtdsGAhEvrjHvGgotl9GPkQI97rB9XGTVaMrNelswsq6TSiEEV0bLFwia+U3vvgk6zLIsIvuU3V4QQbVTiZrn6iDKrWtnUvZhYhzqtbHbYa31Ak8C/FgkD65twyLjI9YFL+QGq6PvoGRAxVrgrzrqB4qB5MMfGZv6SodjcsTd9PwytjPLSFPKGMqig==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1/4	2NFvLYJMcngFBhfvzYFmWfELrses6vDTje8	m/0/1	4	7SZqsu+R+vJNPsJ18MkUt6t72uFgT0INZMACE8L8bxtVjRBZkJ5xnOnH7VeT3o9y1t9AKsjll2dHrMyGCxWivTaXg9Ogr2OidS+4my/Tzq/c+olpChVlXDd7J/nuqMnXEZRnu5RDOG/e1Ne4Kn0sjGd2UA1bFh9ioRRZIfXQlA5BbpAnV5FaZT3yBWmNJofYGdbJhMiLIGniwHaCbcBioA==	Dx1puKejYDU4UiZgkEGKJXVhVDeEeqE/9WVbXSikAD1ZbmZKtX46338QOMUujryGxl8x02yKr3ycbCQNreTjawmUxvYo3HiRhUn8/s5+mQAuMK7e1Md938bk92a1sRW0oC56q+BqAoyyhz9lUy5LNwd87gi3ObfsjX7RoBSfrfkOrqRQIj731wyA1XEFb8/0CWt2fVCuX/aJWddRRAEvvA==	09g0yY3GWb5mD5BnxZNXhtgpthOxzjcUrAXxdckcY3T1yOSIO2wB7LwMT1xNXWRWjezu1AxrLdGfwlN0eTLU3UhyXCaM78LDRQDOUH8cefw4pY0lvhkdfWHCOE1WEa5rfgE8E4Nz95spZgXr0j9V/KLT6vntTsFKhhnbA57yfhG7rFvd3xWpxESf/p27acDjq/uYMi/DT8RHxlIFLtvfKg==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1/5	2MsULnLoRuRnm56PAH6jzhQTk5cWszfeyqu	m/0/1	5	4z+0sNnc5yHWFOwhfg3nRof6BTM9C4Wwoou5MbKf3yTnd09pwN+mfSv50ReeI3ocm09R+3ObwqNe1N85bwNAXPXo5IHmuB4RqBbk48I9jCbmP6iaIYLL6CqPf1YaqSLgOtPWq/7RRHqD+gALnDbvGd3RbebdpiXL3q9Cagw4fPc/2oM1vUjX7LzKcXG/sPdExsxpJmlAIjcHzrjQn68JGg==	fMuux7bOwip+gaGHBvofpHCPMnM92ufpg6ss7Tkc8cJDVGeM02hoKtwEP7+aXISrPVrh2GVNyBgZstjNqDlW0UCIrsS/n1savPrgeGLlgGm9+r93ArxZlKIPGJDnLMz5w4ErrDF1F8zhsvwiC1jnYhmzE/qI04T5U2AeckoMeZ9Hn3afnQcD1rGcD6X9Z1nab+SPje/SwZEtVsSFz+0Orw==	l88QmnSwu7VHUGNzIBQJMCvQarPRUbYLZycTsuiCoFfULI77DOaUuZua8pdFhrFdHcTQz7G0mKE1/2wBb0kwSXzwc8QgnQEoNRAioISA8brGNjtuKLbGUU/YnRvyvfH8w1rd+RdaA+INJXsOi4IlU6qEQiunUQffQtgM1Jn20VhQIs3qdJd/U0OYjPdEK0St8pce6vc4dAZqoAwfa992DQ==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1/6	2N6iHh44KQ7ebJXTJjdLxXgGsh3kUpY4QdR	m/0/1	6	P9qO4wEvDBl4QSvjtgl58yJ5odpQGtkaMEjH4lopkPSV4SEOaiyVcVVaYEYFQswLL0MWbnawWcL9E+6O67RyfzOccsQgjxGUtiVnnub4DAk8xum/aH8ViNRy3RvzU5RbaapGuuuPPyV7aPXREG4+auUqn7ECPKsvEEhPG9lPi58VkaIaEz7dWeeN31XT3mG1OvnWxRcVkCI5CgF6nKU+Xg==	w5JKE3EtitzAvylIs8qgWpZSNuSp8301ZcgxFFExjbQxN5+nTZqSJzpI6DanHefYOaPENpTtjgKGv9qdD9X5W0Z8oCJ4cfa481mrmTNS9Ov1KZJBs/QbBoovPDxXhlhRDDOuDK4zPINceRLjhWPYK3dFT+Uh69zLD1odPBUdd82UqCi/0KMHLKMiOU8oRNrfZzGw6a/s3R/0tmXdPvO94g==	pNKybl37O4hboZV5kwPDNveHLIA4rq3vS4DnxN3CXUyK7woiX3i1HoRzT/AV6zDFo1wYd8MxKqYD4NYhY7rFqWPa/pgNudM1tvqogW5gmRugqL6R0uv/qxvgAhmB0NTbo5M+2bMpGzlRwushQ+E/y5mnvtPRN27ak8ltU5ZDdgGTdS0pR8aTNujE668wreaZAdlxcV1LATkoFKlQ0/xOMg==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1/7	2N2t5siyRGK1uCiscLeD7rHUy8go8dz5EMU	m/0/1	7	NPpsYEVLxAwR3nqJx6ekCDAFLMbKEj6T26XPGzEzGle3dniEOfrr8nq4ZmGWrDRe0Rh/YNjv+4hgAVKmRekEG7vRgL79shkXTyV/DmNgT2+TFcqX5ncJ/MfM1YP7oCsv+4yV9pWGrJC36dFE+lc5AadhKIYfcjrRLmgwmd5TmXGwxohlviAuU81PWUook3cXAoeAbjUFoZPR8PMT3pUhtw==	J6k78QHM4O8WHo34UvjECEGMLxsrAZnAmxKfHlqd7V2OxKPjnUMihf9KGpDsWocef7CpRliRTypwW/+pIVqZIKQ0WfuO28HKejajMAASLqEC5ScfNp724xeS3UTeiyzPuTXQj9IPaIZWRbeSslpcW6gtFe7s8J8aQczHHMaya2EOeykZAMWR2WD7wiso8uruaY8t4dBWKRBDxXAtG3UZEQ==	rSfVRHaOcYyLGx68BZYboW8t9VRPZF9TcfZUg/pKudchfmIg+daU8MlxnN/BB7b2y7ZGn9l8YKIsZCtfolT4q3XYtnlfHb9I5hFtUNCgekqkYPfvBlXnafd5VtY8MtMYWcSQ0M6+J/pbHC8K/Ekog6umXmcBacjqXPEHl+3sLTmZ+GUDVENNFMM/aXIcDRELF5+ynpQCZUxwG2TUudfnYg==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1/8	2MxmJmr8JnBiwMVi94Fttf7faKJc5KvnF5f	m/0/1	8	rbVmhq482S0LXQmByxNrHHE0ipVbDc+L3f6j25nH6ezf8tQcIRcaX98SR1e1hEdnXTjENZTEPqk8Hgnlqqxup1iC1+J34wDm3yH12qV5CgEfB/CRcZGUIs4uqld01sFMFsswU3ZNgs5eEKs55+8eW6prWbvY0wlJ9Dsw+p+qT8wtbHzqIPHsd26sJ7qMEJwetNuYJ8dkUW13ZwM1a9WxMQ==	LyFzZpVE0VrsRumGlJJ4MdD4Yabi+ZXhhGb7cAUikmcWNRFV8Ice8UKYS71voyj+VQILSgG+eHLyu0nDarUZw2hI9vfe+Dr0+EOuMB/ziEc8E7PfrYhkXiu25CpJc+RWV5rBqussZw+5nIXB/WEgxFT/Ak4TWE14fKK3dqLtF3pmNCDj/54d77k9S5RBIR+ip/EiEpnXokZOAAlffedtQg==	do4o2f7wu7xP6L0ILAbf7+syHdLmiOCH4ifXSj12U9gDSdpjYmm5IHUTI6DhDlsdpsv9zV1FU6tPX789kLJA5lvXbuN5hCP+JfeeN9uh9kM4Ty7M+1kT1v2qyuKhgBACcbtDm5X2PRAo7i+cayknYsk1glBPQQYCUSTRQwOy9N1Y8dOZCM3z7I8KRLxvlUIzcKIflJWUjahg2FnDoGqoiw==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1/9	2NB55jR7Q9t75bpHkWGUTxUqPJxAPvD4uq8	m/0/1	9	SIVj/cw96/n/6Pgt80aGv+XKY9vtK2/hdGjehcxQAqO6XOjX4Q2d1+BSbGMp8IASA25O7mojOZK2jlM6DXnGgC4nUvxahvZZZaoaMcgYnjDqWRUxCvnoljYMH+K5b6y1EXspp2jdiqvwpYOfs1PB94ITXDnepoM2aS6go5LSSEmJ3t8Qn4q/Vtxq1d29O6csKjZbs7LF1ZZypFjUUJuRSQ==	IVVUd4Bwf8ZaNV8ghc0w5JyGIGfp2+D5SN5Ek9Mn7hv2xoZJ+eMFXxnFQ9XyPULG/cCQQjlU8fF7ZLo8naA6knIUm5iGRo01townpJgC6BCXWGYUONjjj4T+3DIMuYSOXidrMu6SuiHuluuCPhcHoXgEXJagRtwjkYyL9ualtg3b8heNK8uLkKNvmFAG9MM7RyevtBpgw05nSHZhNCV0UQ==	8FltwUwuo2NKT/2YoX+TMW2ocI8WCRJ7MQA0mx87lfM3ugqqsvVrmukCr6Y6/6xrmHNtnceGRnIz9El78X4rdWljZi2nNp1zJieZoGBxU2VTtIBKEe6Vq0vR5MJDHLaXuFNJcuUdF7GiQwqE8LoahGG5Wc5W2W8ECMwWVTYQOeoAwvpSftOpRJhiJTdgaM2872RjL5vvYDTm8hbruv4kZw==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1/10	2N2e97x9Pqu8k8bGtkxx8cJqCqJ4aQJmDf9	m/0/1	10	M4aI78H+CVn/K+tdN4YlnzRANyPalLpZrjXUUkiDhqOnvqshccGReRgu+ZbXDCctoyuKbf1g0Zho00g5fn1zevKhomiVJAU0Gqi6pZFcXHkUpoFRwLs+TYYiymdPVpW+VrCWMtbV6eS+a9HDlIYrkatzY+7ucwOZiDX6i2b1k7i4FK1i5enNJmhXmYpT9bUwMgJ68h3wOmoQoh3qgS28DQ==	1jgDUm4h/UDoFBdaIw0KGmUd3aFs5cH1kwUvVCfzDiAMRt7vZ6QURp8s/47/VDpQmMHzpLS6+HoOObs9as8/0be5mi1dCmnn6Rmv5Uk+MzshpGnTRrM79pPD/InUNfveZDNd2E6pHBpAKpY7yazFaWKb13uTHXGVergZGdmOXD4GRucaXFer1QIpnV6B/MpG3ugpjxg44j+pDj3Bu6NTZw==	aVbJIEpe6GEq/r/fyvNa9q2+hmogCseJI2SAejU+qat55gevXGMmtLpl3jrpZuNjKUNffoJyEySlVa+MIwpqqAxHAZOdGXyxhw3VDwLbicaqZr173VHVbVe+7kiihadKGwwtjn5OqLDt0IaCsq7FS3lBneGe+z1rUJghc034yIjX4JjgQ3nVzxc1FTJjiuj/ok+kOJbK9QKP4LmFMlJT9A==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1/11	2NDSiEy1NwFurK8foVj3iBjySyq7TUPPppA	m/0/1	11	FAUwAJ5IznRlG7A8KSYqKjKV/beY4VuVdp16++HgALubI12aAGBHXKht61tm3UhlWCEK09Jvy3dbEaWfAfVjHWtdUETaIxJiTA00cvrnExs49GekQzRd044ZjHYWIOkzdWTJto72fpR6tlLcZX6gsn2vA2OHFtcSRGK9Dv/BHbfWaHnL2BkxS0hlClGyPSU1G2he2OfYqCxylfdNgaKEiw==	Se923FOdb7G1Pth4LKwnNIHmlq8xZAZFVkqAvqz+tN9dY6AM4h/XAC5+XBQQClzz7mBM8bo9mRVamVDXGHjaDYSJmVKvfuRfqlAoY6jjqZfrAoTCLVLhC3/eUt1YLuFcZDud76D3XGm8Dtp41cJvBq3jnZr8s1sbAnSBZQzGv5aEmEQc4MLoinD6X+TtRYTVl+YuaK+wKzPag5hPzKaJOg==	VeTW5toDoz+3MMBEuhJT+79Ew+GItrUWIGMAQ8wXGHcbau0tQN9FYCSwzTWtIIBIt5kJ59goAFsXjrmBxrJTJx7Du3/GzSuauNCJn0kwzFlJeoKv7Yxyv/wbe2cHzOEm23qar3UOtmRXgtE9QmmnALzYDAqt9WPzfz/4Gx2ZtFctx54RUbzzHFG3S5bc2dyOy0dU3fvliETpKKZcJOyZlw==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1/12	2N5HkEwuiET7AMvvV2nPR4upHuHR1NEaGz3	m/0/1	12	ixPM8zdYy4vV4Xgt3DlpJvWvWRKv3ozMIyk/+f0vKQP/z5IoG8gzw0y3gmchtft+2aK7R4/7j5p40PWBPsyzFAhKbyGd+0xQUtAMWHjL1Dji89u5NufSWBWzGMwR21C1HTPE9dV+YFzm5wmzvKIEHh0MQ7y23wOTDONUPyiqy7HddE7URh57Nh4x89S5KuSwnf5DraPBPgmC8N1nXxvsag==	EG5ZJF/sAOhkB0qfhYXJVmmgpowDi0mgdL5FToBIK2mIKnv38V6wGyhHKFm4qrB2dnBuK4AgSVjFd+Rbc78ynv4EhTmDxM4zyRODRwKVMhB4eUCdL4qL1bjE6DORhmNLjcz9Ej8Lyjzti3yu6eO1z4Osw18UV/DffI7MCydbVFAhqBIK1pzIaj0B+tmyTcA2aOLa9mhP/F8U4rn0kZVJeg==	Ira2B1TlTEAR8OPLVtE2J4FvL4tgMNw5V23V7h4kNa4x0JsV95WmMTr8Q/1Wn71KzgIj2Ubx2UBRhzJ8haJqDjtSSBJYGB0iguP0Nqy3JHZcNdNxn2QOpMOH+pEF9cbwtzEFHQhehhZad4wu1oSLmZbyNlJlKJNvq7qM2O2r2ciqli0SEgMubwHMAJ4pAZN2W6JAYkfj0bz/h21bD2liAg==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1/13	2NATMgFFMrsbiJhBYqGjx6EhofLVJQXqmx9	m/0/1	13	dg++aw7AdnYpLXJ+KkDtV88SDR/5W6KLyHZnSkasvljNocWovQ0XQPKAf4raCKggDDdcD4tqF9dPDgdK4F0EkUpitq1e0l/+64bx4XfKODiPuCVgikRzQ0dK7Wf9JPeP08gjqmUg7caNvhNopCPsYh8AbmGB2dkUpqeyC1v5u3+zuRkebB3feqUOqY3NRtGMTocXwLaqnPA1AD/Lm2h2pw==	is+zN3qVb2lKrUfwIMeN8KEfQhtk2BZ1jzKZDQfqwml26slmybQKYHSyV29tX7KE2gxfUFpss22YsWwnR5YM6pmIDkbia2UzIy7WRbWFFVvQRk+EyGRKR4oHzU6oaHZDdiOZt95ZsxOZq4A8GVgsH2wPQiTTAgfKzVTGm8mMmpgj/eA/LMRH9A4Ni/FAAqJ5sl/PGCfAglw3ehZ8LJBA7g==	WI0kTxigb9APAptbH5th9kkXAzCDco2tRdvFJ/VJOrY0HJ/5/rpYrp2MM9BY8YyYIh+RJW7pBfgnu0pZLfpVMFD4i1YWHOxvnEfzXGB6dyajoSqc6888FIj8DbXQsVX4I9yFzRQVz6emu/EPJidQ+dkMTc/IKXo9t1js23df+23nCcY8XaCNrnkLhya6MP0LFCfYUimo903Ca5m9zlR9fA==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1/14	2My9puZhoxb9KPf9TK1A3VbSdf6VpL5CTTn	m/0/1	14	4+FB/30Ay5EResleAHomeLziFEXeHLqYe/ikXMoyCntF2DmyNnn0ZS5maZGHH8RMnHdfxBFBlnfZEf23FzbXrll+hlWGKWVSReDcq+OwuFgRW8FI0dWtY+rEUbMKDXz8FWfEbHNeGI2ZnmoCEdPYysHObNvROlQPQWBnz4Bf/UnDU9g9hcegCOxss8O0RyYN9g/hVFBP5raHC5+nUGyD5g==	avIS7RupGXYQOV116Tlewdenu6cK5Gu6Oj9gjEeZWElASt+GNGKhuYCNHkqxIM+vq0KmZTQFFr2V/UGNKq1yKXPPIGjMWy44QOAps1d8LF+RQ5IXGXJvdu0JkOTlcRGxuvyqsZAtOs43XBX9C0su0rILUcgGDcjYNbMBrAR9+SrJ5jlFu902XHAvmYCy7I2lpX2QswOIV1sQ/4xlmjMKnw==	qXqdkqJB9GZjl9XYzkLsIoEULI/xudCqW2xLyTv1BMvyhVeerSSgxs9khM8RqTZ1tj+odP93rkvK6cqXesc/KbxYkWamIQ8WOgXhDgCfinNLhRZFR2NoOXA7w+3OxSlUZboWrGQsz+Kb2z2lO+vfqHIiQE/Dv1mUp3v/qNgNaM5YuOuGMU1YHusG9cl1S8un5HFnw9T+Oodiu5crqH1ZWA==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1/15	2MwPd3V78QyhtiddVmLhhxBYSTME1erJrgr	m/0/1	15	eyZU8Xp9Hh2Xji22yoiqg6T4k/osIpVthH+OLQ9qwbSlFIWXwQpWGqKHZ7fhsccT/fWgFqcD7mC81ejWKhe2lsxw5Q5dq2KzH6xUPizcoaoIttI0xX+lUEmit4p9aursDAiOTBiJnSUSvytU9f1/KB2u9/kflkcdhiXVfPqTq2npBTiHZwU7MUgEDUx3aC1SdqKTMM28B0hPRAw0tNXBlQ==	TC+Mx+RgYc8b/6100WGRsd6jj4zphwd/G7OwMpJuLR7RDqvtep/OnHqAdbhO+5d0XgedO+jx4NgeBJZIw0+vWo1GacAJFtvoelT0ZIS5kidVCJ9WCY9jpTiarfRnXNrNcZEBQTlebN4hVuyJCw98JlYGfGi8PLdPl31udaN1bPCu5UuwX6H+6x0kqDMZdjUrtgkYijwXyrjj4VmE0qqRCw==	LDOmPg670N+PLDYlz39CjGrimykx4tu1nknPSkIozShAVTd+3bCthi8dirrSxwK1Wf/oF1Ltr5liCttMGF2cHP7GgBOEeoBsZw1HNs0oDRUPb26ehobMjgeD9xBZCE3fCbN7lRNBCGZjxxYU9wscxAf+qMmEAlr2r/yeBiBajYt0b+QXcZ1DS15xqM8tDJmzjedUAyaYVBjeZKHkHGWIWQ==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1/16	2MvusY2qZhjmXfb9UN3eaoQexYQn7BufcU8	m/0/1	16	EZ8PzTp78HJ12gcNDpRwx8ZVXD4lJ1bFkmB+hIeq87tmcBw9DOnst/fGKJQZZTXnnd7u74Gvi1dl9NIfprceIGo4g7lb0WoP95xQIQ+vRcGJUwOYUNNHkqvjAmxc8YRG1zSV1G0Gp2fVKmfFQwCyFpOMtcuqRzMJAIASGiEVFLSOkFg5FXc6WkKklIER90ups8yXnvgU/IMq8Q5VIb3F0Q==	Fn0BdlWQj7M28UhVsXZSpgY/rutX+scP7u671poBD2/wXI328CuwiyFFznvrPgVs5naESTtmqVJazkB6kLP5Jv/qfHUfC7Pd5erou52aOKx367qK2K9CChnmz3UmYqFrcA4lvWnVWdvQj7Tt/RxP9li6cmgBmTvthccFGRqIfeKxCRXjrBiYRUhSsSKewXW9gPD2iutIKr+zawevWZOF7w==	AszRYQNVhmlEzHnQt/e1BvTrzTVEYw22Bar48tvr8uIWGW3YJ+mOpqaOqz6vX8LxNwjCbr1y00gKLqoAr8SL6fRYuoIdU3xvRZKjgPSI8xV0YWlbqG6MtB2gul1KaTJOl0inWSaV6Ydk8crj9Ch4VmnEpuSPj8+/qwhX9DKs15+1sYyiG2XyouTG98+wWzx65072nrhr/aSJSjfV2yR2vQ==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1/17	2N4Fr6qSGy9JTK15kY8gb6ewzAbDU6iYLpK	m/0/1	17	g4FJTzQ58kJCAikzbszN00Ls6SgKCXYbN+9t/ueg2ZCuGwwZMSAD0QDaJ2XKQubeTM28oAPrMwsLd5nJmeHebI6cSjceYRLOw+wFtCA7ldIO6p8l7xCK9D7yJ/Uzi1I3dE3aMktM8LtywdAevVCLK+d4JaL9y2XkKGlWvbE3xep+k+uyCeUQ+bYxy/BM7iooZ3t4R0CeOmCc8DPce3xMuQ==	4g/6Jw2pkjKZ+aH6LWyOdH4e6oCq3i4WUbXvgkUx6sqiRE2UiE+Yz5qGoY7+ETQfSJqH/wv3gfG2kXJTAg0YsR6g83265bbSu+L866p0NdHHV7KSV4oxtguRCUNoAwF4C5R/mSz2uE33P46fLIx+2y+mQSdqcCPTVZ67Gv2xzR9arvqA9VKeHndm3gQkhelrmj+qUjFkrtakwtUmt/DW7A==	9+R3cApr3OCuGqYLucPqgDLDEHQ4Tz5UK991xI7HATUdrWkvCTbJDGuh474hKcyxk3VYZHSvK48oAhr+oLnOi971wCbh3d/I1+0+dFfcWr3krFhtaVCMYE1O8+AEzf9d1nBlm3buU6zoXXGlcPMxKI0JsSFb3RpDUkP64GdFXLbZuj8m4u3gueWXZ+oePBocqRqwVlpZ63ypbphC2f5vmQ==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1/18	2NFTCfsGDiqqRZaFQxPrJs89gofRaaeGyrk	m/0/1	18	PvV3rxmErSKA1W0ILiwxRfnPoQM8p4U9WtDqISlD+PwEJnN8HipaUZOiR+Z10uhtZVueeEWuFwujyud3BdjE8FhfAroGsIoxjESwW3hqh/Qz3F2nIBBuh5tSo6PUlyGOcOEOJXZ5vshdKlAdkQS+YDpdrfeI6hwE9uqkfGUaNEjBiGH0e0voD7upD0Dq0dynTDnHC3dnNMN8NeV/P0EUpw==	Qd06Rel82IcP5oeVeiS9DyJW/eZes0ZEiBB9A81vR/e5efmsNp5e/IsTi3Vxsb7EIYLyHCbb0Fr9uHBo9Od8g02VjZTdsTzVfYhZXpIy66KgBTi5XEkzl++4E6HXLncoBsw3j44cxeMP0jXGbnRAJ6SGg9L/1XlUxJzK4e2mzcqWZWg738usY4Kn2W8MCfo+hgW5SCxpInPBcy5qJME74g==	cRrcK7DyxUh0PXyfj5AgiWKfednrBtAM3hEU9R3ieUWamf+v9u9DoAieZeGCJR6hZXbZTrX7xMWONwbFcHOokBpWX67P/7n+lUySBFAjfAdFDT0nvW1d2j0j2VqTyydCr7Ht/ZR70a9zRhjPrlYXK1bc3hUHqVZnQw5tElCqCmYjrl9WrvjEGPIGHX+esd1dwXLspCWJ6xcyEsgTrEWGsQ==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1/19	2NFUwnjBWowesTzNThaq8wfoP43o9ikDoBg	m/0/1	19	Jh0Bk1wYWJHaw+DiK1vvJvr4YE5CRTshW948tJBncCPfOxDIen3U0aIC4uauoHF8naemC51Yd/tKO0muv/CZLxKuXczlTPvxJo+sRNEqaZGjMQQi2yT68f1c0ui6swOjZGiLG3fLHbHJUKRtMTmRNuRkik+rDLdg0SiThKCjIkESDyA8yuMUruZ89qEQDgMjWiLbYjy3rBbCSNVWGTaDdA==	jOrnYiitApkqmSn6ZkUWuba+eQxPxiBkXL8zZPLsj6yal1x59p2qS7YShyyreWpcto5H+QDOk6nfJL9tMCoQA+0aiBj0XTYsbPP4FvffxYkoJPEc/1uZFOinq0ZwNUxvOGGMfjL6dnSJ9hQDJdoa7ORgfS+2oDN1ln5+JDuTJ4v04KE4+AruPdb7XKOJ6G713DKrzH+tw9WiFZwUHYfaeg==	jMtLMTTZHTfLulPEqf6iBklJYVOHJlYTPOY/mvvrR3HmhmlcURuu5KztxOomfYSJOqDOKvv9+Go6RatvdiJOBWqMo8LLfKzXLhiBAlABtJWXbYYLYTOcVSeWluMukNlDbISaeB8DojdwAFEpmPo59b2ymW53LQL5IDkgahrPaVTtgpj+4Qpouaf4YXX77olvREuTW0PUnNXMhTVdAViJhQ==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1/20	2N8JprkCpPnpFZbjz9VJXtaQGkAkC5eVQbv	m/0/1	20	hixJHd1DaiFWqz8Ss76N2MXZiF6+8vpXDVx2wZQlO5B5kt8zHD+yvu4q+Av5JKWaQv6d+RF+o7BC0NDE0X88mTGPPtPiyaoZJlG2120hkQalo2MHU66dKuYbGg37JR9d7NnyJlE1aKZQZpCfVO6dfuZU4SiXgijgIk05/DIz7LV9AtlA89spDDc3lzMbXzOsfcT5VD4+HGBvqWcbvQXPyg==	IWoLPzMHhJS1/0JdBw9R6BQM70OtywDAV57dWZe5zLy7CTfPyITwtC6ywYYWouMsyeOUD51jjYPqxK3hkowZG9GkBhtqINHLKpRYr1P+J18XTD1Lf/7zudt52a3Yw6sDA7Tf+8TBcrvQJn0/gI/i5Rr+JX38gHmfrJDLgv1FMRnOaHzWF90yL2yTcumQcAKiyrnTuYU4kd4L6owDVzslHQ==	BjJjX8248bkHdrvATAwlNZxLtQBRSQDLgJWl+jWJ6DfUQFiArwoou2L5HmRIAQsuL33KFByW3Dtd8btDzQimFhJY0Nv5T75/O3FSW9wK85ctK/3M5ZxHaaEFx3435pR+SRC2x4+si0P/jWKWow+fMqkfkPrDtEFO51PJp90jGg6kDcSLaXTXthYmPB72ZznIGQosSb2AxR8ZkP4DVSR8gg==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1/21	2N5zb9TrHtyqVHB4cGnhLkeWmyMUNL2V6yD	m/0/1	21	l+AfJodQJxu6oUs+L/FIOL1sHSIHviKnQM3uEFTzd67KTgcKBEhB008iu1nR8QcxogRgYVOPNa6TnEioaBoPZguxskt5pbgeN8r++uRtvxEszcUACJqmRBe7U4/G9JLZlyN6emPzv0B1TjeuBaRFBlIs/IuFRz4BgUh5U4OehxDM/dm2qz/3xiCX9ZejjrNM08tZN7WI5GQHbvmGcsRsRw==	p5gXutVsrf1cRZVeAfsyp2Du3SDL9mZMEBDzu70JTvlATtbwjpsge9FvHP7Mn+19/Uby2HEjwE4jyYiJH18ZxAI+2j4rtCDz7DFY6F/AF7PE3aVidsHS+d7Rg9mVdtKA+8ShkLakBLJAKIHkU91bD9tNI6GcS3BWVL0ljmNQ8kn5epsULe+rgfgRwuxbuyBy0uxQhDVqmQspvTR3wyjHJw==	4kzOmwXR76WSpWr+gxgYxIvHsVBwFW8k2rARz9yt5Yy5sVXXPqf0DNvfxIUXM9qLBd+uHNddjjNGaSD9AZK1JxU9Gy6SezwlZXbpRqv0FSqf8r5GxZkno8lnS5UeeIpf9ypXZymbIDGpfiaoxELgPtHaoP2fXPzEdIR2amLrQHGdO/++LGbeSdFBG1Q33P1OdCsynqSkgzNgAlMVyiO2Gg==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1/22	2N44VkGjD4Ti38kHhdXhxER97yDECaBBf8y	m/0/1	22	fffR5GunIMGxO7WOwaykxuyPteeXdxZD12WNJGW45E0tYwcAY5QlOHj8wdFZzxnGhomOd7nnVwZI9YqOJKMEDfm+U8AOQweQA5nQ7CNu+KOkLXqHscMPttT1sR2dSCkfJF37HBnyc1/3os7nN7Qw+be/z9ChNHw1t+XbjtsSyltR9Kf2zbAiMWhAiD999USz5K9sPtBOWfftzTXl62vxGg==	jIwmDx/l8o8I4p+qdYeDmjbozf8xDjElWy2M0OTrCDaMT1ErJkIjhfz+N1554chbmA0xc15MDE1LI1wUGCWyg7DNhIOInrcvDhFu71ZHlWUYyY5RsNbvV7MMZqyUQGOlLeaKG3Gh3wucgUoa/Sgos3M1usq05DlLGjJzuJq1s+hpZea3CjcXQ4WiDJ2oaRjK3jB6TLWEA87Zm7o6X23qZw==	5s8LQs2DdCJNpi4WB0VpFyY1J9CJ6N1AqBE6JaihXh8eZ21kN5OahiqZkSI3GpOVAmjRaSFy13VCiU44umtfMwz49QfP+OSonsgTqAv4CDZ5oMJWLSbLsL+FC01DDrbs2XxtSN5HH4GwzrdaFHL/mLfwp5mm0T0NnX8V9/y/wMDf1GCU7QOhQIm6GH/OwanBqJ8/D6BWa36bMdQLT+00WQ==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1/23	2MxpnDGhD1uMvDsc2s61bNcPXiwiKNkidkh	m/0/1	23	Bzp+AHg/JKpAjzCIzCPxwdeVagmEKJ3WowqVq/e+fGTcXufU0PoniM4ilSmnjN85ldDN2BCyXjqK5T0DjHNr9ad2oSiOYJn/qRBiuruMGMvx5Ttjg6vynwKK/91Vp4f98Ji569LGUcWJsCwFJBnmWsS7/Trz8wl/Es3qo0q/Nya3bF1Nd65OObYdXkrH27jfMDIwy9AwVSWy2K4mBH4bog==	VSm3zbH9c63+HveQ73Uspzi5Ao5IWxiZgDzIJQYJmuO2nzhGUT8V8nvrqLa+EHoQdvPTmFSljySKYZciOtgyv6uD1b3jCXrwTI0RC2l5ab9FYrSWAXz1S5Bog5S5pKKwJXh6KYRfwU+L8QPL2jWW5Lo3MjkKlTYeh1IAhbHdwq7mWaObfnr+aB01qEMAlVlIbit7u0agzQ6g/UabvqoJnA==	mKnvtp7sn5Hf7T4b37hYLcdEoGfgnBrEfNKcH8GV/t8EZrh0IZnJOv54oZFHt3QbVjJ7z7pLytmQ5jxMFbzpxaTyA4rDgqKtOeaxA18Scd0e3Nr5eaAx5HqRmEqdhrmYgNk3P4eI+HgTNx312zdivX4sUtaaHtKap1qMHTpviy4Qo9n6PdyUCtXmo/r2VSycWaT+5sFsEutscXBu/kANUQ==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1/24	2MwsCntT1gjRECq6Tj7BQ6UCRwtyBmQ8t3y	m/0/1	24	O0hgZ6J/cQQnNcUNjZuhQOcfW6g0AW6NrWzTwxe6YyxLBXtvo/sq+vkTcVYX3A0ZhJKvkyYjbkZ2N8xxQtN7VQbfl0lQRigRxnqsVbEZySm6tNTaKxOduSKL1GOHLNVs+Xr9qS/pg4EpfRCyQwD2vLR+lUZtTrZ+1DxIT0KAmvdRgAJ0Cu6ZhZGpqk/7qxu4nRl2Ehk4mC5iuAaGrSiPSA==	OeRzgYvqzN59ewGwltMrgeJYFX7JSaKHPr4vGs3ilZlECxPHO3qM84t/RcPVYDmBqXXc38PEA8nS7jShocQ0bWVcBqPSw0lF8K7h1oKiwIOA6Y2pNELpdjlN/NzWwNAxpgp9ap8xq0Vxl1By6TRMIyhWl/u+a/c87wcwPBQBFcwjfmNAPU03OiqpVAw+a8yCQXZkoIBzpdrH0hAvGeBrgg==	e0kOkoL4yn0mgL1U8UKaE0f8Ib618a77LPrfj+h0BX9n5rWfVu2UGY1B6uxKPJBTwhZdYvx+pTZogEK6C9nFY3nnFLHFqhm7KtrN4OvAzTAy+GXDMGIUurgCXMcmQjPbJqnu3bUqoPw8/y4MeAM0bTANt0HejlbuxhmCgy2cZnb1Yal/tZWl4sqEyYwQPs5P2Ezq+bGKchFOazgAr32xPg==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1/25	2MzVoMKkrtn32dF7G2Korcf2rEYLkrbD7st	m/0/1	25	eamuqFZIQuni8xsSoh69OS4kAnZekcmbTia3VM6NUavF8783CKZ41kL8ty+hak4E37R/6JnCqwLhIaA4IBemRDg01dDKv4eaBAF/+yPT2FFURsh2QA5qbFzEEOSfW14c3UQ71jUqFeT5h7ic4b8Uv7n0m978Gp08ROsAB7vPjtPGzzcjuSTs5GIEiP2ttXZVD3dqY0KU6juI6yRml3tV7Q==	2iTXnPaD4cEZUG6i7X945gY7Nk3UOQcRT4sUHeAAVx/+B/cryNZLRHw7AoqRaYH1uF78D0ftrTfb+/iy0v0TrrtAujB77ndG2yMPfgfuFvU4LR4+ULFZ14nSLXYCpBkYc43RZon4cMo/f8T1zG5MZNWSwXgbcycBKDktf7pxaJsVvhb5ukMGjmsMO8qS0PLNYZeNntjdpVHMv3gjwdaEMQ==	SpY6y6AJ+mu0noPCiN64sLl1hLU7TVW3gtjI1pp0qSXY3LzfUJkFZZuO4IzROAFZYHVG9knWGLqji1g7PCNPJWx8v9we90ce2LKfwEaEqORwBNgZxwVUsAjeSIXesselOJu7mpotma7V18rSUeJQiS7UMmCeAPJO9Nor13aDQ7qi41cy2wal01HKWTnue4nLH+SEe4ek0MqX/Ud3GWQ9Hg==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1/26	2MtdYqfzsDxT364vfomVa59mCe3bQ5p6WAS	m/0/1	26	QYPwgZj0f/1FzXxpicbekSQLAQXZ803HKqPVFMfi0LkGm1wbC2Q6bGIVcw9OrX5b1f/ZVIEi0/yldpUs8Dz2NqygG5Zex6+pudWu5CMW+PFBHA8LxqDWq8nJsRra5cYcOTxqbry7by6EfuhHR5JNoHpORMPFl6ocvpz35bUbJlTHzNLNU4+kYZ6c+j0pL7aPjewE1qbjrCcvRnM17jAHsg==	1eI9keVAQk5uDi14gm1PHGiI9xmQ8fX09babSJo3iDSg/VSX+mfaCfFStpBCTZuL0AkGPD05HcKGdsXRrebu5zDRIHC3qAwjzl69nfo6/xI9nF46fa7A6+SdUA5RSpjavpy6r67z7T0MdHT8CrU12tmYjrOLRM8JUwyBJ1IspczxqmmCUpPyiNIA8gsGtm2chxweulm3g7hlKM/Btdz6PQ==	QMZSTckFc+vR4IB4Drl8L97TTvW2mk1N4+9JNlI1S6eVqKuN7lr6u0iO+kUz4h6PUep0MpLg+y2jm1VrrywElmpMcg+kR+FTNsPUjZSrGQOWsstnHehuMy84E64YMY8HDbxvKDv04Qd+B8oS1/mm4txPY9xvHDe06zdsnj0aL+vTz7Mf+rmoMq+ZaZdkax+AUrruvfUAquvJ5ZNJ3Qt6PA==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1/27	2Mxi73zwmB5NaWdUwPvVMkvaVxg39H8c7K5	m/0/1	27	umYv3GIpSxN8P3KpDoBHXFUQkhUfPhGK+eQkqiK78p2cKuvQZPIj5/TzFiKlONtwtkbcCO3nX+nApU/hcQGLWV3I4sftJ6DhE89YOhJeAVVrsZ+evFXqa466tIe7LY+jOtr3UKuC8QxKjCD43oYp0uFg401HPkULy0uuWuLPOszvnzy7BS0UQdnuaXpMRnUnIFekrpToc/848iiLVXIZ6w==	HTTXg9VNVNFfORmnA8XNBtJEs66iG+HlFWXN5Zym3JxXLRnA2kqSHgKA5ZAvQBOYorTHKZYlCVfNabuXdwKGcI1LDwzyBL/9JsvtPIkp8hrQkls+0WeO4EjnuOWPqCHqVReR1NFJ8Am1igzTRjdzT8By7OEOoNdnaZtDp8+ry64jkv3WuJemxH82FhTqG5R/utkg5uKKjqumAxPPmKZthA==	nhlIW/ULX2FBdnC2eWkzeNuvF7s7vcXBvA2MoLXjhPHaxuRZTbHIQwPgQPmUt2w/Vu82ZmffPzb7wzxXPzHM08MiIWKMCq/hC8kvuZ4eM4LhfLkNC/280TJVlj3R4V8/96I620M3NnVJx649dGcDEk1YlUxXX9dv13KVjBImzruC7LM8NWmHh/JuGZDcfgW6auav+fkBSbQS5jWKGhltkA==	1
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1/28	2N6zEjFyNadEwNoDgCHZgDJx4So3LCZRPJQ	m/0/1	28	DSr5OeihmM8rImC1zpdQPDfKxbhKlXPebH+HSBDLPgPi/FsYL/tMyzYGMySKxlNsQViHyc5PjfInw61QPx05+HSmTXxovjoOVEuTnmZ/s8XkRlF9G+WyWUGR326LO4C8OwKixTCLl+6jhPgadfXi7YytNDh8sCSjx2fVJZKmv4tE+r3zkU0yyx2RPoi+Ej9HoKSs3JzktQs+xEwpVJAMUQ==	HpU2rbGl+x7+qkF61C1VdlXAYsIbeSTYiMb9T+7gHQfwAVzr9E/Kjvdhgak84++vV8ojoJDA8AeLRihb0cU8G6TVT5w6iWeUrd33OGI8+rrxHwKbJJXOABlm3ZOh1MwXrwrbiusn9lOwTwT2s31gu+tNs+Y6JsbiqFBMAt72Xf4UXGWQfj6+qBE8bXSTR4FScpgCELPqtskbc0Yl3p0/Bg==	qHxEov00e2+YcGiRrC1wDmc8yZWevqEnRniZOeBA1x8J2Z0oCsLXLVhh11ixYTpLPV9wtJVLZCcHxv9wPl5o3pFNTciT2Sq4EEiK2AkHDMqcnreeXqxXihnAOINysF5CLtGVZugjwpCiAmRFESiy89xaiKYPwhN2LUjxwybpb/aPxsCJx4qgDSbiNuyCGCDpVJ4vTnJgtqxHr0BS+eU1mg==	1
1be888d0f72e1dd4cf9830224618251944a749be1760835da9da7c22bae70c11	m/0/1/0	2NCLr1Dv4zdFJziXrk7wnjdrvZjMvndFLcj	m/0/1	0	E16APDpVtmR1sTZVZAqysq4aZKgn7Y1AQBTH9nCcEIrkzD6agpcper8V3D3+c9Ty3a7EjXaIIzopaHIAHh+AAdTWwc320H2XstzGLJhhgF1h9cJN9WkxSxHl+6wUvEpByVA7y97ABZ7gIcjHOUFR8XiD5a9m1E1rLxN6nG6gHhG4GERAwjjF4OFoTQuotn8VUzfmDg0jY3EmM4MUcC1tfQ==	SvGjSCk8Tm2bKk3IqiuIFH6R25EpvAO8B5DX5vEnha6MGW1cvjBaDGNdCgLAw56WVd+KE5x4FgvnefXvrEfMEEj9Uqlvl2K2uoUVVjIlQh6JP/uey5QDCLalKEVh+HVBctkyBiqBZ86dmoKSFGfa+GGZNdiVItDan52Bk5sIkTI9rdZfW5fwh76ZxY5sk8v46pTaGfDoeV+n/dmanORWlg==	jWLWnVgMEXJxGEIOB6cLwfJMFgWJJjDQBjvUx6Qm+H7y3IAvwM7rAtiD/eya0c3Rf5JEeKyAhq6weQ8MaIH3eiCvao/RcPP1KGBKn5zKLslYa+A5TPBviI2DIX5UX1YD9Xj+RYxdVQeeP/PFi/Iz8uDvmRRjrAcy2hHq1F8Cj8u38zRdNnMyd2UaTXRzR/J45PPb6HUiyEft1HFC0CvX+w==	1
21fb3f5fb6a0c9a5e6404719057b366699f0be59ba1e37f7d936ef6a2ce7926d	m/0/0/0	2MuZx4Ecn8NtoCM29S7aRV2YdeHuNxWrokT	m/0/0	0	NvlzDMpr96lnrYH3P8qZlSkztP9d4GhY5+aA+yTCpY2/7WLGB1Tl/IcO1tacTug+dZ0byOWwZk0NSea5OByYTGnOnbM1NclvYzjIALTqiANo1+vzc9ZiZZXEwMB/pwWgltoAQPSxy9vSXhP+m029+k2LJs4gfu7nBDuExxKU+aN2Fp+Hl7rS1ePSUNVGK1ezNZSECMzY92J4N8WZT7k8LA==	dlWz3naYdEvwKQim8SKNvowrQGQM1NYchgdoRx/xECVfwgTgBiyJyAzqayeZjuqxmj5l2UZyYaIHHL92dUan62ltLnzLND3nKjw/NWFKiBpKiz+PE69K5uYmiyP9VbMXqJr4F+8GD4//UT+bREQ0w8dzHH/faifYVAFR6ppnTGTBAjJf3COc5zHLOj9SRx6p7HLYi8f6xnurmHW84GpYWg==	3eKKVE3PTC/8G+kLKpyQ8d6k8WoLVJzQxe4XgT03bqbI7OYWwfgIeLALqZJAKDwl/2tmmTV9ZONYfes/fbrBQH2yXwFXjTJmZzPgvkYrvH+UnOx0sAOW3e8ELgjeaPAAa5z7UkPgOY3qvpQ/qOpy/zVxnr7hurHLbJ6CWi4gvPT2L9/8PY0hTwFoautjeh4Rzr7VlgSDvZUtCnpD9iS1Qg==	1
1be888d0f72e1dd4cf9830224618251944a749be1760835da9da7c22bae70c11	m/0/0/0	2N6dZpQEHgViMwrBxHCSCJcNp38eSX8vS9b	m/0/0	0	5AWuXOqYYyA0YozeyhQZ51AWW20lJLny8V6Ceg6lctNTAaz7d/dK26DWhl/BXQNx3GhoBGS91kw5eDo2xN7nYLMaRUhpqJsjP3NDKwatiYyn4fYMTwJKRbBRZIRJ+KKDGqKkIvxhSyFVfTJAA0zC/pgNrOcrjatTysxG0P7TJ4stY8FxX55/40j9zrDV3Fj0GLoCS8SBGzRYcdcw0Zf2cA==	sfOb3C+2KwQe461yl5kkREurCJu/kj9SYVBhmYT4WN+NMHG9njhT6mq1RKaeu1wkqan6i48JcTK2JIfniJ11N6ynSlKzHxEAWERteg4kFxEMLQYrij67KO2IScgz95+IAtUIfFLxDWLqaGobC4bVXtM8FTrg3KBJnJHiZMINxtx5/NFIcDC6GYSjK0m32yjonlihfKNUCS1dNVbesgKJyQ==	xMSpmcdIRJRvOFym21Fhvhw5mjMkJSaRTGqoYJFBa33wOJ1HJgbILyfWBOVN6kH7M9OUEcIWkvv5tUgVVyPgsVMvEaUFXuUTwSHk47W45ZJKRHyfxmMzvKxxgVt1ZbA9anj0ntFe1mir5eBOhA3E5LumYe1wn5tkCLxnQPihI6AEWgtHrXeaLSBKZ12DD6WAswjUqKWNP2ggX+X7icM7tQ==	1
2c9fcb17f3e35a5d2c17ac695b7d6b331f6b2220693ee524b8b202ba0ace358e	m/0/1/0	2MwBUVAtwnPPwDgtUDdL4mn18D1PeqaRxUZ	m/0/1	0	Y5+xy0diF5nEHKEhW19NITjtUA4hWWHuM7cOyxREk9CMAPMyCTazuK79WrCMB03Vlj8K1B5k9IfQ0cS/AYJIlfCEJe29ka1/nYTicu4SWXODjs41HEQ8AsY+l64ym+1IYcjZTWCv/POQVZRUalfm4wOPd7Rz/lxakRLdSGOQGZG8WvLlzdZSJTugZZSAG8rQUoT39ZAl0TM9Q32KghUR5A==	rlziD8qGFPJpN0BiaW27cy30jAw+VpHTDPUjwp7hXu3rSBUH+UQgMIjG4T/XqHCx/SXbs4TDbrmEwKujy56O5EVFAwLGjRhn6GX/Eo80GkgLkI8pzeHCKgxgmZ7+A0+wsZNebeUyuQKEy8d6zqX9KRE1YPICf8rhFt66sWdUEiepUVgyZpm8T8Gmlg32IvfJVeThtwd82viebauPM+wd3Q==	t9A0jDmQmgzy2gc8wDO3URzCmwCWtUpQxgKIty46CeTtTnbMMLvRiaJL5eWdkdDC0OianJh00dUqTFGxFILjwhDWIuagJK7aD264Zf9a1mMvu1CTWDvQMaTNY6gXdCRHjs9A+3JYuX2Tr1udqcD2PvQ7t9bFZbomb8Nmj9D8tK9QJ/JsDx62nV6rDBCn/hhfo8RZAopOP/bmHU4ACWT08g==	1
1b40f08fd133ac1c9e745de021bc15f880b58aeb13b3ebc908a42cd4141767e6	m/0/0/0	2N3JEUGpS5EDFFaVE2LhH2m8Kd4b2y5eYrJ	m/0/0	0	LuE1KPgYjDnoParF7s9ymeNGr1rDTQIX63jT54tY8HjULxsQJr9TUn3+dpD1rdR4iyLoFP3+/eP6k2hP80+We073OAEq5ZI7cQUD0MIVPBuuT6svHLxy4+wxuKNjXNapDIVPZ0dv9Tj2LBSU6444suURwwwWyB8XU8CqK98MBx3QnyjTdUEqWCJjVicGe5hYZpicRibDXK+55SG7fmtw6w==	4esRL9edYBZQ0rNwkpXZNm5Lc0J8/3KHQ/CBPZO8W//WdCvOIrLPPc1aftgfMb9t/wAd1tL7rAytseOPGKABJJh+VRsftq2JRAWK94MdzOvWvpf4s2EFSY3AJyPqF9ULIDrARiBPiQzcMbzcCqkGScLI6fencCX7+pBUxNSUMjfVnZccjCKYuKIaip4k+6QJWvG2ELVkNnkgEg9x56dG7A==	HujN0oCjh2JYQcCq9PA9nCJnIedV6JWAfeze/gQ6bKcYWh+OVli7B9A2Pu1I0rIWRr3p7aPPRabk6LO8j2Fv+MWs61YwfpzTtN5zl+a3jDnn9GHFC9xZEsvCLdJK77pZejKbk0ShlA9VNcC/QeqPZfR7H4FsT6YLubQIzwHthgfcCT0MJx962McPPupI720D9s/eaQfFR9wIakw3y+3i+w==	1
2c9fcb17f3e35a5d2c17ac695b7d6b331f6b2220693ee524b8b202ba0ace358e	m/0/0/0	2NBrN9rSevJKPwed4zMgxPvTV8ep9ZVj1ET	m/0/0	0	s8u/20TP5ccWsrwqtKzMeUsGTBTIA4gDykFEU0ENqSPHdTUojmwiiwaVFT53yG8uQ5/yCOAlZngOlQDgYDQJzh6YlCNLGD+euiEgv6DXXIqtFGiKHrwO6x3JybKODGK29BlD17yoVbor0Qb3ndiU1qxzrgxAvbSFusSUzSlOkgKAYqKqqAzG7XMsYb1dqRsqVYJ0zLi8oLSXujPWDTGbiA==	dOR4wCkIddBsArDmrZXzwJPmTaPMqQ5o0q12itK9pT5/CU97KOdBjTRqp+9fgkTwc6V/45KT6ZQPuMyhZv4SAEpxn/ob2bdfHIF5nnTQQLikyJ7kpjNc3/pqPpLUIa5pOqoK2RNJSF42uZJGNOTI52LJPoCqNCUJXA58/m5+iBE09MBmYinIVewdVKbYaCuft+cizJW7k9bxzOkS6UHWLg==	fFIgOJJxe6BGO1cc5G9JUfcj3ae79snhhR28CJE4HphT5BDUahWjtamf2de4ZQbvKPoSU6+/fSugHzJJwaPlxEvVZiis9OiS/T3UbGL1WoEJ8NlD4bxtbf1OvtrvxaNgZ8G/GETK9j8FzSBPOpEXyo5Aq4chOl77aXguSabcwZIg2q4WDFGNk/a8qKUBske3AWt95gpIFacmzqgLnmF0Bw==	1
1b40f08fd133ac1c9e745de021bc15f880b58aeb13b3ebc908a42cd4141767e6	m/0/1/0	2MxfGyk8PkugSYTS3F1TwDkvifnALY3Cm9D	m/0/1	0	eFk/tlI3iR0eYylayfT1DCN6CphglfCC1jBIMLURnhFimOmFbRhUt+XEdjBhy6302Yrr6MQFMc615QfUDfW6Kx/oe8P87ddX0dC5jBPeWMQah0LAFwzOwVDkNbTE+uVxc+Rhlxxj/RmnmMNaSoFiHtmkgrSJrss69iK5E3so+4D/ixhq0uDG0MspVaw7Rq+oOvMiX/99CTORSc3JS/OD/w==	IDtEuSdRYV/qF/2zJP/lFsicrFio8QBvXSELMPr3L/jylxGVtbPcFv/8ie2f7CYyTr6u4WBwZAw+ZCwMv5lwyerhcOlNA83w4l0SoWo2mbiu4/bWc4ZCH4PXb5XrwUGkHsKEB1VbkWy9ZHF6kxjziI8Oci45thj//zMAdTieiJp5zOPCe6tkEkDmEfmFZV4KGjVdVBvSPmw15eJjpIxM4w==	8ao3tVKdFtvAlZVS3hl+mZ6uFCHzxgqlQQEGbggg8X72iyafUMsYKB+SH5s2iHUChQT3Ey/uPSj3bj3+0Z6Vu1QNUisXz38v6hIqcXQVZRZ5d5ON2g0H1Nm9rJV4H9mBc6+Ez4X83VZEsjkGgxRj2czKRCwBJeKunCtK3DXf/Wbcw+f737MYTwyi030xldFgG5cOEXO2QfnZE369NorrJA==	1
8361b4d1cb16d9ba6b4f6a430c33009b37d23610f4023ba450ee0240c6d55bbe	m/0/0/0	2MtqFJ5epEQ5L6BsLN6NVGa1J1QnTFhiikE	m/0/0	0	9ecjNz71W/w5I24OLSa5rGb2oBGZxIFbi7eFoaQPmJoluJ0UULtBZt256dnAMEL6HJAxjZYhu/yhH6N+T9xJ9M9c8SYIiAJ/gC5Cre0dmsMazWOK244VU0MoD1Z7xZTG9D4lYiygc3DEAUGr7aGsCEeEK+BrlXRDhKPSQWlalbzVdgtueRHZeMTPDUEkWmgt5r9KRKJwbdvElR68ui8FzA==	fqHUgJX5tQeD82ooaetOuonn/9hwYGH7TgGimLzR4Y74XsrP+a7YxnuospSYlCCUq2az8Aau4mdSt68fdUhTj3CAkAQvlmtW320969zGUdrWuCqX9aoxOnuhThY8F25/ywECcHfRrtAK+Nt4Rr4ZaSE71x2r/Qag+GPqoU8g9haHHGrzz3W+fd5Izli/lE6dyttT0SRaf5UfG3dpxbCl+A==	bowalHQtGsdNJ0g/slreNS0r+fVmuVV0z2/BbHvEH7wdTrBLf5kRPsMVAD92FH0GvmzBPrwIRhKs4WlHVblDQYGl5aItT0gGgOxnPTvO1wEegYSfcCwKDnIiijsRduK+WRPTzkgv7wkzIb2XxaF4iuBvEvkH8qldY4Ri3vCBzGGCuGz4DPWcRDCgheze8Tl4QgidhZejf2RgGV3gLoN01g==	1
ad7025c7040d1bf11df14afa54bac054c8fa37362d61f6dbee50605aa2ea801d	m/0/0/0	2Mt8C4KH2STiKtC39trF5R3GsomrMa8m8d2	m/0/0	0	of0c6CNmj1Vqt/C9ZFll9uOLZ9Pu8pGS9i28ZOlrLskbzmBRYurBweTQ+iARmPq7wiYAEJWEP6XELT2aONQoSjscH96/gPTkdtwHHJzrG4i7fAB0zBDULsq2CZ63K7GX33NGdsGPqgctD3tL0xmH1mij23i7poEIvSSGwf5OtR7NtwZ6iw57f6NovgogZTDtNChygd3WZbDyePINLi0NfA==	P7U+frRy1SJKEMJY2TKzr1JnVzS7xK3v+bvJEXTNnm6vpK72udsAuwfu9ZaNQWuVNSKuFr3jBmDrpNbFoc2j4ymjMncQ8+PTb/xiVsNhcLVOWLRQy/DxqDzBtmEwrUJ9I9iQuxmluwS0dDQe7O1y96/LGFuYby6S6YmZ4+D5LJS2FEYO0QRmgb4yyGzw7xCh92JfcUZcjZa+H8dNAFSsRQ==	vMsyTeeVOpG2Zn4zYBmmsQtUV1+ioAeNaBNVO0CtP4BW4hIuRIRoxtn1dkZE8fAe0uZZuC3hHA3xhinKeBxsqPmQUSTXTPkPIZ9Qj2QxuMkT5visVwGKtFudbJZpQuXWS6BhJcZ38k7Ih218GLenTC7Z41KGUaBAKSFlepcHgogqQjDhzhHvLLiU7FVnJcZwEU84+AG8jMIeYQlPerUhBA==	1
ad7025c7040d1bf11df14afa54bac054c8fa37362d61f6dbee50605aa2ea801d	m/0/1/0	2N4gpmQJLRJzXAm3QSTzdBMBXxS54iPEbtq	m/0/1	0	xkcq1DXiI7RO5KN1YtOzj2csETYpY3qnyDc1dYUH92BwX1swOeWqOxnRNP0oRLzvpyPNZi9a9TUQUW3kuGFxjR7Df8TSgM7GmIwLuzSC6e0M3IjK+B4vCPOaXaOliYRwY8fRyOpJ77VmJX0ig9rNckSmS9gpT/r6fZsRMAzC9GuqlBmjTrE8I9AEl9f3ZfzkcePvcwYMH/2jhNXw1SfAYw==	qtaKBm5cVXKGVzIXeWNGMjTPULInREEUoTR2yPiwXRaj7lNoBPp9zhdkX28JlwHnh1NfLmGhds19cMLRWU2tkdf0oDSggHDdoiSBURgcgwVRl3JVSLzjL3MECyj/ZKtB26dM99mSdqFrZJZgRhnBS4kH0pUgMmtluFMusn29Hb3ISLhDJTSBcVAevYW1drGX+ek4k7bB0oaww3kk+CGM4Q==	0lyYnhvzjZnuybiVcV/XfQJcNMpIQYcMlgCXOgMBMiBWJBjVTdZOgfEoWf0Y/FkeLxZCdIUJPjYe8fvkK8Y7+bOCQ+yHSTTk5OM/Ovg93HRBzmLkq355twXd4ki+J69BleX7MzLMog/6A8cBUcJPNyAZ1bOqQkoJwCXfm4WPkjso2JcZYacMU8rdLDPHAssIAk2qDRbi0PJEobKixICZ7A==	1
8361b4d1cb16d9ba6b4f6a430c33009b37d23610f4023ba450ee0240c6d55bbe	m/0/0/1	2NEaeUWRhMkFbe6Hxe3g1JgXTGpHGwLt94D	m/0/0	1	0F+/og/qDDVhNuimWjyWdeHOsBBpac4IPAFhKqyEY5nP5eKZx9zQcXiCudaBFYimkYBV52qWU71bllxH9ZtzW+gh+BU65R6lqfbrSq/MlUm/XWezw6J4b++9AUhMjAhaUgJni4eCmjSQgaESCvaZOglE+45YIKtpcRej5grxHeONTEYW4ag7yKVvkEd+bH/+Z/Hi1TvmTv0H00FQjIG+dQ==	1zuIQMH1N8vg3JGXRLr3jLYJ7cl1J9Fn6OHlMYxhbhNlM0uGSomcKkURJTqf9i2fK84ZjkoRtj82YXo234w6AwWcgTEcTc2Lk9krSglzImpNeTZx7lSovHEkNk2UtnOgi7cWfIk0t2PD/JxkI9lMJhba7nLLvCt6T5TAHWgTDiSJudQvME2KaGwDtqm272qBYZWTDKpkuaB1cvM8QBKTFA==	7EIjXDOqkLVmpI18db6178nbP08iwT9meL7UevFNbS9Z6Ztn4zgpvEYEFtk9R0mpZibjTZajKmWIHlxra7p1W8iULsZKom9HkuQ9v0bfk/5uO2Hj571yRgoFOCGCGREGbsnMUhyCYNrEdx2dnqn/J/M5nlLo84zzi4+njB8h07d0WA1pxt7K22ro0u3t05YD79edzPZIxYbE7SXPpPqWMw==	1
9627105a92bc0de742b59643c811781ee9fc1c10d8b7c7dbdbece3fdf55ebd17	m/0/1/0	2MyjD2NjbP1ApH4gCBqeK8DSRa384AoefgA	m/0/1	0	OWk+laEbPZFb0iZtFkD48/zu16zsT9jY/t7HxDvvgRviav3VytU5PdhE4TfRwTHY3vSe8cgGuOzmBsHCCyJSv4lw+3/mWN3xlGSwz0IfltNge70BULDecNAFyCI/FLqs87JUhY7EzyINdMhB5e7AyZSxZ0P1df57Fu1xhWoef7sku8dKmJlMDxZutECdzpkZo+m/AxtjovrHG400hkZXRg==	rc1PQUQgyU4VHe1C1uhsqeo1QilFCoJCuhm7jrN1rei01i03QZmcurU09YdnpiMT7whu10r7xsg+mwAwje+GwymHU1vfRBKePxmUKmNRaXPgNXz3xkpCPuJ8JkoVnqfCJk5fnJQL6gKROCrP9DKm1y5LfuRQCWO42vXzx9WbQNMkqcGlnYst8lleeYNVLMWpOjM9WtZms7XPTbFEKd29gw==	4kAm80qSLFFLo/2PnjRjBHezfItqiPGtamlBGT19mrLzUyRbyyddiKmLyHUcNVmrVieMN9oAGa2l7ssUbnH4hgVPweZ9QrzkWnYD50sesA4jHbc/eXeW9F7s9KA04DkFWYVAEU6YxYp9ZKJV6QWKgTpIMCdnYcUvoWlU/9WzB6gZoSpEd8aQlG7HdxqPCYPjsUlfTl/7hVpzMP2pV5Z4Zg==	1
9627105a92bc0de742b59643c811781ee9fc1c10d8b7c7dbdbece3fdf55ebd17	m/0/0/0	2N3EGLyaUcRTaqoCinwxESHVBkXnDJXJ3mM	m/0/0	0	5JV2wHVeHGMyq+tc/x+iG3NXWPSytWiT7kPgSXE15GK+SWMrNBnAawYCJHLDyxcbdppgOxoAvMkkRbm8dAf55CwGNNRUDCkxDneC7qNOIjvXF39PZ8zCGvyafnbJsQpR3FepUsx+M/LcTi79uJxvgo8M22iJzFw7lPdvyhlLEyLV6LQW033BT81ojjWlPEy7iia46HT3n8wbHDOnvbfhbg==	9ORcesd2MZKgXIuzGDK7+AQ0tgXStTZ6kRtsWWdeYl4UjqXpkUQrqv9b/raq0Pr0PyQieRFjVYgYpRFyapZfT/AKNEWescG4jm9Kis6ohDV/xFPzOJPbuzDI0Ti3SsxL50RVMbLlgMzlOmE60SktCkDCmqHYgtC9xnwQZBGfyGXL8N34fw157yBCrhsKYc0gkcDGqeBhNLLYRlb+FRXlYg==	ndV6RbAzRHbDoWTy9Of+oSnuzr/9f0Z6aXhL5+DiXIqrhwF6AFyZcSRO4/7BQ9HFASNBptsfbZ6csI5pAIAAwbxY1DZXXV5Fkv9nBUh7tHouKx1QopsbgPHwFiud1F5H6A9Opp61HUMclgFkbfTXoZdXOjsW/yWIEKrnIpTPKvboG6m84jgtHLFTIUis7ZQJTFjj34AEKDtv1hy/vIZuOw==	1
13f9f3b2c5e85e2e4c204d5895902e1a32fcf391daf4d8712b7ac6ec2de41d7a	m/0/0/1	2Mz4ZsqZYar8BtQNcfkYsVAKEdPsqGgM6AG	m/0/0	1	YGPSMicEnPYYt4EMDlSYwZb4nKiM1+/gYEnSbzrsXocNmpY7H+rs7PPrjspbNPvkBF4u9RmU5D6xFXZLbnI3JXEsEeUlJ+Wa72U9hyf7OJidLgCdVj7HsJSMm/yZpQjMbycrP0YW+SqshBAfbEfCPygjDqW3xK1dWELB6/PQelgfCQcE+B3Sxwge0Y9FHDuvfhWRIaYSGVGJNEQv3OHwkA==	kmCYmry6kSxaapTdg3ENJucyx2NKcc8VL0z6X8wbqKfd0TeyT4BxXvOruiKWUNMeHz6KZjOS0lGkr6c64K/Yte0o1zl/KjChyk0URHLz2H6Hg69BAYXG611e+1mkwjIbOx5+6x7ARCxLelrpmj8DcVLs4+SNUE5UZA7nVoJGkiNBof+UqZNJxaohUZKxPze2zVbwDf1OdlYtSFG77lCXYQ==	83iOrEUljcVXhYCPBwrBOiUhchx/NOQ6V5Y0tGTsKqIQpzEvOlR5TBMeXgP9cUhX8tcBrfx9+9R51YG/dVcsjA4QZIJ1/+sMUP/n+oyK0ms2obwsEcL8xYm+4uQxiXwtOu5HLmTRIQ53pQVYkHxeeuuV+UcXGFQGpnjWlVOEP2m02UCbEKhX/nhUhu4R5/dpuCYycR0/q+q2BsVNdVWnbg==	1
13f9f3b2c5e85e2e4c204d5895902e1a32fcf391daf4d8712b7ac6ec2de41d7a	m/0/0/0	2Mxb2EaUjEXRyGtkYrvHjznUp6gUKB6ZM86	m/0/0	0	2cKwWZPhW4+0UdxAXwaqlQMAbsd6op+i2kwKGwLbfiANuY0jbqrK+HfaeGGPVujiwQK53oIX1wIkjQkDMVl2UIJSiSEIuKr0RwEenIY21eO3vwwj37YpNT1H87SkYnPep3h+NeEnNphoHc9/pk9EthJcOIdL6So35AkxkuMLGLp5HlAOgTx8S7g67GpBKpb+kABZZ4SAhF2O0aSbZQiZvg==	m74g/9LgV0yocQMOs5GV4hjHzaPgiY1wRCF/rz7oaWLu5nUhod43fCjKCCkMS86wVt1+vOrelSE3y3RBjYOhFul+PxEoblFNZxpZ/LiamCGfHTNBhPZhhza+lQ5ZMzCmL6oQAv3jsDgohFTwUNMmDjLV+UaQ1Vb3lVX+QDERn4hpTyYukJ3OI0eJI7n/yv1t9FoUxxUQzAcNS5vgUN4EIA==	+Zm//lgTcz3ZFRENz8GWLH0/+zoKR7Z27d/PeEzf6Jc6vDi5TGtbNmDxtvf3E+OY5l+qQfJ6gy3pdDnOdqh/rVxG15v1RFQetJe2xERQprkKKYwBEvtyRQ3mCxIIR6clk6JPb3xykZuPxBVvXP/ZKYnYb5WzFe53Z2kNRUodlzzuXJgQkbBIL/qraVSSsDx6O1A9I2zOjb6Ohmg57lPblw==	1
13f9f3b2c5e85e2e4c204d5895902e1a32fcf391daf4d8712b7ac6ec2de41d7a	m/0/1000/0	2N8kU6Cn6DUWP9YUPygo8yP6H2xeXYbiomw	m/0/1000	0	nU7gJ5yDFDACm0up3T0WfQp/pROdgaWX489BrJjAmWBbwcbtx0mqY4wAwDPzw9BONluFFP2VzE2b+W89lszdc2jD0xGMTIGLcsZVt4WxVKD+j8mArLN53hmG/aSvqNiM/dpTTJu5m/0wlgSnWlYRkHgemBRrZWF9vGdNQCY5sw4vutldAXQPor/XVYwwx2OitCTPXXZXWzHJodLlLsIciA==	7xe4WX20vaa+wOEsP0g7OZ+605w2OfsTY40o2lh6ZyGsZG5hyZtlEpLBs0CzEw/BoTW6FZf+UEdnKDZEFZepd2TWobpzHkUUu3w6aJvj0Mqwu2iqf7zExXK4mNmDsz3gIn3W3Lmt16OaYmDzySE1E4lE9/J0+vNCGGBJRY1UdhtbZQ9UN2qV/jmChltZCZHHBj3yCbOzlpvvdGTahOzaGw==	0ftivZMPP4Tu/DFkgy5rGqT0WIm7p35Y7JJrOsP3Nl684YdIXKjAODnGn0738DLRsZeXib8xMOf79M8/dx+ciYlFtlQklYCmfMW9llnpxJlj4QmBxJk410STvX3/XIDnZmTvjnoMF9aBWhLpXv5chRNFEIh6oS0YbX+/H5rwwmxXp1aFeTHSqwpckHXdXn6VLbGfGwajXN8hr6wXVyJHJw==	1
8361b4d1cb16d9ba6b4f6a430c33009b37d23610f4023ba450ee0240c6d55bbe	m/0/0/2	2Mw8zAY8BbJnAgp5CHTaq99LDtBr9CPCGm9	m/0/0	2	ki5gDx/qve1Wyl39uABFpVz6C8MMTu8cPKgRuGpb3yvxvbBMQkBif3Lw7Nq9mKILG8d/1wcr2aVBle7y8H/xotLOgd6J8/I3VTOm80yFhEy9Y7SwyAq0iDQ+iHyis9mG7jyMwI+q31FUFF/JWyw9LSGjr7cfdVFiA1OCmrDpbLh8U/0pYoz20P5fffy+rL9pKW+LDlzP9lkjzIIqDw7WxQ==	+G10AStvDuZjZCseAhLZql/P6MRC/5K6agAMZU4378gDFLiAonc6XYgVqS8O4Ar+kYp7KwsPWWGHDTOCvS+38lbwcMETNWQBVoibc1fPVi2FgkmI3QTizr2vrXJcgoapufMXxircMfSEwDZ5sZlrQ6qFjfUaViLgpwJssBOKG6ELqabp6IjB8CKg6M93XbSo6sL+BAPnXwsICziCnTfMDw==	5H+0aBsLMZoVgQqixGY0Uh15tGvPnaZVS3iPL14VaZwq02su0NDl4JsLw7oVQYW6thF+FJF4ITS/nDQLwoM/ZIdON4LBLvv6qKdvXWViPGCK5NlRn9tWruRPC+rpYmw/ZSgtaqFQ9Jap+jWize7oWGrDeq6JVdDGMZpmKxbaUnc4DXA4gvTq3lUSKEr+jeDtgicT55j93TIZmrayVuF/PQ==	1
13f9f3b2c5e85e2e4c204d5895902e1a32fcf391daf4d8712b7ac6ec2de41d7a	m/0/1000/1	2N1UM3P5HD5mPBFyursXsi9e8Dsj7AvChdq	m/0/1000	1	JEU+COva4m0f8hY0NKdt2Ii9ZuWwrVWVIgNOy3kSp7sKsN9XDj5hmtvSALC1lez/ImkwYii+gkStF/iSuDTZNn1bSo88JyvYnh3I5aMW8mS0deR5lFSV2yXreShAAxaQvBfYCD5uaeE8erVxcSU1+q4sZL9jxNgqKxr2FMJDfjPVkYgmDQXCOczxzdrk9d7gRt63yR2s39vWzjxfDAhgzQ==	5Lw0CrwsxDkWzrzKCfIZOEHEHtxf6KjA2QxYGnNPNIqkolgaKJLqA1ALapK567mwo4bPUU0jjmUeZCJvRGCAXUYJDJ8iumT/e5fIbO+8txYyr/sTOhZUBOsKhquG/mZn7fqr0qsRbF3dtNjyHprOT4VhuZvMITZ2zUKTwRrW3SpyZYLE1cvbLgUhtQUyr0SnfHJbDg9JRtzoLiHri6pC1w==	FT/UI3H8ZUpIwXKGkdDvAil/jNP3IdtMmAlbTwkAE5zdojz4b5OgJd2tcgx6jdWST8BTEMX1hxvvg49DahtoJ1KOCBwxFj6r4QGNFVJIktNvbvGljUDcbcE7XVBgk1J/sh77pyrsYlL+anRH83Sa3ZqY4EnnXvcJ471DMlFHOpLzyv+yEbez2YHFdEL13lpb2GeURNrHwlPMJeEc0f6VvA==	1
8361b4d1cb16d9ba6b4f6a430c33009b37d23610f4023ba450ee0240c6d55bbe	m/0/1/0	2NF5vXnJ1JFSqkNo7TAyHS5vywxknmjSXTf	m/0/1	0	0AIsba21MhVBIKnhahhnqdf5qeDZFll07N2z5TurZNNQdM0/NffoaJG5+YydsPJO72kNfX5kS4d1gPs3QY0W2Gb9clmJNjE16SGqByhR1Sq3+LUkb12jViFozpfhEt0TndaXUzm4ohDL4kl0aWG4saYQjL0H15NSR3ABKdHmBwwkmOxS6Or4cO80941cm2fNffKFM37OUzUvZSooDoJQgA==	AXj7VZPQh701Sm3jBCE9owGYKT/7SYEQs8fKFndvS1yYUBJn5GzAR85gBUqQ1fVyDZ2SXkNaJfyvheN+iA0Wo7NUvYBkoDZweW4b2jHAdqsDpBeqiLiBGF1GfTOdt9Y41fSTIzEvOW6f9+m7/+e1iFa+Y0tFhZC2P6CAxEZ9eGysiauCgrXPOjV01zHoGlO9rj24H15wc7XXwvk536uA9g==	lh9en3f3hB+bT9UqPu+gBQCMQQwGUhQra8udv6vWMQowUcL3+krl7MszQ8pH91lIOoEv68zatZyn73p6Wtl5PSHY6tRnmpzRVV9n7SPfpP8jpst7d/S6jhnSR5iJrUOkIByuhu957ygvPQdgtJzbxhzWreTrJ26mv52VCg0fAebsuQSCGMwTLWpQPYgUW/tUV+Ykrpf4z06HDGl8egh4KQ==	1
13f9f3b2c5e85e2e4c204d5895902e1a32fcf391daf4d8712b7ac6ec2de41d7a	m/0/1000/2	2MzNCqJ1kFpDjUaf7cjS6JEg4aYxLLhP5QW	m/0/1000	2	GafVCMtAL5C9DRqpfAj6vr0abu8kB6apv4o+sXmuXmZgMRasf1CR6dt1Y2xKhK2erkvKa8NyXqroJpSRiVO23NUw/8sFbjlakKT1so+IBdA/+0ONWy/iTr14BqecpR20ohl/aqkVVWZMlS5ioOE2Qt+vYA+KI34n6CevbRLKrMfF+H4n1MIp1jyhEu6o1RcJoptaO5JpWPvT1AfqBRf0Fg==	PpplYUPcHU4y9OV0lpV6V1sjCp1vWv41EkMMN0sDhWeg7+mWC1mHJWDygR0+9LX4Ayd+DxSHYQB7jRt2unwJZfBoqTwsiLJwcWdf4v1dvR7FVm7WgnZ8mwVj2yldFnpyIJOdstk1OYYIEtcIgwjYMOwlHgms/KUemd2KvtyPDArdFV6F7lVG3mMRmELuCQsxgQYPlCwAslBs8AC3MsQD9g==	53vmvuPE11xXq02EX/mPzmHGMLbVpeUKTGCdfaui2r4cIXDgFK0p0KuqojLvSw0TM1W0Mia+INx2kHhdSKhFKzDNx23i7whDpojOFj22Xi/tiVGO9ZuJ6+7KZ6TxKjJLQ0qhC/jnXdN/G6fskQAv0Ts1pStiUCGDkq/FaEo7XgINZIeyhbMB1IBzqnvCkZOLxsNOqyOhtL6ng8tFX00zSA==	1
8361b4d1cb16d9ba6b4f6a430c33009b37d23610f4023ba450ee0240c6d55bbe	m/0/1/1	2N2mvQkGwbSaKGH9WTL1AexAKPCJ6adwpyU	m/0/1	1	DDUFv/cUfS08i3BoVXedqCj4NFIQAHqkQzYqD4GmmrPjYtatAKRlIzys7BtCMx67oqaIo5ZG0qOIkXl2dRtNCg++BwmAy+NoF7A02xlRMR6JFNeRzIHMo3hGTICw5k6jr3xyrgnZ8zOMR+vh+uiDF8vJe0Aod8l2+51EzULv+AEBGR2qqV/K2femnk2MRJdCwjThVFInD6n3U4Y1XQKufg==	8NqaZY5W5X2kFtL8sNuJ2WiihnMxOkAwZHNqcjiN9tzhiXH6c4TEz0JTazlQeWFBTkr9cr2NackuLtK4n2LaW2ut0Knatp1QtsBggGsWRsazRd8YxW6yPMp3LLyJuUfoyngCawrc1Q8MSxeEQHQ1Wu+2cCzAs9EnHmbxdGp/KAQ/YKMHrE+7a2Sq84bcd2TSDhknOj4as1gIEwAnaQmXCQ==	6ajd/am89sEAJ2O06vTHhA/VTDQh2SL9mG2vXxOxdMYw2QX0cgAw3+gk+WsFB2LNFAjdKu8iNLJlRLkEfd0X4uQ5sU5xyPQ7je1KzqPLsD2CzuMMpTwSj4d3Gl+1tMKNvwttZ5JcqXj6TcvWUESqhPSTQsfLqblID3c6RZ6zvMc8oCjvCE3c0VvIP8ip5QTEc41MAlALLYup61A8vD9K7Q==	1
13f9f3b2c5e85e2e4c204d5895902e1a32fcf391daf4d8712b7ac6ec2de41d7a	m/0/1000/3	2NAfWz4i7MPbi6kKYfp62NFbhZHkvbUmvfu	m/0/1000	3	5VGZ6ges9rigGjZ3peQQyC2tNINFicW2LM40tlyrj5F/b85fDD6TSIJQkaKf1as0AT0gBMwrVKHFJCVGMq5IwASKcatOjUz4BJ3xa5/GOxdK/KMDv1ZVb5FLEhNEzM8JcqeNBRBKIZRTC5TnbvvRstaBqWEZN3u074GPS6rXcCck05qQjmM9I7+ua9tz8fjlWXc3Sl5s89mpel+e4Mb17A==	2wj0/4FQSnMdw5PD3fqDW1GS+WOKHWMj03h3mklqJ7Ued1E51ynFPk48uGCTF9r7+8CnMpqv89wqetYKeuSziNPRSumK1qBAIu+PROB1ETycus15PTu0wHZSinSPvWjc5XojUPOic0t4B/tTJqSkD7RudiXHm3RQS09h+bzo5Nab7BJFAJ1jx9PBMJaS3J1Fcz11IfeeRgfw79hexE91xQ==	piSpp/xSWY5DAHs0SEdbJnxHDbtzNsgmyHaIz2rB4XqhVE4JsTRwlOUPoRsAM9XESqjHAtmGFDv57+QUGIEwFxL47LU3xhcVhF5eI0a+85QgpWXDY486SOGJ9exWINaOudVgluiz55wrhbMJGDwMbwrFEyCP4Xv3ZdErOC4dVAavhSJyOFRBBP2Q0NsTUw50fT5CE35+Adrn89LGEK6JLA==	1
8361b4d1cb16d9ba6b4f6a430c33009b37d23610f4023ba450ee0240c6d55bbe	m/0/1/2	2N7p57TscF1J2ykFaMyCuHP5jDsHiFmCGts	m/0/1	2	cMynrQk3u+CrHPbX7snJrvhAWox+vSRqdsnN4SR7svqYqcuKEUGsTyF95CDCoHf2zQSfWWM/3bBWRn5H7B8k5ynuI9hSbJgzsxY9bABKgwSIOYBKJ6zDlJGQnSkEi0DuCZCch6Urx19hfgMU9b1w0zArHwEgPLdbA1625E4rGZlebyTBQobVPFUWnp4wnR01mxb+pmdnc6E4FGVqoRnjOA==	eGrvGxEhbeJoxH7BdAiBScgLe4u5zjBEje0OgjQd51lCikYR/DrjdfV8W0QOUypE2S5BLXGvPHSbtCbC+WpBH/Al1WJvZsfuqPWB/zwh5yvgms/QH02hmSgSFMAx1NYj5qWHinqbZEgkvagfIf1x/FlStsoze4EN4PHHciMgmoelnFyh5boV5c+7rrXDbnNbtUQWsqr0nguFqFMdcsDtNQ==	L7Jw/k0xBGjXYeqg7kMqHVPyQGO9n0Pz9lAjySvTMCnakUsIKURUvzA7hSvmYMxHP4hy8cncJ7aXlZKad2vZbfYWb7gfbP3GYEJx6duzw9cSdkWJYCo5SJwSB3TehbqJtUIzFzIMsaRBaEwI+RPy/X2K7i0W/579k9c/43iKDDMwjon3wqAQIFrBBM5ixVE0hTnLvDjqjd6W5dZjH/jtuQ==	1
13f9f3b2c5e85e2e4c204d5895902e1a32fcf391daf4d8712b7ac6ec2de41d7a	m/0/1000/4	2NB25WDzGotCKHscbqpeaddWFcv6VZEq3ee	m/0/1000	4	m7nIQNSH3A/Z0SOPUQWIpgFxczE+dzlCXu+FqEHva7vmO2gaffTfJTbdZC2O8lU24+X5nMiLQnZqvZbs7ds77PD7qpLSjaKxrl0mO1KG86bnlZ+hQ04Up8mEmFWcYYC8XEPn9to9Lf4AtzoxFPstb6ULS8PLnMI/mZ0Ks3Cuau1O2xap7lkWZcic4ti2+B1tPAzUAuLWA/Ck8W+XMwNmhg==	x9B7qrr6BBNgGLJ11lFCUs51APIVnZfZc3CYMarWWiPW5Sn4LGsiEumOFJfcm6APndloFX+bzMt3H+gH8/gmRyH2byQNNduBpiTWR5dW0WEvENTS8RSOScP29wcP9Vc0NshNfupIsuJzLw4I2O0FKdehxzZ+NS2mBrEpb4c3jvvQa+Kn5SvPtvB6ofSfgpeDBbyc4RIeOktj7L5HV3LUWA==	xUJMbg3rbOcWatQ2Qk6Ti+1nAFi896cLB97Eg1G6JjTx2U+O5Wap2VPmP9NP46dU1NTKmU+vvZ3bX4mlf9bgXMdXpwPQ0aWOYdFd2vcFU2FDcRa7d9tfvI42yGyQBe6NIS19/ZefCqXR8yrPfy/QuGqFjocc0GKNr9KpZpAWV0yMQ8e5XZ/jBh5Qyh5dnjmAkKBHHzLRKHSUdrlOpx7Qmw==	1
8361b4d1cb16d9ba6b4f6a430c33009b37d23610f4023ba450ee0240c6d55bbe	m/0/1/3	2N4LuQfULnVMX5bvt5gD6h5adGRbKzyug7S	m/0/1	3	eMN0P11lq5tWEBlSgrF1hBvy03rNMlTtPc1/pbJXWMxYqO6sn4GMqVib1HabLVRoyDpY7x38f/QgUmnJn515X96ibTZ0f+nXLLFeehP0cve4lzvv+vZJbZalqVsdU0kQjKn2EbvtQuH1SJACpwku7iagY7a+iNZdGW5sKIcG8hs1Cvw6tWF53EIY07OFiXrssIziMK/T/Asm3c9F4ZrQAw==	8meT2SKWsKUb6Hdy6Kb+FiQbwIHv1Dp6ecMybup/nnDnWHVs9ZhhWPHW+miS4lfR8UnA/wyyk+iUj1C5PmCw5brGcMxruFbpBYyjr8OYMjnHnlgBFxpKc8uYu857CNdVadL5Rp2qH/QIm9TrC9W9Gw2v+3nnLVJLfVuLQExz8GudrTs2ANbhL3dcfh4/waKk1Bp1Z8BNUUGm58PzzJaQNw==	HWi7fCnX8LJo3HjRLzqtn9abCgAw78FCCMIXC/Ujhd4aXcMQv2FyfMZl8H0XPGOWCrFXy16iZ4OqoG50Xvj/edxbr0IGx3sHCyeI5MUCpiSRytDrYYjobNvJkIzE5//Z5rDYRVulRdur/fSyO4YWp1GC9g/cFfgKE/7b4HJ4ZVzeJOxymDTMHj4iwQ84L58TIv3RRfk2P+oLjuCRmYFPKQ==	1
13f9f3b2c5e85e2e4c204d5895902e1a32fcf391daf4d8712b7ac6ec2de41d7a	m/0/1000/5	2N5yeHUZJim6zdbGGYMHcBbxTj46PvuRsan	m/0/1000	5	SLrgyxqJaJsj537bQDsbLE7aRYVjNAOMfwSS9pBBscf4p8AVMaXCyhoj08QQbiTgCJU+PD4WtdHwczGCXDrebWLy3iKX7C3nxWkEH+zbDHkqhPHufulnQ6/P9LVczU8wRHekYg9ZOguxSTPwJhdcRs2l+1FPpa0NHZKDIdFwrt7n3LVdihBvI+nP84su9EogiYxd6Mw0f1W7+//olIjRDQ==	eL+QCeIBOagN7DBwIOYyXV98qdrgjxlZ/t9UvvRBOiVIka037yBfpuCs1IyEeSkfAkOmWQAtzDROeEIeAxjac+RuO8sNsCRa7auVypwSfzy263KSPL28/VgCP83pemgIordY3h2tXTPkxHgyvygk9IVVP85/12WM9pfPbghWDxQDyVMb4jYWmzyWybkxfJn/srnq844J2ZsBRjDE4nxiJw==	HKot5Fl5Vvxy+19WTsUCb46+7awqvAcv0Qi2aUrjgx/MCTuqRoxUpI6mm3zCAiegCl/x2c8brxpU47iwkpVo3IxXyDt6I8/R3HV1yRTT3ZE0TOitLYmGTl0FYpWQKxD1q8ZZ3k4Mw/n0ramAmj/WNP7tQ9sXJGipQTfaMNgxgTRooqWMpsWR/md5bCPnh6kEonTJB6N6zYstmqbCFqTm/g==	1
8361b4d1cb16d9ba6b4f6a430c33009b37d23610f4023ba450ee0240c6d55bbe	m/0/1/4	2NGLTCkxrCcWK9UePuQWP94FYCT4CWmFMYD	m/0/1	4	vuQ4kM31ba7mtMRR/ULLDr4HGz7pv+EPdAofyxbIUG7mQeZ0vXnamvlatiNDI/rzrIuTwSLytmeHzJ3m5OnP/L3KtsnT5xp/Gras7Rn1RTvz6VUfjZH9XZs7K2S0cuGgy8LMB3o7jYoYruZYj/lNQXjqkNXj6ONoPMMUS5sWAR0cvHdWuhsf0ABLsyfvLsDTGVuxDB2wtntkvIVDbKC30A==	697i0/sOtqXXwh6F94Tvs03kAuqUYFgjc/f9Avu5GhmgRFPJgnnZaWFYeKNDg4hoI3xn03mJyhcuGoolt0Ge8ybIbdBdphiwbBDfMQ8XvOGctFbLez1aFLClubGrczN7J6cgQO4OiYEeNhPWuc5jEScPjbjsTyGYcoLxbO6BWX7CcyoAXkXVBYNMOxKNmJTQkqkCI2dh9cxzBwFs7LmFkg==	ZymYXnCCLy7LY/THlCjmw8nn4Fa2Bl2aPA3azwKQyR5O/Am0DozKZLpDZBxjkvmDL8uOGkVFFNQwCwVagjHFReTSqMf51ZCbbrqqcQTMma/yAio+Nw1wstKC1kzAZIqCcbK6BWWVYWitOcHdmAp7g8bUbFiJtsWpFpcTS5CO3KBzn9QzuDHkD+rwTdzIQM0PT2rk+DiQIkDbl+7Lun7BHg==	1
13f9f3b2c5e85e2e4c204d5895902e1a32fcf391daf4d8712b7ac6ec2de41d7a	m/0/1000/6	2NFytMXxTcb3k1KMZhN9tNNzG4VyQTLUPPs	m/0/1000	6	RQuMtlMUmkzNvSHwQISPpNbklEdhqCSzA+9pKe83MOFui6JMFJ+0rzvwRQF38rp5+hMSEDvZ5OnfojE09jf2Qw4c1L9R2r5ButuyglUUX1QvsSPZ/fcjQiXxdvuz9rhSQ+0LWbFXpwuf2l+seXX9LDE7OKVGNw6//CI4zIz9ywVXJmLgxD1bsOpM2YlkajuYxdF8rnbKCoxGqQ8a0QWGnA==	g3b2oUuNPkNC1nd15fg5w/cZ7ch6scYyyFl2O/bVflDnVmRp0KseIfkdh4MFmA6RDd6O0r0s1sfwsZAD6c1f0ReFnAKew5I+BAsjHwz8V+NVfXMA5AbarW9wBAZDtKEQeN9H+3/fqJvQclqZM5f/luU+LRdsK26ZXIJeeHAiw0tz4IBF/zKMCdjHaBiy6kfICDzWFHqoAjjUp8TqO8HFNQ==	3FYyjYNj/84R7d5Fw+yIJmiKLRW2kuIi9Y1Y0QW55LEYc1PZBgitL69n612P9hX0gdXnqCu7dYPlNCV2+TkdRuMAt+h7f90nsBWckQkXad9DCCacs7Ndc2IG5+b0zoJWZlv+0Z2wW3aeD+j/ZJzhtuAn3SxYmpFvMS0uRccplSKclYcrYTSkVDvyEq49DrFE0qGMajhNuzLRug6G/BO3BA==	1
8361b4d1cb16d9ba6b4f6a430c33009b37d23610f4023ba450ee0240c6d55bbe	m/0/1/5	2MzfcuC2krPLFcJFJsoReM1eX6L8DveKd6F	m/0/1	5	c9fr+2FL5itd+vD12DtHgzvhKR2LZWZA73FAlTOJawr3fopexJCaqqXP1pD1AXrvGTuKZ/DMmtYPQ5+Ei86c7xN49HhbmkiXVn5OR+2SRLVSUJoXj1NuYLIoUWVrcQqim6JfEYAh79A1ae7FZ8Zuu9PerNzSSZVsftq2BG+8Vp7Xby7vmMRu0XwaIrOWgoBPv9pdNor1KNtmWi7Pcd/0Fw==	jOGtQ4aeF48WsPMSJOoqpdtmGFPdvcuIcm+4kYIGR9rRqmoLC68r5tRBNBzK+fQxQRjIpCQu5T38FKqiJl+x6XoSuDfLeYEkXswHdE6vIWoBEDPHsFL3qBI2Z5GNW1WQ+wPIrvC0fBVkohEzY8bX6993m2Ge1ygR7Ubjq3vb1DaRMGmBeTk23tPLJQTBGnSE2P0g93xekod7Loj94SSV3A==	6NACdqPzBOFLY3q6AauSRB7uASsQbaliEErDs4hiVnuszWxeQKI5s+3drDVi0DAZ2hmB2c/VoGXIAXnQONQLVWpkMCUCNW1iMZMF44VH8sjG1whzReu8aUMMvWV4hZjIewDPFPfJ409eTmjImuegccqYTaUIRmpUUZmiv3bVxXLpDTqFnstAJCBHI0g05VobfnUvluGqHlqB0UikUeOWWQ==	1
13f9f3b2c5e85e2e4c204d5895902e1a32fcf391daf4d8712b7ac6ec2de41d7a	m/0/1000/7	2N8iesyAJLzBYnRj2jt1xPqn8uUqXYv6Efx	m/0/1000	7	Ec+RdfrOXxUq2Ub4B4OUk7m7YHONn4a8jenu4iHDDne3+PpIaI9uu8gKRowIR1w1ytKXSqIQJpf14x4eKZa55SB0kiIvwGF/lh8Xe1O+30K1q4qEpiNWlXTAE4V0bBjAxzv2Ha8iQ1+cMpv367Re9JvUUlJ4pULwefM0TbJ2nciIJdBFW9nUIKeR2Gghbsz7RnyKU8P2e1obI0nabcJyww==	cHzBeFA/nM1WTgIlGAunPLLyDtBWHk68HCZynjl/oMzs7KwdXlYSNehsl7zMa95PMm0egEtObeV0uSL4+EuULKmAdKB4iG6aMStmTlimA0P6XCCUSMgUZunAZjlmh5081EgSmvjvTIKKTsV/+1bJzFKcEt/n4A9t4dThzBRuJYYvE1ipyF2Fsz1OOupFvVMxss8QGlX70rVwCYqkEkj5gg==	IkthiLKEAg4f4hZMQaaH2zuTFICktmyK6yFZMUHyvHHhwbrx0UsNmOUMdlxnbvNuuV+RZcVKBvsrkpGegKUSNDuFkygwmLDRDFkL3gc8Ow43ulbimAwEOcw4Eysqb0jmMA3Ut0R7DS3NhHPjUU6tjed6g2QkWcB9ylPX8ZodYM+6NulYcmBFMrWwQgfpkwYxXJUOjiqsESWdLxtPAsX/8w==	1
8361b4d1cb16d9ba6b4f6a430c33009b37d23610f4023ba450ee0240c6d55bbe	m/0/1/6	2NDT61QKuwkwMmLuPiHQbpQqxDzMMR4Xhv4	m/0/1	6	1eAK4l7HZtq6a0CbgG2fcD4hPigvQGedohC50UNPTmw1lJotxeXCX8l4pRUdSpUrHqroiLyq0YCZ+oSk92kfWGQJTajvfO6v14SQKPnDEECInOfcucFxVWGbMcmVZ/Kk6uOOKXm7xcPQ4EYR8vNvETjBLo2xH5vZXNGb1/fFdkRbnVDsyYGMDly/flWUx+4pgCuz3oE88R7XPeXi1HdzuQ==	CaoDdcwcfy6h7Z2QsD7USur4syTVksOWexKAmOMtZxMnEJJdKfwYjRZDzDSoQrodcKG/y5SvKI/ZA/2Zb4CfewXw1i9M4pKOXgsUWRWHXkeFp0XXpn8qJL3XZWBRfP2SFzxIyab6MIC22V26x1f7eLRKbadZzwDXY2rPtWijmSPRZ+XjJw205KlhMibnq+P1IdpsRj5c23B3osCRHQkJ3A==	VRGyoZrhFiPi77ZgFHsjMGjzONE4ljhai6Xsod4d2hw14hr2d6SKX8TGZQ3yWpx1U0Acj4Y51QI4MojLDt22Q2iLb9IZC1MeNOd/tQrXG103WnJ8lwbNrEvw3iNBEuMbm+fPliqxlJdSSLBCfb7Q8oGA8zGs3LrhBXGlaEgbWqVRrBAyln8AFIj66lEiDkgkHYOYYDWxqf7n2xVUCItdkg==	1
8361b4d1cb16d9ba6b4f6a430c33009b37d23610f4023ba450ee0240c6d55bbe	m/0/1/7	2NFHSpwLG2qyQ8wdgqzEcihukEHcfrqz1Xw	m/0/1	7	9Z88DRhMSrzzK15UUM6bdyWLYNPB94F0mGt8TpfUAXvTHXzmiZCwXhdlsUtYS8d864l2PDnO2fM/hSkN591DWGbH3b2YQn1ALH2vQkH2DTWIvSs5CLyWwb+1B0Uo6IZ0cADDkthfN1TlhOp8TzP4acmyNIRL4tJgZUQ+jrR/5NrFW7pei3QuJfnCY0vTWeGxk3dPS982GJChjvSn5ZjCSA==	a8+dGP/J4kDA9FQLCnJoxvvVhqTCbXZDVYpHArJlCs503xnr6ArimIENaYrljkPXsC8xCmdfdJpuvqDLUWIT0J4GBTJ/0q511sdTLggPCpjONZcCGLuX4AzHce5CqeI6+tQg5CbY+/tW283pVjRzrzB5MJz58IIFlrs3bl0ZtnmyLJBe9gxoyG/jXuf5s/dFCvrTuG/Xe1EBYDKOXExEBg==	lZQIMhuBlAbkw6dFrePwwLFe13IcPYlr9nugAEBBdEkUVaLUVlhhT7BIA0DQ89clivA20N6b8eA60PH7tTbPJQ3WagRrD0EBl6QvONWn+4RZcovpHbo4mSadRqHnjgMgb9FcKbSBqNyQkBJuHcSXsaWGwaX0Lvffl66AbOxE0b0+LuHPWrT9N+QLXRcYwOhv8ixxZBKp6XeYIaJicc2tIg==	1
13f9f3b2c5e85e2e4c204d5895902e1a32fcf391daf4d8712b7ac6ec2de41d7a	m/0/1000/8	2NApCKDhDFAmVFyJ8ESTxVtnXWRGVP48tjA	m/0/1000	8	pbF+E42RCek5oI5tE/TwUWea2FECntYbWCJ+F7kDbEAGUfckiZCRiV8rpt7uC8CtLouGRxmCdVUg1V4iqNPbDNY8KxkpniXWu8kpEi0fgfGZ8Q+VUa9l48hfSQ97OfGzEMVCn1Q6+ShqjH82LcuFCKDrjFV+ZYjtjfrOJrVQE+pFOKBnhTx45Lm4iGsqr9HpFZCRqmWy8P4TjMCHBr+2Uw==	XyOwJ0htL8iFwVa53TszGqdkiaIpzrpZAGO1Wqkhe9NHK7VV4elxmgi//V5owtIdRyYPl4CHUYMWy6iI8/JLQKq33RpAo3ddvxKk6XO8jlLnnFXlZ25V6gwtlrMblYPel4IsTxrGDT1+scwvigx4SLIO0CIUtJVYgATYOgnAx9Of1KZ5oHVidLnjjsTmXIPgxmlMhv06HbyOgaxxrGiU7A==	qyOT0bzRwWEImSXwg2x6YaXacFkJw5mVCWEE/10Xw2dLNaJsXM7WkEql1b9sPdNX0mtRG3d8wyo6+qnffvz0NajkXqohTLSvWKWscDGHCqAnrHPS2AQO83KvUUKSbJdMzA3I1beSSJdM7aY8boKDMQZ6xwD+AVg5uTxE1XotOnnJR9EMuG0I5xank8IB3E7b1fFko6CIQFA9FOPJ+alF6A==	1
8361b4d1cb16d9ba6b4f6a430c33009b37d23610f4023ba450ee0240c6d55bbe	m/0/1000/0	2N43WPRfLDzY4AxpkmG7cLt7sTs8738FJpr	m/0/1000	0	iV/K8vgaHOUsSNLPzR3U3ozXYzUFVfgvCNaVv8z/a0QGCw8NtDl+kJaZlvz+3S/AYn8hI/2prNyGTd2pDBmOqASiXtBkYivjPqsSXLwM9ES6WHahcDB24ou3C3ioxF7aXQs5y90HNOWyAxojdqwcrLDt/W02UNzU9kpAH44PK7jnmAIxNsB7HJ2rIZh7EiSKKLOhsJuaUn2Gc0NRqFUtUg==	iMDyGscscMBS8B7f27FPV1+7Do8CZVD8x0bQ0QtuqwRaGivTPKOxhzNl2dyOsEL5tPaEs9hYtsR2qbIdOcODqCBeGSpyxD058s5hJUP3O/MW14rpPhicv3er2xZaRokAXRvw/54moi5gBd5O0hppwXFYOUHiTy22Sdz99YA+XDGLYYGD7EySG+qnZj+H5IhJZdltCRdHI03ECz5m+5YT5A==	t4c+VxTxSn9MEx3h+Xg+dEfUsnBmiYWZKluCTFk6d1M0QpGXnD/I26RPsxN52DOeRGBjTUO0jnN1d2vTb+000tuGntkxMW4YtSjhtczp7IBYTgIHDjMDsJkViE3BY5JEwPF6dydAcZ/yGt7WaeOd6xmXDUh6EK7tSYnrDEdYmGGE79+NTfvL16/7bnwdy4zSi+AgHMCLJft30EuWnBsPuA==	1
8361b4d1cb16d9ba6b4f6a430c33009b37d23610f4023ba450ee0240c6d55bbe	m/0/1000/1	2NBGLyaaViHV33iayq9WPSG1xcdrmqRVXeX	m/0/1000	1	Ua43v7dPz0oSiGdsezMVQZVSZ1LTFmM2YQ9csBaX/P6s4EkcP6Umd4X2VQ1hh3yLs3e5TnuTVFUZGxuNcJpXBqGibaXoSNyYkIXpNk3JdmOV5YxkpwVnA52g5NS04r8vNX82Rbx/w7y9v9e5Yb3gl7JGIDnSvpZJkyzQ9OxbeJ9BoreROZ34sT+RLcPYbXDGBl3g5YsXcUyvBoaAWifjeA==	A04t43do1MkFC1JW1QRjC0Wemqsk9G0U1rULIJfe13cRe0/M2Izq4U2nMfFukP1mvlyTOz6qupH+32RqTpyXibM21bEcJV4yaEqd+wUkuarX8mME2aVhs/AKi9v4WDYdfCelUOZlXb+bJfxVhZ52bq9ajcsBsMF/8cX0e6KgLhFsemLKErPAvbVunsALEwvcXMUL0SR5CZ+e8fwmAQbDgQ==	n0mWMDP87uvsB4b/Gh4hbH5anaNKdExunTINwmhMyQCLU/MdIQuFiVz3JZz2tx9K8jSeP91P1yvM6DZDuM9ANg+5haoj9dw/4x5XTQLwwJLTLSeClPN8uFiV4OiwYvDIdTU+xf1xN7J9VFPMl7wsxpGPkI+q4G7fyrXCIFikENjm3cT+OG2eJMfDwCCHVyhdpy75wN/bKn8ZlUiFAr58/A==	1
13f9f3b2c5e85e2e4c204d5895902e1a32fcf391daf4d8712b7ac6ec2de41d7a	m/0/0/2	2MtQQxDY4UjSr66VHiJ8FMrX5iMj3fGNoQf	m/0/0	2	rI0NvR87TIk+JUg5JIu8G3F4kVOri5LBvUt7BVceAOSuMcFLRAvCMMR0ml40NLu19JHjfifnHN4ex1nz0PZH87NBXXyz1gJhM2sNLnayPocjfdCNrwiM480csBzRJQFd5mJdsPPeI1PbGwDbeNKZWNkEw+7tCLGiAukmIQ0zM2ElUgnoOWVKagkONRdTliDro5k3Ay8wVULRI09YhSDeMQ==	N19rTNzj2FCo4FyuADUoaZ5yqWOo/nP7gHAOQw8RymkyWL/hZ1qZ6o9yvR/LaoA/2ul17kmOGBYj56Nj8exVWt7Y0O27/xfdrIExoqdiFKj8GHwvaCTY47NTKQovcrUXt0Guxc1xzQyUaLJB49qmy/NsvVKoqxXZCD7fj4EC+aeTB5K68w3hNhp1/Mk7FTz573W4f/btgHsEYtAqz1rSXg==	6CkoVwQ+GlriQMRleJA4dGYdMaM2GhyJP6cjg8N13WbIPVlXZQVIQCbKk0A+sYz4ZLsky7pZEHgD7sWtO68E3yENXF3SD39Xujco7Yedbq67a9zJILM5ZRYQO3iMzhozPDnF+jOMylWquFKNuAdh+PJ1xG00/w6qYkGYfFMZO9mM+6OFlZBfrid6YsY1sCdpnoqcC6ZlfD3glyCNlJx9rg==	1
8361b4d1cb16d9ba6b4f6a430c33009b37d23610f4023ba450ee0240c6d55bbe	m/0/1000/2	2MwrXTppRKi15rHiomM371hhSa5ch6nAW5E	m/0/1000	2	Pbq5610ZSYpktSP6GJBlzNqwIrZJJpNK2xQ+3DNb6vRXU7XYNLZy4iGsv0hjbV6pq5YUPJYAeFGtRIvHtl7e9jcrpSEvrrEoFbG91hIf3qP7zo/xIvDcQyhtXWNnRQVTfA3Z0g9YybiL7fmfw3OyZRfvSJM4+5tHoUIHFnSUK6n+NfnQKJ376yCWlbA2t4U9SeamvAy0cNqU3tCl1Fn4GQ==	vbUiqxmPYgQRJ7PxvpMhhliYd/IINrjArSvE7j6nxiQsDkb2oBD1tvbG5lH5Na5vjlq38XoFaOpAamD3kGC4aS8JBUgNu0lPlujvsIMXw6unSOZHRKtEMkiounLh1TLKwmocy8Gs3N7dK2CHlFd5OvLN/LyJlLLS2QkmvzyiPWgtTRMg98a+lvrGJHKDGCHjDwkspQn01jM38japhOwojQ==	ANwwGgXY+Bgz7ZSMmcrIIC6pG6EqYBvApkafXgBw7WjLl+CVsMhUm2ZxIpqIg8uINB4GuO5tT96lneZVcNlsDwYUxkkh1Vlp4u3ttSwZyJl/ykBYqOG9hEDqOONxf9rU8vr8LZl6h/xwOm59VuIVKTg5JoWinZqvLqGEFtn8pLYqz6uDD961gU8lPuaUqdiH5OTp0QVWbZQlDTMsyxjB+Q==	1
13f9f3b2c5e85e2e4c204d5895902e1a32fcf391daf4d8712b7ac6ec2de41d7a	m/0/1/0	2MywdnrFPyWFcACFyyMKog5iJzzjV9aJpH9	m/0/1	0	xq00EiI4i22zNDjZ/S75qslxoW2k2edjmBE33/hKtH53YqUfTr1gyCyIu7DIgk76Ex9OWoyd+b8uk+9Xx+N6W04VVxQgExJXct5brJEDQZPdZEqhwYT74f13A+lla1lerRQUyv1yNOsYE7Dh9EhOQJCtFtH9OXvsFZb7vHIfapBS21JhXaI+F70WtHjJp5sgqx09jywmfKKlbiwkk6tGgw==	fWH1fI1G7juLIDY5A0grgq+oKYUxNt0yJ4QV+ztA7dZ2XJtLMqHhrAQSGZWmwk9W2dVbTbZELGcXTa1HhmEZpSbTxLPKmJau7WbLvBudA4Hc8UbBv7U9nvl2WzhdlMDGDMuxwSI6aLYXb4rx9S3WPArXR8pzIwgOGZvHWjkOc711VBwTfcd9z2JkpYs7ncL5DoTOAHkJ6RbXNYMpzo60OA==	MKh4076A/9Fi6aBU37iabRyBLa5c7wPZaF5J0ZDEv+WEV/kgl80gb9ED/VEn0VUQt/69xrWqXGyicl12WERudUVHbCjcPQ764frm2+SCyD7KHV+/TyxSYgM/G+Fst30k3PdmCKASnUPWYaChb9KCgSybYWibe6Xw+fudvTyJmM9A/xybDb1S03+ap3kqlLciELnVJ/JbHvRxwOtbIbrrpQ==	1
8361b4d1cb16d9ba6b4f6a430c33009b37d23610f4023ba450ee0240c6d55bbe	m/0/1000/3	2NB2mNPps3q6Ek4ZgJz6Dq6fpLeV5jnJkUc	m/0/1000	3	WPnYZw3OVQyTua7YZg/AV0YMlf+F4KRkax1UWv8fJZSPfXtivT8luQXRfS+dF0ldPwQN1KtkqDxC4v5Tg1LZKgNMxpzsXuq4HmJDGBEe0fnNawivYAKEl0VXabM1/ILi/sJzbbjT75f2KvbMRusU8NP9CSvh4OejHip4gaX3zDSeKHJQyWz20MbHRRc2J0HWUfAInGAaWc9N7UiKEHUIRA==	bo9ci+SaAbDMcRFFUIBUaNumO3GqerWFtL/PPHNwKRNw0+GRSle6ETY9GtJ8FqHZ1rrGl+jt4snJrFcmVjbAkRrz4BggB0PqVCEFFK6/0MhfM6vUcUI6PScHZXD+yLvMAIpCDQVj5V0MWrCpSWQwwQYe+m8SUdVqVJXsRgjKIanfV6ednEuqu7HV9Fz66vwbbvMA4LUVskiDGiy54LhUOQ==	aIRzFfSHH4ejYALk+PDGuFMU245MceTLUhGyBHdWdBaC+6r97GZKzXEPJEqhodEmqg3owwqLXtbgeikO2uLIF0E3WaMvb5nz/J4N7rjh0mG0JQsIuXbIjt4E9rZIGg/+HTBKg/rmekiToOckES84/QNBrBKe1AB0rNBCI4+rjO8IpAhSUnfjl/35VaG4Cd3uiEOiieJoC06bn0LX6QlCeQ==	1
13f9f3b2c5e85e2e4c204d5895902e1a32fcf391daf4d8712b7ac6ec2de41d7a	m/0/1/1	2NC4C2VRPMz48L6x3SVFS6p8RXjLRw5N2Rs	m/0/1	1	gWtLr81FScBtIOm3Uo+4EXPW4Gd0E50qZP4OPz7fNf0Oki8Eax8nMM572crAbw2iu+D7YZOST4QRuoa53GSM3V9FX8O2lLppvydAyjOw3BU5EXkS8bWVgZr9WJNemluHYoTec7wr5cNYvOT4XPRLpoc8+2Sw6s63qQ0JoroRq/Q9ahlhvrUFiIv7BGRuSXCW14DvePDfv/qF+0O+vzmGvg==	9SSPuMkDJuMKDxxUiSnr7xxhpzS3n90sLM/lZXq4W2GxOHG7WShjCNRiNYMdMW0+n2kROGPLvMJmOOL7b/jSj0Qdr0biw0x4DdBts5ZI8MfyP7lWVfgA/FowO8/XbTeqrHn71ys3ns1PR/oi6nij/nbO+9Dy8G9bqmXut0PmmDhwTVFgBIOd5r0DN7Pc636pzKTZ7l3G+SrnDzSGVEf3Mg==	xp+SuG5+6Zynzh59RyIs9MHKl66C5JzBjEFndlDwONYKzohfn/PVxV+ySK90GJtGCwMfp0KOyIWtH0oLyWrOziY6+4PvakYlQ4DuAeyTROkILThUENUOfFp/sUIBWMYJk9lFUpEw33Y90QLAUtz4Z0ysllW6/yF6jD2LchqrtDKgUUpPaw3X6304CMMyIlXBbllmTyyMPROX9+0ai4uYfw==	1
\.


--
-- TOC entry 2670 (class 0 OID 16402)
-- Dependencies: 186
-- Data for Name: accountbackupcode; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY accountbackupcode (walletid, backupset, backupindex, backupcode, used, dateused) FROM stdin;
43dc22055016c54a2ad7599b113fffa52bd90ea199c2fd31e4d11eb2bd536991	1	1	FI3uVleptp343LqJ5X3OxNEEiUxsBXIZbLHu8+5ETEFGTNhiRA79VcnlmyDpPty4	0	2017-06-07 09:24:12.933
43dc22055016c54a2ad7599b113fffa52bd90ea199c2fd31e4d11eb2bd536991	1	2	RvY53iq8gMouUPn/KNJbasDzMlZkXlfqnoUpjdoxTS2q/M47fszVJtICzkHKsebE	0	2017-06-07 09:24:12.941
43dc22055016c54a2ad7599b113fffa52bd90ea199c2fd31e4d11eb2bd536991	1	3	iPzhj26ciahiE5t9tchZp3lz5jTgPp9PiJh0oN+vyMkXBjWDpbLvSvrS+y6h4Yda	0	2017-06-07 09:24:12.942
43dc22055016c54a2ad7599b113fffa52bd90ea199c2fd31e4d11eb2bd536991	1	4	0TolmaXcmDGPlJnF9UHAoBjI6ahJfdKVHJc+2u14ii2CamYf9/r9/Au+qdtxJlAP	0	2017-06-07 09:24:12.943
43dc22055016c54a2ad7599b113fffa52bd90ea199c2fd31e4d11eb2bd536991	1	5	WXtXjy3gtdod/WCRu/TsIs9BOgnAKDT1Ie8kZQS3ZpFcI+Vvmv7OACsm5zM6ZZYN	0	2017-06-07 09:24:12.944
43dc22055016c54a2ad7599b113fffa52bd90ea199c2fd31e4d11eb2bd536991	1	6	hSdy3xNXJKAREM+uhTxobD6zKODi62+Qre2nWBy1oMzdmatCtHkaeQzL5U86jg4Q	0	2017-06-07 09:24:12.945
43dc22055016c54a2ad7599b113fffa52bd90ea199c2fd31e4d11eb2bd536991	1	7	thKAxZvi+j3lwIvP4RT2r0ZfUnpKg+wZ+gg2irOhB/2NKIKInVZVwW0Q1B8o5P7y	0	2017-06-07 09:24:12.946
43dc22055016c54a2ad7599b113fffa52bd90ea199c2fd31e4d11eb2bd536991	1	8	fQq310JGXRGfhX9i3tRCp3yc5oFDKqUlIT7UfN6wGOe06BAUu/pGSU/X556e+N3K	0	2017-06-07 09:24:12.984
43dc22055016c54a2ad7599b113fffa52bd90ea199c2fd31e4d11eb2bd536991	1	9	LhRwfPEMWNpg8Hd6Niqf3ompDOKjK0MxZi0UjCTzOqyocRlXoVkrgHYUJQU9OIEq	0	2017-06-07 09:24:12.985
43dc22055016c54a2ad7599b113fffa52bd90ea199c2fd31e4d11eb2bd536991	1	10	iS4/8K5GDFQyZKL84eDUnEOOUrBvE4/XsjcadAw4+92nA2nmq6UqkQ99KqewfnQh	0	2017-06-07 09:24:12.986
\.


--
-- TOC entry 2671 (class 0 OID 16410)
-- Dependencies: 187
-- Data for Name: accountdevice; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY accountdevice (walletid, devicename, deviceid, devicemodel, devicepin, devicekey, twofactortoken, regtoken, keydate) FROM stdin;
1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	My Android	\N	\N	\N	Sc19HkB9vgYOGfvsmrvk5QkDJTUxUFeYQq3jFpVIdvPjEKRR2GfCS5+pzPuNH2E+fx37Pq0Oh6ecpX2a2/meAgkv4mT4NlGG5Gv66kD3B2m6gN2lVzmnGrRr8ndAdghVOrWvxk0G+IADxGwZLuDQUPHcmdKiRQzXsDVGnj96UbT2aGRgAnfvFV8z6YD+n2+KDBx979qSk2egi5ajn5aYLg==	df49d4d65bd39214b26babf41616d7ee4c01cc6eb3f48a21bc22d4cb9f808910	e39229e213b44518e112aed22d522ce24a4cd4b3bb15d684c17d2e26c81aa93b	2017-06-07 08:31:51.189
3dc8e60592e1fd4d430ac77eb3a0cfff91405e6652051256c87adde0943d66bc	My Android	\N	\N	\N	yWzhjLMD1ej1wNbv6rfqY1hnI7McjFI3lBrHczGOqmS+FjQgj15Tke6wAJzkcEkqp5izWIAfm+8maxppw5iG17AZxTPJgUVrdfP6XO2WjpcphNqy6GxCxijQjp4wLyqWlHDMPN8hOAMtmfQloNWhoEb8usxu7JqkaspLaVoNKhBBGACrEdDcMAMbnvgnrBC8IoOPps8OW/pOsknlnMp9YQ==	5e5539a770c13f4c570ebea1536c44a6559f6cc5a9c323d99d95812b233c5121	2ada82297c8c74790c57b23346bd21d5622748a939290f7ccac07b3fa7e8c2b8	2017-06-07 13:49:40.99
873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	My Android	platform	model	0c1db681996d3adea9b0d86bb893e3ff32f970dba0ce1cc2b80924c57903dbea	yvmND9igDkkI5aC4TvDljxSedF38K7W+xvFamYl93yUNJFgeFtI13NgmGAVahW4L1UeklT1srINGhgiGp/gwdreZlfpDuA46AXhl26obAP8CNAlkbItlKtMPOLDVaT4rDlFX/94VfFb2UI3+sLjB9eCDgmmOQ7zXc0jolUcxKjS/rm9LVo/7uuZEDnGONIuSwsht+nuorkB50kBYnfu90g==	7ed3d8c5b8f5172754f9d1286406af5ec043f5842e951f8ce95350eb0b88ac2f	67043835c840785340df173f0efb2a50052a9c0b36b74b9b8a718ce0b46e34ee	2017-06-07 13:59:50.097
1b70ecebc36f3c185d22fb87f3c192917e5d84151f6072d82fa6564254e30211	My Android	platform	model	0c1db681996d3adea9b0d86bb893e3ff32f970dba0ce1cc2b80924c57903dbea	F0oLXBgCczj/0XInegcE4p79leqgf0jOdQAPoUH54zmq10zgL5Ufkup2dct8HZKWzFoKyAENdjJJCz9woZmwLPClRidZzryStQO1sg3VP1DQPt12lld1nmGM0oDjKsVe2d9+kmANlj5S/5nDkXgb/L9Yljs53R5YQSCPpQDhjvj9AJxYlV6LOgvMRXE5TWk2kLkWpPubTtf192zKpFVVCg==	5f501d9083aedaec72cc6f250c86b03a9c54c5b5ea901fe65db2faffe385a331	2e1cc8071abe03c1eaa5f8946445e4a39c6e9dcb0ee376142bcfe971b211aee2	2017-06-08 08:49:42.385
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	My iPhone	platform	model	0c1db681996d3adea9b0d86bb893e3ff32f970dba0ce1cc2b80924c57903dbea	Yfy1FLyWLBVESYA5WS1a/VrilMm7d2/nVO6+UGvdgOIp9MAiE1jYP9b4/Jy+TZeHILndhCswUPvdWZB3LEgdLCABZ9avL/eXiLjT3+S1k/GIJZKvlaZwPqbGJehbF6DpPPS5QIdp3jCOE4DVn62R+gpc2qFTSKjM1Gamt3wrXT0FKV2bwoTk3LVRfNYj59SxEcUWFUc90ngnTic8dojb3g==	1308ff7ec0b541a2ae5db65dcf4068ded9c5a53dae285dad6b7a75975b02a769	259c37b3a3246b9397caca49bb92baa3c350c0985c4cceb34001816c4aeb91be	2017-06-08 09:11:45.091
\.


--
-- TOC entry 2673 (class 0 OID 16420)
-- Dependencies: 189
-- Data for Name: accountlog; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY accountlog (logid, walletid, logdate, success, logtype) FROM stdin;
1	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	2017-05-28 14:14:20.372	1	Login
2	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	2017-05-29 12:53:24.46	1	Login
3	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	2017-05-29 12:53:46.942	1	Login
4	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	2017-05-29 12:54:14.003	1	Login
5	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	2017-05-29 12:55:33.292	1	Login
6	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	2017-05-29 12:56:21.417	1	Login
7	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	2017-05-29 12:57:04.311	1	Login
8	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	2017-05-29 12:58:20.182	1	Login
9	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	2017-05-29 13:12:31.484	1	Login
10	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	2017-05-29 13:13:41.186	1	Login
11	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	2017-05-29 13:15:07.69	1	Login
12	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	2017-05-29 13:17:45.838	1	Login
13	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	2017-05-29 13:20:57.314	1	Login
14	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	2017-05-29 13:22:39.104	1	Login
15	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	2017-05-31 09:58:43.49	1	Login
16	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	2017-05-31 10:32:43.495	1	Login
17	3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	2017-05-31 11:17:03.942	1	Login
18	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	2017-05-31 11:19:31.035	1	Login
19	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	2017-06-01 10:56:28.125	1	Login
20	3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	2017-06-01 12:43:39.927	1	Login
21	3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	2017-06-01 12:46:01.724	1	Login
22	3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	2017-06-01 12:47:19.784	1	Login
23	3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	2017-06-01 12:48:41.339	1	Login
24	3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	2017-06-01 12:53:47.583	1	Login
25	3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	2017-06-01 12:54:22.321	1	Login
26	3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	2017-06-01 12:54:42.921	1	Login
27	3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	2017-06-01 12:56:34.17	1	Login
28	3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	2017-06-01 12:56:58.134	1	Login
29	3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	2017-06-01 13:16:50.693	1	Login
30	3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	2017-06-01 13:17:09.812	1	Login
31	3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	2017-06-01 13:20:05.291	1	Login
32	3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	2017-06-01 13:21:20.992	1	Login
33	3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	2017-06-01 13:24:15.169	1	Login
34	3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	2017-06-01 13:25:15.488	1	Login
35	3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	2017-06-01 13:26:19.268	1	Login
36	3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	2017-06-01 13:30:58.855	1	Login
37	3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	2017-06-01 13:48:59.981	1	Login
38	3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	2017-06-01 13:58:57.127	1	Login
39	3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	2017-06-01 14:02:16.116	1	Login
40	3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	2017-06-01 14:04:29.16	1	Login
41	3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	2017-06-01 14:11:04.621	1	Login
42	3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	2017-06-01 14:11:54.165	1	Login
43	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	2017-06-01 14:13:27.793	1	Login
44	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	2017-06-01 19:41:02.864	1	Login
45	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	2017-06-06 10:32:23.744	1	Login
46	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	2017-06-06 10:44:58.445	1	Login
47	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	2017-06-07 08:13:17.162	1	Login
48	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	2017-06-07 08:13:39.666	1	Login
49	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	2017-06-07 08:14:55.817	1	Login
50	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	2017-06-07 08:16:22.662	1	Login
51	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	2017-06-07 08:45:32.329	0	Login
52	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	2017-06-07 08:45:34.616	1	Login
53	090386f5401a8e48b63b19d4c8981e230efe71d2d3f28307f98c0424e6d93f9b	2017-06-07 08:51:11.51	0	Login
54	090386f5401a8e48b63b19d4c8981e230efe71d2d3f28307f98c0424e6d93f9b	2017-06-07 08:51:14.729	1	Login
55	43dc22055016c54a2ad7599b113fffa52bd90ea199c2fd31e4d11eb2bd536991	2017-06-07 08:55:02.724	0	Login
56	43dc22055016c54a2ad7599b113fffa52bd90ea199c2fd31e4d11eb2bd536991	2017-06-07 08:55:04.805	1	Login
57	43dc22055016c54a2ad7599b113fffa52bd90ea199c2fd31e4d11eb2bd536991	2017-06-07 09:20:20.284	0	Login
58	43dc22055016c54a2ad7599b113fffa52bd90ea199c2fd31e4d11eb2bd536991	2017-06-07 09:20:22.083	1	Login
59	43dc22055016c54a2ad7599b113fffa52bd90ea199c2fd31e4d11eb2bd536991	2017-06-07 09:20:31.21	1	Login
60	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	2017-06-07 14:00:05.419	1	Login
61	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	2017-06-07 14:28:21.196	1	Login
62	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	2017-06-07 14:28:21.3	1	Login
63	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	2017-06-07 14:37:57.439	1	Login
64	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	2017-06-07 14:37:57.518	1	Login
65	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	2017-06-07 14:46:50.708	1	Login
66	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	2017-06-07 14:47:16.011	1	Login
67	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	2017-06-07 14:47:16.085	1	Login
68	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	2017-06-07 14:47:20.137	1	Login
69	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	2017-06-07 14:48:00.783	1	Login
70	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	2017-06-07 14:48:00.835	1	Login
71	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	2017-06-07 14:48:19.432	1	Login
72	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	2017-06-08 08:30:10.862	1	Login
73	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	2017-06-08 08:30:11.005	1	Login
74	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	2017-06-08 08:30:18.053	1	Login
75	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	2017-06-08 08:31:34.652	1	Login
76	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	2017-06-08 08:31:34.708	1	Login
77	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	2017-06-08 08:31:39.02	1	Login
78	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	2017-06-08 08:33:53.868	1	Login
79	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	2017-06-08 08:33:54.073	1	Login
80	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	2017-06-08 08:34:23.212	1	Login
81	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	2017-06-08 08:41:02.457	1	Login
82	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	2017-06-08 08:41:02.657	1	Login
83	1b70ecebc36f3c185d22fb87f3c192917e5d84151f6072d82fa6564254e30211	2017-06-08 08:50:06.633	1	Login
84	1b70ecebc36f3c185d22fb87f3c192917e5d84151f6072d82fa6564254e30211	2017-06-08 08:51:10.757	1	Login
85	1b70ecebc36f3c185d22fb87f3c192917e5d84151f6072d82fa6564254e30211	2017-06-08 08:51:10.988	1	Login
86	1b70ecebc36f3c185d22fb87f3c192917e5d84151f6072d82fa6564254e30211	2017-06-08 08:51:14.982	1	Login
87	1b70ecebc36f3c185d22fb87f3c192917e5d84151f6072d82fa6564254e30211	2017-06-08 08:59:21.901	1	Login
88	1b70ecebc36f3c185d22fb87f3c192917e5d84151f6072d82fa6564254e30211	2017-06-08 08:59:22.307	1	Login
89	1b70ecebc36f3c185d22fb87f3c192917e5d84151f6072d82fa6564254e30211	2017-06-08 08:59:27.304	1	Login
90	7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	2017-06-08 09:14:40.518	0	Login
91	7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	2017-06-08 09:14:45.691	0	Login
92	7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	2017-06-08 09:15:08.465	1	Login
93	7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	2017-06-08 09:15:11.714	1	Login
94	7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	2017-06-12 07:13:44.524	1	Login
95	7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	2017-06-12 08:00:47.95	1	Login
96	7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	2017-06-12 08:01:25.606	1	Login
97	7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	2017-06-12 14:31:45.739	1	Login
98	21fb3f5fb6a0c9a5e6404719057b366699f0be59ba1e37f7d936ef6a2ce7926d	2017-06-12 15:19:59.717	1	Login
99	1be888d0f72e1dd4cf9830224618251944a749be1760835da9da7c22bae70c11	2017-06-12 15:33:25.304	1	Login
100	1be888d0f72e1dd4cf9830224618251944a749be1760835da9da7c22bae70c11	2017-06-13 05:26:59.751	1	Login
101	1b40f08fd133ac1c9e745de021bc15f880b58aeb13b3ebc908a42cd4141767e6	2017-06-13 06:15:52.291	1	Login
102	1b40f08fd133ac1c9e745de021bc15f880b58aeb13b3ebc908a42cd4141767e6	2017-06-13 06:18:40.14	1	Login
103	13f9f3b2c5e85e2e4c204d5895902e1a32fcf391daf4d8712b7ac6ec2de41d7a	2017-06-13 08:01:47.587	1	Login
\.


--
-- TOC entry 2709 (class 0 OID 0)
-- Dependencies: 188
-- Name: accountlog_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('accountlog_seq', 103, true);


--
-- TOC entry 2674 (class 0 OID 16426)
-- Dependencies: 190
-- Data for Name: accountsecpub; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY accountsecpub (walletid, secretpub, createdate, updatedate) FROM stdin;
3dc8e60592e1fd4d430ac77eb3a0cfff91405e6652051256c87adde0943d66bc	QZfKO6VlpIdHmgYtjNmidq80gqZwJhgZQAGAc34LLoEahCrrEqqsCrZty1h59RBLZkPQ/J70loNiS25YjfqcyVCrAMQGGGJyIIR6iPVIw2jbGHxtZDNGngv3RfWGfyLdX2PqGqvQwVCdwZcJ9J7/BGXTjQS2lr0OSSw2G0hNCTDy3j6m8iheKcLXCk8KXbhMMKW8A6FxA3Fez8c0UWiN9yWB55EJZmXrLIUt/F6UbY5I6CSB9dGcOeyk7GrwKtYVnO/3XhcwNwrQqbdHTBDDbWM6G+byfMIfqo/6DHNCpZCwqFhgAtz9hMwKySk8DlSAXnFfFDT30KBYiMv+qBbeOvJKz4PoCk72gMrHlWsBrfl35iMW34wlC8pDKM98MG0W	2017-06-07 13:49:37.093	2017-06-07 13:49:37.093
873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	\N	2017-06-07 13:59:46.546	2017-06-07 14:10:53.304
1b70ecebc36f3c185d22fb87f3c192917e5d84151f6072d82fa6564254e30211	\N	2017-06-08 08:49:36.386	2017-06-08 08:50:16.884
\.


--
-- TOC entry 2690 (class 0 OID 16572)
-- Dependencies: 206
-- Data for Name: accountsettings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY accountsettings (walletid, inactivity, minersfee, autoemailbackup, email, emailverified, phone, phoneverified, language, localcurrency, coinunit, emailnotification, phonenotification, passwordhint, twofactor, twofactortype, dailytransactionlimit, singletransactionlimit, nooftransactionsperday, nooftransactionsperhour) FROM stdin;
0af18ebca0a49b3267e20cfbb7bcc685d59d3be0d16817bd637777933c8be6be	10	10000	\N	shibuyashadows+8564@gmail.com	0	\N	\N	EN	USD	BTC	\N	\N	\N	\N	\N	100000000	50000000	10	4
0d91c8a668791d7605d2067c307926bd56a9d07c9f492632d499c2b9ba5ad853	10	10000	\N	shibuyashadows+019@gmail.com	0	\N	\N	EN	USD	BTC	\N	\N	\N	\N	\N	100000000	50000000	10	4
3039ea9cf03f90aead7b772a8fd327ae4188741759575d2c9eef0cb8df702912	10	10000	\N	shibuyashadows+823@gmail.com	0	\N	\N	EN	USD	BTC	\N	\N	\N	\N	\N	100000000	50000000	10	4
1be888d0f72e1dd4cf9830224618251944a749be1760835da9da7c22bae70c11	10	10000	\N	shibuyashadows+iouuiui@gmail.com	1	\N	\N	EN	USD	BTC	\N	\N	\N	1	GOOG	100000000	50000000	10	4
8dc3ff0e9df2a99eb045be1da0fa0bef319c3802a4f68a6eaca3e70c36bdd5b1	10	10000	\N	shibuyashadows+453@gmail.com	0	\N	\N	EN	USD	BTC	\N	\N	\N	1	GOOG	100000000	50000000	10	4
c10bd4f03324f9139fd748f09241b8444266c789c946e023c606c595a30f3819	10	10000	\N	shibuyashadows+457@gmail.com	0	\N	\N	EN	USD	BTC	\N	\N	\N	\N	\N	100000000	50000000	10	4
873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	10	10000	\N	shibuyashadows+poop@gmail.com	1	\N	\N	EN	USD	BTC	\N	\N	\N	\N	\N	100000000	50000000	10	4
03dc241270d18341948e0b57b14a74f7809206839a1bde2b6936d5ca7cbceadc	10	10000	\N	shibuyashadows+902@gmail.com	0	\N	\N	EN	USD	BTC	\N	\N	\N	1	GOOG	100000000	50000000	10	4
3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	10	10000	\N	shibuyashadows+736@gmail.com	1	\N	\N	EN	USD	BTC	\N	\N	\N	1	GOOG	100000000	50000000	10	4
1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	10	10000	0	shibuyashadows+b56@gmail.com	1	\N	0	EN	USD	BTC	0	0	\N	1	GOOG	100000000	50000000	10	4
6e58e78302664bfa2bab1a6ea1516c6ff3c8576db2bccbd067efe4071bfe9358	10	10000	\N	shibuyashadows+943@gmail.com	0	\N	\N	EN	USD	BTC	\N	\N	\N	1	GOOG	100000000	50000000	10	4
d11210844e7b24c78de54b254b008d33b82e06303bdd2ac6449717f4a8bed844	10	10000	\N	shibuyashadows+946@gmail.com	0	\N	\N	EN	USD	BTC	\N	\N	\N	1	GOOG	100000000	50000000	10	4
ad7025c7040d1bf11df14afa54bac054c8fa37362d61f6dbee50605aa2ea801d	10	10000	\N	shibuyashadows+897f@gmail.com	1	\N	\N	EN	USD	BTC	\N	\N	\N	1	GOOG	100000000	50000000	10	4
4298111cb827f99d8ed41047ef20df4cccb5affde2a20140b028ae112d8fd1d4	10	10000	\N	shibuyashadows+949@gmail.com	0	\N	\N	EN	USD	BTC	\N	\N	\N	1	GOOG	100000000	50000000	10	4
090386f5401a8e48b63b19d4c8981e230efe71d2d3f28307f98c0424e6d93f9b	10	10000	\N	shibuyashadows+908@gmail.com	1	\N	\N	EN	USD	BTC	\N	\N	\N	1	GOOG	100000000	50000000	10	4
ea507dd2783bb201fe7ed5d7462328ad5d7d1e370c7a731dbe43434b2ef5beeb	10	10000	\N	shibuyashadows+951@gmail.com	0	\N	\N	EN	USD	BTC	\N	\N	\N	1	GOOG	100000000	50000000	10	4
1b70ecebc36f3c185d22fb87f3c192917e5d84151f6072d82fa6564254e30211	10	10000	\N	shibuyashadows+bentest@gmail.com	1	\N	\N	EN	USD	BTC	\N	\N	\N	1	GOOG	100000000	50000000	10	4
f952b7ccf52fbebb04859d482474ef46fb37d4f5e63f546f563c5811828096bf	10	10000	\N	shibuyashadows+905@gmail.com	1	\N	\N	EN	USD	BTC	\N	\N	\N	1	GOOG	100000000	50000000	10	4
2c9fcb17f3e35a5d2c17ac695b7d6b331f6b2220693ee524b8b202ba0ace358e	10	10000	\N	shibuyashadows+9yhy@gmail.com	1	\N	\N	EN	USD	BTC	\N	\N	\N	1	GOOG	100000000	50000000	10	4
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	10	10000	\N	shibuyashadows+pairback@gmail.com	1	\N	\N	EN	USD	BTC	\N	\N	\N	1	GOOG	100000000	50000000	10	4
13f9f3b2c5e85e2e4c204d5895902e1a32fcf391daf4d8712b7ac6ec2de41d7a	10	10000	\N	shibuyashadows+142@gmail.com	1	\N	\N	EN	USD	BTC	\N	\N	\N	1	GOOG	100000000	50000000	10	4
9627105a92bc0de742b59643c811781ee9fc1c10d8b7c7dbdbece3fdf55ebd17	10	10000	\N	shibuyashadows+785t@gmail.com	1	\N	\N	EN	USD	BTC	\N	\N	\N	1	GOOG	100000000	50000000	10	4
1b40f08fd133ac1c9e745de021bc15f880b58aeb13b3ebc908a42cd4141767e6	10	10000	\N	shibuyashadows+8yht5@gmail.com	1	\N	\N	EN	USD	BTC	\N	\N	\N	1	GOOG	100000000	50000000	10	4
43dc22055016c54a2ad7599b113fffa52bd90ea199c2fd31e4d11eb2bd536991	10	10000	\N	shibuyashadows+913@gmail.com	1	\N	\N	EN	USD	BTC	\N	\N	\N	1	GOOG	100000000	50000000	10	4
5c6c611876ddfd3f128a4bc79219ce75add68653a4dd5db61c2b536d082c6103	10	10000	\N	\N	\N	\N	\N	EN	USD	BTC	\N	\N	\N	\N	\N	100000000	50000000	10	4
3dc8e60592e1fd4d430ac77eb3a0cfff91405e6652051256c87adde0943d66bc	10	10000	\N		0	\N	\N	EN	USD	BTC	\N	\N	\N	\N	\N	100000000	50000000	10	4
21fb3f5fb6a0c9a5e6404719057b366699f0be59ba1e37f7d936ef6a2ce7926d	10	10000	\N	shibuyashadows+uyus@gmail.com	1	\N	\N	EN	USD	BTC	\N	\N	\N	1	GOOG	100000000	50000000	10	4
6b3a29cfe7ac1554621493d4971db7abc2f75e3c859d2715ec362058a9c9c3ff	10	10000	\N	shibuyashadows+89dt@gmail.com	0	\N	\N	EN	USD	BTC	\N	\N	\N	\N	\N	100000000	50000000	10	4
8361b4d1cb16d9ba6b4f6a430c33009b37d23610f4023ba450ee0240c6d55bbe	10	10000	\N	shibuyashadows+90gy@gmail.com	1	\N	\N	EN	USD	BTC	\N	\N	\N	1	GOOG	100000000	50000000	10	4
\.


--
-- TOC entry 2675 (class 0 OID 16442)
-- Dependencies: 191
-- Data for Name: accounttransactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY accounttransactions (walletid, transactionid, transdatetime, totalamount, sendtoaddress, status, blocknumber) FROM stdin;
\.


--
-- TOC entry 2692 (class 0 OID 16666)
-- Dependencies: 208
-- Data for Name: block; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY block (blocknumber, blockhash, prevhash, "timestamp") FROM stdin;
\.


--
-- TOC entry 2691 (class 0 OID 16582)
-- Dependencies: 207
-- Data for Name: emailtoken; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY emailtoken (emailvalidationtoken, walletid, emailaddress, expirydate, isused, tokentype) FROM stdin;
51d5036e6a51dbb0376af94e07a81176688dbefca9e4ff8b24c835b754015acb	0af18ebca0a49b3267e20cfbb7bcc685d59d3be0d16817bd637777933c8be6be	shibuyashadows+8564@gmail.com	2017-05-27 09:02:08.495	0	1
2face65b32a404023746c1f8bb95f53f39f6a2ed6424b0e12bc35539bfe4c28b	0d91c8a668791d7605d2067c307926bd56a9d07c9f492632d499c2b9ba5ad853	shibuyashadows+019@gmail.com	2017-05-27 09:32:52.715	0	1
02d383c7ecbaf7a373e778f90594b57e1004c77050b82d1028f15f3375a106be	3039ea9cf03f90aead7b772a8fd327ae4188741759575d2c9eef0cb8df702912	shibuyashadows+823@gmail.com	2017-05-27 09:35:16.557	0	1
c73c51881d2e2e7f22abd9c48cb122cac27ee967c579145b54399fb1e8fed4d8	8dc3ff0e9df2a99eb045be1da0fa0bef319c3802a4f68a6eaca3e70c36bdd5b1	shibuyashadows+453@gmail.com	2017-05-27 09:37:43.604	0	1
8c75a3fc8b2560a333962782ed3c27bb6c51e1f057a8b70f2595587e5b3f4760	c10bd4f03324f9139fd748f09241b8444266c789c946e023c606c595a30f3819	shibuyashadows+457@gmail.com	2017-05-27 10:01:46.185	0	1
6b964ce74d0ef30c3a5c7f421c3df8d8144b4400a9d974a3307ad4b591a807d5	03dc241270d18341948e0b57b14a74f7809206839a1bde2b6936d5ca7cbceadc	shibuyashadows+902@gmail.com	2017-05-27 10:03:08.797	0	1
c4e3ce90f043e265852fc7836cc9300671584bf1cb77e67af0ccb2182c8c2fc4	6e58e78302664bfa2bab1a6ea1516c6ff3c8576db2bccbd067efe4071bfe9358	shibuyashadows+943@gmail.com	2017-05-27 10:29:04.403	0	1
c4fcc7b8349db3529f697564ebf92b82d67266daeddbc8d3c85dffd2ccf36f14	d11210844e7b24c78de54b254b008d33b82e06303bdd2ac6449717f4a8bed844	shibuyashadows+946@gmail.com	2017-05-27 10:37:22.842	0	1
73b94c150225768a5dfbfd74a8aaf10545e76fb433d0db112d20094682e5d901	4298111cb827f99d8ed41047ef20df4cccb5affde2a20140b028ae112d8fd1d4	shibuyashadows+949@gmail.com	2017-05-27 10:40:37.408	0	1
7c8e74bc057ef24626d8d63cc38c3e486d86f13d08134cff6976d2ecaee6ac7f	ea507dd2783bb201fe7ed5d7462328ad5d7d1e370c7a731dbe43434b2ef5beeb	shibuyashadows+951@gmail.com	2017-05-27 10:42:32.41	0	1
e07b287830869c9305c91c8995cd10022b5fdc4ba026fa8428d0db5c0d524d24	f952b7ccf52fbebb04859d482474ef46fb37d4f5e63f546f563c5811828096bf	shibuyashadows+905@gmail.com	2017-05-27 10:44:02.874	0	1
32a48696e8a30d998a91bdd6e811c766628258eecc9d138c7ab3f6b1a7e6cb18	f952b7ccf52fbebb04859d482474ef46fb37d4f5e63f546f563c5811828096bf	shibuyashadows+905@gmail.com	2017-05-29 13:30:30.932	1	1
23d239e3da957a072ea75c3eb04e4b13409cfef88a68290d7ae5288c1c302bd3	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	shibuyashadows+b56@gmail.com	2017-05-29 13:44:13.802	0	1
ff4502ebba7fc3692e75e68e8a542cd20352755b1762b19c04c8346c0ac067b7	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	shibuyashadows+b56@gmail.com	2017-05-29 13:45:28.952	1	1
87d77cdf9d4452e43b0c35c2771ae8017aad76937a89b287ad8ad7f96f91cef9	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a		2018-05-28 14:25:06.474	0	3
316dc94e391f0030c88a5023262340b6923897009fa440f5ff4107f852dc0399	3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	shibuyashadows+736@gmail.com	2017-06-01 10:56:33.88	0	1
c91279a44a6cd130c0dd6e128382b59bbe06df68ab86f46a81b9bebcfff1975f	3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	shibuyashadows+736@gmail.com	2017-06-01 10:57:27.914	1	1
ea2e6b9a71c6313c8b14a63a08d4f4486847197740136215b2aa91eca6eed300	3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c		2018-05-31 11:17:22.815	0	3
df49d4d65bd39214b26babf41616d7ee4c01cc6eb3f48a21bc22d4cb9f808910	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a		2037-06-07 08:31:51.15	0	3
d3d19be78c5bf1d9d7f94d222a1139132e424ca66f43fd889b45a629837c278d	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a		2018-06-07 08:45:42.746	0	3
d8e298c4db853e7c2128c72bac7fdadfdd618eba29c3f8770b434e2da222bc7e	090386f5401a8e48b63b19d4c8981e230efe71d2d3f28307f98c0424e6d93f9b	shibuyashadows+908@gmail.com	2017-06-08 08:46:52.67	0	1
e6502f5787f1c1c6d3c15e8a4010905beb5d3ab9b3b60627a8e4d0c0b8e60933	090386f5401a8e48b63b19d4c8981e230efe71d2d3f28307f98c0424e6d93f9b	shibuyashadows+908@gmail.com	2017-06-08 08:48:32.966	1	1
0131c716a8db3182fcb075eb01534c093da2cdabe6e08c0c3277d63eb713fd55	43dc22055016c54a2ad7599b113fffa52bd90ea199c2fd31e4d11eb2bd536991	shibuyashadows+913@gmail.com	2017-06-08 08:53:14.958	0	1
5407e9972bb70d36989a6f90abe8afca37a7951a119f8f6d334a75c07788a7c8	43dc22055016c54a2ad7599b113fffa52bd90ea199c2fd31e4d11eb2bd536991	shibuyashadows+913@gmail.com	2017-06-08 08:53:40.612	1	1
64caf5c10a8a08884511da70672638a9abd05c8f6bac71edc6b3726b7d392df1	43dc22055016c54a2ad7599b113fffa52bd90ea199c2fd31e4d11eb2bd536991		2018-06-07 08:55:13.84	0	3
5e5539a770c13f4c570ebea1536c44a6559f6cc5a9c323d99d95812b233c5121	3dc8e60592e1fd4d430ac77eb3a0cfff91405e6652051256c87adde0943d66bc		2037-06-07 13:49:40.887	0	3
7ed3d8c5b8f5172754f9d1286406af5ec043f5842e951f8ce95350eb0b88ac2f	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f		2037-06-07 13:59:50.045	0	3
e284d2a9fe9669d67405e664f4e8ef38adfe1b39bf8db4b7c059889ec9c212d3	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f		2017-06-08 14:11:41.755	0	1
dbf2874a6bd40acfaa50f924662d22832c2cf65276ca79cbb79965069cbc8f3b	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f		2017-06-08 14:15:31.11	0	1
b2b703745f7a1300bcb65dc35d99aacac02d50d2c9d8d76e638e2ad841d83537	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f		2017-06-08 14:20:26.065	0	1
d8ca0ec28574532d221433cb99a44a35de2ad7fda85098f92093139b5eb6ef79	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f		2017-06-08 14:20:26.506	0	1
75296e1ee996532392d0beb4926939704e254fb08acab17f91ba287b265b093f	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f		2017-06-08 14:20:27.732	0	1
c084c81f674a168b3b3bd75072b775ba80c37f6e232015780a870e024c87cf9a	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f		2017-06-08 14:20:32.406	0	1
c113d051d1cb124bf9315efd1c7e92da8f0f0eecad4919053f455ddc8ca022c4	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	shibuyashadows+poop@gmail.com	2017-06-08 14:22:44.83	1	1
8009ee2b483aa37fa7bccfb9c538c55be3ebb5882e9b579b3067bff09981a487	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f		2017-06-07 14:56:49.384	0	6
30b77d12194104bb1038a9f21cf2e4dd90c211b49f61d3b6ce534f8d8276934c	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f		2017-06-07 14:57:19.41	0	6
25d6209b73e5401faee6a8fefe4855954a4f691fe101c2f2387db842177a907c	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f		2017-06-07 14:58:18.56	0	6
378074dd499bbcac04e367db1e6ed7e96e398d20b62e18b07bbaa15df20d5f76	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f		2017-06-08 08:40:17.761	0	6
3b6663b15b9a05135c1a87a899bad5b221a9a233fe0e406c6501e501c2c4871f	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f		2017-06-08 08:41:38.652	0	6
c7a9a9bc9e9eddf470351c876c008a719df2c6892cfb61345e67a818d4dfdd2e	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f		2017-06-08 08:44:22.155	0	6
2abc54b9615d836b6b4baeca8c0371da8fb6ba2ba1ca001d9fc3562e0fd90155	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f		2017-06-08 08:52:25.157	0	6
e1c95184d7c535d3a1678fb90437aace7815480c324e644b850634affd4f1b5c	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f		2017-06-08 08:58:53.75	0	6
5f501d9083aedaec72cc6f250c86b03a9c54c5b5ea901fe65db2faffe385a331	1b70ecebc36f3c185d22fb87f3c192917e5d84151f6072d82fa6564254e30211		2037-06-08 08:49:42.36	0	3
f778947770dbc2a15e2da266eb54bbe60404b33291dc455cec567423f40a1bb0	1b70ecebc36f3c185d22fb87f3c192917e5d84151f6072d82fa6564254e30211	shibuyashadows+bentest@gmail.com	2017-06-09 08:50:33.189	1	1
d58c02902f1d4455795f1837a4e87a0d54e5a0612ed327cc0db684d19d4c1291	1b70ecebc36f3c185d22fb87f3c192917e5d84151f6072d82fa6564254e30211		2017-06-08 09:01:13.908	0	6
51501de629b569b82650c1c9b2e109650a45b40a53b74efc25a33391c6f95de3	1b70ecebc36f3c185d22fb87f3c192917e5d84151f6072d82fa6564254e30211		2017-06-08 09:09:25.327	0	6
b944455744c8d0e8fcdccfd9c65096aedd3fb9d6809ba7ee4c2d7ffcc6bd5c22	7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	shibuyashadows+pairback@gmail.com	2017-06-09 09:10:28.074	0	1
23fccc14a16132abaf527109f87ec98ce3f990cf95eea2c64404acc980e66a97	7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	shibuyashadows+pairback@gmail.com	2017-06-09 09:11:10.949	1	1
1308ff7ec0b541a2ae5db65dcf4068ded9c5a53dae285dad6b7a75975b02a769	7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519		2037-06-08 09:11:45.068	0	3
1f573fe67b0c2c4832ca0afed41b0d4d23aac5fdbb0f4dba1abb1ac3a46b8630	7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519		2018-06-12 07:14:05.47	0	3
f4a7abf414ddc92449e955a1cce3051a3af2a9e3a06db6daa9ba5e21040cb6f5	21fb3f5fb6a0c9a5e6404719057b366699f0be59ba1e37f7d936ef6a2ce7926d	shibuyashadows+uyus@gmail.com	2017-06-13 14:39:39.7	0	1
9ac4297b61969085a740058b974572836d55b9f41757cd441f6efb1946794e33	21fb3f5fb6a0c9a5e6404719057b366699f0be59ba1e37f7d936ef6a2ce7926d	shibuyashadows+uyus@gmail.com	2017-06-13 14:40:30.145	1	1
9c9357f1dac04d48b3a57a9f5b97d8510ce9e50c3d8a4fa09eeb412016f5b22d	1be888d0f72e1dd4cf9830224618251944a749be1760835da9da7c22bae70c11	shibuyashadows+iouuiui@gmail.com	2017-06-13 15:21:14.618	0	1
ace8021119f0699d6c221981ae6566af30e3177a62ebfa338e9d09c70a7759f1	1be888d0f72e1dd4cf9830224618251944a749be1760835da9da7c22bae70c11	shibuyashadows+iouuiui@gmail.com	2017-06-13 15:21:49.217	1	1
51bc6c94e89fa0807729a806f080955b368ec1e61085bbe74764a524978aa4ae	1be888d0f72e1dd4cf9830224618251944a749be1760835da9da7c22bae70c11		2018-06-12 15:33:43.155	0	3
8e4272734c8e75681ca0077d3bf9922db22cb75a255b3b553136f2b130f364ae	2c9fcb17f3e35a5d2c17ac695b7d6b331f6b2220693ee524b8b202ba0ace358e	shibuyashadows+9yhy@gmail.com	2017-06-14 05:40:54.304	0	1
22463a30ff6e6a328df223ef4eeafe3125599e6c81efc74971ac8b5e02b720bc	2c9fcb17f3e35a5d2c17ac695b7d6b331f6b2220693ee524b8b202ba0ace358e	shibuyashadows+9yhy@gmail.com	2017-06-14 05:42:56.184	1	1
042d1e87b0f71974a76344e2d3205298b6a7f458c409128afd60b0f939644926	1b40f08fd133ac1c9e745de021bc15f880b58aeb13b3ebc908a42cd4141767e6	shibuyashadows+8yht5@gmail.com	2017-06-14 05:54:01.546	0	1
9559d60858ecafeb090d1d95523c8941e0b77e0eccf8849bee9bbbc43c425c3b	1b40f08fd133ac1c9e745de021bc15f880b58aeb13b3ebc908a42cd4141767e6	shibuyashadows+8yht5@gmail.com	2017-06-14 05:54:48.219	1	1
643d8244cbcc68f23af73cd48840eeab2228d22406acdacf86f0f83f8b677b19	6b3a29cfe7ac1554621493d4971db7abc2f75e3c859d2715ec362058a9c9c3ff	shibuyashadows+89dt@gmail.com	2017-06-14 06:17:02.616	0	1
572301f15503488cac3046daa4775c96cfd3ab94d594d3aec0d5d86e71e3b527	ad7025c7040d1bf11df14afa54bac054c8fa37362d61f6dbee50605aa2ea801d	shibuyashadows+897f@gmail.com	2017-06-14 06:19:25.089	0	1
a377c13cb00729b838d4275495631ce4ce2a7a4da565004a07163cb286b738ff	ad7025c7040d1bf11df14afa54bac054c8fa37362d61f6dbee50605aa2ea801d	shibuyashadows+897f@gmail.com	2017-06-14 06:19:55.867	1	1
b7f176db70c63a37edd34c5fbab27c76138053a5f61e48e4fdbd4c2e2ea46c6f	9627105a92bc0de742b59643c811781ee9fc1c10d8b7c7dbdbece3fdf55ebd17	shibuyashadows+785t@gmail.com	2017-06-14 06:31:07.876	0	1
eff05db12778421c055ebeb043d0d0ce613e64c20effabbdbff15f1d4e85e297	9627105a92bc0de742b59643c811781ee9fc1c10d8b7c7dbdbece3fdf55ebd17	shibuyashadows+785t@gmail.com	2017-06-14 06:31:54.301	1	1
92adfcb0e061563e00257d2faa529e85560f4228cd34f9b08d2f2ec23f9a8e3f	8361b4d1cb16d9ba6b4f6a430c33009b37d23610f4023ba450ee0240c6d55bbe	shibuyashadows+90gy@gmail.com	2017-06-14 06:39:58.668	0	1
3db93297445fee167ef475ddfee66c07d68db1e8c05d4ad99a3da29a05721533	8361b4d1cb16d9ba6b4f6a430c33009b37d23610f4023ba450ee0240c6d55bbe	shibuyashadows+90gy@gmail.com	2017-06-14 06:40:41.542	1	1
94b1fa84c8356cdab063388c7a00a2a2af0b5d6e124cd2d2201bd2d227ba8681	13f9f3b2c5e85e2e4c204d5895902e1a32fcf391daf4d8712b7ac6ec2de41d7a	shibuyashadows+142@gmail.com	2017-06-14 07:48:33.945	0	1
34a9245305f1a0bbe42b65081b5dcc2c203c19086db63cbc36f1a03d278eebde	13f9f3b2c5e85e2e4c204d5895902e1a32fcf391daf4d8712b7ac6ec2de41d7a	shibuyashadows+142@gmail.com	2017-06-14 07:49:26.809	1	1
7d66a70842c06cb086fb6174534ba8d717c871fc7b0a83755410cb619a1d4c0f	13f9f3b2c5e85e2e4c204d5895902e1a32fcf391daf4d8712b7ac6ec2de41d7a		2018-06-13 08:01:55.511	0	3
\.


--
-- TOC entry 2693 (class 0 OID 16671)
-- Dependencies: 209
-- Data for Name: fees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY fees (feeid, low, med, high) FROM stdin;
\.


--
-- TOC entry 2694 (class 0 OID 16676)
-- Dependencies: 210
-- Data for Name: lastread; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY lastread (id, transactionid, blockfile, blockindex, bytesread, runningblockindex, lastupddate) FROM stdin;
\.


--
-- TOC entry 2676 (class 0 OID 16452)
-- Dependencies: 192
-- Data for Name: nodekeycache; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY nodekeycache (walletid, nodelevel, ninkiderivedpublickey, ninkiderivedprivatekey) FROM stdin;
5f71576f22d08696facede03a7f67f982a6ce75ec7d8b2dc9de86e8d75db10dc	m/0/0	B2WvpSm7THVaRIsOlkVpVunTJ5ifA7rRdchiWluJIZ9YZSUb011rupHHTSkiSbjhMzTDTSKpY2kFGoKH2FX7dknr4G6f5S9MXmSCtW6ncwC5Hs7Tb7opz+i6Z+NdDYMS8YSD4EruWu95XmjW5QX3vmXTJgdJ11K4xUIa8i/noK4wvDD8e5voBpG6CtKhH0BMgc2QDJQzNLtaZCKQ00NtT9j810XDyzdb70eB9gzA88R38ct4EgcBXpdO32AprLUWvj6as8eml81lEczd7uwRhgZHOeFZL772FUyN2G2GmSExaHIIAdUVtw9jkz8zNDD1	Az/ORfj9A7Iur61sblPdlf3NzV+TpYQwdWQeqbCivBwewvXID8C0ihKkGfgejhDe5cPqeZmdvNXabLviiMTcvUKILGjgYlWPQQn+Bsko7comlzXBG6/1iMaPtt7MOundUjiJFz0ydsjhGKesERcGfV0L9OiVMWYIiYiNQ7fJWKCFFWxbXSyzromCQ7MCTp5K5J7wcmTy6LxBL4n+U++GcY7QODObsXzqeb5cJzW72NTbWSdG2UwOnexBMaDgXzp+6MhxuHNUEV5A0KvB2qaQ552BZtT4I22VpeOpHJrXSeQh+TnpBZWvPhsq8VLrGY+L
5f71576f22d08696facede03a7f67f982a6ce75ec7d8b2dc9de86e8d75db10dc	m/0/1	aQtJqClC9upKfm6oamxHJrRua4svSYcj6mZz8bxFCv3S4+1GWlTUA2LMtmVIdzRZeh9Sxi1QrE0FFsecEovFp2mH1AkgXCRZJ4qnXdPlgUNqY4oqPd5MsSnJZzp3pJLHfeO0G8r3rgcW5+vgcgz9gDt+7LqA49o1wDEvlJTaTfEXeJvvufTFEsdnggKmzJ0/VQY59dt3ETpbm9q2IA9igU4KgW3W6kOfHWf+OqpZW0+MG5/mPBOXfA2D+CY7ftPuu8B4Ly1QlpN/yQQdldLtV82Zwncz7jheiyE5Evz33jND62tpftILOaMeEHH5D2sd	4Zn/KpePd7PmI/bJwRMOlFmlV/OgP4Z6liSxefVsaxRq/9TuGydnUuwtuKZrTEp/izeC078BBfo/HGht7zscHikwToTD8OWzcMMIULiX4Ah8UUncWk18iPUfEkpMOOSj9P+FVfz5vjmpRq9ziqx6K0ORFVk+QS2KBy9/uVL/Cxklh+O+bKdLWik0oHzfOv4z0Qzg/Z62HkaxCSXSjdhw9aLiawVxpsth7FN2awsG/zyuxRVl8KW8yhSmDv2x7kfkbFN/3nuGcU7juTaoxWfE8Urvz58fjhsQBJWMd3junTSGmn7InCafpgwIKNMUesPh
e57f8cb6644cb7321185c1d3b579e18201f50d2fb25237c56f7f7dd5f07d3f9f	m/0/0	PowsavmCqt+S8xnKa/7DIRieXaKddCjy3hG+GhN0iclOxVSHHxQh+uyEPoofRurRc1IbqgnqaOlgyqTQc/DgKjSFfKcP8pAtPVkyCr3njOxjT0av2eFoyhL3ug0gjAMfADDZt1X+xEPMJ/n7HvS++BmszQJyNJMNrU+YIGSqgL5/xjqNAPtFk7uUXyuxTopkUQ1iIIGgImcko5lOR86u75WvNq4wSEQPF2UnCnzK4LYk4FfoDA3W6X0gAVXAsG4CI1InY4PXjYXqVDpWEf4rsu/iRYMRMPYDboH10qBc6hRDnWHEJ5rA0bU3sR8i0c5t	u3dGNUgOY7WonDZPbxbtawKYlLgJYEsrilhlmvFxASAfH7jMUDv6YXQ4lFrk90+/MaUPghDosNL4vIFoJfpLAVh+FTSX6tZ/Xc8oXzKtAAuh3qWsPiNwBL+xdhqN/5ekikw1MUiL8UYfqkxGdjaGFA8+SARqArTRHGVko0l1rDS2E2O48y+FGeLv6BmFa9h2nN4eEC13+DfCh4xt2aVkn3WPmsbIi+u7kC2RKx2BDKJp/9mcQ6oN01IvjH5JaAcqjE3rD56lBXss2mApHH7bm0ZGe1KZe1UPH4mh7Vz6gU8zo9UfYwHtH0WXtTsuMUBK
e57f8cb6644cb7321185c1d3b579e18201f50d2fb25237c56f7f7dd5f07d3f9f	m/0/1	HTG0EmEokVG954PruFtd1ggvXFtsORuHLO1GHvAZw93wRrTtIhgL7lNWn2CJe5sjKJ5kg9YL6Mv/SV2IX9thsD6fYFttEZ/cPpteJ6HbSSORXEUbAurGq6yORgScXIqr7aTEXuBNxWg9/NuRPOtC+qdBlMUIyurArlxif7GuSq/Q0ar8lTG5lpbtEwyDsY3BGrBelymO2Gas4DNJvECummX5VPHppl949TA+H8wo41o93qCqPVOfRvD/sD/tEcWLdRTONsj76rCaNfVhYxtnw6DbspqIP8JmdVH2dmtitlHwKScoaIm6yj3Zps+A6h0z	j22cijL8xqWaPcS+9YECz2Ba+YDz1TiFShWm+8kkjEyutSI27QiR3sIOiXcORQi5LOhR6j7CGDFYiBqjU8PdaxvtoR6W36T0uRLpLPgxBydAd6xUZtr+EZ/W37j8gJK/q8j81Q4gx/VRQICEE+Z3krc+2PDiQRrCCXa/C6h8An55y+9Q5bg3QQ9ctw4AAeJXemRdKxkFcawjumVAPekp5Zhvnv4RcnPvEYoiJA14nOvSCYCaDtPt1AaCuFwECkCTqQMMRuq9TpGY3rqnmSdeIQkh0JyW77KPSdGcWO01EIbcrI8XjdqeV/0U6x7YiYVe
460b6252e93001d1e80ccfae2312ef92ba225e24ceb4dcabea9e7783a72a8b6c	m/0/0	iwS3wFXj2WZAzYOZ11iGVWylNrVrpVK7N4eF7VJ5PyvQ85y57d00lcanXpTjQqhRQHRSMg5VYMldRLeVxnq/N3kzQB0CkeEdpS/f+7UWB1AsbgRBdA6migt4NQa/IERPnzoRY1zD1HTsFXvybYJ+FTDKIJ4EZtFGV4ZRcD38/H+NI5NpmKKVPQp0/pX+0ybIrJXK8of1fV1Ou9kuRGB7wm3AzOmOOCkJ+ql9J3sc/1sk+UC82I4B650H6gKDyG5DBSDY2tcbtrmope7yDeXuLxNFrY/qwK/ZAgZEJmUUwlP+XaPpMVZGzdXq03CKVJW/	RLNNmIFKdQaaPl9LSXGSFRt6mzSUWYsdueXk37A030lUMiofhIs8o/PjebhDdv+BOM9MzThcntaN2bUWqYcViOzRYeLC9VU4g27XS8JO07F2uizlen6xPusDPDGHA6PfuDQ5orggdkUwkVTdo0WqAyx6aay7e39Vo1aeDFLV2XF99o0NnMEB0AOYBzYbpEWGx0PR3TftbqRWisnJFRzyOmLcCDYk1iEaKISMez1rrReHmt8jNXrnVO6yywVpJiFIHUb0QjpSYTuz85dD5qxaGjeTeP4D47+8JeV4Tvwhq6MOIKqtzanoSpJuvaTxccDW
460b6252e93001d1e80ccfae2312ef92ba225e24ceb4dcabea9e7783a72a8b6c	m/0/1	C8vbwyQ16x3aQ50zT/YI4kjneCvrNY3ULhFARpeM3gkBqurcvuwtzs6B3F6iQkFhiXk+f3HQ7uh0Vaw3sJFRZ9vu3sTVwiEFJdB7f0/0oq2TE8etfz+4tRYF2usKFlWAJ3BdXBv/hlSWETUOGQhK7HBdBuK9S1ycRYaLfN8klnnzVu+paGoUtJnSVOtD8itJHC5wQ7m8dsFsrWWkAky9LcydqtqinO1Df0u8YLJmnBHexKmgYFY1+c6bYjchk7GqIf/bcCe/2ptC1tJ2ToIUZJAqG9DDYpW76tlrgpuA4cxtKowNE2iE+whqLbAJYiML	LmlxMqJmsq7LU4mS75m7q00plQqT/V4uWLHSYfN1Xn41O41mzR7e3GAGVRfVsmX27ake2p0mhIoLTiD9PP/eohe7Ubyowr6fuWk0XjNny1io0ID86XUnXYNvf/cYeh7MYVN3qcEJFJ1/APcCXKvXMxGMSPJn0as7thwlEpMXLPRgWYRuz12ufMVZkoDhyLt2dn7+1MMME+bIyVE/oiE/eM2Rr8rOUtk1vfvBYNY1RybmzkMTmn5XH2JP8c+aH2EgG2gtEA5h+iVyKeWyrjZlBZSnggZaLQoVDWVmFAJd7xXIP+MA+11+SpHnxk+oUmx5
81325dd0e4e2a1c966480d54345f7ce8e1cfee9be2c67e13593771b0e89da215	m/0/0	UFR3H7qLiDRqJplfTdpbQuy1o8yV8KAa6E2oRE4GugEdQMjDVUYjY1Q7cBlWrefZgN3hYoqi8ESlE5XqXgKXjP+V71Abr1Ga5GgLloaBGr0TKWjMaL5zg3NxP0Ompi7cy3N0z8/Ppy7B6LCAOicAUEttWOvp87npLQMZ0/nhwYDZ34ZWQLQP/zwoN0csjn7INVtpNSA66fWgaQ2UZHRzUZY3gKq5ezinQFQpunMNtqul1z984ta0SXtgwlQGMaLHT5D63bn1L86hI1LGHjPI1GRFr6k0QPXGQsI0wDntn3ovd6GUcXXDdqgLaqMVeiHs	9lrir87WF1W2JtQe2dEJ0EDEWyzelzPN1WHpYvm44hRtxzrmOnb6vHd2crjAk7E1wFl91gamY+ZgQSvviKed7jGqBrupTW3qzqNV3qiybxEDRKXXH9ZrWCqXNgdKWBePmuDJA2X5Y7D96Nj4IufyXnCRYOebjAZZukA9MIdFHTmh3XZQPoVRliQ0ZNg+smIs/dGJ9jcnXuFGyaNE40v6jDcM5HhGkNK819KM591K1euQ3D9xP/r0h8xJNoKpjKe1+KR9AKRGDVXznTi3W4vPQitMyC0bojq4wVAGeh8610UTO7cLb+QtZStlUxCGVO1k
81325dd0e4e2a1c966480d54345f7ce8e1cfee9be2c67e13593771b0e89da215	m/0/1	v1+eQSoK0f6U4bIRQWAsoEnOxGRdPeQJGcfZCV5XenazL7PfhuIu4IVc5Sl2o/8ealxl9dvNaJpCbQX6xdNqVyyXs/7Hwm7F3xlJvKsJ9dfknT5HSUDQlQi2Kdw1iwadr1eLmue93ztA0tGLpHLDvcxpuhMdBvT2VI2bU8zxFZm7lQuMGD/rP+tnpHu+Q6ZLJfzySQv2v3lhr4tJK4244Y6e0NAP0dbqZqolfS4RlxXE9M1KYje4k0JDeqZt6/C4JbZ0G49/sb0VfAgx+ZB9Jwu8Bygwt3Gw+J+0/DhqLcbiQzC8ERgilPk/A8zHJ7oO	E9dtzHcKpwAWs7hJgvLNO8KXW1hWctf9R494tkw3PtM8mcJqz4sLrrLQxiOJGtwqZRHXJ0uOuiyWEDE1tIJEPOP4Vu/uhHsC85M3u4eKOV5/vUeGmGKT6X4gT/PWQILsRx8I82jfZvGf7kWFgnW2FViqT/5mooM7RsC/Uop7eHb0ptyXdiu12WrYpZYkrKpz2P0H/jKpIk9DfHI1sFG1urJgS+eEt65BiDVx9rvc4bYzGjUMZehrvonO2vBcngsWGc5y/qH04pP9A9T1RFoPIKn/FSV5JdXOv8hGat0rFi2nkqO+l979YleW3EXc98bD
ad2fbaae488baa0a3ad271eb9fc6427bc4ebf34b05a8e0b57adea7039e5d2fbc	m/0/0	t03QhCGVn/0RbTM5umRoKXvTTl3cOXZVX2npZlVCd2Ke0VsECVFd4kQKHnbZZ8pb7x+6dAlUzOlPCphBZwF/aJ8d/B038uTEFQjlxCS35kZ5cjR0ALpHbUAigfYNOeFSlYQ2SBbx8YDVW7h7iHS7tYFskHysc0Wtgs84XiOksERNgBJFsMgyp0XZ78HAOF6Kc11vSX0Df5+exYVJWEJKUnuDLdydSQa59tHCyvmCdh0pdc96L0TJKPGJJ/r17+KqXkHgOl3hVMUU/QAYIT80lKPEXHuP0Aaw4g+kM/ZVdhUO5dZhjg7WAO8Zekn6TY5/	sCbjqZMc11k4IqelwNggnVdlFl7IAITvXOI+q3Tik0Xzswwv/tVRrcTCNEEqfg5hhW2DlngqYRG0xTuEbMExz3zQHoDV1rHlNZ4Zjy15vD5/hAVmL2Gd5jGEhcQwWJGifxJYLwwKZdjmDO+d+phgV5dqnViPsU+Zuwz8L8DiF8xaPctEEEiWdKkJEMcmq/wxdiUn6OPgEeJ/hKN7JMnLzN5UOMSk7fjQdJ8LdPnplhgG7KbqxckPfRYy0760eaF4S4R9E5xk92dnUJiAwzWx9sjq8VIPVcuefamiw0Naf0AeyLRdQ395kxcg8ZZ+H5H5
ad2fbaae488baa0a3ad271eb9fc6427bc4ebf34b05a8e0b57adea7039e5d2fbc	m/0/1	XCNrYFdPM5abro2XmvN/+IcDIRvuVidqwyKgtYg9Jdx2G4tfZr/Td07zFfxp+06hG5cjWOgYwZpd+mMCTGPxT8NPL+cL+g8/IMq16DZyxP2Vadb7iDSY4YEMlFlU5KyXfZJSDhCW69bYHy6FXYofBqBpBLE9LeYDaRZBB5kNg/B2OXwR1+G0PG8nPIaguevc0HnVWKhhfndz1BMMpA2oSolatWgv0z/n4so725I9GVkVyYg+O0bDuTOLreHJOIQTaFG9Nl2Sr3+C5VFa/qg186f+z7k13wvpEeRtOxUnV9+9qgOqH6Bi7AJEfpqrWAq4	/XEsqtN9xlx6Al7BIr+CDgqrvqgnwGi/QcbK32Wo5tY+yG3rKDwqsQT/OpqBoDGsUs+k+Zi5H+vQndtchvyPeWzO+KmtNj/ga1P8/DrPvNotYTHZJ706zCbu/2ixmaSrGw/0tiQuwZXgkDViqmB5CVOzIZxSQEtLusEhvVq97xXbREyZyEQ79kfgGiMMOc15x7Yuh8RQ8VbaxMkIzb56bxPgoWWjcobb+uZQV9h6H33R58AzFPnLW/Tp6k1Y7IWy0Ieb2RNh2YXN4BkPG/+ALe3xIgG/4cgR92rNRLoeDvgFAFA3cLtTcpLAu/qiiFt2
e837ababeddec68d1638cab8497bb0bfec6a3b39d2ca4c9f4cab8ad2846d3a87	m/0/0	gcxJZRpyEBSQbUD0Q7ZPufsFrzstarTw4hLqCaIWheU4OmA1TPzXPB7bPcwA35OaUmtT7xoyW35/M6YglqunhVKEsKcE3j2XwN+rZv6NFC3C61kbsVNIoljkuLUi80O3RKY586mThSc0AZWjm8F5vL/FwWdjy3C2Z48YFGyhAwFs+3vxz/qS5KulOuORSEMGzKanlsUa22TE0OASLBmk0oXSHjPCLetB6Cn965k91WwU1DDbZgtPGHni6WrG9COSayuPHKpdHOJbd8gcm0T7MWGioYxq4QRyQtjA9fggDN+MX8Vbb5El+utBAcsRuaMX	o81pe3f1PSB9fy8JlT8HVEN4OVkjMQrnkmy45ylVmTQLzFSAEgH+sq2VpCAww8CxFb7gSBIBVpvEN1XycKJNYmOJd07t97aO4cvFZJnH0mMhsmteo8vv6XsfRd8jHKzoDPHdR47uSYduCsnJYpouN0ZgloicXfwV4BqrSugain6Mny7I5BHb4U3jhEz9wtwWdo4pG44lUu1Yt20zgUFP3Y4ALAZ0YhQqYhKPWIb/Sz0bp/FXnfTZW9/QfRBYTE/iQuk2pbUlPfuiBHYB38hTreDwtgDD+RO5DPVTlHXl+1k0k2zJQ5fqfNqdm0iDvqaU
e837ababeddec68d1638cab8497bb0bfec6a3b39d2ca4c9f4cab8ad2846d3a87	m/0/1	G1CuM3fYMbfWJg2fquhbzBJuwXQ9cxDp2un9wrn0RXw1gN2b3gjMhu7ifl02BRre6n4YWpNvaCEogYlNZhn0o3ccEjA+e75AK82n6xU15Qpaie43GpiyH5x0CBb2MrqnfD0TrC1j1Cq3peJfC67f59Pt+Iqe2FOY8ndpEnGst7fUNs9KE40dhzoVgW/XmWvgf6ctCfM7g9mq8rPcEcoErxr5reMDp2B9E6xLkmj0HMh4LsFXzPpvUlg4G+hpZnHgBx1oBGoTEpQWJF1xfnciX7lPhuMMkyaIZRcazB7Vrx4Rx+hwKKpR7T6HmHWLKVsI	ybueGFFpalVfN/TaPmIdGrw2p43DtdiWRmGCMhMnhNlwgtb4vmk80s39QMq4Z65LMGGFeU7IZyMAxbhaLcTM7l++lbBP0nknLoOmC82Qyo/J6Hz37bzNkGl3Q+fWK7PIA1j2Dd67ujw+BsqgWyqyjq1BeBwT3OzbHa5ZypwanDTHJdvaRStwaZQ4tQkVQ3VTR9jL1dhlNhrgjkc61/H9CnmtTGx8jicWCaskQJJELFFYLizcpMw5uHzMMRP+dPm58ASJ5hclqu442K5kXS8y2aqN9+LvKY08Wx8p8Qv8YMZrFeGkTrhJxddM/6P7Pmu2
e4871053c9d4b92f3081a298b670b9264a7683033c3e89d2a7eddf2be46637e1	m/0/0	1c6++OWIVtg5Uh5ItXYgv67wUtSgmqoxLncxn74K2aaqU416/Uh7zUFdzvGrT67D2REizyQFOQVzsEP2YxSl7Kivp6t/nwskIOok0a7oqt1GDVegmf4WJ8MvrsfvIuX/eW6L/9BZHNQzjKiEc8cWKv6C9NKNrD+R2nKFy17LnK7S6qKVHgCO3/0L+DF/396LtttIMwpTd8e7B7zBU9/aorgzpalwl74EZzcle6nXFY+78si8VkAlHsS9ocGscxrO7PK6eLmOjemS8cKW8I1Szd/Vkd43xag/DNhc8jw7V/R0JTMwKodN88zetD1c+RNS	fNc0gBDJt5qZ0HX8nUqPscoKzPq4UNauSRJBB6QJDZfO9zEQ6P2NxplD8HpV9gHx1kwkNJDVdSipup4otJElME9SbMwxEqcoYo0xR3y7JPhMc+zYVeyg4KGpDrrDtF/YDA6rcbO9dSRsjcIgPBLFZ/0zlyBDr5kfHh2ch9JcMeECXPIuiUvbIR+LWrnqWk+KAAjGJoS1282JCgBlAm1N/U2s70EsJ6/ZvX29U2Hn71rxVvjx07fW8LjDuyyTZiQJ0uvAsNg63XPFkYG/upfjkpHBjTx3oEvGYf5w3bw5GPVTRdyCRylbm0sacPlCm2VQ
e4871053c9d4b92f3081a298b670b9264a7683033c3e89d2a7eddf2be46637e1	m/0/1	fTao8pUZmUDB0cedGrWfxyEDuhA7GHMaqOmf7hxe6IW23sXbGG/veFf+ZFu1xKO+MsMD5MJzm2wkLZK+Si4ZNwgeLOb9y1MgDmdLfnbdhnOKHzonY2nyFRUKHKghX5lhNU4yk6hkhKByffKol3k7IoqWZ/arKknUCCIAvEE+Y75MfQaJoG8w3rfdZHcDV+U/aZ3egYUAPuFMsV6egtjE4rfksGVOUnhm54Xzbhy1mlnBpm8ct6Y3ZMJAuMcSjBKJJU6CUWsX5jlFXRaz91wg+1DBJJ8HsKnpc80fZz1smOszjQ6uh6fQWB4oDcLU0ujQ	+xdi3exCfKLOpTZKT0PCJhgAwZOIwccWRsMzVBLQk3F0jm2T89ZwR8atkjfM73M/n98NXBKGCMUZkiFS5gu4anspKRI/bJJUMCDVUgnCr6IkrHT30rp16rqR6DQCRaUBQ7Nq26Lo2s5TXJqCDbQ3mAGPNqvKczpKIudPIWcMw16v3oc9+cXnnhRhc7XeyBX2QiPlLCrFHIAQGCCDyj0TxAgCUHocf26DOJHGTSSScjJAzu6Fw06v4tEX5PheYquuz0fuqNQ5p3qLKTJVj6dbT4lvgoLts0+YdwZ6BsoDLGp+3PqL1xszcCmGEXKQMo5S
4883cad8c5fe52cac539adc9b48121e2da9cdffc99cc62b8a9fb6b9f68be7e89	m/0/0	fa+n9E6tDRbbHNkG0uLdPWGOmmx7D8cpyMfOAJ3XRSk9e36++tnlIhWeLHEyRTRrDuQWV2GZS0Ie2b8AhXy2/xrC7Hm1OG+eyH4R5Dz+5gkCgvGRo9G5f/yXjY1MqbJ3eiD2yupfRYx4jWq+2riIj+Xm73LTdwCAYJSNnBNIKqYaiBwpQXjGuamLSG0l7qkxl3wg7rOdM+LqjW4Kp7SLQwrDZFq3wAelsClUO0Qi9kzvBbrO3CfqpSzhUI6NNIT/VT70ZLXCpC/h6SuM+IBcbeUfwxuS502SXkqmvpkOWYTPql44LscH+7xBP2Y/g7T5	/Pd0eaP8fHK2/C1Rhg1Wg8wYsicoYJBxdfLIquxQ1FJBiYUN2eRcnEeAbMxQ5nGzrsDSTCeOi/L/E0W/j/vIsrGDExW1P1LZWbPRLOBgGbv8bt01aFgvR/w5DlSyrbHAK+jH6KpQgxq+BhfP+fSdKUSiBobf+f3BsHFXKc9mQYkCCWsxVB1Uj970A9FW0J+MUoLc3hO8fOP4wFg9VcLNSyRBWYdwZP/CRHx2oPEvCcpQSmWDTyLkCIF5UiammkeHjwj3Jz04KnJgX/OXqURsYQQQ11VomkNJ/oyvA5eXGPnBR7eI3V3ioMFlL18LT5iR
4883cad8c5fe52cac539adc9b48121e2da9cdffc99cc62b8a9fb6b9f68be7e89	m/0/1	2qP3QCdQqRvYirru0ffO9zfaqaFNx5jVZbvkdOBzriIQHY3OA30Itm4/USHlw/eGk9Bb3zaDIoRVD3jVVRssAy1ZCWulwgORAwu+KoLVI0NDrfGZJwFtD/3wwa+Zv/5R+etgfH1wuRqplRyzVaXIpIilZmKms5oBTNll6zcW0fAh+UVxkea482n1IYvdrCGRoigwou/iH+vGwa1ndGV40j/nMUAQnjPsHuylMueyRTpO4WIvePbTBvg8jEP6ImINQdcM/rZbxu418vxZADzk4CBnmd+zDrLrR70aQp0gCNGk2oyAO+fSDzTr7EQuIjTa	+U4NfcFnJCm/M80zj3PtK/cwfSgL+GcJSyAPOq7E15SqPvGNN2ieAh9IQ7i1RkbPielrea8stlU5mGkTfMiEHg0x1SG9z2gMXLqA/Y/xlzjy94nv0eSC0R2MtISj8C+sLMcR658FNyPZid421eKg2CFaXlVcjeGG2B6wp8kiLYT7dx0rWm1x5aUn4BJhMv1qh7XhisgaWc5JBXpqDC30RdNCpM2h0Iq8k/R1HJNpR1lz6Zs1yeeY7V3MfwjeK6AmNZNsNQnSBYsv9B/UacV1/r7Q3jba5JBTCpY7MrBSYj2xNNvcgK3gEF5bdPif0xIO
8af802932bd0f045f5534f55f7020390e0e48ba5cc8f538c22748dcf20dcf5b5	m/0/0	L77e5WeWSDE9XApHxZ19JYRZgt8cf23Edo88jMP/xgMRUh0Hp20t/nDFl6Qx4/zyNDZGzymXKo564zACfGy3koh1nTC91A8MAQgyWpwgU1aF/NvoHkcIKuBOm4WLtgnEL0MWZ7SDn5q98gVtv7eqiqARLM2jTR0VyR0QSiwjYxC1V311BiBKboF7jx0GjYuT+FrNywA3vKsINIkGLTq6Wvjr3U24lfE2iusGeWj3c6pGuC4HfQbRbYacumdXKryHfYAUqCuVQLcOfswvjXKWW8RVFESoJNuBx/SXEKxTmAg8bBFxOB4Gi3gBlYjWoxTX	/N0i4TC4bJW+TOjDgXf2Vu3kl93Ult4E4T2RtEXrTrMgIqCnal8WlrR3y4AITNBMLVefhytwFvRRpHck5mV1TlglQDgDDVUPGnTf2q8ShlviZ4kfflV2DGT7+9QDnluBdnMBhRisU/zGkotdNGQGTGtKfd3xoag7k7HiwHKyY6m99CtF+sw+20b841DghM9uE2NY8QFeoar+rqXzQtsYhcLLkLooQSDhndh8Y8wU309mOSSeP5FMCbf2+vmePho1oBvyLGwr5BG+fB7Q+24ruJvw9pyl5QF+iGdBHWaVQD3lVxIMo8WmaLPQFdxH2Mr8
8af802932bd0f045f5534f55f7020390e0e48ba5cc8f538c22748dcf20dcf5b5	m/0/1	VGdr/+lA7GQQGJlD6pz1V7CjNfq2cFZpa2CSrPbF6WEhK13H2a+vqYLPfPdM8iKV8j+kU08UIinT+tagJ87/KOx4covsUHMcBfuoDxsdz2ovXz667zLzv16WhuJzKsBsHnYNtFUoc1EbtuElLY28JGxHWPvNVUzCc1JZY/xMQu7yxNwPitXmPxPLWNINj8O/T03MeWZb2EoBbAySfxLOFKl+nsysFtgvEt7KnQRgCC+x447+5VC9P+1f4dgRj8eTM4Wv6S8LzccM2cLn/D7zowk00qcnRiEOkPKlYO5LO8HqbLBbyk/+fET7Yr3VVOQH	YfG93mJgY8c2/PReyt2b0x0Unh3/jqHUk5zneOpO/zo1dnePmXsqiB/YXL2nmZAnVHbksjs0GtWQRoW5mKk6Vbd3956ZQHTpCQLCmKPokxpoyQThX8WCqWWyoa985jVm/8Mnt9JO2uTBC7MQAeHS+yy6Ww5TG/1I5tHVfrvBzrFEoQDzdlPn0L5s74aCYJT4rxfnfgbqYIBvSMG/uGa0o6V3jxK0zQs13PooFc/rcOTU9bQJ+pOIubKJax3pxV8ckVV+IAToy8St7pxhhQu2nRJDW0iYzWkF7/HlxJqhzhLEAuTmyG+9E/cXjwZfLvIN
af0e6eb3e3277f4f626bab0bce0e309283f228f3f4edcafb9b09f894620c028f	m/0/0	dUoKAfZoQs9OrDvU/Xmfxim1OB9b9wHnsVXcg0xou09snSV2aYg/0/Zv7g1vPoYviu4lx9KOToVG157xj6dA25bxTgMb3+HoM1Ut7Mg9xaZoawD8lqlxkmbjKL1BvhdhP860R6QxSP8Pr2K4BB4TtqQM35W/pW1SPYw0gych8tj8qW+1OBx7ilRrpDxJbb+aFdkwTmrp/aweKfiDMRHBONS9t7v1l201JOv38hxxlCQdvgwTfxCj4KOnZT29WCo27CqonnfrNam0rDAuz4ecGEtS5FcD62S9IYt8AJ9QQl4hb/mHHkSzM4KL9bt8bvR7	2miLMWuX8XSEa/qUe1QFFI7Ko9pnGzbHnR7PHsKx6bnTzmd7XSmLlK7Jpe+SifvRIaphyruergmfut8LZCq45aEJsN82NPHZqVCb3JCUC+rf807zdSRjN8D66NgQ/jFgCRhCivdLCN1WEh35JjhuX4T8HKtipzJdRBFlBqpa4/MLESrApddcFbZVNwgXXCibSgiAtgKyainE73wDFfRgsn8hjbr9vSOWMfMUex+zd4Vhrjt6ryLaxNUhTqYmIAJsytiKdjEe5NHnO3oW34g5wKgqz+t4lJIywxv1wov3ZeMDOgmK7D/0C4jFAy/h5RxL
af0e6eb3e3277f4f626bab0bce0e309283f228f3f4edcafb9b09f894620c028f	m/0/1	1Ykx/8sqPq7MwmCb0FKid5dJlUd8rBoUrG2FnQS+I+2ApLiBYBcpyuaPRQwagbSO7lemuFNSw5z4niwY+rxJAr5QQaLiqr29CpPFuJwuBkzl8P/egOIxmej97ZaY/NtbIwp+YJ6qB6fJ2inVZMx9iecNbB8Woo4QBks/C0q0IdPuhhGMxI5UDEx61V3ZXATygrGnI2/4vTKmwwQ7eghXICRSsxwA3YGf+sZqNYOsMNZzH76fDxPrdsuhcx4Y2bk3HHCL1C5kTWBi1Wl/59UqIIRBGwTkQ8SIpq67NgsZg9PV/NdJiDRfndZuGaZsH/T1	hYMqDZ1LLVDrNh9MuaEmFb0GGIS/6KVxKSP9jNen+2Vh8HsukUNpaVzsotjXYaBOh6Kp+8V1vy7kSERmj1RZ4tJKCNH+oyqjp61VOajyk1Cm83SMHaCzFCM4jjYPpw9xaXyl7Xq+amreZzw9z+PA0ZKioAvu91Px32pYui7EKl2qJxHJcXFBHUggAskiFySO7SLYgJGkIShI+TcbWh0o99vxQdGi1QGCv81P0lUr8wv1WGD9UsB8+mXnEFHbDPoZvuZKYn5eDSkP+GcCnCVQD3dVPDia/ZJ0Th6aD/uJ40E5DJ/e06DNZxKIJSFqa/yC
98ea460da226e52f25e2e6ab837e79535a55cb18da425007ba5df77d759161a5	m/0/0	8BQuQ6XF9OnsaXn4QJZPXtidOgniLO3uCqoGxspNTtEFDR3Tkhkwe2JfWlm3PhO+U/Jybt6OaAu3ZOUzlnbY/vrN1pKW666WYp7J3f8jAGIhXT8jeqst+hSeBdLlZonWHPvsIG233+5EkXAd1BPrqLZLLy+X4EA+Um28PaTTlvT5oeF7EMbyOkF+Ty8fe2+xsXTsLLvaCD6EHZYTVZwEuGnJdR4A6ff5/PSTm7Dxrfxjc+q1DhycqOxdRn+km0etfK9+Zia3tDxKjcMesQxIKm3PZdC3GtzOhDp1mBXsws8Y3sXXbF5HnfzhDEbCAUIC	E6OZcHPEcS+V2tk5XH12WVFQlRNAa7A6Vsj0YpvquRFQS/thnO6PhgPAzSEgFf4JKPet34gXGc2BHNwFBvaVZnFhLsaUeTbNmzaHV9OLbcndfKWTKspaqDubYjsq5xLFnw/3Xr7JBFGdQYRWvDROG0/4uIZow3GT2vxSx1M4n9awVvasDZ+lplBc7sgBTagnnzepnG3fJ09SWmYb3f/qPrqUeZGOXkvyeSP+yuEKZHBTkHlM5PBPfpTcFOh2c75uTWYBO3WyyYL7HOWP/P4I+RIBRsEXYGx7N9tNkWcpvVY1+ZKGiEhSEPBdkSYB+ub3
98ea460da226e52f25e2e6ab837e79535a55cb18da425007ba5df77d759161a5	m/0/1	Bit+ikDY9/OTnBTtKkcrI177QP6fSfuObBEHjF81/77uCsdJsCkXA9fVmn0OjLEbXBCzceHRJAAg1KfMT8bKPWV6dP9a2kZIw/NdzN8OcVlC32PflYiT0kn7UKOkgEChC8nsSNo/4BdySRsH0NBHijczo7pHNNXlszqTQDFv3bUreDZAtkZNmqx0a3gaOz/atA4DrONzC2GZ+yQnn7Y/2F/updkP5U3OV7jfSRY6mSwZXBtabJ5BCaRQkrlVS4UkXx6185twDi3f6m3f8d2FuX67CspMj3s/27R0w/gTTNYfg+nDvWNKiZdWmX55AVc0	ZUJo18OXPlv+WQUoYzNezs0xBaGP+KqjXAIicWbe92QHPBSZzZYeCgU20CAkXHApoXdX/bSbEk2cmn2ybM0j0M6kOPJ1Mo4TA6NKWMiGGSwlcUZbbG+dOa/Lh7rwRBOMIFbrpIErTYRdNeGYqPb6XO5cAGHJ+dMI7o4ZIfbgRt1IcBgNcTd38jvhhqA5TwdujsFN30cMtgoUypE8CkFbuh2IecGs6oEibjJDUxTMw/yDyReJ3wVQ+Pe8ggauSO5rKRJWP/A3zfSJUzamaw6WWSzdlAyeVCdHqj5NS0+dwolR5QhK+VyIh3kHkXdlAQzI
5634f05be7c4877b24c9f6f4d054c8e024fdd40616edc80b08749418c3eca65b	m/0/0	bxxN8yqi1azUVYvWtgXTo8k+Uv0JfrcdCPkFgoXHjFknCptR0eaCV96AnEqzmvOTqVFcD2//BZ5QYPeJDhimXu2nvh3Ea1ckYvBk95K4nnzrsAyU0crTHag+mBZIVjBO+6fw8Pzs+pDFDzriPmvPxYRZiaqnMdJ33I0gz57p+HePcUDT8iCoEUZIJ9v9+26g+KlV7vqYSSnIXEgQL/pKSDq0Gw+5Ovmmj75ae02+uXckd9usV0elezOpbhx6zOTXYZhJF5AZ+ph7bLetgZqz7q9TZw4ifVodPpqLLHN8ETWWsEry38J71cNnWVMrZaZD	lKycuEoK6joYkyHeijzuIichqjsgYSiG1un0IPAAk66R58Mhb3g9zhIIWBHp9rbrSuJbEMXZeij9oxgiIek9CTtoxo6kRL6ZNfp+icxXOdedK5ABkNj+pTnA3VORhbU3EKEaPRNSLtFneJDA7GQKpLlYeDzhTjIbu/Q9RrnsVqhnF6BEC/ukG78nGff9SO1+VjPfA0LZ+X5cFFtNpe6vHEH3OHxjcOf2M65k1XaIaH/223NDIOZm9du42l9/Hb1DtW42U0SsrXBxCtYNXjmz89iS1l04d3I0lLq5nAPubSDXleg8Q++230w+pkfsOVt6
5634f05be7c4877b24c9f6f4d054c8e024fdd40616edc80b08749418c3eca65b	m/0/1	R9ecIKYdDiFxRwqCOCFjfm43OPUXcVx4VFWVHfwjah7TDYOvIDUfgw6uqaCrOcWH44KlFDBz8S0e05IwWncfKt8iCJN7Ip05Ui3qhJebPpgkhr63k1Y6yNeR8tSNynuyHNNJJTbpbtGAPoX+LScmz/haP6R1wjqGZfpfU6NtsLNQkzLfjexPnnzRgW7fL0nSOtUfq0OtOhgggc473EONj/CfbPzM+hpPzHnyHeDoGpkkQOfCIaapm4L2JYHIREV06d0HJRwGFtlRKJi++hLqF6FvoBhUVpS9AfO9fbGWwmjhqAAwh4ccBZgMLCI5W9XP	5GpK3LOJkQsF7BFZZG+InC08J8rbltiNIrg3pEM5kRNmsJBuwXSte8+siYWIL+6QbZu21IGmxLT3/jsIQBbsS8Rwn2FuadYDkNqb0jepoJQLQ9YE4Ibn0TqUII00NILe/Z8Ba0LvyH/Inhl64mKwORS/kzXyfRa3tiGRQOJffsN4vxF8QW2hdQ4ICWOrrXCPTKKxGeMNvhSKLXxFu7hg7SoysGEbnxahSBja+017Y/eTQ29LBQgw5emKBQGyPSavGawNLSywRnhv0G7eKiALkSAkoZw3nhak/tQNDs/R8DA8lVVXvpK87lsXn8NDoPtp
b5c826469c124e2ce20f64714f0165fc5ad85c83cdc4ec23a7103cdf046d46d0	m/0/0	36AMvnbzfJREvPCwexcWZHbxIIdRQxO3zWuEZj+Gt/V8oK3QolBR0lXxGa6mYebaMFELFZsCemkK2v4g+2D2q5yumdkhXt7d+mcLOzluvF/2gke4+XLyG0siA/jQL+gjcvaXm0myVrud84iMxVxFUb/OZOuuEAYf1ecipBU2as6LQhpHHw96DS2rAKfJGFCjdM/ihZDkyP1JiM95j4gVqt9Nz/8WUmWVgStCb6HpmgujNWkVcrGVRnrRlHnuV/zl/9JXx6BYX5aZjH7c9SRJhtmfevCQ5OTTP3VDAZYDAxOTvKpl5+KWdgUbhg7cVMlk	QqhFDCKKYOxBwKFXp4RLG2Vo9DGFsVKJAG1ZlQamTha8VjFjHJfJQWmWipb9eG5n4hEM2AfssQG3k0Qm6tZdYSqiQziB1dmQsbMfOm/fXCFxez4QPjVRXGZQC2Wd3/nD8mHEFIGGJiBdksW2HDvd+rGJ8du3h/L2YSy2v1Yszk9Mkp3R+s5z80MSaP21zDvGiyQTxn1QRRrsoJnMO20XfaLFDBcrxGaLq7I0j5UU8gOwJ6ic2PHbuMkbvcEGlwa+SzxpGD8PR/DggEqOyvZp3fWPx3zwhTdXIrHlhuhvgfIbiJyDD1bPLfyKSTAxmP8O
b5c826469c124e2ce20f64714f0165fc5ad85c83cdc4ec23a7103cdf046d46d0	m/0/1	lIZPdpJHhpGBRKnF/ewaIcosZAr4/xOwe+C7n6jULPCunweGOKUiMqS3bKnPVmjkS+6r3Y5OKd6T5skQhdmsNffGjSenUe2a3Vkz9SHShutq6ejGViUv/j0qi9E6Cds5Fxn7gyTt/1JRIckOTY2PAsfI9s1ZjEihnh9mTWqoAZNkV48ZhWeSIr31Kwc7ZMKRfscuQcFZbNj5iG1O7L1fHHmNYZvZDfo3W2AW6/JZJQd6ZGGSmZU2+iBlwn9IqpvKJDad4y7Jy/YqtBx9YqpXw5x0hBx/JSjnInesh8G1Jvmm84Qc71as9DItdfDlSUm9	uy1R8zkM+at9GJ6r8eb2Bynw5vEbHtfq/3tCULZvlI9IUOmsQ0QBUiremEv7gjXTYFjMKAHaJvmb3rCA5kPoyF9XjGedac/Mtpl3jY3UzpH8k2KAwEaOmm7X9IInWv9pzfi7werz3C6lJD+JRv25pw/vuqVndfOVn8uGEV79oG72cRIZNBjP5Rf9zvpbJa78pnq2IUN7ZavkzyfqhqUEBFTV3sEZF+WbLBbZQwS3Oms8pKV8eg7Jcc7wVrubEILxOi47GwqLdqbNGp/ZGzWPkFI1gnc17wdlRw+9YdTiMTzhAj2vT11y0tD2IjuMPzXr
798c8705baf4378f3e0a6a190cd0b1c73713f9049a73a6d9a29a49d840639f11	m/0/0	oB8PQ2ff6nsDfYedVdKzUVUIxFz1SBtJ5uwVkeqo2pUyaFHwMzi5PV9HFeluevyeUqYfmgUtauETZpv4iq2jXTbfXXPlSFdFDAdGt2wiQXasKLIEnm8287adRUOhiRaXeQQu+wbo8jarB9tzuRu9JTemeL6KrPUd9wfhN7DTe7oxUISqKVb7l0428mBOOHKkWWP/mdit1018iy4fH22VlQ/T8gBU0+vL+CPIyZlSiBYoX5dKCAgYKsmF2TJ73yJPRZjTpCRAbFWhFHpnY8nCzDRzFnswa/zSCkPYgcPhhNRZL1WCiuzhwSAxVZyCQPOe	D1PuTaRl57FIzhzs3wh3yxf48YSmUcR3c8uPOnZIwHJXzm29oYod9V5GL28NxG+wqO4VTKN/KYjH0Vu7DqpU74AKTH+v8Vr8fhjtbBiT+AfunGgv0YruefkgaLYzXz/LY5hCQrcd0+Xbn9Ae66pkzsiOIasLzLNzlORSmjcib4hSR04tY4c0ps23Yd1Sq0ne423Qlxbt23gq6wpaDcSnPVXwerM1gXFxXxZBI8qcKucElRgu/ItxZUjVaDWBeUesVvOCUR2FDG+H+1BHqneNXRntmseMdq2YQq8m6+ouWW4vRUvf0yS9noSSzyfZnwUr
798c8705baf4378f3e0a6a190cd0b1c73713f9049a73a6d9a29a49d840639f11	m/0/1	TgpEI10blAubju6yiPbr+252jR0NpqS0ZV73LIcg7bLIWdYjklFKo7tuCrmcddvWY+WuyJo7TL5uvoSDY3pjCdIbpoIf9JeCnpSvNpXNAONHzA5zN0sh9zCbpFlhIyb7CbMjIVd7TlxusXj68VfTVfxlhD94hmOWVq4P8A1vRn9s3GpXlc6GAuZJzdGpUlibP/i7YQcha/Bb2Bywuscxu9muQYQWIvXoP8NAwgRSc8ncQv/zbDZghjcaaSIces03WORh/HfydcYq5rOg60kc/maMs/VnS98CiXcN4Y0t2a4jhDgZUpvUfCkEMp4arZ93	Whf6vjIvEvIRMWHl0vlrpyNVIv9rV5phx1Nujz/WJc5/u13UDmwFDfeFCsGzqXXRxwLw9eGL9ilix21kzzMUPTMkoohClbeGWq2kmmvdDsDQ+SoFJ/QSSu+qqwIg8Bx/ywNUFcQzpDQph8AQNNPUUG6bPpdma+ziu1MGnMDEhOcqSeXQxS6XXddd919v5tcmsz8jcr2Ty9A/VqfJwXMNyuZ5cCyizGg4ECxOeeKOWzrRJaPq3LPQ1zPZnG2tCajOR+U9J/iYC3yTq3soTlYSd5M3M1VcFNWTxc91PyrzLe5Zquzzv4/0EvdCNZrYz7qV
e9085d06848bec6961134a2eac85fee7787bf6620a796314340c2989093a87f6	m/0/0	K4K9gWKRD7dZqH3Y99lRQwiWo5QOZ8T/1qOSzrUdsPQ8LKnOXgrKmZ2xyYN31eYk+rB69ET39xLHsFatqRdttU8BdTwie0fBcmmFd37Qe0AtToXWasIXr0hFpfgmCi6YSAxtm9BhpF/aFmIKUW1R8UE1ET8Yz2fltDr3lUSWT5JDnKzDZqHOTxW/lDW1sbM/FuObAsHqYw+8VyoB39LAYoTVmHiDFiQjkbQ2h+CSkYtfgwOoZPC1EmGakFyqTl+Nr849ZgChzCzWEbH9T2bBg4FRVksv/IJ3EphXgmnDb9ti1/euhq+pS+PfZXMcmETm	4CZ0WJGxEPQiF1bEQuurllKuwhd+0TcuVT+k6INU/0RNowPEi9uEAxjrl+ku+NwAc6TBX4Fp8bOd6uiSBJ8lngWX/Ld3Pdx/9RZvvMyYSobTfktzR5VVgVFT+oXs9ljLAmBeOK8rpe0JKRLgzsOiDuKk30QewainnStYsvyvOSAzVOMpDH10Ni8TM6nsiXC/whPk7uwQ/XIuAsVHmLfSqJdclnSjtdtm60FNfdDtRdbdpsGdOYby7PHFMeSmTCT8Kauv39PW2iI9xTw8LdiMWBe69jn4LKZuigoiFuG8MCJrQ2/IkSLds7FdKRJEC2Un
e9085d06848bec6961134a2eac85fee7787bf6620a796314340c2989093a87f6	m/0/1	+zDhJB4G7QHlafic8HnymjiickqMoRK1aAQ9sgaL5qUsYB6C1XBQCWDVX4+SrWrfdxFMcaLN6s32hMs98MbszkG1ZvG7rER004zXjlweszbLCH4n9ik5YSBoG/mLtBJtdBwZ8SFsjkunyLoEbuYDeyn4KkMNPn6htJCG+rPUlTIr+mKFhfBvKyso0ZqtR6WKj7WoW/Bb8sAinu7m1QSp1STflyzSVqLZ17SDLIF1qkaGiEKzR59Qe8SM+xiQcTuUWbbTTCtLGRZ4S2s7Ejaqd0Az4rF5zrIpRems5HRyKjW+fkpIgqB8AJQV1OQ4rrM/	a+TgYZhwRTtTYCj3VY+Md4KP6mx8tk6olaqRAVW8xAW2V9PmCb7f0hPVRc/eUFJB7xZs/WnM8ogIE27JlZEh1F1k4Q1DT3K33x2IPgnFzYUi+78Xz/LmVYDwsCEYjfrpwcxeO15nZ+bSsspLMCTdcvObVKuI6gAYg9EQZ2ZMlSaP3qtC1rMSDz6inc+Zld9lUkpuuDSA2JFycTDLLa2iRIaHeMbJFqYJ/CL9DPuC7iZSCm+qCvdPcRacoNkTzO2V4zJm+eFtPC5GGYvHiK3/RLoM/NLiKBeXG8u5IoKuQViWfcDZC6eliNsRZ1xqPaV4
40472bf49352eb4d6dbd5b0a501fdced0f99df82ea4550693a34dd19d71680af	m/0/0	c6LIUrM2KxnNG9DKDsFgKk0VT0kykLUejRSH/M7Tmo5WpIcXyxNlr8PQ7XUWCwYX/naKkVta/KBycEMf+QeynLA9MxDMGg18VB+bFO/QYlLj1B/wdV16BKAGlyjPxjjzFJmmqYlDUwgq2Qcgxollmlxgc4cn30l9aY/aSrOmzcQ3Ifb83QObK4tX4clmZq6pe4hymH4NukD0RS/zHnx2N2XGB5AhPQmFY4S8Bqgro30Fit1Jl+NkjgUNHMsaJK3gEwyu0hl0HAm1faNYiS1vZSpkezARC52H7SkvGwywru9iNWOGRabV8kDh4Sxn4W4o	G2LcGUX4/+sfMy/C5hcvPl22kn3tl0PSAeNJdZeJFPQKG2d3JqqAvdwaIVjjv39BmmaDpZqdSlOB/8yqFlMXmdqRsIc5txJ0z6M9dLkCn918E7R6xR2V9DCRo2rGQEG7R6wpaceGtOV5lbI7iiHJb5vbX0Ax0nPTcJe3k0rP44cX3CXosyZE+LXcGGBSuYYilELIonC0aZX1hK6JQFw8LaT+bPpmt4ZoOj+Clgl57RyndmJ9xta/QRwlFTi3RfA8X+bL4rSRQhTs75tUWHuaKWbOkjq2pR/SAJyW0EDrmSqldALZrO3QwYuu3phs9yyG
40472bf49352eb4d6dbd5b0a501fdced0f99df82ea4550693a34dd19d71680af	m/0/1	7+g4SkNSfjUagMIWa7ACeqb6g/Uph1hcA3LV4mAWClmx0jWRAt7eBaJWRmy3KIx2wG7jtsXaH8JD/LM2jOl+HnC+MkZ4IUTcaO4rWkDVAcDlaSKFYpYhZYGGC6bf7rZTJXQHNCqYGqg5YUNzT5uS0Iu+vtgNOGYWy7vtCVXJQDd4bGChPlijBW5gfbtxPDOvHJrL9qcS5Z6T4sMOz8YjI70EezvqOCzT0fChwHd4qede9Pf3MiT1kRXSiKVq7yE4ukBXAK0vsLLukIBZsRoW/3dTA5uoRRKlZUIf7bqfa5lUcKMnmo/9QfUpf2S4TCCo	BSFErykjIDaaxMcYhCE5TdU8Hge0SrsndnYXfMB8wqUAuaPLJVQxZrN9DdaxKMlFs21BXi2hVW4FCH2sMlutRUUqdL9sCPoqIxcsZjAcFBIdUi1KSwbOj8CM0aHgrOPi20knlPqPpjQukYYu2h/T74v5IkCZI6+qK6TqFmdJfDkN17WbUsPRlIgfl7T6nDRi4xcccWxl06SzIozwYDYitBb8TirrmNyji5MAQHobe8f3Fm6/ioo4BB3lsHEFfvas8mZqp/KzRY5nmKFtlZZ+cDluJpwsnFDAztd82eGSbRxWeHdq/NT8F0DBHRXCSZV3
ffafdec2a94670306bd98349d659933946d5dc419c337975892422800ac8dc6e	m/0/0	cam3c7DziXyU44hFKsdnZP5e8q8OVCliro8YuIaS5WCMMTH5RWRrnbfhxpSgXY1qhlVfAHIj1prrdi+W1df4iAU/MPEqyy4ItqGG9Ohi9jIryeyF0X5kB+JGUQXkvmDDiK7u9HdkNqNseNuPGh46Lsr9fhZtM+yLvI2thoI2fdonJsJSc5XNfFqgVajWTvLD6Cfo0V323GW3uTQzzk/BDlpAAo9yYiuQyLTwpL5XwhpImFVV/aRuBHmdGj9z0Dhndygi/m9IQr0Sbs+YApuI0JyLgIc4KQyLfAHGpRak7+N6gxKYvoMYMb98bkxyxyxF	DNmcdGSRXeoWjfVe0F1c8HXkAykqKAotdkuMEewBJjKYEKWOj7WM2/hsyeVxDiGCSWjaL5gUcMkRXgoFlAD7OtqsRjBgaFcttSc2gN3NZkJquUdyjx5RDjhjhVW5N/U6Nr8RoJrQsIaDdiBSRv2fCsXIuGkuk+hDxVml6zm0dfqXv8+Hu3t2xscrvD4/Bi6U73EKwOXFd5U6tUdHOg30kLP0VOA0hGtQls1ujaUmlyHCbo54Jwew2Em1v2kz4Ah+RyI4d6FM3PHNdXaYXpNn6KzYtzEv7hk25FhihOJS/y+HwDyB9Vx2OJU8i5ip4k8O
ffafdec2a94670306bd98349d659933946d5dc419c337975892422800ac8dc6e	m/0/1	4jCeLA5vRCbhE5p1sQ9e4hd3BqAGVdbiANsUNzUS3tYAd7bSW3kDO/81j9eF5qy2EzKCdaWP0eU+WrN/2XuF1l22ppseas9xLe3kCTs/C948tAPLcZfMswXcOlCrkngN6fkvHnY2Zm14PUDCnpCwWZEUnAjlaLElDxDb4zJHEQr4XRomNWtQJzGOGyB34+9PyavHf7oLPKC9RVCmbm/3gnet/SvMtiLZNm56cq6ZORxony5gCUszvEgDzd//iWzeTNgnPCvgh/DTuyHA9CqhndMGLH/pgITAPFTgEItF/m7VmB+61kvf5WgWU438swbZ	b1A0avVJa2L9JOSpBhC/CY4imnBjJGLkuebqL6xdiYqxkEwY2ffRpadslhqsZwtYXJwxUS+mDAEsRjzMNCCgreOlrGjun0opg88IMFXdd5R9qABAHoIaTXV+xY3u3j4jb4nwiC82Y0HLk0CzekZeEdofLzugU2NDij2S37yhCkpv7FZzOW5DcZR+LuJRiJiA6KJyxt5soeewT4yAM+RW+UdZ5P1fK60vcra9yU8xbZ3+RuLzE5Xlhrii8e/fSd2kx2F2iRXytbRZ8r0p2qBzf61a6kb8ByQDmhbB1vRU4QHZVbwWHpyVYmcvIL02t4HT
0af18ebca0a49b3267e20cfbb7bcc685d59d3be0d16817bd637777933c8be6be	m/0/0	6NO5F0kq0Yy4V1j5svQ94pM7jd3wi3MF2v6/jYxJeofqCBogEl/58B/3IPLBj6n+OkG1naf6ZIUIFx2ut5WY+6hOXXQjJrWvBKJWea/R1rItK2sKmM9COMUFc/YHhrNDgrd6y2R6Ki2Nwp242zckFbQAWy7w0pEWGEEuUz7vhGtSOjzBlJJvh49PXJ9iqsNAqavdf5cHzlz9sEKxK7XSScnd0agR0CLNqINk2yHC5cYmFlw4eMdpnI8QnrbXQHUs3Hm0/rUo8R+Vlcx4fNJUS++/LFCA0VuHBmHKxjse9mg/OO6nNc1kK85HDtUKm6K4	DryVGVVQ9LGIaUcIVhe2aAcSWfd67f2XVeQpK95KLeWAYOeNmFsFPDoh0kvWN5AySVnQR16VpBvsvPNa4lcWHxN7zhr5SkE6BqZrZZCU4d4zS+RWIq1INM8MAgkHL+3NbUuLztZke3MtWrV32M0/l2BOw/Dw9jUTA9yIYz1UINMPAujWQIDE7ysZUpN6jY4cJk8APCt4PqvJo+LLYsmqHldIh/UASvqzaEwv26KBAabqyuCQdVOWNwxhabTvxwv1BA8ahAvArKrtPC0J9c6AMcgtwkZIV5JWC10L2phZmubKcYYfKR3H0HtnksejogDj
0af18ebca0a49b3267e20cfbb7bcc685d59d3be0d16817bd637777933c8be6be	m/0/1	H7lx6ibcNvcsEkYmQbNzbD4Gr8EOxWeBdr7Haqzq00D71iAxpewV4pP3yl8p8WQ0hVH5c9uGJQCnRLD07IeuySQawzI9R+0fN51gUJ+uaw7u637UWOlsbglTFqrUT2MEV+YWWRwZrybtKfxXpdGH3KDuRgwoRLBxGq47aHKUYs802g8X4+96jorQfm6RdjXLLQmlPFXcoDjR6JrzuRcSETNleG1uji/EQWvaBW29nJa794jdXTu9boeTpt0wwJ6KgjuFm3TpVkCONvZjv+sQciUUbHd1xg3YiOUmUHiJZx0uxgiLeOKuJATs04xAmzWw	JpndSUnLPbHNOEj/fZBqtApWovGF9jA4+YLlOfyjUNa5r1km4nJvSwUJ2EtC78LAA1lEjpIRBhSp3BLXXc9qwMhpgAS+vODSYsbtEtpB2nsQKmI4fCyk9HZ6QoEigBBJVtSORphllT034Kam6l+GeyB6GGCtD5PRcv0m0q9w45wOtnZZiDqpr1JYqQU71S684PlcYXr6aEafvdm+/T1DncjA9kPIlty7/Hm5eM4R78NttlZvEt4g3r1pEYuOSrwWYmXDphraYiFrt81hDJu8zz61kjZDuevGkTdIjpWYNRryIQdlAD4A10R7CKZlBVfE
0d91c8a668791d7605d2067c307926bd56a9d07c9f492632d499c2b9ba5ad853	m/0/0	HLI+CnSlIn8RxH5+ixfOLLclSQNZHpLMq4pqwWu1FoN+RprmvGo06SzWN74p4dQqvkqT95mZzArG0y4sIiKHnyDCUp44DAh1xj8+W1RTkbcloHIVGxukWyXH5F9WCCkLigG4/jnnwcFhGg7rfI+/PJhCfjMDbSMyZkmRwsZjBxbKCBxxbofaPaHUkyQzOWaCR5zFZInk8YiLSzV6nTzMf1B2FIodV4gJ/y6iVLpH9+M93u2v24BAnAizRejCrXnk0ErgUSz8f/VCjqmaiVeh3lSv/dsyo2akK10uHx/Ro404F4B1yJXqa7k0xisFjPoZ	CHuVYVVteb1HCmFPfMBfHa6mZbv1F//GEjRVoz+lQDS1h8BJiFS3DXRkQs3TD+Kd0TErceYjJVggHB3ZfK8UIVFP5tTasLlhqsAv0yj7bBfPXlphnndCxn+II0iPSGTv6NndBKvTFYfi+H+usN6V4Wn/CNwYK71ZB4zww8mZGJe1mUffC7YKRtNI4ljB5VJyNOZopA3roppPi3WDEgYMWQYP6ZjUN8nAKtHEpFsCNY07Qcv0nbS88MikQqJfJ6W63VsSsrvZ+BjpLZkPa6xUvNrxKJWul8scuHt31cybV04kV10ysspUMG2ejBFc7+Wj
0d91c8a668791d7605d2067c307926bd56a9d07c9f492632d499c2b9ba5ad853	m/0/1	M7emFMgFbnzmSnEBnxwvDOyKlVHgJGekrAhxbSxz2cc6LVCDjY0Yo1Ivb54ZA+xnqgz/wEvqJyKrw5h68bydx/7V9y7LjeW7/PGT6o71rsVP4mobAlcIMe6BQ+0vELDfUKWpQsXIfn4Dr/0ScnUdoGTUNV2S1wtuLyB49+p356Se1AUoyjiYvaV+S0Q/AUVVQtRtxUM2arzEZXn07sWOOddJrXUun42Cmd2jIEYaDCSCkkHdjzHN1/YymebRmRR1cj/odMK0QIbZwM4RGY4hP6oGdpjEKEhkdM8GSGpmc3H2GUj8I/TXQmOPEPSeCsEX	7Xi6wNxA33vniHAYr27GujgHtwgAqha9ZC2DFYTBYviO6vS142ZVxp5PX4ik3J+iTzi9gyUpvgFDiblz9cZjqMk2q9yIB83AOdxDCaQsgNjs6WnNFm1sdtjrvAuDvod6V8Xyryz6nIN5mc8Q+wfdxWY3YG04oYqxhrZhbowWM6bOO6AL9cpTKupw973NM0YKHZvXnhbZnz3l/33KgcfXzUEySMAc56oK1h6xrAvqsvlx6VO5FASu6EGghruUxSYiUPIMiVjGREcWMxrZBbUHggF4qL7xLXNwbIrwepK5xtLiLKv8cOVTnCesL+TtfoYi
3039ea9cf03f90aead7b772a8fd327ae4188741759575d2c9eef0cb8df702912	m/0/0	Oz8OKUL8PMUPns1wjDkAUxX1QT8OdUSnSv8WOYpg+S3ciQcPNqrNOTyR/UfUhqfKEZz6F3jEljCqb0+HhNHeZ9dD+NbulyIGw7twG4Z+REWy5d4OL4/VAwoRAgYggaF5bdHp84JFGbKEugUxqcHawX3rAhB3Vi6m6lKIWqheWohT/fiVR+GXrIWp1ketHKaRi+iLh3yBlyZwUYcnE+2RabwsEHW/SQAKg4/lRDGEvMktfm0geAIhfdqS3NUefyOU6ONwl85qB7Qx1ashfWxLDcKqza50fyBdV1r37Ud5GTySlXRM8va+Z1yF/vDavdRI	gwobBlXwTYih9vDIh2tt5UURkP2h9XqWlCxDILherQDflLqnqqM7aokHaz8yC/t/0fRwRQjsY80H9JEhHufzIv/qtiH17bZkX6+ZAwpAzOH/NTYB+I8Cc3s4Bf/WJg/co+4fsVKR5fg7+Wwdec504d/HRvnO50yt1chd8IV9WtgzDeNyLN2TgXwzbiGEYDZOg/lilOUE0XYUf7+UI1j5ToJNAezMAf1jB0e8H1kBVV/ydXv1Jnha2cja6L10Ur6Y2ytxaaYhn55nEcI2jANJSgiiOCb5OwnKOdRhlvYJwchy5lQba/9R3g5PmasRYdV/
3039ea9cf03f90aead7b772a8fd327ae4188741759575d2c9eef0cb8df702912	m/0/1	2vqG/3OcjsquUtkVaG7cVk8QxMeJ9qgY8L37WfuQ4LnTFSFfxtmBT0Tv1yt7od/BSNnOOM2TzxHFjk9/kzCpiFx3ODlUS/4XVi8zxgX8FQqiNaa7v1HBYzdOdnankVc/CTfjwyGnvtNdl/otI2mc4XxxtVdYKiylDVJdmkCMYVkX3kg4hmA1yQoZmDMffe2Glto2pUtgFtX6Vuh8YdGiySbfBfIeVgQa7Y9l5LN8GdowoUWvsMCuwCBqk4egi8ZD8NSWMlNSw4aO6QqEZdqq3LLw4XlJICwKxtPCaZEj5/uhQwNReh+Si0YU8tZDG5Lu	ixUl5NJPwYK4pil+UqN36wBfeFtsWQi8NHSMtbkM4Dm9YGnmYAe8s4r9u43JZ/HcMiQxZ8YHf/XRzQIx8upm+qrumQoyjiUaI5+lvwoDLHpYuzoL+IHVUjQH+FWRKub83FF4NWAlzQ7OseMu/dk6jI8+BI6QRe0PfzhyUgeapB7iR9ekTHprEpR1q+SLX5RFjNCx2LdVNVLjmS4nHHiERvi9Ygg/Vwb778FZhHSQZdyxZtgKuB1dPqzGCf0hx9VIyI6L9meGS2ZvRCEpnHX9C9iNqjrs5P5Xj2fNJaKYXisxLrA09wR6Ax03nizgEQ79
8dc3ff0e9df2a99eb045be1da0fa0bef319c3802a4f68a6eaca3e70c36bdd5b1	m/0/0	j0mnXn81daaILRbwjDnlhG0xqV/KsoBF/dRQNPiSUDltIR4IzCLeNySl4eqh2KPxuhy+xG+Pizq+UVLWgfTTmMBApRblI9fuCeWUxC3EeDPbqx9kSOwaEF989GAfHWCLeDkSw9+2lGOL7FNItLI3HHRhOR3vEYAvo4mR6zbaD/eEMeZnOX0iQIxNUke+yM70LDdLAFkB5gA49O/KCFzWwXFMLorpQuTaJQNmdUgSJWXxgPoJiT+yUE+tSZ0Mk0abUHIgHbAlfXdynVKHzfS2M7kw6TpniAX21991XSN6BPbDrZdATSAVPz+R7cDLJykv	wzESSInv3SEa1xgcnwOieZk4K1U96PtUaIYiYnV7e0VjLGy/VqrOsdPOWjhEm4TQvlccOZbgajcUEtT4WpDusTvymNkUtD6ycdptU2lT6zt9cm3zlTCRZnMc6kHygSaIFKnHIvpHocLtjGWUR3DWNJTSkucBppxkLvkAfrW325kr7Ipiq1Lt2nAJlolsfsm0bxSegpPdLCr1M3e7OzAphR1+egrfpIdauj+ZAT2MXmeLVKizSEof0BE41zu+1iqhqu04dVOFgyXZBQinAiNx+o6gGXafghY1MhipUz7xjPNt759+23zYuUGASxejaDxA
8dc3ff0e9df2a99eb045be1da0fa0bef319c3802a4f68a6eaca3e70c36bdd5b1	m/0/1	3uF8fQ3u7EhKkUSuigxZKsKpEtpsTS3MMKpDihdNki2a3u5xR2taL05xSEYx3bWQZODxS8QMYN6QUI99adUNVIIp6QkrTNtWPbhjV3uGAUuwvkoYS1B2K5fCDu1WZRWI8vKXTY/qppjgtqO9N1up+q3ni6hFmgQM25/duOfDitu6VvAPE+DIdoXudfNp0QwzPWTi8nQnjktBs/ELx4kxGhN8Jy9UQAaiU44XhW26i1jrMj9rUhgBF8D/SeNmRhO6Hg6SIJaBcbenMJr8eukhDMbvztw/UHOcAUN3wxnqqHaMLDdTTSE8ta3hW0UQoM7q	Hjdz/sfK0fuVZrAdqk0serdKsulW/i/l891sNjz3L/xdWOwrRbOGsIsOiuFaFFiHAJoU0jfJFaVckKzOevVoPHxC5jjOkGhBG89Ak/SeOeq2GjKy7fUZO8TEhnYJ+K0Rvx+i8PXfeWp8HT8kjYBvADKXRKIQQ5vYAh5Jr5vujTfafasqqt6arUgKqyMn4H2qoGMOxjpW1Nrn79x6NXQbTXL0eTgL+Mwsy98kjz0J3TY7VRAvzqq8z1n0dz7gWHqWunDxJjPQRZSntiU4vdWs/HCECyR4VpboP1gK9+3Fv64yp4aWhi2QH5S8/QSB9wk8
c10bd4f03324f9139fd748f09241b8444266c789c946e023c606c595a30f3819	m/0/0	a/06PUMY2MR2IL6vd7nhkqiW4v+Lq/Wa/vdivMdBFP2grrgWmUlB2p5XtUAdVxYZT79X3P4yV6jFMtJCQwJFDgrLzXuqlAdI2TIZuUkKVqa6uSgj3nXGu+CR4nwWGIv4tewi3eg4/0XhKGeqXgiCMhFln2vFyJttqFQKbT2s0ib5RMw+oy/UzZpBhogiCEEWTbqYUmV2bKj6Ps7QjSEZK/na5SYsPS8BvbDZaG/ZLpGo4DVmktCbC9Xoudsh/9pxt2xBoDzYvTo7YFt6uiTrP+UAYGJy0Y0/rWMUMblrxH6QxbyHsmYYo8X8Cpy0Gl2e	70VLBFUX+2cIkCWMUsDls88H9i0muXhRiUGXZMdQ+czTxdfS4yOXpCVx2GMrby2dUW8+b+Ru9cOrJSUvRzrSYVc9fh4Mb+HIB5UYsMWX93LDeWYbUidv3z+H0y+ft4lP5gwX2Q8osvdRdLJQBuUeMh7MqgNlxyeCC8fpvk2mZBnR/9e8tSblR0beJDeQp8/g+EtqskoCQJMqH4wNvH0oSABfHKX4gLsMlkykqpscxrYnJPjVrKthhZqsyZ+cCU85iYHwq+zzsdj9ssLdgSOwOgySDTfNxc0g0+BauDs5Rqyh7yfuS/J+5wl4idHSAMmV
c10bd4f03324f9139fd748f09241b8444266c789c946e023c606c595a30f3819	m/0/1	qeaqKnUkv3tkZsj9pI+INaxt5cxFs+95tifgUmJfBr24qH3t4cqGbtdDd5AIvPj5bnoJDI33H+fIQ+ukd+GfdzfPRflybr/ZgeOH9SGpIG6D43+xJBaWUHEiiICG1ZMlPFcLKVGALHV9/ic0f7HeUWpjJ+DyVV06Ya/MuOOHgKCkWRbtQyblB6BDX+kS4i34CHIYkCguE9V48z8eLFiB9xUbL2Lb0xJrM3Q32wBF6VSLv/ThFSUZTbnSnycQT50S9jKALAYcARV7roXC4nWdeEsvFFhpK0G/3L+zk1ZhINySqh9QOjuhEd01iCW17C9D	ynerZLhMQMbL0YpXRmXHZ5dGhR2+E0+uIe7Ev6huKdxYqBvZA7Dlu4UJs1NwqumgxRjLVrTZ3BuHVnVoIh8em84qFl1HrWRcsctRmuWZh00EaWaq7Y4ieFTWkv1gpMEe7W5ZO434L5jXX7omHsDeXscEf6+L+VzKr+e7lG4SKJXTyyvMOQU1QzTbWNzA9+tq3XUkr/jRDqdOTsFDL95WCXePjmndPL1ET94pJKAaOv+w0shA++09osfAKNOwG3IHgRNoySpDxErmXerWPhaMWF1SzQVYFxmkpvvgIXfGJRzCU3bSDBG9Hjivux6QhQyI
03dc241270d18341948e0b57b14a74f7809206839a1bde2b6936d5ca7cbceadc	m/0/0	89PqFpM9GvQUGtkB0pAb8vdR/yQrQfovkV4Aaf8Egtq9QT9yfNhFGxp3R2hAU+LhETsiGtVr+4va4KL3/pTc0AcEup2W0FvEMQTgin+uMA4IDS5YMcgKV/IqH166Qh/MQsoQ7sEF4NNmadP3KF55ITiZHA34jLKpm+857arufXl7rjG+0h3kWBaSxMmfp2hYFHitB+1cm5QsaFgGsFfCALX/VwLx0XlphtK6M7pd3DofOjpkVvZBF+Rc3teJaHdJE62wBpIjEz6V6IFLC8Dv8TnT+tyGgv6NeoxLaKSDS7nbbU9YyTTIMMnj6E7Jpxlp	l6qOONWPqv+sgcmlRrjshibL/D7wcMZW/Kb3DI53dTiFgzW2wZgYMsYrjAzkkaJfHAfnfeRoagBwTp+DR/fpO+u4IY23TZzkgTGQlMe6TEmKRuW3PK7qy84Ky0hclh5Ry5RS0aRMVr/Rpk2LhvjQbZ1K8Sc5nXWTanFYqOLaUffMKdIevzNfhRKwbOnraBVAkcg+YoF3I8b01cwf+dMdnJVhkwOgclFmyxCvRkF9hyp+7ms+TGzhqEs0PzNu01fiD6WtcAblvk9TYA2ukykn1QxjbyMqs352q8i0wEuuP+yv5H1kkGkMa8L9Wvkkf5JX
03dc241270d18341948e0b57b14a74f7809206839a1bde2b6936d5ca7cbceadc	m/0/1	czsibLd/81j+QfkpkjnpwvKGpb72+EZO2l7pgDDoqnnGKGj25/6Hn3c8Qx29QfPUsocEFh6oSp+foqTXY2tQ5G/5kNdE89KC1mfznVBlH2G7YzhkAw1myqhQuX0EDKdn3ZbhCqDchX4InvvYIfpknnam9JKrxomAxqYcRqm2mxQXBZUwKZjNNqrHwymsCVcs2I4Eh049mWNssVoUbbZneN92tXt9nw0W1ZtnLSDdMStywnYf98mXULA7pnQLT9ISF0Wc7ofrCuHCgtByOmzEnEkKzZgh/lXDI+XnROg0p4/wuM2mDrzgD0IwiZ6GUMmV	0KfxdWuHmmZPHd/fzltiivHh8jrutIm3F52Bgdu4AL1mf08IuMvA+O9qBdmSKeG5A0gzUNbdkJ5WQwRBBinpENnYxE0VjPfCcoxWFjeXytF5APHUbLj32e6PAFE60otilYTZwyH9eqXy1KCvaesigP7c25S+QfSmIvHBQ/6pyqh/ZMvZxsHARQBf1bC06fv6o3VckXTJDiHj9A9IeePv+k2Xvmd2xQT7Je3dcaCeoRoOHaoxhI3PcFwE2eZjfZ75you7oshxyCdgYSwnpFq7qWSoBLrKn8MtIuF/wtiPqR5fhqkl0QfLVXcAnz2CWrN7
6e58e78302664bfa2bab1a6ea1516c6ff3c8576db2bccbd067efe4071bfe9358	m/0/0	FQqCQkbpKGYnQHRICZyAYX7CkXoqCdUVCaAlJ2ks+3ItAUsTvKqeIRF9xq0VNrRQYouWCOqr1cKBjrThH37fyYzZe+kFDfhW7+FLwWbGYvrxWqnxHMaN2hJLIVYpUX4Fg6lUhlcQ7grsRvc7a8Qrv5XHiLI4JAyYAND476wxcX0UlKe5zELySpYPVtWvdYiW8AZYi3VIS8r6zk/dl/h4Od1uPx/NPluX2y8uSWfNKVgXlxBKObE6Nrxegwo4s+wJaaJ4ko4fZMiMZiH2Yb4aeJdwzrcWzj/LBxKfAnMGa6CpyJs8BKpeq00+9Rhh/0RI	Hty8/MZ4sc/yD0o699HObVw0qHe88W+4e2I9wNnXrF7MkTz9L37Gt0oVICPpcydXcTevBb8imGMuX/o9HijzNr/GDtL0cOy2QvGYJGiiQpnGvIfczT6PhURA/vyX6ChPbWpSlE5SpMKay+YzAPtW9WQ+Zahuwrert/cvwlrcTDPG1bvwYUSCz5ymzyBUI2pWHfAf9q6gsgHwb/2cFucE+5CVUiC7ZM8UQ4sKWs7GhiQdjicmUJoZnvC8wNSugIg9xd2HyQKmAMG+ceq9+/o7VvAeEFhpGDjlbcm7DBRIl8Vq9OJUUx2UGvn9VvW72D6o
6e58e78302664bfa2bab1a6ea1516c6ff3c8576db2bccbd067efe4071bfe9358	m/0/1	nnnrRlEdlEhw3OQfxnDO+lK6R0JkubLinofl+prNYG/s21wYhnULvPdp78XafH1VQ6Z4cpAUMY+Cm2zE5ZhcYGRYrT9tfeiRQizUiWx+Q60R5ufvTylZ8SSU6eG1ciaPOgl5yUtmg0mbuhl+YEZUzNIz9kxjKYSM5VG+IuJr5wTvuQsSx1NaKYRtLuka0mJowx8jYv0YHVoG+mEbufedg/tlJPliMuApD0qP4Dfa2hOQU5CPVFm8z4M/1lfwuv2DQcSp0zx3+B8DW+dkBYldpG0wi0GEvYMfnM+q7QUHdHxJYbqRjcP/2L3CqqKI4Uav	wnGX3vVSIXsztCcNz7Wt5VEyNc7acrDmO1GEpXW8wAW7dOWHoOKAgV/Yn8Eg3grSB/GXH44mP683jwOy6uTTDZ7VZL5SjxkIVlufS1cUhpmMm7KQcp2x2a5RPYPLlNLodGrXkbu5ne7bBzLdmDGauYPCVulKXw1nzvwQEWnH6K4dpcYFiQiFTDGfdB+V+lKjhDDpotbCyMNtlnbLrYt9wtpErSRnjqUl4Trgr2NY7qr5ZHdND7GnaHMVzdBrxPqGTe2saB2LBXM63mXbX+95RPn8FuzS65nefkNpgwL98KGVMJqFleNg7ABfBDh6Gbmd
d11210844e7b24c78de54b254b008d33b82e06303bdd2ac6449717f4a8bed844	m/0/0	GSRLPlL7FJyBj4nPDNEDa1LCEG81snsw/NyyJ+UnZEbGhOcWwC1UtdkrIk4/45rpDZt+2GgMWt+//CFeqNpKRz9Bn+pFhrkFHVMfKQNSNde6DHFdBWk2iQuHRGl9MgzVAcDoGWFT0rRs2x9ZRXzn3BRrrqmh62nR5it2PUZwDJ/PAwwRqbsDROmDKzyfSiJrbfu4T60DX04yo2i57/7BYlnWua1nnaAHv2zWe0HQI0Gdlkqsjz3FNITEbDDQlXNu7Dm5KKN64phDI+B5RzGmwf6M731CMxCK+f7lP5TqGFSdEW7AJ/XzdgMyjmjjkNOv	20Du1zMqIx5OL1LV7cGE1TRgX3vqzct/4UTtWjp+Gbcy+pyjYb8mVJ6OjHjww6L8dsCe4gBpr6Rxvw9lmY8BnghVdycvs1N4o4Fd5mXiwh2dO7L9KSEw47DOXQmUtr/qaZyDfOIbTvqSnVIci9NLvbjxs9ceC7tbcXIPTTQsAKgjMeT4OLMeASa0bbF3oR5NdzVU7m2mKQ/pzfYGo7v5C8LgumeRhWlsthWnP6u0j+2rnAw4hog7YImo90PrKjrT3yt/pOQ/fw6UhOwFJHc5MZtz1XF3H2IK3zuJkb6mFU1yCgTPMhZi+psmjTqgYexr
d11210844e7b24c78de54b254b008d33b82e06303bdd2ac6449717f4a8bed844	m/0/1	NZU7u61hQ5rBMoIT7JmO7/gg/RuwuLdb/95BDM3Uehd2at2fWp9gV0gZs2B7wYCYREu2+4SOkq2TYpgyQRy4SxjqPv2qqLfCzVE6R/bA+THc1I6CBLVJkA5bgZm97dR/Ae8VxJZnNWZO5q/5v/iqJkRrtG/c2iM5m/tZ2BXsaRnrF4wLlQFzHfeCwPgSjnkhfh/JPj8G/+CorO2vkW8YPMXBQpnr3E79vaPaILRz9INywMjdnBPxRjhJvOoJXJI6JAFckMiEwW6muMbmf0IReeXfIrla/HnywMPvWeyx62uIBiC6OD83YFQ+eGL1xkli	epDPZtZm8ccH4MSCwHww+p/41HsGeEWDPDwRUpW9bW7lkLnevGbkpClNW35MOS61TuqNaeoHeik2UhLi0NjQXK3af6CBg61BWhfbaJZApdwrYLjNYY+5Bohbar++i1jTnvAE5Bjku9SQpIaAQdplAGha0u//f6kxxL/tLANF6LMV4tXdj+5EvcAEWmcIBg3IVwpzQ6V3xg5TuHb5k2nsHrXuhm3NqN+z8gBMbeeCfTw/YEJ0Wt9HRnEqCoJNGq8JtT4o499o/7K4uSgMPz39KSGaXTwDm8HFnWObGlbQl2QuOxMES0/mMlsQ1E/5Z/eT
4298111cb827f99d8ed41047ef20df4cccb5affde2a20140b028ae112d8fd1d4	m/0/0	IQzmMX7GaN40xyaLmqSnsE9QqlDulfVpX4MNupKgZRuWC+nj3PcJKCNlErD702nHpYmuEkSQaIHd0KG8BF3sl5kWOQNyEH9gffF6UpnwrHmiLSpVeFM+LVU0QnswJHhM1J/pdwM8SoaySm+UCJ7yLF3Qn7cmduo7NQmIpK9rupPMshJF+xgHps14OqKglLkhI1zjvUtVUV3fDiEgBi0nfZsgO2mFLHvNe22aj2SwSDN0e7ZWErlatJiuD0jNYoHk1Q0+uc9BixmcdH23AhpCduplcKUarvrDHKzQEH48LSb7qjs2WL66XVTejXUASN/c	S3kAhCx2+nargJkvPNHKyhctFtZljdJTpapKrxz5bGB9iI98bwsamtyRT+B3Lfimpw8jvUHl8EmOgYCfzyoSl1Gi1U/OT6GLwlzVTc9e1N2GwJfJAH7gnM3opwkOnbPXuQRyZ996/vE8F/xkJgcRzBCdknf7wTLbr4cY6HrWnhufsxaiNuGMLa25unHeEjyLOR48uCqy4VVf7FP3H7bh0elzmRkYQckC/0ypCloHsf/xokP16IvVNTxEarRKfHA2zFcm5Yy3Z6DCqaD6kE/9U1hqK9q0UcmRVeTCyv5XiAUUYml7o9AgRqJvWtRY0T/B
4298111cb827f99d8ed41047ef20df4cccb5affde2a20140b028ae112d8fd1d4	m/0/1	a/3Nc0RleiAgX54yVtCgvIxLXfWj1EZgdX5iQO//8mcbGzO/RNTaHI6RvgLAVIgtzcxaZo1rzZc+9BiH02kqf2iEEAyKxp+oS7YvtQ86dcecl5ViuEmHHcGHbIPI7jgBJAwkLjwHkRIk58c2ov/KzYnpWOmNQtqH2WKl325fBDIUoMNen1ub/G4cmfuHkMyEGfmAOE4ZkO0lNPocDhAuVH1aNl30THw3jJPNAXhi3Q5chALrSvQjWN4i0YeepTByeqd/iNbwc8ROhx0XRCErix/IaR0Dzjc9XsDvoNTaTlkgLKkv8ynGKjWUWWRBqUfp	EJ9m148zVRsz1qYt+OiGnFv08flDVeUaULUlaXVAQV+qKWU/W/w0vdywMh0wjEpHYKuDaACclfMVdQ3q7wgYW67cqyT0e3DDkh8M6JHJ9StaMoDZJR8opHzshV+SufnmeIRVfo7FFcAD0sH5XEW31LHjXVc2Wjce+RjTFHmyEYC67n5/HWOOUfXBMi/UZ6g8vsKb7RokbTVBgJuTZNUKjqQoQgClxW7mySvyzZ0tVwt1UhHZOWX5AGBP+vWdzcfGl4EdCu6qJHa4hYLrlc4uj9h5cKMO1U5HIHgbSGeYKd2Pm08Orzb2Hc2jimgcKkv3
ea507dd2783bb201fe7ed5d7462328ad5d7d1e370c7a731dbe43434b2ef5beeb	m/0/0	x3rfLLw/dMtZuFR4d4IejHdFW3uaMlB1p4VmlQRVBXnfHnDmFdauzi3Trlq0XK7Btf0NKbrDUKewIF6gG8pwLONGFnraW47ccsbb5P0Xxp/917qgorcj7Q4nlIc46a2HRNidTgIlmUDNPZaAFuntof62AQF3xwLgJ7iyFpH9Ldg6TtDAYb/jLeX28Jwb2zos48XwZmS88xCeNjpAyKyGoYSJLNrUXWglFBcQ4E5UNp5n1lS+2cifVSh/1lYmF+8/3sAPPb9+y4bi3Ek6M++PWCmYD+koI33ickwlzZfLpT+0Qxzi1HhWgPUEBk99sDpo	2iIokVbLFe+aguc5hOuwecgEXhzpM+zi6O8cE1dKSNwWgi54R0ou+iPThQeYj4TSldgWUVKFnlolWnUAjq0Trp5B5cmWhQIwRBN15MJF5zSZVOzDN+fIK4iJljLLQueHse0zV/Mxw3HRv2A3OG9WSHfcaSpcTMlAO8xD74mpc28y9g+NpdMcTcaQTvRXZXB5kG216gcx/sCGmsbS5P3utiva7KLKLSH/gmuGgYli6A2Wb1T/rGcsxu+mjtjOQaSPZIEC8Gv4fOOkJDHKtCLHm5594zOxfEYdI+O4caRlOD0PA9errQSBtzcvCALxZCP6
ea507dd2783bb201fe7ed5d7462328ad5d7d1e370c7a731dbe43434b2ef5beeb	m/0/1	lOCBv77h6lQjkX++RW/7VN/nEhQ2+5Sblh2qVWk37plQ9u5/7gyfv0D10f02D7NLDThnRtDoUnKFzvRpZys0+P4LMLWCN86VB3rlgWFeghILuxsDByl3cqoApeN0ydXCdXU+2E/SjRjmKK0LNqWz1Kj3/1i9xY8vZjXk5oXWKGXN8mS+PyU8QpAoM6pS0s0/RuleKSeSjXocgceZbrY2eNEvBjs0Q6CKX8OZDSwe+mRvly/02h8PxHBe0VrygCQbU/pekXFPTRmkdMl7tyd2BfKydcO//imUjTrT1L5FvLc8fP1xQgu1k04/7BThHht6	YsLE0qqF76WHJRpBtVz0HX+VuaMydN847e8ZG+AIWmjo3LpRY6m20Qv/rxR40esBAquv3x3IdEQGJ3MMzMEUAMm3p7DYRzFHdeTBMuiL5X0YgT8DeJhUYi6gavGjHf/VSS48nbk0c0kEvSC9cDoLFnbKwjrl+WQlnu+68BYkf7hcqQBwFVskwPd1PiiRMnM/Kkmo45hiSLPiJzDqhTDK9ec2WMv0S520vN2JllFxKjWa97qjjR1h4vPIpeeMusXgPxOKd0HEErWI2MT9GS2nwLeVz961gxeuuWnx2obWNpYj2OyrfIXMS5BLy2ARTmpJ
f952b7ccf52fbebb04859d482474ef46fb37d4f5e63f546f563c5811828096bf	m/0/0	0sQxGiBEJ/ScwSeseiPDD6VhqsyrtMm4EUgPikp6mZ4hVfS4rEbsXBL+TyMNEbdgln4RZp1f4eqs0iaOR84NY9PMWEqT2Le72+wfZtPbSUYChLeMZ7kLF+yS47dzSn72zToO6Z43TFruehh8k7x0aJE603bVVnF1qW6DNwEHVeL4cjDIolfOlupQoS5dytZzEShoi+cFNAa6im8yS+8n+25GzIMZAGsxabgS0iRz93jE5zF9VoXYe+M+vhPLgMRti1ZG8WlEUV6eAHTyeiimrFv4p0/himl6EBhGLeR+9T+ICyDpj2MEOhpp31D+JnYK	Gkh7XuGr6VIw3C8NVKlgRbrQgchuzmpm66WW3N/hHl5yZ/foNfWFFqKT0OBH/Q8QzNYKCn7qI6TCTb/f02xJRp6Cr+se/v3DL6qRfYX6HXbvnRWPkCgyJkUOzLZYuA26LcHcVZ80joqzLWswfSPVv0OabkvPeMkP+uWibOhGeODDWu8lofxXiXd7PCE/eXt6G2uK0vFon94ofgV1ejzmFbRgJGVqnKbMdCB0phMMnmun2ulMcM1qKtpTHh+hTzxWJqaJvLdWkoQm2x45+uvSqXj8eU+bt1qYnaxWwTM/8d/kLTVj71Cul9DPRd+Jb2e5
f952b7ccf52fbebb04859d482474ef46fb37d4f5e63f546f563c5811828096bf	m/0/1	NDp5gvAqyiLezeKJ+Moq6FPXwr/ZFgsWhwM9GAeMhfq7gxB4u73HD3CBSuk9FpaeAj7bBvd4f/oczowOqq+wFPJrg4hc93Yytx7xmcbZP9k5ToVA9dOa9XPpu0yk5jKlLzeIYdAhVsnnpEBLrhUWLvZprnw6Uf6M1GPHyHvee1Wr+oNw2p1L9V8iQ6M0xeKfEeBTMpiFhS973CAphsTicJatxU01UdbJ40xnjRvmeKu1UKyjbJEV9Q+OCvqBxLH8acVqT4GDAmY+booe8rl6g8wOK9r1d2AQvvN37Js/b6CzhTKufu8yH39Sq9cWvHCX	sGSshFbV5GvCD2g7RXB8b2qHSqYmSEi0PCX/0Zv1ET0TP+CW9ojBbitMmFug0at4+R6i36WkXE14mS9z1HvK5RjsZt8DZzKA2t70Q2aZGZUWsLHQSxDehwjYc6GBF/fRhhYtuGDtDISpi+wU7JyBFPmz/TLog4LI23idVi+flkYIHZNn+yk2GNAqSvp+z75avSXkzw3n+tytCRYQZ3ms6IQ2OQCn343u1s+wSTf8jwWotP5mTuwg1ZiDiifzTUN1hgbIq8j31yBe/fuVZ0ZIVIuS0tV+0JPRBykDOYuSj6uiKwoM8RiwaQdB42zQ8tZO
1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	m/0/0	BxmpjbkSH1zerDOMPKxROl92styYdFuz/dF+l+ZVoxDKuJqytY/Fi9h3RnVhgF4XyYNdTsqkAfM6XiYtY/JUD3j9x2skVrbIYX0mJKmtezk2b08eoHgZn8MLK7w4rTzJ3F7/D/6Q8B1aYYewhn/xm7OSSuZsRwqLHmkRNsvE2NAD0Xt7U4ohsU0p53LdOZgj6xtPCgWAStzEjC5dTD1BPThdiQbIxMaYjH7OGA/NldSP6UudbWNi2OC7PWSyMrXo2ue8ZSi/r6f2cCS1b35B4UYn6KaOGQvkO4lV+EMSDzlVLsLMtPbjtR2k8pndyqdU	IJsCgwXw8L/AC1ZvgaQvdd5WHmiARAtG48xBsgnKJ0G9EgiDneWfqf7RbJYP/FNrAELYq55v1P5ZsMiV/QunrZNLBtn2Is/pf4AZg82e4ght6FpdJIRm7w9yb8JB9dJ+qHbrBhhLFhkaqLm/FaXROoxOeD0K+E8myPbffAsSTytzrliiP55Dp4u36nGzK9kkrorLUIAyLR9C7fNH260zaWCCZjuuLiswHCS03Ne01X5mm3FUjXl0P0QlA4K6wdVSwlTX2lapgP6JFM9I2OVOdczGj25EZozVazioBKm9rUBazoRWzMkqhXQ6tSCXuT1N
1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	m/0/1	npsvHHD8DnM9d2jDZBAeAWEVkMC1cC+h+7WzfmTFBwuLnIYveHIGxTEBbjDmT1v+TtYKeo9894usdro5sxJzDoh+q6pydK9+9FMZOny0QLJ053Jl8CyYhRYTrsmouqF5eL/m/q3BL+RhLCw6x4YzArQTLW8hION0vIEoICisyQIVuQsnpotuv8x5fJNo/ytlpgb34X0I2WcBibYeWFixJdF7zTk8Qjq5bfrpOhwO0GxcnXjFKL2B753ZFd0lezHC4Hkc7ZK0rzDJiGUwMWYRVZ7GZJigPC/b/cdpdELaLG7XFmR84x9EIYUtS/FBVu5n	pl+oGvjwbzBieReywhl5ct9f9KPl0u9TWtmvOhsrWV0+/65CgCeGmm52T36VQhKilhgdcYUupEzizkeA1cBqNFQOvDFNMD9ENT3IItv+DtEeEX/hJt4SqW1sY+HutSwhZ5YuK0MOJCtJVVIZw0HWfMpXlvyYQh3+NcBBxR9exBwoby3g7AJWQQwBNiarmln9WPaoTnkmNcCEGlV/+j/nDtysplWt4FsO98dN3AkLTy0bpKD6EfVSLOAyt9hG7ORMOdVvGOxcQxIztqBL7+Jy53iZQYH9r8rQaE/MOQl99zzDJVtOb5MC0DHbNUqEi7uz
3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	m/0/0	QRMuwttX2CjliGmvVuooy+/rn5ViIepVYVfxChw0IFpfX8eJDNeOLKDS9i+pQESgur/zmMSEgwyWbFTbCiNoTANHQs0HZWblPyhh+AzKePLtnjvANKZha6V040ynZEQf5KkEysc6oAaqrsKHIltN9Vecu2tS/Mw8i/ol8as3MdWWL82/2nNOrLWvrYO3YuXlbVTj3r4PVzMjTYUrCYPwxF/GhnABHQkp+Q+vJA0uJhsC9jGnEhHuGkixTKA2aaUhWTTgwRGBMIZYyAxGciUUFLrv9i2m4VuVUPIGXT3WxNpBLURuvUU2C5TcQab9WKkU	K2jfmccrP7DeaDaaZzqEC2aWQpkBED+XeW8UcwnIAZHwsr1EOPVp6PMNtt3CvA/I1MvBweDTNK/TrFSECdoh7cKHN0Fu7qTiOiit02KVcOrH7Ve9Cu8+cSJVlhIOcSmog2giU21+Slb/qj2kkelduX+Xd9n2wxKw+FmIwFE44dE1MSKjGEaZ2myJxbizxnNJfNqt5xDeeGArYTLq0jGkzKqREE9nYJK1XWe+2RQAx8w8SyRiWmWsJFmyg/+sOqNIwl+PX6uR2a5R085ZzXZp2ymrfYIn1mnMRDAmraY+NKR0juHyhfDaHpbBlzSOxxZx
3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	m/0/1	kUm4JAAbn5bLEJl7gJnoMGIlCog7J8sAlzrkBbYul55PPOoydDJQgOhahCW+GwwUeOI8UfVuDJlsEwWgvrpFcr6UPHe7NcNb4AqPPSf2GcVnK7zGXseh548FvIjc5ChKQMYpjA6iKP5N2ceOsrRH7n6OWwCB11yBy6yCsrQttrQvhFQ8d5wd0hSfKkIGWIzTbt+Oblrs5fAcvvh2Sh7hKxv4xdqTEp0vxfb/S7TfyanabjQVMj+a9hoSGh8MP0rvDyUtzd9wqSYLI5wJ1UpAUGbv691dDoDE6vZmQNxHQmvRglaNOtcRvoXBF6bHo6y1	Cfcexe+HgKucJ1t4om8QrE8XGmpiZ9He8GSyBcPZYHtfdY9pjgXY1scxrXhtN/FqO/JVSHukBXz2IhIUMe9NorIvks34qjK+GhlyOtdsJ5Bm5mttWZLj+Bf2cwXpBHJG+d8nZytpIaM6dh/f/h8VpcP7Rm6BXmWePrm8O6iLG1LpY82LdSInJUcWqiNksHHJ9jKMGritdvjOTkN9WcSUBt9Fqclj7puWvet62/zNNG0rnjLJGfI6zH6EXx5RNKZrp3Ai1uBD5WmcFUTh3dcMZlo6YORTzj6A9WfIEImgwMtOdSNfEDeiongrn6YcQPhy
1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	m/0/1000	1J10WYj3PZjHgM95Smaqp7ZsLyW78GJ/DZ4ijgcLrDxhYYFgFJnfQzrkb27d6FMDNKwzn9fmfstZPPQwhwK13iS6jsGjppyDyfZkQFvbH4fNCrq22fJsR2YLtKHVhd9dkcYAeky/AurvKFwRAHe7rfSHMv2dHXi4nlAJH0HuusgurwNgCvc9hfaR066o2am+cbUxsgqR6kojCv1XbZWPw/MHslRfkePn7aORxocjRjK9vXkV4wxOlcpAnWCiHiFFJj0ijsM7GIluSImHki+PEU4IMLoLsiewr2PVtkiesf35uMGUYdcOHtcliEawZ1FG	JY8LlyHVwG7CDu9Lvz+HHAGL2bOdGh1K1roG0X0v+9Uj9p2vVLHTqOYOFu3YsiReXAsXwI8FVEG0eq0Vl8ZUJDJDvUcnv725ud3mFM6dCVKBsiuj7RYtW2dH6LD747pCSwKsXXpklu+F+QCAYUW1Rf5huT7oQ0STj5gu1earr7g+yxSGvpdonwnVvvZTZ84hjoKFWqMxaXiAZfOy7nYc54dOAKH4CsF9hUqttnd/kjGLo3eSrhjjUkPnVKgQ2clVAUXF+1fjp6MJ467cY9sv3jt9nwQX2x4nV2Fol4OpECTtKWcuC5BsdDGtqA2m/i7f
3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	m/0/1000	EU8eT0RTbjdowLwOCLfWi2qjG4XpgeXHXhWqKfr3UV8gKSy03itP5bHJn0Uj2zHFMyBejjTThPCra1eWZmNlqHYZ8WQasfvBWHPks+7NuxxNJW6vBWgCNObaHpQEDUmn3/gbC9k9s90GEExJBQKSnQSD8j9DFlCedKzjvP+qCLgRZPrfS0fCglBpzMAD9nIB0JOORD7LLy0zrhUOxREfBeQE0Zq/pmbHBBJVKQCTKu6zQKMSthz+A7TQoA/nqQ1AZ936U5FHUeiVubE7qOizO74vUyiLb4r/9pNEyvY0m6ovb/z9GpzSDiccfWB8IIbj	+fCR6HoiUSUoAMD/lPTZJA+ncOSWncGKIqMT4GIoMOCg2WpZt+JTABeCLbTlR4NpPms/V/DlFJAvjX8pogDsTzrSn5om4zxogf7YdvK5Cp1r+5qFjuMtPX4KMZeuILqz6FTvihdIwiC0KKHIMtS4CmFjx9yLfDyklq8hO0B/bxFSLP+DlpI1D9wOPjbG/zfjKXtiNb90ryjYO2Iue66eImFlq7VCN4Wbqy3tVKjn/GJnGcn5GSchS9w31D1KsSc0BihuBAGmZTw3ntGHDj+7K9W0kyk3VUEyq8kP7O6Hg/Pws7YAC9/oY3TqqIXUUAC2
090386f5401a8e48b63b19d4c8981e230efe71d2d3f28307f98c0424e6d93f9b	m/0/0	MGY+NhJu+4mOdDNpT3dxK5YIe8HWFByTG5LIamyif1Sx6+EApcyd6siP1iIaSASbN9Hj5/By5wkOhdadNdSyALPktk+LTmTKIVaIoRoFcSOZN7H8cQjTYmkdSMaqfdlMl5JA+D3bdeTyUk4nkbKezpz/LsftxnsmAhNtNrz/FLqxouK/FS8BCHtYcEKiQfgEJa+rHZjX+sMSolxuhDb0TOhWabu5eZMDdpMfGiKIEKbzWmtiDbvMNWNu+ZTjnOSePFZ+WnnytJfFP8YlGOX5Zf2Eg8v95ABdRBg1C+VOsHWPj3VBAvvIdlIWdhtbHkh3	npERptTCVgh5ZiMYPbzCBfGudhky/P1801oSuCSb0D97b0G5KAshBgz5gPBPSfyIt1hG+L6meDD2DFBA63FHtw3rLGQDLkjiO7ldmHB+sAi0N7xJeXVbhbLAn5GxhPjTVr6wUK4pwrL/RdXp2i7Fg5/Bq/YU5LEqSdldPE1Mmpj0gog8CxRRrRHX56s8sLVS3ISs1E+1uexImuHMcJ1a2ZiCV2LXmyb/9PTETcaVlrkeP/D6xvuCmy8LLVZf/eHvruvhlwLDFatZjPUdELDbMYNALFok2fJHdqWLUl0D24jsF7+YLZNOjo/v8lKmVa99
090386f5401a8e48b63b19d4c8981e230efe71d2d3f28307f98c0424e6d93f9b	m/0/1	Xp0HWgCqgi7bMOffqEz55C4MfRe736i3xk3/zaj22dytS5f3a9qJHTSkbnMWWrGykFVm1dacwifHl2bm3/GvgUC2mJlgdDHtb79csnsJ4wfl2IKjS9kIGCFXzgiKG7SZp9dupzegzFkPXL5OGgnTY02P4fp5R2INZxHRRa5/4pNH6oOtRa7t9xd6knXSzkusgbOxHKXhgmxpedgiXEZX0D6IIdT8goiDIjKXEtrvKanr4oYR8X9oDQd3Kv6lVs469/THWm81pCVyyzxOLcfcTMdrBNXfqaaFfEmClVDsX8pHriWcxjxZ5cMESRH0Z6Oy	Mh2TqwHNuCzGaH28rdBd3F9bGM+8VFZsEJjTPW4Zi38m6w9toOSJW3HtXl+SNsckc2XJPR2QOC8dwtnKEhhSyjOp69fYtsYeLPkP9FMSQNvsjGOiGHS4eDS7gKALliJ2rUn2gluusobK/9vMS4aYY8VKisMw4PWFkaQDAYeenhdqiAxuvLNI4nJQ/2de7tREf5/45k39HJd237rTnYPW7t3qDnhluUA1GaBRYIP2w9tB9r8pNXnYpquwnw02x2bxJ9iIbKqx1qvglX9YePGr0Gnz/W3rvYzuseHaQYAN8nz2mT72kvoKcuELenRD9uma
43dc22055016c54a2ad7599b113fffa52bd90ea199c2fd31e4d11eb2bd536991	m/0/0	Ez8f+NTyi8cxhlw0IvtaAg8OhlYx6e0Q89y9w0r06OkVbfiyG9KzJ7OBwRyOdEUKH97vlT2VneCttdt+jA1fP5ukSvkTcU0uCabUFk1kRp1Hb8dNgbLkfpHAnwUBblnrKkO/qU7ogw8i2JZNws0+7R9xqA4m4S/1YkxUkbtLiFZuL9CMBqjC7P9pa6XTjplhIwJS5bO81htKNAivI17cbsJbFDZs/Tl+jPEDH94HFkuZNP4KTPGQHZcJQDyQuYUVL10jMvkckx6S7d1Yp6sTBBxamJ0ySXX/7GWzTr4WGP3G34nGcUSdChhv2r+fGPBC	mhPkrc2vfGctYvDbO0RRXR/6Bjyw4Kh4ckF9ZLIwgR/JDvZMDGT5bN72g6QkQKvzmeCyaTAleMP9+qaayTDW+z5xZpvFwACHiu91l0TkVJRD88bPH6eqX/aN9ReI5d5B6xcTkzqtoX2jVFsBcvoXvB5BH43Sm5qNrHPb2cU5hdrjNJU50AW/3SjPZ61dudCeRE7nEy8o5coLEVGOa1wPGsnTJj1xJkzI5B9Xy2gUGZ/Ag1WrqMETiQiXfOLtdZu+MSEBTo3s50vRR3VzI+ygzY2noux0BQEp4G9mL2+u+LTKhROAsced73End0cMk4wy
43dc22055016c54a2ad7599b113fffa52bd90ea199c2fd31e4d11eb2bd536991	m/0/1	JgTa949oRw17uRt5gFdaaHekCpNdNkSrFIHo8Xel2ITzKoQAfhja0ygOkt76Q8Pmn1ZhE3Sx34zs7ucvxBwrU3b6LQnjy8ctCwGEZ+9TNzLuRpOYy0/Nh+xnzVP/5HvNgOPq70K/+dzbVnAwC2oOfBOcxVuADcCyRwHQYOoEq6ffjOFce2k4wqW0AkWFJWqp/FbylT2qjTowKFcP8QB+Y2B6sMbzRlalgiDEDO/hIVIAXjWZvXu+yMj9JDUHMgMZI6cqXfpKwzB8AObim7zD5ankY7spzOBqYPsri1Eqc7IuMX/aouav2DomR3InPRo3	APIb9K5wVxH4ynYq2OgKORKKE+YGk9HNz9MjMNveHuoB2obwMWTfuFiD1oEViG1cd2QYMWuhUatZbAkJOIsUKyQf3GmA5DEnr3Kk+Pwq3N2/0pOebDthigx85gkGC62VcTHkr8iEeIKDEqHYVMRBLgIex7b/lVTNyCSsbD/Lw+WPAkKBTJ6EQRcXOBfrJA9jvNxZ0gsPDlL1LPbty+ks1pHAf/FTMCxFPeWw/NIcjgt7mQa3kkf6mz8Xo4UilGW+SpOh9oExaXIhMlxsbrpNzy61HzChl/jjKac4enHmYz7H77RbIDT4DaGR6+39Y5Qj
5c6c611876ddfd3f128a4bc79219ce75add68653a4dd5db61c2b536d082c6103	m/0/0	UiQJXhr1+TCfX5tQgwwPuB+hXlSPa8T63zrrrkw5badLAOdv8ht/mVMEvgK5afYc20BdH0fbBkPpT/y1rRVDUDOFOlqY6LzRb30c3Zl/XdnKs9qwZIlBYOfU+KwtERjEKbZmPFJWqWp8uW2/tTyn/TXZHmikrYS9WhHDXdq+fKdi6XvnmEXFmTt5dTX/ph9BSDkb/gmQD/IKreaAwHZolq7jZJ2YR3np0MOo82DotaxN5WqASk7NgnzAuKey6Hw8p2ZPgI/bMoamna2LRzQBl4vnj79Nus7L6A29VDbrd4YAdYyNcRpEsPCAibi5Evlz	LkPPDj7+Q8vfIvf07pqEDLEIXeXGHigwiVCMzC+eGD4xMZbnLCcah8Q3PwFdjAiaf28rOyYiRgF+xglX09X8P+wM4uQ/E7rj1YQk8zQExoyA22Ux0BaNAaxW12aHtdiM2nUk+FKGCWIbszzP75xzha+EXjTv9mxIYpTvPkxa8dKVyrCV8ZFK6jH6Em3/UkVY3eyZ2SE9Rct7uMXj5uJM8ki02Jr7AttuddyQvAaKfZDkaA9cByKp3Fiwy4V7CUapjqHj5gnQghzI8Co1+/6Ggu6oZJahbblVU4uH8kk/WKln2jGgsIw9xgVnKuqY0p+E
5c6c611876ddfd3f128a4bc79219ce75add68653a4dd5db61c2b536d082c6103	m/0/1	p3flVFXfLkDKta9x16Gi5D5mpcIhMesP587bevEwJmA1XzNuasRUpcpjfNPadK22ZzOjsKybUDOEyAzrZLAhyw4CRRhD7Toa5nKzivo4FUHmgfLD5+CV8mk/pEktUVW67uMjVf1tzkTyem79BqrthOH8h1IyX87d05H9TtJqJoGvXVXBZDMt+xbhK+C2Fxp7bKVm6xomz71yCwP3p1WRFgLcBSKk3b/I/8I1dW7HIk5dC4CD/s1opN5KMY0PMgMR4cw9B2Zsi/S7Xzwtv6HItSQ0YpPGK3PLvvtjdkZKjGxDmiv38CsjA3YPU7aK2aPH	5Asw7yZmrEcEIxDzJCH1VFYC5SzLmiO6BG/3FzyO3SgcRcoLsb8fVVjacAtHKrZNju+GR62lcUmUQQ7qaRZWeLal8n9zoNzV6xPmiCGR/edUfqy1WWhmhzVqt6CXlMrtqLT++IVLgdtoa6A0uTwP+NXVnEvSgKsB9iK2AaKVSxcp3CkhY7UcQ2YVf/QAS0rgQV7Lsbb+8ymVrPjHlYNTN+4cWaA1ZwE+pg3hEalQhnPpe/Vu6jIQRH4gNH+3Fz5o4GL6IFG/zXhuSaruL7AIwggJXfi5oyV9BxYqhdRLRilzOk+1IHVEoUhFi+82iMky
3dc8e60592e1fd4d430ac77eb3a0cfff91405e6652051256c87adde0943d66bc	m/0/0	qvaviPuJU5iMYP4Uc5OVemAyEnd9GPuIYKyUxxNvFxmtIfNKXn8sEC0R12obpREgA3XPUJoVlDmnaFMyzkfQ2UjY5Ot1+e+z6mpHxY12Wxack8JA5pj2KcnDaA73r0gh+iprnj4O6PCopJw5qjDu8vR67PZ3U1DDOVxkSqnRFY0+mFgxU9X8XmaoyfkMTcLec5ytE6pOsL0+dkTKvk4HsfDy/jKDYul2dfPOOY4LYldlcPT0Z45O3JKsaqLeGmeL9675BAJ4yJUZn/ClS5g6WN49XmOfKLY4WoHlcTV/97lIZh8JoRAXOUQHdEh5oXyP	LrE/CuUlClU5TAgTqad65I6eT1xGPkpH5bQIpN88ObPoFnSznGHI4RMv9CleCeROAhz8m8+vDUEs8Fzp9n9mJ9kHTM5ZpPmUl7QZ9qThCKKZ9Fi+a/4kmjJhKtPkzpdxF9zF+zKsO4N5f+K11qh8HJ7KJel+K/UV4dlTjomQK1dza9q6nduz9aYkbHh5X66gfQoKR585x2NdgQEDuS965eypgUfKT3ZlBDQcnd9zApSJJ7cEST1Coz3/mx6KUIaGIXs7tQTYb1xS2ED4MRM17JJfe8yRPBrCZflNk46hNFeKU1mwYId8xLMA5bYae4S3
3dc8e60592e1fd4d430ac77eb3a0cfff91405e6652051256c87adde0943d66bc	m/0/1	O3IKVtNoYHArbRoOcWnN1wUFfuYjs/xHvNMlPMzrppB4cYrwnyf/tpY1idXVcFpAu6H3gM5LclpN7+qHxg2bl3liTuwyyvj8Sa2tfNX7pLnkv0IycdYcFo9scfitW7e/BMkP7sXs/pwTVwVkGAY/+k6Np1j8adyFJxnMyOU3lDLwbtnGpNmedwmOiJ2PO2gpKPEI02BO86f1wE9H9BQWnfpFxZn9MAdE7X28Ld5NG9B72Hi1MAtkbgQ0u/7gbvmKKEgkikxB1+7C3bE/Augqm0sa01QJuCX86NJSuUBHX3tYoCXExQ7ahYdzzL6z+7RY	m9+9LojSJlKriw77ssZIAPeon8Z1g9z/9Z81Vow6wXImxfqWwDHDwlFBN9WHsSMo/GnClxxcYxY79vFSmxmtyOmTv7wwgS1EoA1U4oXhwkKqe6ciVjTA9xfhNUsx2CcKYyvSM1qoSH8Bo2j1ftt9X24Kc8oHbSgMYbQr4LdZVQ4BcNuFYSSsTwnzTjqNYdQF2azQ3tQ/xGNLijFt5wLWDtNnEnEUk/q4Cuv72xBdtgbt+ElYpvq6SjR4q0xSXHIExbGa6P4zWFvDUE4UeQTGnrzVIRjU8rBZe6qx8i8I/jH0ZaU1Uc8dHrVaCV3vLC/S
873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	m/0/0	BssUnCzW0Wbq1xBK8c4eCcXepv+8mNx5x9nH7WgFb0qdsJTBGxSds35WtVEEAN60o8UDIN/GTvBKXPk0v9nhrvcLjSkFicQ5ySKAN8KaW2w3nlfLI8dexA3E65hVBaDtaGW97DArvVF1d8TpJRCKrmUN/bceVzHLoEOnwEC3tMzOFJvEj/UqfjM8CX9qtJkvDA0NK7FzN2KB/145ODF1SNAd+GX/isURIynabHkXLL4o7VPc6/W2XtWwDC/gTY6alIaFvht6fG1CaYSy9z7tazMULKpI8f9eCBkZP71vnYgKc/WnLhcqZtePRA0RqldW	6GvEJIj3GXdBm0XtyI9tRohNXMidoosVgAhHFCzCI4Lszr9un3UhliFYpE/6N1ZUSkyXIGAn5G92R/vBdkMhhqtqn4DhTyvX6tXp9PowuRW4L62AscCQ3jr1yHPh/TG14D47xPAkQCbSEpkvzE4BedYD0PMh1ChrlXHycP4A699Qo9kxNlJFn4Hiujde/CTAMbmqWT42S8ioEQXKEJyMdmARIM1QcXKZhtx4a9KErF1HbrnjVhaqyqAyF53Huw7obMPACjHR9K0wr0qq7R22ylUATgQidh5mFK3kZGJ8b93jiVPHDt0fuyzRnPLt53bV
873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	m/0/1	+dx+FVO4LlsmEkHHfjnT96x4PFMOABGQzZ5YFEBdeM2DusmQSxluBaY3tV2+/FtAnbKp8+pranj32K3plkX3Ezf0jbrD8HQTQ0amDElSlf+XdsbnRSbDGvKRqbvGCP27nnl/4eycrJMepui4HKd0IvonBg1GtlTsbeb3+u5MwMANlLrBp0cW2cvvEi/y3fMwEXnn27KlL2xBFAR23NQy5tzY6j9jMgOrDPfnYqHAYR1Fz8Y+lLYKR/WHdMicGOWoW3I7+Ue24zvvkZxTPjYJWxaxQyOUV7Qs+FZBn/SQdb7AyKPJoS4WwE8QSjS9ou77	ubmVGG/NNIMShBEDAdthFY38fkNA6hKvAqQQiRmyaQh02LL8iJjldD/in+5Q0F7+Xi6HJTCS5ip3+PskotdrGDls4rPO6vpub8Npk1L1XFob7vHxR1h/MeNtJ3qPkxtRk3aKL9KhIY7hRIbwCqpLw8mYERgTGIbEvmSfH/I/nncxIjH24sMi37dum2/uamyqQHfBoT2d2uIeFuPRUxltc5gfxYtEXHucaydkbXoD0fajyqK2usTmws/uWgzO2uIUczkyI5s+aUFLvPZNEizyaJnGeUnDTBvwOcTcGNoAabK9BgN8NeufHppIvuOANTcn
1b70ecebc36f3c185d22fb87f3c192917e5d84151f6072d82fa6564254e30211	m/0/0	CGQMC3oFNkY2pe+SWBWs4nZoZnz2cGbsWmsx3d0X+ncdCytyZOIghefBNPZ5cPzbGimqbHz3PIWHvqOlidZoMpmiP6ISRLd8UGAF6w7HFu3sLLbHqheIP88WIxpM0ZvSiM63TXmhZhFimLsGOBLNvgEwx/c3GLiQKzHKHGrX4IJoCj2jJvpwKa/kRrYIZ8QzFIpTdPaABV0ZNPeJrpA3X0zRRxGcK0jrK8KKJLCrmfBJHBMRvEuXO6kUxRmP2hPlVteWUJJVIJJlK0WW90vyPuMU0TXPy5k/DeegSjkZ0vTJ6ZbLzRj6daoqOwtWG2T5	0cnWdRdG//7ISaTazUy2vb8hARky++JjYphTvt3KSRflhcP2AiNuGviak54dNOHdyiZ0ACWc2NR37FJ3sUt+cClftL5JHylSn5Mhc6TKQm6sFLKxQ59WeO1jMRti21fhcukbDZyEo/pwXMM7HuRRy4D05Rbh4pZrsXrOKgrDHyoK3SFNsK/UGvoCnSh9zR6TOTbVzvH5dEXkxUjelgYxsULzDGZazs7MW4XzdD2NkYEMCBz9bI8sXdsu8xZZK//3rRq8VgIkVGNvS3w2IEVdfffxk8/K0DC+BWXmMINiKQ0QJ43w0eG60z6tpA3Zx/eN
1b70ecebc36f3c185d22fb87f3c192917e5d84151f6072d82fa6564254e30211	m/0/1	KEve7RPqhvYd7TxvZ99EKgdbqu7WBmO7jWlYPSIr/DwrAP5jt2YE0S4zl/2bqLXBeMAuJpnYXUBxATdT64SCKYVlCA+TS+du5mTDoh+w6K1sJRQVPZMy4gAXYnzqXesexRyLaxK1z35RoC6+Uh0ke0pqMpXwO2qtKJoWiAwjjzZaHMP3x0zWWsGn2AV5zUiWMm2aCH9xfABJkgnbJX49p9WWX/xdPTM7S2Az4rLPvAfm/y42Zo8L4Smgxk47Qw4Ul80gQeGfAwrZF5CRzg35h+Y6NQtunsa/QXgc3/uNUrYZtAbYU+x7xcve4J++gOmN	UVseF8Gn2XOxv+MoIkNnqfvwvJjU4pzNJKGwGECmm+cmqzwUWTlsLH8efUk235mCtWRGJw46ElrxXX2Mc0F3C6h84MUVi9/D9FM3yGkDsKqe66h6c5uefAdvq05QD3RMTvnl8rj+jGFh7bh3QJKspZYAJLtZl0BGjyik59iZ4pu39/yNpD2YuZqC9YfojzpbIdROG7NzOF2uOaErS5aAl0IrwU5eWppOt01ed44u0BmkTIpMm7BwrpKJohjBVS63sBNdrg0N1/JJ+obSTT7z9fBPUAG5gAHgx91OQRdd9lrOjSiRZZCWJkDhIUPbbTp3
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/0	gDVgfhVSN3goHe4xSVxHmWXRd/KKxWqt+G0EhjpPCxYSYgFM/ePLP25McRTjYtxeEr8a0hylQjjVqmn5DuuU+D35mj25wm7DXfEheRt3FLeoc21sp8lHqERO16mGn6yWQP2XnFWx+83yWYv/NqSk0tWlfVjyQsnAHwGhi9vehQKKnHI0d0yQhRzLK6BE4NucnQOG7vPObFb48V7NbfY2lU9ZaHox2k4UDvS1eBynziZS4FSA3SSP7H0H+d6QvGYIrwbC+uTAWwlyaVJmotX2gd7jAXw81PX18u9UlSA5f3dqWShTHWvkO48XDf53mGX5	e6PPp6jz5Hvnb26Efp7T0vo1HrkfLj4HqClXkZa6OGcTKqDZwOrbBLeJ9k3IebrYBHGYuao5qy3jFWgkdOV0uoTKtPwL35SqoT4UnXza4hLEGEriKRVRz7OMN/EITaq+26zkTAOLEsgllVTYjhHn67AkvuHlkhX3KN0al3XroJx/Qy7iPB/WDSb75KmlTf7jjQIoB6AG4v1bFDigAKM5We/OB47rSMIUGtm2o3oXuxatcHAymhulWtraEzBXdWxqq5UzMG3LvwGDKUVY+jEue/jlvrwykA+vvALywTGhdHOr1ddx2Wrp4sXg1WrlXSDT
7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	m/0/1	wsMN2S8STIQNEZY5XExwG6h+Zj1CuaR0pukRbSYFOgOzTAMe6AB3Otn9P9FkX9h1pyhGU72YPZdDk1zaKRxuPwqzfO98NfYf32WzI0OM0WmWAfc1bZY3loI/BpZ+iBntTY+c5K2xEQckroLhQzvrnhA7TEvnXzvb5tl1z67DE5+HIf3jgiRJykh82QYh7ZNTMGGiapPt4QiOT2ChEGx4mDzTIr1QSiyw0bV+Noa3s2AuwSJ59kMQehEPPe3iJisvBe/n6k+rs5DmnlueZYZuH/GAwT3tVca+KY8A2kPv28OGKRscXbnZT3A08pUjtyWM	Fo4HCl5akxzjyn5w1J74nrvIV2i8LQWomda78tOdEuCF74clwH3/p09TXAI406oUSy6qfyVoR5soeIrRBpOwhRCc5IqrpyQGULsO62R3xBUu36eW4uqaq8BpvOXDKU7YTw/frpP3YXzzzGOjdF0QrD0r42v24z9bDxLQVfn6NA26RGQa+x5EBF6xQbnYE0anE6MaMiiuYgqqZVhvowGABn8LG63r4sCoXyT4YQnsPDXPKoV5cduYjWy4o8UgVcq/NxWFa0WdmLKMCzdD3FFxn4NlIZ1rGVRk/bPHMqLMCoBHmS/CofnZYUGWTZ3pzPVx
21fb3f5fb6a0c9a5e6404719057b366699f0be59ba1e37f7d936ef6a2ce7926d	m/0/0	rEtGssTHZb6GMTaw/AyszWNSku+yFmnjp5u576Ndt/6WEzv+Y/MoIs+8houR19fTX+BGR6j3PHBsQHD7w8cWiNSD5img6zPKDJWqMW8ywa3XDpEo6HvKqz/c3qonc1qp2UEMLEaHMzFJBjwpXSDJ6Qq81cz5Wi7lY3pM0SS37aqmL6OUqQm63PNGRniCWXXrK8ofmziPqaoULnlRPBb2cLMfmT2WU5mHZCm2oTkjBA2nrdr6AvJL9+gYc/tp9zxLdabHHI+vPYf4c0k7r/Kgs6pov4ApRKrOiLfbPwTypoVYBeTnlhvaLeDJIcTtJUB4	DHjoXBdWZYvF56VTFBBS24UeWfFEK5tte7PpC+wDK1IY1lD0fA1q6NExSBPsqg7xODMzFuzVE9SaHSEfBnPLbT2AY7jTcT63gkDwN3dp9JpmfGQq7stvZGew/CE6TSb5xMDpKEAWYhftMrZPa4sPs1JNivXF6mGhMIYh5Fvy0RwzUH7AR6vjkZWUgXftzx8rOiieIwH0kEKXHMrOn1lRB3u7WkqK8Q4RAcUDTzJhkV5rhezrHq65VF9+0nB/4xG3rZuM92XGIRgWz+elaY1CzJJGrk+HtutOSkU/23UFOa3mskhq/SkDdwCpyxq4AYYJ
21fb3f5fb6a0c9a5e6404719057b366699f0be59ba1e37f7d936ef6a2ce7926d	m/0/1	x3EPsu0khsNMIcVbrC29TJ7/5yQcpt2JWIzu7ZAUjHB3nxhNFzYhzkP7rpP+BYh/VS6K6I1hIJJUkhs5vWxDWyuPI1+ifaeXjaBcKzCtgEBVVeoZrKM6Bm268fTXonkz5psztL1Ii7txBIfL9COnIVkhqRAcUiesucTC12eQ1hJnTFH6Hwax2ciYcwBMLKbP1+XN0uZHrM+r0Fq6dpSF5rG//qhR+YD7ur/V3/cnXT/zs8PYyaps/lHxPJbVEjwWRD67i8y+bQhN8TLPbaolB20+XWMBXbyKDYWNZLbs+MChQgGejd9RMYJxFRzVPIh9	YkvAzfs0Uo7WQpsfc0W9SpiIR7NkRV3WWnfXPTSphvSfiK+4zSBMRJCv1Oa1ROxsnxJ8TyR0MfNz5gRzuNWTPWCqJHy5SPCOZQPVV1nICsl3RZPSMgohzBCg7WSlpBG3o4EBjS0ZiVZwCskbLqTij/tajY9iARjlwVpcu8/Jdswpk6IMa8G4bzuTzTjf2rEf88qEpf8oaNzNUOLgE/Oqu/N58IBjWy1AgDnmwtDxQdpRWZaRsh5RmSSkvF2njvggQ1GN5NAbUiL1m51hLGjvThKAG8reQNqaiGBO+9eEIVMOAVVRx5vH+izntZgl/u0S
1be888d0f72e1dd4cf9830224618251944a749be1760835da9da7c22bae70c11	m/0/0	1kqiEjZ8wI8gqFXJeKRkYp0aOBug02WDCFZNQUj6q2IOcB1ceXV2cBq5o3nx572se4Ji0780NS5wjcBSwlC+VebkJj9FwfgW6Wa+jl8lHnT2nQyY6bxMliEREERhbKKDgsfXVnbR25DYgRzap8Dh5cOQOsLsWblv8VRLYYhOKlr/FZWYhs5xxJO6kNBJbn5C7ggsUGdGo61Fy2MX4xch+NMzZSuQm34w7mVuob4fMPYhIK7aHvzPKVgTOuLL35Dk7PPmXoLkce1BwLrD3AKSeBAWnbKyeMjU7zyjtQ9htEXJDIT8zPG2E2C6ruPSMDTQ	ZfvVwDfAZitWlB/cWydhVpqM+G9ZRkAxlg6M0JhpjaFf7AREBgZy5VwHI6N/FLjYQmdmvslsjcayASb//FxfJX+frDwgXVa4CQVdVN3ERykyxyqHHvE/olBVg5Sg067bjOZqVTt/68BNrrEFlB84/eFWWn7WyL42ouSjMrMq1wYaVBCDLhE9Mpktr06evcOT2k2pPAyEmRFx4aG0G41NDwCtWorHEQA2zI9D8aPSaRa4j+qHWAhu7aYtepNUmtizusog6hnOJWWNjbMlO97Ywt5jN6hzHv1chuhU2TxpEIUFHls9qkQyWgGakOXvRMj9
1be888d0f72e1dd4cf9830224618251944a749be1760835da9da7c22bae70c11	m/0/1	r5gWOf0Vi9B3oPqarwtqK8jxmsi7sHzn2OkLGwjZfdsix1l3rAAmTGZU4+R32IFnVrrLkP+w8Gwp02R/NGBIzhikCMi9VnWOfqF4w2jnKCJ6eOYlvYsGD5QGaaO0bT/xtaPY8NDfT6+jOCFx2us4cKZKP1zFq3ZEgPnJJ+PUtKiRM0W/BQImTeRgUKSdizHZMdiUbaxpjnLZFwoW+IT1l4yIyNM92JAr21YuLsFJ4nLtZFkBNYa3ayoAwV8WDBTJ6K+aeXSO7IWfv/xsatlYCq2B3lhWommYf0gSd/C+FyAW4gW7VimG2ebOGL2ryzeA	dOxs2HRb+lzrbxNC89CiTPRV6XjW3Ume0pqI7ESdkkJWpXUlvqX23T7MsTc6ufZhx++BiNH9Trp3+3CI2EqmFO3hTBvZbZclSn9Y7PpcT56fBFfa39GS0iGpmpo0zK7n15hvNCjlv534rr2kH5YKbsp608txXyFpO1NFauEwAs1vgBBK9ObrMhhdZw7uu33Ujo1bu4wPv187kQeQ3v31ZTPlYv6flpb08OBpjQ9EGaSawD7xpUiUpHGAJhmXXw5Jc/3y++h36DzhW5VjA+E8PriJYrcZi/sA5Pw1zPHSYmS0GtKVSNXyj+Pp5tGymTIb
2c9fcb17f3e35a5d2c17ac695b7d6b331f6b2220693ee524b8b202ba0ace358e	m/0/0	+Au+yDVOX3Nfn7RGmPGFIii6cjO3+SYj8xB4IfA0ROQu32C7ITlSmd8hHQUGQIEBp9PGWy5PwTQOtDMtQBg6iZOmI8z1ZepvhPeW7JkH4uxaBBaTsgK4oeSCfcJHfIBjut32gkW8Fe+CaCKsKQnBeuLyTdblf1D4k4czNIA0w6K0Bu/OxvBdY0WVu141CluhfOBJPrJm1vlJDbNBhaWeTiIm5u5IoTN0LSMmX2qdgO0aenavEl3LGKXcvfL3RRz8C3biphjfIcXZ2dGNN/gxKktmTGJeh9gYWKapjBuVSVL1sMOmna78nvgohj4eR0ec	XC3fQrb4unq4JyIlrXd9U7mQ3SwkqRrWjMYYMLGuNXROsFBEdMeDlRmYZFbrnn7MNDZ3gkggyxpZiA5uuhRO+Fvdwararp5opo1m0QA0MPLGklDRur8vcbZ7rx3KYXjF/BGqKSJx7g1HJu3fSYjHu6HDeLKq4dKGh922xHYySiUvjQ0WQKzYO82afC8E9plhwCa4ou1oaZLZ+AlHY5OLNdNf8u94IQQLnRoE4uH9ZQ5pVQ2NgIO/P0NkpTS/ZHLmjaZQWr1dzfqSb6jzwXFj6BPe2x7ifclCCgzNe/kfpG+jSkTG+aoTTWe6tLtq18QG
2c9fcb17f3e35a5d2c17ac695b7d6b331f6b2220693ee524b8b202ba0ace358e	m/0/1	fIVqmJQDwdH5mUnIpQY2EH8+3DaAT3Sa/g9s0mdHmffhX13lgdNchmQjG8EKsOm3OBCYOlnqXBjJh5490ba/MUcOW/yRyMYSGd+SUXnRNE6KS5RNbl/245GOET8I8CZCNibGHfCMeTB6HDcY5v+M6ZxscEfjDo4jkEFCCA77VDBU1wOvPEYWW2IXJpLADGsROgn1GmJlwU2I43Ha1yfltc7FEBo26iMz8oFQ2zh71PQ5OOw73eipAEUOPbmHMR7SvZGPoey3StAGXkqofNDqpveIk2xVwLpIrtmGk65XWMCwUsAbcBDBZtnBF+EZKQuf	RZbE+RsB1xSzyxf3y5MOH55qsdbK4mSD899xPY1UCRX2KZlsGDfK+/Coq6X99+nMKSmDi0yr3Fbg4IqzmCOyXPcrb1IaRidnKqe7VT0ES2sKF3Sxtg8Yso7Wd7MgZEmyHpnh8yEwcW6x84sa2LTwjI6ZbPSzvIULHk/FxmBdD2rexjgBuM+mjQqcA27frTdVF/JhbAx6/gGOXnK73GJogsHyNOOz3LGZlynV587gEVx73NNG0JHHauslEcL+by5qXc8RD+L9PCoF9wv2Zrr9Cb86/XEReu/jIR0+gFsIzZDm5qz4UEWIShCif96k6X76
1b40f08fd133ac1c9e745de021bc15f880b58aeb13b3ebc908a42cd4141767e6	m/0/0	ZcSGPZsQDV9oB8o/nO0fIcoCTljVZvs4T2aTzr79wtENNcQximTxCSx1B2qDjv0nGWJnQHVLtpj/Hh9C7Xfhr5xWcbWkNUK8lI3e/kvhY2jDJptnNLjQE8ekcsAohEQTBIScQdQUPFteOSzyw5xAvJYqCq5E8X0hKQ2rdcKcvE256FHCEZv6NmwoU9Y4pNde2V7JCc2EL459PZmS7V0uI85Px6XolS8WauR2l90ikpQPavzhoH8s1tcm4jbrvG0j8fPiYf9bvDQ/aNzJmUH2UqKsBrtxIoh+VrIope0msyjybvRxI41LN02zVts4zDEa	de8MzVu3vPxTTxQr+VoK8QBMUHEw++Y1ENWUOf4cWS83DtzJZTaOcW8ne0id/qtCIVgbJ9mqpfFaTAdzQrGHHbjJM0jTpXHCeea2/UgEPB07k5l5gpRctvqR8JpqTLu2dvwxvzdIdpAzXiqGsbVvxWBCKvlU2eqPqX4ZUfw6D3o2C9r5HU0s+2vVKYQlYdMtFSgz8GTlbBp7l3oJXWFXCpfFGO3mgKbCI2dHqBecsjMz8pRmGEykSDmSurYdFPkaD8q8NxUgrpqpoj1CfMc95UM95IApnWu1de/OSRXRxRFOK7VE5RhkFkCsVBsvsvfs
1b40f08fd133ac1c9e745de021bc15f880b58aeb13b3ebc908a42cd4141767e6	m/0/1	iJP70fK8m1ECOQ3cwhOIGb4qhBs1cjhlQqkedkl5Xl342GDeZEb/cgVGX/bZEBJnhryRjHaiD4aoPmz1XsepxN+dbKoLD0q2J5mMfzS8Yzl9M5L93TKibjM1QJCmyfYkBh/UprfW5JxrnX/SGoKpSukPz9v4o70CgivgCMfHeys2zw6JIP+ZA2VOEsRusnVB7HpfR/ZAVDV2gXR19npCpL9v0nQWKZM3WbRwx7x9HTyWWMQhR99gCsbFfcb1p57xsRjtgcBWxEOagZ1yT3YEupHs6PpDd/aPqEVw1kZ6wrRVXtcpUcZlY5OCnSSuaQpE	vUJ6wCe9fzW4KRjm7uTjNAg4OOci/IVFnBOhH7CExNW9hTSJD0eguRtSfoLCLG6KgST0AWjYZ2Bc7zK1pBkbPEPcmBX0mejhTxufg0C1H6J2MQiHTlFEfbEhhLLg3NYv4s22AIRh85g6QWIqmNJNJYiYcdnXbp5q21x2QdRkXGzUQbOw3L0q2n8eLj7iKKjhu6flmf2lPmKBTOnDfQHD4lDAHfLYRVjOMHVFgpeUHvWdZfizf2QcS640vYtyHFtJO3hUsj0X1Fj/le8qhQt/wVDc7E6H7+m7qIcTv12x2dE00Hx3GBjRS1B4SgUeDKDf
6b3a29cfe7ac1554621493d4971db7abc2f75e3c859d2715ec362058a9c9c3ff	m/0/0	Uuju9lQjrRMu6VfXWbEK0QzGftbOm+dO+XEkWYkNL8rmOAnNGD9VWRwkxsbe6zYWrB0bEjofRnDffRQtanE4QrBe9mHrrY3XzcbFd7OGZZa5VWdm3pZYeWnmH9LPOZvyhjdoVWMDicHA1wjOjB6cjob0/FbbntjzDc5aFDSOGkXyDXSMdPmntFU/f0wjhCXJbxhvq1nBjuFTt9FdK+sI5VC0+IJI9FznbkNe8r3FlEpameMcEzGcITZWeXdCPJHuOezI5jSRbXMJbwPCi+kQxWbqy/yWjTLoSBYeSDanGP8tk7XxZ4skeiEVGKuJDOgw	jWOv56fdOVgCx3Kir6ByZSefD7aQ+E0wAixhZ8ZAHNPtN6o82z5Zzf64EhT3SgEfguOjSf6eyHOwMYtcoJZeDvqaMJUPjZElsixoKSg2jucA3OLbaug32ajhp6TQgy0G5DGnvLrJt3KMmW9LMvkJY/uvtVl7DpOUk3meOv/BaZknlw8lo3psUYRt1mdgk3I401pH6dudRF4gHlH//kV7trh/jcZdewdjUuE9rbwVHWLeAxXpSTBFl64dSM6zA6PrMOw/SteMKU6pMiNy9k00iDe6qWafXpysuIYi9sjNypWr3AVurDqX1W3VGzAvgmfn
6b3a29cfe7ac1554621493d4971db7abc2f75e3c859d2715ec362058a9c9c3ff	m/0/1	dasOKW2bgV4bdEdhW6lYkl8k6idErshI9vAtBzbSa4BXZq0rg/vpIVRAWs1HI89SLclNyp5sUQ+IM9cqVu1mPDUxxo5eqqWpq7IsKBwa40iywRcqv3XhyBHe5ADd+P0cUjrjKcidG/ItA2lax5CyPmr+9CK6CtMtu0YhA8l0/dz5dF8PEyH0lt/bFqOyGG9Tv2yPq/qeve8eXtcV+SjvIeHtVCK6+7VfR1x0mXOUojn1lVTzaEHvwwi41suqAwKmZsoRohwGyAft1cZm6VlWEibkdqkXIo/6TKJy9CB+oPXrYTrrKlVle40QsPJbVL5O	O6Z5nlL8nieiv137fVh++g33tF2eBaX1wbPjKNRBd28zrbQVHL+S8dUuSlwj1FYNDigApAYcOXME00XJPal5W4hv+A5U2KTv4BTsTKut1kxH0M5sJqXPGEszdvz8lRnoAS4aAmaoh6hX+W1lDXWBMoPX9E+h2lKr3nXKEBM8JodhMuFzWCikCYAgMzkz95nJeh5x+8dJMUARpb5NtR/HjGKX/V9iqV1NESaO5Vy7w41YSzGVsco7G9pqjkNmzjuLwccPk9qmk1PzxDh4OBeIEEkV6/mBLnuaJuoQUOS7IeRBLG0lFHl/Jhsd3wqb1ao8
ad7025c7040d1bf11df14afa54bac054c8fa37362d61f6dbee50605aa2ea801d	m/0/0	9U2qjsYWBn22/SM9GW3nZCnLMdfMG9hXHdzOMCPQwAm5MddIXp2sl79cJQ2YZtiPW5TAhvDgAgvDm9sTuP97qTQCU44f4pR+HP7WN5SX9QO9THgOkAYtfmCfc8H+VZjkAaKCSweQuw4n3Gs+t8mGFbsOLvq9VtuuhPxPhxU43ekVplysFeN0BLMEXTxFcXCODLZWfA0ZsnmWSaUTcoT6c/wpdbMA7wS+RehAfcYkNV0F7MgXgUhIA9sbOsSKtLSn4UveexuizfKuwmoudrgWmfXCu4GMrB4Gjxx5cYtGFW03RT8AnkfoEe7R0/e4K1WA	rciN5pGKXG4uNd/Lk8XlVoIkkEDCIeycAEiHknmoGVTgi8b5Rjk1za5jV5F26b9Tm2poAZalk0IlJcwVjxxPjNMlKZeLYyReCWXTOW0VarxywVH/Bi1ENmuwdXQY+z5E9ztV9GC3+6mYNnBLZSeRJhhkRRDXRG0pzoMA0N+8al/a8oO987ajwY5lNJjYbKoyGKL4c+xUMBgUnwjKoVGh93oPvB2H1ka4GdZM/plEjswxtsK68zSGr4DlulfOgK5eYiuo7aXY3na7IWbBN0V0bIZklSKwfkcnZEhTayD0nfhcTVQ9CSEJ11UTIgkCRjFy
ad7025c7040d1bf11df14afa54bac054c8fa37362d61f6dbee50605aa2ea801d	m/0/1	F+n0qUxLBy1Cooi0uQl1BaZnOFaS54w9j4z7558zLYCOQKdTJ+CbROWGFEWaMxyZr1SJ/DqlfYRJzwxXKDQ94szUgQR5fNm2AvV817zohriqDLSkRyWLHNQ7VT3MSbnf+7jdOgZMRFdDDxmceu/J29fSvY0PuRUfTc4o7Iha8r0/QIFZnSUlRCot5/Ifm0OOQyH8p6BPCJubn5P88zTT8jNtECnrM0GwutEJLrWMHT3ENWGcD5tiJR4ciBOx2znCTR/lUCGFa8/rT+qsigHEBp9EcbiAXDhVpV2QGPAyTu0Ca+CjoSlm52T+2fDEdwsQ	8XwzK6wtJOD7HojU1LWf7UQqOqeEkt+3F1Pw4CEb9T+mnNTwvutFGisArya0ztnn3zwTlWHaC2eH77LDDA03eU2Rk1PuURlQW7b2B41phdafoLdXtzSFa2qbqisQCtkSrbby4QJ4rHR1gWzTDpGISyi2+P4j1UwJ9CmpR6f68M1L8a+3qeI5fKJk5YG7vdZuh4qX7aKoEMlLSIWM9NNwo6IXK//nkmlSO1hXbOM+fsftF5frgYBCGFMOWDhjjV3dpxYZewT9lbG5pHAINKZVYgeEVcnwjuk/vaAifE0GJNoWQnD2KYBWq10KnZ81vA/h
9627105a92bc0de742b59643c811781ee9fc1c10d8b7c7dbdbece3fdf55ebd17	m/0/0	PNaBBIKA/WyZpYGNaHpSZGhGJ1YI8j9hvsZbXD4TqELOIRkzHNpDD+KV4jXQ134iQL4hoygakfocZ1dWV8JXGVGyuBGI7xEyV6bO1vDT/d9TReD0C4mwlWU932tN25FmkBEDzrBFAaaP5au0E44Nm2EARdVSbsFudqkYwi8jkohAzQk1FT/LUAYBZjjvPBaoREFQrm+geSntlthV7zdpHRCG5Xo57LLiebXGLyYw1sTwY4/AuByTnUr9UCy7C96JQcr04Bc5j8ACzl6j/wCk5xTeclyuUW1NMLDwBBInqgPzCCdWTmUMO9H1K2suYjB2	w75tXcqJcNBcJYtJ04b9P5MdAkYHn8EWrmzhXN4zw4lf4dCPhn2nOPBI5JVOZk0hMXnHUjxeAlMT5OANi2IuNdK5Z1axz//5IOjFymtouZqyuaoTqccw5EFo23FDaepQzTIEVWeCpBHbkei2hciKREeUh8oWmzmc/5Fne5Rz0xaVRUGglnhy9+j6ze7Kd0X+5FNKlposxcUBmTXl1XB7wjnu8bahMn3/l5FxllocVSfO2i/NWZ+JUrE1ildLzpJz5klw/LSRONYSdHUvDoTc0K+QZ5nq5V2ODewHP2sRYJzxVVFArhB7GJQFfUA8dHEK
9627105a92bc0de742b59643c811781ee9fc1c10d8b7c7dbdbece3fdf55ebd17	m/0/1	V5Irj1A3BUj+qtRgktvbENpB6iXhQQeDZJcRtNM23hFEaGuo4VL+C7JK/o6Sa2BQbE7ycNcddCQclWblp2w6aiQceULYJbqwIbLUHBN8mhA8z9eDMGCUewzUcWxRqjKS7r237WEZ/+EIGFXh4b+OJjwKkvzB/mtqbhjxAVPSWNSKMRnCBbS4s5esrUria9vEsJ10V5pza0zXcI1g5dsOGDMhGgOaQ02HDQ+l+JPkHx+yGBk3tka6Oq4CfigEX2RWCZWX48EhgQImHUWiPLITjbP59SCVnksRemUyLZNbaMHwT43kZJUgmcQ8VAbd2yK4	Zf0Xm5qL8QxzzIHG4cN6pNw8v2e4uJRn5mvGc9xaQsq1QGdJTIZ2rgugbjsYmSLsGjb/D32ixgBNVNdk+6/GJ4z8Hg+1hc9u5G9OgJ3fA+t9VbpexqNXPmVXqWkL5xBw7MKkyHY5FopYxRkuK3aQ/HXS1ZUZK5vXYKoonG71hNbP/sDZE48tPvWomI1Fe3Yw5xMMe9WNCqdpRs7l/9M3N18xPopThxUL823NGmSY1aGuDyaIrnk+hCFIJ6HUjHznyZlqpu6TiuwiV8OMoV2W1X6K8ybpkXsxR39krPAuqCNQfExhHMRRWhm/pS2zAue+
8361b4d1cb16d9ba6b4f6a430c33009b37d23610f4023ba450ee0240c6d55bbe	m/0/0	FRPfGq+eZdxbnzptnRy3Wbhco/eE4JvE89Nx7TNHmR+hKG53pQGMVNXtNAc2/wMYBOcyTt9u2QPkDT/O9GSVFWc6ijjf9YmL7A1wIwzjxSNCTGwkoBLJUV0KAzp2uJtQXOnX16TneAiiThlEEID8gfUMeavNdV6gxY5+bF4qDCyOdH/piIoVE+7Qd4rf9S/zmui3LpcD1ypZ3qnhu1e8HH0UY1sHD5EoH4OGqPPWFC5+l+gSFN5Unly51cv79WePknV2nUdl7fGtUw1v0rtm1xiYeyTj7fvF2rlsTBqaX+ri7LUe1dvhktF5QlWjgp5G	z1d7EzJxoqTgs8LTn8a78KGxtkkaqAe4yynMuC4Y0pd855thpE5UM9uKD1NXa/bFtwZAqGh/IOfDSL5wgaGy/K+VXGRp+BoSLSC47J1g3zTAD6d1fyiqkP9OxYlrzIsqxqZkHehUwDnCHIZm5qhLKzZ62WntFGhkvhTDCcWbI3ETPm6QbL1HegqSHXxmUgGvIbxrBIwkCyRwKjdeY01PDz+779pU58ILM6OfM0gS8FQGxF9chPplUV2K0dUwSY/sCT8drK07ThCTfm3FxChdDZ3wp0PXua5tRV5/SbjXWQX9vgPWlHTQESgwcYVkVNVu
8361b4d1cb16d9ba6b4f6a430c33009b37d23610f4023ba450ee0240c6d55bbe	m/0/1	F1mCm3pIajZoEz4H4K0KjfxfB/wzlzVvTkfk1/9lwNquijRpATABZ670FWmKMlVIkxo7K790HHzKw18M0Zso7ciKuS7KiGdGlIAXk5Lj66oid2XtfTp/5yvReFYH6t4UYjN0X9WwN5YFGrSwrbY8A9O5ni9fwUiPqK79tXXa6LcUwaupXCgZeylnZ0cEKogCpwFKqwTDiDSIkNr7rIWuiSoQioquuw8/2TP93PSqfmIIAV0Ntl4YEkt3JX4WFHqI9sB+MiiAYtQ3pbOrXPVeXBbma85fVFQE5VsRihRyiHm1DqGw9kCHfeBsmcaTiHky	n9K93F2NkNw2hFP4tFqRCyDVIeoxw3Qo0dSSx3uhtavQuve8SvdrSUEKnnV5CUhO/GRs3JGYDzCR/a4NUIXNnwlRn9JxvFwRtZaGZuFsGPKoPxMVs/Ty+7aJSwL5+BWGLuGUBSpyf/wJMoS20tBXEOI9zV8caBNdj4+JfzufdJeNYkq/SB30e4KYuomciW6Q5KoJIS8S7c9MGC9gV0lk5n6Py5OSC4uZGL9aU+KWw0UC7Tvf7HdoQ37azuOgsE1R5hgr6aaLAyYZrE3cy69puh/eg+7b33/XY9Esb1Jq6Z7e1x4E2K+0rGgzcBDZ42+0
13f9f3b2c5e85e2e4c204d5895902e1a32fcf391daf4d8712b7ac6ec2de41d7a	m/0/0	prhXkEoQO4PYvKVV8ytlABcubOc4jgpnpO1tIaREJSOmpyTWjhJCcFE5MdWuxZmtPsb+3zWN9uWlBbEZfEAkHIKqda4F5ytM9Xr7U4vhvmlR730eb6CosidysyRw8cNycuio929ZiyNRFTC+dm3O25n/sj6LI6rs/Dcjs49OVF8NpwkXmcLNbbVrdfCwTSuVFW560dMigdKjumDtr5w8s+MiF7JJhrGQNGOAR8tpMTyZlbebWRUvPZ7DMcfLyeze5S1zKV0qqXtlV/uQbjhaPQlkbhOyUjacWds9Y4owZDMEF4x3Bzwa87UGCbIO8Be9	6dTYRPEyr7hI8nheAERZqzdUY+j4CWLvhAU08qRT9XwlA6uGf2HF2wfrNZgquQKb1Wt90fQ7ZYh+ImpkmNj4/i1afSol7VYtZILFW5Sxa5rucgKvvA35/gqM7IxxeiLMO4QcUJgGHWozc+WNpTvP+MI+x7S5+6x1PLrSgr7Im34oUwd9wax68qXbwi9w3vFuB6DlBmrLvwFFbdiedrf4w6b8qnhfBLHq+TAKXtq86L8owzWsE1Mbu9Ept8OmjY9RYMC7Zmc+9obBwwXEVxQjbsT2iDlqZuqCPh04wO0fDTUCB3Z2aXqsHFy1VfKWlPXM
13f9f3b2c5e85e2e4c204d5895902e1a32fcf391daf4d8712b7ac6ec2de41d7a	m/0/1	7Bv1bSfwvrpvWZPJQC8A39iycMkjgM7GVmqoDwV7NErHVUyWsa6zIdigVVEKmOCKUHb/zZ+aMt+el8wjj7q6oh37d3z5C4tUCsX6OuMFB4pTJjZ209ZngUVL4O2ORQFVUXYxzfwi/GH3pSHkGSwHX6KR2Vuy97PCP6Di+gvLfjB50kZWtLpQlh/Q5hwVEkwVd+9lZGSyCbvtv++KCWAojIlUE0HP8IkwU3w2pPl/qYBuqqJyTkGv02eh1cp5C9J88Z8TKu2JQgzooTQP0dAvvOV8Hav2B88N5E3Qi5E0r5/GQuZXM2z+XlIspraDHDDG	k1CWJlw0ael8KAfsg8+6bW9b90ne23Kq1UuKZHmlbCg7Ai3XZ9XLQoehB9/czNDEq0muSIVN4Vio/ycrtQGf+9yuVMgdYaoKakcIRu24pvLXDYct7ie6fIvBsE4OtG9YYH7giowOR2PK9egB0+uNkSSrJU76qxLH5nwitl8tJplYD0vnalMswIv17l9PFy6fpUheQvPD3TqIEIvjApfFoMcTPlw3f7tM9eB/EO6LBUJd3PmQHoqhueFD7WrxhRGH+HmBAdFMxKy7ZN6mcUY6/FaIO+yBzOdaL8CqxFmJYkrgUxZGScie1/HxXp0h3wfg
13f9f3b2c5e85e2e4c204d5895902e1a32fcf391daf4d8712b7ac6ec2de41d7a	m/0/1000	HsRiuRF4AuWB6lg14JlbunRN97fb951qhFfnhvfxj+Az5OV6xtFs/PG19FlA3z6CqL4jPNI/Ji4KZQGFxhgqIKh6RTB0RlMCN+GdfU5MkSnEHaH0rdYsVdjQbA7Yjl5k/JlAgfPEEAYD9SprwFOs8mtwZoJS4lJtBy0HETvWKyKd+VioJKc/1ttDOdHzIxrc6qrtgu8bfyAJQUDsRqufkHvEwM+hUVUwG7+caI2bfDGny3zQeO3vsvAvdcp4fszHIchF3sMSDh6EOIzZaAaE6wVbzSrHYP9d28vL7pPGgOt7zjFBa/fvBkovSnfBd9UC	wZdTzPYZ15ut+vf47OLxdbc7uaO/lYTjkI7/o5G1I8RIBQdElCIwNXsVa99W9A4X+/go+UBVqnLx5d5+gtNuluiPSgU0jXiUhTeHAF9j9L+rmt+mvysq+rQoUa9r2SWDDu877XbuIWkLBdeFkdgiJ4v2aedN3YnL3HVECa8znynW/mze3TYWNr3Yfn2EZoF1Tsydvv5WElDQl0Rfn2QTO1NxMl/TJQ9+jBZ80icSU+63lpLH5SsVSSbrAP3JEeq/cfU6zzByFu6HGmQTQJshkqXTS7TRtWzLMiteF9rZJ3xkofZn9gRMVhruu4WUIYEP
8361b4d1cb16d9ba6b4f6a430c33009b37d23610f4023ba450ee0240c6d55bbe	m/0/1000	b3ZVYX8Zq73BH/EWnHfL61CvqKL9hx2cha5I3vlr+mMuZ+HetihMwc65LVJ8MNFD0ekam6CR7nuzDGO812hdk2loAESIoV2Sj/88TUwa3qCYDWO6IcDDeUJlqPrERmPLbQgWAUoAIa9OAsexHC+6bPkpQUXeeOiVTphpMxeXIV7FX4OR8XDQLDX1GTqF8/Q43+OO5Uuk5rPOIMsXbZWDVPW9O+c8dJxzlc32cYfdBZwnS4rJ88TNlCC2HIsHCBXG9R1UYAHSgAl2O+nl+4ptmCPN3Wjm8I4JEg2GVNG72SUs2qFnhfnHeydWT3jtCr/1	za41mBpdbDrthO3WYPGSwbTT6Q5Q9S2C9sIOTNbAnvSUNyx4HjNZgfblU2qBOqPJPtfHjxH5FYNFeYsQuUuA+Bnvbyl6DsvxX3aIIBoSLjP7mMiW++UDYYlz4RjXLvm5v9YCMNDRpjTD+NG4Vxd4BEFn1IBe/Hzpv1ANjXJT888t/uvY3VvcooyEGndqVAgTGh43n+yFbLc07hV7P/c5UKk35sIl3lPtt0KEyva80CR9aOzmxHmuoYUoES748xYqmZsM9H/1rWB0rjZhkiFTKpwlglJoJJdO9cl73Xn2wCKM4Y4lo6UFiL8cNzcHp8az
\.


--
-- TOC entry 2688 (class 0 OID 16525)
-- Dependencies: 204
-- Data for Name: recs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY recs (id, pk, un, em, ph, vc, iv, pkh, mpkh, createdate) FROM stdin;
2	Myn0ZXQ7zVllpsaL/g2U8vfIyTVa4LhHgrksCw6EQZ60lg6UaY/IPKOZ43Bi4nT6wlohC3ZivbIRruldRithUDvwzJk0vcvK2qTosX0trGf7fm4dOmTIGDgPHCtPhKma	shibuyashadows9095	shibuyashadows+9095@gmail.com			\N	89fa6c73f0d581afd44be2613c4ea172d33e157b209b5bef573ff5fcaa431afa5ebbd64b81a1c4932ff13c742c3af2f3d29e16e11901082a6ffccc66a870cc5d	ae399e890746452ff73a6103b1f28adfd918c3a6c0e60b4fd3025776350aa18c	2017-05-25 00:00:00
3	EguhqpD1DziGZoVtRqtqEDbijqSPYsdb3lNsjUY7Yt13URt4JBI2BB+Kp7Ps4OYjeGIDbxjIOusqJwDxsKJIiSSNMYUt0gNG4YAT4ulHR50sLriO828SwVIBOUfJuRXs	shibuyashadows9078	shibuyashadows+9078@gmail.com			\N	a9383eb737e496d063ffc48ceb4af69fcaafaf8a1ded39f1dabc95606e78452b221ea97e6d744f2db77291b7e5737b8d9182a4c6dc422a88541a0dd794acbd6b	0b92bf6e281d9594ec5f24784c91068000de3a0c9d4969be177ad7c8a508440d	2017-05-25 00:00:00
4	izmM1NPIBWSqbNjElmbFK6yyoAgPfBx+i72IvRLWSFRb5u841UTgvWhsV4HK/HA20dKDdc/s10ePu3W12+xAn5IvCijStXsnCt+2CaZUCIxicv/mxWlQERRM8rZceltn	shibuyashadows9079	shibuyashadows9079@gmail.com			\N	3a94b4ed2e1778bb9b59744f70c7ca8477d74a9eb3423409b8154ca4df4002f7a151ec335a8e4811c08d4c5f01324dc714ca6526adb68c630dcf47d5433c824f	9ac2327cf63031027dd5a969a699f47db3d688217570b571465d6c65a51e4e11	2017-05-26 00:00:00
5	B9J5rUN25yhms/6LXx+XxqpBkiOyd/EP/m2i8b+PDMKwD9IF5eoxt7Z1i+3WNmoL9ni5JazzYpkqLIUAJ1N+K+dLgqkCxKkA0nXEXt0B/il/10AxvarcSzS0MmRvm5Rb	shibuyashadows8564	shibuyashadows+8564@gmail.com			\N	f41540b90d8ec16008ff11dca0ba04eae6637e6428a401098d75d275f52b73016a71d6b4952a1f64959a241fbfeb8bff67b784c7a045c4c72f21eb27536de7f1	f27464b989e3aff9927fbfdee4dc7e6e798a4424fe254c2d9e872d8759dda01e	2017-05-26 00:00:00
6	IMHtpkVSw2gspEtAXELNFVdsnlgVSUnr/UgOosX2Oxz6/47Ge+LOU2jtXETz7YCFrhonzOxxzjkt9dnLFeFigWWl6BDYqhY4lhUZsAe970uDKPyzR+JlS6EDpuECNBGj	shibuyashadows019	shibuyashadows+019@gmail.com			\N	ef0ba1e41890b6f4ecf71c3ccb463dacd90216848402eaf0f858ba2b822fc2de817b2d4037c962e3af666e692a21f8e9e59e72cf8ec680874f04675f1bf7f80e	6d49be1954c3ed840b453d587ee4d86fe68296f761b268f9b321699e72f572e4	2017-05-26 00:00:00
7	zDstd2d5+OYtgPOD7+UtJlvSTx2GW9zkJPVoV8Pewn1mFs2etBiSVEk063oaAB8ij4mkz5IcsxA1yzJwelDltb5o+gzsSaJF1KijHWEMGorG66HfSb8DyMf25qA6+S9s	shibuyashadows823	shibuyashadows+823@gmail.com			\N	8d634fdc6515b4deb0b9be9a3c0fb1ec24504755a8d265720966b74b4df6959fa96fda46ae9157e50f1fba7a1a589e6ff8f04327e345da3ead655f5486ea9972	56887ca978ba8c47652d3bb15fcdd203fb01f218d5466ca3f869ad5c29df3211	2017-05-26 00:00:00
8	9k8dHkynL1ZxzFQBXshU7gV4b5ub0OiRFUj3TEap4g+wL+bAuZOrfNMWrRAVCaalmlQLJb9ypbFB2NG5+GVWusQDEMFWC9dl+gyVhxfLje6ac6+zF5t3maYPS1dmb4VF	shibuyashadows453	shibuyashadows+453@gmail.com			\N	a6e7f4a6a58f01de26580277ab447b9c8323e9f511d03b35210e2e6daaf64309ef1d035b88bc5b5974f94557d7f7769effff6ffa48fbc5cc2fdf46ed1d424a78	07bf06653b5c9d38d3df83fdddfe3ee02d2f071f5842723a41c8e7e79a4e1d6e	2017-05-26 00:00:00
9	J4LuBP4wPlhU7w1xe++Ywt9ySxOIH6wAY0UiCaiOhZXHnPGj1wfyuajuuZMQViSHEDuDi11G7oCHUtrhFMrWBoFFe2SJDDbAbeYR3i+Uux7Usa6gV6zPvBsHf6cqHCQK	shibuyashadows457	shibuyashadows+457@gmail.com			\N	9ca7fe776aa83376989376b2bbb5581b250e7d231dc119cefdad8309697cb61b6c7140594479b8576caeeba429f059b345bed8cdbf1f8cbd6542a4e22be639de	4ea8f608db9d05b39be24de809defd42b67fa82f4812f7abbe8853cec23b7262	2017-05-26 00:00:00
10	m5hgrZnQ6grr3J5CS4dfQbhASWY16Rb+6mLg0eDxwQFwEm+MCVH6wmpau+TCKUrMd6TrWLR9VnrW3dfQsqGqa3AJCqH9ABGfX3j/jXUb8dwq81lQcMKkKUENo5mXErzu	shibuyashadows902	shibuyashadows+902@gmail.com			\N	af4df13a74adac5f9c26bb5ddcd21261e13eb48fdbf1761b8dca12f3ddd28a2956f688d452ce0b1f3170c38de0f724676cc594cb91b56606548cc27ea3da7b9e	d18e5e4dcba570951bd522db5895a015f04b0adbeea5ef1a5349af920c58983d	2017-05-26 00:00:00
11	h5YV6V1epAHXkODrrzDOXUdaeAJ3hSh3zlss9mgM9RJmGx19FNTDCc32UBodivQL+bXfgvD00WhuX3ubp8HBDo01KqBiGTo2qlsRkEgO4wZPG8hk5cZBREZkKKHnabj7	shibuyashadows943	shibuyashadows+943@gmail.com			\N	9cfbfecb83cdcc2cc524ed95eedeb223988d508507994666dd4db79af7a9af37cdfa29932cc7223245aa3f002fcff0879cfa7cdd95a57182d7fc4e2c1f858898	d2837f054be1a9acfd431cda97ea5cf267399d248cf1a0f5c01719e850f8e2c5	2017-05-26 00:00:00
12	h90KApPaXEJc4BDjFj0qobEMisL00yBxWpMkQpOG6A527MC8QgufAplumsPlzWT/wmkcW+7XHuDWvPjHGJL4BXE/wpo+A8JuqHgXoZO2Dv5lOrGywG23/6K8o4p30PDg	shibuyashadows946	shibuyashadows+946@gmail.com			\N	d377168e4ce070426d630d4927d2b0516c2e02cbbf1c5875441c1dc5791c75d4941bf7332b4a0a4f9e629041af8a9a4d6eb46158cc1f15fcd11bd60e2a5035c4	af2a6fb298dfe59e3647672fa37047df31421bb165b1668898767f08e3a4aac9	2017-05-26 00:00:00
13	TyFiPWz01xL3OzaUsdcOAV0nR4IuFBPJAr74lL+/y6AaUFXNZApL+NEV7OvKdoThMWPMrwiCQ6uhaIyOfQ8C0lQW2MM7GhQOE4ym4U9D3iMxaHLyYk5UKzr7on3S3ESV	shibuyashadows949	shibuyashadows+949@gmail.com			\N	c5ffd339973730a3ef4fa53eed42f6dd5e6d60acf03f92fb6ff4e64b24132979e468aa909e8cf183825b348314e51df3a2a79cf2838e291aec92ade6a6a9b328	977f2df8e10efebcad1912879fc17a9746196075d3c159474c62fe67d9c451a9	2017-05-26 00:00:00
14	Hyp1nG/r+DQ6eoTmitjzzBMiEgXJwmYUIVIF9BZ4v6xefchCaFxyr1ALqlELdAolQc4nT5z7lTICP/xbzZhjvbTVo8+wIi2csXv2jrIp/vs+OhNXPF0sxyeyDf1xUO/T	shibuyashadows951	shibuyashadows+951@gmail.com			\N	bf48745bb8334225a05f5627ee78e3bfb1f54a9dd984de032e5954f40d1dd301608424bf96799fa4a91af5bad70c9b620168514f6529a15660787e48cc6f4779	b2e52146e7de17a7d92dceb9d43b8074ea6cb82b534708220ca89641ee577725	2017-05-26 00:00:00
15	CYoj3b6+BsenldOy7DFva+0i4Ha63akHrSv2VCdtC2OlnbAHHmYwQ4NWJmEQln/FTpzYf/M+/ntKQGYtlPIXCTavgmAzGxaOpIOWtb0TH1/kGBucfOwUSzj15PkeGBsS	shibuyashadows905	shibuyashadows+905@gmail.com			\N	f074a4a6e48cdb6f858f0a86c424801ea4823800fb1015cee297ffb41e023f1f96115b3c4fec2cf3524d1f93946719ee5967496fa660173234a0e3d79c5bd558	9071da3ebee47c69f20a811f24776bc04db30324789b3bc2ec6275cfa2afb6f3	2017-05-26 00:00:00
16	Zib9uM7cZ6wyRlWkbyREXfL/ysL/WrdksW2kSU2wnhxYAjI2hEtf0URjT8Ie08ZXXYNyA7Y9uHgEPexKOBJLR/vYEe/D24f4J0PjIPuFcQDwQXd/nL3bAqLgQu8K/Kxf	shibuyashadowsb56	shibuyashadows+b56@gmail.com			\N	bdfd2eb8848fb5b6b91c920f2bdf5211288ae0f2c001a95e3f12c0f4de0c67703ea1b439ce0f946364bcce69bcbc57d14c08a0edf8fd8ce8910343f36810561f	d49bcca03be27bcfc372fcd2ff8b0db33d5f885e2a5235629da18bd187ae1ccd	2017-05-28 00:00:00
17	NZp4XVs0sMyMA76kpdxU9NY831cdZnML0AQLL6XjaP1yWkQJRzx3Yp3q1eqBGQobgZz58175dw1Xu4P8DLL9h0NQbXsN7wwGWLc+yVM/n3HDoYyIbmr0TMSByxZE/eG9	shibuyashadows736	shibuyashadows+736@gmail.com			\N	7a3a2e58ad8c741cf67bec3e106b3e770c0573b23f966c10a015fe4230cf21da41dc20ac5383fdbeae6623b2b929f5bbfd16bda0627f5f4012c84c397b23440e	83e74af6e68b4420342198adc4ff7810c6d0e4cf412abb223e007a5afe50fa16	2017-05-31 00:00:00
18	yUmeGEKu6Bk8ynflXEtqLVxgDSWfazA1XVlsnYDxy5Nma7fiNbSdTg48Jwk4MO96BXuPmG5vLDoijMuVe/jY9zH6q21xcvx1tzN+MXV8higMAQ6/wIY4RpJ0yLuISJ9T	shibuyashadows908	shibuyashadows+908@gmail.com			\N	c69a6d6d72d499c52a1c59eefb9bf4b45e3fe899bcdea6b35b7315d0fdc8625d730db81049cd1bbb307a5efa065f5f640368f70baa41d85d765d1b699b9ea221	cf8ec4daa0bf6432ec2fc0c514d861da715d8e22c40ff39a18a84ce4717c80b7	2017-06-07 00:00:00
19	/5Fe6TAxM0IS9YUqKCae4kw42mSNsxTZGlhH63LqEU9Vtq2954ZQAdtsPKsLOyHog96SOAosZet55CKKLVduB5lZ+vJ38cs6uM0Fiktgf1uBBTkctxUpuMfaMaA+0q3B	shibuyashadows913	shibuyashadows+913@gmail.com			\N	ddeffbedefa73b91d8f091d47861ccc88acf4920e8fb05e55bb10bf529649148f73f9fb0fce5ab74f88e2144f880853c1002e1202f03904aaa094e4f9204a54b	2247fa364abee7ef7a0ef94f189edc4a63fdd2f96f15b909fd56bcc2a0c9ca7c	2017-06-07 00:00:00
20	Vq+YH2Wz45ssnOl2Mu+/BYfGOWHRKQHiwNmcMtqnKubWvCITrh1JiZnH5mvtY8ko0pYppsOW5gUBupDHCNhy0nEcaqbG4jaG8E1WCvYWbIR8afXILOQGrKvPiDQMJ+hB	bobbydr				\N	a8d4525e7d3b9c831ce9d19c0537b85fc747541c3052eb21a82b8a953a9a29183f3a17609cda6a9d9731a6490dce4ae09bf0b0a680bc8a15d137642cfbd3d5da	063544d46edb033aa9d13ecdd5ee1707e0b61efde8393414c3266ec7cb9efa36	2017-06-07 00:00:00
21	REX4aXdYXarSFdpm1L49IlLMgjPQgTyMEcWGHmcuXHqeXQiQXg+Cez7YmRyXjJhbtMglslD0KLAnz0OqKqnRzN2/Sx8zpiyom9atSRpAb0BLXsBNLV3VQYlz7DTZsU8f	mrbenjamin				\N	1df56e2c79985fc5e5f1b668a20b8ae6ff52c7d8b4a3d135cfeb1e6a745145c2cd78b6820822d9f6fa24aade04ddb25b7b3e770b6c64308b180f71640977e31f	c63c43f6f6d30031d8297c055622d45c9100589a8f8c9d4e1e8d9ca3a659966b	2017-06-07 00:00:00
22	9Lj6o5ZtovOF5fRrjvCtfqcjs+GO/RiTDwVqtjuJVpjQHER1lInAoC/1lzF7yWuF50z7/EOJa5/IJ5I3dbe8oCRSFgSm2S5BgeKK3KvNWc9CpKhWTd8O0UZLMQTwRtwE	bentester				\N	2dada012444c56e0c3bbb0e518951b8527eb9cedbb82b5a25522cf8e2577c8200f436f3890813e8e921230047fce708b509de0c9fe4190b3b5c0d6f008c7bbb6	b6e92b56fee201c6df21ee2519eae663356bfbd59880bb9f659a314aaa4139a6	2017-06-08 00:00:00
23	W2L2Whdv/0hxXB9MXSrHlRynNWM+v2yHRTawVge5s4alKVu+TBz0pNNmCWsLg95qiIat48AscD9x3kBtnpROIfopqGP0FmCEWzjizj37N7cQnLtoul4FKGHEY6F4ZG02	shibuyashadowspb	shibuyashadows+pairback@gmail.com			\N	9f4e934d003a170e7df7d38db3e44da66b2f83184b5d872e18076ea895c11617d34b2370d32399a3fa53d173b23355ffe533cbe9a56db8e3bb4f0003c31526a3	6a0819523651765117adf16d9c39c8b7d9853412dac049c92d3f9d4306b1128d	2017-06-08 00:00:00
24	g/6tN0LpPah2uMCP0e0V26I+dBuXf3E0vUGD4TTJ9HHEg/+bOBSrEuzHjRGqjOY1hJfF9BRegI3F3wN8vjpNlMOrHI042tsGjNwKNvRu1RFzaIgpUwIk4KZ4wAGXbOLM	shibuyashadowsuyus	shibuyashadows+uyus@gmail.com			\N	edc174d6238e9ba1de6dcb4c8d859ae9e0efc62c92ee4a100566b5ecd809a449e4cfa78ec18cb487bae3ac77d9293cd18af920b428b7abfabe4d10793881ae97	1d19e03a93e96d8982c277a88b3e97b3444590ad146a8863fdb02087c0699aec	2017-06-12 00:00:00
25	HYMWDq4tN00v4hnuZIDQvcklYZAl2TU6VchZ76gStexoVeTjpM37G/KI5r4IPruggsBXcUHHVrvHu+0plzEyX46sA3TdULPyFQ/fVP+3QgdUVQaPYUtVkc2k+9gECmzp	shibuyashadowsiou	shibuyashadows+iouuiui@gmail.com			\N	150330eec051ed6f2386067ee2ae0156a447de8ff4257db65d18b743c075bbf753322056a93d89f5d71526ffb6e01a2177bf22a3b6fcf5eec5821fce971cd3d0	c931fb531ef49996bc5d37f08c3b2b008d86cba72ea67366d813f6dbb9b46547	2017-06-12 00:00:00
26	w4m2ia++3DG0aWMP2Fl3JTkt3CyDVcH8Qyu1tpTI+hHgv1A3S/uW00W0K9QCHNxXA4XnpQpI9xwQl0LDTqHSJCFZ/RITPyX3wpc+YjBTuti6AVAXKyio3SanHB5umIto	shibuyashadows9yhy	shibuyashadows+9yhy@gmail.com			\N	c09de4362cdd74164b80ea77e8cd2f33125ebfe28c95d6773512318b830e802038355bfacba95fc0a8128a1b8e8d4640db9b71ea336bbd9f83670c7325f92466	0fc90e3dfb75e32ab865dcf15295a72913eb531120aa4119e49ea6f9de9eccb8	2017-06-13 00:00:00
27	B8njoFsxVl9BirIgV9LWRyBoGDGLDRE57F5siuly2xbStqDtpn2Bjigr9lYoNLXrOvcmF0WvnIpXn8c2GMIiZ1A+7WYBxg4AD3dfp8q6T5SVBtgcvGZjg/tsQYolXJ97	shibuyashadows8yht5	shibuyashadows+8yht5@gmail.com			\N	c19d41a1a741bbd97344dad4ad50c2498620e901009b8ab34cb2b42957bc414601a09a9ffb1e4cd0344d2e6b0c3698ba7f1c709cea2f08dec16d3a3d3b61ec8b	80e7960fb4ba81e4a120f9c91a3726680eec64c760676d82b4e0fe460f997534	2017-06-13 00:00:00
28	Jpeo0Ma/suAJw1jfLhqFnnn7HMltQnpalp2IdH0CgBzx+Wz0NESIz3r+u7BlJCYHjKZzAo6rgupDU/+FyecT4uZXY64FpawkXqyfy4gXmxSe0+LywzUah5h4bU4TNAcs	shibuyashadows89dt	shibuyashadows+89dt@gmail.com			\N	d9a283909e6b2cf2ef6c0f984918d9f771e9d4501d723845cdb614e9c3efa72f133e1a50503633eb8fcc8eacee6917490447e98fd90e18403fafd1535489dc58	477f57b67d21f2b85a94678d91fbcea4aab3ca372b0bc3f87a125c011fc237de	2017-06-13 00:00:00
29	yH1A+u0uXOQ0VgSIf+juv2qbABgvLIPuiuFPTHLBVHBAfHFf6OS1vvUKi5UhsgdI9E4JY0Hdyj4Lp9CpHuMp5DF6R0ZddxHi7bUqd9rMoHln+uLowxP4yiqkCmA5/jIb	shibuyashadows897f	shibuyashadows+897f@gmail.com			\N	5c259e477707a8834da486e1bd8a1965455d18a1f1cb1d4f2bd8410b30549ddc6ed466e6fe52dc1eab62a39eab9016e8bc8771ba83e3c434d50a822c5f3576ff	15b04890bc0f13629df98082eef06750acb187a67476bd23b3153c7ef070f2f7	2017-06-13 00:00:00
30	LmDmZ4Xxcq0iO2WTYy8Mw+vjZYa8uuCghL7x2UXpUVVimORaQBBmdp1/LHyvf5NySE9Pkyl/TZxewKY/2JDJSNqvsIPIF6CDS5XSbxtN+uqn/MpgRZusz4a4fAyjDw/k	shibuyashadows785t	shibuyashadows+785t@gmail.com			\N	3faad15ef99aad1f635896fb598647f6508afe2847bed9d623f213b5608cd90b112546093addc8d93f2eaf7ad790de97adf76a1a61809cea557fd85af36a1ae7	cc3613a9c3d12f7b6b29bcdcb6d24a6d85069a287f412c485b8d47e1e8fab514	2017-06-13 00:00:00
31	fwq0NFuAAV18Dgk5tGFkuc1iAaTE/Igm21T/yjBP5U2YOaT5V9mwfTSLPe+ytEXOwvynIHg+1TTqJh8BldURAfGcvaI2dSvTP5Xw/7uPNtFscOWPYy9QYhzkjozFT16i	shibuyashadows90gy	shibuyashadows+90gy@gmail.com			\N	d2f6cc604f0948de5c2a9b2a38a5eab404f59ce7dc74d8e735ac1c5679d457ed86afe6d1bc719435a91c317d091f0405585795fb9cc07338c862ca4f7b1e9604	f6525d8c7ee14f4c1d69509b3146646b59c4159c80959190a62635bdfa245062	2017-06-13 00:00:00
32	KprVDtNIqd5KXtcM50BzuJ2JAP2P/Fdinvd1sFMRLNMfUosQN/BFd+faX89/rAwZoVUY4Cqa458pCXo4zXbnbd3+7PVHGHIH8K6BQrIqFVgsD2N1jyi7A+91n7DIcpvZ	shibuyashadows142	shibuyashadows+142@gmail.com			\N	5e377135214dfdb47d6c3c755861a3bc5a79f3c187bfa5e34f931ac143fa871625ceb0fe651ba53ba3fbe907d8fbf93b8f24cf47fc5654eb7755a2d0ccc067f2	3b6f369474be57d354537dcd554177943409349a6aa784a7fab7f6506b6ddad2	2017-06-13 00:00:00
\.


--
-- TOC entry 2710 (class 0 OID 0)
-- Dependencies: 203
-- Name: recs_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('recs_seq', 32, true);


--
-- TOC entry 2695 (class 0 OID 16681)
-- Dependencies: 211
-- Data for Name: traninputs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY traninputs (transysid, inputindex, rawstring, prevtransactionid, prevtransoutputindex) FROM stdin;
\.


--
-- TOC entry 2696 (class 0 OID 16689)
-- Dependencies: 212
-- Data for Name: traninputsnoncon; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY traninputsnoncon (transactionid, prevtransactionid, prevtransoutputindex) FROM stdin;
06c07d550734c726c6bb534c3784c09e67b31aeca747df845165d0e1a5bf87b9	288c1653ace3062bb20fc291e27df8a84b8dd5e1ef7f2e208bd0e41b015fa522	0
e4bf3c41465e32a7f1792695f9b7d8af8ead6bd49c9cfefc522479c314291c6a	06c07d550734c726c6bb534c3784c09e67b31aeca747df845165d0e1a5bf87b9	1
20832cf00e05cc0cbe5e20920cea33bfd1385d47a5744fbe02e4574bd9f4ac60	25e3fdb5ed2d592b11b41c4a7c40adbad510923c47329b21b08b6ad123610d26	0
20832cf00e05cc0cbe5e20920cea33bfd1385d47a5744fbe02e4574bd9f4ac60	a9f8ec4f854d3433ab27972657b9c172adb4f6b4074029b817fdca2ee278ea96	0
20832cf00e05cc0cbe5e20920cea33bfd1385d47a5744fbe02e4574bd9f4ac60	3e54c8190f4f6b55304be0ae54ac0cc30f3b639fbd57fb168630ef6c9c8bb748	0
20832cf00e05cc0cbe5e20920cea33bfd1385d47a5744fbe02e4574bd9f4ac60	8b60f7e5e4b9c1add087e1373226841f254cd9d373741270d73529ca8df845a5	0
d1c2d6102d1342fcbcfd4b22ba2d159eece2e2fff96578d4e436ab63ae0559ac	60acf4d94b57e402be4f74a5475d38d1bf33ea0c92205ebe0ccc050ef02c8320	1
d1c2d6102d1342fcbcfd4b22ba2d159eece2e2fff96578d4e436ab63ae0559ac	ec422a2714834fbf476314b5b02249f37efad50ddd085b969531a37c028fc3b7	0
d49d872d88423fdb730bf2b119b393f8c9bfbdbb27b1af1f1cfd09b5115e742a	20832cf00e05cc0cbe5e20920cea33bfd1385d47a5744fbe02e4574bd9f4ac60	1
d49d872d88423fdb730bf2b119b393f8c9bfbdbb27b1af1f1cfd09b5115e742a	b7c38f027ca33195965b08dd0dd5fa7ef34922b0b5146347bf4f8314272a42ec	0
fd42289599b52b26a5ef6e1bc34e40c1c0b916d8b892aaa991787b921e4f8c6a	2a745e11b509fd1c1fafb127bbbdbfc9f893b319b1f20b73db3f42882d879dd4	0
c54013b97803ae394fe838b4c9358f2037964c92c77042a4aa4cd2440d34424c	6a1c2914c3792452fcfe9c9cd46bad8eafd8b7f9952679f1a7325e46413cbfe4	0
e7a68300c70a9e3464fdb419b5664b6a92342e728082349995d88c3894ddb3e8	d49d872d88423fdb730bf2b119b393f8c9bfbdbb27b1af1f1cfd09b5115e742a	0
8736941f1c281122a73bdd56255ee94e93bad099b996cb302910c4053b3980ed	30674473e764caed00e6586ea5f4a4020fb432b9a6b5f93d2b8f1a9464603f0d	1
b3a45950786d0cd90925e4fe76d1302c228c063f4eba4e18c9645803a5f512a4	e8b3dd94388cd89599348280722e34926a4b66b519b4fd64349e0ac70083a6e7	1
4dbe456dc69f6c22a49cab176521461849031fff78391e02014de955e3ccfcbb	0d3f6064941a8f2b3df9b5a6b932b40f02a4f4a56e58e600edca64e773446730	0
eeb047c65500ca808d927ecbaa40fa2199a1422ae7dff38d7d030bd65a3c3871	e7a68300c70a9e3464fdb419b5664b6a92342e728082349995d88c3894ddb3e8	1
9d172efc7cc836ccb2191c0743722144f5103eb19984e93c56be2497a8e5d67e	eeb047c65500ca808d927ecbaa40fa2199a1422ae7dff38d7d030bd65a3c3871	1
9d172efc7cc836ccb2191c0743722144f5103eb19984e93c56be2497a8e5d67e	8a4ade05586aabb5eee254b1b1211d8955e65ac0d9069ea763d1df2c7ed7c386	1
d1102c379d4917b798ccb4217b456f160890eadd09b069ad3db87fd0bbe0e64e	71383c5ad60b037d8df3dfe72a42a19921fa40aacb7e928d80ca0055c647b0ee	0
817344b0c267ff9b0ac0566be08e3dd41b1b98724104c16124d7157d0f814620	0799611fbc133bb81cd534e4e88e01aee061ba147a0e9d1039d8886f4f73f59d	1
f00606d6d1448326058722f79b0c2e1d7c4387239b6b64d8c97467aa53be07dc	86c3d77e2cdfd163a79e06d9c05ae655891d21b1b154e2eeb5ab6a5805de4a8a	0
0799611fbc133bb81cd534e4e88e01aee061ba147a0e9d1039d8886f4f73f59d	eeb047c65500ca808d927ecbaa40fa2199a1422ae7dff38d7d030bd65a3c3871	0
3ea665a2cdfe2e3be0e37d064af91ce2d9ba43b3fccc3a75b37f2381d4d87256	afa757cf2bb5535667d4f040c93cd7c91f28b84df3ce2c1f3cb5c81d8cb2a156	1
281b031339abc50070fc5f7e06905959a09da44e703f6b0c912d60b696af236c	9df5734f6f88d839109d0e7a14ba61e0ae018ee8e434d51cb83b13bc1f619907	0
f7a78be036cd3e077f3d284863bb67d0d60dab50057006bcd57049351885096e	0799611fbc133bb81cd534e4e88e01aee061ba147a0e9d1039d8886f4f73f59d	0
0a24fdbbc1401a5614c6a6dfc9144b97605601a72950758bb6944bb548ce21f4	f7a78be036cd3e077f3d284863bb67d0d60dab50057006bcd57049351885096e	1
a8c23969353f0a78f92b8b576cdd50a1283544fa13f42d67349890bf7a77f116	2046810f7d15d72461c1044172981b1bd43d8ee06b56c00a9bff67c2b0447381	0
a8c23969353f0a78f92b8b576cdd50a1283544fa13f42d67349890bf7a77f116	28008fbbeeb708f2d87e3b6ffc8112166b2d40a0980bf1c65102394406f2a039	0
a8c23969353f0a78f92b8b576cdd50a1283544fa13f42d67349890bf7a77f116	7ed6e5a89724be563ce98499b13e10f544217243071c19b2cc36c87cfc2e179d	0
a8c23969353f0a78f92b8b576cdd50a1283544fa13f42d67349890bf7a77f116	6e098518354970d5bc06700550ab0dd6d067bb6348283d7f073ecd36e08ba7f7	0
652fc9a13334f6b1122e4c73650815fe9d61054a688524f6331f03943fc6bc92	817344b0c267ff9b0ac0566be08e3dd41b1b98724104c16124d7157d0f814620	0
652fc9a13334f6b1122e4c73650815fe9d61054a688524f6331f03943fc6bc92	39a0f20644390251c6f10b98a0402d6b161281fc6f3b7ed8f208b7eebb8f0028	0
652fc9a13334f6b1122e4c73650815fe9d61054a688524f6331f03943fc6bc92	9d172efc7cc836ccb2191c0743722144f5103eb19984e93c56be2497a8e5d67e	0
652fc9a13334f6b1122e4c73650815fe9d61054a688524f6331f03943fc6bc92	f7a78be036cd3e077f3d284863bb67d0d60dab50057006bcd57049351885096e	0
cee6ff83f6d9dc8212412f6ccd994f1bd8a31e30a6aa8259e598146ffbfe3c08	652fc9a13334f6b1122e4c73650815fe9d61054a688524f6331f03943fc6bc92	1
d75f04db0990fb4f183ed68e7dcbbd0747301f67f283b845ade275dd387ebd66	92bcc63f94031f33f62485684a05619dfe150865734c2e12b1f63433a1c92f65	0
d75f04db0990fb4f183ed68e7dcbbd0747301f67f283b845ade275dd387ebd66	5672d8d481237fb3753accfcb343bad9e21cf94a067de3e03b2efecda265a63e	0
d75f04db0990fb4f183ed68e7dcbbd0747301f67f283b845ade275dd387ebd66	e9f0bfe5f314135f6033bd6b0eca3cfda86c956c3b4a0992b9a02094de9a22ef	0
29b1bf3eff31d17381a456d7c113060d2de1f7cc9f35b9f26f5ab542b26622a8	a1cc2c8091beb482e1025563cae4902a1c03fceeb1c7c47ae0549e0147535d5d	1
a1cc2c8091beb482e1025563cae4902a1c03fceeb1c7c47ae0549e0147535d5d	652fc9a13334f6b1122e4c73650815fe9d61054a688524f6331f03943fc6bc92	0
a1cc2c8091beb482e1025563cae4902a1c03fceeb1c7c47ae0549e0147535d5d	3ea665a2cdfe2e3be0e37d064af91ce2d9ba43b3fccc3a75b37f2381d4d87256	0
a1cc2c8091beb482e1025563cae4902a1c03fceeb1c7c47ae0549e0147535d5d	ef229ade9420a0b992094a3b6c956ca8fd3cca0e6bbd33605f1314f3e5bff0e9	0
df3978c50f44a91368502859a4fb1c75d65f15c0bda1f2c94669c7d387ec6886	cee6ff83f6d9dc8212412f6ccd994f1bd8a31e30a6aa8259e598146ffbfe3c08	0
\.


--
-- TOC entry 2701 (class 0 OID 16853)
-- Dependencies: 217
-- Data for Name: tranoutputs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY tranoutputs (transysid, outputindex, rawstring, amount, address, isspent, ispending) FROM stdin;
\.


--
-- TOC entry 2697 (class 0 OID 16700)
-- Dependencies: 213
-- Data for Name: tranoutputs_noncon; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY tranoutputs_noncon (transactionid, outputindex, amount, address, isspent) FROM stdin;
e4bf3c41465e32a7f1792695f9b7d8af8ead6bd49c9cfefc522479c314291c6a	1	1000000.00	2MxMALiZWyDzD7jKFJtwFAULBKLsqbXN7wP	0
20832cf00e05cc0cbe5e20920cea33bfd1385d47a5744fbe02e4574bd9f4ac60	0	100000.00	2MuZx4Ecn8NtoCM29S7aRV2YdeHuNxWrokT	0
d49d872d88423fdb730bf2b119b393f8c9bfbdbb27b1af1f1cfd09b5115e742a	1	100000.00	2N6dZpQEHgViMwrBxHCSCJcNp38eSX8vS9b	0
e7a68300c70a9e3464fdb419b5664b6a92342e728082349995d88c3894ddb3e8	0	100000.00	2NBrN9rSevJKPwed4zMgxPvTV8ep9ZVj1ET	0
30674473e764caed00e6586ea5f4a4020fb432b9a6b5f93d2b8f1a9464603f0d	1	100000.00	2N3JEUGpS5EDFFaVE2LhH2m8Kd4b2y5eYrJ	1
8736941f1c281122a73bdd56255ee94e93bad099b996cb302910c4053b3980ed	0	50000.00	mntRiQEVdKSgiVxwWkNRwb99o5vZD1riEF	0
8736941f1c281122a73bdd56255ee94e93bad099b996cb302910c4053b3980ed	1	40000.00	2MxfGyk8PkugSYTS3F1TwDkvifnALY3Cm9D	0
eeb047c65500ca808d927ecbaa40fa2199a1422ae7dff38d7d030bd65a3c3871	1	10000.00	2Mt8C4KH2STiKtC39trF5R3GsomrMa8m8d2	1
8a4ade05586aabb5eee254b1b1211d8955e65ac0d9069ea763d1df2c7ed7c386	1	100000.00	2Mt8C4KH2STiKtC39trF5R3GsomrMa8m8d2	1
9d172efc7cc836ccb2191c0743722144f5103eb19984e93c56be2497a8e5d67e	0	10000.00	mtT8kurcg4yNos79thTSLkuPP4eBzPBaYW	0
9d172efc7cc836ccb2191c0743722144f5103eb19984e93c56be2497a8e5d67e	1	90000.00	2N4gpmQJLRJzXAm3QSTzdBMBXxS54iPEbtq	0
0799611fbc133bb81cd534e4e88e01aee061ba147a0e9d1039d8886f4f73f59d	1	100000.00	2N3EGLyaUcRTaqoCinwxESHVBkXnDJXJ3mM	1
817344b0c267ff9b0ac0566be08e3dd41b1b98724104c16124d7157d0f814620	0	10000.00	mn3PwCRjLjGvLTGro36pk57kWMjwEunn9y	0
817344b0c267ff9b0ac0566be08e3dd41b1b98724104c16124d7157d0f814620	1	80000.00	2MyjD2NjbP1ApH4gCBqeK8DSRa384AoefgA	0
afa757cf2bb5535667d4f040c93cd7c91f28b84df3ce2c1f3cb5c81d8cb2a156	1	100000.00	2MtqFJ5epEQ5L6BsLN6NVGa1J1QnTFhiikE	1
3ea665a2cdfe2e3be0e37d064af91ce2d9ba43b3fccc3a75b37f2381d4d87256	0	90000.00	n2DTKms5erSLBvHwPjNCCgVEtQ9outseab	0
f7a78be036cd3e077f3d284863bb67d0d60dab50057006bcd57049351885096e	1	100000.00	2Mxb2EaUjEXRyGtkYrvHjznUp6gUKB6ZM86	1
0a24fdbbc1401a5614c6a6dfc9144b97605601a72950758bb6944bb548ce21f4	0	90000.00	mtm5gTbgJNk4MCaEC7BQSGnkzcgQvTemBK	0
652fc9a13334f6b1122e4c73650815fe9d61054a688524f6331f03943fc6bc92	1	100000.00	2Mw8zAY8BbJnAgp5CHTaq99LDtBr9CPCGm9	1
cee6ff83f6d9dc8212412f6ccd994f1bd8a31e30a6aa8259e598146ffbfe3c08	1	40000.00	2NFHSpwLG2qyQ8wdgqzEcihukEHcfrqz1Xw	0
a1cc2c8091beb482e1025563cae4902a1c03fceeb1c7c47ae0549e0147535d5d	1	100000.00	2MtQQxDY4UjSr66VHiJ8FMrX5iMj3fGNoQf	1
29b1bf3eff31d17381a456d7c113060d2de1f7cc9f35b9f26f5ab542b26622a8	0	90000.00	2NBGLyaaViHV33iayq9WPSG1xcdrmqRVXeX	0
cee6ff83f6d9dc8212412f6ccd994f1bd8a31e30a6aa8259e598146ffbfe3c08	0	50000.00	2NApCKDhDFAmVFyJ8ESTxVtnXWRGVP48tjA	1
df3978c50f44a91368502859a4fb1c75d65f15c0bda1f2c94669c7d387ec6886	0	10000.00	2NB2mNPps3q6Ek4ZgJz6Dq6fpLeV5jnJkUc	0
df3978c50f44a91368502859a4fb1c75d65f15c0bda1f2c94669c7d387ec6886	1	30000.00	2NC4C2VRPMz48L6x3SVFS6p8RXjLRw5N2Rs	0
\.


--
-- TOC entry 2699 (class 0 OID 16707)
-- Dependencies: 215
-- Data for Name: trans; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY trans (transysid, transactionid, rawstring, blockdate, blockfile, blockindex, blockbytestart, isspent, blocknumber, blockhash) FROM stdin;
\.


--
-- TOC entry 2711 (class 0 OID 0)
-- Dependencies: 214
-- Name: trans_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('trans_seq', 1, false);


--
-- TOC entry 2700 (class 0 OID 16716)
-- Dependencies: 216
-- Data for Name: transnoncon; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY transnoncon (transactionid, datecreated) FROM stdin;
\.


--
-- TOC entry 2677 (class 0 OID 16460)
-- Dependencies: 193
-- Data for Name: userinvoices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY userinvoices (userid, invoiceid, username, invoicedate, invoicestatus, invoicepaiddate, transactionid, packetforme, packetforthem) FROM stdin;
2f2286e0-7227-4c1f-9627-6abbeeb9c015	1	shibuyashadows736	2017-06-01 19:23:23.533	0	\N	\N	-----BEGIN PGP MESSAGE-----\r\nVersion: OpenPGP.js VERSION\r\nComment: http://openpgpjs.org\r\n\r\nwYwDl2hj47qazmMBBACFj8ivqJmHKd9GWoN6iQz51EwmJc4b98WTBJCjLnFu\nBhH0C48tBSx1ZKISWrXIghueeJB2vfcxGp9wI3yNt5SX8aik/iZYrMwaYyq+\nnaR6FVSXammXsytEH1TZH1wItV6lH8UCPBSqxjTm7LBRZLXUrvAohdiqQrPl\n7qy7xOO9btLArgF1C++WgDj4ZFmu5ehtRX5H30QI8U3ufTujA6o/CuyQMFgs\n7CmFai5PMH58lSNwhE0hYpihlicTPAVB5nadWIiw2TCLpJ1lxfFbq0cjeoYD\nyWs4UUB4wQ1hmb9E5dUQ9OmCSXmYZHporEzwaS1vETxWrhdUD8xH60mmEvdK\nuTjomH43d8VIyrt3R38SmPFs2maFyn3RpRC2N8uA/zDRBR0up8zn8n2c+Es0\nSr0muT+xYOTUTHFzzkWjw++W7t5iCzFdLjNl4icmkAhDjNfQX+tFywO6cG9I\nlxpq0pwjvCq9Ra5/l35T6UL6hLZhZw8Pq0XYQNfjmHRldAPpgeZtCmRk4iEG\nD9HfGv6nEHk2CsJOXl5+fdOJON1Y3sazy4u6MYlaX0xK02+rwotaZ22HHoYl\n6PhUUJNr/Ncax9R7i148qat5RYlJZLcjjOK5aef11Jdr42gqUg2TkhHenQMk\nUAnVox5k7Xn2QZhj83Naaw==\r\n=a1Hj\r\n-----END PGP MESSAGE-----\r\n	-----BEGIN PGP MESSAGE-----\r\nVersion: OpenPGP.js VERSION\r\nComment: http://openpgpjs.org\r\n\r\nwYwD0UKqqCoR4xYBA/4+WO4R7pNT3goLPQQW5g8bim4tRUZtNCF7BwO8CiOt\nO3vnGcoR5bEwyp1/Y9TuCnGrig/ydCdzm6KIICvl/4IVwiwMsbdxQ+ZQ/mCP\ndOjpmCIIhFxwF/iKidt1tsOjgUWblozZuYYgr/Rec8f6/2Yded4nTa0P+VDv\nBA2oA9dbdtLArgH74mS9wM1md7jWD3ySJxJ+cWPlRvVMU36oreYKnxpIHd5j\nVUgV6a+EP3T5EDmc1AqFwmZ8uHmxGAnTMjPZ/fh+7J0+eUrO1hUrD5RVaKFF\niaVRXFId+1fYsI/oftRiR1SBRWsEKMtTDdZ3TwVqFmPZEnIt0dVXNvHpLRh0\nHBK9EscCDl1A6ZKL4CR0N6/yfWUvOkgMeqBkjRpClNrf1tiIGEmwvqh4Bb0i\nnH7OBXoLZS3ry0hDCe8CtWUD2LEN2DrgaVPTcF0uzFyDDFgo4fKgpeE4fRCc\nygVTWTOqTDCIxoVyidpkIT9Eqtr1qsQ3+CRXal6AkmmKqzPz4DhFHVOqp3er\n/Wy94KxFY+Gan2rmBBESqoBpgL1x14eLGMCr1XnxtBCwPhbalgIVyS2PDR2w\nHxcLUBu/xUTpel0uuWgw70J+Ilpchj4JovQkByzIZFwpq4YPngABMG4m/gL4\nhatk/MTTYUml23s+QlqpBA==\r\n=bPDL\r\n-----END PGP MESSAGE-----\r\n
92e8af98-63da-476c-b9ef-26185bae9607	1	shibuyashadowsb56	2017-06-01 19:44:01.258	2	2017-06-02 11:02:49.974		-----BEGIN PGP MESSAGE-----\r\nVersion: OpenPGP.js VERSION\r\nComment: http://openpgpjs.org\r\n\r\nwYwD0UKqqCoR4xYBA/9P3RtMrNSoJnB+3s/mdMBtOpbM3sz5vd1YP1PfuDrS\npkqL3t/7/I5xERGoEIEokY1M5KLK5bNbTbVstl7EON6j7Y/l+gZyGP43cEaZ\n44EjoSkdNaeTQhpTPRQO96lM3nOGBZ6AiKhVWodkD8qS9JvOmU+SwDCs56rL\n8s3RUK6G9tLArgGEU6l1nGDIYYwJCaBKIMr/im08TYh0u7ymtmqtfqkTFYP8\n7IXj4MgumDZNayG+FkB3Ai45nfPr/8kvc7engZ+dxGHkkUU8kpE1XpX3wJ/M\n+rIwTOFOSK5DbjHVF0J13inN2uo7aKFBZpeeRFtlMaE2ykBisEmPI/JLo3mR\nEAaHhOku0lHtHXPN5d6yETK+kToqhNQTrEB1PuMaI7ya4SEu35H5yitFQ5lU\nSD9iOSb2slIYOAcAw33sIWgdXd/QBm9x3+BmFnMw2sn0TC0rjZBLAJwBXpWB\nrY3XEoNQP8dq0suHJiIzcx/ifZ+/of6aiSifoHX0C3Fazuxi7+3KNYLr2eyV\nnQPzZO1zLCQsXVsHee421A/OE2FpxMJEy14RuKFz2/XKFoc361o26xNlx7S5\npNXcoQZzqbdvSyMo79tYeYPPnVo4qaSOorK6saZe8k3MNqla3tOLQVCAxZiX\nzTIaaR54BL5FeXDZ6SVLOg==\r\n=b4w6\r\n-----END PGP MESSAGE-----\r\n	-----BEGIN PGP MESSAGE-----\r\nVersion: OpenPGP.js VERSION\r\nComment: http://openpgpjs.org\r\n\r\nwYwDl2hj47qazmMBA/9XpDhAzNIpDDfgpHcdvapzUugzM+/jrbr0Ne4tMxfi\nraSAGg8S4IEkFJOhJ1dR/oScPygxlUB2enhbAQ+XE/WgbyrnLa13nwuSBr6J\nhvwpeEDa/FKl6Ugm8D8zy55M6qvso2k41gC5elQZCJd7voNFTTM1yDSHrJby\nFHJdy56RPtLArgE92sHFlX45WZrVXF/0mY6doJ1XGpr4vKifeWa9gHN7/CHr\nCVCJraa0zVNzrfgdFh+iLs0NpBiZVTtUeePSDJnoDWLvt+0gaiwSvbP2DyXo\nKCbgvKM5K0/Andq6gGj+XIO/h5v2N3XAkdVNEEdRBrZDvd0OStr0M0fOLOG8\nTJ2Q0cicnWP5oIQyCXW1axU0zknBU2DotVONHlgbNmjYQPEK0gJ5svrsSXBj\no50oV7CKeKzcVlLcF7ohd7MpRw4wlwyRNR3SQ5q1PZE28VUJ+JrfwXTnmiDI\nYKxU2y2rZt46/ibKlqwJ0Ng8w+Ja2yR9OfWhSiAIkMpaQGyY4Fh5IiGcXtUY\nfOu75uqK0+wDnQVGZ5mqCSW6eOLGlOVBrXDi+Cl5dBI4SBLUFHROLcCjWtSE\ng4/QcmSyZDL0ZT++U+q+qvnjYyjIE8UVZ8kvkjAbGPUOfEYml2yk947Oz/o5\npeCR+lghu/i1MnYjsBPq+Q==\r\n=56eT\r\n-----END PGP MESSAGE-----\r\n
9063f4dc-d9c4-47ae-ba12-d5050789f4b0	1	shibuyashadows142	2017-06-13 08:41:55.171	2	2017-06-13 08:43:02.371		-----BEGIN PGP MESSAGE-----\r\nVersion: OpenPGP.js VERSION\r\nComment: http://openpgpjs.org\r\n\r\nwYwD4YFBzF6WINIBA/wOIBe5XMkkgSd3T70BKhRoUcSppl4JP4xNV8Zj1ZGI\nwHlG3zQ8Cf0HOEZR2T+RulR0bOFGj6Kb4dQp7a2NRZSC4+VDYA/ktU71t1AY\nzH87V2taaAWqq2GfJvjwk++FIB4vFh8wBqqg91yPnnTus62yp5gDxhi6WHLy\nTozvZgN1c9LAowGHE3mibJFAr1SggUJ+6fjcdVf1u4+1nhlvRz1yvSxHz5BB\nryipdLRWOuwXdTXhTcV0HQfDizNQmz8Pm1koEpS9gcq71HoDuKHwWJQKyblF\n3FEI2iMehgatEhPzHSt0D8AXGNCmCP6nfSbpyfXqzAoVxTDOvHe+YdUIl9/J\nE6M9juOj3zxaYWEEE4gsj2Mqf25H5nZ7Il2GY255UxSNkSTjeoX7zOq16KAI\nr2HmG/S8/BRzg+kAkk0HEmiUWRagQFeZ93sQIaxZ7qUhawIxMETEkLTwWr8O\na0BEeX3fPXTs/8n47FeT1A/Lw7z+07gPr0v1Dk1yQ3w63wpvQphtzSobwM3I\nfn4KsetrwGDmw10oYqmm4MwZKgqOkPqlteTCDtasP0RgSsVIh40RyvL+wfaQ\n7XW93eeUoVI+Nt/nX0tpWydhrNeRy/d/NQyVENIHYz1CD/BLnE9F5HPV82c3\n3ybzQCU=\r\n=5YPt\r\n-----END PGP MESSAGE-----\r\n	-----BEGIN PGP MESSAGE-----\r\nVersion: OpenPGP.js VERSION\r\nComment: http://openpgpjs.org\r\n\r\nwYwD/0R7xcMBCroBA/4o62OVdr07ksn1ntb1unFVzsZohFoTuC7vUd/8pll+\nGsBVu6VRAQQNzSSGf9XFrL+OoPMF2tDITC9lgAhqwuNsUe2eWi3zIq36ySvf\n0T3pM9WScgmMtBUP47l0dar/n0R6W4wCsRD6pUgtpLhjLs1q9CZ0Buxlv/BY\n2O6tIKuLONLAowGlEobrZ4vpYXbVWdsYkMF5YNNCp4cxLBO+v30d/QwIHHnd\ngD+q91e2nAVqUXv2bOsfC8esvYdm5xy5XASoIryWjHjIDu9Gg0+rpurQHvD1\n/RmkOMV71bGdjq6R2h0vzSz9Hb94J4JgQcSq6LVJ2EY4e7nFDHRDoyUKXS0m\nUmL7cW2BayqeE84z6/+XOSOPmdUr3mKz9RiDTLD2wDFFUDQVAYBb6tPtaUfk\nELXIFIy8l0dvdGl7ouWzx00vHt/A73ciS55ySclEymYxqn8kDWNNoXnWwacv\naB3ZJz0yqWCx/+MRprCcORAwHuBDWx0vWfXa20J2zAVdKoW/TQnUEWpDe9Yu\nyeSnRjpae/V4H67+UfpmSeznaXX1caVvwRYAtC8NQAyuOkoM5AtJ/HbOb5EM\nKbvdbN0+YhhjTDJhZ6CwnBLpus3VEzzLJSnGym5DJVudOp81iChhc3Gi6D38\n0xsUSjY=\r\n=yqlj\r\n-----END PGP MESSAGE-----\r\n
9063f4dc-d9c4-47ae-ba12-d5050789f4b0	2	shibuyashadows142	2017-06-13 08:44:20.143	1	2017-06-13 08:47:34.716	{"error":false}	-----BEGIN PGP MESSAGE-----\r\nVersion: OpenPGP.js VERSION\r\nComment: http://openpgpjs.org\r\n\r\nwYwD4YFBzF6WINIBA/9Bk8YLIc5quGPtm8EWkouH4nSPWB/zM3p3A04w58xa\nowoow22Y+Udd5EA7ug+0S7VoMGNEp7ymc+Ct7C+s9qAtnpJyLkbs1rP4Ljr7\n7cAdZ8DrBRitJ43sGmIFcDpgQH+s/bts32GVxzIgp6Xv66yfJnjhMgUKW0sL\npDTm2fajj9LAnwF8GTDjhkIg9K2tzmQSo04djf8sC4jh4CJC0z3em3iz8Ysn\n74ER3s/kBrMEJicz6Z1HxIcEPNcbeCYSpi0fkGkFnT2Iop2OwRXrfWnxodSu\nN6g3lwKKb0emtHg3CxcE+W7c224IRRPf09q8+h3Nc2kUl/n+jQj1ieyfq3I5\nrlLKuOzLF4XHXYwUJDTxkdnss2oa4ZRg11SQf1ZvXIYCBk3D/SuPCKarGn12\nEZK9kuoDFULKpoZJ66DsJiZRP9c36cswzTjnrdW4rq+n5F+xk9m2qf1c8kZr\nGz7LWn/wwRvMjWd7zwsVVqAzr/AEbEAJQjC3yBt1vWf5IUGfjEm0RZVM69NF\nlMdOmlwA2AHkL6W3WeR7GiaSFmkshhfGGRjXW3s3xNm7n1VfnhrugTMK/IbS\nYaT0oFc2P1VN6QdI7zSoNinVR37lA/0mqpftlRQQJJHKBHBH04vP/sDJGvoK\n9g==\r\n=M02o\r\n-----END PGP MESSAGE-----\r\n	-----BEGIN PGP MESSAGE-----\r\nVersion: OpenPGP.js VERSION\r\nComment: http://openpgpjs.org\r\n\r\nwYwD/0R7xcMBCroBA/0Z5SPzaruypj7HARSKmeRtbqQvdIDcWkZadopT/O6z\nu1bnZFSht/NOztCNTh1G/2zw5KGMK+f6f5kdw5IN320IMlpBWIFlUXUa4qXe\n78JC0Uq5vkVpn+G8UC+dx0OOaxuia/5wLLEpiQ2MX3rvoTUe+KyIpaU2nlGL\nwPZcDATkitLAnwFkcb21R39wEwzayB3F1OWJnLbWXedQgP84bex/Lm3hB1tl\nJm7JBeebvzm+3JJ0Q1GWYUxMcHWgz/rbIatxUCj8QjDyEJ+koh7lXgv5/dDz\n5M8dONX8bejNa9Ir7d/Q1f1K3I7Q1gz+GFLqb6f674ZLX6EBBZJdgBta2P80\ns4IzVUUZpQ6UzKRdHyvw0SuRkUpq6PFQvAVQ4o8q1STrkfvyLRC9K0wpDO3Q\nWCfeM9NsLL5Qt0RPsRn7NlStiohyuPqw8K1hCg6aGN+f2WKgQjLV8jxfU85E\nVycmFheGwcVlcLZk/FCKovRGgrllFnGhDOOMSutj1YYNoRyo53NVL6ALnX40\nBuaG4QMNp+8YxzxI5fBpUegtJex2O/GLzARcDIpoMWgKm1U42BHPVA5h8GCH\n2Eie0blK58LLbZN86+LByFpma87TXgr0mko8hNbImSA4tjA0CbzQAN8VprNX\nfg==\r\n=W6dY\r\n-----END PGP MESSAGE-----\r\n
\.


--
-- TOC entry 2678 (class 0 OID 16468)
-- Dependencies: 194
-- Data for Name: usermessage; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY usermessage (userid, messageid, username, packetforme, packetforthem, createdate, transactionid, invoiceuserid, invoiceid) FROM stdin;
2f2286e0-7227-4c1f-9627-6abbeeb9c015	1	shibuyashadows736	-----BEGIN PGP MESSAGE-----\r\nVersion: OpenPGP.js VERSION\r\nComment: http://openpgpjs.org\r\n\r\nwYwDl2hj47qazmMBA/0UBEYN5KdP1Ay95UDvgaKMd0AKURqPzTn+obh6CVYg\n0HrtHC+lT78nvXs904t+69Dtr7rks4+YrIdvDk3jjJttwaJEwg6Uh1UxdIee\nA2D9Z5N+QAv/a0RwITSX0BPaZTWbpr2e/fayIxQbSEJdptagHZb54yTRC4aE\nVLdt3FDF89LAKwF3eOIuVkDspzXk/SWea209gMo9Fv70ean6Ac/02Sis9zlV\nDDQbLfq8HHjUFA+2CCPxm37JCiHBY3yMShu2pl+MeoDVjCCtAk1sjQfBfQkQ\nP5l4wZ1x98cnRtmDPLvxzK+q4W022w6eM8ZdiDdHPomcZ6XoYGAT/Q9LeW6K\nDiio4RASLgchvinnu+GylVGR19E1rKwiRXfH8zvL1aBYPqZkYJBx8f+LMU3H\nl3RsNiiLgK+mJE+4+esdqJBdBDHYNCKe/Ro1Lzv0AcAt/Qg8cBQdlqzI7O6+\nmRZLMSp3cr8/cbrQVjWq/yvo0js=\r\n=HRFE\r\n-----END PGP MESSAGE-----\r\n	-----BEGIN PGP MESSAGE-----\r\nVersion: OpenPGP.js VERSION\r\nComment: http://openpgpjs.org\r\n\r\nwYwD0UKqqCoR4xYBA/9DghrebZxW+Ynf8gvKqIU5nco7rtM2R0jYuIvOq+Ub\nXFqz/d6j1DAWjZB84f89x+E0YKGlTtSmuSjQDLRbzwBPKH81LvyHDQZAdoy5\nO/nDL6ta7G2IRXB60+RM7zYSm7LyE3T4zHloOleKKXG6X+gK7tTWPZyhLkxR\nE7YA6HoOGtLAKwEOyS7BNp0APTRCMpeYtCw2rpQ/IqEOhJWbCbYUR3WPUU5F\nXrhEQDOBXezj0pYbWX0KOmOnt7cCU7KWfo8cKiEJ+KSwUl0OuvRkY2OF8W27\n0t20gO3TvSvg0eoxFujar2dpwM4v7ef3djS7drJF83guzRNkqHjUCbCzmdh1\nf6nyd0clN+jel3xi510XT0VvYXzIk/JDsBkys3xeOg0lVtOQSF/TzoIl8Bui\nRLxBp0loCcT7K9G93AYCf4bVpA4taPCbKtuLH8Hcv4HE9YTusaS4gYIU7lGL\n17Xxff22zG6oNE34s/A/fRZp6jg=\r\n=BksL\r\n-----END PGP MESSAGE-----\r\n	2017-06-01 19:39:23.469		\N	\N
2f2286e0-7227-4c1f-9627-6abbeeb9c015	2	shibuyashadows736	-----BEGIN PGP MESSAGE-----\r\nVersion: OpenPGP.js VERSION\r\nComment: http://openpgpjs.org\r\n\r\nwYwDl2hj47qazmMBA/4lRxxZdxYu4av/l7VfV48tDpP7Qx3hU1n7cao4rE+U\nJLHNEa2uH1cJCggf8IyxvVoPye3o0LCWqh4Nqvq9Vd2mBly2Buds2bz4Nqj/\nNO2ZeKiqFZ7ZlFuxmfFmwVVKDVii6+oqy0uHMpZwkeZcP8k71z0l769e3BLc\nzoKUCB30f9LALAGC/R4dk25ihPFbNANWiILbHP11VSoPwHQh3GeyMqi0zVIE\nEtGSzEMWu2VjfBuQDLtFGjK5hiQ/fRvOfvoa7dX0dgapbch0kK4LScFKVBRN\nfoYuQEbiu8uKZrh/PSacctCiPQcNdtXDYqCyrcgluaYX5603i5+izlM40Teb\n8/SFYSebg3xCrllNWBNw+YvzBqOGbQKfm9xVJkVrfsTP6atiFhsjAHzN1Gsq\n5zrDoUyUHEyOu9n/TQIuXYno9N6KSUM76KFVNmLZjXxvyZgipsKBaZQl0Nx7\nM3tsbHOcxR7RfHDTFuLw2SEJcZbi\r\n=KGjm\r\n-----END PGP MESSAGE-----\r\n	-----BEGIN PGP MESSAGE-----\r\nVersion: OpenPGP.js VERSION\r\nComment: http://openpgpjs.org\r\n\r\nwYwD0UKqqCoR4xYBA/wJ/frRREg+GlVFZeOp8yYJ4f2YqLxAfqoU4ypvmZSp\nLNcsGpKvB+nFsu1K+qRoYbyOgb11dNwcAC5nvrhF3awbE5jGIbMAarDUZkxt\nYg6BvAoivqdgvdOngU93evMKYMJeWKnigl2oM5Q6kvT6D9D2SxgeODCkFZFB\nBH0ichkDHdLALAHihT6mAqaLIeGxEsQnyZKxDdwPdclAirpbYWWtlkWsMogH\nHOrYyBlk7qpTG1wMWvslX8+025YnpL6lT6YAVJhhM4pVL0WUNRHokL7FtQ/D\nNj0oqQDa1ii1ZWlh6RuAZ1tNwfbMlssNdTOLPk6xmYEWZPwf1ENisH57ahbp\nNP551ZAwgwyifBD26O0qewVrgW2xz4+ypvUon89gOxV3ulaCf5r3S3Un+1Qd\nJgKkKzwZjLwNxq3/+G8oiIvL++Xfq8ZxMa8YOF7H17FwsYM8k2RyCV5p2t2q\nxjn+UXWTQ9DIRxrAzkILN0enlBiw\r\n=QEYJ\r\n-----END PGP MESSAGE-----\r\n	2017-06-01 19:41:12.987		\N	\N
92e8af98-63da-476c-b9ef-26185bae9607	1	shibuyashadowsb56	-----BEGIN PGP MESSAGE-----\r\nVersion: OpenPGP.js VERSION\r\nComment: http://openpgpjs.org\r\n\r\nwYwD0UKqqCoR4xYBA/9bsq9hz2w2ToRKIVSSPW9IkLwuxuezG18xG+LkTb1Q\n7OmiL4Lu/QDTzn5yS5pts8O0rkRz/abZZXe4MlSs79xm6nycKw8f+Iv5megG\nII6Zy/adzd465n9lxgFi0w2YfyMIFzzU6IV70Y/5+zrKDcsZxSs+wfRilsnp\nMAUbmo9/RdLALwEuGn148Rei7kFegRp/SZZHauNukcAtct2DWtU9UQ5bb9/N\naTuIjyrXsa7I9RfiNru4eeZecChE2CXq27IW+P61hd9UEVXb02sX0VzF2kDg\nuIlRqG0SAAA3uPlRwceKtGZM+Xy89u+9u7uUXkC0fOfwHoywiaCPT+dax8Q5\n/NX95HIpNgAbFmoPfjLngMrcMvHs96LfhwpYg0uOb5VuXQpnIEtc4xEqTwfb\ncPjgmRpUdRdYxIjmmzzuT9qMap1kdzG8XTq+nynKHfggrtda/LLsOHVP1eOw\nJAJHL6mS7zIFHhenFL7gqRcwik/B4J6p\r\n=WOM2\r\n-----END PGP MESSAGE-----\r\n	-----BEGIN PGP MESSAGE-----\r\nVersion: OpenPGP.js VERSION\r\nComment: http://openpgpjs.org\r\n\r\nwYwDl2hj47qazmMBA/0RC8RMJE2VVxTsXdjy8pSDlUZAUxJ6PptHy9LuKKBe\nTUgb0bYATuGz3hEoojHG6UFr5iA2BpkogICPXKTfKx2IKCSVgNcjL5ry5dRX\nviPvfR4+K5Flb/JJZiJgYLRZrw5Db17zO4cP/7UbpsHiHXB98VVqcKJBVMMT\npukOe78g2dLALwEIMByKgrlv9kyGI1oaLQ/zhGBNUQsH/8FY8kehx0wbZQBZ\nxOgYPrNMboBxhXp2odfzCCMEESCtEp/RM1Xkvh09g0O8kyJIxX9rUTjjzMKy\nFh1d73Gx9mhmwhgiF4FWb5T5iAbdMpRj5cDT83tZrqAbfbNaRvGEEm7VQgS3\nlFLHtzui7O3vGUHH6+2uyaYxqrhgNYTQtTgLseTsutcV6JkqIDpKkdOcH6RZ\nbXKe+SMHFM6fI/tz1Z8uWKRmRJ5oagPs46SkXVa6vJABeR0p18129KIw89eB\nog/v5QIH80C91IrVexZX9BH043LSbZr7\r\n=QLMz\r\n-----END PGP MESSAGE-----\r\n	2017-06-01 19:43:26.288		\N	\N
2f2286e0-7227-4c1f-9627-6abbeeb9c015	3	shibuyashadows736	-----BEGIN PGP MESSAGE-----\r\nVersion: OpenPGP.js VERSION\r\nComment: http://openpgpjs.org\r\n\r\nwYwDl2hj47qazmMBA/0SpHGykn/t9A/vcrq0aOJOa7NRXLpPdjSLgg96uflH\nGM3DK4V8SgZHkSCmWvQ0KgxHp/ZPuRhVvGeACWSVog6MZooGgwLNoMUb//BF\nhtMbOs3N4Sj34AO/l+fZ93yRWjFvtGDKLQzU1Ms/yib3K1j1nWvxWFx2Tz5m\n70xbfQ22gNLAKwHfahYmy98fAuZHEJnvpBUD5I5AzeUSi/nbKLxvXkx52igW\nKv8Yanbns48fr7AuwrYqg3oibIUuIxQfO8BWHFpn/OYbyWD/YFGmeiYwpV31\nJPu/uJ+et+tvEy6zHRvoBPxNGoX1rMLJhsjXmo1T6VqutWEOOQrjKVpDZB2o\npWiizqdTZUGho8C9TXfaDO/hrwH6LEWXFF64vHUalXsK6BJgTQHUqhobnyPi\nlzFozpEPo5KL5FpGoc4N+zgcAe8qeYj0aBDU9LCKCdlGJF5o60xPCBikz1zk\nI4OfN+wTJSY+E3neT0TKJxoJHYg=\r\n=a5U2\r\n-----END PGP MESSAGE-----\r\n	-----BEGIN PGP MESSAGE-----\r\nVersion: OpenPGP.js VERSION\r\nComment: http://openpgpjs.org\r\n\r\nwYwD0UKqqCoR4xYBA/44uOn6emQvHrQSixCcaLGuijRAMjrNLSCwWvblJEev\nAc6R5RbJkUdrKJoS2lPie0sh7gnyfRn8zcekrUp6uMJYsxnr/obl7v+xIsk4\n9Hv6u0or/eOphStOwk3ZMgj6/vSBqvdGYxwtU12ABuiwE+SMNASZVnRZMOh7\nAyer8YZqC9LAKwHE6EJ0dHA+GPqCYtWF9BSU73ZvKxhTeuwrgrwVHkCEnv04\nRomQPfcjXx1ecp9DqvHsmeFvPw9PcpXZP7ZLTxtCelm+FgLlvLbkEbQOh9SR\n+vVNmrFqHc38jkqdPcfbf+aR7u8fSpf4dE47DDgVgoVBVKJCQYMgrxgJo16+\nVx778I8k2RFdOOOuUyTh0fW0wDU7/27WooKVTPdDhV1q4PHygHZMJssh//XY\nCxritth8yywGxt8rneQf3ud4jjw6b08LV6AoUdy9rOR7LnMX5Oc31KEh+jcj\nqWq8oz3ToMCkHfbHwt9ChZxivKM=\r\n=Uj+j\r\n-----END PGP MESSAGE-----\r\n	2017-06-06 10:32:42.47		\N	\N
2f2286e0-7227-4c1f-9627-6abbeeb9c015	4	shibuyashadows736	-----BEGIN PGP MESSAGE-----\r\nVersion: OpenPGP.js VERSION\r\nComment: http://openpgpjs.org\r\n\r\nwYwDl2hj47qazmMBBACEJNvtzF9Nja7Gti+2GaijU6X58ghuTEwJ4hl1bpNC\nAlYdpPu6c9FQ3F9futJ1mmFh/EozT892MX7FUygjc4YdNir2PxYUGBmQl8Hh\nUEOTCO8XazIvmFgxTXrMxdDMEO594HggABda0YhwKl1ImJ1EPYmEHq0OGJ/0\nNn5qOBcMYdLALAFuQCZQoNnIJ7sestPlwTd91XaqexyG2EJw9Eg/sE/CaEEG\nqS2TYYfkpXCd8lusMWsqrvRxq+/JYhDxsmQsWlpF6GDS8tT70c+HAzOMnmgQ\nXd0fvjwZYo9RhDqU5d21sUJ3SC1VFnGJObPkeHh6CK5+4roj9tcGZRKyPd0C\nq155Wp3QxccJUEe+qghG8KrgGvyX8EDM6Ymx1eSqcSkcl+NZePsCk4Xg78eT\nE+Z82ZhEPQVCc2jlBdMLC85QCmZfGKo4Lb2UwFCWNM9Zi4f+ADUusy3P1ZBg\nysy7Ve+di8IFyKnIbhip815lyWQN\r\n=MSJS\r\n-----END PGP MESSAGE-----\r\n	-----BEGIN PGP MESSAGE-----\r\nVersion: OpenPGP.js VERSION\r\nComment: http://openpgpjs.org\r\n\r\nwYwD0UKqqCoR4xYBA/9Qn4Ucmhp71XLvVgnBoGDuNXVLcjU7TaMb6yMFEPGG\nGP2+vUZoWMMYuobLDlcSnXJAWFLtaWoVHV/hEbIhycj/CXAkF8KmNB2bLDJA\n4gx4XKQlhxbioFEQMc+9bqGzCsL225FKY7TIVuMl9nk673XEIZ3Jf5fnxo8j\nTnODKi+vBtLALAHsGRI+PHti4wvm9VIyHvhA551201uia5J0V4WNPs9PRa60\nzQmS+XAipwyiVXbosWmjHMAEPm4R2uf9takFmXuwqBAqNOtBiQ9DFpXdcsba\n8X986eoUsi3DEp2h6EDQytUpDP6r/wTKnJEman4hLDGm2MFet7gsDopufuts\ndNvZ1KzMEyJ7nDfLo+UeD42tW8x7DrSn2x/C/iKw000E7fIv1u9GF7+QVVXL\noCXWX0BSWl2Pw5Y76DY3Q0Ol0mWooUQOAe2/sXAwk8AUARLU9SYHA4lefkDP\nLogijWr+rlT9fCtDCRRXSeWRBF2V\r\n=xqHS\r\n-----END PGP MESSAGE-----\r\n	2017-06-06 10:45:35.244		\N	\N
\.


--
-- TOC entry 2679 (class 0 OID 16476)
-- Dependencies: 195
-- Data for Name: usernetwork; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY usernetwork (userid, useridfriend, nodelevel, nodebranch, nodeleaf, packetforfriend, status, addressset, validationhash, category, notify, createdate, updateddate) FROM stdin;
2f2286e0-7227-4c1f-9627-6abbeeb9c015	92e8af98-63da-476c-b9ef-26185bae9607	m/0/1000	m/0	1000	-----BEGIN PGP MESSAGE-----\r\nVersion: OpenPGP.js VERSION\r\nComment: http://openpgpjs.org\r\n\r\nwYwD0UKqqCoR4xYBA/9scEN8+XoxB42642/2wCzZTr8VBXssIZoeM+W0pAKc\nCHIW7Fg28Venjjbsnef+rZMJsOL8B7wQxH77KF8XIJcTfLQMOcv30azgdI2v\nrSMGKZQEeNQF6ZYhV6wIvEOsHHoclF+4DhuzWqsWy7seFXkJ8rLBJdu0Lta4\nnOjbMeLCitLBcwHM8ucgDFi2BzE/8t1Nb6sTzfdyYBXgyevbNp9CE+pqzJI2\nAz5u94b+WTGpGfJrax7l5FLYFxbRtviUtqAOKa4UdiVQEYGWp1YcKF3U6RMo\nVyJ+OBmZbKVQASPk4BC+RKH42iPllTosO/bu9k2NzENHDtp8Clp8+/hE2UsD\n0q6wUHeYVy2lQtXKMTNvnkNmavRGVHSxEARjvh8xYNBmkHmR4IQjvUV9qza9\nYzhkWM0z3fuNcPqtYxY63ZbOQHyT9Xh5sm2I2XaESpJYGUSeBmoSzRlw6znU\npTAXtBjAKQ6mjqXsBw+AZU5vBpKrFxvKeNPubMXzNdgXslACzyq64OI8jseW\nfJR2LM5FBo1I9SrvJAF8hebVrk+NlW93+gBTGpgkFuBKX7VTMD5pTTq1d3gt\necrpusa1pLyfqm+51s4mbIs3hD3imxv24DsxSBCEdcaXE9L9Tx7MfOT5Uvqv\nv3HeNq6uOcaLQ9aM2RjuZRr0/p6JwG1Npr9crCR3ACRkH6kYo6GPVuaGNVS4\nTV70uqGlJ4xysroCaDLIF+EeCl3NHajQWJ1toAjVZXXWZpUimWsgkwNtlg8M\nO6TFnbMP7Os5cXaSGsFQZf12sPsnaXN2giuMP4qYGkyi/hqkrCS17jDl0D4q\no7Qbn6LtUOsBLbH4pVtv9zytwTkAaa01fe/tuR7OVs/np7o8cgThUU0QKnbK\nltBvqDpOkstGCdaEtxRbVHxp9GEKrTXoUw4hmSevUtAr\r\n=/AC6\r\n-----END PGP MESSAGE-----\r\n	1	-----BEGIN PGP MESSAGE-----\r\nVersion: OpenPGP.js VERSION\r\nComment: http://openpgpjs.org\r\n\r\n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\r\n=dVuY\r\n-----END PGP MESSAGE-----\r\n	c5c7b7d35407443d72cdb5dbe329e959bda3f9d3	\N	1	2017-06-01 12:41:15.463	2017-06-01 19:10:26.141
92e8af98-63da-476c-b9ef-26185bae9607	2f2286e0-7227-4c1f-9627-6abbeeb9c015	m/0/1000	m/0	1000	-----BEGIN PGP MESSAGE-----\r\nVersion: OpenPGP.js VERSION\r\nComment: http://openpgpjs.org\r\n\r\nwYwDl2hj47qazmMBA/0Up26nRCyseAhvzCeXQOdM1DbD+Y7GZrzaNX0cGgEd\nY8D5BzoUdDdI6s4rg03YcKItobzxskqw9pqqbVk+H2fke3Stf2+ELIikSkuk\nLZ1uwSzyrTHn804kFlKNDq2W4uIi2Gtjm9p3rGo7Uc2nZDK8kmCrmxTGa6D7\n6t4HPjYkg9LBcwHv2VWHMtxIiA53/jeDqCZ/wn0PWPVYuMH/hqjdRqNP8Huf\npsBdOskuMKdoUNEdc3Mnbp/2MYDyDDU5F5l5p5ijP9anfjGHesQpSiiCKa6i\nBhEoeIIdX0RznUEbg4ZXkwKtSZRAFLXRQ6Mz76mdfh2jRmj0Wc35yXK/qSsl\nvghtYatBZPlD2QyU0jn2s+K3+Szp9w/8BaqxpfrJS1mWCbet6Kjxh6DU2iFe\nI9/03TKsKsAw92jLk0bLIKbViwTRA0gR+Yk7qtaP2RstlPcxk2O9mQW1Rp7T\nmnT66IQw5Hjj8rtSxP8GTTvUIh9dAIm/WUPX6pWb3me2+elX7Yp06cbSTRix\nBf3PPS3zLzWaj9TGc3syHyCQgm4x6WqXVpIDNAnBm9ptM0b8sQ4iRzUrH5ue\nfmQ+UaIgkoO9dAO5bOcTlbvBVfVpQRF4tYucxmJyI4yIgWHlvg+dER9klxYX\nEc1Hn/4Ck6tNEC/1q8wmUNTJlHlR63iYwgYDBFcHKDrBiz0EWS9aoYd+T0ge\n//mxsFpz/A5VsUXzvU0eMaNO50NBFda1xLfIIWeYHvXlau8RLkEceEPLM1JS\nk8AD0mg9/++Xg3TWZOCaB4UjbvMtxcd+F6aB49Pf2usuYHki8FqqlVSvLQDJ\nIBwYVU/TlGPbdmTfMWZ5kNfuXGzVbAnqUFWKoIJp/Pz/th9M/Zs6u3ZOV7hi\nnrwri+mdzGvEEpg4/ioWj2djzoPAvDCP26FANX+A4ApK\r\n=7qYL\r\n-----END PGP MESSAGE-----\r\n	1	-----BEGIN PGP MESSAGE-----\r\nVersion: OpenPGP.js VERSION\r\nComment: http://openpgpjs.org\r\n\r\n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\r\n=0QeM\r\n-----END PGP MESSAGE-----\r\n	6c6cd67ec933ac98069968c2ada9725ceae1434d	\N	1	2017-06-01 13:31:04.433	2017-06-01 19:10:00.804
85a009cd-370a-404e-9586-5775984e5674	9063f4dc-d9c4-47ae-ba12-d5050789f4b0	m/0/1000	m/0	1000	-----BEGIN PGP MESSAGE-----\r\nVersion: OpenPGP.js VERSION\r\nComment: http://openpgpjs.org\r\n\r\nwYwD4YFBzF6WINIBA/9RrmzvbLOoqiWblE9yIRIOopJYaVKiJcUF6zK7bLZZ\nLrP7KVgCq3+HePAZyd0t/rsDGIkDU3ZL5PR96aqRwXajECJhyINqJEQPj0M6\npoh7k63A3vHggb8+ESP3Qam35B5Y3s7JkJw+yp9b9q2PhU2L8wfbI7j89jij\ntp4PhleARdLBcwGY2Lfd0lyQ9EK5sk/6acLjoIzjW5rJlQkSBGyBfsfEvBw0\nf+VFr/WuX4yHlwxgADb31siotichic0JdO+GJvpe6FkxoBJDzIrNl5b4kKcr\nmomQq4ucpt2oPkyj/kqFOgjzZ0HfyorgyDjQnVwg3k912dD+YeAr4WMGENtY\nxkcxPvkWZiHnuz0JZ16wdCWqyBdydJJJ4pGREq2xf9nvbBPIdXzizN/u/wpW\nYGrlnFLufvgCIgAcWC3kfuI5dtB8nCEHRtlXt9dJvURsVkoPNfQ/U3WXI/vu\nJ0d7jSji5PlfIzFQ8FOrgPKGUnPN9BbdHlEni+mTbAYvf1Suqj/f/Srmz3Bw\nPM9l3WXOu+xE8i+dsLnNwFTHkVA3/MMKyg+2/bzZxrNpKbYZqb+lHJxGaau+\nxkPiRtfsW/yptHxHvpTBITTDnohKsPf/rMDb6oQ/KANoaUYyRe1x5mkJeZS3\noq86pQpXHXGx8kROI5SEK1uMAVvkqQIVZ/e2z4H+z0A/Go60wbWjzsUMmOAQ\nYNr/9HHq/6f0xPQa0+KIHLHJ71ZVVDHpyLrffn2Qm+Cpd/x3YbjbWlg4+k0z\nCNejAZ9CbMAG+iN/5sYkx7ONmV29vci94QxKUyVr/w0tgIsqftlRiUmeuhbh\niLQL8LHUtQLwtmXJjdFDM+RssSPdEng6kMmZU+NAQ3MbJ1Mepp6yH3m4LayD\nmzS8q6hTSrvI4whxeNZwc4sNaKVTyeh29Jsh6RD8CI/Z\r\n=A1JV\r\n-----END PGP MESSAGE-----\r\n	1	-----BEGIN PGP MESSAGE-----\r\nVersion: OpenPGP.js VERSION\r\nComment: http://openpgpjs.org\r\n\r\n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\r\n=eQVA\r\n-----END PGP MESSAGE-----\r\n	62008010da9bb30ca5f3a1deb001e9f64c96d94b	\N	1	2017-06-13 08:03:17.589	2017-06-13 08:04:01.595
9063f4dc-d9c4-47ae-ba12-d5050789f4b0	85a009cd-370a-404e-9586-5775984e5674	m/0/1000	m/0	1000	-----BEGIN PGP MESSAGE-----\r\nVersion: OpenPGP.js VERSION\r\nComment: http://openpgpjs.org\r\n\r\nwYwD/0R7xcMBCroBA/0cfhIGmneLed7bbLJLxwgyi2c7I80+LqNbZnRCbBWa\nQasZ9JAfJm4dLLMYFLy+cVqmBVACeqqMAiwTcGtlhTNxMTYNfLtx0fn4C+gC\nN/dTyuz7/N+Tu/j0axrJLesdugbUUecD9MdY311lbR1CI84ehZYvlOWUVy5O\nDct+6NqI09LBcwHF/uv0nOSJx/nQzhF15ziWKOu50z6siV3ehiigPGF2xJTw\n3NFIS5UU43nVnt5jqFGmDTj2yMkUwrfDCciHlPUHCdBW0bsSRoVKXnqTf3NQ\nSX3Mhj3iEDc2hFmFfKhgVgxf3qUIIXAOEPIyl0JLsM2Fe7Mjkrvh3w4tjvlw\neCFlTV4VajZHNXC6PvJ3ZevAKOstHBg1lP3zaggomYU949+nNrb30OiGj77/\nYPNsyVi/48HJealmKcWw9AtsNPGYcj+Bpp3RioWm+sif+sxTHbEj3OisjAh0\n5AZi3WRZ/VBb2qMSjlAE+ZIfuESgYqycYR0b+iFLus4iUcGkHwMcM/3OCpb0\nxaMJR5h6O+p/S5IE4gwFtjNMRsbX1zKX5LeaVK4l1z8LRuTL3+U+yksgTUGc\nedVqkUW063MFFsb+kZp/b81xVYu+9ywfYrB49+b1+CBcataf4Jq9JVWEmSco\nuhXAYCQnd2ZttxV4vkdkUSZpK8BHj6ZM5azEnDk1sT8STYlg/DYU7qoJeHpJ\nBjd2VTPsMPebIqRuqQe2QWSYWBeU6W9OESiLXzu106H6518S+NakE6MKu6Za\n+RrJ+E8QvMzSYQmOEX6O+OKkMMf8+faEUqeeAbLf1hZDt2DT0fcXNamqPROq\noMj8AxeGs1Rkl2q7rP9+UaffS149i4hrM+1uQiC/WkvGXpeq6qWbXLvWL7aI\nCP6IphDanpv4AT9VR/TAKaI2TW2e1WnBgf3ebfSThc0m\r\n=nX99\r\n-----END PGP MESSAGE-----\r\n	1	-----BEGIN PGP MESSAGE-----\r\nVersion: OpenPGP.js VERSION\r\nComment: http://openpgpjs.org\r\n\r\n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\r\n=i6x7\r\n-----END PGP MESSAGE-----\r\n	4a5f4a957444790b475a026b2b11502aaddcd3b4	\N	1	2017-06-13 08:03:39.042	2017-06-13 08:04:19.296
\.


--
-- TOC entry 2681 (class 0 OID 16486)
-- Dependencies: 197
-- Data for Name: usernetworkcategory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY usernetworkcategory (categoryid, name) FROM stdin;
\.


--
-- TOC entry 2712 (class 0 OID 0)
-- Dependencies: 196
-- Name: usernetworkcategory_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('usernetworkcategory_seq', 1, false);


--
-- TOC entry 2682 (class 0 OID 16492)
-- Dependencies: 198
-- Data for Name: userprofile; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY userprofile (userid, profileimage, status, invoicetax, offlinekeybackup, seclevel) FROM stdin;
4619c475-b6d1-47c9-ab00-23c9125d00b1	\N	\N	\N	1	\N
a9e3ec68-9ca6-46ac-bf41-ac46d3fbff0d	\N	\N	\N	1	\N
\.


--
-- TOC entry 2683 (class 0 OID 16497)
-- Dependencies: 199
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY users (userid, walletid, username, firstname, lastname, userpublickey, userpayload, iv) FROM stdin;
7588d891-3e0d-423b-9e43-2d48d6013b26	0af18ebca0a49b3267e20cfbb7bcc685d59d3be0d16817bd637777933c8be6be	shibuyashadows8564			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	7b2b50b885e66d0009b874e6fe62341601a5015f7f2f8ff2f0b2a031c774f883
d585a366-ced0-4421-bb4c-62a63209c6da	0d91c8a668791d7605d2067c307926bd56a9d07c9f492632d499c2b9ba5ad853	shibuyashadows019			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	a6337ec0bfb974b88dfe6bc2a46badca760b71d48104eabde9cf779e1e04b78a
c572ce72-86a8-4acd-9199-c71d709b2b13	3039ea9cf03f90aead7b772a8fd327ae4188741759575d2c9eef0cb8df702912	shibuyashadows823			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	f0314c21fcafe7c37f4bd6eac04d8a744a26ca88172c23906a5e4c852a838196
949e5ac4-9934-463a-a99c-26bc9e053fc9	8dc3ff0e9df2a99eb045be1da0fa0bef319c3802a4f68a6eaca3e70c36bdd5b1	shibuyashadows453			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	8dc5d9bef15c404555e7b5df555455f58021b743b574a4754fe6636ee333b52b
d6a6eb89-2727-4122-a2ac-c7357b18ee2f	c10bd4f03324f9139fd748f09241b8444266c789c946e023c606c595a30f3819	shibuyashadows457			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
7910d1a1-7bac-450c-b7dc-19a59f7b6ab0	03dc241270d18341948e0b57b14a74f7809206839a1bde2b6936d5ca7cbceadc	shibuyashadows902			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	d910fe5527011f4427f1f3f3cc66837bfad82367158873ca8ebcfb0f87cc43d4
af268fcb-0091-452e-8d2a-f26776abca29	6e58e78302664bfa2bab1a6ea1516c6ff3c8576db2bccbd067efe4071bfe9358	shibuyashadows943			ZMoeE84j8nVO5YXiqgi6zuHv6n7XSCAOwRZEd0+QgG9rX2eRKPh9Co1tuVDHrQlnmxIcy6btTEjPHkI7jRNP/f9LutWwQMm0Ey+w4M1tcTjywletgvkafhuDs//R4ptp3PsAD3jcbGuh8BF6wOmtew7WbVLt/Wt+2aN2wEgPawB4RqKCIEytykkastnpk7PafPbGPLSxBeUK5yyXg3s2/Pz2V7yzwfzuQgY/5CfmvZpzN2I/8D5umo4o8pRTlrcwLIhqfTfhVs/F/8iQCNXuCJWBJf4cFN68M+uzr3IXuNgQrOlFd1+z4H1glWf/KgZHhwkCuAKUQ3S5WeqGsAA4ja5ooIg1amdbLKsbvQoEgCL6ZEJs59xsLtQVHi1KBB+u8QipyKDMeZ8EJZa8vmeJ3UchINhkLTjtNQ7OgM7uJ5NmE5xmZRVthfR2TOgTuL+D/zsPt7RS7+BqwJlqyGk2xtcOIfAyKQd3a8B/AEyHsEmv45MS9KW1S3O1lihnmohxPabaoKqBhrKrX7DUVmhmBQEKSLpA6vQnEsyda+IrmLpwecQslug3Vx7th6YEvHNVsia/StGoGuamxqtr99LnMwSP0jW0/Mn7hONddemYQpcL7aAbjsSP+/5ka9ukTjQ1UCx+pQROiXLlCTMXU6KzxnVF9/Uuf9yzg5gFwmvIfa3nYMRIr5HDE2uadhJeDW8Pn9fDJOsb5H54cI/KbOPVVxVo07K3rFtgmDgML7eV6Xqu7wUmAmuyj9N/czfMUJsIP5+/FhW5aRoc+F7qP25pfR/dNI0wB0MPL0VHEtzjBrU8cTlme5nhcRbIJSIzb/ybK1JYRyDc8yG6NT4ZT1084V+jS40YU33XdwOu1I7LGs2M/UvYM4y9U93BJmBDSO7o454GysC9g3+fAKlKVf99WtXO8urFrnDEExTVlj+dgqAOuBbg5QgUfNJpt9BHD0o41v2k0TBuylYLNI4HxCaE+CsFxzr2HsWLET5v0goDoArQayOxOKLhVMGGsG/6OIXCmD+I9lZosUdqYUxYC6dnZqXd3UwvZh1Hay0cCeu9uOkalBp7Hq2oXmeahOPnA32J6vL3bNsAcyLIh2UiQIqpRggO4DyCo5U+Ov639MtA7gaQxUS4PuUYH3gLOBZWY+WivvDqSI1Wtw5jIpIH4YQcMc/7PE7XUbw+05Y6Y62zykjN9UWRU3i238FuM4oGqFy31FBDaWWciN5fyk8+oxdaO5BQYQGoBvVC4C2yuMJOKaFXD54XF2PJiHM4StR49k8H7zozPJyzAC4qCiAw0YaNqs+gPB/yUSkVt8Ip5GdL1LJM1ki+hIFTbIEEiOwIBDv9HPOdSL5R1IrwWNhcRLYeFG46lNTMW6syo7wUjA1t28ATVZP6rbWaBVbiJyhL1n8Ri+YNaNo4sfEiWdx9T05xtOV9rgsahpnldFCP4pfCX91xkarBuHP+iBFHrpP2xOM3Ap27hT0jyCP2C7N97M0WL62MOICnuEs8TZeTKtZQbP8DawIgvZ0Oa/KYhaE3gjyQR7j4gkKjvKGzupycMCftHYZnzk3aR4TOHYv6RFKmT2x3d+cTMTfqcSEnMJtyWbxTaMEf6sHwbfrkatKymunY75AEmsjR51SUyuL/oNWt9MMAwHyKvJ/W0Si6wqplQ2Nxt9O1YxA2WOejMo8x7/t+EFe8AXXOeYLOpsK9MMlyj/H4LG41vK8lLqHTijCIjcyk3b6CWftguR10jBksSw6WDMKblHcPCZF28cyzoxfYCv1muBL7Wljr3nkOY0iXBjf6GvsPrL6qqwvVTNbmQxcpqGyz7/gOSwcxdRukuE/07NlNOxLp8NUJILRxg70L3nf70KjH6NMHB6ApT4gPL74oQIn7/9WVcoyBsLaZ2+1XjB35qb24uhDxzT6n0ZYfBOkEqp0z9Nqo2DKX+k73R0F7lWTPWOHP9SRIQeFg5RdY7fgyLV3m1Wh/ZEfrnUik/PyolduZ4x8O6WmkWZ4RVC0G+9uiXXtCVT3fFAz4v1vl3B2Q7qx17Qi4KWzhuFhiFCdmVDYT2EnxJPHf3VfQp0mApqEFz6bkNmCTc9m7zdYpamOuiW8H/v2n6DI3x6CUf87Exb2URsfiefpX4nhssaNB5WLF1audMav88tWZDcxg2J+AogZueapYhpnkU0LxXfmMpOEsT86Wgk9PKtmwPUACYv1hv19Y7n+hBYaraTVofB/dE5ugNcsJm3scQnaZJott/GBdaYnGXKEl5Y63drRCnp3kuhq7VYaq1E2gWNguOGSrly5NoFiNDPhDXU3Mp4egIoYBvD8+i8Rw4Oyp3yClFg5eRq6eC2wtR0EVpWPjixelM/9JXDVqmzpiFhE9VJKsdzEfaxj2EH9AYAEPv/rCj7kU+xUmZb79A20OpWrCpeuxa9jwt7CWl2FM2UJMKr1xPNF/irgBWu4KJtzcfEZ3AWwxPV+0M+VYMpl4RsuHKR8rtIXkhScBEsV1wgM0BrpB6gAfepkTdGOncvs3fYnPekktgJqkhv1Q2P9Gk3Xf+6is10NxLFXWa2cD7Pu5BT0gA7ACTZ1aMUn/I1czASUnwghHVmHIgk6D/KA42TnWl2cuDG0WUOXhJK+fHGBq821/ixrSh4D8W8Mgus9C8nzO7n1agG5oQUX0NP+IkbG/BnbFpJQP1XzEnna5fYTiyPDByTiewScjI+nfqLOddm8vVTU0OcPRUPGcaPhrKFhtvArsjM6xee9pTpgY9QDuZtURMp637IABVhRLiz8EMJyoSQ==	hlcaChplelaofFQ38uq1dyAdB5ZtQc5CL3zqT1s2BuL9DTOsM8kugREUbemtes10B05h6EZbdOeiiGxkcN6IZ+mur7xUGhLlmFJSH0UtQ80Buyc0eTn7EwnVFMnkY+H4bxu0MY1eUCkHCaqdRtOlFszCvozqMkLiUX8F0c7y++20O8iAMlZ9AarR2Nlohmx/CkYyN5kXQuNDaNfRLXSS8q6ZKm9g3OjXSZst7NF1vXgMAeTHycg7f0OPiGJ9oz5ah4akPu+V64ej4BlOXGL/33KveCRFibVLU6DOLaQ6C0HDOJ7Wah2ukSnHj1j1zQQeo11n6oC6TIrKReDLed6dv1g2O+2pk3tjERxf3BZWudJN+XsksgcteOJ3wEADnlQGa5rbRQyR7UdJaqzff8seNb8ku9VHFhrztIw8O6xmYJFCsvgAvpo5ldTiY6gpxDkI3VbVQdY3zJ0v0Pu7xhbbri3Zx0JuY55TwyCvf8RxDXMIqjU7OFYNRmXGL0TPfomyHCVmGnnOfk2XopoLWwIybFVw+DxRVL9vh0u8GXl/qK8FvFBDaTya+fU7+176HBNU9YXFzkP+/qoEV9+ZfiQ4yLtoI97i5FS4FP7MJqwfOqYzrMUM0hk0wONvTff1+UebNrdnAjlti6i9ct48GmuP4ZhGlXsA1PyARQV1tkWEit3cupbvToct/6NJmLUGTygjJLkkdG5wSGOcPzb8YP2B87P3bc2CpLJfLqZrHb/eZyqngJbSHSEETpsUXaEEoTGzl5Wmvz62NoB+ot0rdtdaSUyGAJ77VLM3GGXzUFZQ1AbieiNfvM02+h3IXhpod5UzwgiPsHLLJ5l75Lf7QA1O3v5AluCIlpw7ZRJ4bXEM3yH+rI+spxqqZhuufrTyjKFGqn48Iv8TF52/vS9lYsWn5iTTNq4+4HB25Kp0LjG6EzdEfjq83qr3aL1rLwSlAOkc1VYrYR8ZmUDdGyDKdOiKY3qhuhnpzd9oYdxJgQDPc02ByUY/rxLQ3LFX+6Q5UAwneNS5kSQOR1rzCjZcGA0dmNv2sXamrqVnk69j/3lsi9kA2ZCTYqDmLqMbPc2JRwjxuR8hut5BrQoPYTGxAOXBcgVVlPaI09Bivr8XYfp5w2xO2zP0lA18VV7dkyx2TOxtlObc0T2P5Em/BJM1rVAKL9bMRCyYd9HbMcTlBWxfA5N4r0pDDfLZxfrxKQodsbkNLZ+73P1CtzEq+qK/uaZvy8GgwyOroa4QOz4Cy1FKctAm7DcD9EVhoiZR8I15lK+FzE/EjZwhPSLVJSByrz9ljV6B1yaL9V++yPXAcNNZE6ijdaHqpY2cW5krRORiv2r0Ix2SAihzv0sM/r84O7a44FPLRWsogAgYDJYmUQqWJojyIu0QXa99kHm2aH+/xjqlOgmG8omnUEXmjfhg1eB2gxvuFDUollyU2dYpdLYhEQox8f/I0kyoysNmmYfh8ge413D2Svwmb5pvFCorHuohQAtyAqTIgKPlUGfkZON0SMcmAXPomAkJs6HYYJPSZ+ieXy03Ta7rUvaK8rgBKN8LgaIwbPXpjyY1G8khAzxOEIMVUZ4AVYECSjVNyE59KgcnEIsHJDxYNie4YNrTAEVC1VKCE+T3WGHY8hR5yVwZGLPwAc/XpwC5QIZCBYwj1ZogtPhyhxoCgl4mdjwK/Ztm0KInCbmRO0fHsHhsoCTGXTEkM+uF4j8/tirXqKlTPSpgo823NNuZWuVtcIkcUiA5mNg3pJBmoggWf8OemO+4cCdf5qUcrRR1LtvSyJQKuL8GFtpgi//kr27Q6dEmMmSbQCUMl7cYCbwqkXhNw0daSXZtcrnQM/CqxEaBWvqs75w1DYZneq2izRTHHCnz4UV/oGvp4FTCApoYsuM4mdUm/9txnB6rw2Ge+PWhkh0nUtb6JKtvESFHAiyfrJroWpCrrfyUSnWk+C6+QvVQjYHyRORn0Hr1TPmtgU+LUyeVlTsd/dhoQGAKlbXnwbGabKafZ8Hotoyn5HaEhCfs3eP2beVFDQgKrxuUV7X2UyKhWLQ9JEUZFL/o+iF44impAv+XiaXtAm1QYEFsVX3LyEDqqd9iT5LMZNUqzKO3kR10BIZVxioSj1161kvfD8N79WZDBlC1LSx//dPV7p24tVqG8VolPopJUuQnAJ4NzDfIxt0GtEjfhl+1tWBIAAPDRdYquKxupm2H+rZPO/8HwnFEmzn+O/nGyk5m9B2BBbdSL/HGu1Jdk2gBhN9uAxITR6P0h5pWTFGqYA/Tkd3/2gT4oocIm2gpBLshk3YaEzQJ+Cn2Ieuc1uodU3qXcNJSgVsIoxCH6oOSMkp9ZoBO10KqjTGpNH3eSQT44pPMGqPBs+pgTahejcRdbEpDmIYqAo1AuherqGt0NgdvAh1wU0nHY7Bm+8vrNnn41rGVTqhG9nxx00xcInZ9lvy0Qhr/HvU5mji2+/CoEbJPlyKqBEoGqaLyzx+pG9R2ruPJvJwooczBLjpbUZkd+tpQnI5Fredk1Qm7jLTFMqiY9SQ3B0ql4EQS1EK9s+nxVt2ExRXbGbryR0aSJTw+AU+V1BKUGd3Gfej58sez72A6UDPCXzfcdMl/djz7mSRY+yry2Grk3N1Hln4KeWoQq8FGaM3pcrdIMAgxG/fH+CnG26lcQsZ2POw622hGcDjd9IZ77OelveT+hS+Ob0/7ofbSCe5fE7/L07VTFQQyT6lzXo3F778Z2svy8wZJwkG+wVmxmY84rpUpsxJUtyxuiQGjVC7IfHP37tJdy1lPOWKIVMJs4aAY8JKHYvlxGQT1BYvx0qDTR0YqoqCKHFvjntc1/ZA54hDAeHVGpNE7iasfzSkRYh9eQImRFh7WiZq3Eex0YArZAYXO8/DtvlFXneBkfTUm4brKYt1YTwcIO87jV0Cts1ZwMtqXoCTNu8UhQNjIqCdcNiN1uId39jKqjY3nI4XV+oH/HIpvZdNq5k1G50gXJleGMmxfQ/5DaxvsHq7ByAsCr3QppYgBAweJdIA2f3v56zHWYspGPV0l8HpdC86vstd+DnEKN3mqVmM5lQVsBcARQ6Xy2zULAyZJ1vBJwoFT6PNaPrLsw9QXxkz5VsU3Sm2iNRCJX9mzMJy2YNh5mWIh/BqbePTqr++EG1ud3VtyBMmJDG/wzGbaIZ5VMwT1Zj+xxwqUnCVggpvv+i0U6yWSdUE2O6eFUOJn0H1/wY/SOj3fO/9wfjmomzj6r2mdzmEtcO3d7Bzec0DiQBB+wABnPxENXguMpbLwi1AiEElvpKkKr6ZaZNs6IPd/VSPFRQFCRvRzG4tBRazyg1BHTqHMAfisuI0VuC3MdMZPo4/JXyC3a7hOclGHEiNzhiH31VB6JJOsETj7CxWkjZTBAQJdokqCIpnN9MYLhvckynxQjFUKEogPhpnV/YdN6fttqeS4KHWmazFSKAYwbJ/dj6t1ibnsg+nPuWpls2AnpWRTixltLHjpuzyy9VHL01Hpus/cZEsvZ2NEzBkx+mE1xxinvLm+Mea8PcOt/RZTYltU8wq+Xixpwn/39crPUsIxGFYKV68mhAvUnSGUZzz3UactOTwqJmdx5+5eQ07iq359tIXnExXf6PpHX8QUvVWb647dwVdLPhilHrOPzLWGLeFoLFGA9gcP+BRxfGmj42rlCCV9EJoDoGOho6VzZSdBPMuZ9eObY+Ty1Yv+8IW/Yh1Mw4VgKKZHzeIqaQ6QRDBlFUVJG+RIrBy/VjXIsHvZEB8pJd9U8f9gUgh8MlRlxPeOskLs+H8NRHpF3bm6b9r15k5mrrE2NFMWMEF0ZfL/x2vnk/FT77ySCiHpkkGId5aUv5TcPFZ+gBVR1v14+RwwI62PyCQ2lXjigIGnizETV1QoX69tZzVqGNm7sacNv5bjyfZbVDMI/V4OAJXZKEemGGtItez7Zj/EOmPcMD9fG7hoYJLBaM8pLZpA8mTEfU9XzeCVso49H79au0qtlk1CvZRHA29rszsZuMuMtvANja1OGja/iyBZCuyrpRODjeig/buDrFFsu3rv8BA+VNWgzCR51FHJ70EFdhhJSZ/MIzyzQUmbVSmjwAF4pcG9blBsE7VoltBnzc+Z+5jxHxAImCSDKafsSSUDJkmXXMoto53LnvvKhGeuC780eANBfJZ5zvM5fwMyPVFuKdROk/OlshLfEmA+isc5XAfiVDQyJwV5HgQ0iBH6/lGmUxdFPtr583u4PI2UG92huUYFT8TX8ft8nA==	a16ff1a042916d522ed4f24a34f0bbcb8e585443fcb5107da4cb66f68a927731
2eb99598-2bad-4f2f-ab65-ef44965f04b3	d11210844e7b24c78de54b254b008d33b82e06303bdd2ac6449717f4a8bed844	shibuyashadows946			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
0d8073c8-c36e-49b4-8a01-c572c7cef223	4298111cb827f99d8ed41047ef20df4cccb5affde2a20140b028ae112d8fd1d4	shibuyashadows949			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
4323ef94-7249-444e-90af-c6322d26477c	ea507dd2783bb201fe7ed5d7462328ad5d7d1e370c7a731dbe43434b2ef5beeb	shibuyashadows951			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	672495a46b8aa99fe268871c447141bc9514ede9efa4323dc6dfb7f8167522dc
89415b05-7106-457d-9baf-43dfaad2c93a	f952b7ccf52fbebb04859d482474ef46fb37d4f5e63f546f563c5811828096bf	shibuyashadows905			+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	0729a680a81a532ca8060493b9b35ee44cc15362f1eeda4f7c4aba665e52f15a
92e8af98-63da-476c-b9ef-26185bae9607	3e545f317e0fe3289fbc6a641244f6b22362c45eb102cb479036fd5382fbbc9c	shibuyashadows736			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	eaea0539acedb11c9fff060eda8617a445631f2b13400475981059f6fac20b07
2f2286e0-7227-4c1f-9627-6abbeeb9c015	1a4ea9f16cf1459789fbfefbda20363096c11939a215442129f6798223ebdd9a	shibuyashadowsb56			ARUp42v3Qg0IY84qmZn/mr0zXul5P9JAlqILYWSenzqfgXcGWYmbPlgPob3O7dvmtiWep1Hmgu6xdBWlgywrf4a98X2kHLdIU+Y4CaulrBvrDJaqw1zA8WA8IwWHkTMH0Ts5mxPHfUolbexClhIqAtuPWx11EhlynoWzxkkOeYCgj3AQq9xtxu2sHL2nEQY3CDhwPQdpdv4tTXsySrMRCHW257FAc2Hkk0p8KPzRtTwpFGHUwkE4kyxqt4ut1u5rjkTl9NLxYKm5p50zUN7iVB2Fzwcscbxd1LzkShaDJfYrJUQCRbCSgUwMCB4djeSeiuQvJCmOKbF+eoJRwB1HQQheqqSBWg5klYeMDbZeh/lRJ3bZkAynYuTxO24bZx6MYNnLHdIPYdlY30khjr3Oc1/7/tC8sOY4lMf3JAXSiOfFUpCQO8mQ/v7qdaCC+GNPKDdDkg4lEC8ivFUBJm5XDjqWqHG3py8RlXSv8hxqyUqwnIEs5pyJxeW/Kapax4aB0MaPFKMmb9b+Fjo301atiIgi1K7hGRghCuSJF8cq7AiD7Zy72P1DKKrhRxD1gB5ImT0Ei2aRuW+vQaMjflzRcCPHkUmwbtWbNXZ0GlOyS6jME5EDu5j/FW8KEk/foprChM9FFwQGtZB9qpwp6SLpCVmpPW9SUlDzbf3K4QgNxrTeNOgtnz9Z9sk8gKongqE4gICwc9DfrFkJ+EDufH/8EGdyfLgoGua8n5pGW3Tsz+55jLsBA4fJDnhwqDVcKGaA0BuoKaXQk4tR2sYfJ3eKLrAsHZGrnKM+zrInggCgo5nn2uMk+HfVbZs5R5xIG7jWrEVgR5pj3U011QNTRonV6rOlAmCFK1ZRv/Y0oogWUv664fwf1ArZBXw2hwMwqrkUI2A4ohWr4rAdST6V6gn2tbCnCUUueEO/+cZOmDV1RIdZfKW1siY0j0k1GnTPeTOsDmvA7zj+VFmBa73WoD6ZvFeNV5HgaYO2KsSnoC30Gqx1VeY5Ajb6dm7h4gzYVEgGD4r5jTjBD6g6opexis4mAnh4NrLupf8p/bATmp2JHacV8LGEEkKnOIBV4tKiBzUk4oWhrTDKzEaahuJ2vChVJlc+ewPfyxrpK96FCJR2loTU6dTAWu/aY40VCD4irRskn5JXAWS04TmAHT/c0dBB/NpkLChP7WDnG1x5uiS1eUoUNwU5RnvBkYhdfgrG2I1auMLg9MqAnJIiqGY2FR0BdivStrrME/z9kf14Yff6XjjC7sJeOkomUFyW4bpGi8eY20mwzfKs9F1+GimX6gYRsf+LKk+BjlqWcYmP+292RCmIF6o0RFQzxW6fVRIUVfwgkCOTWHhPGcktuYCH43n3orA+yjFFJ+v5tYO3olbN0u2TSPsLZlVYwzgtWNgEPU1NuLM1eb53Pzen+4mjaUmKTerm4pC8q+viTfNllkWL5fnLbntCixBwjtqtwz221jf2UguQagvx6pPdrXazQeimAgbMB3GpL7F1stNx+POvAy7+5JcD5Wx7eqoRYKkjNEoWiA6YeZvRb4grvvQYTzZJ5TNeBrmOrf5KHneVT0OF70jSACUU9i5Ro4B2UuC+B5RCDBOV97wdIRLurK5Uo6qoHnt38j3MFkDjRTqKyBESIbDyWk+GjWLwh6Z8WNX4BILbSzi7GYpQs5SKbxe/cHr8eHyrVqtfvADRMtEu5aGCa9vzW5psFrU3RwkQC14pAcKsWF0rfN6Sax3qRsCRpuBYlSjk8VFlfClEY4kKeK3NTabDmaT7iIGjxdSjU73tCfGIkjOtp3KqpXD1Qe08cj0mC2PdpVKOjbD3ta+vtgZ2l+CsA4wX7HFRRcRknGhU4naBFx70zLeATdBqPqXmoqwS3U4AJtyObcJzmHGVqjOFJmnfygZPxpf7VOz3323v1LJIMnKwHa0/ipyF1B7bMD/v2Wad41NL967qicsCxxaNX/MyQPhP02veV95+hYNCtUceLN1aZ/mDPHge/2Kv7Rw/yJWYJvbdswJ3kZ/cX4I/sbWvm7QRL6q9+Cpn5v+/RZkWhT2o3gtn0MUrWANFl7sdyaLgl/iIe1ElGzFQYJfBx3mK//ahJ7xWzNeUKa8wQcgfCBAgUMTlroZ3s7d7TcusSEMogYt3Q0BQSW3zs9KoZBALqYVlWANFwCVq07Qhb4JryUCeBQtvYaXw/R5SEV46gAsLlMdZCdWz366uDYRubo3jkHEsyOGcIiavGlWPEJ8aiXL+xxgZo/nE98EpSEkOFzwqlP4ce1Ep/oX9/NWYCL3oI5L+NHVfrNZF5Aw0LuNiFMbrnyROEfcniTN5aikvGOph3EtA1UIstp7Mg98eevEh0nbGf+4vVzj6p2EGRI9Yl71RdZvxRdznHPxwZNEbZG+ipEVZagV1iCrmIceZLZmztSMBa1iZb2Xhs10cQ81fxEc6dVg2y/zXb4PPkzXZ0DXHTklVDD9gcdvh5q9YTjCe6MHNwd05LiY/0VO8rGjh+rC7EOfvJfetbAH4NUpdbI5DiXgFQN6jM9dB9JENCvaYoughR+ieLRpHBio6cBzBt94VnU7FyJ9iWpGQjBLX/ns7bnY7miA9YwpzFu8dtJxUVdp67iQHLh67P0Yrs9m5MzKZYDdv+xXgOnzULYf8ewypxDoRMYYDYcSWm0pIS3f34OztcX520eHUPA1LZ4HyfoeOk2APfl1cjLR66yX4qw9P9nYdvTyclmfJO8yfxSOv0ab/0/giqGF4YJjgKBQgOBTNined7MK/jJT58DXchg==	zfvGXDQ2fdsxKy/4alb/rSqqTacllmJs4gShUN8IwD2vLTl0EGgiXioL/FRx4IbpfVTrX1iN+fjugK5+INFxMGlLN5HtefQAE5JAj/p731fiCGxn5vpOKn7N+futocd1N0jskYHlXz6kem6bCIJJRhSrTrbDdgaBY0w3rLrXbREkXUQRUtY4vIk9RZn9rKULbT0LCopabRPKykgPtse/woI/Bl+T02CBFMF3rNALZgWeZWQpu9A8mCS5mxNAmO5r97KETRYTGlVIloYDFG/vsFtTxC4jCLTrhVwa0IswZ6ZyEeW2165HuVeQq/A81c6nwPsJ0IVb5daBNUMVZ2xQ1dvO5RfQJtoTTxp3g+047AtKCa2g21x15ySmychnRopLXkIYtafTWajK4BQhbqtFq93Sqohw1ljALQULindy4ZppypHDMJlKahrLQy4wfjti+btOR1tbawmKAm5P0u9+Y51YbbKGlw3uDrfz2iyv1x14Ih6WxhuoxgLPQyY3UmN5sGk9FZrT1ltU0II64a0lcMEKFE8E/d/sGwuNufXeLC65lrz1XI9CjRDTbc06MDKtVGhz4BA+L0lsEHuZfEq1UqL63TexKoEDTie6ARJnS9nBbrrzouEJjxAPmVOGSxgMwkbNJsLCxibxdw+S6OOgrBeKdryNx9iOKgcpxnEacsxftfw0U9PZX01WZ8f6egnnD2mM4jflPwGi5u9mBIjbbUvrwAcBp8yxKrKbudn25pdlzp8kt+Go8g9J/5qqRmunWwG0wUbHBT8wM72jjAdu1xJ2MEt2OORGK50ca1umq9uo/AJISK4Er/c1qNOOx1PztICfV/Zqk6xpXRQa/SqPCbGG3kcFx2K/2jm1taQRNU75aoPbMdYgcR/gOCRzhRvaVmCgvjTWbAh5+F0C/XOzHcFEuBD4UhiePc5Uep1Di+iS7PaNYZhTXC+AjO/4o7xhAWHebx6uNVhQlNmfpL4cQfSgTCcbALVbcxdUNZn88oLGrytQioHXPVpE3qz/NPrN54oonssg8udwSomFQAXKltA20QI8KkCFfv3xyt1fl7OREEKCe1ZJzkfEOQmKaiwCcGJMbmIfRawwpMNzE8NJzJlyQNqKpZJIdGQMwnNN4Mq2Ditxh8/zkwca+sFZkwbvMM2TgOkxUrsXJXYBlLFmnxFZPb36a4+P4XCURCf1nPO+op5LBRBpZ+qIAgM2w5O7fTMLB2n8K7fO9a71JEPfHekRCL6mLz48eoGsxZv9tpaEnqZN/2tn6NQPj3dBUHQPCOanS96IF90j0aGB7K88xaRlynLhSBG1a6nFHmZRwhN7GKJ4GetOmntXCyRcjlNgk0B7IKPeQhiN5SR7QqjxVpzWK4qa/o/jvXvmOljDWCKF6YtV5FjaU3wCqqMe41NpTHgij1mdleyRiKBD36IQOARDYwYFYzrM/Bjksl+QElB6GtAqDP1iV8EhQTptK/RDrScyQlc1ws55seReFCplYvdwZJQO2CkKWUyvE7F1Osj10ozmoVeT4PIlCo4i4pg0VwNctdvmLqGDvQNeA1MPIMWfumhyBQe25KMwxbWg4jIunWy+NhWJnj6+PxhbJvv2/KUx5sjqh92fr+vsjgRHYd5ZovuMlsPvPr/bmWKVzcp9jwLOmqlklcMGNPa02/QegdokVxZIiyTdfLqeoPuiEibvDYX7WBniWvksYto5EcIeQCk+/B/b1inruJvghX+Bf/iW5iI/UftVVZrfe1iBoThvJPxpxVq0yQ+0rzApT3MW626KojmAWEKlFiaNObMBaSh4UjZKXIdpCLO1k4ABVi2QTUdXc3m1f962Ju6/CARIuVniDMVaFcgsUGL4w4e9+hmPvWSbp5GWT+EnO0/rRxn8o6S9qdic5NRY4r9aGgWF2nYgOPYOpQKm6vN5Y8b+RSo8iGt5GAPJxxw1qpLa1aXq4Xgc2rfcBwd374QqVMakd6jrU4mDIZldE8HrzrM09zERzEt1IYgXbP4++7sjohCk58m+jmoDR1VCI71QMSexfFXLztmWvnoxGfGtigRvt8fW1wWJqrSwGAbQGaweWCFHHFAAjUmjHp/gFTLBU5cZZvJ10eDV1bevbrv4fMlLktNDf3fP6xUqkLeOyd8iDPUlZiZQuONdEafpZ27dhSf95gbHQFHz2UN9L53X2RjAywC/+uXe7YR53KPlH1LaO3oygiWjuvxG2YPRCBmuvOOJobbRtUa54MaE7G6ge1/IoxKUvupIbnBavE6i59f78P36LIEVduuyI5w4xmuZLT6+j66PqIa1xA0WsqZB/RPWMVoOHWaq3t65owjOVNmT+tw0btCI1NznpuIoSEUFwosy5sLz+FM2G97UWCe3E/pV7WI9u/HcJWBatInxfv3X1ukIcAGMs2+V7cRKz/OaB6rq7f8R+jSNB+gzov3hRSvEzfuOMRIAZdfQEI+AHl8D1Xh+PN2RMPcdvqCq309w7uWq7OjozZ54fDQ5optLJXJWs+mjEoemrOC9gZAaZQVGdlLc4ovcMFfDRK6AJL6VgQFbylmthLdiKu6IUjf8/UDJfPAqcrldjY27c1K4KHNNBr2n2MCUURPrSa8bQEs/HEM+WyrtxBDkrlTtalblzZYZrdyUTFzWXTHJAIsuYefKIm+COByXKfTZMp7mxVj62gK0Ou6nIvdDKEJflq9sAnG93EOUbLvU1AdkpjGnOeCFiavxNWTn+zpa8kcmRfEbFDu3/zqFzg568vmDGYu071bKZ6ZaGGJm9IxZ9ybZSzaEyPVuE1mwuoa+r8CoXdprfQOfUge0d4gdXmO7X6Nvy8moXgfPi1y5zZpggYHuJQ1Q9TKdq4QVcktqfOp5HhlmMw+LAysgWDiqrX3CLFmRPVcG79WRmxqAEN4jh1srZWJ3q9T1+Aoa2ZmpconuZXR73M6tpvI924DUR0qkLVRyqcZWI6snA6eKzYhgx58A6M0XFUDHckzzRuDFQfqxBxVmGThvHmHlcC69qJ1gRIOzdtyn78Uzv1zprQ3wzQ3FncS2rAYo0Q427epfdQaRMwE24yRF2Rm+K4nUd9iQov9XJjOe46w49KB0km+IlK/D2d7RGuviNmw7gXkGK+0hTjaivno/tnN8rFni2C9ke4/TsgBSlMC9fhMc8Y8Wks4Irp5+mE4mKdaWIpHalpwh673DjuWxE8A7i8g8J66RNlds0iPlxik6YJrNHRbEdZPSzY7fzS7/10VdsP7/vyaH1skS5OwTFWgOooSN/0c9bh1A/qJCgEQER/PyuWEibfkvV96r8JbZbckhkuGy6m03U+cKqNjsSvPFyxxOKVo6huPHUXlXOu1BnVF+oftqJ2B0gumb+6dfQFqu0M6QzOW5O7Le+lDAXYYInttDj+9xEWdhkI7jX5GvpUI95caWFYwFwKnRzdakuO+v+R/PaBvBShoM6Q6DoFxDwZFXOemSdc1tc7J15wwsYFCX600rTsgjsd5nkdTAzKI7Axoj1XO29Z5J1gtNzbeZpwVBihNhI1sbfGEU6sSnmMd9TlLU7G198HIJd9B1marsnjMicfJs7B0pivy4xNqowQRsprwVw806AVtCP6ruCodEeIyK6AFtpNHmHfqbpsa2wIV6vpI1bsevUv9gHlhHZ58xYblaDeys7QgQA1Y6xOckIZxHr3zuQDs6pIAyDbbmJBwbJaau5Qoxl2sFlRaM0nuNV9TBTGiAtqzun1lj9p9YnQ6qmw+NxOFZceOVwBgo1Jw9s0egj9hVIzgp7orvwOo8Fpwbofe6NtXeXdKaYG97uLN/0TS0mpvCiC+Vk+fBwWqPpH7Eb7SxAKl1S2RGeCSdqusLi9RwDCrdasF9E96K2D3Msui3qPpTrkk0kHLqovSSrE/RVJIaEC5ABIlripmQXFoSJ6nF4jDED7Q+ro9C9h7JyvK07fKMYGkWFSWLitDmO+gYAWOKGuZOIUGUEPocQo79Y5DmPMw5ygWmGxrNgqyO89sOqXpeZU3xkBGXywTTi3xsZNpd4PZwWsxKUsWY7TWOdAGoS9fNTm747N6DoIk67JUhc/y0V504DFruuXzSU/v757s3sj/92EYcVOVR205XLveKsrUBTFncW5udB8ek+ezwnY2kOgcNG7hKe6EIe8A+LfswGsL7cEj3rdSODLWb1KfEpyjUcNXpbVJzjhk3LtKcpzPWSIlSVVwF6QUNYPHfnt6rEK3a5BWGBaiBXL6XRlv3XoNvn24JusAx7zIRsW+uP3L6nw==	c39ec3b5c5df6e31016f1942decd069dd3006be2458b540253255a4f836e5a91
8d93855c-7d74-4f6f-849c-65e78b8d1e36	090386f5401a8e48b63b19d4c8981e230efe71d2d3f28307f98c0424e6d93f9b	shibuyashadows908			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	45cedffeff3492519292e462b851408765116d5178cf5f56c00354ff3a6ada83
f1dcc325-81b5-4aaf-9834-eb770b8ac7b6	43dc22055016c54a2ad7599b113fffa52bd90ea199c2fd31e4d11eb2bd536991	shibuyashadows913			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	6bad3d131deb2bf58ffd2d26149f0110e903199d2bd40098e53d3227ad90e2ab
5f168b37-0b7c-4ab7-97f9-328cf89acb43	3dc8e60592e1fd4d430ac77eb3a0cfff91405e6652051256c87adde0943d66bc	bobbydr			bgDBp4z+nK74eHt083w4H66umI2gQQx15fhuRrXZPoWr0ijKBQtChUG2qMAS1qWfmmhrC7RGEerp++jt3JNTmpUkYRieTHmqT1D05hIu/AXNA7ncbulPfOIA5jO9EYPoQeh5Tg23KDUtpJSXH/3w7E24ae1SZupmgsfFbFhYZjTYB7UHSizXcaAfBih6SipVEjXdr94C60BuXCkaafl04fNSu1LoXwDAEoP/RThAyRVTN/c6VE+3KCsnOuw6Drg/TamHpoa/Ezq6a60imdiIyunyzdp0ucV2iTTUfzIuh+76KQRZZm1rrGvdyt8T8RoG3+uYVy09+YrA1A8HKKSCUWVMwU4thm4eYDoF6u5J48P4wr8msKwoiCCiUciwitFRCVA8YP2VHf7kFo5GFIAieHTP8mFmln/pvIEYSC8gii+0rdD85LmJNUZD+bK2ScHY14cm9jU8yqBTe8wGQ+NqDHZSGdKuz0aezIPebeIRXIV2K6Aiw59aLu63lpCqIIVqVrAaXoVBy2sFvpH0q2MBfh4N++SFlm2H6mKnTJhKTds42o4fdCEPiad+y///xVaJxg2pQJLh3VYa3oj6/vzqwco+NSy0IARz7u+CHFKUNqE+LPEYO75o6s/fhKzvKgfT94B/sW3CkkFqrh8Q//QLvA0J0oXARy5RIQw2dluOL2z6pu8zlFW/KW9tQESpAwF+NakM9dNTt1FM2L2A6ddZYXCYZSpzatWroOaQRKlFV/I3Y3ecOPcE09U4LJWu4unYqwYD9HE8eVtOyCxeg+h9Z5rmtx5YKHOBeHiv9rfFDLvmvSZyQEoAsAZcRBvXBxU9Bdylskjdc0CVWQsBX449SdZj304oK0qkyJ3RCUsQjSC68o/koKltBqATipH03UE8KGtrTIQywih5xXkL31lqrZ77Mb75kcFp+pxGAIinQKic2QWD6hlVFXHIluCa8e8Dkn0ezfqfCb66LCUKGOECT+cbrOEFeSpOvE39NYJLc6mEJzAJe2sHqQu5SznTTQ5YVAkqw6DQpaVJ40qjo6z5U2+2WOTkQlYw4qONWDnraD9J9YouOokjwyRTZyGX+4rq7IFNVJn4Da3FrfGhG5WRcvd77H9+TQFDDECHyToh9kzLY+6kpTgz2LS1cmxU5EXfoDc2utVd5l3PzwsL2ouavNhp3rm+AiZhwAX4lNw7F7wjiF4fZi5SYyMfrGS1HWyUzMdAl03T0PliECtt2wgGEkO3jWFUOcYiOl7i2x4xeVVKXXRYXyhGcuaTLEQtX6SMynI/rbLibXlb8Wxcma8w22EoW6ETJF4Zjv5lGn5eg5UuNHH4EQtF4x2YTgAr5FHvgOwnnfuUIzAAlqS5S4yBORINKvVioxP0nepipGyLv+NeUXeKFnZpFIfKc7f48DxdWkURPPgIQhRQB9pq1a10HcQ39/PhjjgzDGG3PNqrhRgYh2dhRkO86Jj8/xMHa4PHyyCUn6OIhluaNdHgZCjU8UlWIjGV3PQT1cbsRDl0jZtsTzciYNpvLj0nYzpaD7WDh5O77ikv9ebr0c7rZF9B8KavLwVefFi40ygz2x4nQJq4Mpq+WmOeSoLx3ZimJop47o77Hn35fX4bUd8+i087qpzs0J1YtAUMBYtk6jx0PxItHMJ2ac2DNkWww9NM5y3jJad+6Nq4VCMgjZWDjArg2UtzicWariaPSuTjqI0acgl4t3M87BA1Rj7YlSKKTNL4TCs0u8EuXFixVYhp8IvSqJ20G1ukVA1g7S952gtkffGdHFco2nj5hByT28Ta3yL5sLppC3/KmjveR8BAuvfiUfGeDwHF2PVGhaWR8T/kT6ooah0u8VzCSAbY+nEA5NB+Lm9UErlNw/OdblQzcRjLU9qZ7qKI1zHKRMM8cGEkyh+wWwWnX60eufnN20cjrQ5ua024vhIpUB/JymCClX8feHZK2VDpmL+fIaV5wp+YJfNWhifEqA8tV0FUJkNgfq/2eg8Q9ykj48Ohx1s1Iw3I2qWxsV8MchhQ3KpzLc+r4jRvW8JnUgqaPBDpHgyEvWo49gvoPL7EdaedIK2I6I2hZAVdfm8omx3rxWk6owlRNfrrdWEHvZ39+jE0kXuf6MVrlYuiQ08IwGNdnLFP3jyYfxalrF7/7QzT0ACtaZ2OTgP71s09n6msLQho+AFrjmBLlCURIr/Rm/D6RMTynDno7f/c7kVALRj4/FH0qI6Tb8z7G308/R2vOsfgduMqi1fWAR1LDFto0b1VGD0yi+64ir/IVrAJ7zocrddvK0Su25IoRDrRAOI0BaecaCgnQDba+LZG4WWee8iIHo3L9XqC+wh7HrVtzsYWc81cx88FYPGFyhFxBubLNvLkg4PuGxlFfOUhieqWDKMRFtpZixVcbLvCJFAd/mYruXF/YOi5okeZvMtVAZVq7nljRqnzH2nC2LqrMZPDzJEPjkslRswOhFzv/BCLoPsveiBn6B1Ue86a150EqITpwAPaTuHRJjnidRrQxJDnjhb8/noHtByMwDyfkv8zCA0Vjdg0BitQBPI3Wpkpt70k3/0ddNMec0Ggb903zm5/6DcGOiEvCxj/rypnNPE1z85QdFflUDYP4bn2RgU2yfDt0poXqI2DU/EhEyx9zPf84imBB6+8poECkygnvkgtxFKVixGSM0o9b+a2jwJU3p+Ge8ROLt/NL/2Bu+Ad6SXECxmMRQwJkqc2P1PAQr1Ey71LYvsIPpvgus8=	JQvEmXwD9fYj0o8HdNg4kv53JTSYS2m6oY2R2LgyE34H2Ox+AlRcOGUKj757xR9otq8xi3QBj7f+8QMVBH5uPcAXiF+MPJP2RoegNFaY1H3H5EPXN6rV1Ccx6DgcqekRLwAvuvrH5Cgq3F6DKhfo2YWsf5Gde5bVWpxH5e3xY2s9G7BgdqM2d4iKtBhNuU0V3BZv4Bm4ErBQEvBUl0Ib9DCg7IC9JTWhZvXRHjxQhS0DFPY+9HaCrRh5D0SPh1ndOw7/eJCiooIDAxIKjQ1LmEuIlVotNYFcjn3VobOy8Q8/CAqjUCcmj8uzNVCcPNQB0Fj5Y47KuPKoPUVervqar87mYD62PHhMQfseZr7sXxP+rfJpSQuKtH8u07OXMYjY8RJ661XYAtYns1Ayt/QIRK0kwHatrAvbZQQer41wK5qhFFWbfI3zdjLciCgL6LSzkxSvihJI+USHdcp2IgDiN82W3VUWOSlgpbTx1hPa8xAMjs6YS89N07VQYuqEEpUf1p6S7gRBKTIQJP0SIlpbotqbS/dOwO2JhiPimT5V1byL+UU3jLu7+R9fp+P6KZE2MaHR+6dVtZOn9nZpZj0zzg+bPFGDGkyOAKouoI+EC+aNSQaxTfvf54pwI5QLLQWADpvCiz4FLX85H9cZyKv9em6qf7/vYrd7Z1h/XZrZWSIfk75nV6DP7xIBuSzg8PUyxY9VCfkeWlVoVmoRdLnT7Dk/REe+76l3hln6Fj+GTGTiqXUgLCLKBINq/nEntB7UeQPgkQ0i8WVzyajQrFX/EDDMPHpmWF2CqNlVB8NRF8Lg9aQXTVEwJ2QlVMtIdPSDSM6vlcIZOcpUDR/6c6nAwOY1iP8ywDK6O/dwV9g7Q5/s/ZCiepxUmG9zp/iyJrI/t2d8FK3CHnOsdMsbfiK0WSLoJeiNiIAStcY9UscWVLr/DzKvu4AvYiZSV9HMG3Xin4J+CRqiPcJsKLtB2MYIep3k5m+ZO8Rp8wTfa7wX66H83JynuvOuZl+owzMmqJOY4OeD1t3S0uT9xl0MebrIOad0tLwGCdXucrIT6W70LSphU8puAWHrWDGgB9OG2Ay/BAnv6qUWW340D7Odu4FKfdXwoL+bPLpYkh0rsdcdXxv5Ij05HKEuBh2jXKhjLBJz6GqcRLaGDIjBkBHG7LaCS1sANm6y2fOgSDcWD2Hg26RJdvCw7H3Ygz/Gg7fV3o4cqoe9aWcdt1AY6LsvTUO5CdTb+K5JzcMeOyi2EnP2UsR7Hd/VcTuExP19U6HAmKmepRO1iUk2AOQ6C8nr/eyrpLW8rZ3Ug/EUpT6P5DPK/QeooXh+T0qQ/m+wP7tcqV9PK6KPCwcMF9DHvni+qQQ2+bgycmHvH4VWu/qpXejXLhH02hWfCXhzB8aNwonvjENGPpkaQnPcnftlGjXIZthlfyv6KhRXnpdSLWeViS8+NPiYrc0Vf5mEciaiyy5c/tLQebQQdaB3+JFntNfY2ExFfcsZTd9xDrNombtEVQgn+jDml0pmD7ERdt6pseNC90GvNR5QsRXmwP6pqjV5tmB9ukxWwYNpDgl3TEn+2R8lR+26mJJzT/t7Y7LPmEEP/iiS35md26JbkcYwXqEa0khGBsp/0DWl1s4AhouewqEppchXJfmIAHCKwvpkKDqCbouKcX7Sn9T/KbRD5nlJiPhHDAgnSrD1Ub9d449N5pw0+7xhF2ap3ogyrgWjC2QyNj41ocbaug9KdCZp8/m2KRUGPv29ND8k5UY4p7M1GnpvMxoYzH9Vcb7Z3wixUrCSo6UYjABmhwFbEGxn1E01RFZu5WezlUhvr8PEvS8cGlLmgDB12iYnb7xFuHrIkkhzQEXXMilDJ06VMQWRD+sqOcWcCglcOuf35UkauRzWYCHN8XsyIvUboGbORU1uAbgHDLi38l9RtPnH/9JvFn9vPTDZbEt9IEKCV2YENKLlHe0GOMGu3/VthE9NhqblKwhpdiG04F5fn9L3m6iXd8Fv1gCdinCakl2npgWMqwJv2NGa3RnjlvXsbkwFgvOPwr/Gi0CC21rk8+zZ3TxmUCQceuNCYSiO5W5qYKVxKqMmOR0aRNiceCvPoa5Md0NQgGubriU2GBXATNfLVRKWqw8KIwXnnqYNIMhJdpYrwIpAjPNXRM2k2lILicOLLiMsbQp8vfXKkJg4RnjzH0vo6ylygWQpYb1Pffex7J8g5TLY8NsPk6RRdlo0PVBke42hWtsBxu7Xd68OLyVOcGamNvbt1HQKdwVTTMMEOd7zq+mILhqR85glVO+mVsy8HOFkFI3FpTmppoY6NCmzkUysltAYJjzuFa0b3V1SpcJqbatWvX7G33ogi65eUhhu5ezsZt5oLLAm6eagjxDczq0/xI0lqOg+GZf9h4u7hEcpbVFN4FMm9CZxvR5P7/GVnTJGp7IKe4k7NOzfom+qO9QKyhDlTHF1+sdSFq5YYvWJYwMRU8Ad/zkDInilyGWEmoVhWQmlb3dUu/zRsAGooLZBP3OKMB7xhK7rVj+6a5iuDhUrGLjYWdZ9PV+4R2O2Np+5zfdFyQd254i3L4c+6WFhe1keSd1dSh4TgGxAlPFc8IqXvbASniLZeqLOK2dwGXgmijEq/WITwPZer0l+i2bJFDHRJmDMHo49H2kLhm0vBuFEBORWHDzAJ/fOZcFbuynQY+9WipGLB2JGbiZP+fGNXuMp1HkaSW4kuDiOS3hUjZUBM4WuKL7sPcg7n5l/68SPy6DOwkXSRONBFq8wOjCpsXzKxJ2iqxgjmtJFLJ5vLSh2REkB3pQc8Qr9J8HzIPFO+jCLixbQ6OvATAPKPI3m9mtLT0R4T9dtKUZPi0tTDslnpfgZt4K4jjfQnvhlcw524athXJypo0jVy80qdBaa5+VbBRLv6lvMtazWbhlWWzwQ0o3aQ5hPFwKotnKuakkWQp6XGEnIL8jSJk6ozxHjH3evcuPE3a2hVAMN26iqbYbZNhTwmuCtBArrEis0P1iL5DPRJX4+3A2zt7DoKNjQz4ST8UHLBUKWOKx4f7tyhunazB1woboEDYk763sU8OJnfGUJASFeKXqNCc1Fpsoayw/oW1RHTXKLwldYFJTIOSbsO0tYv1uEuXZnH8KA0FZZyRqS8o1VfDzXVxn0+dQp9NNJGq6aZEpa3X0tH/GvYTihvdfTVUzmiAlM7FyfYo0ijzk12x7jGsqPwkDRUUDGlFN7jSknqtPswTo/WiTJDOfgoqWsyGf0Zo6pR30Mfzp7gHeyWdJyN4cXA2M25YJozh8t8/kPDzK5rb2MnvxrJ6YDPBuOZ1zU4Y7Xbk7iIuCMgEx803U2JOpzexZMAk6yANnFIY2D0UGxuczrtIjQqI9h+e2ikQCz34K6a1FfYXrw9y+HiN+53fvrbSH233TsFFdlQ+jd58ntl2JYV8uOHWJSpU8mwkifRRyIGtwQ6iBgXUx/Cwm7RtFFFRW8q9fJ8ZUEJX74B0vpffsaWVawuG9QyGd6+0zHODcA9Yz9QlTfzO5qpNruy9230O/atd46YJJWxR/C04qEWGVv/ZqwVqKsciT3ybRJb6xuWziZO4TUy/Izf8jhqS7ZTqZtTdrhGnnEVt1J72ZiwJ1sCNzDMmjSavyqelpUt562FxIvBj7l2Ca81USiHsEFZA/JxNHWTLEXwCPdBG7RNzJMvPe2G1dLhhE7QAmSBFPlCJMN3kcCo6YEbeqC8/Hd1R49ndE+3G9xFhiUS45wf/hBfOGumqwNb8b8Ng5XM5iXgWxibPsieYR0a0KJKne6p7G89op2xiJGDaqrZsAS9ofrAj22CUVJeiIuH1T6K5jxxANL9/P9vQ1lmF8vx1zhy4YtxWabVnUvGPO6axMWdfrr7GkY/ZfNK4iiNo2zZ5JAmJU54oYWyvB97/P+JtTIbxg8YYFE0xdILFpNSM1ns7NJXqQUJHCVQUmYKpGsLz7Rh3uYcoNH9Uz60SGbLkQWJVEqTBGll+Ie1GCLf0+2TjS7trFc1Tsal575jvdp5zUGHDAG6MFzYm3haQcCUJfSBHRijrcOSgSJ2FgP6F2JPrtmH8g5jPL490YvByOiF5Uhxl75Bivq4eoy/Hp17W0qSeYOL/rd5/fheaOEb293kAp/TfrRAmzg6tRd7BZ6Jwb+UsQ/rysaaYtgWwzN6gWyzZtHu6zLeM0uCmE7OEzcVlPEbkns/2/c1ozd/Bs=	d3b6a54cfca86bbb23e59223d2a9e8033bceec4172e1100385e3830fb4041d86
4619c475-b6d1-47c9-ab00-23c9125d00b1	873315053c0823de4f9981b3cd1c88adad080610262b35783dc3fbb1503b8e0f	mrbenjamin			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	257ea462597c060e15671441cca7abe5f4001d0f6798a157c09a1e5814d61684
a9e3ec68-9ca6-46ac-bf41-ac46d3fbff0d	1b70ecebc36f3c185d22fb87f3c192917e5d84151f6072d82fa6564254e30211	bentester			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	98d23b28a46a0ed059ca1afc8f5adccde1b29e552ee3661d839645217e838015
55f0f010-279e-4e81-9e1d-94857b42fcc3	7eba8f29024ec8b52d48b8885d35afa7ee1b16d255e88b62922d9abeb89ac519	shibuyashadowspb			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	ec6f89ed59f812c19c8b419c54c4aaf8cb408342727b3ec7ee47067ca1091cd4
19834ace-c383-44ed-b2c5-2e230427108f	21fb3f5fb6a0c9a5e6404719057b366699f0be59ba1e37f7d936ef6a2ce7926d	shibuyashadowsuyus			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
87759c11-f3f3-49a4-a2b0-83215fd252a5	1be888d0f72e1dd4cf9830224618251944a749be1760835da9da7c22bae70c11	shibuyashadowsiou			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	f88af22286919965bc9f4b6ecae50018eb0c3430071d963bd3bfe1343d789e2b
2273e8f3-a3fe-4817-b059-19335a558989	2c9fcb17f3e35a5d2c17ac695b7d6b331f6b2220693ee524b8b202ba0ace358e	shibuyashadows9yhy			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	397a8e54493e1ecb28afc23d32f723994fe010f1edad1dc59cdc75fccea1b942
71cc7c07-fa2d-4c85-8a44-ff056d22f491	1b40f08fd133ac1c9e745de021bc15f880b58aeb13b3ebc908a42cd4141767e6	shibuyashadows8yht5			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	46c5869bc55d74aee157ba5864c2515f3f9be0c26b1d2ec5da09a2214116e9d3
9bee755d-e24c-4b2a-99aa-9e16cac85cce	6b3a29cfe7ac1554621493d4971db7abc2f75e3c859d2715ec362058a9c9c3ff	shibuyashadows89dt			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	504e88db105ae2c0894214fdd7dce8ba1dac8ad279db9622b934609db100bfbf
d46ad125-a07f-43ee-b60f-5f16c1763ca0	ad7025c7040d1bf11df14afa54bac054c8fa37362d61f6dbee50605aa2ea801d	shibuyashadows897f			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	ac9d1df3e2b14713bb5241836b5be96ef2ef35e151946a63a4fac9b385d90f9e
c9d0d224-8c29-416c-b186-6e2a5a5fb3fa	9627105a92bc0de742b59643c811781ee9fc1c10d8b7c7dbdbece3fdf55ebd17	shibuyashadows785t			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	f21d6336c63f97a975e4527a8caaa51145a7e821058c1973224fafcb0d50fa19
9063f4dc-d9c4-47ae-ba12-d5050789f4b0	8361b4d1cb16d9ba6b4f6a430c33009b37d23610f4023ba450ee0240c6d55bbe	shibuyashadows90gy			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	ce8f4633d224b4d6bd3efa2d20f4bed79d2021103c68a132d3403f2121e46eb9
85a009cd-370a-404e-9586-5775984e5674	13f9f3b2c5e85e2e4c204d5895902e1a32fcf391daf4d8712b7ac6ec2de41d7a	shibuyashadows142			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	5de8396cc108e342403c824dec6ff7e615fdd18a9ecc8e843cb5ddd5c4e46baa
\.


--
-- TOC entry 2685 (class 0 OID 16507)
-- Dependencies: 201
-- Data for Name: usertimeline; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY usertimeline (timelineid, userid, timelinetype, transactionid, username, invoiceid, timelinedate) FROM stdin;
11	2f2286e0-7227-4c1f-9627-6abbeeb9c015	FRS	\N	shibuyashadows736	0	2017-06-01 12:41:16.672
12	92e8af98-63da-476c-b9ef-26185bae9607	FRR	\N	shibuyashadowsb56	0	2017-06-01 12:41:16.672
13	92e8af98-63da-476c-b9ef-26185bae9607	FRS	\N	shibuyashadowsb56	0	2017-06-01 13:31:05.108
14	2f2286e0-7227-4c1f-9627-6abbeeb9c015	FRR	\N	shibuyashadows736	0	2017-06-01 13:31:05.108
18	2f2286e0-7227-4c1f-9627-6abbeeb9c015	MS	\N	shibuyashadows736	\N	2017-06-01 19:43:26.288
16	92e8af98-63da-476c-b9ef-26185bae9607	IR	\N	shibuyashadowsb56	1	2017-06-02 11:02:49.977
19	92e8af98-63da-476c-b9ef-26185bae9607	IS	\N	shibuyashadowsb56	1	2017-06-02 11:02:49.977
15	2f2286e0-7227-4c1f-9627-6abbeeb9c015	IS	\N	shibuyashadows736	1	2017-06-02 11:02:49.977
20	2f2286e0-7227-4c1f-9627-6abbeeb9c015	IR	\N	shibuyashadows736	1	2017-06-02 11:02:49.977
17	92e8af98-63da-476c-b9ef-26185bae9607	MS	\N	shibuyashadowsb56	\N	2017-06-06 10:45:35.244
21	87759c11-f3f3-49a4-a2b0-83215fd252a5	TR	d49d872d88423fdb730bf2b119b393f8c9bfbdbb27b1af1f1cfd09b5115e742a	External	\N	2017-06-12 15:24:00.763
22	2273e8f3-a3fe-4817-b059-19335a558989	TR	e7a68300c70a9e3464fdb419b5664b6a92342e728082349995d88c3894ddb3e8	External	\N	2017-06-13 05:45:13.419
23	71cc7c07-fa2d-4c85-8a44-ff056d22f491	TR	30674473e764caed00e6586ea5f4a4020fb432b9a6b5f93d2b8f1a9464603f0d	External	\N	2017-06-13 05:58:55.665
24	d46ad125-a07f-43ee-b60f-5f16c1763ca0	TR	eeb047c65500ca808d927ecbaa40fa2199a1422ae7dff38d7d030bd65a3c3871	External	\N	2017-06-13 06:21:47.609
25	d46ad125-a07f-43ee-b60f-5f16c1763ca0	TR	8a4ade05586aabb5eee254b1b1211d8955e65ac0d9069ea763d1df2c7ed7c386	External	\N	2017-06-13 06:24:34.208
26	c9d0d224-8c29-416c-b186-6e2a5a5fb3fa	TR	0799611fbc133bb81cd534e4e88e01aee061ba147a0e9d1039d8886f4f73f59d	External	\N	2017-06-13 06:33:54.695
27	9063f4dc-d9c4-47ae-ba12-d5050789f4b0	TR	afa757cf2bb5535667d4f040c93cd7c91f28b84df3ce2c1f3cb5c81d8cb2a156	External	\N	2017-06-13 06:43:04.237
28	9063f4dc-d9c4-47ae-ba12-d5050789f4b0	TS	3ea665a2cdfe2e3be0e37d064af91ce2d9ba43b3fccc3a75b37f2381d4d87256	External	\N	2017-06-13 06:44:10.007
29	85a009cd-370a-404e-9586-5775984e5674	TR	f7a78be036cd3e077f3d284863bb67d0d60dab50057006bcd57049351885096e	External	\N	2017-06-13 07:53:16.49
30	85a009cd-370a-404e-9586-5775984e5674	TS	0a24fdbbc1401a5614c6a6dfc9144b97605601a72950758bb6944bb548ce21f4	External	\N	2017-06-13 08:00:42.844
31	85a009cd-370a-404e-9586-5775984e5674	FRS	\N	shibuyashadows90gy	0	2017-06-13 08:03:19.541
32	9063f4dc-d9c4-47ae-ba12-d5050789f4b0	FRR	\N	shibuyashadows142	0	2017-06-13 08:03:19.541
33	9063f4dc-d9c4-47ae-ba12-d5050789f4b0	FRS	\N	shibuyashadows142	0	2017-06-13 08:03:42.292
34	85a009cd-370a-404e-9586-5775984e5674	FRR	\N	shibuyashadows90gy	0	2017-06-13 08:03:42.292
35	9063f4dc-d9c4-47ae-ba12-d5050789f4b0	TR	652fc9a13334f6b1122e4c73650815fe9d61054a688524f6331f03943fc6bc92	External	\N	2017-06-13 08:06:10.984
36	9063f4dc-d9c4-47ae-ba12-d5050789f4b0	TS	cee6ff83f6d9dc8212412f6ccd994f1bd8a31e30a6aa8259e598146ffbfe3c08	shibuyashadows142	\N	2017-06-13 08:32:23.203
37	85a009cd-370a-404e-9586-5775984e5674	TR	cee6ff83f6d9dc8212412f6ccd994f1bd8a31e30a6aa8259e598146ffbfe3c08	shibuyashadows90gy	\N	2017-06-13 08:32:23.203
38	85a009cd-370a-404e-9586-5775984e5674	TR	a1cc2c8091beb482e1025563cae4902a1c03fceeb1c7c47ae0549e0147535d5d	External	\N	2017-06-13 08:39:02.101
39	85a009cd-370a-404e-9586-5775984e5674	TS	29b1bf3eff31d17381a456d7c113060d2de1f7cc9f35b9f26f5ab542b26622a8	shibuyashadows90gy	\N	2017-06-13 08:39:56.549
40	9063f4dc-d9c4-47ae-ba12-d5050789f4b0	TR	29b1bf3eff31d17381a456d7c113060d2de1f7cc9f35b9f26f5ab542b26622a8	shibuyashadows142	\N	2017-06-13 08:39:56.549
41	9063f4dc-d9c4-47ae-ba12-d5050789f4b0	IS	\N	shibuyashadows142	1	2017-06-13 08:43:02.372
42	85a009cd-370a-404e-9586-5775984e5674	IR	\N	shibuyashadows90gy	1	2017-06-13 08:43:02.372
45	85a009cd-370a-404e-9586-5775984e5674	TS	df3978c50f44a91368502859a4fb1c75d65f15c0bda1f2c94669c7d387ec6886	shibuyashadows90gy	\N	2017-06-13 08:47:34.618
46	9063f4dc-d9c4-47ae-ba12-d5050789f4b0	TR	df3978c50f44a91368502859a4fb1c75d65f15c0bda1f2c94669c7d387ec6886	shibuyashadows142	\N	2017-06-13 08:47:34.618
43	9063f4dc-d9c4-47ae-ba12-d5050789f4b0	IS	\N	shibuyashadows142	2	2017-06-13 08:47:34.717
44	85a009cd-370a-404e-9586-5775984e5674	IR	\N	shibuyashadows90gy	2	2017-06-13 08:47:34.717
\.


--
-- TOC entry 2713 (class 0 OID 0)
-- Dependencies: 200
-- Name: usertimeline_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('usertimeline_seq', 46, true);


--
-- TOC entry 2686 (class 0 OID 16513)
-- Dependencies: 202
-- Data for Name: usertransactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY usertransactions (userid, transactionid, outputindex, transdatetime, amount, address, username, transtype, status, notified, blocknumber, minersfee) FROM stdin;
87759c11-f3f3-49a4-a2b0-83215fd252a5	d49d872d88423fdb730bf2b119b393f8c9bfbdbb27b1af1f1cfd09b5115e742a	1	2017-06-12 15:24:00.681	100000	2N6dZpQEHgViMwrBxHCSCJcNp38eSX8vS9b	External	R	1	0	0	372
71cc7c07-fa2d-4c85-8a44-ff056d22f491	30674473e764caed00e6586ea5f4a4020fb432b9a6b5f93d2b8f1a9464603f0d	1	2017-06-13 05:58:55.627	100000	2N3JEUGpS5EDFFaVE2LhH2m8Kd4b2y5eYrJ	External	R	1	0	0	224
2273e8f3-a3fe-4817-b059-19335a558989	e7a68300c70a9e3464fdb419b5664b6a92342e728082349995d88c3894ddb3e8	0	2017-06-13 05:45:13.266	100000	2NBrN9rSevJKPwed4zMgxPvTV8ep9ZVj1ET	External	R	1	0	0	224
d46ad125-a07f-43ee-b60f-5f16c1763ca0	8a4ade05586aabb5eee254b1b1211d8955e65ac0d9069ea763d1df2c7ed7c386	1	2017-06-13 06:24:34.137	100000	2Mt8C4KH2STiKtC39trF5R3GsomrMa8m8d2	External	R	1	0	0	224
d46ad125-a07f-43ee-b60f-5f16c1763ca0	eeb047c65500ca808d927ecbaa40fa2199a1422ae7dff38d7d030bd65a3c3871	1	2017-06-13 06:21:47.522	10000	2Mt8C4KH2STiKtC39trF5R3GsomrMa8m8d2	External	R	1	0	0	224
9063f4dc-d9c4-47ae-ba12-d5050789f4b0	afa757cf2bb5535667d4f040c93cd7c91f28b84df3ce2c1f3cb5c81d8cb2a156	1	2017-06-13 06:43:04.199	100000	2MtqFJ5epEQ5L6BsLN6NVGa1J1QnTFhiikE	External	R	1	0	0	224
c9d0d224-8c29-416c-b186-6e2a5a5fb3fa	0799611fbc133bb81cd534e4e88e01aee061ba147a0e9d1039d8886f4f73f59d	1	2017-06-13 06:33:54.536	100000	2N3EGLyaUcRTaqoCinwxESHVBkXnDJXJ3mM	External	R	1	0	0	224
9063f4dc-d9c4-47ae-ba12-d5050789f4b0	3ea665a2cdfe2e3be0e37d064af91ce2d9ba43b3fccc3a75b37f2381d4d87256	0	2017-06-13 06:44:09.986	90000	n2DTKms5erSLBvHwPjNCCgVEtQ9outseab	External	S	0	0	0	10000
9063f4dc-d9c4-47ae-ba12-d5050789f4b0	652fc9a13334f6b1122e4c73650815fe9d61054a688524f6331f03943fc6bc92	1	2017-06-13 08:06:10.929	100000	2Mw8zAY8BbJnAgp5CHTaq99LDtBr9CPCGm9	External	R	1	0	0	668
9063f4dc-d9c4-47ae-ba12-d5050789f4b0	cee6ff83f6d9dc8212412f6ccd994f1bd8a31e30a6aa8259e598146ffbfe3c08	0	2017-06-13 08:32:23.177	50000	2NApCKDhDFAmVFyJ8ESTxVtnXWRGVP48tjA	shibuyashadows142	S	0	0	0	10000
85a009cd-370a-404e-9586-5775984e5674	cee6ff83f6d9dc8212412f6ccd994f1bd8a31e30a6aa8259e598146ffbfe3c08	0	2017-06-13 08:32:23.177	50000	2NApCKDhDFAmVFyJ8ESTxVtnXWRGVP48tjA	shibuyashadows90gy	R	0	0	0	10000
85a009cd-370a-404e-9586-5775984e5674	29b1bf3eff31d17381a456d7c113060d2de1f7cc9f35b9f26f5ab542b26622a8	0	2017-06-13 08:39:56.423	90000	2NBGLyaaViHV33iayq9WPSG1xcdrmqRVXeX	shibuyashadows90gy	S	0	0	0	10000
9063f4dc-d9c4-47ae-ba12-d5050789f4b0	29b1bf3eff31d17381a456d7c113060d2de1f7cc9f35b9f26f5ab542b26622a8	0	2017-06-13 08:39:56.423	90000	2NBGLyaaViHV33iayq9WPSG1xcdrmqRVXeX	shibuyashadows142	R	0	0	0	10000
85a009cd-370a-404e-9586-5775984e5674	a1cc2c8091beb482e1025563cae4902a1c03fceeb1c7c47ae0549e0147535d5d	1	2017-06-13 08:39:02.059	100000	2MtQQxDY4UjSr66VHiJ8FMrX5iMj3fGNoQf	External	R	1	0	0	520
85a009cd-370a-404e-9586-5775984e5674	f7a78be036cd3e077f3d284863bb67d0d60dab50057006bcd57049351885096e	1	2017-06-13 07:53:16.454	100000	2Mxb2EaUjEXRyGtkYrvHjznUp6gUKB6ZM86	External	R	1	0	0	224
85a009cd-370a-404e-9586-5775984e5674	0a24fdbbc1401a5614c6a6dfc9144b97605601a72950758bb6944bb548ce21f4	0	2017-06-13 08:00:42.803	90000	mtm5gTbgJNk4MCaEC7BQSGnkzcgQvTemBK	External	S	0	0	0	10000
85a009cd-370a-404e-9586-5775984e5674	df3978c50f44a91368502859a4fb1c75d65f15c0bda1f2c94669c7d387ec6886	0	2017-06-13 08:47:34.57	10000	2NB2mNPps3q6Ek4ZgJz6Dq6fpLeV5jnJkUc	shibuyashadows90gy	S	0	0	0	10000
9063f4dc-d9c4-47ae-ba12-d5050789f4b0	df3978c50f44a91368502859a4fb1c75d65f15c0bda1f2c94669c7d387ec6886	0	2017-06-13 08:47:34.57	10000	2NB2mNPps3q6Ek4ZgJz6Dq6fpLeV5jnJkUc	shibuyashadows142	R	0	0	0	10000
\.


--
-- TOC entry 2531 (class 2606 OID 16556)
-- Name: account pk_account; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY account
    ADD CONSTRAINT pk_account PRIMARY KEY (walletid);


--
-- TOC entry 2499 (class 2606 OID 16401)
-- Name: accountaddress pk_accountaddress; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY accountaddress
    ADD CONSTRAINT pk_accountaddress PRIMARY KEY (walletid, nodelevel);


--
-- TOC entry 2501 (class 2606 OID 16409)
-- Name: accountbackupcode pk_accountbackupcode; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY accountbackupcode
    ADD CONSTRAINT pk_accountbackupcode PRIMARY KEY (walletid, backupset, backupindex);


--
-- TOC entry 2503 (class 2606 OID 16417)
-- Name: accountdevice pk_accountdevice; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY accountdevice
    ADD CONSTRAINT pk_accountdevice PRIMARY KEY (walletid, devicename);


--
-- TOC entry 2505 (class 2606 OID 16425)
-- Name: accountlog pk_accountlog; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY accountlog
    ADD CONSTRAINT pk_accountlog PRIMARY KEY (logid);


--
-- TOC entry 2507 (class 2606 OID 16433)
-- Name: accountsecpub pk_accountsecpub; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY accountsecpub
    ADD CONSTRAINT pk_accountsecpub PRIMARY KEY (walletid);


--
-- TOC entry 2533 (class 2606 OID 16579)
-- Name: accountsettings pk_accountsettings; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY accountsettings
    ADD CONSTRAINT pk_accountsettings PRIMARY KEY (walletid);


--
-- TOC entry 2509 (class 2606 OID 16446)
-- Name: accounttransactions pk_accounttransactions; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY accounttransactions
    ADD CONSTRAINT pk_accounttransactions PRIMARY KEY (walletid, transactionid);


--
-- TOC entry 2537 (class 2606 OID 16670)
-- Name: block pk_block; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY block
    ADD CONSTRAINT pk_block PRIMARY KEY (blockhash);


--
-- TOC entry 2535 (class 2606 OID 16586)
-- Name: emailtoken pk_emailtokens; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY emailtoken
    ADD CONSTRAINT pk_emailtokens PRIMARY KEY (emailvalidationtoken);


--
-- TOC entry 2539 (class 2606 OID 16675)
-- Name: fees pk_fees; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY fees
    ADD CONSTRAINT pk_fees PRIMARY KEY (feeid);


--
-- TOC entry 2541 (class 2606 OID 16680)
-- Name: lastread pk_lastread; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY lastread
    ADD CONSTRAINT pk_lastread PRIMARY KEY (id);


--
-- TOC entry 2511 (class 2606 OID 16459)
-- Name: nodekeycache pk_nodekeycache; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY nodekeycache
    ADD CONSTRAINT pk_nodekeycache PRIMARY KEY (walletid, nodelevel);


--
-- TOC entry 2529 (class 2606 OID 16533)
-- Name: recs pk_recs_1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY recs
    ADD CONSTRAINT pk_recs_1 PRIMARY KEY (id);


--
-- TOC entry 2543 (class 2606 OID 16688)
-- Name: traninputs pk_traninputs; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY traninputs
    ADD CONSTRAINT pk_traninputs PRIMARY KEY (transysid, inputindex);


--
-- TOC entry 2551 (class 2606 OID 16860)
-- Name: tranoutputs pk_tranoutputs; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tranoutputs
    ADD CONSTRAINT pk_tranoutputs PRIMARY KEY (transysid, outputindex);


--
-- TOC entry 2545 (class 2606 OID 16704)
-- Name: tranoutputs_noncon pk_tranoutputs_noncon_1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tranoutputs_noncon
    ADD CONSTRAINT pk_tranoutputs_noncon_1 PRIMARY KEY (transactionid, outputindex);


--
-- TOC entry 2547 (class 2606 OID 16715)
-- Name: trans pk_trans; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY trans
    ADD CONSTRAINT pk_trans PRIMARY KEY (transysid);


--
-- TOC entry 2549 (class 2606 OID 16720)
-- Name: transnoncon pk_transnoncon; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY transnoncon
    ADD CONSTRAINT pk_transnoncon PRIMARY KEY (transactionid);


--
-- TOC entry 2513 (class 2606 OID 16467)
-- Name: userinvoices pk_userinvoices; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY userinvoices
    ADD CONSTRAINT pk_userinvoices PRIMARY KEY (userid, invoiceid);


--
-- TOC entry 2515 (class 2606 OID 16475)
-- Name: usermessage pk_usermessage; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY usermessage
    ADD CONSTRAINT pk_usermessage PRIMARY KEY (userid, messageid);


--
-- TOC entry 2517 (class 2606 OID 16483)
-- Name: usernetwork pk_usernetwork; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY usernetwork
    ADD CONSTRAINT pk_usernetwork PRIMARY KEY (userid, useridfriend);


--
-- TOC entry 2519 (class 2606 OID 16491)
-- Name: usernetworkcategory pk_usernetworkcategory; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY usernetworkcategory
    ADD CONSTRAINT pk_usernetworkcategory PRIMARY KEY (categoryid);


--
-- TOC entry 2521 (class 2606 OID 16496)
-- Name: userprofile pk_userprofile; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY userprofile
    ADD CONSTRAINT pk_userprofile PRIMARY KEY (userid);


--
-- TOC entry 2523 (class 2606 OID 16504)
-- Name: users pk_users; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY users
    ADD CONSTRAINT pk_users PRIMARY KEY (userid);


--
-- TOC entry 2525 (class 2606 OID 16512)
-- Name: usertimeline pk_usertimeline; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY usertimeline
    ADD CONSTRAINT pk_usertimeline PRIMARY KEY (timelineid);


--
-- TOC entry 2527 (class 2606 OID 16517)
-- Name: usertransactions pk_usertransactions; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY usertransactions
    ADD CONSTRAINT pk_usertransactions PRIMARY KEY (userid, transactionid, outputindex);


-- Completed on 2017-06-14 13:50:06 JST

--
-- PostgreSQL database dump complete
--

