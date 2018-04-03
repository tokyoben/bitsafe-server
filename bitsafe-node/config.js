"use strict";
var ISNODEENV = (typeof module !== 'undefined' && module.exports);

var config = {
    walletSecurity: {
        minimumPasswordLength: 5, //Bi-directional encryption
        minimumPassphraseLength: 10, //Public key encryption
        rsaKeyBitLength: 512
    },
    thisServer: {
        protocol: "https",
        hostname: "localhost",
        port: "1111",
        basePath: ""
    },
    thisWebServer: {
        protocol: "https",
        hostname: "netcore",
        port: "1112",
        basePath: ""
    },
    redisHost: "redis"
}

config.thisServer.baseUrl = config.thisServer.protocol + '://' +
    config.thisServer.hostname + ':' + config.thisServer.port +
    config.thisServer.basePath;

config.thisWebServer.baseUrl = config.thisWebServer.protocol + '://' +
    config.thisWebServer.hostname + ':' + config.thisWebServer.port +
    config.thisWebServer.basePath;

if (ISNODEENV) {
    config.upstreamServer = require("./config/").upstreamServer;
    config.proxyServer = require("./config/").proxyServer;
    module.exports = config;
}
