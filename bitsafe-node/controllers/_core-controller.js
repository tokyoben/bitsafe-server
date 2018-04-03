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

var dcore = errhandle.getdomain();

var route = '/core';

exports.amIAlive = function(req, res, next) {

    res.send(200, "yes");

}

exports.getPrice = function(req, res) {

    var expectedParams = {
        guid: {
            minlength: 64,
            maxlength: 64,
            dataType: 'hex'
        },
        ccy: {
            minlength: 3,
            maxlength: 3,
            dataType: 'alpha'
        }
    };

    validator.validateRequest(req, expectedParams, function(pass) {

        //console.log(pass);

        if (pass) {

            var ccy = req.body.ccy;
            client.get('price' + ccy, function(err, price) {

                if (!price) {
                    price = 0;
                }

                res.json(JSON.stringify(price));

            });

        } else {
            res.send(500, "ErrInvalid");
        }

    });

}

exports.getTimeline = function(req, res) {

    dcore.run(function() {

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

                var cacheroot = 'timeline';
                var cacheKey = req.body.guid;
                var lkey = req.body.lkey;
                var lkeyname = "TimelineId";
                var pageFrom = req.body.tranPageFrom;
                var pageTo = req.body.tranPageTo;
                var reqtimestamp = req.body.timestamp;

                cache.getCache(cacheroot, cacheKey, reqtimestamp, lkeyname, lkey, pageFrom, pageTo, function(err, cres) {

                    if (!err) {

                        //load the cache from the database
                        getTimeline(req.body.guid, req.body.sharedid, function(err, vResult) {

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

function getTimeline(guid, sharedid, callback) {

    var options = {
        'url': config.upstreamServer.baseUrl + route + '/GetTimeline',
        'proxy': config.proxyServer.url,
        'form': {
            guid: guid,
            sharedid: sharedid
        }
    };

    request.post(options, function(err, results) {

        //writeUnitTestData(options, results.body);

        validator.validateResult(results, function(err, vResult) {

            return callback(err, vResult);

        });

    });

}

//app.post('/api/1/u/getversion'

exports.getVersion = function(req, res) {

    dcore.run(function() {

        var expectedParams = {};
        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                //console.log(config.upstreamServer.baseUrl)
                var options = {
                    'url': config.upstreamServer.baseUrl + route + '/GetVersion',
                    'proxy': config.proxyServer.url
                };
                //writeUnitTestData(options)
                request.post(options, function(err, results) {
                    writeUnitTestData(options, results.body);
                    //console.log(results)
                    validator.validateResult(results, function(err, vResult) {
                        if (err) {
                            res.send(500, vResult.errorMessage);
                        } else {
                            var tmp = JSON.parse(vResult);
                            tmp.CreateMobOff = false;
                            tmp.CreateOff = false;
                            vResult = JSON.stringify(tmp);
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
