class RequiredMethodNotFoundException extends Exception {
  factory RequiredMethodNotFoundException({String message, String name}) => _RequiredMethodNotFoundException(message: message, name: name);
}

class _RequiredMethodNotFoundException implements RequiredMethodNotFoundException {
  final message;

  final String name;

  _RequiredMethodNotFoundException({this.message, this.name});

  String toString() {
    if (message == null) return "Exception: required method not found: '${this.name}'";
    return "Exception: $message";
  }
}
