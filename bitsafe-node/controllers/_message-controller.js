const config = require("../config.js");
const domain = require('domain');
const client = require('redis').createClient({"host":config.redisHost});
const validator = require('../helpers/_validation-helper.js')
const request = require('request');
const express = require('express')
const cache = require('../helpers/_cache-helper.js')

const errhandle = require('../error-handler.js');

const crypto = require("crypto");

const dataCacheExpiry = 3600;

var route = '/message';


function writeUnitTestData(){

}

var dmess = errhandle.getdomain();

exports.createMessage = function(req, res) {

    dmess.run(function() {
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
            },
            transactionId: {
                minlength: 0,
                maxlength: 64,
                dataType: 'hex'
            },
            messageId: {
                minlength: 64,
                maxlength: 64,
                dataType: 'hex'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {
            //console.log(pass);
            if (pass) {
                var options = {
                    'url': config.upstreamServer.baseUrl + route +  '/CreateMessage',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid,
                        userName: req.body.userName,
                        packetForMe: req.body.packetForMe,
                        packetForThem: req.body.packetForThem,
                        transactionId: req.body.transactionId
                    }
                };

                request.post(options, function(err, results) {
                    writeUnitTestData(options, results.body);

                    validator.validateResult(results, function(err, vResult) {

                        if (err) {

                            //return cache keys
                            //guid1 || username2
                            //guid2 || username1
                            //update cache
                            //switch around

                            res.send(500, vResult.errorMessage);

                        } else {

                            var sha256 = crypto.createHash("sha256");
                            sha256.update(req.body.guid + req.body.userName, "utf8"); //utf8 here
                            var cacheKey = sha256.digest("hex");

                            var jres = JSON.parse(vResult);

                            //instead of invalidating the cache key
                            //we can add the new item into the cache

                            //will this cause concurrency issues ?

                            //console.log("invalidate:" + cacheKey);
                            //console.log("invalidate:" + jres.message);

                            var date = new Date();

                            var popItem1 = {};

                            popItem1.MessageId = req.body.messageId;
                            popItem1.UserName = '';
                            popItem1.PacketForMe = req.body.packetForMe;
                            popItem1.PacketForThem = req.body.packetForThem;
                            popItem1.CreateDate = date;
                            popItem1.TransactionId = '';

                            var popItem2 = {};

                            popItem2.MessageId = 0;
                            popItem2.UserName = req.body.userName;
                            popItem2.PacketForMe = req.body.packetForMe;
                            popItem2.PacketForThem = req.body.packetForThem;
                            popItem2.CreateDate = date;
                            popItem2.TransactionId = '';

                            //console.log("setting cache...");

                            var multi = client.multi();
                            multi.lpush('message' + cacheKey, JSON.stringify(popItem1));
                            multi.lpush('message' + jres.MessageCacheKey, JSON.stringify(popItem2));

                            multi.exec(function(errors, results) {

                                //console.log("cache is set...");

                                var timestamp = new Date().toUTCString();

                                //console.log("timestamp is " + timestamp + "...");

                                client.set('messagets' + cacheKey, timestamp, function(e) {

                                    //console.log("set 1 " + timestamp + "...");

                                    client.set('messagets' + jres.MessageCacheKey, timestamp, function(e) {

                                        //console.log("set 2 ret " + timestamp + "...");

                                        client.expire('message' + cacheKey, dataCacheExpiry, function(err, reply) {

                                        });
                                        client.expire('messagets' + cacheKey, dataCacheExpiry, function(err, reply) {

                                        });

                                        client.expire('message' + jres.MessageCacheKey, dataCacheExpiry, function(err, reply) {

                                        });
                                        client.expire('messagets' + jres.MessageCacheKey, dataCacheExpiry, function(err, reply) {

                                        });


                                        //console.log(jres.TimelineCacheKey);
                                        //console.log(jres.MessageCacheKey);
                                        //too frequent for rapid chat ---
                                        //if rapid chat is implemented then need to throttle
                                        client.del('timeline' + jres.TimelineCacheKey, function(err, reply) {

                                        });
                                        client.del('timelinets' + jres.TimelineCacheKey, function(err, reply) {

                                        });

                                        res.json(vResult);

                                    });

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

exports.getMessagesByUserNetwork = function(req, res) {

    dmess.run(function() {

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
        //, reqttl: {dataType: 'ascii'}
        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var sha256 = crypto.createHash("sha256");
                sha256.update(req.body.guid + req.body.userName, "utf8"); //utf8 here

                var cacheKey = sha256.digest("hex");

                var cacheroot = 'message';
                var lkey = req.body.lkey;
                var lkeyname = 'CreateDate';
                var pageFrom = req.body.pageFrom;
                var pageTo = req.body.pageTo;
                var reqtimestamp = req.body.timestamp;



                cache.getCache(cacheroot, cacheKey, reqtimestamp, lkeyname, lkey, pageFrom, pageTo, function(err, cres) {

                    if (!err) {

                        //load the cache from the database
                        getMessages(req.body.guid, req.body.sharedid, req.body.userName, function(err, vResult) {

                            if (!err) {

                                //console.log(vResult);

                                cache.loadCache(cacheroot, cacheKey, pageFrom, pageTo, vResult, function(err, result) {

                                    //console.log(result);

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

function getMessages(guid, sharedid, username, callback) {
    var options = {
        'url': config.upstreamServer.baseUrl + route + '/GetMessagesByUserNetwork',
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
