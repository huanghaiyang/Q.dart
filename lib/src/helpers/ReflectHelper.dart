import 'dart:mirrors';

typedef ParameterAnnotationCallback = void Function(ParameterMirror parameterMirror, InstanceMirror instanceMirror);

class ReflectHelper {
  static dynamic reflectParameterValue(Type type, String value) {
    dynamic result;
    switch (type) {
      case int:
        result = int.parse(value);
        break;
      case String:
        result = value;
        break;
      case bool:
        if (value == 'true') {
          result = true;
        } else if (value == 'false') {
          result = false;
        }
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
        result = value;
        break;
    }
    return result;
  }

  static dynamic reflectParameterValues(Type type, List<String> values) {
    Type subType;
    bool isCollection = false;
    List result = List();
    ClassMirror classMirror = reflectClass(type);
    if (classMirror == reflectClass(List) || classMirror == reflectClass(Set)) {
      isCollection = true;
      classMirror.declarations;
      reflectType(type).typeArguments.forEach((TypeMirror typeMirror) {
        subType = typeMirror.reflectedType;
      });
    } else {
      subType = type;
    }
    for (var value in values) {
      result.add(reflectParameterValue(subType, value));
    }
    if (isCollection) {
      return reflectCollection(type, subType, values);
    } else {
      return result[0];
    }
  }

  static dynamic reflectCollection(Type classType, Type argType, dynamic values) {
    ClassMirror classMirror = reflectClass(classType);
    if (classMirror == reflectClass(List)) {
      switch (argType) {
        case int:
          return List<int>.from(values);
        case String:
          return List<String>.from(values);
        case bool:
          return List<bool>.from(values);
        case BigInt:
          return List<BigInt>.from(values);
        case DateTime:
          return List<DateTime>.from(values);
        case double:
          return List<double>.from(values);
        case num:
          return List<num>.from(values);
        case Symbol:
          return List<Symbol>.from(values);
        default:
          return values;
      }
    } else if (classMirror == reflectClass(Set)) {
      switch (argType) {
        case int:
          return Set<int>.from(values);
        case String:
          return Set<String>.from(values);
        case bool:
          return Set<bool>.from(values);
        case BigInt:
          return Set<BigInt>.from(values);
        case DateTime:
          return Set<DateTime>.from(values);
        case double:
          return Set<double>.from(values);
        case num:
          return Set<num>.from(values);
        case Symbol:
          return Set<Symbol>.from(values);
        default:
          return values;
      }
    }
  }

  static void reflectParamAnnotation(
      Function function, Type annotationClass, ParameterAnnotationCallback parameterAnnotationCallback) {
    assert(function != null);
    assert(annotationClass != null);
    FunctionTypeMirror functionTypeMirror = reflect(function).type;
    functionTypeMirror.parameters.forEach((ParameterMirror parameterMirror) {
      List<InstanceMirror> instanceMirrors = parameterMirror.metadata;
      if (instanceMirrors.isNotEmpty) {
        InstanceMirror annotationMirror = instanceMirrors.lastWhere((InstanceMirror instanceMirror) {
          return instanceMirror.type == reflectClass(annotationClass);
        });
        if (annotationMirror != null && parameterAnnotationCallback != null) {
          parameterAnnotationCallback(parameterMirror, annotationMirror);
        }
      }
    });
  }
}
