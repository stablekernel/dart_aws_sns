part of aws_dart;

class EmailConfigurationItem extends ConfigurationItem {
  String region;
  String accountID;
}

class EmailOptions extends ApplicationResource {
  EmailOptions.fromConfiguration(EmailConfigurationItem config) :
        super.forAccount(config.region, config.accountID);

  EmailOptions(String region, String accountID) : super.forAccount(region, accountID);

  String get service => "ses";
  String get host => "email.$region.amazonaws.com";
}

class Email {
  Email(this.source, String to, String subject, {String bodyHTML, String bodyText}) {
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
