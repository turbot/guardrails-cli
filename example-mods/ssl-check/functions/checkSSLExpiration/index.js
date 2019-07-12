const { fnAsync } = require("@turbot/fn");
const https = require("https");
const moment = require("moment");

exports.control = fnAsync(async (turbot, $) => {
  var options = {
    host: $.inputSite,
    method: "get",
    path: "/",
    agent: new https.Agent({
      maxCachedSessions: 0
    })
  };

  turbot.log.info(`Website url: ${$.inputSite}`);

  function _request(options) {
    return new Promise((resolve, reject) => {
      let req = https.request(options);

      req.on("response", res => {
        resolve(res);
      });

      req.on("error", err => {
        reject(err);
      });

      req.end();
    });
  }

  try {
    const response = await _request(options);
    const certificate = response.connection.getPeerCertificate();
    if (!certificate.valid_to){
      turbot.log.error("Failed to load certificate");
      return turbot.error("Failed to load certificate");
    }
    const expiration = moment(certificate.valid_to);
    const expired = expiration.isBefore();
    const expiresIn = expiration.diff(moment(), 'days');
    const withinWarningPeriod = expiresIn < $.warningPeriod;

    turbot.log.debug(`Certificate`, certificate);
    turbot.log.debug(`Expiration ${expiration.format()}, expiresIn: ${expiresIn}`);
    turbot.log.info(`Certificate authorized: ${response.socket.authorized}`);
    turbot.log.info(`Expiration warning period ${$.warningPeriod} days`);

    if (expired) {
      turbot.log.info(`Certificate expired on: ${certificate.valid_to}`);
      return turbot.alarm(`${options.host} expired on: ${certificate.valid_to}`);
    }

    if (withinWarningPeriod){
      turbot.log.info(`Certificate will expire in ${expiresIn} days.` );
      return turbot.alarm(`Certificate will expire in ${expiresIn} days`);
    }
    turbot.log.info(`Certificate will expire on: ${certificate.valid_to}`);
    return turbot.ok(`${options.host} will not expire in next ${$.warningPeriod} days`);
  } catch (err) {
    turbot.log.error("Error occurred", err);
    if (err.code === "UNABLE_TO_VERIFY_LEAF_SIGNATURE") {
      turbot.log.warning(`${options.host} doesn't have SSL Enabled`);
      return turbot.alarm(`${options.host} doesn't have SSL Enabled`);
    }
    if (err.code === "ENOTFOUND") {
      turbot.log.error(`Provided site ${$.inputSite} doesn't exist`);
      return turbot.error(`Provided site ${$.inputSite} doesn't exist`);
    }
    return turbot.error(err);
  }
});
