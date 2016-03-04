part of aws_dart;

class EmailOptions {

  EmailOptions.fromConfig(Map<String, String> config) {
    region = config["region"] ?? "us-east-1";
    service = config["service"] ?? "ses";
  }
  EmailOptions({this.region:"us-east-1",this.service:"ses"});

  String region;
  String service;
  String get host => "email.$region.amazonaws.com";
}

class Email {

  Email(String from, String to, String subject, {String bodyHTML, String bodyText}) {
    source = from;
    destination = new EmailDestination()..toAddresses = [to];
    message = new EmailMessage()
      ..subject = (new EmailContent()..data = subject);
    message.body = new EmailBody();
    if (bodyHTML != null) {
      message.body.html = new EmailContent()..data = bodyHTML;
    }
    if (bodyText != null) {
      message.body.text = new EmailContent()..data = bodyText;
    }
  }

  String source;
  EmailDestination destination;
  EmailMessage message;
  Map<String, String> asMap() {
    var map = {
      "Source" : source,
    };
    map.addAll(destination.asMap());
    map.addAll(message.asMap());
    return map;
  }
}

class EmailDestination {
  List<String> toAddresses;
  Map<String, String> asMap() {
    var map = {};
    for (int i = 0; i < toAddresses?.length ?? 0; i++) {
      map["Destination.ToAddresses.member.${i+1}"] = toAddresses[i];
    }
    return map;
  }
}

class EmailMessage {
  EmailContent subject;
  EmailBody body;

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

class EmailBody {
  EmailContent text;
  EmailContent html;

}

class EmailContent {
  String data;
}
