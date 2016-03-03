import 'package:aws_sns/aws_dart.dart';
import 'package:test/test.dart';


void main() {
  var client = new SESClient()
    ..accessKey = "AKIAJAF6H4WQNE4TARYQ"
    ..secretKey = "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";

  var email = new Email()
    ..source = "test@stablekernel.com"
    ..destination = (new Destination()..toAddresses = ["alex.nachlas@stablekernel.com"])
    ..message = (new Message()
      ..body = (new Body()..text = (new Content()..data= "Hello"))
      ..subject = (new Content()..data = "Test"));
  var stuff = new Stuff()
    ..region = "us-east-1"
    ..service = "ses"
    ..host = "";

  var subscribedEndpoint = null;
  test("Create endpoint", () async {
    var resp = await client.registerEndpoint(client.platformApplications["iOS"], "861f9359e2cd748e2a1ad73ba663bee3054c5f210e6d7bd603b68e086c557683", "1");
    expect(resp, startsWith("arn:aws:sns"));
    subscribedEndpoint = resp.split("/").last;
  });

  test("Send notification", () async {
    var note = new APNSNotification()
      ..alert = (new APNSAlert()
        ..body = "Hello");

    try {
      var resp = await client.sendAPNSNotification(client.platformApplications["iOS"].endpointForID(subscribedEndpoint), note);
      expect(resp, true);
    } catch (e) {
      fail("Should succeed $e");
    }
  });
}