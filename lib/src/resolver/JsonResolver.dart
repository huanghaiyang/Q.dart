import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Q/src/Request.dart';
import 'package:Q/src/resolver/AbstractResolver.dart';

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
    return req.headers.contentType.mimeType.toLowerCase().startsWith(RegExp(ContentType.json.mimeType));
  }

  @override
  Future<Request> resolve(HttpRequest req) async {
    Converter<List<int>, Object> decoder = json.fuse(utf8).decoder;
    Map data = await decoder.bind(req).single;
    Request request = Request(data: data);
    return request;
  }
}
