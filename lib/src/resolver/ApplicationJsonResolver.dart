import 'dart:convert';
import 'dart:io';

import 'package:Q/src/Request.dart';
import 'package:Q/src/exception/UnExpectedRequestApplicationJsonException.dart';
import 'package:Q/src/resolver/AbstractResolver.dart';
import 'package:Q/src/utils/RequestUtil.dart';

class JsonResolver implements AbstractResolver {
  JsonResolver._();

  static JsonResolver _instance;

  static JsonResolver instance() {
    return _instance ?? (_instance = JsonResolver._());
  }

  @override
  Future<bool> match(HttpRequest req) async {
    ContentType contentType = req.headers.contentType;
    if (contentType == null) return false;
    return contentType.mimeType.toLowerCase().startsWith(RegExp(ContentType.json.mimeType));
  }

  @override
  Future<Request> resolve(HttpRequest req) async {
    String jsonText = await RequestUtil.getRequestBodyString(req);
    try {
      Map data = await jsonDecode(jsonText);
      Request request = Request(data: data);
      return request;
    } catch (error) {
      throw UnExpectedRequestApplicationJsonException(json: jsonText, originalException: error);
    }
  }
}
