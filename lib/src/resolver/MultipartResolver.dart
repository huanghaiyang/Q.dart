import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Q/src/MultipartRequest.dart';
import 'package:Q/src/Request.dart';
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
  Future<bool> isMe(HttpRequest req) async {
    return req.headers.contentType.mimeType
        .toLowerCase()
        .startsWith(RegExp('multipart/form-data'));
  }

  // int i0, 13表示换行
  @override
  Future<Request> resolve(HttpRequest req) async {
    req.listen((List<int> data) {
      // TODO transform
      print(String.fromCharCodes(data));
    });
    MultipartRequest multipartRequest = MultipartRequest();
    return multipartRequest;
  }
}
