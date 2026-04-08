import 'dart:mirrors';

/// 反射缓存工具类
/// 用于存储和管理反射操作的结果，提高反射操作的性能
class ReflectionCache {
  /// 单例实例
  static final ReflectionCache _instance = ReflectionCache._private();
  
  /// 类镜像缓存
  final Map<Type, ClassMirror> _classMirrors = {};
  
  /// 方法镜像缓存
  final Map<Type, Map<Symbol, MethodMirror>> _methodMirrors = {};
  
  /// 字段镜像缓存
  final Map<Type, Map<Symbol, VariableMirror>> _fieldMirrors = {};
  
  /// 注解缓存
  final Map<Type, List<dynamic>> _classAnnotations = {};
  final Map<Type, Map<Symbol, List<dynamic>>> _methodAnnotations = {};
  final Map<Type, Map<Symbol, List<dynamic>>> _fieldAnnotations = {};
  
  /// 泛型类型参数缓存
  final Map<Type, List<Type>> _typeArguments = {};
  
  /// 私有构造函数
  ReflectionCache._private();
  
  /// 获取单例实例
  static ReflectionCache get instance => _instance;
  
  /// 获取类镜像
  ClassMirror getClassMirror(Type type) {
    if (!_classMirrors.containsKey(type)) {
      _classMirrors[type] = reflectClass(type);
    }
    return _classMirrors[type];
  }
  
  /// 获取方法镜像
  MethodMirror getMethodMirror(Type type, Symbol methodName) {
    if (!_methodMirrors.containsKey(type)) {
      _methodMirrors[type] = {};
    }
    
    if (!_methodMirrors[type].containsKey(methodName)) {
      ClassMirror classMirror = getClassMirror(type);
      _methodMirrors[type][methodName] = classMirror.declarations[methodName] as MethodMirror;
    }
    
    return _methodMirrors[type][methodName];
  }
  
  /// 获取字段镜像
  VariableMirror getFieldMirror(Type type, Symbol fieldName) {
    if (!_fieldMirrors.containsKey(type)) {
      _fieldMirrors[type] = {};
    }
    
    if (!_fieldMirrors[type].containsKey(fieldName)) {
      ClassMirror classMirror = getClassMirror(type);
      _fieldMirrors[type][fieldName] = classMirror.declarations[fieldName] as VariableMirror;
    }
    
    return _fieldMirrors[type][fieldName];
  }
  
  /// 获取类注解
  List<dynamic> getClassAnnotations(Type type) {
    if (!_classAnnotations.containsKey(type)) {
      ClassMirror classMirror = getClassMirror(type);
      _classAnnotations[type] = classMirror.metadata.map((metadata) => metadata.reflectee).toList();
    }
    return _classAnnotations[type];
  }
  
  /// 获取方法注解
  List<dynamic> getMethodAnnotations(Type type, Symbol methodName) {
    if (!_methodAnnotations.containsKey(type)) {
      _methodAnnotations[type] = {};
    }
    
    if (!_methodAnnotations[type].containsKey(methodName)) {
      MethodMirror methodMirror = getMethodMirror(type, methodName);
      _methodAnnotations[type][methodName] = methodMirror.metadata.map((metadata) => metadata.reflectee).toList();
    }
    
    return _methodAnnotations[type][methodName];
  }
  
  /// 获取字段注解
  List<dynamic> getFieldAnnotations(Type type, Symbol fieldName) {
    if (!_fieldAnnotations.containsKey(type)) {
      _fieldAnnotations[type] = {};
    }
    
    if (!_fieldAnnotations[type].containsKey(fieldName)) {
      VariableMirror fieldMirror = getFieldMirror(type, fieldName);
      _fieldAnnotations[type][fieldName] = fieldMirror.metadata.map((metadata) => metadata.reflectee).toList();
    }
    
    return _fieldAnnotations[type][fieldName];
  }
  
  /// 获取类型参数
  List<Type> getTypeArguments(Type type) {
    if (!_typeArguments.containsKey(type)) {
      ClassMirror classMirror = getClassMirror(type);
      List<Type> typeArgs = [];
      
      // 处理泛型类型
      if (classMirror is ClassMirror && classMirror.typeArguments.isNotEmpty) {
        for (var typeArg in classMirror.typeArguments) {
          if (typeArg is TypeMirror) {
            // 尝试获取类型参数的实际类型
            try {
              typeArgs.add(typeArg.reflectedType);
            } catch (e) {
              // 忽略错误，继续处理
            }
          }
        }
      }
      
      _typeArguments[type] = typeArgs;
    }
    return _typeArguments[type];
  }
  
  /// 获取嵌套类型的类型参数
  List<Type> getNestedTypeArguments(Type type) {
    List<Type> allTypeArgs = [];
    
    // 获取当前类型的类型参数
    List<Type> typeArgs = getTypeArguments(type);
    allTypeArgs.addAll(typeArgs);
    
    // 递归处理嵌套类型参数
    for (var typeArg in typeArgs) {
      allTypeArgs.addAll(getNestedTypeArguments(typeArg));
    }
    
    return allTypeArgs;
  }
  
  /// 清除缓存
  void clear() {
    _classMirrors.clear();
    _methodMirrors.clear();
    _fieldMirrors.clear();
    _classAnnotations.clear();
    _methodAnnotations.clear();
    _fieldAnnotations.clear();
    _typeArguments.clear();
  }
  
  /// 清除指定类型的缓存
  void clearType(Type type) {
    _classMirrors.remove(type);
    _methodMirrors.remove(type);
    _fieldMirrors.remove(type);
    _classAnnotations.remove(type);
    _methodAnnotations.remove(type);
    _fieldAnnotations.remove(type);
    _typeArguments.remove(type);
  }
}
