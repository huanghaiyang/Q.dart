class RequestParamRequiredException extends Exception {
  factory RequestParamRequiredException({String message, String name}) => _RequestParamRequiredException(message: message, name: name);
}

class _RequestParamRequiredException implements RequestParamRequiredException {
  final message;

  final String name;

  _RequestParamRequiredException({this.message, this.name});

  String toString() {
    if (message == null) return "Exception: request params must be contains '${this.name}'";
    return "Exception: $message";
  }
}
