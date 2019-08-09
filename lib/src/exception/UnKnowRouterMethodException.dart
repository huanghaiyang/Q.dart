import 'package:Q/src/Method.dart';

class UnKnowRouterMethodException extends Exception {
  factory UnKnowRouterMethodException({String message, HttpMethod method}) =>
      _UnKnowRouterMethodException(message: message, method: method);
}

class _UnKnowRouterMethodException implements UnKnowRouterMethodException {
  final message;

  final HttpMethod method;

  _UnKnowRouterMethodException({this.message, this.method});

  String toString() {
    if (message == null) return "Exception: method '${this.method.toString()}' unknown";
    return "Exception: $message";
  }
}
