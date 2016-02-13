part of aws_sns;

class SNSClient {
  Map<String, SNSResource> resources;
  SNSClient(this.resources);

  Future<String> registerEndpoint(String applicationResource, String token, String userAssociationValue) async {
    var resource = resources[applicationResource];
    if (resource == null) {
      throw new SNSClientException(500, "Invalid applicationResource $applicationResource.");
    }

    var req = new SNSRequest()
        ..region = resource.region
        ..service = "sns"
        ..method = "POST"
        ..accessKey = "AKIAJAF6H4WQNE4TARYQ" // HIDE
        ..secretKey = "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" // HIDE
        ..host = "sns.${resource.region}.amazonaws.com";
    req.headers["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8";

    var values = {
      "Action" : "CreatePlatformEndpoint",
      "CustomUserData" : userAssociationValue,
      "Token" : token,
      "PlatformApplicationArn" : "arn:aws:sns:us-east-1:414472037852:app/APNS_SANDBOX/dart_test"
    };
    req.requestBody = values.keys.map((k) {
      return "$k=${Uri.encodeQueryComponent(values[k])}";
    }).join("&");

    var response = await req.execute();
    if (response.statusCode != 200) {
      throw new SNSClientException(response.statusCode, response.body);
    }

    var regex = new RegExp("<EndpointArn>([^<]*)<\\/EndpointArn>");
    var endpointARN = regex.firstMatch(response.body).group(1);

    return endpointARN;
  }

  Future<bool> sendAPNSNotification(String applicationResource, String targetResourceName, APNSNotification notification) async {
    var resource = resources[applicationResource];
    if (resource == null) {
      throw new SNSClientException(500, "Invalid applicationResource $applicationResource.");
    }

    var req = new SNSRequest()
      ..region = resource.region
      ..service = "sns"
      ..method = "POST"
      ..accessKey = "AKIAJAF6H4WQNE4TARYQ" // HIDE
      ..secretKey = "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" // HIDE
      ..host = "sns.${resource.region}.amazonaws.com";
    req.headers["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8";

    var values = {
      "Action" : "Publish",
      "TargetArn" : targetResourceName,
      "Message" : JSON.encode({resource.type : JSON.encode(notification.asMap())}),
      "MessageStructure" : "json"
    };

    req.requestBody = values.keys.map((k) {
      return "$k=${Uri.encodeQueryComponent(values[k])}";
    }).join("&");

    var response = await req.execute();
    if (response.statusCode != 200) {
      throw new SNSClientException(response.statusCode, response.body);
    }

    return true;
  }
}

class SNSResource {
  String type;
  String region;
  String accountID;
  String topicName;
  String subscriptionID;

  SNSResource(this.type, this.region, this.accountID, this.topicName, this.subscriptionID);
}

class SNSClientException implements Exception {
  String message;
  int statusCode;
  SNSClientException(this.statusCode, this.message);

  String toString() {
    return "SNSClientException: $statusCode $message";
  }
}