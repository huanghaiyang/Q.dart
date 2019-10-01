class TimeUnitParseException extends Exception {
  factory TimeUnitParseException({String message, String formattedString}) =>
      _TimeUnitParseException(message: message, formattedString: formattedString);
}

class _TimeUnitParseException implements TimeUnitParseException {
  final message;

  final String formattedString;

  _TimeUnitParseException({this.message, this.formattedString});

  String toString() {
    if (message == null) return "Exception: Can not parse '${this.formattedString}'";
    return "Exception: $message";
  }
}
