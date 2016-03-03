part of aws_dart;

abstract class AWSClient {
  String accessKey;
  String secretKey;
}

class ClientException implements Exception {
  String message;
  int statusCode;
  ClientException(this.statusCode, this.message);

  String toString() {
    return "SNSClientException: $statusCode $message";
  }
}
