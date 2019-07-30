import 'package:Q/src/Method.dart';

class HttpMethodHelper {
  static bool checkValidMethod(HttpMethod methodName) {
    return HttpMethod.values.contains(methodName);
  }

  static String getMethodName(HttpMethod httpMethod) {
    return httpMethod.toString().replaceFirst(RegExp("HttpMethod\."), "");
  }
}
