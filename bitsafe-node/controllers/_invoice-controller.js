const config = require("../config.js");
const domain = require('domain');
const client = require('redis').createClient({"host":config.redisHost});
const validator = require('../helpers/_validation-helper.js')
const request = require('request');
const express = require('express')
const cache = require('../helpers/_cache-helper.js')
const crypto = require("crypto")

const errhandle = require('../error-handler.js');

function writeUnitTestData() {

}

var route = '/invoice';

var dinvoice = errhandle.getdomain();

exports.createInvoice = function(req, res) {

    dinvoice.run(function() {
        //console.log(req.body);

        //restrict packet length to roughly 20 invoice lines?

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
            userName: {
                minlength: 3,
                maxlength: 50,
                dataType: 'ascii'
            },
            packetForMe: {
                minlength: 0,
                maxlength: 10000000,
                dataType: 'ascii'
            },
            packetForThem: {
                minlength: 0,
                maxlength: 10000000,
                dataType: 'ascii'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {
            //console.log(pass);
            if (pass) {
                var options = {
                    'url': config.upstreamServer.baseUrl + route +'/CreateInvoice',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid,
                        userName: req.body.userName,
                        packetForMe: req.body.packetForMe,
                        packetForThem: req.body.packetForThem
                    }
                };

                request.post(options, function(err, results) {
                    writeUnitTestData(options, results.body);

                    validator.validateResult(results, function(err, vResult) {
                        if (err) {
                            res.send(500, vResult.errorMessage);
                        } else {


                            //invoicetpnet
                            //invoicebmnet



                            var cacheroot = 'invoice';
                            var cacheroot2 = 'invoicebu';

                            var cacherootnet = 'invoicetpnet';
                            var cacherootnet2 = 'invoicebunet';

                            var cacheKey = req.body.guid;


                            var sha256 = crypto.createHash("sha256");
                            sha256.update(req.body.guid + req.body.userName, "utf8"); //utf8 here
                            var cacheKeyNet2 = sha256.digest("hex");


                            var tmpret = JSON.parse(vResult);

                            client.del(cacheroot + req.body.guid, function(err, reply) {

                            });
                            client.del(cacheroot + 'ts' + req.body.guid, function(err, reply) {

                            });

                            client.del(cacheroot + tmpret.CacheKey, function(err, reply) {

                            });
                            client.del(cacheroot + 'ts' + tmpret.CacheKey, function(err, reply) {

                            });

                            client.del(cacheroot2 + req.body.guid, function(err, reply) {

                            });
                            client.del(cacheroot2 + 'ts' + req.body.guid, function(err, reply) {

                            });

                            client.del(cacheroot2 + tmpret.CacheKey, function(err, reply) {

                            });
                            client.del(cacheroot2 + 'ts' + tmpret.CacheKey, function(err, reply) {

                            });

                            client.del(cacherootnet + tmpret.CacheKeyNet, function(err, reply) {

                            });
                            client.del(cacherootnet + 'ts' + tmpret.CacheKeyNet, function(err, reply) {

                            });

                            client.del(cacherootnet2 + tmpret.CacheKeyNet, function(err, reply) {

                            });
                            client.del(cacherootnet2 + 'ts' + tmpret.CacheKeyNet, function(err, reply) {

                            });

                            client.del(cacherootnet + cacheKeyNet2, function(err, reply) {

                            });
                            client.del(cacherootnet + 'ts' + cacheKeyNet2, function(err, reply) {

                            });

                            client.del(cacherootnet2 + cacheKeyNet2, function(err, reply) {

                            });
                            client.del(cacherootnet2 + 'ts' + cacheKeyNet2, function(err, reply) {

                            });

                            client.del('timeline' + req.body.guid, function(err, reply) {

                            });
                            client.del('timelinets' + req.body.guid, function(err, reply) {

                            });

                            client.del('timeline' + tmpret.CacheKey, function(err, reply) {

                            });
                            client.del('timelinets' + tmpret.CacheKey, function(err, reply) {

                            });

                            //return keys for network list also

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

exports.getInvoicesToPayNetwork = function(req, res) {

    dinvoice.run(function() {

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
            pageFrom: {
                minlength: 0,
                maxlength: 50,
                dataType: 'numeric'
            },
            pageTo: {
                minlength: 0,
                maxlength: 50,
                dataType: 'numeric'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var cacheroot = 'invoicetpnet';

                var sha256 = crypto.createHash("sha256");
                sha256.update(req.body.guid + req.body.username, "utf8"); //utf8 here
                var cacheKey = sha256.digest("hex");

                var lkey = req.body.lkey;
                var lkeyname = "dummy";
                var pageFrom = req.body.pageFrom;
                var pageTo = req.body.pageTo;
                var reqtimestamp = req.body.timestamp;

                cache.getCache(cacheroot, cacheKey, reqtimestamp, lkeyname, lkey, pageFrom, pageTo, function(err, cres) {

                    if (!err) {

                        //load the cache from the database
                        _getInvoicesToPayNetwork(req.body.guid, req.body.sharedid, req.body.username, function(err, vResult) {

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

exports.getInvoicesByUserNetwork = function(req, res) {

    dinvoice.run(function() {

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
            pageFrom: {
                minlength: 0,
                maxlength: 50,
                dataType: 'numeric'
            },
            pageTo: {
                minlength: 0,
                maxlength: 50,
                dataType: 'numeric'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var cacheroot = 'invoicebunet';

                var sha256 = crypto.createHash("sha256");
                sha256.update(req.body.guid + req.body.username, "utf8"); //utf8 here
                var cacheKey = sha256.digest("hex");

                var lkey = req.body.lkey;
                var lkeyname = "dummy";
                var pageFrom = req.body.pageFrom;
                var pageTo = req.body.pageTo;
                var reqtimestamp = req.body.timestamp;

                cache.getCache(cacheroot, cacheKey, reqtimestamp, lkeyname, lkey, pageFrom, pageTo, function(err, cres) {

                    if (!err) {

                        //load the cache from the database
                        _getInvoicesByUserNetwork(req.body.guid, req.body.sharedid, req.body.username, function(err, vResult) {

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

exports.updateInvoice = function(req, res) {

    dinvoice.run(function() {

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
            userName: {
                minlength: 3,
                maxlength: 50,
                dataType: 'ascii'
            },
            invoiceId: {
                minlength: 0,
                maxlength: 50,
                dataType: 'int'
            },
            transactionid: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            },
            status: {
                minlength: 0,
                maxlength: 50,
                dataType: 'int'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {
                var options = {
                    'url': config.upstreamServer.baseUrl + route +'/UpdateInvoice',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid,
                        userName: req.body.userName,
                        invoiceId: req.body.invoiceId,
                        transactionId: req.body.transactionId,
                        status: req.body.status
                    }
                };

                request.post(options, function(err, results) {
                    writeUnitTestData(options, results.body);
                    validator.validateResult(results, function(err, vResult) {
                        if (err) {
                            res.send(500, vResult.errorMessage);
                        } else {

                            var cacheroot = 'invoice';
                            var cacheroot2 = 'invoicebu';
                            var cacheKey = req.body.guid;

                            var cacherootnet = 'invoicetpnet';
                            var cacherootnet2 = 'invoicebunet';

                            var sha256 = crypto.createHash("sha256");
                            sha256.update(req.body.guid + req.body.userName, "utf8"); //utf8 here
                            var cacheKeyNet2 = sha256.digest("hex");

                            var tmpret = JSON.parse(vResult);

                            client.del(cacheroot + req.body.guid, function(err, reply) {

                            });
                            client.del(cacheroot + 'ts' + req.body.guid, function(err, reply) {

                            });

                            client.del(cacheroot + tmpret.CacheKey, function(err, reply) {

                            });
                            client.del(cacheroot + 'ts' + tmpret.CacheKey, function(err, reply) {

                            });

                            client.del(cacheroot2 + req.body.guid, function(err, reply) {

                            });
                            client.del(cacheroot2 + 'ts' + req.body.guid, function(err, reply) {

                            });

                            client.del(cacheroot2 + tmpret.CacheKey, function(err, reply) {

                            });
                            client.del(cacheroot2 + 'ts' + tmpret.CacheKey, function(err, reply) {

                            });

                            client.del(cacherootnet + tmpret.CacheKeyNet, function(err, reply) {

                            });
                            client.del(cacherootnet + 'ts' + tmpret.CacheKeyNet, function(err, reply) {

                            });

                            client.del(cacherootnet2 + tmpret.CacheKeyNet, function(err, reply) {

                            });
                            client.del(cacherootnet2 + 'ts' + tmpret.CacheKeyNet, function(err, reply) {

                            });

                            client.del(cacherootnet + cacheKeyNet2, function(err, reply) {

                            });
                            client.del(cacherootnet + 'ts' + cacheKeyNet2, function(err, reply) {

                            });

                            client.del(cacherootnet2 + cacheKeyNet2, function(err, reply) {

                            });
                            client.del(cacherootnet2 + 'ts' + cacheKeyNet2, function(err, reply) {

                            });

                            client.del('timeline' + req.body.guid, function(err, reply) {

                            });
                            client.del('timelinets' + req.body.guid, function(err, reply) {

                            });

                            client.del('timeline' + tmpret.CacheKey, function(err, reply) {

                            });
                            client.del('timelinets' + tmpret.CacheKey, function(err, reply) {

                            });

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

exports.getInvoicesToPay = function(req, res) {

    dinvoice.run(function() {

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
            pageFrom: {
                minlength: 0,
                maxlength: 50,
                dataType: 'numeric'
            },
            pageTo: {
                minlength: 0,
                maxlength: 50,
                dataType: 'numeric'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var cacheroot = 'invoice';
                var cacheKey = req.body.guid;
                var lkey = req.body.lkey;
                var lkeyname = "dummy";
                var pageFrom = req.body.pageFrom;
                var pageTo = req.body.pageTo;
                var reqtimestamp = req.body.timestamp;

                cache.getCache(cacheroot, cacheKey, reqtimestamp, lkeyname, lkey, pageFrom, pageTo, function(err, cres) {

                    if (!err) {

                        //load the cache from the database
                        _getInvoicesToPay(req.body.guid, req.body.sharedid, function(err, vResult) {

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

exports.getInvoicesByUser = function(req, res) {

    dinvoice.run(function() {

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
            pageFrom: {
                minlength: 0,
                maxlength: 50,
                dataType: 'numeric'
            },
            pageTo: {
                minlength: 0,
                maxlength: 50,
                dataType: 'numeric'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var cacheroot = 'invoicebu';
                var cacheKey = req.body.guid;
                var lkey = req.body.lkey;
                var lkeyname = "dummy";
                var pageFrom = req.body.pageFrom;
                var pageTo = req.body.pageTo;
                var reqtimestamp = req.body.timestamp;

                cache.getCache(cacheroot, cacheKey, reqtimestamp, lkeyname, lkey, pageFrom, pageTo, function(err, cres) {

                    if (!err) {

                        //load the cache from the database
                        _getInvoicesByUser(req.body.guid, req.body.sharedid, function(err, vResult) {

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

function _getInvoicesToPay(guid, sharedid, callback) {

    var options = {
        'url': config.upstreamServer.baseUrl + route + '/GetInvoicesToPay',
        'proxy': config.proxyServer.url,
        'form': {
            guid: guid,
            sharedid: sharedid
        }
    };

    request.post(options, function(err, results) {
        writeUnitTestData(options, results.body);
        validator.validateResult(results, function(err, vResult) {

            callback(err, vResult);

        });
    });

}

function _getInvoicesToPayNetwork(guid, sharedid, username, callback) {

    var options = {
        'url': config.upstreamServer.baseUrl + route +'/GetInvoicesToPayNetwork',
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

            callback(err, vResult);

        });
    });

}

function _getInvoicesByUser(guid, sharedid, callback) {

    var options = {
        'url': config.upstreamServer.baseUrl + route +'/GetInvoicesByUser',
        'proxy': config.proxyServer.url,
        'form': {
            guid: guid,
            sharedid: sharedid
        }
    };

    request.post(options, function(err, results) {
        writeUnitTestData(options, results.body);
        validator.validateResult(results, function(err, vResult) {

            callback(err, vResult);

        });
    });

}

function _getInvoicesByUserNetwork(guid, sharedid, username, callback) {

    var options = {
        'url': config.upstreamServer.baseUrl + route +'/GetInvoicesByUserNetwork',
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

            callback(err, vResult);

        });
    });

}
