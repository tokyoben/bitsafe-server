config = {
    upstreamServer: {
        protocol: process.env.BITSAFE_UPSTREAM_PROTOCOL, //"http"
        hostname: process.env.BITSAFE_UPSTREAM_SERVER, //"netcore"
        port: process.env.BITSAFE_UPSTREAM_PORT, //"5000"
        basePath: process.env.BITSAFE_UPSTREAM_PATH //"/api"

    },
    proxyServer: {
        url: ''
    },
    redisHost: process.env.BITSAFE_REDIS_HOST,
    mailTransport: process.env.BITSAFE_MAIL_TRANSPORT,
    mailKeyID: process.env.BITSAFE_MAIL_KEY_ID,
    mailSecret: process.env.BITSAFE_MAIL_SECRET,
    mailServiceURL: process.env.BITSAFE_MAIL_SERVICE,
    nodeServicePort: process.env.BITSAFE_NODE_SERVICE_PORT,
    nodeServiceSSLKey: process.env.BITSAFE_NODE_SERVICE_SSL_KEY,
    nodeServiceSSLCert: process.env.BITSAFE_NODE_SERVICE_SSL_CERT,

}

config.upstreamServer.baseUrl = config.upstreamServer.protocol + "://" + config.upstreamServer.hostname + ":" + config.upstreamServer.port + "/" + config.upstreamServer.basePath

module.exports = config;
