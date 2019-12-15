import 'dart:mirrors';

import 'package:Q/src/Router.dart';

class RawBodyHelper {
  static Future<dynamic> reflect(Router router, ParameterMirror parameterMirror, InstanceMirror annotationMirror) async {
    if (annotationMirror != null) {
      return router?.context?.request?.data;
    }
  }
}
