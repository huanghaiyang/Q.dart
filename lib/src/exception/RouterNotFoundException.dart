class RouterNotFoundException extends Exception {
  factory RouterNotFoundException([var message]) => _RouterNotFoundException(message);
}

class _RouterNotFoundException implements RouterNotFoundException {
  final message;

  _RouterNotFoundException([this.message]);

  String toString() {
    if (message == null) return "Exception";
    return "Exception: $message";
  }
}
