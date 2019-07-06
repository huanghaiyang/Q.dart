import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/Context.dart';
import 'package:Q/src/MimeTypes.dart';
import 'package:Q/src/Request.dart';
import 'package:Q/src/ResponseEntry.dart';

class Response {
  Application app;
  HttpResponse res;
  Request request;
  Context ctx;
  ResponseEntry responseEntry;

  // 默认请求返回的格式
  MimeTypes mimeType = MimeTypes.JSON;

  Response([this.app, this.res, this.request, this.ctx]);

  void onerror(Error error) async {}
}
