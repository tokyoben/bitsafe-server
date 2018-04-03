const config = require("../config.js");
const client = require('redis').createClient({"host":config.redisHost});

const dataCacheExpiry = 3600;

exports.getCache = function(cacheroot, cacheKey, reqtimestamp, lkeyname, lkey, pageFrom, pageTo, fload, fget) {

    // uncomment to prevent cache use
    //client.del(cacheroot + cacheKey);
    //client.del(cacheroot + 'ts' + cacheKey);

    //console.log('getting cache...');
    //console.log(cacheroot + cacheKey);

    client.lrange(cacheroot + cacheKey, 0, -1, function(err, messcache) {

        if (!err) {

            client.get(cacheroot + 'ts' + cacheKey, function(err, timestamp) {

                if (timestamp) {

                    //console.log("Cache ts = " + timestamp);
                    //console.log("Client ts = " + reqtimestamp);

                    var cacheDate = Date.parse(timestamp);
                    var reqDate = Date.parse(reqtimestamp);

                    //only return the cache if the client doesn't have the latest version

                    if (cacheDate > reqDate) {

                        //console.log('using ' + cacheroot +' cache:' + cacheKey);

                        //roll over cache expiry
                        client.expire(cacheroot + cacheKey, dataCacheExpiry, function(err, reply) {

                        });

                        var retcache = [];

                        var total = messcache.length;

                        var tfrom = pageFrom;
                        var tto = pageTo;

                        if (tto > total) {
                            tto = total;
                        }

                        for (var i = tfrom; i < tto; i++) {

                            messcache[i] = JSON.parse(messcache[i]);

                            if (messcache[i][lkeyname]) {

                                //console.log("checking..." + messcache[i][lkeyname]);
                                //console.log("checking..." + lkey);

                                if (messcache[i][lkeyname] == lkey) {
                                    //console.log("breaking...");
                                    break;
                                }
                            }

                            retcache.push(messcache[i]);
                        }

                        var cacheObject = {};
                        cacheObject.data = retcache;
                        cacheObject.timestamp = timestamp;
                        cacheObject.total = total;

                        return fget(false, JSON.stringify(cacheObject));

                    } else {

                        //console.log("client up to date...");

                        var ret = {};
                        ret.message = -1;
                        ret.error = false;
                        return fget(false, JSON.stringify(ret));

                    }


                } else {

                    fload();

                }

            });

        }

    });

}


exports.loadCache = function(cacheroot, cacheKey, pageFrom, pageTo, vResult, callback) {

    var data = JSON.parse(vResult);
    var timestamp = new Date().toUTCString();
    var total = data.length;


    client.del(cacheroot + cacheKey, function(err, reply) {

    });

    var multi = client.multi();
    for (var i = 0; i < data.length; i++) {

        if (data[i].CreateDate) {

            data[i].CreateDate = new Date(data[i].CreateDate.match(/\d+/)[0] * 1)
        }

        multi.rpush(cacheroot + cacheKey, JSON.stringify(data[i]));

        //console.log("pushed...");
    }

    multi.rpush(cacheroot + 'set', cacheKey);

    multi.exec(function(errors, results) {

        //console.log("create ts = " + timestamp);

        client.set(cacheroot + 'ts' + cacheKey, timestamp, function(e) {

            client.expire(cacheroot + cacheKey, dataCacheExpiry, function(err, reply) {

            });
            client.expire(cacheroot + 'ts' + cacheKey, dataCacheExpiry, function(err, reply) {

            });

            //console.log("get range...");
            //console.log(pageFrom);
            //console.log(pageTo);

            client.lrange(cacheroot + cacheKey, pageFrom, pageTo - 1, function(err, messcache) {

                for (var i = 0; i < messcache.length; i++) {
                    messcache[i] = JSON.parse(messcache[i]);
                }

                var cacheObject = {};
                cacheObject.data = messcache;
                cacheObject.timestamp = timestamp;
                cacheObject.total = total;
                callback(false, JSON.stringify(cacheObject));

            });

        });

    });

}
