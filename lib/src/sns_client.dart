part of aws_sns;

class SNSClient {
  Map<String, SNSResource> resources = {};
  String accessKey;
  String secretKey;

  void addResource(String resourceName, SNSResource resource) {
    resources[resourceName] = resource;
  }
  void removeResource(String resourceName) {
    resources.remove(resourceName);
  }

  Future<String> registerEndpoint(String applicationResource, String token, String userAssociationValue) async {
    var resource = resources[applicationResource];
    if (resource == null) {
      throw new SNSClientException(500, "Invalid applicationResource $applicationResource.");
    }

    var req = new SNSRequest()
        ..region = resource.region
        ..service = "sns"
        ..method = "POST"
        ..accessKey = accessKey
        ..secretKey = secretKey
        ..host = "sns.${resource.region}.amazonaws.com";
    req.headers["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8";

    var values = {
      "Action" : "CreatePlatformEndpoint",
      "CustomUserData" : userAssociationValue,
      "Token" : token,
      "PlatformApplicationArn" : "arn:aws:sns:${resource.region}:${resource.accountID}:app/${resource.platform}/${resource.applicationName}"
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
      ..accessKey = accessKey
      ..secretKey = secretKey
      ..host = "sns.${resource.region}.amazonaws.com";
    req.headers["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8";

    var values = {
      "Action" : "Publish",
      "TargetArn" : targetResourceName,
      "Message" : JSON.encode({resource.platform : JSON.encode(notification.asMap())}),
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
  String platform;
  String region;
  String accountID;
  String applicationName;

  SNSResource(this.platform, this.region, this.accountID, this.applicationName);
}

class SNSClientException implements Exception {
  String message;
  int statusCode;
  SNSClientException(this.statusCode, this.message);

  String toString() {
    return "SNSClientException: $statusCode $message";
  }
}