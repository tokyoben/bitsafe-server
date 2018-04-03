var nodemailer = require("nodemailer");

var transport = nodemailer.createTransport("SES", {
    AWSAccessKeyID: "AKIAJBWCQF362ZERJYDQ",
    AWSSecretKey: "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",
    ServiceUrl: "email-smtp.us-east-1.amazonaws.com"
});


var mailOptions = {
    from: "shibuyashadows@gmail.com",
    to: "shibuyashadows@gmail.com",
    subject: "Welcome to Ninki - Validate your Email",
    text: "textmail",
    html: "htmlmail"
}

transport.sendMail(mailOptions, function(error, response) {

  console.log(error)

});

