const config = require("../config.js");
const domain = require('domain');
const client = require('redis').createClient({"host":config.redisHost});
const validator = require('../helpers/_validation-helper.js')
const request = require('request');
const express = require('express')
const cache = require('../helpers/_cache-helper.js')
const speakeasy = require("speakeasy");
const crypto = require("crypto")

const errhandle = require('../error-handler.js');

var route = '/transaction';

function writeUnitTestData() {

}

var dtran = errhandle.getdomain();

//app.post('/api/1/u/getlimitstatus',
//app.post('/api/1/u/preparetransaction'


//string guid, string sharedid
exports.getLimitStatus = function(req, res) {

    dtran.run(function() {

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
                    'url': config.upstreamServer.baseUrl + route + '/GetLimitStatus',
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

exports.prepareTransaction = function(req, res) {

    dtran.run(function() {

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
            amount: {
                minlength: 0,
                maxlength: 32,
                dataType: 'int'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/PrepareTransaction',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid,
                        amount: req.body.amount
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

exports.getCoinProfile = function(req, res) {

    dtran.run(function() {

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
                    'url': config.upstreamServer.baseUrl + route + '/GetCoinProfile',
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

exports.getUnspentOutputs = function(req, res) {

    dtran.run(function() {

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
                    'url': config.upstreamServer.baseUrl + route + '/GetUnspentOutputs',
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

exports.createTransactionRecord = function(req, res) {

    dtran.run(function() {

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
            },
            transactionid: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            address: {
                minlength: 0,
                maxlength: 255,
                dataType: 'ascii'
            },
            amount: {
                minlength: 0,
                maxlength: 20,
                dataType: 'int'
            },
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                res.json("{\"error\":false,\"message\":\"ok\"}");

            } else {
                res.send(500, "ErrInvalid");
            }

        });
    });
}

exports.getTransactionRecords = function(req, res) {

    dtran.run(function() {

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
                    'url': config.upstreamServer.baseUrl + route + '/GetTransactionRecords',
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



exports.getTransactionsForNetwork = function(req, res) {

    dtran.run(function() {

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


            var sha256 = crypto.createHash("sha256");
            sha256.update(req.body.guid + req.body.username, "utf8"); //utf8 here

            var cacheKey = sha256.digest("hex");

            var cacheroot = 'transaction';
            var lkey = req.body.lkey;
            var lkeyname = "TransactionId";
            var pageFrom = req.body.tranPageFrom;
            var pageTo = req.body.tranPageTo;
            var reqtimestamp = req.body.timestamp;

            cache.getCache(cacheroot, cacheKey, reqtimestamp, lkeyname, lkey, pageFrom, pageTo, function(err, cres) {

                if (!err) {

                    //load the cache from the database
                    _getTransactionsForNetwork(req.body.guid, req.body.sharedid, req.body.username, function(err, vResult) {

                        if (!err) {

                            cache.loadCache(cacheroot, cacheKey, pageFrom, pageTo, vResult, function(err, result) {

                                //return the cache
                                if (!err) {
                                    res.json(result);
                                } else {
                                    res.send(500, "ErrInvalid");
                                }

                            });

                        } else {
                            res.send(500, "ErrInvalid");
                        }

                    });

                } else {
                    res.send(500, "ErrInvalid");
                }

            }, function(err, gres) {

                //return the cache
                if (!err) {
                    res.json(gres);
                } else {
                    res.send(500, "ErrInvalid");
                }

            });

        });

    });
}

function _getTransactionsForNetwork(guid, sharedid, username, callback) {

    //console.log("called getTransactionsForNetwork");
    var options = {
        'url': config.upstreamServer.baseUrl + route +  '/GetTransactionsForNetwork',
        'proxy': config.proxyServer.url,
        'form': {
            guid: guid,
            sharedid: sharedid,
            username: username
        }
    };

    request.post(options, function(err, results) {
        writeUnitTestData(options, results.body);
        validator.validateResult(results, function(err, vResult) {
            return callback(err, vResult);
        });
    });

}

exports.sendTransaction = function(req, res) {

    dtran.run(function() {

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
            },
            userName: {
                minlength: 0,
                maxlength: 50,
                dataType: 'ascii'
            },
            jsonPacket: {
                minlength: 0,
                maxlength: 10000000,
                dataType: 'ascii'
            }
        };

        //console.log('calling send');
        //console.log(req.body.twoFactorCode);
        validator.validateRequest(req, expectedParams, function(pass) {

            //validate two factor code

            //console.log('validated');

            if (pass) {

                //console.log('passed');
                if (req.body.twoFactorCode.length == 6) {

                    //console.log(req.body.twoFactorCode);
                    //console.log('getting 2fa');

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
                                            'url': config.upstreamServer.baseUrl + route + '/SendTransaction',
                                            'proxy': config.proxyServer.url,
                                            'form': {
                                                jsonPacket: req.body.jsonPacket,
                                                sharedid: req.body.sharedid,
                                                userName: req.body.userName,
                                                twofactor: true
                                            }
                                        };

                                        request.post(options, function(err, results) {
                                            writeUnitTestData(options, results.body);
                                            validator.validateResult(results, function(err, vResult) {
                                                if (err) {
                                                    res.send(500, vResult.errorMessage);
                                                } else {

                                                    //expire the transaction cache

                                                    var tmpret = JSON.parse(vResult);

                                                    //console.log(vResult);


                                                    if (req.body.userName) {

                                                        //console.log("deleting networktrans cache...");

                                                        var sha256 = crypto.createHash("sha256");
                                                        sha256.update(req.body.guid + req.body.userName, "utf8"); //utf8 here
                                                        var cacheKeyNet2 = sha256.digest("hex");

                                                        client.del('transaction' + cacheKeyNet2, function(err, reply) {

                                                        });
                                                        client.del('transactionts' + cacheKeyNet2, function(err, reply) {

                                                        });

                                                        client.del('transaction' + tmpret.NetCacheKey, function(err, reply) {

                                                        });
                                                        client.del('transactionts' + tmpret.NetCacheKey, function(err, reply) {

                                                        });

                                                    }


                                                    //console.log('deleting cache keys...');
                                                    //console.log('transaction' + req.body.guid);
                                                    //console.log('transaction' + tmpret.CacheKey);

                                                    client.del('transaction' + req.body.guid, function(err, reply) {

                                                    });
                                                    client.del('transactionts' + req.body.guid, function(err, reply) {

                                                    });

                                                    client.del('timeline' + req.body.guid, function(err, reply) {

                                                    });
                                                    client.del('timelinets' + req.body.guid, function(err, reply) {

                                                    });

                                                    client.del('bal' + req.body.guid, function(err, reply) {

                                                    });

                                                    client.del('transaction' + tmpret.CacheKey, function(err, reply) {

                                                    });
                                                    client.del('transactionts' + tmpret.CacheKey, function(err, reply) {

                                                    });

                                                    client.del('timeline' + tmpret.CacheKey, function(err, reply) {

                                                    });
                                                    client.del('timelinets' + tmpret.CacheKey, function(err, reply) {

                                                    });

                                                    client.del('bal' + tmpret.CacheKey, function(err, reply) {

                                                    });

                                                    var ret = {
                                                        error: false,
                                                        message: vResult.TransactionId
                                                    };
                                                    res.json(JSON.stringify(ret));

                                                }

                                            });
                                        });

                                    } else {


                                        //if length is 64
                                        //validate token is valid
                                        //validate the token is a mobile token


                                        res.send(500, "Invalid two factor code");
                                        return;

                                    }

                                }

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
                                if (valtok1.message == "Valid") {

                                    var options = {
                                        'url': config.upstreamServer.baseUrl + route + '/SendTransaction',
                                        'proxy': config.proxyServer.url,
                                        'form': {
                                            jsonPacket: req.body.jsonPacket,
                                            sharedid: req.body.sharedid,
                                            userName: req.body.userName,
                                            twofactor: false
                                        }
                                    };

                                    request.post(options, function(err, results) {
                                        writeUnitTestData(options, results.body);
                                        validator.validateResult(results, function(err, vResult) {
                                            if (err) {
                                                res.send(500, vResult.errorMessage);
                                            } else {


                                                var tmpret = JSON.parse(vResult);

                                                if (req.body.userName) {

                                                    //console.log("deleting networktrans cache...");

                                                    var sha256 = crypto.createHash("sha256");
                                                    sha256.update(req.body.guid + req.body.userName, "utf8"); //utf8 here
                                                    var cacheKeyNet2 = sha256.digest("hex");

                                                    //console.log(cacheKeyNet2);

                                                    client.del('transaction' + cacheKeyNet2, function(err, reply) {

                                                    });
                                                    client.del('transactionts' + cacheKeyNet2, function(err, reply) {

                                                    });

                                                    client.del('transaction' + tmpret.NetCacheKey, function(err, reply) {

                                                    });
                                                    client.del('transactionts' + tmpret.NetCacheKey, function(err, reply) {

                                                    });


                                                }


                                                //console.log(vResult);

                                                //console.log('deleting cache keys...');
                                                //console.log('transaction' + req.body.guid);
                                                //console.log('transaction' + tmpret.CacheKey);

                                                client.del('transaction' + req.body.guid, function(err, reply) {

                                                });
                                                client.del('transactionts' + req.body.guid, function(err, reply) {

                                                });

                                                client.del('timeline' + req.body.guid, function(err, reply) {

                                                });
                                                client.del('timelinets' + req.body.guid, function(err, reply) {

                                                });

                                                client.del('bal' + req.body.guid, function(err, reply) {

                                                });

                                                client.del('transaction' + tmpret.CacheKey, function(err, reply) {

                                                });
                                                client.del('transactionts' + tmpret.CacheKey, function(err, reply) {

                                                });

                                                client.del('timeline' + tmpret.CacheKey, function(err, reply) {

                                                });
                                                client.del('timelinets' + tmpret.CacheKey, function(err, reply) {

                                                });

                                                client.del('bal' + tmpret.CacheKey, function(err, reply) {

                                                });

                                                var ret = {
                                                    error: false,
                                                    message: vResult.TransactionId
                                                };
                                                res.json(JSON.stringify(ret));

                                            }

                                        });
                                    });
                                } else if (valtok1.message == "Expired") {
                                    res.send(500, "TokenExpired");
                                    return;
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

exports.getTransactionTemplate = function(req, res) {

    dtran.run(function() {

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
            transactionid: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            }
        };


        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/GetTransactionTemplate',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid,
                        transactionid: req.body.transactionid
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




//add a version 2 api that supports caching and paging of transactions
//hit db for top x transactions
//cache them all up
//on send / send friend / send by friend / receive transaction listener - blockchain
//take index parameters to select from the cache


//timestamp: {minlength: 0, maxlength: 50, dataType: 'ascii'},
//lkey: {minlength: 0, maxlength: 50, dataType: 'ascii'}


exports.getTransactionFeed = function(req, res) {

    dtran.run(function() {

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
            timestamp: {
                minlength: 0,
                maxlength: 50,
                dataType: 'ascii'
            },
            lkey: {
                minlength: 0,
                maxlength: 50,
                dataType: 'ascii'
            },
            tranPageFrom: {
                minlength: 0,
                maxlength: 50,
                dataType: 'numeric'
            },
            tranPageTo: {
                minlength: 0,
                maxlength: 50,
                dataType: 'numeric'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var cacheroot = 'transaction';
                var cacheKey = req.body.guid;
                var lkey = req.body.lkey;
                var lkeyname = "TransactionId";
                var pageFrom = req.body.tranPageFrom;
                var pageTo = req.body.tranPageTo;
                var reqtimestamp = req.body.timestamp;

                cache.getCache(cacheroot, cacheKey, reqtimestamp, lkeyname, lkey, pageFrom, pageTo, function(err, cres) {

                    if (!err) {

                        //load the cache from the database
                        _getTransactionFeed(req.body.guid, req.body.sharedid, function(err, vResult) {

                            if (!err) {

                                cache.loadCache(cacheroot, cacheKey, pageFrom, pageTo, vResult, function(err, result) {

                                    //return the cache
                                    if (!err) {
                                        res.json(result);
                                    } else {
                                        res.send(500, "ErrInvalid");
                                    }

                                });

                            } else {
                                res.send(500, "ErrInvalid");
                            }

                        });

                    } else {
                        res.send(500, "ErrInvalid");
                    }

                }, function(err, gres) {

                    //return the cache
                    if (!err) {
                        res.json(gres);
                    } else {
                        res.send(500, "ErrInvalid");
                    }

                });

            } else {
                res.send(500, "ErrInvalid");
            }

        });
    });
}


//split out get transaction feed so we are left with the generic caching code


//domians for these functions

function _getTransactionFeed(guid, sharedid, callback) {

    var options = {
        'url': config.upstreamServer.baseUrl + route + '/GetTransactionFeed',
        'proxy': config.proxyServer.url,
        'form': {
            guid: guid,
            sharedid: sharedid
        }
    };

    request.post(options, function(err, results) {
        writeUnitTestData(options, results.body);

        validator.validateResult(results, function(err, vResult) {

            return callback(err, vResult);

        });

    });

}


exports.getTransactionTemplate = function(req, res) {

    dtran.run(function() {

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
            transactionid: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            }
        };


        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/GetTransactionTemplate',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid,
                        transactionid: req.body.transactionid
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



exports.getBalance = function(req, res) {

    dtran.run(function() {

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

                client.get('bal' + req.body.guid, function(err, bal) {

                    if (bal) {

                        //console.log("balance from cache...");
                        var ret = JSON.parse(bal);
                        res.json(ret);

                    } else {

                        var options = {
                            'url': config.upstreamServer.baseUrl + route + '/GetBalance',
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

                                    client.set('bal' + req.body.guid, JSON.stringify(vResult), function(err, reply) {

                                    });
                                    //console.log("balance from db...");
                                    res.json(vResult);
                                }

                            });

                        });

                    }

                });

            } else {
                res.send(500, "ErrInvalid");
            }


        });

    });
}


exports.getUnconfirmedBalance = function(req, res) {


    dtran.run(function() {

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
                    'url': config.upstreamServer.baseUrl + route + '/GetUnconfirmedBalance',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid
                    }
                };


                request.post(options, function(err, results) {
                    writeUnitTestData(options, results.body);

                    alidator.validateResult(results, function(err, vResult) {

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
