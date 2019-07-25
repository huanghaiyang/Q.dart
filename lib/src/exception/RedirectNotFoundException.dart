class RedirectNotFoundException extends Exception {
  factory RedirectNotFoundException([var message]) => _RedirectNotFoundException(message);
}

class _RedirectNotFoundException implements RedirectNotFoundException {
  final message;

  _RedirectNotFoundException([this.message]);

  String toString() {
    if (message == null) return "Exception";
    return "Exception: $message";
  }
}
