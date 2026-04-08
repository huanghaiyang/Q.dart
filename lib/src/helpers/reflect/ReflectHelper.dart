import 'dart:mirrors';
import 'dart:convert';

import 'package:Q/src/utils/SymbolUtil.dart';

typedef ParameterAnnotationCallback = void Function(ParameterMirror parameterMirror, InstanceMirror instanceMirror);

class ReflectHelper {
  // 类型转换缓存
  static Map<String, dynamic> _typeConversionCache = {};
  // 类型转换缓存大小限制
  static const int MAX_TYPE_CONVERSION_CACHE_SIZE = 1000;
  static dynamic reflectParameterValue(Type type, dynamic value) {
    if (value == null) return value;
    
    // 处理基本类型
    if (value is String) {
      // 生成缓存键
      String cacheKey = '$type:$value';
      
      // 检查缓存
      if (_typeConversionCache.containsKey(cacheKey)) {
        return _typeConversionCache[cacheKey];
      }
      
      dynamic result;
      try {
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
            // 尝试处理复杂对象类型
            result = _reflectObjectType(type, value);
            break;
        }
        
        // 缓存结果
        if (result != null) {
          // 检查缓存大小
          if (_typeConversionCache.length >= MAX_TYPE_CONVERSION_CACHE_SIZE) {
            // 移除最早的缓存项
            String firstKey = _typeConversionCache.keys.first;
            _typeConversionCache.remove(firstKey);
          }
          _typeConversionCache[cacheKey] = result;
        }
      } catch (e) {
        // 安全处理类型转换异常
        print('Type conversion error: $e');
        result = value; // 转换失败时返回原始值
      }
      return result;
    } else if (value is Map) {
      // 处理 Map 类型，尝试转换为复杂对象
      return _reflectObjectType(type, value);
    } else if (value is List) {
      // 处理 List 类型，尝试转换为泛型集合
      Type subType = getSubType(type);
      if (subType != null) {
        List<dynamic> result = [];
        for (var item in value) {
          result.add(reflectParameterValue(subType, item));
        }
        return result;
      }
    }
    
    // 默认返回原始值
    return value;
  }
  
  // 反射处理对象类型
  static dynamic _reflectObjectType(Type type, dynamic value) {
    try {
      ClassMirror classMirror = reflectClass(type);
      InstanceMirror instanceMirror = classMirror.newInstance(Symbol.empty, []);
      
      // 处理 Map 类型的 value
      if (value is Map) {
        // 遍历对象的所有字段
        for (var declaration in classMirror.declarations.values) {
          if (declaration is VariableMirror && !declaration.isStatic && !declaration.isPrivate) {
            String fieldName = MirrorSystem.getName(declaration.simpleName);
            if (value.containsKey(fieldName)) {
              // 获取字段类型
              Type fieldType = declaration.type.reflectedType;
              // 递归处理字段值
              dynamic fieldValue = reflectParameterValue(fieldType, value[fieldName]);
              // 设置字段值
              instanceMirror.setField(declaration.simpleName, fieldValue);
            }
          }
        }
        return instanceMirror.reflectee;
      } else if (value is String) {
        // 尝试将字符串解析为 JSON
        try {
          Map<String, dynamic> jsonMap = json.decode(value);
          return _reflectObjectType(type, jsonMap);
        } catch (e) {
          // 解析失败，返回原始值
          return value;
        }
      }
    } catch (e) {
      // 处理异常，返回原始值
      print('Object type conversion error: $e');
    }
    return value;
  }

  // 获取list或者set的子元素类型
  static Type reflectSubType(Type type) {
    Type subType;
    ClassMirror classMirror = reflectClass(type);
    if (classMirror == reflectClass(List) || reflectType(type).isSubtypeOf(reflectType(List))) {
      reflectType(type).typeArguments.forEach((TypeMirror typeMirror) {
        subType = typeMirror.reflectedType;
      });
    }
    return subType;
  }

  static Type getSubType(Type type) {
    Type subType;
    reflectType(type).typeArguments.forEach((TypeMirror typeMirror) {
      subType = typeMirror.reflectedType;
    });
    return subType;
  }

  static dynamic reflectParameterValues(Type type, dynamic values) {
    // 处理单个值的情况
    if (values is! List) {
      return reflectParameterValue(type, values);
    }
    
    List result = List();
    bool isCollection = false;
    Type subType = reflectSubType(type);
    if (subType != null) {
      isCollection = true;
    } else {
      subType = type;
    }
    
    for (var value in values) {
      result.add(reflectParameterValue(subType, value));
    }
    
    if (isCollection) {
      return reflectCollection(type, subType, result);
    } else {
      return result.first;
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

  static void reflectParamAnnotation(Function function, Type annotationClass, ParameterAnnotationCallback parameterAnnotationCallback) {
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

  static DeclarationMirror getDeclaration(Type clazz, String name) {
    Map<Symbol, DeclarationMirror> mirrors = reflectClass(clazz).declarations;
    Symbol symbol = mirrors.keys.firstWhere((Symbol symbol) {
      return SymbolUtil.toChars(symbol) == name;
    });
    if (symbol != null) {
      return mirrors[symbol];
    }
    return null;
  }
}
