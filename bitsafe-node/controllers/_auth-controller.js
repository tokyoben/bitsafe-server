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

var dauth = errhandle.getdomain();

function writeUnitTestData() {

}

var nodemailer = require("nodemailer");

var transport = nodemailer.createTransport(config.mailTransport, {
    AWSAccessKeyID: config.mailKeyID,
    AWSSecretKey: config.mailSecret,
    ServiceUrl: config.mailServiceURL
});

var route = "/account"

exports.requestAuthMigration = function(req, res) {

    dauth.run(function() {

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
            authreqtoken: {
                minlength: 36,
                maxlength: 36,
                dataType: 'guid'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            //here we need to validate the secret

            var options = {
                'url': config.upstreamServer.baseUrl + route + '/ValidateSecret',
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

                        //console.log("logging validate secret message");
                        //console.log(acc);

                        if (acc.guid) {

                            var request = {
                                guid: req.body.guid,
                                authreqtoken: req.body.authreqtoken
                            };

                            client.set('reqauth' + req.body.guid, JSON.stringify(request), function(e) {

                                client.expire('reqauth' + req.body.guid, 1200, function(err, reply) {

                                });

                                if (e) {
                                    res.send(500, "Error");
                                } else {

                                    var ret = {
                                        error: false,
                                        message: "ok"
                                    };
                                    res.json(JSON.stringify(ret));
                                }

                            });

                        }


                    }
                });

            });


        });

    });

}

exports.getAuthMigrationRequest = function(req, res) {

    dauth.run(function() {

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

            //console.log(pass);
            //return a json array

            var reqs = [];

            client.get('reqauth' + req.body.guid, function(err, req) {

                if (!err) {
                    reqs.push(JSON.parse(req));
                }

                res.json(JSON.stringify(reqs));

            });

        });

    });

}

