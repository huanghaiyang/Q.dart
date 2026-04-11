import 'dart:io';

import 'package:Q/src/Application.dart';

class UnSupportedContentTypeHelper {
  static bool checkSupported(HttpRequest req) {
    var applicationContext = Application.getApplicationContext();
    var allowedContentType = applicationContext?.configuration?.httpRequestConfigure?.allowedContentTypes;
    if (allowedContentType == null || allowedContentType.isEmpty) return true;
    return allowedContentType.indexWhere((contentType) => contentType.mimeType == req.headers.contentType?.mimeType) >= 0;
  }
}
