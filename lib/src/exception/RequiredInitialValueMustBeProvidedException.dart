class RequiredInitialValueMustBeProvidedException extends Exception {
  factory RequiredInitialValueMustBeProvidedException({String message, String name}) =>
      _RequiredInitialValueMustBeProvidedException(message: message, name: name);
}

class _RequiredInitialValueMustBeProvidedException implements RequiredInitialValueMustBeProvidedException {
  final message;

  final String name;

  _RequiredInitialValueMustBeProvidedException({this.message, this.name});

  String toString() {
    if (message == null) return "Exception: required initial value must be provided: '${this.name}'";
    return "Exception: $message";
  }
}