exports.authMigration = function(req, res) {

    dauth.run(function() {

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
            twoFactorToken: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            authreqtoken: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            //console.log(pass);
            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + "/device" + '/GetDevMigTwoFactorToken',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid,
                        twoFactorToken: req.body.twoFactorToken
                    }
                };

                //console.log("posting");
                request.post(options, function(err, result) {
                    writeUnitTestData(options, result.body);

                    //console.log("validating result");
                    validator.validateResult(result, function(err, vResult) {

                        if (err) {
                            res.send(500, vResult.errorMessage);
                        } else {

                            //add the token into memory
                            //against the guid + token request token

                            var acc = JSON.parse(vResult);

                            //console.log("setting token")
                            //console.log(acc)

                            client.set(req.body.authreqtoken + req.body.guid, acc.message, function(e) {

                                if (e) {
                                    res.send(500, "Error");
                                } else {

                                    //remove the request

                                    //console.log('deleting reqauth' + req.body.guid);
                                    client.del('reqauth' + req.body.guid, function(err, reply) {

                                    });

                                    var ret = {
                                        error: false,
                                        message: "ok"
                                    };
                                    res.json(JSON.stringify(ret));
                                }

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

exports.getAuthMigrationToken = function(req, res) {

    dauth.run(function() {

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
            authreqtoken: {
                minlength: 36,
                maxlength: 36,
                dataType: 'guid'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            //validate secret //is this necessary?

            client.get(req.body.authreqtoken + req.body.guid, function(err, req) {

                var ret = {
                    error: false,
                    message: req
                };
                res.json(JSON.stringify(ret));


            });

        });

    });

}

exports.updateSecretPacket = function(req, res) {

    dauth.run(function() {

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
            vc: {
                minlength: 0,
                maxlength: 1000000,
                dataType: 'base64'
            },
            iv: {
                minlength: 0,
                maxlength: 300,
                dataType: 'hex'
            }
        };

        validateRequest(req, expectedParams, function(pass) {

            //console.log(pass);
            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/UpdateSecretPacket',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid,
                        vc: req.body.vc,
                        iv: req.body.iv
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

exports.validateSecret = function(req, res) {
    dauth.run(function() {

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
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            //console.log(pass);
            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/ValidateSecret',
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

exports.getResetToken = function(req, res) {

    dauth.run(function() {

        var expectedParams = {
            guid: {
                minlength: 36,
                maxlength: 36,
                dataType: 'guid'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            //console.log(pass);
            if (pass) {

                //GetTwoFactorToken
                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/GetResetToken',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid
                    }
                };

                request.post(options, function(err, result) {
                    writeUnitTestData(options, result.body);

                    validator.validateResult(result, function(err, vResult) {

                        var pres = JSON.parse(vResult);

                        //email token

                        //pres.Token

                        //console.log(pres.Token);
                        //console.log(pres.Email);

                        var message = pres.Token;
                        var nl = '\r\n\r\n';
                        var htnl = '<br/>';
                        var textmail = "Here is your token to reset your account." + nl + pres.Token;
                        var htmlmail = "<p>Here is your token to reset your account.</p><p>" + pres.Token + "</p>";

                        var iserror = false;
                        var mailOptions = {};
                        try {
                            mailOptions = {
                                from: "shibuyashadows@gmail.com",
                                to: pres.Email,
                                subject: "Your Account Token",
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

                    });

                });

            } else {
                res.send(500, "ErrInvalid");
            }

        });

    });

}

exports.updatePackets = function(req, res) {

    dauth.run(function() {

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
            accountPacket: {
                minlength: 0,
                maxlength: 1000000,
                dataType: 'base64'
            },
            userPacket: {
                minlength: 0,
                maxlength: 1000000,
                dataType: 'base64'
            },
            verifyPacket: {
                minlength: 0,
                maxlength: 1000000,
                dataType: 'base64'
            },
            passPacket: {
                minlength: 0,
                maxlength: 1000000,
                dataType: 'base64'
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
            PIV: {
                minlength: 0,
                maxlength: 300,
                dataType: 'hex'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                if (req.body.twoFactorCode.length == 6) {

                    //console.log(req.body.twoFactorCode);
                    //console.log('getting 2fa');

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

                                //console.log('result');
                                //console.log(parsedBody);

                                //hacks until 2fa is written properley
                                if (parsedBody != '') {

                                    var twoFactorSecretFromServer = parsedBody.GoogleAuthSecret;

                                    var twoFactorCodeGeneratedFromServerSecret = speakeasy.totp({
                                        key: twoFactorSecretFromServer,
                                        encoding: 'base32'
                                    });

                                    //allow a 2fa code from the previous 30 seconds in as valid
                                    //add a server side cache to verify?
                                    var time = parseInt(Date.now() / 1000) - 30;
                                    var prevTwoFactorCodeGeneratedFromServerSecret = speakeasy.totp({
                                        key: twoFactorSecretFromServer,
                                        encoding: 'base32',
                                        time: time
                                    });


                                    var twoFactorCodeFromClient = req.body.twoFactorCode;

                                    if (twoFactorCodeGeneratedFromServerSecret == twoFactorCodeFromClient || prevTwoFactorCodeGeneratedFromServerSecret == twoFactorCodeFromClient) {

                                        var options = {
                                            'url': config.upstreamServer.baseUrl + route + '/UpdatePackets',
                                            'proxy': config.proxyServer.url,
                                            'form': {
                                                guid: req.body.guid,
                                                sharedid: req.body.sharedid,
                                                accountPacket: req.body.accountPacket,
                                                userPacket: req.body.userPacket,
                                                verifyPacket: req.body.verifyPacket,
                                                passPacket: req.body.passPacket,
                                                IVA: req.body.IVA,
                                                IVU: req.body.IVU,
                                                IVR: req.body.IVR,
                                                PIV: req.body.PIV
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


                                    }

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

exports.migratePacket = function(req, res) {

    dnetwork.run(function() {

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
            accountPacket: {
                minlength: 0,
                maxlength: 10000000,
                dataType: 'base64'
            },
            IVA: {
                minlength: 0,
                maxlength: 300,
                dataType: 'hex'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                if (req.body.twoFactorCode.length == 6) {

                    //console.log(req.body.twoFactorCode);
                    //console.log('getting 2fa');

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

                                //console.log('result');
                                //console.log(parsedBody);

                                //hacks until 2fa is written properley
                                if (parsedBody != '') {

                                    var twoFactorSecretFromServer = parsedBody.GoogleAuthSecret;

                                    var twoFactorCodeGeneratedFromServerSecret = speakeasy.totp({
                                        key: twoFactorSecretFromServer,
                                        encoding: 'base32'
                                    });

                                    //allow a 2fa code from the previous 30 seconds in as valid
                                    //add a server side cache to verify?
                                    var time = parseInt(Date.now() / 1000) - 30;
                                    var prevTwoFactorCodeGeneratedFromServerSecret = speakeasy.totp({
                                        key: twoFactorSecretFromServer,
                                        encoding: 'base32',
                                        time: time
                                    });


                                    var twoFactorCodeFromClient = req.body.twoFactorCode;

                                    if (twoFactorCodeGeneratedFromServerSecret == twoFactorCodeFromClient || prevTwoFactorCodeGeneratedFromServerSecret == twoFactorCodeFromClient) {

                                        var options = {
                                            'url': config.upstreamServer.baseUrl + route + '/MigratePacket',
                                            'proxy': config.proxyServer.url,
                                            'form': {
                                                guid: req.body.guid,
                                                sharedid: req.body.sharedid,
                                                accountPacket: req.body.accountPacket,
                                                IVA: req.body.IVA
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


                                    }

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

exports.getVerificationCode = function(req, res) {


    dauth.run(function() {

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
            username: {
                minlength: 3,
                maxlength: 50,
                dataType: 'ascii'
            }
        };


        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/GetVerificationCode',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid,
                        username: req.body.username
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

exports.createBackupCodes = function(req, res) {

    dauth.run(function() {

        //console.log(req.body);

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
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {


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

                                    var options = {
                                        'url': config.upstreamServer.baseUrl + route + '/CreateBackupCodes',
                                        'proxy': config.proxyServer.url,
                                        'form': {
                                            guid: req.body.guid,
                                            sharedid: req.body.sharedid
                                        }
                                    };

                                    request.post(options, function(err, results) {
                                        writeUnitTestData(options, results.body);

                                        //console.log(results.body);

                                        validator.validateResult(results, function(err, vResult) {
                                            if (err) {
                                                res.send(500, vResult.errorMessage);
                                            } else {
                                                res.json(vResult);
                                            }

                                        });
                                    });
                                }

                            } else {
                                res.send(500, "ErrInvalid");
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

exports.resetTwoFactorAccount = function(req, res) {

    dauth.run(function() {

        var expectedParams = {
            guid: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            signaturecold: {
                minlength: 0,
                maxlength: 2000,
                dataType: 'hex'
            },
            secret: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                client.get('challenge' + req.body.guid, function(err, challenge) {

                    if (!err) {

                        var options = {
                            'url': config.upstreamServer.baseUrl + route + '/ResetTwoFactorAccount',
                            'proxy': config.proxyServer.url,
                            'form': {
                                guid: req.body.guid,
                                signaturecold: req.body.signaturecold,
                                secret: req.body.secret,
                                challenge: challenge
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

                        res.send(500, "ErrChallenge");
                    }

                });

            } else {
                res.send(500, "ErrInvalid");
            }

        });

    });
}

exports.getSigChallenge = function(req, res) {

    dauth.run(function() {

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
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/GetSigChallenge',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        secret: req.body.secret
                    }
                };

                request.post(options, function(err, result) {
                    writeUnitTestData(options, result.body);

                    validator.validateResult(result, function(err, vResult) {

                        if (err) {
                            res.send(500, vResult.errorMessage);
                        } else {

                            var challenge = JSON.parse(vResult);
                            challenge = challenge.message;

                            //cache the challenege in redis temporarily
                            client.set('challenge' + req.body.guid, challenge, function(e) {

                                client.expire('challenge' + req.body.guid, 60, function(err, reply) {

                                    res.json(vResult);

                                });

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
