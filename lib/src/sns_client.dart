part of aws_dart;

class SNSClient implements AWSClient {
  String accessKey;
  String secretKey;
  Map<String, PlatformApplication> platformApplications = {};

  Future<String> registerEndpoint(PlatformApplication app, String token, String userAssociationValue) async {
    var req = new AWSRequest()
      ..method = "POST"
      ..region = app.region
      ..service = app.service
      ..accessKey = accessKey
      ..secretKey = secretKey
      ..host = app.host;
    req.headers["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8";

    var values = {
      "Action" : "CreatePlatformEndpoint",
      "CustomUserData" : userAssociationValue,
      "Token" : token,
      "PlatformApplicationArn" : app.asARN()
    };
    req.requestBody = values.keys.map((k) {
      return "$k=${Uri.encodeQueryComponent(values[k])}";
    }).join("&");

    var response = await req.execute();
    if (response.statusCode != 200) {
      throw new ClientException(response.statusCode, response.body);
    }

    var regex = new RegExp("<EndpointArn>([^<]*)<\\/EndpointArn>");
    var endpointARN = regex.firstMatch(response.body).group(1);

    return endpointARN;
  }

  Future<bool> sendGCMNotification(PlatformApplicationEndpoint app, GCMNotification notification) async {
    if (app.platformApplication.platform != Platform.gcm) {
      throw new ClientException(500, "Trying to send GCM notification to non-GCM endpoint.");
    }

    var req = new AWSRequest()
      ..method = "POST"
      ..region = app.platformApplication.region
      ..service = app.platformApplication.service
      ..accessKey = accessKey
      ..secretKey = secretKey
      ..host = app.platformApplication.host;
    req.headers["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8";

    var targetARN = app.asARN();
    var values = {
      "Action" : "Publish",
      "TargetArn" : targetARN,
      "Message" : JSON.encode({app.platformApplication.platformString : JSON.encode(notification.asMap())}),
      "MessageStructure" : "json"
    };

    req.requestBody = values.keys.map((k) {
      return "$k=${Uri.encodeQueryComponent(values[k])}";
    }).join("&");

    var response = await req.execute();
    if (response.statusCode != 200) {
      throw new ClientException(response.statusCode, response.body);
    }

    return true;
  }

  Future<bool> sendAPNSNotification(PlatformApplicationEndpoint app, APNSNotification notification) async {
    if (!(app.platformApplication.platform == Platform.apns || app.platformApplication.platform == Platform.apnsSandbox)) {
      throw new ClientException(500, "Trying to send APNS notification to non-APNS endpoint.");
    }

    var req = new AWSRequest()
      ..method = "POST"
      ..region = app.platformApplication.region
      ..service = app.platformApplication.service
      ..accessKey = accessKey
      ..secretKey = secretKey
      ..host = app.platformApplication.host;
    req.headers["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8";

    var targetARN = app.asARN();
    var values = {
      "Action" : "Publish",
      "TargetArn" : targetARN,
      "Message" : JSON.encode({app.platformApplication.platformString : JSON.encode(notification.asMap())}),
      "MessageStructure" : "json"
    };

    req.requestBody = values.keys.map((k) {
      return "$k=${Uri.encodeQueryComponent(values[k])}";
    }).join("&");

    var response = await req.execute();
    if (response.statusCode != 200) {
      throw new ClientException(response.statusCode, response.body);
    }

    return true;
  }
}
