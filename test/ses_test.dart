import 'package:aws_sns/aws_dart.dart';
import 'package:test/test.dart';

void main() {
  var client = new SESClient()
    ..accessKey = "AKIAJAF6H4WQNE4TARYQ"
    ..secretKey = "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";

  test("Can send email with html and text", () async {
    var email = new Email("test@stablekernel.com", "test@stablekernel.com","Test1",bodyHTML: "<h1>Hello</h1>",bodyText: "Hello");
    var resp = await client.sendEmail(email);
    expect(resp, true);
  });

  test("Can send email with html", () async {
    var email = new Email("test@stablekernel.com", "test@stablekernel.com","Test2",bodyHTML: "<h1>Hello</h1>");
    var resp = await client.sendEmail(email);
    expect(resp, true);
  });

  test("Can send email with text", () async {
    var email = new Email("test@stablekernel.com", "test@stablekernel.com","Test3",bodyText : "Hello");
    var resp = await client.sendEmail(email);
    expect(resp, true);
  });
}