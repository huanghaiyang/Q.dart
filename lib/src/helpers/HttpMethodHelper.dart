import 'package:Q/src/Method.dart';

class HttpMethodHelper {
  static bool checkValidMethod(HttpMethod methodName) {
    return HttpMethod.values.contains(methodName);
  }

  static String getMethodName(HttpMethod httpMethod) {
    return httpMethod.toString().replaceFirst(RegExp("HttpMethod\."), "");
  }

  static HttpMethod fromMethod(String methodName) {
    methodName = methodName.toUpperCase();
    switch (methodName) {
      case 'GET':
        return HttpMethod.GET;
      case 'POST':
        return HttpMethod.POST;
      case 'PUT':
        return HttpMethod.PUT;
      case 'DELETE':
        return HttpMethod.DELETE;
      case 'OPTIONS':
        return HttpMethod.OPTIONS;
      case 'PATCH':
        return HttpMethod.PATCH;
      default:
        return null;
    }
  }
}
