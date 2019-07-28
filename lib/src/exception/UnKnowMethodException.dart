class UnKnowMethodException extends Exception {
  factory UnKnowMethodException({String message, String method}) => _UnKnowMethodException(message: message, method: method);
}

class _UnKnowMethodException implements UnKnowMethodException {
  final message;

  final String method;

  _UnKnowMethodException({this.message, this.method});

  String toString() {
    if (message == null) return "Exception: method '${this.method}' unknown";
    return "Exception: $message";
  }
}
