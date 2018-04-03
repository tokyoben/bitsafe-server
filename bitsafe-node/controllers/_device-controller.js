const config = require("../config.js");
const domain = require('domain');
const client = require('redis').createClient({"host":config.redisHost});
const validator = require('../helpers/_validation-helper.js')
const request = require('request');
const express = require('express')
const cache = require('../helpers/_cache-helper.js')
const speakeasy = require("speakeasy");
const apiToken = require('api-token');

const errhandle = require('../error-handler.js');

function writeUnitTestData() {

}

var route = '/device';

var pinCache = {};
var pinAttempts = {};

var ddevices = errhandle.getdomain()


exports.getDevices = function(req, res) {

    ddevices.run(function() {

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
            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/GetDevices',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid
                    }
                };


                //console.log("posting getDevices");

                request.post(options, function(err, result) {
                  //console.log("getDevices result");
                  //console.log(result);

                    writeUnitTestData(options, result.body);

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

exports.getDeviceToken = function(req, res) {

    ddevices.run(function() {

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
            deviceName: {
                minlength: 3,
                maxlength: 50,
                dataType: 'ascii'
            },
            twoFactorCode: {
                minlength: 6,
                maxlength: 6,
                dataType: 'numeric'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            //console.log(pass);

            if (pass) {


                var options = {
                    'url': config.upstreamServer.baseUrl + "/account" + '/GetTwoFactorSecret',
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
                                        'url': config.upstreamServer.baseUrl + route + '/GetDeviceToken',
                                        'proxy': config.proxyServer.url,
                                        'form': {
                                            guid: req.body.guid,
                                            sharedid: req.body.sharedid,
                                            deviceName: req.body.deviceName,
                                            twoFactorCode: req.body.twoFactorCode
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
                                                var acc = JSON.parse(vResult);
                                                res.json(vResult);
                                            }

                                        });

                                    });

                                }

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

exports.getDeviceTokenForApp = function(req, res) {

    ddevices.run(function() {

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
            deviceName: {
                minlength: 3,
                maxlength: 50,
                dataType: 'ascii'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            //console.log(pass);

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/CreateDevice',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid,
                        deviceName: req.body.deviceName
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

                            var options = {
                                'url': config.upstreamServer.baseUrl + route + '/GetDeviceToken',
                                'proxy': config.proxyServer.url,
                                'form': {
                                    guid: req.body.guid,
                                    sharedid: req.body.sharedid,
                                    deviceName: req.body.deviceName
                                }
                            };

                            request.post(options, function(err, result) {
                                //writeUnitTestData(options, result.body);
                                //console.log("validating Result")
                                validator.validateResult(result, function(err, vResult) {
                                  //console.log(err)
                                  //console.log(vResult)

                                    if (err) {
                                        res.send(500, vResult.errorMessage);
                                    } else {
                                        var acc = JSON.parse(vResult);
                                        res.json(vResult);
                                    }

                                });

                            });

                        }

                    });

                });
            }

        });

    });


}

