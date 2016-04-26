part of aws_dart;

class SNSClient extends AWSClient {
  static String AuthorizationError = "AuthorizationError";
  static String EndpointDisabled = "EndpointDisabled";
  static String NotFound = "NotFound";
  static String PlatformApplicationDisabled = "PlatformApplicationDisabled";

  Stream<PlatformApplicationEndpoint> onDisable;
  StreamController<PlatformApplicationEndpoint> _onDisableController = new StreamController<PlatformApplicationEndpoint>();
  Map<String, PlatformApplication> platformApplications = {};

  Future<AWSResponse> safelyRegisterToken(String platformApplicationKey, String token, String userAssociatedValue) async {
    var resp = await registerEndpoint(platformApplicationKey, token, userAssociatedValue);
    var registeredArn = null;
    if (!resp.wasSuccessful) {
      if (resp.error.key != AWSClient.InvalidParameter) {
        return resp;
      }

      var regex = new RegExp(r"Endpoint ([\S]+) already exists with the same Token, but different attributes");
      var match = regex.firstMatch(resp.error.message);
      if (match == null) {
        return resp;
      }

      registeredArn = match.group(1);
    } else {
      registeredArn = resp.value["endpointARN"];
    }

    resp = await getEndpointAttributes(registeredArn);
    if (resp.value["customUserData"] == userAssociatedValue && resp.value["enabled"] == true) {
      return new AWSResponse()
        ..value = {"endpointARN" : registeredArn}
        ..statusCode = 200;
    }

    var attributesResponse = await setEndpointAttributes(registeredArn, enabled: true, userAssociatedValue: userAssociatedValue);
    if (!attributesResponse.wasSuccessful) {
      return attributesResponse;
    }

    return new AWSResponse()
      ..value = {"endpointARN" : registeredArn}
      ..statusCode = 200;
  }

  /// On success, the [value] is a Map that will contain a single key, endpointARN, with the registered endpoint arn.
  Future<AWSResponse> registerEndpoint(String platformApplicationKey, String token, String userAssociationValue) async {
    var app = platformApplications[platformApplicationKey];
    if (app == null) {
      throw new AWSException(500, "Invalid platformApplication $platformApplicationKey, available values are ${platformApplications.keys.join(",")}", null);
    }
    var values = {
      "Action" : "CreatePlatformEndpoint",
      "CustomUserData" : userAssociationValue,
      "Token" : token,
      "PlatformApplicationArn" : app.asARN()
    };

    var result = await executeRequest(app.newRequest(values));
    if (!result.wasSuccessful) {
      return result;
    }

    var endpointArn = result.resultXMLElement?.
      children?.firstWhere((n) => n is xml.XmlElement && n.name.local == "EndpointArn")?.text;
    result.value = {"endpointARN" : endpointArn};

    return result;
  }

  /// On success, [value] is a Map will contain a value for the key messageID.
  Future<AWSResponse> sendGCMNotification(String endpointArn, GCMNotification notification) async {
    var endpoint = new PlatformApplicationEndpoint.fromString(endpointArn);
    if (endpoint.platformApplication.platform != Platform.gcm) {
      throw new AWSException(500, "Trying to send GCM notification to non-GCM endpoint.", null);
    }

    var targetARN = endpoint.asARN();
    var values = {
      "Action" : "Publish",
      "TargetArn" : targetARN,
      "Message" : JSON.encode({endpoint.platformApplication.platformString : JSON.encode(notification.asMap())}),
      "MessageStructure" : "json"
    };

    var result = await executeRequest(endpoint.platformApplication.newRequest(values));
    if (!result.wasSuccessful) {
      return result;
    }

    if (!result.wasSuccessful) {
      if (result.error?.key == SNSClient.EndpointDisabled) {
        _onDisableController.add(endpoint);
      }
      return result;
    }

    var messageID = result.resultXMLElement?.
      children?.firstWhere((n) => n is xml.XmlElement && n.name.local == "MessageId")?.text;
    result.value = {"messageID" : messageID};

    return result;
  }

