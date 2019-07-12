const { fnAsync } = require("@turbot/fn");
const https = require("https");

exports.control = fnAsync(async (turbot, $) => {
  var options = {
    host: $.inputSite,
    method: "get",
    path: "/"
  };

  turbot.log.info("Provided website is", $.inputSite);

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
    turbot.log.info("certificate authorized:" + response.socket.authorized);
    if (response.socket.authorized) {
      return turbot.ok();
    } else {
      return turbot.alarm();
    }
  } catch (err) {
    turbot.log.error("Error occurred");
    turbot.log.error(err);
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
