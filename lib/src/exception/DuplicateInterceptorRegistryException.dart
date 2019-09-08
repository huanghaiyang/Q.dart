import 'dart:mirrors';

import 'package:Q/src/interceptor/AbstractInterceptor.dart';

class DuplicateInterceptorRegistryException extends Exception {
  factory DuplicateInterceptorRegistryException({String message, AbstractInterceptor interceptor}) =>
      _DuplicateInterceptorRegistryException(message: message, interceptor: interceptor);
}

class _DuplicateInterceptorRegistryException implements DuplicateInterceptorRegistryException {
  final message;

  final AbstractInterceptor interceptor;

  _DuplicateInterceptorRegistryException({this.message, this.interceptor});

  String toString() {
    if (message == null)
      return "Exception: duplicate interceptor [${reflect(interceptor).type.reflectedType.toString()}] registry to the HttpRequestInterceptorChain";
    return "Exception: $message";
  }
}
