The internet facing application server for Ninki Wallet. Depends on a default installation of redis.

The api-token node module needs to be overwritten with the customized version to support redis.

https://gitlab.com/ninkimig/api-token

Yes! The app.js really is a single 12,000 line file :0
Can be split out into a router.js / controller model as part of migration...
