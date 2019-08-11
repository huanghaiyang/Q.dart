import 'dart:async';
import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/Request.dart';
import 'package:Q/src/multipart/MultipartTransformer.dart';
import 'package:Q/src/multipart/MultipartValueMap.dart';
import 'package:Q/src/resolver/AbstractResolver.dart';
import 'package:Q/src/utils/ListUtil.dart';

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
    ContentType contentType = req.headers.contentType;
    if (contentType == null) return false;
    return contentType.mimeType.toLowerCase().startsWith(RegExp('multipart/form-data'));
  }

  // int i0, 13表示换行
  @override
  Future<Request> resolve(HttpRequest req) async {
    List<int> requestData = concat(await req.toList());
    MultipartValueMap data =
        await transform(req, requestData, Application.getApplicationContext().configuration.multipartConfigure.fixNameSuffixIfArray);
    Request request = Request(data: data);
    return request;
  }
}
