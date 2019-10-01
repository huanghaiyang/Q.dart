class SizeUnitParseException extends Exception {
  factory SizeUnitParseException({String message, String formattedString}) =>
      _SizeUnitParseException(message: message, formattedString: formattedString);
}

class _SizeUnitParseException implements SizeUnitParseException {
  final message;

  final String formattedString;

  _SizeUnitParseException({this.message, this.formattedString});

  String toString() {
    if (message == null) return "Exception: Can not parse '${this.formattedString}'";
    return "Exception: $message";
  }
}
