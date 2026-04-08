import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';
import 'package:Q/src/Context.dart';
import 'package:Q/src/handler/HandlerAdapter.dart';
import 'package:Q/src/graphql/GraphQLExecutor.dart';
import 'package:Q/src/graphql/GraphQLSchema.dart';
import 'package:Q/src/graphql/GraphQLResolver.dart';
import 'package:Q/src/graphql/annotations/GraphQL.dart';
import 'package:Q/src/utils/ReflectionCache.dart';

/// GraphQL 处理器类
/// 用于处理 HTTP 请求并执行 GraphQL 查询
class GraphQLHandler implements HandlerAdapter {
  /// GraphQL 执行器
  final GraphQLExecutor executor;
  
  /// 解析器
  final _GraphQLResolver _resolver;

  /// 私有构造函数
  GraphQLHandler._({GraphQLSchema schema, _GraphQLResolver resolver}) : 
    _resolver = resolver,
    executor = GraphQLExecutor(schema: schema, resolver: resolver);

  /// 工厂构造函数
  factory GraphQLHandler({GraphQLSchema schema}) {
    _GraphQLResolver resolver = _GraphQLResolver();
    return GraphQLHandler._(schema: schema, resolver: resolver);
  }

  /// 添加字段解析器
  void addResolver(String typeName, String fieldName, Function resolver) {
    _resolver.addFieldResolver(typeName, fieldName, resolver);
  }

  /// 添加类型解析器
  void addTypeResolver(String typeName, Map<String, Function> resolvers) {
    _resolver.addTypeResolver(typeName, resolvers);
  }

  /// 扫描带有 GraphQL 注解的类
  void scanType(Type type) {
    // 使用反射缓存获取类镜像
    ClassMirror classMirror = ReflectionCache.instance.getClassMirror(type);
    
    // 检查类是否有 @GraphQLType 注解
    List<dynamic> classAnnotations = ReflectionCache.instance.getClassAnnotations(type);
    for (var annotation in classAnnotations) {
      if (annotation is GraphQLType) {
        String typeName = annotation.name ?? MirrorSystem.getName(classMirror.simpleName);
        
        // 扫描方法
        for (var declaration in classMirror.declarations.values) {
          if (declaration is MethodMirror && !declaration.isStatic && !declaration.isPrivate) {
            Symbol methodName = declaration.simpleName;
            
            // 使用反射缓存获取方法注解
            List<dynamic> methodAnnotations = ReflectionCache.instance.getMethodAnnotations(type, methodName);
            for (var methodAnnotation in methodAnnotations) {
              if (methodAnnotation is Query) {
                String fieldName = methodAnnotation.name ?? MirrorSystem.getName(methodName);
                _resolver.addFieldResolver('Query', fieldName, (parent, args, context) async {
                  InstanceMirror instanceMirror = classMirror.newInstance(Symbol.empty, []);
                  var result = instanceMirror.invoke(methodName, [parent, args, context]);
                  // 处理异步结果
                  if (result.reflectee is Future) {
                    return await result.reflectee;
                  }
                  return result.reflectee;
                });
              }
              
              // 检查方法是否有 @Mutation 注解
              if (methodAnnotation is Mutation) {
                String fieldName = methodAnnotation.name ?? MirrorSystem.getName(methodName);
                _resolver.addFieldResolver('Mutation', fieldName, (parent, args, context) async {
                  InstanceMirror instanceMirror = classMirror.newInstance(Symbol.empty, []);
                  var result = instanceMirror.invoke(methodName, [parent, args, context]);
                  // 处理异步结果
                  if (result.reflectee is Future) {
                    return await result.reflectee;
                  }
                  return result.reflectee;
                });
              }
              
              // 检查方法是否有 @Subscription 注解
              if (methodAnnotation is Subscription) {
                String fieldName = methodAnnotation.name ?? MirrorSystem.getName(methodName);
                _resolver.addFieldResolver('Subscription', fieldName, (parent, args, context) async {
                  InstanceMirror instanceMirror = classMirror.newInstance(Symbol.empty, []);
                  var result = instanceMirror.invoke(methodName, [parent, args, context]);
                  // 处理异步结果
                  if (result.reflectee is Future) {
                    return await result.reflectee;
                  }
                  return result.reflectee;
                });
              }
            }
          }
        }
      }
    }
  }

