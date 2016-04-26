import 'package:aws_sns/aws_dart.dart';
import 'package:test/test.dart';


void main() {
  var client = new SNSClient()
    ..accessKey = "AKIAJAF6H4WQNE4TARYQ"
    ..secretKey = "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";

  var platformApp = new PlatformApplication("us-east-1", "414472037852", Platform.apnsSandbox, "dart_test");
  client.platformApplications["iOS"] = platformApp;

  group("Raw calls", () {
    var subscribedEndpoint = null;
    test("Create valid endpoint", () async {
      var resp = await client.registerEndpoint("iOS", "861f9359e2cd748e2a1ad73ba663bee3054c5f210e6d7bd603b68e086c557683", "1");
      expect(resp.statusCode, 200);
      expect(resp.value["endpointARN"], startsWith("arn:aws:sns"));
      subscribedEndpoint = resp.value["endpointARN"];
    });

    test("Create invalid endpoint", () async {
      var resp = await client.registerEndpoint("iOS", "f9359e2cd748e2a1ad73ba663bee3054c5f210e6d7bd603b68e086c557683", "1");
      expect(resp.statusCode, 400);
      expect(resp.error.key, AWSClient.InvalidParameter);
      expect(resp.error.message, "Invalid parameter: Token Reason: iOS device tokens must be 64 hexadecimal characters");
    });

    test("Send notification", () async {
      var note = new APNSNotification()
        ..alert = (new APNSAlert()
          ..body = "Hello");

      var resp = await client.sendAPNSNotification(subscribedEndpoint, note);
      expect(resp.statusCode, 200);
      expect(resp.value["messageID"], isNotNull);
    });

    test("Send silent notification", () async {
      var notif = new APNSNotification()
        ..otherValues = {"t" : "test", "id" : 5};

      var resp = await client.sendAPNSNotification(subscribedEndpoint, notif);
      expect(resp.statusCode, 200);
      expect(resp.value["messageID"], isNotNull);
    });

    test("Get endpoint attributes", () async {
      var resp = await client.getEndpointAttributes(subscribedEndpoint);
      expect(resp.statusCode, 200);
      expect(resp.value["enabled"], true);
      expect(resp.value["token"], isNotNull);
      expect(resp.value["customUserData"], 1);
    });

    test("Set endpoint attributes", () async {
      var resp = await client.setEndpointAttributes(subscribedEndpoint, userAssociatedValue: "Foo");
      expect(resp.statusCode, 200);

      resp = await client.getEndpointAttributes(subscribedEndpoint);
      expect(resp.statusCode, 200);
      expect(resp.value["enabled"], true);
      expect(resp.value["token"], isNotNull);
      expect(resp.value["customUserData"], "Foo");
    });

    test("Delete endpoint", () async {
      var resp = await client.deleteEndpoint(subscribedEndpoint);
      expect(resp.statusCode, 200);

      resp = await client.getEndpointAttributes(subscribedEndpoint);
      expect(resp.statusCode, 404);
    });
  });

  group("Safe registration", () {
    var subscribedEndpoint = null;

    test("Create valid endpoint", () async {
      var resp = await client.safelyRegisterToken("iOS", "861f9359e2cd748e2a1ad73ba663bee3054c5f210e6d7bd603b68e086c557683", "1");
      expect(resp.statusCode, 200);
      expect(resp.value["endpointARN"], startsWith("arn:aws:sns"));
      subscribedEndpoint = resp.value["endpointARN"];
    });

    test("Re-register, normal", () async {
      var resp = await client.safelyRegisterToken("iOS", "861f9359e2cd748e2a1ad73ba663bee3054c5f210e6d7bd603b68e086c557683", "1");
      expect(resp.statusCode, 200);
      expect(resp.value["endpointARN"], subscribedEndpoint);
    });

    test("Re-register, different custom user data", () async {
      var resp = await client.safelyRegisterToken("iOS", "861f9359e2cd748e2a1ad73ba663bee3054c5f210e6d7bd603b68e086c557683", "12");
      expect(resp.statusCode, 200);
      expect(resp.value["endpointARN"], subscribedEndpoint);
    });

    test("Re-register, after disabled", () async {
      var resp = await client.setEndpointAttributes(subscribedEndpoint, enabled: false);
      expect(resp.statusCode, 200);

      resp = await client.getEndpointAttributes(subscribedEndpoint);
      expect(resp.statusCode, 200);
      expect(resp.value["enabled"], false);

      resp = await client.safelyRegisterToken("iOS", "861f9359e2cd748e2a1ad73ba663bee3054c5f210e6d7bd603b68e086c557683", "12");
      expect(resp.statusCode, 200);
      expect(resp.value["endpointARN"], subscribedEndpoint);

      resp = await client.getEndpointAttributes(subscribedEndpoint);
      expect(resp.statusCode, 200);
      expect(resp.value["enabled"], true);
    });

    test("Delete when done", () async {
      var resp = await client.deleteEndpoint(subscribedEndpoint);
      expect(resp.statusCode, 200);

      resp = await client.getEndpointAttributes(subscribedEndpoint);
      expect(resp.statusCode, 404);
    });
  });

  group("Disabled feedback", () {
    var subscribedEndpoint = null;

    test("Create valid endpoint", () async {
      var resp = await client.safelyRegisterToken("iOS", "861f9359e2cd748e2a1ad73ba663bee3054c5f210e6d7bd603b68e086c557683", "1");
      expect(resp.statusCode, 200);
      expect(resp.value["endpointARN"], startsWith("arn:aws:sns"));
      subscribedEndpoint = resp.value["endpointARN"];
    });

    test("Disable and get feedback", () async {
      var resp = await client.setEndpointAttributes(subscribedEndpoint, enabled: false);
      expect(resp.statusCode, 200);

      var note = new APNSNotification()
        ..alert = (new APNSAlert()
          ..body = "Hello");

      resp = await client.sendAPNSNotification(subscribedEndpoint, note);
      expect(resp.statusCode, 400);

      var nextDisableItem = await client.onDisable.first;
      expect(nextDisableItem.asARN(), subscribedEndpoint);
    });

    test("Delete when done", () async {
      var resp = await client.deleteEndpoint(subscribedEndpoint);
      expect(resp.statusCode, 200);

      resp = await client.getEndpointAttributes(subscribedEndpoint);
      expect(resp.statusCode, 404);
    });
  });
}