import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/Method.dart';
import 'package:Q/src/helpers/HttpMethodHelper.dart';

class UnSupportedMethodHelper {
  static bool checkSupported(HttpRequest req) {
    List<HttpMethod> allowedMethods = Application.getApplicationContext().configuration.httpRequestConfigure.allowedMethods;
    if (allowedMethods.isEmpty) return true;
    return allowedMethods.indexWhere((method) => HttpMethodHelper.getMethodName(method) == req.method.toUpperCase()) >= 0;
  }
}
