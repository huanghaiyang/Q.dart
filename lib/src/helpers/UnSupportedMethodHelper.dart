import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/Method.dart';
import 'package:Q/src/helpers/HttpMethodHelper.dart';

class UnSupportedMethodHelper {
  static bool checkSupported(HttpRequest req) {
    var applicationContext = Application.getApplicationContext();
    var allowedMethods = applicationContext?.configuration?.httpRequestConfigure?.allowedMethods;
    if (allowedMethods == null || allowedMethods.isEmpty) return true;
    return allowedMethods.indexWhere((method) => HttpMethodHelper.getMethodName(method) == req.method.toUpperCase()) >= 0;
  }
}
