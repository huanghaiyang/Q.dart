import 'dart:io';

import 'package:Q/src/Request.dart';
import 'package:Q/src/resolver/AbstractResolver.dart';
import 'package:Q/src/utils/RequestUtil.dart';

class TextResolver implements AbstractResolver {
  TextResolver._();

  static TextResolver _instance;

  static TextResolver instance() {
    return _instance ?? (_instance = TextResolver._());
  }

  @override
  Future<bool> match(HttpRequest req) async {
    ContentType contentType = req.headers.contentType;
    if (contentType == null) return false;
    return contentType.mimeType.toLowerCase().startsWith(RegExp('text/plain'));
  }

  @override
  Future<Request> resolve(HttpRequest req) async {
    String text = await RequestUtil.getRequestBodyString(req);
    Request request = Request(data: {'text': text});
    return request;
  }
}
