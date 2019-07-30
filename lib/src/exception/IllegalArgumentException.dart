class IllegalArgumentException extends Exception {
  factory IllegalArgumentException({String message, dynamic argument}) => _IllegalArgumentException(message: message, argument: argument);
}

class _IllegalArgumentException implements IllegalArgumentException {
  final message;

  final dynamic argument;

  _IllegalArgumentException({this.message, this.argument});

  String toString() {
    if (message == null) return "Exception: Bad argument '${this.argument.toString()}'";
    return "Exception: $message";
  }
}
