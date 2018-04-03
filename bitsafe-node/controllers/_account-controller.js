const config = require("../config.js");
const domain = require('domain');
const client = require('redis').createClient({"host":config.redisHost});
const validator = require('../helpers/_validation-helper.js')

const request = require('request');
const express = require('express')
const cache = require('../helpers/_cache-helper.js')
const crypto = require("crypto")

const errhandle = require('../error-handler.js');

const speakeasy = require("speakeasy");
const apiToken = require('api-token');

var nodemailer = require("nodemailer");

var transport = nodemailer.createTransport("SES", {
    AWSAccessKeyID: "AKIAJBWCQF362ZERJYDQ",
    AWSSecretKey: "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",
    ServiceUrl: "email-smtp.us-east-1.amazonaws.com"
});

apiToken.setDb(client);

var route = '/account';

function postToRoute(options, callback){

  request.post(options, function(err, result) {

      callback(err,result);

  });

}

function writeUnitTestData() {

}

var daccount = errhandle.getdomain();

daccount.on('error', function(er) {

    //unexpected error so log and alter
    //console.log(er.stack);
    afterErrorHook(er);
});

function getTwoFactorSecret(guid, callback) {

    var options = {
        'url': config.upstreamServer.baseUrl + route + '/GetTwoFactorSecret',
        'proxy': config.proxyServer.url,
        'form': {
            guid: guid
        }
    };

    request.post(options, callback);

}

function saveTwoFactorSecret(guid, sharedid, secret, twoFactorOnLogin, callback) {

    var options = {
        'url': config.upstreamServer.baseUrl + route + '/UpdateTwoFactorSecret',
        'proxy': config.proxyServer.url,
        'form': {
            guid: guid,
            sharedid: sharedid,
            secret: secret,
            twoFactorOnLogin: twoFactorOnLogin
        }
    };

    request.post(options, callback);
}

function saveExistingTwoFactorSecret(guid, sharedid, secret, twoFactorOnLogin, callback) {

    var options = {
        'url': config.upstreamServer.baseUrl + route + '/UpdateExistingTwoFactorSecret',
        'proxy': config.proxyServer.url,
        'form': {
            guid: guid,
            sharedid: sharedid,
            secret: secret
        }
    };

    request.post(options, callback);
}

exports.getRecoveryPacket = function(req, res) {

    //console.log('calling /api/1/getrecoverypacket');

    daccount.run(function() {

        var expectedParams = {
            guid: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            }
        };


        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                //console.log(config.upstreamServer.baseUrl + route + '/GetRecoveryPacket');


                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/GetRecoveryPacket',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        username: ''
                    }
                };

                request.post(options, function(err, result) {

                    //console.log(options)
                    //console.log(result.body)
                    writeUnitTestData(options, result.body);

                    //console.log(result);
                    validator.validateResult(result, function(err, vResult) {

                        if (err) {
                            res.send(500, vResult.errorMessage);
                        } else {
                            res.json(vResult);
                        }
                    });

                });

            } else {
                res.send(500, "ErrInvalid");
            }

        });

    });

}

exports.sendWelcomeDetails = function(req, res) {

    daccount.run(function() {

        var expectedParams = {
            guid: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            sharedid: {
                minlength: 36,
                maxlength: 36,
                dataType: 'guid'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/GetWelcomeDetails',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid
                    }
                };

                request.post(options, function(err, result) {

                    writeUnitTestData(options, result.body);

                    validator.validateResult(result, function(err, vResult) {

                        //console.log(result);
                        //console.log(err);

                        if (err) {
                            res.send(500, vResult.errorMessage);
                        } else {

                            var jobj = JSON.parse(vResult);
                            var token = jobj.Token;
                            var email = jobj.Email;
                            var ninkiPubKey = jobj.NinkiPubKey;
                            var nickName = jobj.Nickname;

                            var nl = '\r\n\r\n';
                            var htnl = '<br/>';
                            var textmail = "Do NOT reply to this email" + nl + "Welcome to Ninki" + nl + "Do NOT delete this mail, it contains important information" + nl + "Please validate your email using this code:" + nl + token + nl + "Below is your Ninki master public key, you will need this in the event you need to recover your bitcoins:" + nl + ninkiPubKey + nl + "Your username is:" + nl + nickName;
                            var htmlmail = "<p>Do NOT reply to this email</p><p>Welcome to Ninki</p><p>Do NOT delete this mail, it contains important information</p><p>Please validate your email using this code:</p><p>" + token + "</p><p>Below is your Ninki master public key, you will need this in the event you need to recover your bitcoins:</p><p>" + ninkiPubKey + "</p><p>Your username is:</p><p>" + nickName + "</p>";

                            var mailOptions = {
                                from: "shibuyashadows@gmail.com",
                                to: email,
                                subject: "Welcome to Ninki - Validate your Email",
                                text: textmail,
                                html: htmlmail
                            }

                            transport.sendMail(mailOptions, function(error, response) {
                                if (error) {
                                    //console.log(error);
                                    res.send(500, "ErrSendMail")
                                } else {
                                    //console.log("ok");
                                    var ret = {
                                        error: false,
                                        message: "ok"
                                    };
                                    res.json(JSON.stringify(ret));
                                }
                                // if you don't want to use this transport object anymore, uncomment following line
                                //smtpTransport.close(); // shut down the connection pool, no more messages
                            });

                        }
                    });

                });

            } else {
                res.send(500, "ErrInvalid");
            }

        });

    });

}

