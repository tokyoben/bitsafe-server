const express = require('express');
const _coreController = require('./controllers/_core-controller.js');
const _accountController = require('./controllers/_account-controller.js');
const _networkController = require('./controllers/_network-controller.js');
const _deviceController = require('./controllers/_device-controller.js');
const _authController = require('./controllers/_auth-controller.js');
const _transactionController = require('./controllers/_transaction-controller.js');
const _settingsController = require('./controllers/_settings-controller.js');
const _addressController = require('./controllers/_address-controller.js');
const _invoiceController = require('./controllers/_invoice-controller.js');
const _messageController = require('./controllers/_message-controller.js');


module.exports = function(app,server) {

  const apiRoutes = express.Router();

  apiRoutes.get('/1/u/amialive', _coreController.amIAlive);
  apiRoutes.post('/1/u/getprice', _coreController.getPrice);
  apiRoutes.post('/1/u/gettimeline', _coreController.getTimeline);
  apiRoutes.post('/1/u/getversion', _coreController.getVersion);
  apiRoutes.post('/1/getusernetworkcategory', _networkController.getUserNetworkCategory)
  apiRoutes.post('/1/updateusernetworkcategory',  _networkController.updateUserNetworkCategory)
  apiRoutes.post('/1/u/createfriend', _networkController.createFriend)
  apiRoutes.post('/1/u/getfriendrequestpacket',  _networkController.getFriendRequestPacket)
  apiRoutes.post('/1/u/getfriendpacket',  _networkController.getFriendPacket)
  apiRoutes.post('/1/u/updatefriend',  _networkController.updateFriend)
  apiRoutes.post('/1/u/rejectfriend',  _networkController.rejectFriend)
  apiRoutes.post('/1/u/getuserpacket',  _accountController.getUserPacket)
  //apiRoutes.post('1/getusernetwork',  _networkController.getUserNetwork)
  apiRoutes.post('/1/u/getfriend',  _networkController.getFriend)
  apiRoutes.post('/1/u/getpendinguserrequests',  _networkController.getPendingUserRequests)
  apiRoutes.post('/1/u/doesnetworkexist',  _networkController.doesNetworkExist)
  apiRoutes.post('/1/u/getfriendrequests',  _networkController.getFriendRequests)
  apiRoutes.post('/1/u/getrsakey',  _networkController.getRSAKey)
  apiRoutes.post('/2/u/getusernetwork',  _networkController.getUserNetwork)

  apiRoutes.post('/1/getrecoverypacket', _accountController.getRecoveryPacket);
  apiRoutes.post('/1/sendwelcomedetails', _accountController.sendWelcomeDetails);
  apiRoutes.post('/1/verifyrecoverpacket', _accountController.verifyRecoverPacket);
  apiRoutes.post('/1/getemailvalidation', _accountController.getEmailValidation);
  apiRoutes.post('/1/getemailvalidationtwofactor', _accountController.getEmailValidationTwoFactor);
  apiRoutes.post('/1/getguidbympkh', _accountController.GetGUIDByMPKH);
  apiRoutes.post('/1/emailguid', _accountController.emailGUID);
  apiRoutes.post('/1/gettwofactorimg', _accountController.getTwoFactorImg);
  apiRoutes.post('/1/getrecoverypacket', _accountController.getRecoveryPacket);
  apiRoutes.post('/1/getnewtwofactorimg', _accountController.getNewTwoFactorImg);
  apiRoutes.post('/1/u/updatetwofactor', _accountController.updateTwoFactor);
  apiRoutes.post('/2/u/createaccount', _accountController.createAccountv2);
  apiRoutes.post('/1/u/createaccount2', _accountController.createAccount2);
  apiRoutes.post('/1/u/updateemailaddress', _accountController.updateEmailAddress);
  apiRoutes.post('/1/u/createaccountsecpub', _accountController.createAccountSecPub);
  apiRoutes.post('/1/u/getaccountsecpub', _accountController.getAccountSecPub);
  apiRoutes.post('/1/u/removeaccountsecpub', _accountController.removeAccountSecPub);
  apiRoutes.post('/1/u/getaccountdetails', _accountController.getAccountDetails);
  apiRoutes.post('/1/u/getuserdata', _accountController.getUserData);
  apiRoutes.post('/1/u/getaccountdata', _accountController.getAccountData);
  apiRoutes.post('/1/u/doesaccountexist', _accountController.doesAccountExist);
  apiRoutes.post('/1/u/unlockaccount', _accountController.unlockAccount);
  apiRoutes.post('/1/u/getnickname', _accountController.getNickname);
  apiRoutes.post('/1/u/updateuserprofile', _accountController.updateUserProfile);
  apiRoutes.post('/1/u/getuserprofile', _accountController.getUserProfile);

  apiRoutes.post('/1/u/getdevices', _deviceController.getDevices);
  apiRoutes.post('/1/u/getdevicetoken', _deviceController.getDeviceToken);
  apiRoutes.post('/1/u/getdevicetokenforapp', _deviceController.getDeviceTokenForApp);
  apiRoutes.post('/1/u/createdevice', _deviceController.createDevice);
  apiRoutes.post('/2/u/getdevicekey', _deviceController.getDeviceKey);
  apiRoutes.post('/1/u/destroydevice', _deviceController.destroyDevice);
  apiRoutes.post('/1/u/destroydevice2fa', _deviceController.destroyDevice2FA);
  apiRoutes.post('/1/u/registerdevice', _deviceController.registerDevice);
  apiRoutes.post('/1/u/getdevicetokenrestore', _deviceController.getDeviceTokenRestore);

  apiRoutes.post('/1/u/requestauthmigration', _authController.requestAuthMigration);
  apiRoutes.post('/1/u/getauthmigrationrequest', _authController.getAuthMigrationRequest);
  apiRoutes.post('/1/u/authmigration', _authController.authMigration);
  apiRoutes.post('/1/u/getAuthMigrationToken', _authController.getAuthMigrationToken);
  apiRoutes.post('/1/u/updatesecretpacket', _authController.updateSecretPacket);
  apiRoutes.post('/1/u/validateSecret', _authController.validateSecret);
  apiRoutes.post('/1/u/getResetToken', _authController.getResetToken);
  apiRoutes.post('/1/u/updatepackets', _authController.updatePackets);
  apiRoutes.post('/1/u/migratepacket', _authController.migratePacket);
  apiRoutes.post('/1/u/getverificationcode', _authController.getVerificationCode);
  apiRoutes.post('/1/u/createbackupcodes', _authController.createBackupCodes);
  apiRoutes.post('/1/u/resettwofactoraccount', _authController.resetTwoFactorAccount);
  apiRoutes.post('/1/u/getsigchallenge', _authController.getSigChallenge);

  apiRoutes.post('/1/u/getlimitstatus', _transactionController.getLimitStatus);
  apiRoutes.post('/1/u/preparetransaction', _transactionController.prepareTransaction);
  apiRoutes.post('/2/u/getbalance', _transactionController.getBalance);
  apiRoutes.post('/1/u/getunconfirmedbalance', _transactionController.getUnconfirmedBalance);
  apiRoutes.post('/1/u/getcoinprofile', _transactionController.getCoinProfile);
  apiRoutes.post('/1/u/getunspentoutputs', _transactionController.getUnspentOutputs);
  apiRoutes.post('/1/u/createtransactionrecord', _transactionController.createTransactionRecord);
  apiRoutes.post('/1/u/gettransactionrecords', _transactionController.getTransactionRecords);
  apiRoutes.post('/1/u/gettransactionfeed', _transactionController.getTransactionFeed);
  apiRoutes.post('/2/u/gettransactionsfornetwork', _transactionController.getTransactionsForNetwork);
  apiRoutes.post('/1/u/sendtransaction', _transactionController.sendTransaction);
  apiRoutes.post('/2/u/gettransactionfeed', _transactionController.getTransactionFeed);

  apiRoutes.post('/1/u/getaccountsettings', _settingsController.getAccountSettings);
  apiRoutes.post('/2/u/updateaccountsettings', _settingsController.updateAccountSettings);

  apiRoutes.post('/1/u/getnextnodeforfriend', _addressController.getNextNodeForFriend);
  apiRoutes.post('/1/u/getnextleafforfriend', _addressController.getNextLeafForFriend);
  apiRoutes.post('/1/u/getnextleaf', _addressController.getNextLeaf);
  apiRoutes.post('/1/u/createaddressforfriend', _addressController.createAddressForFriend);
  apiRoutes.post('/1/u/createaddress', _addressController.createAddress);

  apiRoutes.post('/1/u/createinvoice', _invoiceController.createInvoice);
  ///apiRoutes.post('1/u/getinvoicestopay', _invoiceController.getInvoicesToPay);
  apiRoutes.post('/2/u/getinvoicestopaynetwork', _invoiceController.getInvoicesToPayNetwork);
  //apiRoutes.post('1/u/getinvoicesbyuser', _invoiceController.getInvoicesByUser);
  apiRoutes.post('/2/u/getinvoicesbyusernetwork', _invoiceController.getInvoicesByUserNetwork);
  apiRoutes.post('/1/u/updateinvoice', _invoiceController.updateInvoice);
  apiRoutes.post('/2/u/getinvoicestopay', _invoiceController.getInvoicesToPay);
  apiRoutes.post('/2/u/getinvoicesbyuser', _invoiceController.getInvoicesByUser);

  apiRoutes.post('/1/u/createmessage', _messageController.createMessage);
  apiRoutes.post('/1/u/getmessagesbyusernetwork', _messageController.getMessagesByUserNetwork);

  app.use('/api', apiRoutes);

}
