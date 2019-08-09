import 'package:Q/src/Method.dart';
import 'package:Q/src/helpers/HttpMethodHelper.dart';

class UnSupportedRequestMethodException extends Exception {
  factory UnSupportedRequestMethodException({String message, HttpMethod method}) =>
      _UnSupportedRequestMethodException(message: message, method: method);
}

class _UnSupportedRequestMethodException implements UnSupportedRequestMethodException {
  final String message;
  final HttpMethod method;

  _UnSupportedRequestMethodException({this.message, this.method});

  String toString() {
    if (message == null) return "Exception: 服务器禁止${HttpMethodHelper.getMethodName(this.method)}请求类型访问";
    return "Exception: $message";
  }
}
