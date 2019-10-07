import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/Method.dart';
import 'package:Q/src/helpers/HttpMethodHelper.dart';

class UnSupportedMethodHelper {
  static bool checkSupported(HttpRequest req) {
    List<HttpMethod> unAllowedMethods = Application.getApplicationContext().configuration.httpRequestConfigure.unAllowedMethods;
    if (unAllowedMethods.isEmpty) return true;
    return unAllowedMethods.indexWhere((method) => HttpMethodHelper.getMethodName(method) == req.method.toUpperCase()) == -1;
  }
}
