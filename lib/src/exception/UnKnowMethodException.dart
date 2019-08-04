import 'package:Q/src/Method.dart';

class UnKnowMethodException extends Exception {
  factory UnKnowMethodException({String message, HttpMethod method}) =>
      _UnKnowMethodException(message: message, method: method);
}

class _UnKnowMethodException implements UnKnowMethodException {
  final message;

  final HttpMethod method;

  _UnKnowMethodException({this.message, this.method});

  String toString() {
    if (message == null) return "Exception: method '${this.method.toString()}' unknown";
    return "Exception: $message";
  }
}