exports.verifyRecoverPacket = function(req, res) {

    daccount.run(function() {


        var expectedParams = {
            guid: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            token: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/VerifyRecoverPacket',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        token: req.body.token
                    }
                };

                request.post(options, function(err, result) {
                    writeUnitTestData(options, result.body);

                    validator.validateResult(result, function(err, vResult) {

                        //console.log(result);
                        //console.log(err);

                        if (err) {
                            res.send(500, vResult.errorMessage);
                        } else {
                            //res.json(result.body);

                            //parse the result
                            //if ok, send an email containing the returned token
                            var iserror = false;

                            var accDetails = JSON.parse(vResult);


                            var message = accDetails.token;
                            var nl = '\r\n\r\n';
                            var htnl = '<br/>';
                            var textmail = "Here is your token to setup two factor authentication on your Ninki account." + nl + accDetails.token;
                            var htmlmail = "<p>Here is your token to setup two factor authentication on your Ninki account</p><p>" + accDetails.token + "</p>";


                            var mailOptions = {};
                            try {
                                mailOptions = {
                                    from: "shibuyashadows@gmail.com",
                                    to: accDetails.email,
                                    subject: "Setup Two Factor Authentication",
                                    text: textmail,
                                    html: htmlmail
                                }

                            } catch (oerror) {
                                iserror = true;
                            }

                            if (!iserror) {
                                transport.sendMail(mailOptions, function(error, response) {

                                    if (error) {
                                        //console.log(error);
                                        res.send(500, "Error");
                                    } else {
                                        //console.log("ok");
                                        var ret = {
                                            error: false,
                                            message: "ok"
                                        };
                                        res.json(JSON.stringify(ret));
                                    }
                                    // if you don't want to use this transport object anymore, uncomment following line
                                    //smtpTransport.close(); // shut down the connection pool, no more messages
                                });
                            } else {
                                res.send(500, "Error");
                            }

                        }
                    });

                });

            } else {
                res.send(500, "ErrInvalid");
            }

        });

    });

}

exports.getEmailValidation = function(req, res) {

    daccount.run(function() {

        var expectedParams = {
            guid: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            sharedid: {
                minlength: 36,
                maxlength: 36,
                dataType: 'guid'
            },
            token: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            }
        };


        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/GetEmailValidation',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid,
                        token: req.body.token
                    }
                };

                request.post(options, function(err, result) {
                    writeUnitTestData(options, result.body);

                    validator.validateResult(result, function(err, vResult) {

                        //console.log(err);

                        if (err) {
                            res.send(500, vResult.errorMessage);
                        } else {
                            res.json(vResult);
                        }

                    });
                });

            } else {
                res.send(500, "ErrInvalid");
            }
        });

    });


}

exports.getEmailValidationTwoFactor = function(req, res) {

    daccount.run(function() {

        var expectedParams = {
            guid: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            token: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/GetEmailValidationTwoFactor',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        token: req.body.token,
                        status: 1
                    }
                };

                request.post(options, function(err, result) {

                    writeUnitTestData(options, result.body);

                    validator.validateResult(result, function(err, vResult) {

                        //console.log(err);

                        if (err) {
                            res.send(500, vResult.errorMessage);
                        } else {
                            res.json(vResult);
                        }

                    });
                });


            } else {
                res.send(500, "ErrInvalid");
            }

        });

    });

}

exports.GetGUIDByMPKH = function(req, res) {

    daccount.run(function() {

        var expectedParams = {
            mpkh: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/GetGUIDByMPKH',
                    'proxy': config.proxyServer.url,
                    'form': {
                        mpkh: req.body.mpkh
                    }
                };

                request.post(options, function(err, result) {

                    writeUnitTestData(options, result.body);

                    validator.validateResult(result, function(err, vResult) {

                        //console.log(err);

                        if (err) {
                            res.send(500, vResult.errorMessage);
                        } else {
                            res.json(vResult);
                        }

                    });
                });


            } else {
                res.send(500, "ErrInvalid");
            }

        });

    });

}

exports.emailGUID = function(req, res) {

    daccount.run(function() {

        var expectedParams = {
            userName: {
                minlength: 3,
                maxlength: 50,
                dataType: 'ascii'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var userName = req.body.userName;

                //call function, get guid and email address by userName

                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/GetRecoveryInfoByUsername',
                    'proxy': config.proxyServer.url,
                    'form': {
                        userName: userName
                    }
                };

                request.post(options, function(err, result) {
                    writeUnitTestData(options, result.body);

                    validator.validateResult(result, function(err, vResult) {

                        //console.log(vResult);

                        if (err) {
                            res.send(500, vResult.errorMessage);
                        } else {

                            var iserror = false;
                            var accDetails = JSON.parse(result.body);

                            var mailOptions = {};

                            var nl = '\r\n\r\n';
                            var htnl = '<br/>';
                            var textmail = 'Please find your guid below:' + nl + accDetails.guid;
                            var htmlmail = 'Please find your guid below:' + htnl + accDetails.guid;

                            try {
                                mailOptions = {
                                    from: "shibuyashadows@gmail.com",
                                    to: accDetails.email,
                                    subject: "Ninki Account Info",
                                    text: textmail,
                                    html: htmlmail
                                }
                            } catch (oerror) {
                                iserror = true;
                            }

                            if (!iserror) {
                                transport.sendMail(mailOptions, function(error, response) {
                                    if (error) {
                                        //console.log(error);
                                    } else {
                                        //console.log("Message sent: " + response.message);
                                        var ret = {
                                            error: false,
                                            message: "ok"
                                        };
                                        res.json(JSON.stringify(ret));
                                    }
                                    // if you don't want to use this transport object anymore, uncomment following line
                                    //smtpTransport.close(); // shut down the connection pool, no more messages
                                });
                            } else {
                                res.send(500, "Error");
                            }
                        }

                    });

                });

            } else {
                res.send(500, "ErrInvalid");
            }

        });

    });

}

