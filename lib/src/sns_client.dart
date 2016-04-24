part of aws_dart;

class SNSClient extends AWSClient {
  static String AuthorizationError = "AuthorizationError";
  static String EndpointDisabled = "EndpointDisabled";
  static String NotFound = "NotFound";
  static String PlatformApplicationDisabled = "PlatformApplicationDisabled";

  Map<String, PlatformApplication> platformApplications = {};

  /// On success, the [values] will contain a single key, EndpointArn, with the registered endpoint arn.
  Future<AWSResponse> registerEndpoint(PlatformApplication app, String token, String userAssociationValue) async {
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

    return await req.execute();
  }

  /// On success, [values] will contain "MessageId".
  Future<bool> sendGCMNotification(PlatformApplicationEndpoint app, GCMNotification notification) async {
    if (app.platformApplication.platform != Platform.gcm) {
      throw new AWSException(500, "Trying to send GCM notification to non-GCM endpoint.", null);
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
    var error = response.error;
    if (error != null) {
      throw error;
    }

    return true;
  }

  /// On success, [values] will contain "MessageId".
  Future<AWSResponse> sendAPNSNotification(PlatformApplicationEndpoint app, APNSNotification notification) async {
    if (!(app.platformApplication.platform == Platform.apns || app.platformApplication.platform == Platform.apnsSandbox)) {
      throw new AWSException(500, "Trying to send APNS notification to non-APNS endpoint.", null);
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

    return await req.execute();
  }

//  Future<EndpointAttributes> getEndpointAttributes(String endpointArn) async {
//    var platform = new PlatformApplication.fromEndpoint(endpointArn);
//    var req = new AWSRequest()
//        ..method = "POST"
//        ..region = platform.region
//        ..service = platform.service;
//
//    return null;
//  }
}
