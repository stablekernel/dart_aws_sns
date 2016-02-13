import 'package:aws_sns/aws_sns.dart';
import 'package:test/test.dart';


void main() {
  var client = new SNSClient()
    ..accessKey = "AKIAJAF6H4WQNE4TARYQ"
    ..secretKey = "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";

  var resource = new SNSResource("APNS_SANDBOX", "us-east-1", "414472037852", "dart_test");
  client.addResource("ios", resource);

  test("Create endpoint", () async {
    var resp = await client.registerEndpoint("ios", "861f9359e2cd748e2a1ad73ba663bee3054c5f210e6d7bd603b68e086c557683", "1");
    expect(resp, startsWith("arn:aws:sns"));
  });

  test("Send notification", () async {
    var note = new APNSNotification()
      ..alert = (new APNSAlert()
        ..body = "Hello");

    try {
      var resp = await client.sendAPNSNotification("ios",
          "arn:aws:sns:us-east-1:414472037852:endpoint/APNS_SANDBOX/dart_test/9844c45f-e585-3a5c-b579-993236542627",
          note);
      expect(resp, true);
    } catch (e) {
      fail("Should succeed $e");
    }
  });
}