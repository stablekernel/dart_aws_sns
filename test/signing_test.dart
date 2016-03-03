import 'package:aws_sns/aws_dart.dart';
import 'package:test/test.dart';

void main() {
  test("Signature", () {
    var signingKey = SNSRequest.calculateSigningKey("wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY", new DateTime(2015, 8, 30), "us-east-1", "service");
    var stringToSign = "AWS4-HMAC-SHA256\n20150830T123600Z\n20150830/us-east-1/service/aws4_request\nbb579772317eb040ac9ed261061d46c1f17a8133879d6129b6e1c25292927e63";
    var signature = SNSRequest.calculateSignature(signingKey, stringToSign);
    expect(signature, "5fa00fa31553b73ebf1942676e86291e8372ff2a2260956d9b8aae1d763fbf31");
  });

  test("Vanilla Get", () {
    var snsReq = new SNSRequest()
        ..host = "example.amazonaws.com"
        ..service = "service"
        ..accessKey = "AKIDEXAMPLE"
        ..secretKey = "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY"
        ..region = "us-east-1"
        ..method = "GET"
        ..timestamp = new DateTime(2015, 8, 30, 12, 36);
    var canonReq = snsReq.canonicalRequest;
    var expectedCanonicalRequest = "GET\n/\n\nhost:example.amazonaws.com\nx-amz-date:20150830T123600Z\n\nhost;x-amz-date\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";
    expect(canonReq, expectedCanonicalRequest);

    var expectedStringToSign = "AWS4-HMAC-SHA256\n20150830T123600Z\n20150830/us-east-1/service/aws4_request\nbb579772317eb040ac9ed261061d46c1f17a8133879d6129b6e1c25292927e63";
    var actualStringToSign = snsReq.stringToSign;
    expect(actualStringToSign, expectedStringToSign);

    var expectedSignature = "5fa00fa31553b73ebf1942676e86291e8372ff2a2260956d9b8aae1d763fbf31";
    expect(snsReq.signature, expectedSignature);

    var expectedAuthorizationHeader = "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-date, Signature=5fa00fa31553b73ebf1942676e86291e8372ff2a2260956d9b8aae1d763fbf31";
    expect(snsReq.authorizationHeader, expectedAuthorizationHeader);
  });

  test("Vanilla Get Unreserved", () {
    var snsReq = new SNSRequest()
      ..host = "example.amazonaws.com"
      ..service = "service"
      ..accessKey = "AKIDEXAMPLE"
      ..secretKey = "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY"
      ..region = "us-east-1"
      ..queryParameters = {"-._~0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz" : "-._~0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"}
      ..method = "GET"
      ..timestamp = new DateTime(2015, 8, 30, 12, 36);
    var canonReq = snsReq.canonicalRequest;
    var expectedCanonicalRequest = "GET\n/\n-._~0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz=-._~0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz\nhost:example.amazonaws.com\nx-amz-date:20150830T123600Z\n\nhost;x-amz-date\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";
    expect(canonReq, expectedCanonicalRequest);

    var expectedStringToSign = "AWS4-HMAC-SHA256\n20150830T123600Z\n20150830/us-east-1/service/aws4_request\nc30d4703d9f799439be92736156d47ccfb2d879ddf56f5befa6d1d6aab979177";
    var actualStringToSign = snsReq.stringToSign;
    expect(actualStringToSign, expectedStringToSign);

    var expectedSignature = "9c3e54bfcdf0b19771a7f523ee5669cdf59bc7cc0884027167c21bb143a40197";
    expect(snsReq.signature, expectedSignature);

    var expectedAuthorizationHeader = "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-date, Signature=9c3e54bfcdf0b19771a7f523ee5669cdf59bc7cc0884027167c21bb143a40197";
    expect(snsReq.authorizationHeader, expectedAuthorizationHeader);
  });

  test("Get Vanilla empty query key", () {
    var snsReq = new SNSRequest()
      ..host = "example.amazonaws.com"
      ..service = "service"
      ..accessKey = "AKIDEXAMPLE"
      ..secretKey = "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY"
      ..region = "us-east-1"
      ..queryParameters = {"Param1" : "value1"}
      ..method = "GET"
      ..timestamp = new DateTime(2015, 8, 30, 12, 36);
    var canonReq = snsReq.canonicalRequest;
    var expectedCanonicalRequest = "GET\n/\nParam1=value1\nhost:example.amazonaws.com\nx-amz-date:20150830T123600Z\n\nhost;x-amz-date\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";
    expect(canonReq, expectedCanonicalRequest);

    var expectedStringToSign = "AWS4-HMAC-SHA256\n20150830T123600Z\n20150830/us-east-1/service/aws4_request\n1e24db194ed7d0eec2de28d7369675a243488e08526e8c1c73571282f7c517ab";
    var actualStringToSign = snsReq.stringToSign;
    expect(actualStringToSign, expectedStringToSign);

    var expectedSignature = "a67d582fa61cc504c4bae71f336f98b97f1ea3c7a6bfe1b6e45aec72011b9aeb";
    expect(snsReq.signature, expectedSignature);

    var expectedAuthorizationHeader = "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-date, Signature=a67d582fa61cc504c4bae71f336f98b97f1ea3c7a6bfe1b6e45aec72011b9aeb";
    expect(snsReq.authorizationHeader, expectedAuthorizationHeader);
  });

  test("Get Vanilla", () {
    var snsReq = new SNSRequest()
      ..host = "example.amazonaws.com"
      ..service = "service"
      ..accessKey = "AKIDEXAMPLE"
      ..secretKey = "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY"
      ..region = "us-east-1"
      ..method = "GET"
      ..timestamp = new DateTime(2015, 8, 30, 12, 36);
    var canonReq = snsReq.canonicalRequest;
    var expectedCanonicalRequest = "GET\n/\n\nhost:example.amazonaws.com\nx-amz-date:20150830T123600Z\n\nhost;x-amz-date\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";
    expect(canonReq, expectedCanonicalRequest);

    var expectedStringToSign = "AWS4-HMAC-SHA256\n20150830T123600Z\n20150830/us-east-1/service/aws4_request\nbb579772317eb040ac9ed261061d46c1f17a8133879d6129b6e1c25292927e63";
    var actualStringToSign = snsReq.stringToSign;
    expect(actualStringToSign, expectedStringToSign);

    var expectedSignature = "5fa00fa31553b73ebf1942676e86291e8372ff2a2260956d9b8aae1d763fbf31";
    expect(snsReq.signature, expectedSignature);

    var expectedAuthorizationHeader = "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-date, Signature=5fa00fa31553b73ebf1942676e86291e8372ff2a2260956d9b8aae1d763fbf31";
    expect(snsReq.authorizationHeader, expectedAuthorizationHeader);
  });

  test("Get Vanilla Order Key Case", () {
    var snsReq = new SNSRequest()
      ..host = "example.amazonaws.com"
      ..service = "service"
      ..accessKey = "AKIDEXAMPLE"
      ..secretKey = "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY"
      ..region = "us-east-1"
      ..queryParameters = {"Param2" : "value2", "Param1" : "value1"}
      ..method = "GET"
      ..timestamp = new DateTime(2015, 8, 30, 12, 36);
    var canonReq = snsReq.canonicalRequest;
    var expectedCanonicalRequest = "GET\n/\nParam1=value1&Param2=value2\nhost:example.amazonaws.com\nx-amz-date:20150830T123600Z\n\nhost;x-amz-date\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";
    expect(canonReq, expectedCanonicalRequest);

    var expectedStringToSign = "AWS4-HMAC-SHA256\n20150830T123600Z\n20150830/us-east-1/service/aws4_request\n816cd5b414d056048ba4f7c5386d6e0533120fb1fcfa93762cf0fc39e2cf19e0";
    var actualStringToSign = snsReq.stringToSign;
    expect(actualStringToSign, expectedStringToSign);

    var expectedSignature = "b97d918cfa904a5beff61c982a1b6f458b799221646efd99d3219ec94cdf2500";
    expect(snsReq.signature, expectedSignature);

    var expectedAuthorizationHeader = "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-date, Signature=b97d918cfa904a5beff61c982a1b6f458b799221646efd99d3219ec94cdf2500";
    expect(snsReq.authorizationHeader, expectedAuthorizationHeader);
  });

  test("Post Vanilla", () {
    var snsReq = new SNSRequest()
      ..host = "example.amazonaws.com"
      ..service = "service"
      ..accessKey = "AKIDEXAMPLE"
      ..secretKey = "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY"
      ..region = "us-east-1"
      ..method = "POST"
      ..timestamp = new DateTime(2015, 8, 30, 12, 36);
    var canonReq = snsReq.canonicalRequest;
    var expectedCanonicalRequest = "POST\n/\n\nhost:example.amazonaws.com\nx-amz-date:20150830T123600Z\n\nhost;x-amz-date\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";
    expect(canonReq, expectedCanonicalRequest);

    var expectedStringToSign = "AWS4-HMAC-SHA256\n20150830T123600Z\n20150830/us-east-1/service/aws4_request\n553f88c9e4d10fc9e109e2aeb65f030801b70c2f6468faca261d401ae622fc87";
    var actualStringToSign = snsReq.stringToSign;
    expect(actualStringToSign, expectedStringToSign);

    var expectedSignature = "5da7c1a2acd57cee7505fc6676e4e544621c30862966e37dddb68e92efbe5d6b";
    expect(snsReq.signature, expectedSignature);

    var expectedAuthorizationHeader = "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-date, Signature=5da7c1a2acd57cee7505fc6676e4e544621c30862966e37dddb68e92efbe5d6b";
    expect(snsReq.authorizationHeader, expectedAuthorizationHeader);
  });

  test("Post Vanilla Query", () {
    var snsReq = new SNSRequest()
      ..host = "example.amazonaws.com"
      ..service = "service"
      ..accessKey = "AKIDEXAMPLE"
      ..secretKey = "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY"
      ..region = "us-east-1"
      ..queryParameters = {"Param1" : "value1"}
      ..method = "POST"
      ..timestamp = new DateTime(2015, 8, 30, 12, 36);
    var canonReq = snsReq.canonicalRequest;
    var expectedCanonicalRequest = "POST\n/\nParam1=value1\nhost:example.amazonaws.com\nx-amz-date:20150830T123600Z\n\nhost;x-amz-date\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";
    expect(canonReq, expectedCanonicalRequest);

    var expectedStringToSign = "AWS4-HMAC-SHA256\n20150830T123600Z\n20150830/us-east-1/service/aws4_request\n9d659678c1756bb3113e2ce898845a0a79dbbc57b740555917687f1b3340fbbd";
    var actualStringToSign = snsReq.stringToSign;
    expect(actualStringToSign, expectedStringToSign);

    var expectedSignature = "28038455d6de14eafc1f9222cf5aa6f1a96197d7deb8263271d420d138af7f11";
    expect(snsReq.signature, expectedSignature);

    var expectedAuthorizationHeader = "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-date, Signature=28038455d6de14eafc1f9222cf5aa6f1a96197d7deb8263271d420d138af7f11";
    expect(snsReq.authorizationHeader, expectedAuthorizationHeader);
  });

  test("Post Vanilla x-www-form-urlencoded", () {
    var snsReq = new SNSRequest()
      ..host = "example.amazonaws.com"
      ..service = "service"
      ..accessKey = "AKIDEXAMPLE"
      ..secretKey = "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY"
      ..region = "us-east-1"
      ..method = "POST"
      ..timestamp = new DateTime(2015, 8, 30, 12, 36)
      ..requestBody = "Param1=value1";

    snsReq.headers["Content-Type"] = "application/x-www-form-urlencoded";

    var canonReq = snsReq.canonicalRequest;
    var expectedCanonicalRequest = "POST\n/\n\ncontent-type:application/x-www-form-urlencoded\nhost:example.amazonaws.com\nx-amz-date:20150830T123600Z\n\ncontent-type;host;x-amz-date\n9095672bbd1f56dfc5b65f3e153adc8731a4a654192329106275f4c7b24d0b6e";
    expect(canonReq, expectedCanonicalRequest);

    var expectedStringToSign = "AWS4-HMAC-SHA256\n20150830T123600Z\n20150830/us-east-1/service/aws4_request\n42a5e5bb34198acb3e84da4f085bb7927f2bc277ca766e6d19c73c2154021281";
    var actualStringToSign = snsReq.stringToSign;
    expect(actualStringToSign, expectedStringToSign);

    var expectedSignature = "ff11897932ad3f4e8b18135d722051e5ac45fc38421b1da7b9d196a0fe09473a";
    expect(snsReq.signature, expectedSignature);

    var expectedAuthorizationHeader = "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=content-type;host;x-amz-date, Signature=ff11897932ad3f4e8b18135d722051e5ac45fc38421b1da7b9d196a0fe09473a";
    expect(snsReq.authorizationHeader, expectedAuthorizationHeader);
  });

  test("Post Vanilla x-www-form-urlencoded parameters", () {
    var snsReq = new SNSRequest()
      ..host = "example.amazonaws.com"
      ..service = "service"
      ..accessKey = "AKIDEXAMPLE"
      ..secretKey = "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY"
      ..region = "us-east-1"
      ..method = "POST"
      ..timestamp = new DateTime(2015, 8, 30, 12, 36)
      ..requestBody = "Param1=value1";

    snsReq.headers["Content-Type"] = "application/x-www-form-urlencoded; charset=utf8";

    var canonReq = snsReq.canonicalRequest;
    var expectedCanonicalRequest = "POST\n/\n\ncontent-type:application/x-www-form-urlencoded; charset=utf8\nhost:example.amazonaws.com\nx-amz-date:20150830T123600Z\n\ncontent-type;host;x-amz-date\n9095672bbd1f56dfc5b65f3e153adc8731a4a654192329106275f4c7b24d0b6e";
    expect(canonReq, expectedCanonicalRequest);

    var expectedStringToSign = "AWS4-HMAC-SHA256\n20150830T123600Z\n20150830/us-east-1/service/aws4_request\n2e1cf7ed91881a30569e46552437e4156c823447bf1781b921b5d486c568dd1c";
    var actualStringToSign = snsReq.stringToSign;
    expect(actualStringToSign, expectedStringToSign);

    var expectedSignature = "1a72ec8f64bd914b0e42e42607c7fbce7fb2c7465f63e3092b3b0d39fa77a6fe";
    expect(snsReq.signature, expectedSignature);

    var expectedAuthorizationHeader = "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=content-type;host;x-amz-date, Signature=1a72ec8f64bd914b0e42e42607c7fbce7fb2c7465f63e3092b3b0d39fa77a6fe";
    expect(snsReq.authorizationHeader, expectedAuthorizationHeader);
  });
}