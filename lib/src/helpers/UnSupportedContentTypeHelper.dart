import 'dart:io';

import 'package:Q/src/Application.dart';

class UnSupportedContentTypeHelper {
  static bool checkSupported(HttpRequest req) {
    List<ContentType> unSupportedContentTypes = Application.getApplicationContext().configuration.unSupportedContentTypes;
    if (unSupportedContentTypes.isEmpty) return true;
    return unSupportedContentTypes.indexWhere((contentType) => contentType.mimeType == req.headers.contentType.mimeType) == -1;
  }
}
