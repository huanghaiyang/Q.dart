class UnExpectedRequestApplicationJsonException extends Exception {
  factory UnExpectedRequestApplicationJsonException({String message, String json, Exception originalException}) =>
      _UnExpectedRequestApplicationJsonException(message: message, json: json, originalException: originalException);
}

class _UnExpectedRequestApplicationJsonException implements UnExpectedRequestApplicationJsonException {
  final message;

  final String json;

  final Exception originalException;

  _UnExpectedRequestApplicationJsonException({this.message, this.json, this.originalException});

  String toString() {
    if (message == null) return "Exception: request json '${this.json}' is invalid";
    return "Exception: $message";
  }
}
