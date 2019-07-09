import 'dart:async';
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

  @override
  Future<Request> resolve(HttpRequest req) async {
    req.listen((List<int> bytes) {
      print(bytes);
    }, onDone: () {
      print('done');
    }, onError: (error) {
      print(error);
    }, cancelOnError: true);
    MultipartRequest multipartRequest = MultipartRequest();
    return multipartRequest;
  }
}
