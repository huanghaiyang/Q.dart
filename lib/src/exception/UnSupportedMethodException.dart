import 'package:Q/src/Method.dart';
import 'package:Q/src/helpers/HttpMethodHelper.dart';

class UnSupportedMethodException extends Exception {
  factory UnSupportedMethodException({String message, HttpMethod method}) =>
      _UnSupportedMethodException(message: message, method: method);
}

class _UnSupportedMethodException implements UnSupportedMethodException {
  final String message;
  final HttpMethod method;

  _UnSupportedMethodException({this.message, this.method});

  String toString() {
    if (message == null) return "Exception: 服务器禁止${HttpMethodHelper.getMethodName(this.method)}请求类型访问";
    return "Exception: $message";
  }
}