  /// 扫描多个带有 GraphQL 注解的类
  void scanTypes(List<Type> types) {
    for (var type in types) {
      scanType(type);
    }
  }

  @override
  Future<dynamic> handle(Context context) async {
    try {
      // 解析请求体
      String body = await _readRequestBody(context, maxSize: 10 * 1024 * 1024); // 10MB 限制
      Map<String, dynamic> request = _parseAndValidateRequest(body);
      
      // 执行 GraphQL 查询
      Map<String, dynamic> result = await executor.execute(
        request['query'],
        variables: request['variables'],
        context: {
          'request': context.request,
          'response': context.response,
        },
      );
      
      // 返回结果
      context.response.headers.contentType = ContentType.json;
      return jsonEncode(result);
    } catch (e) {
      // 处理错误
      context.response.status = HttpStatus.badRequest;
      context.response.headers.contentType = ContentType.json;
      return jsonEncode({
        'errors': [
          {
            'message': e.toString()
          }
        ]
      });
    }
  }
  
  /// 读取请求体，限制大小
  Future<String> _readRequestBody(Context context, {int maxSize = 10 * 1024 * 1024}) async {
    List<int> data = [];
    int totalSize = 0;
    
    await for (var chunk in context.request.req) {
      totalSize += chunk.length;
      if (totalSize > maxSize) {
        throw ArgumentError('Request body too large');
      }
      data.addAll(chunk);
    }
    
    return utf8.decode(data);
  }
  
  /// 解析并验证请求
  Map<String, dynamic> _parseAndValidateRequest(String body) {
    if (body == null || body.isEmpty) {
      throw ArgumentError('Request body cannot be empty');
    }
    
    // 解析 JSON
    dynamic parsed = jsonDecode(body);
    if (parsed is Map<String, dynamic>) {
      Map<String, dynamic> request = parsed;
      
      // 验证请求结构
      if (!request.containsKey('query') || request['query'] == null) {
        throw ArgumentError('Query is required');
      }
      
      // 验证查询类型
      if (request['query'] is! String) {
        throw ArgumentError('Query must be a string');
      }
      
      // 验证 variables 类型
      if (request.containsKey('variables') && request['variables'] != null && request['variables'] is! Map) {
        throw ArgumentError('Variables must be an object');
      }
      
      // 验证查询字符串，防止恶意查询
      _validateQuery(request['query'] as String);
      
      return request;
    } else {
      throw ArgumentError('Invalid request format');
    }
  }
  
  /// 验证查询字符串
  void _validateQuery(String query) {
    // 检查查询长度
    if (query.length > 100000) { // 100KB 限制
      throw ArgumentError('Query too long');
    }
    
    // 检查查询复杂度（简单实现，可根据需要扩展）
    int depth = _calculateQueryDepth(query);
    if (depth > 10) {
      throw ArgumentError('Query depth too deep');
    }
    
    // 检查是否包含危险操作（可根据需要扩展）
    List<String> dangerousKeywords = [
      'DROP', 'ALTER', 'TRUNCATE', 'DELETE', 'INSERT', 'UPDATE', 'CREATE'
    ];
    for (var keyword in dangerousKeywords) {
      if (query.toUpperCase().contains(keyword)) {
        throw ArgumentError('Query contains dangerous keywords');
      }
    }
    
    // 检查查询结构完整性
    _validateQueryStructure(query);
  }
  
  /// 验证查询结构完整性
  void _validateQueryStructure(String query) {
    // 检查括号匹配
    _validateBrackets(query);
    
    // 检查引号匹配
    _validateQuotes(query);
    
    // 检查操作类型
    _validateOperationType(query);
    
    // 检查字段名称
    _validateFieldNames(query);
    
    // 检查参数名称
    _validateArgumentNames(query);
  }
  
