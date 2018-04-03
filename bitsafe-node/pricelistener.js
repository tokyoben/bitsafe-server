var request = require('request');
var config = require("./config.js");
var client = require('redis').createClient({"host":config.redisHost});
var multi = client.multi();

//this module loads an initial price history
//then listens and updates the price every 5 minutes


var ccys = ["USD", "EUR", "JPY", "CNY", "GBP", "AUD", "NZD"];

loadPrices();

setInterval(function () {

    loadPrices();

}, 30000);

function loadPrices() {

    for (var i = 0; i < ccys.length; i++) {

        !function outer(ccy) {
            getPrice(ccy, function (err, price) {

                if (!err) {

                    client.set("price" + ccy, price);


                    logger.log('info', 'Updated %s with %s', ccy, price);

                    //push the new price into the history cache

                    //var now = moment();

                    //console.log("added price " + price);
                    //console.log(now.toDate().getTime());

                    //client.rpush("pricesUSD", JSON.stringify([now.toDate().getTime(), price]));

                } else {

                    logger.log('error', err);

                }

            });
        } (ccys[i])
    }

}


function getPrice(ccy, callback) {

    var options = {
        'url': 'https://api.bitcoinaverage.com/ticker/global/' + ccy + '/last'
    };

    request.get(options, function (err, result) {

        if (!err) {
            callback(err, result.body);
        } else {
            callback(err, 0);
        }

    });

}


//loadPriceHistory("USD", function (prices) {

//    client.del("prices" + "USD");

//    for (var i = 0; i < prices.length; i++) {

//        multi.rpush("prices" + "USD", JSON.stringify(prices[i]));

//    }

//    multi.exec(function (errors, results) {

//        console.log("loaded " + prices.length + " for " + "USD");

//        loadPrices();

//        setInterval(function () {

//            loadPrices();

//        }, 30000);

//    });

//});


function loadPriceHistory(ccy, callback) {

    request.get('https://api.bitcoinaverage.com/history/' + ccy + '/per_minute_24h_sliding_window.csv', function (error, response, body) {
        if (!error && response.statusCode == 200) {

            csv.parse(body, function (err, data) {

                var pricehistory = [];
                var k = 0;
                for (var i = 0; i < data.length; i++) {

                    if (k == 5 || i == data.length) {

                        //parse date to UTC format
                        var date = moment(data[i][0].replace(" ", "T") + "+0000")
                        data[i][0] = date.toDate().getTime();
                        pricehistory.push(data[i]);
                        k = 0;
                    }

                    k++;
                }


                callback(pricehistory)

            });

            // Continue with your processing here.
        }
    });
}
