part of dart_aws;

class Stuff {
  String region;
  String service;
  String host;
}

class Email {
  String source;
  Destination destination;
  Message message;
}

class Destination {
  List<String> toAddresses;
}

class Message {
  Content subject;
  Body body;
}

class Body {
  Content text;
  Content html;
}

class Content {
  String data;
  //String charset;
}
