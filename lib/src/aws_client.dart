part of aws_dart;

abstract class AWSClient {
  static String IncompleteSignature = "IncompleteSignature";
  static String InternalFailure = "InternalFailure";
  static String InvalidAction = "InvalidAction";
  static String InvalidClientTokenId = "InvalidClientTokenId";
  static String InvalidParameterCombination = "InvalidParameterCombination";
  static String InvalidParameter= "InvalidParameter";
  static String InvalidParameterValue = "InvalidParameterValue";
  static String InvalidQueryParameter = "InvalidQueryParameter";
  static String MalformedQueryString = "MalformedQueryString";
  static String MissingAction = "MissingAction";
  static String MissingAuthenticationToken = "MissingAuthenticationToken";
  static String MissingParameter = "MissingParameter";
  static String OptInRequired = "OptInRequired";
  static String RequestExpired = "RequestExpired";
  static String ServiceUnavailable = "ServiceUnavailable";
  static String Throttling = "Throttling";
  static String ValidationError = "ValidationError";

  String accessKey;
  String secretKey;
}

class AWSException implements Exception {
  AWSException(this.statusCode, this.message, this.key);

  final int statusCode;
  final String message;
  final String key;

  String toString() {
    return "AWSException: $statusCode $key $message";
  }
}
