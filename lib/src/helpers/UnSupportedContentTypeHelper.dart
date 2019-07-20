import 'dart:io';

import 'package:Q/src/ApplicationContext.dart';

class UnSupportedContentTypeHelper {
  static bool checkSupported(HttpRequest req) {
    List<ContentType> unSupportedContentTypes = ApplicationContext.getInstance().configuration.unSupportedContentTypes;
    if (unSupportedContentTypes.isEmpty) return true;
    return unSupportedContentTypes.indexWhere((contentType) => contentType.mimeType == req.headers.contentType.mimeType) == -1;
  }
}
