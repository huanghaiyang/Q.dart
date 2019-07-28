import 'package:Q/src/Method.dart';

class HttpMethodHelper {
  static bool checkValidMethod(String methodName) {
    return METHODS.contains(methodName);
  }
}
