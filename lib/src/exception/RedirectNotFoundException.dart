class RedirectNotFoundException extends Exception {
  factory RedirectNotFoundException({String message}) => _RedirectNotFoundException(message: message);
}

class _RedirectNotFoundException implements RedirectNotFoundException {
  final message;

  _RedirectNotFoundException({this.message});

  String toString() {
    if (message == null) return "Exception";
    return "Exception: $message";
  }
}
