import 'dart:mirrors';

import 'package:Q/src/Router.dart';
import 'package:Q/src/helpers/reflect/ClassTransformer.dart';

class BodyReflectHelper {
  // 通过反射获取使用RequestParam注解的参数
  static Future<dynamic> reflectBody(Router router, ParameterMirror parameterMirror, InstanceMirror annotationMirror) async {
    if (annotationMirror != null) {
      Map data = router?.context?.request?.data;
      if (data == null) return null;
      return ClassTransformer.fromMap(data, parameterMirror.type.reflectedType);
    }
  }
}
