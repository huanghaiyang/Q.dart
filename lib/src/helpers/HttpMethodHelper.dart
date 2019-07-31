import 'package:Q/src/Method.dart';

String HTTP_METHOD_PREFIX = 'HttpMethod\.';

Pattern HTTP_METHOD_PREFIX_PATTERN = RegExp(HTTP_METHOD_PREFIX);

class HttpMethodHelper {
  static bool checkValidMethod(HttpMethod methodName) {
    return HttpMethod.values.contains(methodName);
  }

  static String getMethodName(HttpMethod httpMethod) {
    return httpMethod.toString().replaceFirst(HTTP_METHOD_PREFIX_PATTERN, "");
  }

  static HttpMethod fromMethod(String methodName) {
    switch (methodName.toUpperCase()) {
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