exports.getTwoFactorImg = function(req, res) {

    daccount.run(function() {

        var expectedParams = {
            guid: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            sharedid: {
                minlength: 36,
                maxlength: 36,
                dataType: 'guid'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                //here we have greated the guid and sharedid and also if we have selected 2fa
                //we save the secret

                var guid = req.body.guid;
                var sharedid = req.body.sharedid;
                var twoFactorResults = speakeasy.generate_key({
                    name: "Ninki",
                    length: 20,
                    google_auth_qr: true
                });

                saveTwoFactorSecret(guid, sharedid, twoFactorResults.base32, false, function(req, res_dummy) {
                    var ret = {
                        error: false,
                        message: twoFactorResults.base32
                    };
                    res.json(JSON.stringify(ret));

                });

            } else {
                res.send(500, "ErrInvalid");
            }
        });

    });

}

exports.getNewTwoFactorImg = function(req, res) {

    daccount.run(function() {

        var expectedParams = {
            guid: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            sharedid: {
                minlength: 36,
                maxlength: 36,
                dataType: 'guid'
            },
            twoFactorCode: {
                minlength: 6,
                maxlength: 64,
                dataType: 'ascii'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            //console.log(expectedParams);
            //console.log(pass);


            if (pass) {

                //here we have greated the guid and sharedid and also if we have selected 2fa
                //we save the secret

                if (req.body.twoFactorCode.length == 6) {

                    var options = {
                        'url': config.upstreamServer.baseUrl + route + '/GetTwoFactorSecret',
                        'proxy': config.proxyServer.url,
                        'form': {
                            guid: req.body.guid,
                            sharedid: req.body.sharedid
                        }
                    };

                    request.post(options, function(err, results1) {
                        writeUnitTestData(options, results1.body);

                        validator.validateResult(results1, function(err, vResult1) {

                            if (err) {
                                res.send(500, vResult1.errorMessage);
                            } else {

                                var parsedBody = JSON.parse(vResult1);

                                if (parsedBody != '') {

                                    var twoFactorSecretFromServer = parsedBody.GoogleAuthSecret;
                                    var twoFactorCodeGeneratedFromServerSecret = speakeasy.totp({
                                        key: twoFactorSecretFromServer,
                                        encoding: 'base32'
                                    });


                                    var twoFactorCodeFromClient = req.body.twoFactorCode;

                                    if (twoFactorCodeGeneratedFromServerSecret != twoFactorCodeFromClient) {
                                        res.send(500, "Invalid two factor code");
                                        return;
                                    } else {

                                        var guid = req.body.guid;
                                        var sharedid = req.body.sharedid;
                                        var twoFactorResults = speakeasy.generate_key({
                                            name: "Ninki",
                                            length: 20,
                                            google_auth_qr: true
                                        });

                                        saveExistingTwoFactorSecret(guid, sharedid, twoFactorResults.base32, true, function(req, res_dummy) {
                                            //to do: handle fail to save ??
                                            var ret = {
                                                error: false,
                                                message: twoFactorResults.base32
                                            };
                                            res.json(JSON.stringify(ret));

                                        });

                                    }

                                }

                            }

                        });

                    });

                } else if (req.body.twoFactorCode.length == 8) {

                    var options = {
                        'url': config.upstreamServer.baseUrl + route + '/UseBackupCode',
                        'proxy': config.proxyServer.url,
                        'form': {
                            guid: req.body.guid,
                            sharedid: req.body.sharedid,
                            usercode: req.body.twoFactorCode
                        }
                    };

                    request.post(options, function(err, results1) {
                        writeUnitTestData(options, results1.body);

                        validator.validateResult(results1, function(err, vResult1) {


                            //console.log(results1.body);

                            if (err) {
                                res.send(500, "ErrBackupCode");
                            } else {


                                var guid = req.body.guid;
                                var sharedid = req.body.sharedid;
                                var twoFactorResults = speakeasy.generate_key({
                                    name: "Ninki",
                                    length: 20,
                                    google_auth_qr: true
                                });

                                saveExistingTwoFactorSecret(guid, sharedid, twoFactorResults.base32, true, function(req, res_dummy) {
                                    var ret = {
                                        error: false,
                                        message: twoFactorResults.base32
                                    };
                                    res.json(JSON.stringify(ret));

                                });

                            }
                        });

                    });

                } else {

                    var options = {
                        'url': config.upstreamServer.baseUrl + route + '/VerifyToken',
                        'proxy': config.proxyServer.url,
                        'form': {
                            guid: req.body.guid,
                            token: req.body.twoFactorCode
                        }
                    };

                    request.post(options, function(err, valtok) {

                        validator.validateResult(valtok, function(err, valtok1) {

                            valtok1 = JSON.parse(valtok1);

                            //console.log(valtok1);


                            if (err) {
                                res.send(500, valtok1.errorMessage);
                            } else {

                                if (valtok1.message == "ValidForTwoFactor") {


                                    var guid = req.body.guid;
                                    var sharedid = req.body.sharedid;
                                    var twoFactorResults = speakeasy.generate_key({
                                        name: "Ninki",
                                        length: 20,
                                        google_auth_qr: true
                                    });

                                    saveExistingTwoFactorSecret(guid, sharedid, twoFactorResults.base32, true, function(req, res_dummy) {
                                        var ret = {
                                            error: false,
                                            message: twoFactorResults.base32
                                        };
                                        res.json(JSON.stringify(ret));

                                    });


                                } else if (valtok1.message == "Expired") {
                                    res.send(500, "TokenExpired");
                                } else {
                                    res.send(500, "Invalid two factor code");
                                    return;
                                }
                            }

                        });

                    });

                }

            } else {
                res.send(500, "ErrInvalid");
            }
        });

    });

}

