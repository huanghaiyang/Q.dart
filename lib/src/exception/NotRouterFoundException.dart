class NotRouterFoundException extends Exception {
  factory NotRouterFoundException([var message]) =>
      _NotRouterFoundException(message);
}

class _NotRouterFoundException implements NotRouterFoundException {
  final message;

  _NotRouterFoundException([this.message]);

  String toString() {
    if (message == null) return "Exception";
    return "Exception: $message";
  }
}
