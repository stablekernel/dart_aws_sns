part of aws_dart;

enum Platform {
  apns, apnsSandbox, gcm
}

class PlatformApplicationConfigurationItem extends ConfigurationItem {
  String region;
  String name;
  String platform;

  @optionalConfiguration
  String accountID;
}

class PlatformApplication extends ApplicationResource {
  static Platform platformForString(String platformString) {
    switch (platformString) {
      case "APNS" : return Platform.apns;
      case "APNS_SANDBOX" : return Platform.apnsSandbox;
      case "GCM" : return Platform.gcm;
    }
    return null;
  }

  PlatformApplication(String region, String accountID, this.platform, this.name) : super.forAccount(region, accountID);

  PlatformApplication.fromConfiguration(PlatformApplicationConfigurationItem item) {
    region = item.region;
    accountID = item.accountID;
    name = item.name;
    platform = platformForString(item.platform);
  }

  PlatformApplication.fromEndpoint(String endpointARN) {
    var components = endpointARN.split(":");
    region = components[3];
    accountID = components[4];

    var endpointComponents = components[5].split("/");
    name = endpointComponents[2];

    switch(endpointComponents[1]) {
      case "APNS" : platform = Platform.apns; break;
      case "APNS_SANDBOX" : platform = Platform.apnsSandbox; break;
      case "GCM" : platform = Platform.gcm; break;
    }
  }

  Platform platform;
  String name;
  String get service => "sns";
  String get host {
    return "sns.$region.amazonaws.com";
  }

  String get platformString {
    switch (platform) {
      case Platform.apns : return "APNS";
      case Platform.apnsSandbox : return "APNS_SANDBOX";
      case Platform.gcm : return "GCM";
    }
  }

  PlatformApplicationEndpoint endpointForID(String id) {
    return new PlatformApplicationEndpoint(this, id);
  }

  String asARN() {
    return "arn:aws:sns:$region:$accountID:app/$platformString/$name";
  }
}

class PlatformApplicationEndpoint {
  PlatformApplicationEndpoint(this.platformApplication, this.id);
  PlatformApplicationEndpoint.fromString(String endpointArn)
      : this(new PlatformApplication.fromEndpoint(endpointArn),
      endpointArn.split("/").last);

  String id;
  final PlatformApplication platformApplication;

  String asARN() {
    return "arn:aws:sns:${platformApplication.region}:${platformApplication.accountID}:endpoint/${platformApplication.platformString}/${platformApplication.name}/$id";
  }
}

class EndpointAttributes {
  dynamic customerUserData;
  bool isEnabled;
  String deviceToken;
}