exports.updateTwoFactor = function(req, res) {

    daccount.run(function() {

        //console.log('CALLING UPDATE 2FA');

        var expectedParams = {
            guid: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            sharedid: {
                minlength: 36,
                maxlength: 36,
                dataType: 'guid'
            },
            twoFactorCode: {
                minlength: 6,
                maxlength: 6,
                dataType: 'numeric'
            },
            verifyToken: {
                minlength: 0,
                maxlength: 64,
                dataType: 'hex'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var guid = req.body.guid;
                var sharedid = req.body.sharedid;
                var twoFactorCode = req.body.twoFactorCode;

                getTwoFactorSecret(guid, function(err, result) {

                    validator.validateResult(result, function(err, vResult) {


                        //console.log(vResult);

                        //hacks until 2fa is written properley
                        if (result.body != 'ErrNoSecret') {
                            var parsedBody = JSON.parse(vResult);
                            var twoFactorSecretFromServer = parsedBody.GoogleAuthSecret;
                            var twoFactorCodeGeneratedFromServerSecret = speakeasy.totp({
                                key: twoFactorSecretFromServer,
                                encoding: 'base32'
                            });


                            var twoFactorCodeFromClient = req.body.twoFactorCode;

                            if (twoFactorCodeGeneratedFromServerSecret != twoFactorCodeFromClient) {
                                res.send(500, "Invalid two factor code");
                                return;
                            } else {

                                var options = {
                                    'url': config.upstreamServer.baseUrl + route + '/UpdateTwoFactorSecret',
                                    'proxy': config.proxyServer.url,
                                    'form': {
                                        guid: guid,
                                        sharedid: sharedid,
                                        secret: parsedBody.GoogleAuthSecret,
                                        twoFactorOnLogin: true
                                    }
                                };

                                request.post(options, function(err, result) {
                                    writeUnitTestData(options, result.body);

                                    validator.validateResult(result, function(err, vResult) {

                                        if (err) {
                                            res.send(500, vResult.errorMessage);
                                        } else {


                                            var user = apiToken.addUser(req.body.guid);
                                            var ret = {};
                                            ret.error = false;
                                            ret.message = user.token;
                                            //console.log(user);
                                            //console.log("sending token");

                                            res.json(JSON.stringify(ret));

                                        }

                                    });
                                });


                            }
                        }

                    });

                });

            } else {
                res.send(500, "ErrInvalid");
            }

        });


    });


}

exports.createAccount = function(req, res) {

    daccount.run(function() {

        var expectedParams = {
            guid: {
                minlength: 36,
                maxlength: 36,
                dataType: 'guid'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/CreateAccount',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid
                    }
                };

                request.post(options, function(err, result) {

                    writeUnitTestData(options, result.body);

                    validator.validateResult(result, function(err, vResult) {

                        if (err) {
                            res.send(500, vResult.errorMessage);
                        } else {
                            res.json(vResult);
                        }

                    });

                });

            } else {
                res.send(500, "ErrInvalid");
            }

        });

    });
}

exports.createAccountv2 = function(req, res) {

    daccount.run(function() {

        var expectedParams = {
            guid: {
                minlength: 36,
                maxlength: 36,
                dataType: 'guid'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/CreateAccount',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid
                    }
                };

                request.post(options, function(err, result) {
                    writeUnitTestData(options, result.body);

                    validator.validateResult(result, function(err, vResult) {

                        if (err) {
                            res.send(500, vResult.errorMessage);
                        } else {
                            res.json(vResult);
                        }

                    });

                });

            } else {
                res.send(500, "ErrInvalid");
            }

        });

    });
}

exports.updateEmailAddress = function(req, res) {

    daccount.run(function() {

        var expectedParams = {
            guid: {
                minlength: 36,
                maxlength: 36,
                dataType: 'guid'
            },
            sharedid: {
                minlength: 36,
                maxlength: 36,
                dataType: 'guid'
            },
            emailAddress: {
                minlength: 0,
                maxlength: 100,
                dataType: 'email'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/UpdateEmailAddress',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid,
                        emailAddress: req.body.emailAddress
                    }
                };

                request.post(options, function(err, result) {
                    writeUnitTestData(options, result.body);

                    validator.validateResult(result, function(err, vResult) {

                        if (err) {
                            res.send(500, vResult.errorMessage);
                        } else {

                            res.json(vResult);
                            //if this is ok
                            //then send the mpk email

                        }

                    });

                });

            } else {
                res.send(500, "ErrInvalid");
            }

        });

    });
}

