import 'dart:mirrors';

class ReflectHelper {
  static dynamic reflectParameterValue(ParameterMirror parameterMirror, String value) {
    dynamic result;
    switch (parameterMirror.type.reflectedType) {
      case int:
        result = int.parse(value);
        break;
      case String:
        result = value;
        break;
      case bool:
        result = bool.fromEnvironment(value);
        break;
      case BigInt:
        result = BigInt.from(num.parse(value));
        break;
      case DateTime:
        result = DateTime.parse(value);
        break;
      case double:
        result = double.parse(value);
        break;
      case num:
        result = num.parse(value);
        break;
      case Symbol:
        result = Symbol(value);
        break;
      default:
        break;
    }
    return result;
  }
}