const express = require('express'),
      bodyParser = require('body-parser'),
//      cors = require('cors'),
      app = express();

const fs = require('fs');
const http = require("http");
const https = require("https");
const router = require('./router');
const graceful = require('./graceful');
const config = require("./config.js");

process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";

var options = {
    key: fs.readFileSync(config.nodeServiceSSLKey),
    cert: fs.readFileSync(config.nodeServiceSSLCert),
    agent: false
};

const server = https.createServer(options,app);

var port = config.nodeServicePort;

app.use(function (req, res, next) {
    res.set("Access-Control-Allow-Origin", "*");
    res.set("Access-Control-Allow-Headers", "X-Requested-With, Content-Type, Accept, API-Token, Authorization");
    next();
});


app.use('/api', function(req,res,next){
    console.log(req.url);
    next();
});


app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
//app.use(cors());


router(app,server);

server.listen(port);

//graceful(server);

console.log('Your server is running on port ' + port + '.');