exports.createAccount2 = function(req, res) {

    daccount.run(function() {

        var expectedParams = {
            guid: {
                minlength: 36,
                maxlength: 36,
                dataType: 'guid'
            },
            sharedid: {
                minlength: 36,
                maxlength: 36,
                dataType: 'guid'
            },
            payload: {
                minlength: 0,
                maxlength: 1000000,
                dataType: 'base64'
            },
            hotPublicKey: {
                minlength: 0,
                maxlength: 1000,
                dataType: 'ascii'
            },
            coldPublicKey: {
                minlength: 0,
                maxlength: 1000,
                dataType: 'ascii'
            },
            googleAuthSecret: {
                minlength: 0,
                maxlength: 1000,
                dataType: 'base64'
            },
            nickName: {
                minlength: 3,
                maxlength: 50,
                dataType: 'ascii'
            },
            emailAddress: {
                minlength: 0,
                maxlength: 100,
                dataType: 'email'
            },
            userPublicKey: {
                minlength: 0,
                maxlength: 1000000,
                dataType: 'ascii'
            },
            userPayload: {
                minlength: 0,
                maxlength: 1000000,
                dataType: 'ascii'
            },
            secret: {
                minlength: 0,
                maxlength: 300,
                dataType: 'ascii'
            },
            ninkiPhrase: {
                minlength: 0,
                maxlength: 1000,
                dataType: 'ascii'
            },
            IVA: {
                minlength: 0,
                maxlength: 300,
                dataType: 'hex'
            },
            IVU: {
                minlength: 0,
                maxlength: 300,
                dataType: 'hex'
            },
            IVR: {
                minlength: 0,
                maxlength: 300,
                dataType: 'hex'
            },
            recPacket: {
                minlength: 0,
                maxlength: 1000000,
                dataType: 'base64'
            },
            recPacketIV: {
                minlength: 0,
                maxlength: 300,
                dataType: 'hex'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var optionsusr = {
                    'url': config.upstreamServer.baseUrl + route + '/DoesAccountExist',
                    'proxy': config.proxyServer.url,
                    'form': {
                        username: req.body.nickName,
                        email: req.body.emailAddress
                    }
                };


                request.post(optionsusr, function(err, results) {

                    validator.validateResult(results, function(err, vcheck) {

                        if (err) {
                            res.send(500, vcheck.errorMessage);
                        } else {

                            var tmpcheck = JSON.parse(vcheck);

                            //console.log(tmpcheck);

                            if (tmpcheck.UserExists || (tmpcheck.EmailExists && req.body.emailAddress.length > 0)) {

                                res.send(500, "ErrInvalid");

                            } else {

                                var options = {
                                    'url': config.upstreamServer.baseUrl + route + '/CreateAccount2',
                                    'proxy': config.proxyServer.url,
                                    'form': {
                                        guid: req.body.guid,
                                        sharedid: req.body.sharedid,
                                        payload: req.body.payload,
                                        hotPublicKey: req.body.hotPublicKey,
                                        coldPublicKey: req.body.coldPublicKey,
                                        googleAuthSecret: req.body.googleAuthSecret,
                                        nickName: req.body.nickName,
                                        emailAddress: req.body.emailAddress,
                                        userPublicKey: req.body.userPublicKey,
                                        userPayload: req.body.userPayload,
                                        secret: req.body.secret,
                                        IVA: req.body.IVA,
                                        IVU: req.body.IVU,
                                        IVR: req.body.IVR,
                                        recPacket: req.body.recPacket,
                                        recPacketIV: req.body.recPacketIV
                                    }
                                };

                                request.post(options, function(err, result) {
                                    writeUnitTestData(options, result.body);

                                    validator.validateResult(result, function(err, vResult) {

                                        if (err) {
                                            res.send(500, vResult.errorMessage)
                                        } else {


                                            if (req.body.emailAddress.length > 0) {

                                                var token = JSON.parse(vResult).result;
                                                var email = req.body.emailAddress;
                                                var nl = '\r\n\r\n';
                                                var htnl = '<br/>';
                                                var textmail = "Do NOT reply to this email" + nl + "Welcome to Ninki" + nl + "Do NOT delete this mail, it contains important information" + nl + "Please validate your email using this code:" + nl + token + nl + "Below is your Ninki master public key, you will need this, together with the two phrases you wrote down, in the event you need to recover your bitcoins:" + nl + req.body.ninkiPhrase + nl + "Your username is:" + nl + req.body.nickName;
                                                var htmlmail = "<p>Do NOT reply to this email</p><p>Welcome to Ninki</p><p>Do NOT delete this mail, it contains important information</p><p>Please validate your email using this code:</p><p>" + token + "</p><p>Below is your Ninki master public key, you will need this, together with the two phrases you wrote down, in the event you neeed to recover your bitcoins:</p><p>" + req.body.ninkiPhrase + "</p><p>Your username is:</p><p>" + req.body.nickName + "</p>";


                                                var mailOptions = {
                                                    from: "shibuyashadows@gmail.com",
                                                    to: email,
                                                    subject: "Welcome to Ninki - Validate your Email",
                                                    text: textmail,
                                                    html: htmlmail
                                                }

                                                transport.sendMail(mailOptions, function(error, response) {
                                                    if (error) {
                                                        //console.log(error);

                                                        res.send(500, "ErrSendMail")

                                                    } else {
                                                        //console.log("ok");


                                                        var sha256 = crypto.createHash("sha256");
                                                        sha256.update(req.body.guid, "utf8"); //utf8 here
                                                        var result = sha256.digest("hex");


                                                        var user = apiToken.addUser(result);
                                                        var ret = {};
                                                        ret.error = false;
                                                        ret.message = user.token;
                                                        //console.log(user);
                                                        //console.log("sending token");
                                                        res.json(JSON.stringify(ret));


                                                    }
                                                    //if you don't want to use this transport object anymore, uncomment following line
                                                    //smtpTransport.close(); // shut down the connection pool, no more messages
                                                });

                                            } else {

                                                var sha256 = crypto.createHash("sha256");
                                                sha256.update(req.body.guid, "utf8"); //utf8 here
                                                var result = sha256.digest("hex");


                                                var user = apiToken.addUser(result);
                                                var ret = {};
                                                ret.error = false;
                                                ret.message = user.token;
                                                //console.log(user);
                                                //console.log("sending token");
                                                res.json(JSON.stringify(ret));

                                            }
                                        }

                                    });


                                });

                            }
                        }

                    });
                });

            } else {
                res.send(500, "ErrInvalid");
            }

        });

    });

}

