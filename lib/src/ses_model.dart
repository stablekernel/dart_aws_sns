part of aws_dart;

class EmailOptions {
  String region = "us-east-1";
  String service = "ses";
  String get host => "email.$region.amazonaws.com";
}

class Email {
  Map<String, String> asMap() {
    var map = {
      "Source" : source,
    };
    map.addAll(destination.asMap());
    map.addAll(message.asMap());
    return map;
  }

  String source;
  Destination destination;
  Message message;
}

class Destination {
  List<String> toAddresses;
  Map<String, String> asMap() {
    var map = {};
    for (int i=0; i<toAddresses.length; i++) {
      map["Destination.ToAddresses.member.${i+1}"] = toAddresses[i];
    }
    return map;
  }
}

class Message {
  Content subject;
  Body body;

  Map<String, String> asMap() {
    var map = {
      "Message.Subject.Data" : subject.data
    };
    if (body.text != null) {
      map["Message.Body.Text.Data"] = body.text.data;
    }
    if (body.html != null) {
      map["Message.Body.Html.Data"] = body.html.data;
    }
    return map;
  }
}

class Body {
  Content text;
  Content html;

}

class Content {
  String data;
}
