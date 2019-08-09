import 'dart:mirrors';

import 'package:Q/src/Router.dart';

class UnSupportRouterHandlerParameterAnnotationException extends Exception {
  factory UnSupportRouterHandlerParameterAnnotationException(
          {String message, Router router, Type annotation}) =>
      _UnSupportRouterHandlerParameterAnnotationException(
          message: message, router: router, annotation: annotation);
}

class _UnSupportRouterHandlerParameterAnnotationException
    implements UnSupportRouterHandlerParameterAnnotationException {
  final String message;

  final Router router;

  final Type annotation;

  _UnSupportRouterHandlerParameterAnnotationException({this.message, this.router, this.annotation});

  String toString() {
    if (message == null) {
      String annotationName = MirrorSystem.getName(reflectClass(annotation).qualifiedName);
      String path = router.path;
      return "Exception: The handler of router [$path] include unsupoprt parameter annotation : [$annotationName]";
    }
    return "Exception: $message";
  }
}
