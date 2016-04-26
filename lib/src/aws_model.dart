part of aws_dart;

abstract class ApplicationResource {
  String region;

  String get service;
  String get host;

  ApplicationResource();
  ApplicationResource.inRegion(this.region);

  AWSRequest newRequest(Map<String, dynamic> values) {
    var req = new AWSRequest()
      ..method = "POST"
      ..region = region
      ..service = service
      ..host = host;
    req.headers["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8";

    req.requestBody = values.keys.map((k) {
      return "$k=${Uri.encodeQueryComponent(values[k])}";
    }).join("&");

    return req;
  }
}
