import 'dart:mirrors';

import 'package:Q/src/Router.dart';
import 'package:Q/src/annotation/Request.dart';

class RequestHelper {
  // 通过反射获取使用Request注解的参数
  static Future<dynamic> reflectRequest(Router router, ParameterMirror parameterMirror, InstanceMirror annotationMirror) async {
    if (annotationMirror != null) {
      return router.context.request;
    }
    return null;
  }
}