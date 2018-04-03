"use strict";

var config = {
	upstreamServer:{
		protocol:"http",
		hostname:"netcore",
		port:"5000",
		basePath:"/api"
		/*
		 Routes:
		 CreateAccount
		 CreateAccount2
		 CreateAddress
		 GetAccountDetails
		 GetVersion
		hostname:"54.72.54.193",
		port:"81",
		 */
		},
	proxyServer: {
		url: ''
	}
}

config.upstreamServer.baseUrl=config.upstreamServer.protocol+'://'+
	config.upstreamServer.hostname+':'+config.upstreamServer.port+
	config.upstreamServer.basePath;

module.exports = config;
