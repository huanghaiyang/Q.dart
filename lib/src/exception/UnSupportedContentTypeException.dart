import 'dart:io';

class UnSupportedContentTypeException extends Exception {
  factory UnSupportedContentTypeException({String message, ContentType contentType}) => _UnSupportedContentTypeException(message: message, contentType: contentType);
}

class _UnSupportedContentTypeException implements UnSupportedContentTypeException {
  final String message;
  final ContentType contentType;

  _UnSupportedContentTypeException({this.message, this.contentType});

  String toString() {
    if (message == null) return "Exception: 服务器禁止${contentType.value}类型数据访问";
    return "Exception: $message";
  }
}
