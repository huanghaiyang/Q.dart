import 'dart:io';

class RouterNotFoundException extends Exception {
  factory RouterNotFoundException([var message]) => _RouterNotFoundException(message);
  factory RouterNotFoundException.withRequest(HttpRequest request) => _RouterNotFoundException.withRequest(request);
}

class _RouterNotFoundException implements RouterNotFoundException {
  final message;
  final HttpRequest request;

  _RouterNotFoundException([this.message, this.request]);
  
  _RouterNotFoundException.withRequest(HttpRequest request) : 
    this.message = null,
    this.request = request;

  String toString() {
    if (request != null) {
      return "RouterNotFoundException: No router found for ${request.method} ${request.uri.path}";
    }
    if (message == null) return "RouterNotFoundException";
    return "RouterNotFoundException: $message";
  }
}
