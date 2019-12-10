class InstanceMemberTypeNotMatchException extends Exception {
  factory InstanceMemberTypeNotMatchException({String message, String name}) =>
      _InstanceMemberTypeNotMatchException(message: message, name: name);
}

class _InstanceMemberTypeNotMatchException implements InstanceMemberTypeNotMatchException {
  final message;

  final String name;

  _InstanceMemberTypeNotMatchException({this.message, this.name});

  String toString() {
    if (message == null) return "Exception: instance member type not match: '${this.name}'";
    return "Exception: $message";
  }
}
