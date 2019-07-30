import 'dart:io';

import 'package:Q/src/Application.dart';

class UnSupportedMethodHelper {
  static bool checkSupported(HttpRequest req) {
    List<String> unSupportedMethods = Application.getApplicationContext().configuration.unSupportedMethods;
    if (unSupportedMethods.isEmpty) return true;
    return unSupportedMethods.indexWhere((method) => method.toLowerCase() == req.method.toLowerCase()) == -1;
  }
}
