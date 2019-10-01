import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/Method.dart';
import 'package:Q/src/helpers/HttpMethodHelper.dart';

class UnSupportedMethodHelper {
  static bool checkSupported(HttpRequest req) {
    List<HttpMethod> unSupportedMethods = Application.getApplicationContext().configuration.httpRequestConfigure.unSupportedMethods;
    if (unSupportedMethods.isEmpty) return true;
    return unSupportedMethods.indexWhere((method) => HttpMethodHelper.getMethodName(method) == req.method.toUpperCase()) == -1;
  }
}