exports.createAccountSecPub = function(req, res) {

    daccount.run(function() {

        var expectedParams = {
            guid: {
                minlength: 36,
                maxlength: 36,
                dataType: 'guid'
            },
            sharedid: {
                minlength: 36,
                maxlength: 36,
                dataType: 'guid'
            },
            secretPub: {
                minlength: 0,
                maxlength: 2000,
                dataType: 'hex'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {
                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/CreateAccountSecPub',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid,
                        secretPub: req.body.secretPub
                    }
                };

                request.post(options, function(err, result) {

                    writeUnitTestData(options, result.body);

                    validator.validateResult(result, function(err, vResult) {

                        if (err) {
                            res.send(500, vResult.errorMessage);
                        } else {
                            res.json(vResult);
                        }

                    });

                });

            } else {
                res.send(500, "ErrInvalid");
            }

        });


    });


}

exports.getAccountSecPub = function(req, res) {

    daccount.run(function() {

        var expectedParams = {
            guid: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            sharedid: {
                minlength: 36,
                maxlength: 36,
                dataType: 'guid'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {



            if (pass) {
                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/GetAccountSecPub',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid
                    }
                };

                request.post(options, function(err, result) {
                    writeUnitTestData(options, result.body);

                    validator.validateResult(result, function(err, vResult) {

                        if (err) {
                            res.send(500, vResult.errorMessage);
                        } else {
                            res.json(vResult);
                        }

                    });

                });

            } else {
                res.send(500, "ErrInvalid");
            }

        });


    });


}

exports.removeAccountSecPub = function(req, res) {

    daccount.run(function() {

        var expectedParams = {
            guid: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            sharedid: {
                minlength: 36,
                maxlength: 36,
                dataType: 'guid'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {
                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/RemoveAccountSecPub',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid
                    }
                };

                request.post(options, function(err, result) {

                    writeUnitTestData(options, result.body);

                    validator.validateResult(result, function(err, vResult) {

                        if (err) {
                            res.send(500, vResult.errorMessage);
                        } else {
                            res.json(vResult);
                        }

                    });

                });

            } else {
                res.send(500, "ErrInvalid");
            }

        });


    });

}

