import 'dart:io';

class ContentTypeUtil {
  static ContentType reflect(ContentType type) {
    String code = type.toString();
    if (code == ContentType.json.toString()) {
      return ContentType.json;
    } else if (code == ContentType.html.toString()) {
      return ContentType.html;
    } else if (code == ContentType.binary.toString()) {
      return ContentType.binary;
    } else if (code == ContentType.text.toString()) {
      return ContentType.text;
    }
    return type;
  }
}
