var validator = require('validator');
var sanitizer = require('sanitizer');


exports.validateResult = function(result, callback) {

    //console.log(result);
    var errorResult = {};
    var err = false;
    if (result) {

        if (result.body) {

            //console.log(result);
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
                //console.log(result.body);
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

        //console.log(result);
        callback(true, errorResult);

    } else {

        //this is json and guarnateed to be one property deep
        //by the api
        //so sanitise everything that will be returned

        var sanres = '';



        sanres = sanitizer.sanitize(result.body);


        callback(err, sanres);

    }


}


exports.validateRequest = function(req, expectedParams, callback) {
    //console.log("running validate");
    //request should have body
    if (req.body) {
        //console.log("entered validate");
        var pass = true;

        //inspect the type, length etc. and validate

        if (Object.keys(req.body).length >= Object.keys(expectedParams).length) {
            for (var propt in expectedParams) {
                  //console.log(propt);
                if (typeof req.body[propt] == 'undefined') {

                    pass = false;
                } else {


                    var spec = expectedParams[propt];
                    if (spec['dataType']) {

                        var pval = req.body[propt];

                        var pminlength = 0;

                        var pmaxlength = false;

                        if (spec['minlength']) {
                            pminlength = spec['minlength'];
                        }

                        if (spec['maxlength']) {
                            pmaxlength = spec['maxlength'];
                        }


                        var dataType = spec['dataType'];

                        var perror = false;
                        //check max length

                        if (pminlength == 0 && pval == '') {

                            perror = false;

                        } else {

                            perror = !validator.isLength(pval.toString(), pminlength, pmaxlength);

                            if (dataType == 'boolean') {

                                if (pval.toString() == 'true' || pval.toString() == 'false') {

                                    perror = false;

                                } else {

                                    perror = true;
                                }
                            }

                            if (!perror) {
                                if (dataType == 'alpha') {
                                    perror = !validator.isAlpha(pval.toString());
                                    //console.log("isAlpha");
                                }
                                if (dataType == 'numeric') {
                                    perror = !validator.isNumeric(pval.toString());
                                }
                                if (dataType == 'ascii') {
                                    perror = !validator.isAscii(pval.toString());
                                    //console.log("isAscii");
                                    //console.log(perror)
                                }
                                if (dataType == 'base64') {
                                    perror = !validator.isBase64(pval.toString());
                                }
                                if (dataType == 'hex') {
                                    perror = !validator.isHexadecimal(pval.toString());
                                    //console.log("isHex");
                                    //console.log(perror)
                                }
                                if (dataType == 'guid') {
                                    perror = !validator.isUUID(pval.toString());
                                    //console.log("isUUID");
                                    //console.log(perror)
                                }
                                if (dataType == 'ip') {
                                    perror = !validator.isIP(pval.toString());
                                }
                                if (dataType == 'date') {
                                    perror = !validator.isDate(pval.toString());
                                }
                                if (dataType == 'email') {
                                    perror = !validator.isEmail(pval.toString());
                                }
                                if (dataType == 'int') {
                                    perror = !validator.isInt(pval.toString());
                                }
                            }
                            //console.log(propt);
                            //console.log(pval);
                            //console.log(perror);
                        }

                        pass = !perror;
                        if (!pass) {
                            return callback(pass);
                        }
                    }

                }
            }
        } else {
            //console.log("length not equal");
            pass = false;
        }
    } else {
        //console.log("here!")
        pass = false;
    }

    if(pass==false){
      //console.log(req.body);
      //console.log(expectedParams);
    }


    callback(pass);
}