exports.getAccountDetails = function(req, res) {


    //console.log(req.headers);


    daccount.run(function() {

        var expectedParams = {
            guid: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            secret: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            twoFactorCode: {
                minlength: 0,
                maxlength: 64,
                dataType: 'ascii'
            },
            rememberTwoFactor: {
                minlength: 0,
                maxlength: 5,
                dataType: 'boolean'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {


            //get the account details
            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/GetAccountDetails',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        secret: req.body.secret
                    }
                };

                //console.log("posting");
                request.post(options, function(err, result) {
                    writeUnitTestData(options, result.body);

                    //get back the payload
                    //if 2FA is enabled then perform the check
                    //else just returen as normal
                    //console.log(accDetails.body);
                    //console.log("validating result");
                    validator.validateResult(result, function(err, vResult) {

                        if (err) {
                            res.send(500, vResult.errorMessage);
                        } else {


                            var acc = JSON.parse(vResult);

                            //console.log("is two fact");
                            //console.log(acc.TwoFactorOnLogin);


                            if (acc.TwoFactorOnLogin) {

                                //if length is 6 we have a 2 factor code
                                //if not we may have a token
                                if (req.body.twoFactorCode.length == 6) {

                                    var options = {
                                        'url': config.upstreamServer.baseUrl + route + '/GetTwoFactorSecret',
                                        'proxy': config.proxyServer.url,
                                        'form': {
                                            guid: req.body.guid,
                                            sharedid: req.body.sharedid
                                        }
                                    };

                                    request.post(options, function(err, results1) {
                                        writeUnitTestData(options, results1.body);

                                        validator.validateResult(results1, function(err, vResult1) {

                                            if (err) {
                                                res.send(500, vResult1.errorMessage);
                                            } else {

                                                var parsedBody = JSON.parse(vResult1);

                                                if (parsedBody != '') {

                                                    var twoFactorSecretFromServer = parsedBody.GoogleAuthSecret;
                                                    var twoFactorCodeGeneratedFromServerSecret = speakeasy.totp({
                                                        key: twoFactorSecretFromServer,
                                                        encoding: 'base32'
                                                    });


                                                    var twoFactorCodeFromClient = req.body.twoFactorCode;

                                                    if (twoFactorCodeGeneratedFromServerSecret != twoFactorCodeFromClient) {
                                                        res.send(500, "Invalid two factor code");


                                                        return;
                                                    } else {

                                                        //start an api session for the user


                                                        var user = apiToken.addUser(req.body.guid);

                                                        //console.log("remember?...");


                                                        //if the user wants to bypass two factor on login
                                                        //then generate a token
                                                        if (req.body.rememberTwoFactor) {

                                                            //create a token which expires in 3 hours
                                                            //write the token to a cookie
                                                            //console.log("setting 2 fa cookie...");

                                                            //GetTwoFactorToken
                                                            var options2 = {
                                                                'url': config.upstreamServer.baseUrl + route + '/GetTwoFactorToken',
                                                                'proxy': config.proxyServer.url,
                                                                'form': {
                                                                    guid: req.body.guid,
                                                                    sharedid: ''
                                                                }
                                                            };

                                                            request.post(options2, function(err, results2) {

                                                                validator.validateResult(results2, function(err, vResult2) {

                                                                    var pres = JSON.parse(vResult2);
                                                                    var tacc = JSON.parse(vResult);

                                                                    tacc.CookieToken = pres.Token;
                                                                    tacc.SessionToken = user.token;
                                                                    vResult = JSON.stringify(tacc);
                                                                    res.json(vResult);

                                                                });

                                                            });

                                                        } else {


                                                            acc.SessionToken = user.token;
                                                            vResult = JSON.stringify(acc);
                                                            //console.log(vResult);
                                                            res.json(vResult);

                                                        }


                                                    }
                                                }

                                            }

                                        });
                                    });

                                } else if (req.body.twoFactorCode.length == 8) {

                                    //we have a backup code
                                    //verify

                                    var options = {
                                        'url': config.upstreamServer.baseUrl + route + '/UseBackupCode',
                                        'proxy': config.proxyServer.url,
                                        'form': {
                                            guid: req.body.guid,
                                            sharedid: '',
                                            usercode: req.body.twoFactorCode
                                        }
                                    };

                                    request.post(options, function(err, results1) {
                                        writeUnitTestData(options, results1.body);

                                        validator.validateResult(results1, function(err, vResult1) {

                                            //console.log(results1.body);

                                            if (err) {

                                                res.send(500, "ErrBackupCode");

                                            } else {

                                                var user = apiToken.addUser(req.body.guid);

                                                acc.SessionToken = user.token;
                                                vResult = JSON.stringify(acc);

                                                res.json(vResult);

                                            }

                                        });

                                    });

                                } else {

                                    //verify the two factor bypass token


                                    var options = {
                                        'url': config.upstreamServer.baseUrl + route + '/VerifyToken',
                                        'proxy': config.proxyServer.url,
                                        'form': {
                                            guid: req.body.guid,
                                            token: req.body.twoFactorCode
                                        }
                                    };

                                    request.post(options, function(err, valtok) {

                                        validator.validateResult(valtok, function(err, valtok1) {

                                            valtok1 = JSON.parse(valtok1);

                                            //console.log(valtok1);


                                            if (err) {
                                                res.send(500, valtok1.errorMessage);
                                            } else {
                                                if (valtok1.message == "Valid" || valtok1.message == "ValidForTwoFactor") {


                                                    //create an api session
                                                    var user = apiToken.addUser(req.body.guid);

                                                    acc.SessionToken = user.token;
                                                    res.json(JSON.stringify(acc));



                                                } else if (valtok1.message == "Expired") {
                                                    res.send(500, "TokenExpired");
                                                } else {
                                                    res.send(500, "Invalid two factor code");
                                                    return;
                                                }
                                            }

                                        });

                                    });

                                }


                            } else {
                                //two factor is now mandatory for this data

                                //special case where a beta account didn't setup 2 factor
                                //log them in the old way so their account gets migrated
                                //then we can make them setup 2factor authentication


                                //create an api session
                                var user = apiToken.addUser(req.body.guid);

                                acc.SessionToken = user.token;
                                res.json(JSON.stringify(acc));

                                //res.send(500, "Invalid two factor code");
                            }
                        }

                    });

                });
            } else {
                res.send(500, "ErrInvalid");
            }


        });

    });

}

exports.getUserData = function(req, res) {

    daccount.run(function() {

        var expectedParams = {
            guid: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            sharedid: {
                minlength: 36,
                maxlength: 36,
                dataType: 'guid'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var accountData = {};

                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/GetUserData',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid
                    }
                };

                request.post(options, function(err, result) {
                    writeUnitTestData(options, result.body);

                    validator.validateResult(result, function(err, vResult) {

                        if (err) {

                            res.send(500, vResult.errorMessage);

                        } else {

                            res.json(vResult);
                        }

                    });

                });

            } else {

                res.send(500, "ErrInvalid");

            }

        });

    });

}

exports.getUserPacket = function(req, res) {

    daccount.run(function() {

        var expectedParams = {
            guid: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            sharedid: {
                minlength: 36,
                maxlength: 36,
                dataType: 'guid'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route +'/GetUserPacket',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid
                    }
                };

                request.post(options, function(err, results) {
                    writeUnitTestData(options, results.body);
                    validator.validateResult(results, function(err, vResult) {
                        if (err) {
                            res.send(500, vResult.errorMessage);
                        } else {
                            res.json(vResult);
                        }

                    });
                });

            } else {
                res.send(500, "ErrInvalid");
            }


        });
    });
}