  /// 检查括号匹配
  void _validateBrackets(String query) {
    // 检查大括号
    int braceCount = 0;
    for (int i = 0; i < query.length; i++) {
      if (query[i] == '{') {
        braceCount++;
      } else if (query[i] == '}') {
        braceCount--;
        if (braceCount < 0) {
          throw ArgumentError('Unmatched closing brace at position $i');
        }
      }
    }
    if (braceCount != 0) {
      throw ArgumentError('Unmatched opening brace');
    }
    
    // 检查小括号
    int parenthesisCount = 0;
    for (int i = 0; i < query.length; i++) {
      if (query[i] == '(') {
        parenthesisCount++;
      } else if (query[i] == ')') {
        parenthesisCount--;
        if (parenthesisCount < 0) {
          throw ArgumentError('Unmatched closing parenthesis at position $i');
        }
      }
    }
    if (parenthesisCount != 0) {
      throw ArgumentError('Unmatched opening parenthesis');
    }
    
    // 检查方括号
    int bracketCount = 0;
    for (int i = 0; i < query.length; i++) {
      if (query[i] == '[') {
        bracketCount++;
      } else if (query[i] == ']') {
        bracketCount--;
        if (bracketCount < 0) {
          throw ArgumentError('Unmatched closing bracket at position $i');
        }
      }
    }
    if (bracketCount != 0) {
      throw ArgumentError('Unmatched opening bracket');
    }
  }
  
  /// 检查引号匹配
  void _validateQuotes(String query) {
    bool inSingleQuote = false;
    bool inDoubleQuote = false;
    
    for (int i = 0; i < query.length; i++) {
      if (query[i] == '\\') {
        // 跳过转义字符
        i++;
        continue;
      }
      
      if (query[i] == "'" && !inDoubleQuote) {
        inSingleQuote = !inSingleQuote;
      } else if (query[i] == '"' && !inSingleQuote) {
        inDoubleQuote = !inDoubleQuote;
      }
    }
    
    if (inSingleQuote) {
      throw ArgumentError('Unmatched single quote');
    }
    if (inDoubleQuote) {
      throw ArgumentError('Unmatched double quote');
    }
  }
  
  /// 检查操作类型
  void _validateOperationType(String query) {
    // 检查是否包含有效的操作类型
    bool hasValidOperation = false;
    List<String> validOperations = ['query', 'mutation', 'subscription'];
    
    for (var operation in validOperations) {
      if (query.contains(operation)) {
        hasValidOperation = true;
        break;
      }
    }
    
    if (!hasValidOperation) {
      throw ArgumentError('Query must contain a valid operation type (query, mutation, or subscription)');
    }
  }
  
  /// 检查字段名称
  void _validateFieldNames(String query) {
    // 简单的字段名称验证
    RegExp fieldNameRegex = RegExp(r'\b([a-zA-Z_]\w*)\b');
    Iterable<Match> matches = fieldNameRegex.allMatches(query);
    
    for (var match in matches) {
      String fieldName = match.group(1);
      if (_isReservedKeyword(fieldName)) {
        throw ArgumentError('Field name "$fieldName" is a reserved keyword');
      }
    }
  }
  
  /// 检查参数名称
  void _validateArgumentNames(String query) {
    // 简单的参数名称验证
    RegExp argNameRegex = RegExp(r'([a-zA-Z_]\w*):');
    Iterable<Match> matches = argNameRegex.allMatches(query);
    
    for (var match in matches) {
      String argName = match.group(1);
      if (_isReservedKeyword(argName)) {
        throw ArgumentError('Argument name "$argName" is a reserved keyword');
      }
    }
  }
  
  /// 检查是否为保留关键字
  bool _isReservedKeyword(String name) {
    List<String> reservedKeywords = [
      'query', 'mutation', 'subscription', 'fragment', 'on', 'true', 'false', 'null',
      'String', 'Int', 'Float', 'Boolean', 'ID', 'scalar', 'type', 'interface', 'union',
      'enum', 'input', 'extend', 'implements', 'directive', 'repeatable', 'schema'
    ];
    return reservedKeywords.contains(name);
  }
  
  /// 计算查询深度
  int _calculateQueryDepth(String query) {
    int depth = 0;
    int maxDepth = 0;
    
    for (int i = 0; i < query.length; i++) {
      if (query[i] == '{') {
        depth++;
        if (depth > maxDepth) {
          maxDepth = depth;
        }
      } else if (query[i] == '}') {
        depth--;
      }
    }
    
    return maxDepth;
  }
}
