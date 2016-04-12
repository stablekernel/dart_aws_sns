import 'package:aws_sns/aws_dart.dart';
import 'package:test/test.dart';


void main() {
  var client = new SNSClient()
    ..accessKey = "AKIAJAF6H4WQNE4TARYQ"
    ..secretKey = "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";

  var platformApp = new PlatformApplication("us-east-1", "414472037852", Platform.apnsSandbox, "dart_test");
  client.platformApplications["iOS"] = platformApp;

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

  test("Send silent notification", () async {
    var notif = new APNSNotification()..otherValues = {"t" : "test", "id" : 5};
    try {
      var resp = await client.sendAPNSNotification(client.platformApplications["iOS"].endpointForID(subscribedEndpoint), notif);
      expect(resp, true);
    } catch (e) {
      fail("Threw exception $e");
    }
  });
}