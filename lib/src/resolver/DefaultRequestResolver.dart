import 'dart:io';

import 'package:Q/src/Request.dart';
import 'package:Q/src/resolver/AbstractResolver.dart';

class DefaultRequestResolver implements AbstractResolver {
  DefaultRequestResolver._();

  static DefaultRequestResolver _instance;

  static DefaultRequestResolver instance() {
    if (_instance == null) {
      _instance = DefaultRequestResolver._();
    }
    return _instance;
  }

  @override
  Future<Request> resolve(HttpRequest req) async {
    return Request();
  }

  @override
  Future<bool> match(HttpRequest req) async {
    ContentType contentType = req.headers.contentType;
    return contentType == null;
  }
}
