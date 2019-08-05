class UnExpectedRequestJsonException extends Exception {
  factory UnExpectedRequestJsonException(
          {String message, String json, Exception originalException}) =>
      _UnExpectedRequestJsonException(
          message: message, json: json, originalException: originalException);
}

class _UnExpectedRequestJsonException
    implements UnExpectedRequestJsonException {
  final message;

  final String json;

  final Exception originalException;

  _UnExpectedRequestJsonException(
      {this.message, this.json, this.originalException});

  String toString() {
    if (message == null)
      return "Exception: request json '${this.json}' is invalid";
    return "Exception: $message";
  }
}
