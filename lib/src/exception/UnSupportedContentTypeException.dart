class UnSupportedContentTypeException extends Exception {
  factory UnSupportedContentTypeException([var message]) => _UnSupportedContentTypeException(message);
}

class _UnSupportedContentTypeException implements UnSupportedContentTypeException {
  final message;

  _UnSupportedContentTypeException([this.message]);

  String toString() {
    if (message == null) return "Exception";
    return "Exception: $message";
  }
}