//GetDeviceToken
exports.createDevice = function(req, res) {

    ddevices.run(function() {

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
            deviceName: {
                minlength: 3,
                maxlength: 50,
                dataType: 'ascii'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            //console.log(pass);
            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/CreateDevice',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid,
                        deviceName: req.body.deviceName
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


//need to remove from memory after t


//need to add the token to this call
exports.getDeviceKey = function(req, res) {

    ddevices.run(function() {

        var expectedParams = {
            guid: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            devicePIN: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            regToken: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            //console.log(pass);
            if (pass) {


                //console.log("checking for pin cache...");
                if (!pinCache[req.body.guid + req.body.regToken]) {


                    //console.log("not found...");

                    var options = {
                        'url': config.upstreamServer.baseUrl + route + '/GetDeviceKey',
                        'proxy': config.proxyServer.url,
                        'form': {
                            guid: req.body.guid,
                            devicePIN: req.body.devicePIN,
                            regToken: req.body.regToken
                        }
                    };

                    //console.log("posting");

                    //console.log("checking database...");
                    request.post(options, function(err, result) {

                        writeUnitTestData(options, result.body);

                        //console.log("validating result");
                        validator.validateResult(result, function(err, vResult) {

                            //console.log(vResult)

                            if (err) {
                                res.send(500, vResult.errorMessage);
                            } else {


                                var acc = JSON.parse(vResult);

                                //if the PIN is correct
                                //cache the PIN in memory against the guid + deviceToken
                                //and a counter of incorrect PIN

                                //guid-regtoken {PIN,count}

                                if (acc.DeviceKey.length > 0) {

                                    //console.log("PIN correct...");
                                    var pinc = {
                                        pin: req.body.devicePIN,
                                        dkey: vResult
                                    };
                                    pinCache[req.body.guid + req.body.regToken] = pinc;
                                    pinAttempts[req.body.guid + req.body.regToken] = 0;



                                    //create an api session
                                    var user = apiToken.addUser(req.body.guid);

                                    acc.SessionToken = user.token;
                                    res.json(JSON.stringify(acc));


                                    //refresh the session


                                } else {

                                    //console.log("PIN incorrect from database...");

                                    var patt = pinAttempts[req.body.guid + req.body.regToken];

                                    if (!patt) {
                                        patt = 0;
                                    }

                                    pinAttempts[req.body.guid + req.body.regToken] = patt + 1;
                                    //console.log("PIN attempts = " + pinAttempts[req.body.guid + req.body.regToken]);

                                    //in-memory alone isn't really safe for this
                                    //ddos-ing the server could reset the count
                                    //this should be in some kind of distributed in-memory cache

                                    //move to redis

                                    //add timings / timeouts to PIN attempts based on account status
                                    //return at initial logon


                                    if (pinAttempts[req.body.guid + req.body.regToken] < 3) {

                                        res.send(500, "ErrPIN:" + pinAttempts[req.body.guid + req.body.regToken]);
                                        //if attempts = 3 then destroy the device

                                    } else {

                                        var options = {
                                            'url': config.upstreamServer.baseUrl + route + '/DestroyDevice',
                                            'proxy': config.proxyServer.url,
                                            'form': {
                                                guid: req.body.guid,
                                                devicePIN: req.body.devicePIN,
                                                regToken: req.body.regToken
                                            }
                                        };

                                        //console.log("posting");

                                        //console.log("checking database...");
                                        request.post(options, function(err, result) {
                                            writeUnitTestData(options, result.body);

                                            //console.log("validating result");
                                            validator.validateResult(result, function(err, vResult) {

                                                if (err) {

                                                    //error here is not good
                                                    //means failed to destroy device
                                                    //how should we handle this?
                                                    res.send(500, vResult.errorMessage);

                                                } else {

                                                    pinCache[req.body.guid + req.body.regToken] = null;

                                                    res.send(500, "ErrDeviceDestroyed");

                                                }

                                            });

                                        });

                                    }


                                }

                            }

                        });

                    });

                } else {

                    //console.log("found cache...");

                    var pinc = pinCache[req.body.guid + req.body.regToken];
                    //console.log(pinc);
                    //console.log(req.body.devicePIN);

                    if (pinc.pin == req.body.devicePIN) {

                        //console.log("PIN correct...");
                        pinAttempts[req.body.guid + req.body.regToken] = 0;

                        //refresh the session

                        var acc = JSON.parse(pinc.dkey);



                        //create an api session
                        var user = apiToken.addUser(req.body.guid);

                        acc.SessionToken = user.token;
                        res.json(JSON.stringify(acc));




                    } else {


                        //console.log("PIN incorrect from cache...");
                        var patt = pinAttempts[req.body.guid + req.body.regToken];

                        if (!patt) {
                            patt = 0;
                        }

                        pinAttempts[req.body.guid + req.body.regToken] = patt + 1;
                        //console.log("PIN attempts = " + pinAttempts[req.body.guid + req.body.regToken]);

                        //in-memory alone isn't really safe for this
                        //ddos-ing the server could reset the count
                        //this should be in some kind of distributed in-memory cache

                        if (pinAttempts[req.body.guid + req.body.regToken] < 3) {

                            res.send(500, "ErrPIN:" + pinAttempts[req.body.guid + req.body.regToken]);
                            //if attempts = 3 then destroy the device

                        } else {

                            var options = {
                                'url': config.upstreamServer.baseUrl + route + '/DestroyDevice',
                                'proxy': config.proxyServer.url,
                                'form': {
                                    guid: req.body.guid,
                                    devicePIN: req.body.devicePIN,
                                    regToken: req.body.regToken
                                }
                            };

                            //console.log("posting");

                            //console.log("checking database...");
                            request.post(options, function(err, result) {
                                writeUnitTestData(options, result.body);

                                //console.log("validating result");
                                validator.validateResult(result, function(err, vResult) {

                                    if (err) {

                                        //error here is not good
                                        //means failed to destroy device
                                        //how should we handle this?
                                        res.send(500, vResult.errorMessage);

                                    } else {

                                        //delete the session

                                        var user = apiToken.addUser(req.body.guid);

                                        pinCache[req.body.guid + req.body.regToken] = null;

                                        res.send(500, "ErrDeviceDestroyed");


                                    }

                                });

                            });

                        }

                    }


                }
            } else {
                res.send(500, "ErrInvalid");
            }


        });

    });

}


//version 2
//uses redis for in memory cache
//uses time based attempts
//3 attempts - >1hr
//3 attempts - >6hr
//1 attempt - >12hr
//1 attempt - >24hr - destroy


//need to add the token to this call
exports.getDeviceKey = function(req, res) {

    ddevices.run(function() {


        var pinblockinitial = 60;
        var pinblockmultiplier = 8;


        var expectedParams = {
            guid: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            devicePIN: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            regToken: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            //console.log(pass);
            if (pass) {


                //check that user has not exceeded PIN attempts

                client.get('pinattempts' + req.body.guid + req.body.regToken, function(err, attemptcheck) {

                    attemptcheck = attemptcheck * 1.0;

                    if (attemptcheck >= 3) {

                        client.ttl('pinattempts' + req.body.guid + req.body.regToken, function(err, ttl) {

                            res.send(500, "ErrBlocked:" + ttl);

                        });

                    } else {


                        client.get('pin' + req.body.guid + req.body.regToken, function(err, result) {


                            if (!result) {

                                var options = {
                                    'url': config.upstreamServer.baseUrl + route + '/GetDeviceKey',
                                    'proxy': config.proxyServer.url,
                                    'form': {
                                        guid: req.body.guid,
                                        devicePIN: req.body.devicePIN,
                                        regToken: req.body.regToken
                                    }
                                };


                                //console.log("posting");

                                //console.log("checking database...");
                                request.post(options, function(err, result) {
                                    writeUnitTestData(options, result.body);

                                    //console.log("validating result");
                                    validator.validateResult(result, function(err, vResult) {


                                        if (err) {
                                            res.send(500, vResult.errorMessage);
                                        } else {


                                            var acc = JSON.parse(vResult);

                                            //if the PIN is correct
                                            //cache the PIN in memory against the guid + deviceToken
                                            //and a counter of incorrect PIN

                                            //guid-regtoken {PIN,count}

                                            if (acc.DeviceKey.length > 0) {

                                                //console.log("PIN correct...");

                                                var pinc = {
                                                    pin: req.body.devicePIN,
                                                    dkey: vResult
                                                };
                                                client.set('pin' + req.body.guid + req.body.regToken, JSON.stringify(pinc), function(e) {

                                                    //console.log('setting device key');
                                                    //console.log(e);

                                                    client.set('pinattempts' + req.body.guid + req.body.regToken, 0, function(e) {

                                                        //remove any pinblock
                                                        client.del('pinblock' + req.body.guid + req.body.regToken, function(err, reply) {

                                                        });

                                                        //console.log('setting pin attempts to  0');
                                                        //console.log(e);

                                                        //create an api session
                                                        var user = apiToken.addUser(req.body.guid);

                                                        acc.SessionToken = user.token;
                                                        res.json(JSON.stringify(acc));

                                                    });

                                                });

                                                //refresh the session

                                            } else {

                                                //console.log("PIN incorrect from database...");

                                                client.get('pinattempts' + req.body.guid + req.body.regToken, function(err, result) {

                                                    var patt = result * 1.0;

                                                    if (!patt) {
                                                        patt = 0;
                                                    }

                                                    patt = patt + 1;

                                                    client.set('pinattempts' + req.body.guid + req.body.regToken, patt, function(e) {

                                                        if (patt < 3) {

                                                            res.send(500, "ErrPIN:" + patt);
                                                            //if attempts = 3 then destroy the device

                                                        } else {

                                                            //set PIN attempt cache to expire in n
                                                            //set PIN attemptTime to n^2

                                                            client.get('pinblock' + req.body.guid + req.body.regToken, function(err, pinblock) {

                                                                if (!pinblock) {

                                                                    pinblock = pinblockinitial;

                                                                } else {

                                                                    pinblock = pinblock * (pinblock / pinblockinitial) * pinblockmultiplier;
                                                                }

                                                                client.expire('pinattempts' + req.body.guid + req.body.regToken, pinblock, function(err, reply) {

                                                                });

                                                                client.set('pinblock' + req.body.guid + req.body.regToken, pinblock, function(err, reply) {

                                                                });

                                                                //console.log("block for " + pinblock + " amount of time");

                                                                res.send(500, "ErrBlocked:" + pinblock);

                                                            });

                                                        }

                                                    });

                                                });

                                            }

                                        }

                                    });

                                });

                            } else {

                                var pinc = JSON.parse(result);


                                if (pinc.pin == req.body.devicePIN) {

                                    //console.log("PIN correct...");

                                    client.set('pinattempts' + req.body.guid + req.body.regToken, 0, function(e) {

                                        //reset any PIN block
                                        client.del('pinblock' + req.body.guid + req.body.regToken, function(err, reply) {

                                        });

                                        //refresh the session

                                        var acc = JSON.parse(pinc.dkey);

                                        //create an api session
                                        var user = apiToken.addUser(req.body.guid);

                                        //add the session token property
                                        acc.SessionToken = user.token;

                                        res.json(JSON.stringify(acc));

                                    });

                                } else {

                                    client.get('pinattempts' + req.body.guid + req.body.regToken, function(err, result) {

                                        var patt = result * 1.0;

                                        if (!patt) {
                                            patt = 0;
                                        }

                                        patt = patt + 1;

                                        client.set('pinattempts' + req.body.guid + req.body.regToken, patt, function(e) {

                                            if (patt < 3) {

                                                //console.log("ErrPIN:" + patt);
                                                res.send(500, "ErrPIN:" + patt);
                                                //if attempts = 3 then destroy the device


                                            } else {

                                                client.get('pinblock' + req.body.guid + req.body.regToken, function(err, pinblock) {

                                                    if (!pinblock) {

                                                        pinblock = pinblockinitial;

                                                    } else {

                                                        pinblock = pinblock * (pinblock / pinblockinitial) * pinblockmultiplier;
                                                    }

                                                    client.expire('pinattempts' + req.body.guid + req.body.regToken, pinblock, function(err, reply) {

                                                    });

                                                    client.set('pinblock' + req.body.guid + req.body.regToken, pinblock, function(err, reply) {

                                                    });

                                                    //console.log("block for " + pinblock + " amount of time");

                                                    res.send(500, "ErrBlocked:" + pinblock);

                                                });

                                            }

                                        });

                                    });

                                }

                            }

                        });

                    }

                });

            } else {
                res.send(500, "ErrInvalid");
            }

        });

    });

}

//need to add the token to this call
exports.destroyDevice = function(req, res) {

    ddevices.run(function() {

        var expectedParams = {
            guid: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            regToken: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            //console.log(pass);

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/DestroyDevice',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        regToken: req.body.regToken
                    }
                };

                //console.log("posting");

                //console.log("checking database...");
                request.post(options, function(err, result) {
                    writeUnitTestData(options, result.body);

                    //console.log("validating result");
                    validator.validateResult(result, function(err, vResult) {

                        if (err) {

                            //error here is not good
                            //means failed to destroy device
                            //how should we handle this?
                            res.send(500, vResult.errorMessage);

                        } else {

                            res.json(JSON.stringify("DeviceDestroyed"));

                        }

                    });

                });

            } else {
                res.send(500, "ErrInvalid");
            }


        });

    });

}

