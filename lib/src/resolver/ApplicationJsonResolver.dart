import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Q/src/Request.dart';
import 'package:Q/src/exception/UnExpectedRequestJsonException.dart';
import 'package:Q/src/resolver/AbstractResolver.dart';
import 'package:Q/src/utils/ListUtil.dart';

class JsonResolver extends AbstractResolver {
  JsonResolver._();

  static JsonResolver _instance;

  static JsonResolver getInstance() {
    if (_instance == null) {
      _instance = JsonResolver._();
    }
    return _instance;
  }

  @override
  Future<bool> match(HttpRequest req) async {
    ContentType contentType = req.headers.contentType;
    if (contentType == null) return false;
    return contentType.mimeType
        .toLowerCase()
        .startsWith(RegExp(ContentType.json.mimeType));
  }

  @override
  Future<Request> resolve(HttpRequest req) async {
    String json_text = String.fromCharCodes(concat(await req.toList()));
    try {
      Map data = await jsonDecode(json_text);
      Request request = Request(data: data);
      return request;
    } catch (error) {
      throw UnExpectedRequestJsonException(
          json: json_text, originalException: error);
    }
  }
}