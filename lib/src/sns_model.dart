part of aws_sns;

abstract class ApplicationResource {
  String region;
  String accountID;

  String get service => "sns";
  String get host {
    return "sns.$region.amazonaws.com";
  }

  ApplicationResource(this.region, this.accountID);
}

class Topic extends ApplicationResource {
  Topic(String region, String accountID, this.name) : super(region, accountID);

  String name;

  String asARN() {
    return "arn:aws:sns:$region:$accountID:$name";
  }
}

enum Platform {
  apns, apnsSandbox, gcm
}

class PlatformApplication extends ApplicationResource {
  PlatformApplication(String region, String accountID, this.platform, this.name) : super(region, accountID);

  Platform platform;
  String name;

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

  String id;
  final PlatformApplication platformApplication;

  String asARN() {
    return "arn:aws:sns:${platformApplication.region}:${platformApplication.accountID}:endpoint/${platformApplication.platformString}/${platformApplication.name}/$id";
  }
}