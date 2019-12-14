class RequiredFieldNotFoundException extends Exception {
  factory RequiredFieldNotFoundException({String message, String name}) => _RequiredFieldNotFoundException(message: message, name: name);
}

class _RequiredFieldNotFoundException implements RequiredFieldNotFoundException {
  final message;

  final String name;

  _RequiredFieldNotFoundException({this.message, this.name});

  String toString() {
    if (message == null) return "Exception: required field not found: '${this.name}'";
    return "Exception: $message";
  }
}
