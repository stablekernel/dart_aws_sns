part of aws_dart;

class SESClient {
  String accessKey;
  String secretKey;

  Future<bool> sendEmail(Email email, Stuff stuff) async {
    var req = new SESRequest()
      ..method = "POST"
      ..region = stuff.region
      ..service = stuff.service
      ..accessKey = accessKey
      ..secretKey = secretKey
      ..host = stuff.host;
    req.headers["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8";

    var values = {
      "Action" : "SendEmail",
      "Source" : email.source,
      "Destination.ToAddresses.1" : email.destination.toAddresses.first,
      "Message.Body.Text.Data" : email.message.body.text.data,
      "Subject.Text.Data" : email.message.subject.data
    };

    req.requestBody = values.keys.map((k) {
      return "$k=${Uri.encodeQueryComponent(values[k])}";
    }).join("&");

    var response = await req.execute();
    if (response.statusCode != 200) {
      throw new ClientException(response.statusCode, response.body);
    }
    return true;
  }
}