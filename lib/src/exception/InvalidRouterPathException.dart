class InvalidRouterPathException extends Exception {
  factory InvalidRouterPathException({String message, String path}) =>
      _InvalidRouterPathException(message: message, path: path);
}

class _InvalidRouterPathException implements InvalidRouterPathException {
  final message;

  final String path;

  _InvalidRouterPathException({this.message, this.path});

  String toString() {
    if (message == null) return "Exception: router path '${this.path}' is invalid";
    return "Exception: $message";
  }
}