//need to add the token to this call
exports.destroyDevice2FA = function(req, res) {

    ddevices.run(function() {

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
            deviceName: {
                minlength: 3,
                maxlength: 50,
                dataType: 'ascii'
            },
            twoFactorCode: {
                minlength: 6,
                maxlength: 8,
                dataType: 'numeric'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            //console.log(pass);

            if (pass) {


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

                                        var options = {
                                            'url': config.upstreamServer.baseUrl + route + '/DestroyDevice2fa',
                                            'proxy': config.proxyServer.url,
                                            'form': {
                                                guid: req.body.guid,
                                                sharedid: req.body.sharedid,
                                                deviceName: req.body.deviceName
                                            }
                                        };

                                        //console.log("posting");

                                        request.post(options, function(err, result) {

                                            writeUnitTestData(options, result.body);

                                            //console.log("validating result");
                                            validator.validateResult(result, function(err, vResult) {


                                                var vResult = JSON.parse(vResult);

                                                if (err) {

                                                    //error here is not good
                                                    //means failed to destroy device
                                                    //how should we handle this?
                                                    res.send(500, vResult.errorMessage);

                                                } else {

                                                    //console.log('removing pin cache');

                                                    //console.log(req.body.guid + vResult.message);

                                                    client.del('pin' + req.body.guid + vResult.message, function(err, reply) {

                                                    });

                                                    pinCache[req.body.guid + vResult.message] = null;

                                                    //console.log(pinCache);

                                                    res.json(JSON.stringify("DeviceDestroyed"));

                                                }

                                            });

                                        });

                                    }

                                }

                            }
                        });

                    });

                } else if (req.body.twoFactorCode.length == 8) {
                    //validate and use backupcode


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

                                var options = {
                                    'url': config.upstreamServer.baseUrl + route + '/DestroyDevice2fa',
                                    'proxy': config.proxyServer.url,
                                    'form': {
                                        guid: req.body.guid,
                                        sharedid: req.body.sharedid,
                                        deviceName: req.body.deviceName
                                    }
                                };

                                //console.log("posting");

                                request.post(options, function(err, result) {

                                    writeUnitTestData(options, result.body);

                                    //console.log("validating result");
                                    validator.validateResult(result, function(err, vResult) {

                                        if (err) {

                                            //error here is not good
                                            //means failed to destroy device
                                            //how should we handle this?
                                            res.send(500, vResult.errorMessage);

                                        } else {

                                            client.del('pin' + req.body.guid + vResult.message, function(err, reply) {

                                            });

                                            pinCache[req.body.guid + vResult.message] = null;

                                            res.json(JSON.stringify("DeviceDestroyed"));

                                        }

                                    });

                                });

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

exports.registerDevice = function(req, res) {

    ddevices.run(function() {

        var expectedParams = {
            guid: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            deviceName: {
                minlength: 3,
                maxlength: 50,
                dataType: 'ascii'
            },
            deviceId: {
                minlength: 0,
                maxlength: 50,
                dataType: 'ascii'
            },
            deviceModel: {
                minlength: 0,
                maxlength: 50,
                dataType: 'ascii'
            },
            devicePIN: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            regToken: {
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
                    'url': config.upstreamServer.baseUrl + route + '/RegisterDevice',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        deviceName: req.body.deviceName,
                        deviceId: req.body.deviceId,
                        deviceModel: req.body.deviceModel,
                        devicePIN: req.body.devicePIN,
                        regToken: req.body.regToken,
                        secret: req.body.secret
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

exports.getDeviceTokenRestore = function(req, res) {

    ddevices.run(function() {

        var expectedParams = {
            guid: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            deviceName: {
                minlength: 3,
                maxlength: 50,
                dataType: 'ascii'
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
                            'url': config.upstreamServer.baseUrl + route + '/GetDeviceTokenRestore',
                            'proxy': config.proxyServer.url,
                            'form': {
                                guid: req.body.guid,
                                deviceName: req.body.deviceName,
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
