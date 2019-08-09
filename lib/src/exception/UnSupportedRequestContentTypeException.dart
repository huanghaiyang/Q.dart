import 'dart:io';

class UnSupportedRequestContentTypeException extends Exception {
  factory UnSupportedRequestContentTypeException({String message, ContentType contentType}) =>
      _UnSupportedRequestContentTypeException(message: message, contentType: contentType);
}

class _UnSupportedRequestContentTypeException implements UnSupportedRequestContentTypeException {
  final String message;
  final ContentType contentType;

  _UnSupportedRequestContentTypeException({this.message, this.contentType});

  String toString() {
    if (message == null) return "Exception: 服务器禁止${contentType.value}类型数据访问";
    return "Exception: $message";
  }
}
