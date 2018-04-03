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

var route = '/settings';

function writeUnitTestData() {

}

var dsettings = errhandle.getdomain();


dsettings.on('error', function(er) {

    //unexpected error so log and alter
    //console.log(er.stack);
    afterErrorHook(er);
});

//string guid, string sharedid
exports.getAccountSettings = function(req, res) {

    dsettings.run(function() {

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

exports.updateAccountSettings = function(req, res) {

    dsettings.run(function() {

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
            jsonPacket: {
                minlength: 6,
                maxlength: 1000000,
                dataType: 'ascii'
            },
            twoFactorSend: {
                minlength: 0,
                maxlength: 5,
                dataType: 'boolean'
            }
        };

        validator.validateRequest(req, expectedParams, function(pass) {

            if (pass) {

                //check if 2fa code is provided
                //if there is one, authenticate
                //then set the isAuth property

                var guid = req.body.guid;
                var sharedid = req.body.sharedid;
                var twoFactorCode = req.body.twoFactorCode;

                getTwoFactorSecret(guid, function(err, result) {

                    //console.log(result);

                    validator.validateResult(result, function(err, vResult) {

                        //console.log(vResult);
                        //hacks until 2fa is written properley

                        if (!err) {
                            var parsedBody = JSON.parse(vResult);

                            if (parsedBody.TwoFactorOnLogin) {

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
                                        'url': config.upstreamServer.baseUrl + route + '/UpdateAccountSettings',
                                        'proxy': config.proxyServer.url,
                                        'form': {
                                            guid: req.body.guid,
                                            sharedid: req.body.sharedid,
                                            jsonPacket: req.body.jsonPacket,
                                            isAuth: true
                                        }
                                    };

                                    request.post(options, function(err, results) {
                                        writeUnitTestData(options, results.body);

                                        validator.validateResult(results, function(err, vResult) {

                                            if (err) {
                                                res.send(500, vResult.errorMessage);
                                            } else {
                                                //console.log("req.body.twoFactorSend");
                                                //console.log(req.body.twoFactorSend);

                                                if (req.body.twoFactorSend) {
                                                    //create a token
                                                    //write the token to a cookie
                                                    //console.log("setting 2 fa cookie...");

                                                    //GetTwoFactorToken
                                                    var options2 = {
                                                        'url': config.upstreamServer.baseUrl + route + '/GetTwoFactorSendToken',
                                                        'proxy': config.proxyServer.url,
                                                        'form': {
                                                            guid: req.body.guid,
                                                            sharedid: req.body.sharedid
                                                        }
                                                    };

                                                    request.post(options2, function(err, results2) {


                                                        validator.validateResult(results2, function(err, vResult2) {

                                                            var pres = JSON.parse(vResult2);

                                                            //console.log(vResult2);
                                                            //console.log(vResult);


                                                            vResult.Token = pres;



                                                            res.json(vResult2);

                                                        });

                                                    });
                                                } else {
                                                    res.json(vResult);
                                                }

                                            }

                                        });

                                    });


                                }
                            } else {

                                req.body.isAuth = false;

                                var options = {
                                    'url': config.upstreamServer.baseUrl + route + '/UpdateAccountSettings',
                                    'proxy': config.proxyServer.url,
                                    'form': {
                                        guid: req.body.guid,
                                        sharedid: req.body.sharedid,
                                        jsonPacket: req.body.jsonPacket,
                                        isAuth: req.body.isAuth
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
                    });

                });

            } else {
                res.send(500, "ErrInvalid");
            }


        });

    });

}

function getTwoFactorSecret(guid, callback) {

    var options = {
        'url': config.upstreamServer.baseUrl + "/account" + '/GetTwoFactorSecret',
        'proxy': config.proxyServer.url,
        'form': {
            guid: guid
        }
    };

    request.post(options, callback);

}
