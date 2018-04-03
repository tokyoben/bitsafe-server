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

var route = '/address';

function writeUnitTestData(){

}

var daddress = errhandle.getdomain();

daddress.on('error', function(er) {

    //unexpected error so log and alter
    console.log(er.stack);
    afterErrorHook(er);
});

exports.getNextNodeForFriend = function(req, res) {

    daddress.run(function() {

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
                    'url': config.upstreamServer.baseUrl + route + '/GetNextNodeForFriend',
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

exports.getNextLeafForFriend = function(req, res) {

    daddress.run(function() {

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
                    'url': config.upstreamServer.baseUrl + route +'/GetNextLeafForFriend',
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

exports.createAddressForFriend = function(req, res) {

    daddress.run(function() {

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
            address: {
                minlength: 0,
                maxlength: 255,
                dataType: 'ascii'
            },
            leaf: {
                minlength: 0,
                maxlength: 32,
                dataType: 'int'
            },
            pk1: {
                minlength: 0,
                maxlength: 300,
                dataType: 'hex'
            },
            pk2: {
                minlength: 0,
                maxlength: 300,
                dataType: 'hex'
            },
            pk3: {
                minlength: 0,
                maxlength: 300,
                dataType: 'hex'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route +'/CreateAddressForFriend',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid,
                        username: req.body.username,
                        address: req.body.address,
                        leaf: req.body.leaf,
                        pk1: req.body.pk1,
                        pk2: req.body.pk2,
                        pk3: req.body.pk3
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

exports.getNextLeaf = function(req, res) {

    daddress.run(function() {

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
            pathToUse: {
                minlength: 0,
                maxlength: 50,
                dataType: 'ascii'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                var options = {
                    'url': config.upstreamServer.baseUrl + route +'/GetNextLeaf',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid,
                        pathToUse: req.body.pathToUse
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

            }

        });

    });
}

exports.createAddress = function(req, res) {

    daddress.run(function() {

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
            path: {
                minlength: 0,
                maxlength: 50,
                dataType: 'ascii'
            },
            address: {
                minlength: 0,
                maxlength: 255,
                dataType: 'ascii'
            },
            pk1: {
                minlength: 0,
                maxlength: 300,
                dataType: 'hex'
            },
            pk2: {
                minlength: 0,
                maxlength: 300,
                dataType: 'hex'
            },
            pk3: {
                minlength: 0,
                maxlength: 300,
                dataType: 'hex'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {
                var options = {
                    'url': config.upstreamServer.baseUrl + route +'/CreateAddress',
                    'proxy': config.proxyServer.url,
                    'form': {
                        guid: req.body.guid,
                        sharedid: req.body.sharedid,
                        path: req.body.path,
                        address: req.body.address,
                        pk1: req.body.pk1,
                        pk2: req.body.pk2,
                        pk3: req.body.pk3
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
