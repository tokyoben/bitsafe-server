const express = require('express'),
      app = express();
const http = require("http");
const server = http.createServer(app);
const domain = require("domain");


//functions to allow graceful exit
var afterErrorHook = function(err) {
  //app.set("isShuttingDown", true);

  // server.close(function() {
  //   console.log("afterErrorHook: shutdown");
  //   process.exit(1);
  // });
  console.log("error from domain")
  console.log(err)
}

var shutdownMiddle = function(req, res, next) {
  if(app.get("isShuttingDown")) {
    console.log("isShuttingDown: setTimeout");
    req.connection.setTimeout(1);
  }
  next();
}

exports.getdomain = function() {
  var domapp = domain.create();
  domapp.on('error', function (er) {
      console.log(er);
      //unexpected error so log and alter
      setTimeout(function() {
          afterErrorHook('');
      },1000);
  });
  return domapp;
}
