class RequiredAnnotationNotFoundException extends Exception {
  factory RequiredAnnotationNotFoundException({String message, String name}) =>
      _RequiredAnnotationNotFoundException(message: message, name: name);
}

class _RequiredAnnotationNotFoundException implements RequiredAnnotationNotFoundException {
  final message;

  final String name;

  _RequiredAnnotationNotFoundException({this.message, this.name});

  String toString() {
    if (message == null) return "Exception: required annotation not found: '${this.name}'";
    return "Exception: $message";
  }
}
