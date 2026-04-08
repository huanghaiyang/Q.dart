import 'dart:mirrors';
import 'package:Q/src/graphql/GraphQLType.dart';
import 'package:Q/src/graphql/GraphQLField.dart';
import 'package:Q/src/graphql/annotations/GraphQL.dart';
import 'package:Q/src/utils/ReflectionCache.dart';

/// GraphQL Schema 类
/// 用于定义 GraphQL API 的类型和操作
class GraphQLSchema {
  /// 类型定义
  final Map<String, GraphQLType> types;
  
  /// 查询操作
  final GraphQLField query;
  
  /// 变更操作
  final GraphQLField mutation;
  
  /// 订阅操作
  final GraphQLField subscription;

  /// 构造函数
  GraphQLSchema({
    this.types = const {},
    this.query,
    this.mutation,
    this.subscription,
  });

  /// 从 SDL 字符串创建 Schema
  factory GraphQLSchema.fromSDL(String sdl) {
    // 这里应该实现 SDL 解析逻辑
    // 暂时返回一个空的 Schema
    return GraphQLSchema();
  }

  /// 从数据模型类生成类型定义
  static GraphQLObjectType fromModel(Type modelType, {String typeName, Map<String, GraphQLType> types}) {
    // 使用反射缓存获取类镜像
    ClassMirror classMirror = ReflectionCache.instance.getClassMirror(modelType);
    String name = typeName ?? MirrorSystem.getName(classMirror.simpleName);
    
    // 检查类是否有 @GraphQLType 注解
    List<dynamic> classAnnotations = ReflectionCache.instance.getClassAnnotations(modelType);
    for (var annotation in classAnnotations) {
      if (annotation is GraphQLType) {
        name = annotation.name ?? name;
        break;
      }
    }
    
    // 如果类型已经存在，直接返回
    if (types != null && types.containsKey(name)) {
      return types[name] as GraphQLObjectType;
    }
    
    // 处理嵌套的泛型类型参数
    List<Type> nestedTypeArgs = ReflectionCache.instance.getNestedTypeArguments(modelType);
    for (var typeArg in nestedTypeArgs) {
      if (typeArg != null) {
        fromModel(typeArg, types: types);
      }
    }
    
    // 扫描字段
    Map<String, GraphQLField> fields = {};
    for (var declaration in classMirror.declarations.values) {
      if (declaration is VariableMirror && !declaration.isStatic && !declaration.isPrivate) {
        String fieldName = MirrorSystem.getName(declaration.simpleName);
        String fieldType = _getGraphQLType(declaration.type, fieldName);
        
        // 处理嵌套类型
        _processNestedTypes(declaration.type, types);
        
        // 检查字段是否有 @GraphQLField 注解
        List<dynamic> fieldAnnotations = ReflectionCache.instance.getFieldAnnotations(modelType, declaration.simpleName);
        for (var annotation in fieldAnnotations) {
          if (annotation is GraphQLField) {
            fieldName = annotation.name ?? fieldName;
            fieldType = annotation.type ?? fieldType;
            break;
          }
        }
        
        fields[fieldName] = GraphQLField(
          name: fieldName,
          type: fieldType,
        );
      }
    }
    
    GraphQLObjectType resultType = GraphQLObjectType(name, fields: fields);
    
    // 如果提供了 types 映射，将当前类型添加进去
    if (types != null && !types.containsKey(name)) {
      types[name] = resultType;
    }
    
    return resultType;
  }
  
  /// 处理嵌套类型，递归生成所有必要的类型
  static void _processNestedTypes(TypeMirror typeMirror, Map<String, GraphQLType> types) {
    if (types == null) return;
    
    // 处理可空类型
    if (typeMirror is TypeVariableMirror) {
      _processNestedTypes(typeMirror.upperBound, types);
      return;
    }
    
    // 处理类型参数
    if (typeMirror is TypeParameterMirror) {
      _processNestedTypes(typeMirror.bound, types);
      return;
    }
    
    // 处理泛型类型
    if (typeMirror is ClassMirror && typeMirror.typeArguments.isNotEmpty) {
      String genericTypeName = MirrorSystem.getName(typeMirror.simpleName);
      
      // 处理 List、Set 等集合类型
      if (genericTypeName == 'List' || genericTypeName == 'Set' || genericTypeName == 'Queue') {
        TypeMirror elementType = typeMirror.typeArguments.first;
        _processNestedTypes(elementType, types);
      }
      
      // 处理 Future 类型
      else if (genericTypeName == 'Future') {
        TypeMirror futureType = typeMirror.typeArguments.first;
        _processNestedTypes(futureType, types);
      }
      
      // 处理 Map 类型
      else if (genericTypeName == 'Map') {
        TypeMirror keyType = typeMirror.typeArguments.first;
        TypeMirror valueType = typeMirror.typeArguments[1];
        _processNestedTypes(keyType, types);
        _processNestedTypes(valueType, types);
      }
      
      // 处理其他泛型类型
      else {
        for (var typeArg in typeMirror.typeArguments) {
          _processNestedTypes(typeArg, types);
        }
        
        // 处理泛型类型本身
        String typeName = MirrorSystem.getName(typeMirror.simpleName);
        if (!_isBasicType(typeName) && !_isSystemType(typeMirror)) {
          // 如果类型已经存在，直接返回
          if (types.containsKey(typeName)) {
            return;
          }
          
          // 先创建一个占位符，避免循环引用
          GraphQLObjectType placeholderType = GraphQLObjectType(typeName, fields: {});
          types[typeName] = placeholderType;
          
          // 递归生成实际类型
          GraphQLObjectType nestedType = fromModel(typeMirror.reflectedType, types: types);
          // 更新占位符为实际类型
          types[typeName] = nestedType;
        }
      }
      
      return;
    }
    
    // 处理自定义类型
    if (typeMirror is ClassMirror) {
      String typeName = MirrorSystem.getName(typeMirror.simpleName);
      
      // 跳过基本类型和系统类型
      if (!_isBasicType(typeName) && !_isSystemType(typeMirror)) {
        // 如果类型已经存在，直接返回
        if (types.containsKey(typeName)) {
          return;
        }
        
        // 先创建一个占位符，避免循环引用
        GraphQLObjectType placeholderType = GraphQLObjectType(typeName, fields: {});
        types[typeName] = placeholderType;
        
        // 递归生成实际类型
        GraphQLObjectType nestedType = fromModel(typeMirror.reflectedType, types: types);
        // 更新占位符为实际类型
        types[typeName] = nestedType;
      }
    }
  }
  
