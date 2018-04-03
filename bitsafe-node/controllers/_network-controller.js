const config = require("../config.js");
const domain = require('domain');
const client = require('redis').createClient({"host":config.redisHost});
const validator = require('../helpers/_validation-helper.js')
const request = require('request');
const express = require('express')
const cache = require('../helpers/_cache-helper.js')

const errhandle = require('../error-handler.js');


function writeUnitTestData(){

}

var route = '/network';

var dnetwork = errhandle.getdomain();

exports.getUserNetworkCategory = function(req, res) {

    dnetwork.run(function() {

        var expectedParams = {};

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route +'/GetUserNetworkCategory',
                    'proxy': config.proxyServer.url,
                    'form': {}
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

exports.updateUserNetworkCategory = function(req, res) {

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
            username: {
                minlength: 3,
                maxlength: 50,
                dataType: 'ascii'
            },
            category: {
                minlength: 3,
                maxlength: 20,
                dataType: 'alpha'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route +'/UpdateUserNetworkCategory',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid,
                        username: req.body.username,
                        category: req.body.category
                    }
                };

                request.post(options, function(err, result) {

                    writeUnitTestData(options, result.body);

                    validator.validateResult(result, function(err, vResult) {

                        if (err) {
                            res.send(500, vResult.errorMessage);
                        } else {


                            var cacheKey = 'usernetwork';
                            client.del(cacheKey + req.body.guid, function(err, reply) {

                            });


                            client.del(cacheKey + 'ts' + req.body.guid, function(err, reply) {

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

exports.createFriend = function(req, res) {

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
            username: {
                minlength: 3,
                maxlength: 50,
                dataType: 'ascii'
            },
            node: {
                minlength: 0,
                maxlength: 50,
                dataType: 'ascii'
            },
            packetForFriend: {
                minlength: 0,
                maxlength: 1000000,
                dataType: 'ascii'
            },
            validationHash: {
                minlength: 0,
                maxlength: 256,
                dataType: 'hex'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route +'/CreateFriend',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid,
                        username: req.body.username,
                        node: req.body.node,
                        packetForFriend: req.body.packetForFriend,
                        validationHash: req.body.validationHash
                    }
                };

                request.post(options, function(err, results) {
                    writeUnitTestData(options, results.body);
                    validator.validateResult(results, function(err, vResult) {
                        if (err) {
                            res.send(500, vResult.errorMessage);
                        } else {

                            //del timeline cache
                            var tmpret = JSON.parse(vResult);

                            client.del('timeline' + req.body.guid, function(err, reply) {

                            });

                            client.del('timeline' + 'ts' + req.body.guid, function(err, reply) {

                            });

                            client.del('timeline' + tmpret.CacheKey, function(err, reply) {

                            });
                            client.del('timeline' + 'ts' + tmpret.CacheKey, function(err, reply) {

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

exports.getFriendRequestPacket = function(req, res) {

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
            username: {
                minlength: 3,
                maxlength: 50,
                dataType: 'ascii'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route +'/GetFriendRequestPacket',
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

exports.getFriendPacket = function(req, res) {

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
            username: {
                minlength: 3,
                maxlength: 50,
                dataType: 'ascii'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {
                var options = {
                    'url': config.upstreamServer.baseUrl + route +'/GetFriendPacket',
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

exports.updateFriend = function(req, res) {

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
            username: {
                minlength: 3,
                maxlength: 50,
                dataType: 'ascii'
            },
            packet: {
                minlength: 0,
                maxlength: 10000000,
                dataType: 'ascii'
            },
            validationHash: {
                minlength: 0,
                maxlength: 256,
                dataType: 'hex'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route +'/UpdateFriend',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid,
                        username: req.body.username,
                        packet: req.body.packet,
                        validationHash: req.body.validationHash
                    }
                };


                request.post(options, function(err, results) {
                    writeUnitTestData(options, results.body);
                    validator.validateResult(results, function(err, vResult) {
                        if (err) {
                            res.send(500, vResult.errorMessage);
                        } else {

                            var cacheKey = 'usernetwork';

                            var tmpret = JSON.parse(vResult);

                            client.del(cacheKey + req.body.guid, function(err, reply) {

                            });
                            client.del(cacheKey + 'ts' + req.body.guid, function(err, reply) {

                            });

                            client.del(cacheKey + tmpret.message, function(err, reply) {

                            });
                            client.del(cacheKey + 'ts' + tmpret.message, function(err, reply) {

                            });

                            client.del('timeline' + req.body.guid, function(err, reply) {

                            });
                            client.del('timeline' + 'ts' + req.body.guid, function(err, reply) {

                            });

                            client.del('timeline' + tmpret.message, function(err, reply) {

                            });
                            client.del('timeline' + 'ts' + tmpret.message, function(err, reply) {

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

exports.rejectFriend = function(req, res) {

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
            username: {
                minlength: 3,
                maxlength: 50,
                dataType: 'ascii'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {
                var options = {
                    'url': config.upstreamServer.baseUrl + route +'/RejectFriend',
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



exports.getPendingUserRequests = function(req, res) {

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
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route +'/GetPendingUserRequests',
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

exports.doesNetworkExist = function(req, res) {

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
            username: {
                minlength: 3,
                maxlength: 50,
                dataType: 'ascii'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route +'/DoesNetworkExist',
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

exports.getFriendRequests = function(req, res) {

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
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {
                var options = {
                    'url': config.upstreamServer.baseUrl + route +'/GetFriendRequests',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid
                    }
                };

                //console.log("GetFriendRequests")

                request.post(options, function(err, results) {
                    //console.log("GetFriendRequests result")
                    //console.log(results)
                    //writeUnitTestData(options, results.body);
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

exports.getRSAKey = function(req, res) {

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
            username: {
                minlength: 3,
                maxlength: 50,
                dataType: 'ascii'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route +'/GetRSAKey',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid,
                        username: req.body.username
                    }
                };

                request.post(options, function(err, results) {
                    writeUnitTestData(options, results.body);

                    //console.log(results);
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

exports.getUserNetwork = function(req, res) {

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

                var cacheroot = 'usernetwork';


                var cacheKey = req.body.guid;

                var lkey = req.body.lkey;
                var lkeyname = "dummy";
                var pageFrom = req.body.pageFrom;
                var pageTo = req.body.pageTo;
                var reqtimestamp = req.body.timestamp;

                cache.getCache(cacheroot, cacheKey, reqtimestamp, lkeyname, lkey, pageFrom, pageTo, function(err, cres) {

                    if (!err) {

                        //load the cache from the database
                        _getUserNetwork(req.body.guid, req.body.sharedid, function(err, vResult) {

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

exports.getFriend = function(req, res) {

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
            username: {
                minlength: 3,
                maxlength: 50,
                dataType: 'ascii'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route +'/GetFriend',
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




function _getUserNetwork(guid, sharedid, callback) {

    var options = {
        'url': config.upstreamServer.baseUrl + route +'/GetUserNetwork',
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
