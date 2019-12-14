import 'dart:io';

import 'package:Q/src/Application.dart';

class UnSupportedContentTypeHelper {
  static bool checkSupported(HttpRequest req) {
    List<ContentType> unAllowedContentTypes = Application.getApplicationContext().configuration.httpRequestConfigure.unAllowedContentTypes;
    if (unAllowedContentTypes.isEmpty) return true;
    return unAllowedContentTypes.indexWhere((contentType) => contentType.mimeType == req.headers.contentType.mimeType) == -1;
  }
}
