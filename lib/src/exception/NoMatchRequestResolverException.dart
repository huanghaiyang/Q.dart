import 'dart:io';

class NoMatchRequestResolverException extends Exception {
  factory NoMatchRequestResolverException({String message, ContentType contentType}) =>
      _NoMatchRequestResolverException(message: message, contentType: contentType);
}

class _NoMatchRequestResolverException implements NoMatchRequestResolverException {
  final String message;

  final ContentType contentType;

  _NoMatchRequestResolverException({this.message, this.contentType});

  String toString() {
    if (message == null) {
      String mimeType = this.contentType == null ? '' : this.contentType.toString();
      return "Exception: no match http request resolver for content-type '${mimeType}'.";
    }
    return "Exception: $message";
  }
}
