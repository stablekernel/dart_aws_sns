part of aws_sns;

class APNSNotification {
  APNSAlert alert;
  int badge;
  String soundFilePath;
  bool contentAvailable;
  String category;

  Map<String, dynamic> otherValues;

  Map asMap() {
    var aps = {};

    if (alert != null) {
      aps["alert"] = alert.asMap();
    }

    if(badge != null) {
      aps["badge"] = badge;
    }

    if (soundFilePath != null) {
      aps["sound"] = soundFilePath;
    }

    if (contentAvailable != null && contentAvailable) {
      aps["content-available"] = 1;
    }

    if (category != null) {
      aps["category"] = category;
    }

    var map = {};
    if (aps.length > 0) {
      map["aps"] = aps;
    }

    if (otherValues != null) {
      map.addAll(otherValues);
    }

    return map;
  }
}

class APNSAlert {
  String title;
  String body;
  String localizedTitleKey;
  String localizedTitleArguments;
  String localizedActionKey;
  String localizedKey;
  String localizedArguments;
  String launchImagePath;

  Map asMap() {
    var map = {};

    if (title != null) {
      map["title"] = title;
    }

    if (body != null) {
      map["body"] = body;
    }

    if (localizedTitleKey != null) {
      map["title-loc-key"] = localizedTitleKey;
    }

    if (localizedTitleArguments != null) {
      map["title-loc-args"] = localizedArguments;
    }

    if (localizedActionKey != null) {
      map["action-loc-key"] = localizedActionKey;
    }

    if (localizedKey != null) {
      map["loc-key"] = localizedKey;
    }

    if (localizedArguments != null) {
      map["loc-args"] = localizedArguments;
    }

    if (launchImagePath != null) {
      map["launch-image"] = launchImagePath;
    }

    return map;
  }
}