class UnExpectedRequestXmlException extends Exception {
  factory UnExpectedRequestXmlException({String message, String xml, Exception originalException}) =>
      _UnExpectedRequestXmlException(message: message, xml: xml, originalException: originalException);
}

class _UnExpectedRequestXmlException implements UnExpectedRequestXmlException {
  final message;

  final String xml;

  final Exception originalException;

  _UnExpectedRequestXmlException({this.message, this.xml, this.originalException});

  String toString() {
    if (message == null) return "Exception: request xml '${this.xml}' is invalid";
    return "Exception: $message";
  }
}
