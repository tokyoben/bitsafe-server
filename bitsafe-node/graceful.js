
module.exports = function(server) {

  var sockets = [];
  server.on('connection', function (socket) {
      console.log(socket.remoteAddress + ": Open");
      socket.setTimeout(2 * 1000);
      sockets.push(socket);
      socket.on('close', function () {
          console.log('Socket closed.');
      });

      // 30 second timeout. Change this as you see fit.
  });

  var pid = process.pid + '';

  var numofmins  = pid.substr(pid.length - 1)

  var custommins  = (((numofmins*1.0) + 1)*60*1000);
  var onehour = 1000 * 60 * 60;
  var recyclehours = onehour * 0;
  var totrecycle = recyclehours + custommins;

  setTimeout(function() {

  //  console.log(server._handle);
  //  console.log(server._connections);
  //  console.log('closing server');

    server.close(function() {
   //   console.log('closed');
      process.exit();
    });

    setTimeout(function() {
      sockets.forEach(function(socket) {
        socket.destroy();
      });
    },5000);

  },totrecycle);

}
