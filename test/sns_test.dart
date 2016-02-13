import 'package:aws_sns/aws_sns.dart';
import 'package:test/test.dart';


void main() {
  var resource = new SNSResource("APNS_SANDBOX", "us-east-1", "414472037852", "dart_tests", "bc33a42e-4562-4e57-9b3b-7efcbca55591");
  var client = new SNSClient({"ios" : resource});

  test("Create endpoint", () async {
    var resp = await client.registerEndpoint("ios", "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", "1234567");
    expect(resp, startsWith("arn:aws:sns"));
  });

  test("Send notification", () async {
    var note = new APNSNotification()
      ..alert = (new APNSAlert()
        ..body = "Hello");
    //try {
      var resp = await client.sendAPNSNotification("ios",
          "arn:aws:sns:us-east-1:414472037852:endpoint/APNS_SANDBOX/dart_test/9844c45f-e585-3a5c-b579-993236542627",
          note);
//    } catch (e) {
//      print("$e");
//    }


  });
}