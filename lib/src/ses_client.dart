part of aws_dart;

class SESClient extends AWSClient {
  Map<String, EmailOptions> emailOptions = {};

  Future<bool> sendEmail(String emailOptionKey, Email email) async {
    var options = emailOptions[emailOptionKey];
    if (options == null) {
      throw new AWSException(500, "No options available for $emailOptionKey", null);
    }

    var req = new AWSRequest()
      ..method = "POST"
      ..region = options.region
      ..service = options.service
      ..accessKey = accessKey
      ..secretKey = secretKey
      ..host = options.host;
    req.headers["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8";

    var emailMap = email.asMap();
    emailMap["Action"] = "SendEmail";
    req.requestBody = emailMap.keys.map((k) {
      return "$k=${Uri.encodeQueryComponent(emailMap[k])}";
    }).join("&");

    var response = await req.execute();
    var error = response.error;
    if (error != null) {
      throw error;
    }
    return true;
  }
}