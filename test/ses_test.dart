import 'package:aws_sns/aws_dart.dart';
import 'package:test/test.dart';

void main() {
  var client = new SESClient()
    ..accessKey = "AKIAJAF6H4WQNE4TARYQ"
    ..secretKey = "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";

  var stuff = new Stuff()
    ..region = "us-east-1"
    ..service = "ses"
    ..host = "email.us-east-1.amazonaws.com";

  test("Can send email with html and text", () async {
    var email = new Email()
      ..source = "test@stablekernel.com"
      ..destination = (new Destination()..toAddresses = ["alex.nachlas@stablekernel.com"])
      ..message = (new Message()
        ..body = (new Body()..html = (new Content()..data= "<h1>Hello</h1>")..text=(new Content()..data="Hello"))
        ..subject = (new Content()..data = "Test"));
    var resp = await client.sendEmail(email, stuff);
    expect(resp, true);
  });
}