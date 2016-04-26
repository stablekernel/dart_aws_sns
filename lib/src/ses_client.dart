part of aws_dart;

class SESClient extends AWSClient {
  EmailOptions options = new EmailOptions();

  /// Successful response [value] is a Map with the key messageID.
  Future<AWSResponse> sendEmail(Email email) async {
    var emailMap = email.asMap();
    emailMap["Action"] = "SendEmail";
    var result = await executeRequest(options.newRequest(emailMap));

    var endpointArn = result.resultXMLElement?.
    children?.firstWhere((n) => n is xml.XmlElement && n.name.local == "MessageId")?.text;
    result.value = {"messageID" : endpointArn};

    return result;
  }
}