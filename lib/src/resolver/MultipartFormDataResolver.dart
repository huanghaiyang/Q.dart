import 'dart:async';
import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/Request.dart';
import 'package:Q/src/configure/MultipartConfigure.dart';
import 'package:Q/src/exception/MaxUploadSizeExceededException.dart';
import 'package:Q/src/multipart/MultipartTransformer.dart';
import 'package:Q/src/multipart/MultipartValueMap.dart';
import 'package:Q/src/query/MultipartFile.dart';
import 'package:Q/src/query/Value.dart';
import 'package:Q/src/resolver/AbstractResolver.dart';
import 'package:Q/src/utils/ListUtil.dart';

class MultipartResolver implements AbstractResolver {
  MultipartResolver._();

  static MultipartResolver _instance;

  static MultipartResolver instance() {
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
    MultipartConfigure multipartConfigure = Application.getApplicationContext().configuration.multipartConfigure;

    MultipartValueMap data = await transform(req, requestData, fixNameSuffixIfArray: multipartConfigure.fixNameSuffixIfArray);
    for (List<Value> values in data.values) {
      for (Value value in values) {
        if (value is MultipartFile) {
          if (multipartConfigure.isExceeded(value.size)) {
            throw MaxUploadSizeExceededException(maxUploadSize: multipartConfigure.maxUploadSize, uploadSize: value.size);
          }
        }
      }
    }
    Request request = Request(data: data);
    return request;
  }
}