  /// 检查是否是基本类型
  static bool _isBasicType(String typeName) {
    return [
      'String', 'int', 'double', 'bool', 'DateTime', 'dynamic',
      'List', 'Map', 'Future'
    ].contains(typeName);
  }
  
  /// 检查是否是系统类型
  static bool _isSystemType(ClassMirror classMirror) {
    String libraryName = MirrorSystem.getName(classMirror.owner.simpleName);
    return libraryName.startsWith('dart.') || libraryName.startsWith('core.');
  }

  /// 获取 GraphQL 类型名称
  static String _getGraphQLType(TypeMirror typeMirror, String fieldName) {
    // 处理可空类型
    if (typeMirror is TypeVariableMirror) {
      return _getGraphQLType(typeMirror.upperBound, fieldName);
    }
    
    // 处理类型参数（用于泛型）
    if (typeMirror is TypeParameterMirror) {
      return _getGraphQLType(typeMirror.bound, fieldName);
    }
    
    String typeName = MirrorSystem.getName(typeMirror.simpleName);
    
    // 处理基本类型
    switch (typeName) {
      case 'String':
        // 检查是否是 ID 类型（字段名为 id 或以 Id 结尾）
        if (_isIdField(fieldName)) {
          return 'ID';
        }
        return 'String';
      case 'int':
        return 'Int';
      case 'double':
        return 'Float';
      case 'bool':
        return 'Boolean';
      case 'DateTime':
        return 'String'; // GraphQL 没有内置的 DateTime 类型，使用 String 表示
      case 'dynamic':
        return 'String'; // 默认为 String
      default:
        // 处理泛型类型
        if (typeMirror is ClassMirror && typeMirror.typeArguments.isNotEmpty) {
          String genericTypeName = MirrorSystem.getName(typeMirror.simpleName);
          
          // 处理 List 类型
          if (genericTypeName == 'List') {
            TypeMirror elementType = typeMirror.typeArguments.first;
            return '[${_getGraphQLType(elementType, fieldName)}]';
          }
          
          // 处理 Map 类型
          else if (genericTypeName == 'Map') {
            return 'String'; // GraphQL 没有内置的 Map 类型，使用 String 表示
          }
          
          // 处理 Future 类型
          else if (genericTypeName == 'Future') {
            TypeMirror futureType = typeMirror.typeArguments.first;
            return _getGraphQLType(futureType, fieldName);
          }
          
          // 处理其他泛型类型（如 Set、Queue 等）
          else {
            // 对于其他泛型类型，我们可以尝试获取其元素类型
            if (typeMirror.typeArguments.isNotEmpty) {
              TypeMirror elementType = typeMirror.typeArguments.first;
              return '[${_getGraphQLType(elementType, fieldName)}]';
            }
            return typeName;
          }
        }
        
        // 处理自定义类型
        return typeName;
    }
  }
  
  /// 检查是否是 ID 字段
  static bool _isIdField(String fieldName) {
    // 字段名为 id 或以 Id 结尾
    return fieldName == 'id' || fieldName.endsWith('Id');
  }

  /// 转换为 SDL 字符串
  String toSDL() {
    StringBuffer sdl = StringBuffer();
    
    // 生成类型定义
    for (var type in types.values) {
      sdl.writeln(type.toSDL());
      sdl.writeln();
    }
    
    // 生成查询操作
    if (query != null) {
      sdl.writeln('type Query {');
      for (var field in query.fields.values) {
        sdl.writeln('  ${field.toSDL()}');
      }
      sdl.writeln('}');
      sdl.writeln();
    }
    
    // 生成变更操作
    if (mutation != null) {
      sdl.writeln('type Mutation {');
      for (var field in mutation.fields.values) {
        sdl.writeln('  ${field.toSDL()}');
      }
      sdl.writeln('}');
      sdl.writeln();
    }
    
    // 生成订阅操作
    if (subscription != null) {
      sdl.writeln('type Subscription {');
      for (var field in subscription.fields.values) {
        sdl.writeln('  ${field.toSDL()}');
      }
      sdl.writeln('}');
    }
    
    return sdl.toString();
  }
}