  /// On success, [value] is a Map will contain a value for the key messageID.
  Future<AWSResponse> sendAPNSNotification(String endpointArn, APNSNotification notification) async {
    var endpoint = new PlatformApplicationEndpoint.fromString(endpointArn);
    if (!(endpoint.platformApplication.platform == Platform.apns || endpoint.platformApplication.platform == Platform.apnsSandbox)) {
      throw new AWSException(500, "Trying to send APNS notification to non-APNS endpoint.", null);
    }

    var targetARN = endpoint.asARN();
    var values = {
      "Action" : "Publish",
      "TargetArn" : targetARN,
      "Message" : JSON.encode({endpoint.platformApplication.platformString : JSON.encode(notification.asMap())}),
      "MessageStructure" : "json"
    };

    var result = await executeRequest(endpoint.platformApplication.newRequest(values));
    if (!result.wasSuccessful) {
      return result;
    }

    if (!result.wasSuccessful) {
      if (result.error?.key == SNSClient.EndpointDisabled) {
        _onDisableController.add(endpoint);
      }
      return result;
    }

    var messageID = result.resultXMLElement?.
    children?.firstWhere((n) => n is xml.XmlElement && n.name.local == "MessageId")?.text;
    result.value = {"messageID" : messageID};

    return result;
  }

  Future<AWSResponse> deleteEndpoint(String endpointArn) async {
    var endpoint = new PlatformApplicationEndpoint.fromString(endpointArn);
    var targetARN = endpoint.asARN();
    var values = {
      "Action" : "DeleteEndpoint",
      "EndpointArn" : targetARN
    };

    var result = await executeRequest(endpoint.platformApplication.newRequest(values));

    return result;
  }

  Future<AWSResponse> setEndpointAttributes(String endpointArn, {bool enabled: true, dynamic userAssociatedValue, String token}) async {
    var endpoint = new PlatformApplicationEndpoint.fromString(endpointArn);

    var values = {
      "Action" : "SetEndpointAttributes",
      "EndpointArn" : endpointArn
    };
    var keyCount = 1;

    values["Attributes.entry.$keyCount.key"] = "Enabled";
    values["Attributes.entry.$keyCount.value"] = enabled ? "true" : "false";
    keyCount ++;

    if (userAssociatedValue != null) {
      values["Attributes.entry.$keyCount.key"] = "CustomUserData";
      values["Attributes.entry.$keyCount.value"] = userAssociatedValue;
      keyCount ++;
    }

    if (token != null) {
      values["Attributes.entry.$keyCount.key"] = "Token";
      values["Attributes.entry.$keyCount.value"] = token;
      keyCount ++;
    }

    var result = await executeRequest(endpoint.platformApplication.newRequest(values));

    return result;
  }

  /// Successful response [value] contains {'customUserData' : any, 'token' : DeviceToken, 'enabled' : bool}
  Future<AWSResponse> getEndpointAttributes(String endpointArn) async {
    var endpoint = new PlatformApplicationEndpoint.fromString(endpointArn);
    var targetARN = endpoint.asARN();
    var values = {
      "Action" : "GetEndpointAttributes",
      "EndpointArn" : targetARN
    };

    var result = await executeRequest(endpoint.platformApplication.newRequest(values));
    if (!result.wasSuccessful) {
      return result;
    }

    var attributes = result.resultXMLElement?.
      children?.firstWhere((n) => n is xml.XmlElement && n.name.local == "Attributes");

    var map = {};
    attributes
        ?.children
        ?.where((n) => n is xml.XmlElement && n.name.local == "entry")
        ?.forEach((n) {
      var key = n.children
          .firstWhere((child) => child is xml.XmlElement && child.name.local == "key",
            orElse: () => null)?.text;
      var value = n.children
          .firstWhere((child) => child is xml.XmlElement && child.name.local == "value",
            orElse: () => null)?.text;

      if (key != null && value != null) {
        var firstChar = key.substring(0, 1).toLowerCase();
        var camelCasedKey = key.replaceRange(0, 1, firstChar);
        if (value == "true") {
          value = true;
        } else if (value == "false") {
          value = false;
        } else {
          try {
            var intValue = int.parse(value, radix: 10);
            value = intValue;
          } on FormatException {}
        }
        map[camelCasedKey] = value;
      }
    });
    result.value = map;

    return result;
  }
}