exports.getAccountData = function(req, res) {

    daccount.run(function() {

        var expectedParams = {
            guid: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            sharedid: {
                minlength: 36,
                maxlength: 36,
                dataType: 'guid'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var accountData = {};

                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/GetAccountSettings',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid
                    }
                };

                request.post(options, function(err, result) {
                    writeUnitTestData(options, result.body);

                    validator.validateResult(result, function(err, vResult) {

                        if (err) {
                            res.send(500, vResult.errorMessage);
                        } else {

                            accountData.settings = JSON.parse(vResult);

                            var options = {
                                'url': config.upstreamServer.baseUrl + route + '/GetNickname',
                                'proxy': config.proxyServer.url,
                                'form': {
                                    guid: req.body.guid,
                                    sharedid: req.body.sharedid
                                }
                            };

                            request.post(options, function(err, results) {
                                writeUnitTestData(options, results.body);

                                validator.validateResult(results, function(err, vResult) {

                                    if (err) {
                                        res.send(500, vResult.errorMessage);
                                    } else {

                                        var nickname = JSON.parse(vResult).message;

                                        accountData.nickname = nickname;

                                        var options = {
                                            'url': config.upstreamServer.baseUrl + route + '/GetUserPacket',
                                            'proxy': config.proxyServer.url,
                                            'form': {
                                                guid: req.body.guid,
                                                sharedid: req.body.sharedid
                                            }
                                        };

                                        request.post(options, function(err, results) {
                                            writeUnitTestData(options, results.body);
                                            validator.validateResult(results, function(err, vResult) {
                                                if (err) {
                                                    res.send(500, vResult.errorMessage);
                                                } else {

                                                    accountData.userPacket = JSON.parse(vResult);

                                                    var options = {
                                                        'url': config.upstreamServer.baseUrl + route + '/GetUserProfile',
                                                        'proxy': config.proxyServer.url,
                                                        'form': {
                                                            guid: req.body.guid,
                                                            sharedid: req.body.sharedid
                                                        }
                                                    };

                                                    request.post(options, function(err, results) {
                                                        writeUnitTestData(options, results.body);
                                                        validator.validateResult(results, function(err, vResult) {
                                                            if (err) {
                                                                res.send(500, vResult.errorMessage);
                                                            } else {

                                                                accountData.userProfile = JSON.parse(vResult);
                                                                res.json(JSON.stringify(accountData));
                                                            }

                                                        });
                                                    });


                                                }

                                            });
                                        });


                                        //res.json(vResult);
                                    }

                                });
                            });


                            //res.json(vResult);
                        }

                    });

                });

            } else {

                res.send(500, "ErrInvalid");

            }

        });

    });

}

//information leak
exports.doesAccountExist = function(req, res) {

    daccount.run(function() {
        //console.log("running doesaccountexist");

        var expectedParams = {
            username: {
                minlength: 3,
                maxlength: 50,
                dataType: 'ascii'
            },
            email: {
                minlength: 0,
                maxlength: 100,
                dataType: 'email'
            }
        };

        //console.log("calling validate request");
        validator.validateRequest(req, expectedParams, function(pass) {
            //console.log(pass);
            if (pass) {


                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/DoesAccountExist',
                    'proxy': config.proxyServer.url,
                    'form': {
                        username: req.body.username,
                        email: req.body.email
                    }
                };


                request.post(options, function(err, results) {
                    writeUnitTestData(options, results.body);
                    validator.validateResult(results, function(err, vResult) {
                        if (err) {
                            res.send(500, vResult.errorMessage);
                        } else {
                            res.json(vResult);
                        }

                    });
                });

            } else {
                res.send(500, "ErrInvalid");
            }


        });
    });
}

exports.unlockAccount = function(req, res) {

    daccount.run(function() {


        var expectedParams = {
            guid: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            token: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/UnlockAccount',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        token: req.body.token
                    }
                };

                request.post(options, function(err, results) {
                    writeUnitTestData(options, results.body);
                    validator.validateResult(results, function(err, vResult) {
                        if (err) {
                            res.send(500, vResult.errorMessage);
                        } else {
                            res.json(vResult);
                        }

                    });
                });
            } else {
                res.send(500, "ErrInvalid");
            }

        });
    });
}

exports.getNickname = function(req, res) {

    daccount.run(function() {

        var expectedParams = {
            guid: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            sharedid: {
                minlength: 36,
                maxlength: 36,
                dataType: 'guid'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/GetNickname',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid
                    }
                };


                request.post(options, function(err, results) {
                    writeUnitTestData(options, results.body);
                    validator.validateResult(results, function(err, vResult) {
                        if (err) {
                            res.send(500, vResult.errorMessage);
                        } else {
                            res.json(vResult);
                        }

                    });
                });

            } else {
                res.send(500, "ErrInvalid");
            }

        });
    });
}




exports.updateUserProfile = function(req, res) {

    daccount.run(function() {

        var expectedParams = {
            guid: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            sharedid: {
                minlength: 36,
                maxlength: 36,
                dataType: 'guid'
            },
            profileImage: {
                minlength: 0,
                maxlength: 50,
                dataType: 'ascii'
            },
            status: {
                minlength: 0,
                maxlength: 50,
                dataType: 'ascii'
            },
            tax: {
                minlength: 0,
                maxlength: 50,
                dataType: 'float'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/UpdateUserProfile',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid,
                        profileImage: req.body.profileImage,
                        status: req.body.status,
                        tax: req.body.tax
                    }
                };

                request.post(options, function(err, results) {
                    writeUnitTestData(options, results.body);
                    validator.validateResult(results, function(err, vResult) {
                        if (err) {
                            res.send(500, vResult.errorMessage);
                        } else {
                            res.json(vResult);
                        }

                    });
                });

            } else {
                res.send(500, "ErrInvalid");
            }

        });
    });
}

exports.getUserProfile = function(req, res) {

    daccount.run(function() {

        var expectedParams = {
            guid: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            sharedid: {
                minlength: 36,
                maxlength: 36,
                dataType: 'guid'
            }
        };


        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/GetUserProfile',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid
                    }
                };

                request.post(options, function(err, results) {
                    writeUnitTestData(options, results.body);
                    validator.validateResult(results, function(err, vResult) {
                        if (err) {
                            res.send(500, vResult.errorMessage);
                        } else {
                            res.json(vResult);
                        }

                    });
                });

            } else {
                res.send(500, "ErrInvalid");
            }

        });
    });
}
