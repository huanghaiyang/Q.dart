import 'dart:async';
import 'dart:io';

import 'package:Q/src/Request.dart';
import 'package:Q/src/multipart/MultiValueMap.dart';
import 'package:Q/src/multipart/MultipartTransformer.dart';
import 'package:Q/src/resolver/AbstractResolver.dart';

class MultipartResolver extends AbstractResolver {
  MultipartResolver._();

  static MultipartResolver _instance;

  static MultipartResolver getInstance() {
    if (_instance == null) {
      _instance = MultipartResolver._();
    }
    return _instance;
  }

  @override
  Future<bool> match(HttpRequest req) async {
    return req.headers.contentType.mimeType.toLowerCase().startsWith(RegExp('multipart/form-data'));
  }

  // int i0, 13表示换行
  @override
  Future<Request> resolve(HttpRequest req) async {
    List<int> requestData = concat(await req.toList());
    MultiValueMap data = await transform(req, requestData);
    Request request = Request(data: data);
    return request;
  }
}
