import 'dart:io';

import 'package:Q/src/Application.dart';

class UnSupportedContentTypeHelper {
  static bool checkSupported(HttpRequest req) {
    List<ContentType> allowedContentType = Application.getApplicationContext().configuration.httpRequestConfigure.allowedContentTypes;
    if (allowedContentType.isEmpty) return true;
    return allowedContentType.indexWhere((contentType) => contentType.mimeType == req.headers.contentType.mimeType) >= 0;
  }
}
