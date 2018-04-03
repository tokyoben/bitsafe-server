var domain = require('domain');
var config = require("./config.js");
var request = require("request");
var client = require('redis').createClient({"host":config.redisHost});
var winston = require('winston');
var expressWinston = require('express-winston');


var logger = new (winston.Logger)({
    transports: [
    new (winston.transports.DailyRotateFile)({
        name: 'info-file',
        filename: 'logs/block-info.log',
        level: 'info',
        datePattern: '.HH'
    }),
    new (winston.transports.DailyRotateFile)({
        name: 'error-file',
        filename: 'logs/block-error.log',
        level: 'error',
        datePattern: '.HH'
    })
  ]
});

logger.log('info', 'Block listener started...');

var dgetversion = domain.create();
dgetversion.on('error', function (er) {

    //unexpected error so log and alter
    logger.log('error', er.stack);
});

setInterval(function () {

    dgetversion.run(function () {

        checkForNewBlock();
    });

}, 5000);



function checkForNewBlock() {

    var options = {
        'url': config.upstreamServer.baseUrl + '/GetVersion',
        'proxy': config.proxyServer.url
    };

    request.post(options, function (err, results) {

        validateResult(results, function (err, vResult) {

            if (err) {

                console.log(vResult.errorMessage);

            } else {

                //compare with last block
                //if new block
                //del all transaction caches

                var info = JSON.parse(results.body);

                client.get('blockheight', function (err, blockheight) {

                    if (err) {

                        console.log("error getting block height from redis");
                    }

                    if (!err) {

                        //latest block height cache in redis

                        if (info.BlockNumber != blockheight) {

                            logger.log('info', 'new block %s', info.BlockNumber);

                            client.set('blockheight', info.BlockNumber, function (err, reply) {

                            });

                            client.lrange('transactionset', 0, 10000000, function (err, trankeys) {

                                //check to see if caches exist
                                //if not remove the key from transaction set

                                trankeys.forEach(function (t) {

                                    //console.log(t);

                                    var key = t;

                                    client.del('bal' + key, function (err, reply) {

                                    });

                                    client.get('transactionts' + key, function (err, timestamp) {

                                        if (timestamp) {

                                            client.del('transaction' + key, function (err, reply) {

                                            });
                                            client.del('transactionts' + key, function (err, reply) {

                                            });

                                            client.del('timeline' + key, function (err, reply) {

                                            });
                                            client.del('timelinets' + key, function (err, reply) {

                                            });

                                        } else {

                                            client.lrem('transactionset', key, 0, function (err, reply) {

                                            });
                                        }

                                    });

                                });

                            });

                        }
                    }

                });

            }

        });

    });

}



function validateResult(result, callback) {

    var errorResult = {};
    var err = false;
    if (result) {

        if (result.body) {

            //console.log(result.body);
            var IsErrInvalidOp = result.body.substring(0, "System.InvalidOperationException".length);
            if (IsErrInvalidOp == "System.InvalidOperationException") {
                err = true;
                errorResult.errorMessage = 'ErrInvalidOperation';
            }

            if (result.body == "ErrService") {
                err = true;
                errorResult.errorMessage = 'ErrService';
            }

            try {
                var test = JSON.parse(result.body);
                if (test.error == true) {
                    err = true;
                    errorResult.errorMessage = test.message;
                } else {

                }
            } catch (error) {
                err = true;
                errorResult.errorMessage = 'ErrParse';
            }

        } else {
            err = true;
            errorResult.errorMessage = 'ErrResult';
        }

    } else {
        err = true;
        errorResult.errorMessage = 'ErrResult';
    }

    if (err) {

        ////console.log(result);
        callback(true, errorResult);

    } else {

        //this is json and guarnateed to be one property deep
        //by the api
        //so sanitise everything that will be returned

        var sanres = '';

        callback(err, sanres);

    }



}
