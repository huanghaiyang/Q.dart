import 'dart:convert';
import 'package:Q/src/graphql/GraphQLSchema.dart';
import 'package:Q/src/graphql/GraphQLResolver.dart';

/// GraphQL 执行器类
/// 用于执行 GraphQL 查询
class GraphQLExecutor {
  /// Schema
  final GraphQLSchema schema;
  
  /// 解析器
  final _GraphQLResolver resolver;

  /// 构造函数
  GraphQLExecutor({this.schema, this.resolver});

  /// 执行查询
  Future<Map<String, dynamic>> execute(String query, {Map<String, dynamic> variables, Map<String, dynamic> context}) async {
    try {
      // 检查查询是否为空
      if (query == null || query.isEmpty) {
        throw ArgumentError('Query cannot be null or empty');
      }
      
      // 检查 variables 是否为 null
      variables ??= {};
      
      // 检查 context 是否为 null
      context ??= {};
      
      // 解析查询
      Map<String, dynamic> parsedQuery = parseQuery(query);
      String operationName = parsedQuery['operationName'];
      
      // 确定操作类型
      String operationType = _determineOperationType(query);
      
      // 执行操作
      dynamic result;
      switch (operationType) {
        case 'query':
          result = await _executeQuery(query, variables, context);
          break;
        case 'mutation':
          result = await _executeMutation(query, variables, context);
          break;
        case 'subscription':
          result = await _executeSubscription(query, variables, context);
          break;
        default:
          throw ArgumentError('Unknown operation type');
      }
      
      return {
        'data': result
      };
    } catch (e) {
      return {
        'errors': [
          {
            'message': e.toString(),
            'locations': null,
            'path': null
          }
        ]
      };
    }
  }

  /// 解析查询字符串
  Map<String, dynamic> parseQuery(String query) {
    // 简单的查询解析实现
    // 提取操作名称
    RegExp operationNameRegex = RegExp(r'\s*\w+\s+([a-zA-Z_]\w*)?\s*\(');
    Match match = operationNameRegex.firstMatch(query);
    String operationName = match != null && match.group(1) != null ? match.group(1) : null;
    
    return {
      'operationName': operationName,
      'query': query,
      'variables': {}
    };
  }
  
  /// 确定操作类型
  String _determineOperationType(String query) {
    if (query.contains('mutation')) {
      return 'mutation';
    } else if (query.contains('subscription')) {
      return 'subscription';
    } else {
      return 'query';
    }
  }
  
  /// 执行查询操作
  Future<Map<String, dynamic>> _executeQuery(String query, Map<String, dynamic> variables, Map<String, dynamic> context) async {
    // 提取查询字段
    List<Map<String, dynamic>> fields = _extractFields(query);
    
    // 执行每个字段
    Map<String, dynamic> result = {};
    for (var field in fields) {
      String fieldName = field['name'];
      Map<String, dynamic> args = field['args'] ?? {};
      List<Map<String, dynamic>> subFields = field['fields'] ?? [];
      
      // 解析参数
      Map<String, dynamic> resolvedArgs = _resolveArgs(args, variables);
      
      // 执行字段解析器
      dynamic fieldResult = await _executeField('Query', fieldName, null, resolvedArgs, context);
      
      // 处理嵌套字段
      if (subFields.isNotEmpty && fieldResult is Map) {
        fieldResult = await _executeSubFields(fieldResult, subFields, variables, context);
      } else if (subFields.isNotEmpty && fieldResult is List) {
        List<dynamic> listResult = [];
        for (var item in fieldResult) {
          if (item is Map) {
            listResult.add(await _executeSubFields(item, subFields, variables, context));
          } else {
            listResult.add(item);
          }
        }
        fieldResult = listResult;
      }
      
      result[fieldName] = fieldResult;
    }
    
    return result;
  }
  
  /// 执行变更操作
  Future<Map<String, dynamic>> _executeMutation(String query, Map<String, dynamic> variables, Map<String, dynamic> context) async {
    // 提取变更字段
    List<Map<String, dynamic>> fields = _extractFields(query);
    
    // 执行每个字段
    Map<String, dynamic> result = {};
    for (var field in fields) {
      String fieldName = field['name'];
      Map<String, dynamic> args = field['args'] ?? {};
      List<Map<String, dynamic>> subFields = field['fields'] ?? [];
      
      // 解析参数
      Map<String, dynamic> resolvedArgs = _resolveArgs(args, variables);
      
      // 执行字段解析器
      dynamic fieldResult = await _executeField('Mutation', fieldName, null, resolvedArgs, context);
      
      // 处理嵌套字段
      if (subFields.isNotEmpty && fieldResult is Map) {
        fieldResult = await _executeSubFields(fieldResult, subFields, variables, context);
      }
      
      result[fieldName] = fieldResult;
    }
    
    return result;
  }
  
  /// 执行订阅操作
  Future<Map<String, dynamic>> _executeSubscription(String query, Map<String, dynamic> variables, Map<String, dynamic> context) async {
    // 提取订阅字段
    List<Map<String, dynamic>> fields = _extractFields(query);
    
    // 执行每个字段
    Map<String, dynamic> result = {};
    for (var field in fields) {
      String fieldName = field['name'];
      Map<String, dynamic> args = field['args'] ?? {};
      
      // 解析参数
      Map<String, dynamic> resolvedArgs = _resolveArgs(args, variables);
      
      // 执行字段解析器
      dynamic fieldResult = await _executeField('Subscription', fieldName, null, resolvedArgs, context);
      
      result[fieldName] = fieldResult;
    }
    
    return result;
  }
  
  /// 提取字段
  List<Map<String, dynamic>> _extractFields(String query) {
    // 简单的字段提取实现
    List<Map<String, dynamic>> fields = [];
    
    // 找到第一个 { 后的内容
    int startIndex = query.indexOf('{');
    if (startIndex == -1) return fields;
    
    String fieldsString = query.substring(startIndex + 1);
    int endIndex = _findMatchingBrace(fieldsString);
    if (endIndex == -1) return fields;
    
    fieldsString = fieldsString.substring(0, endIndex).trim();
    
    // 分割字段
    List<String> fieldStrings = _splitFields(fieldsString);
    
    for (var fieldString in fieldStrings) {
      fieldString = fieldString.trim();
      if (fieldString.isEmpty) continue;
      
      Map<String, dynamic> field = _parseField(fieldString);
      if (field != null) {
        fields.add(field);
      }
    }
    
    return fields;
  }
  
  /// 解析字段
  Map<String, dynamic> _parseField(String fieldString) {
    // 解析字段名称
    RegExp fieldNameRegex = RegExp(r'^([a-zA-Z_]\w*)');
    Match match = fieldNameRegex.firstMatch(fieldString);
    if (match == null) return null;
    
    String fieldName = match.group(1);
    String rest = fieldString.substring(match.end).trim();
    
    Map<String, dynamic> args = {};
    List<Map<String, dynamic>> subFields = [];
    
    // 解析参数
    if (rest.startsWith('(')) {
      int endIndex = _findMatchingParenthesis(rest);
      if (endIndex != -1) {
        String argsString = rest.substring(1, endIndex).trim();
        args = _parseArgs(argsString);
        rest = rest.substring(endIndex + 1).trim();
      }
    }
    
    // 解析子字段
    if (rest.startsWith('{')) {
      int endIndex = _findMatchingBrace(rest);
      if (endIndex != -1) {
        String subFieldsString = rest.substring(1, endIndex).trim();
        List<String> subFieldStrings = _splitFields(subFieldsString);
        
        for (var subFieldString in subFieldStrings) {
          subFieldString = subFieldString.trim();
          if (subFieldString.isEmpty) continue;
          
          Map<String, dynamic> subField = _parseField(subFieldString);
          if (subField != null) {
            subFields.add(subField);
          }
        }
      }
    }
    
    return {
      'name': fieldName,
      'args': args,
      'fields': subFields
    };
  }
  
  /// 解析参数
  Map<String, dynamic> _parseArgs(String argsString) {
    Map<String, dynamic> args = {};
    
    // 简单的参数解析实现
    List<String> argStrings = _splitArgs(argsString);
    
    for (var argString in argStrings) {
      argString = argString.trim();
      if (argString.isEmpty) continue;
      
      List<String> parts = argString.split(':');
      if (parts.length < 2) continue;
      
      String argName = parts[0].trim();
      String argValue = parts.sublist(1).join(':').trim();
      
      // 解析参数值
      dynamic value = _parseValue(argValue);
      args[argName] = value;
    }
    
    return args;
  }
  
  /// 解析值
  dynamic _parseValue(String valueString) {
    valueString = valueString.trim();
    
    // 处理字符串
    if (valueString.startsWith('"') && valueString.endsWith('"')) {
      return valueString.substring(1, valueString.length - 1);
    }
    
    // 处理数字
    if (double.tryParse(valueString) != null) {
      return double.parse(valueString);
    }
    
    // 处理布尔值
    if (valueString == 'true') {
      return true;
    }
    if (valueString == 'false') {
      return false;
    }
    
    // 处理 null
    if (valueString == 'null') {
      return null;
    }
    
    // 处理变量
    if (valueString.startsWith('$')) {
      return valueString.substring(1);
    }
    
    return valueString;
  }
  
  /// 解析参数，替换变量
  Map<String, dynamic> _resolveArgs(Map<String, dynamic> args, Map<String, dynamic> variables) {
    Map<String, dynamic> resolvedArgs = {};
    
    for (var entry in args.entries) {
      String key = entry.key;
      dynamic value = entry.value;
      
      if (value is String && value.startsWith('$')) {
        String varName = value.substring(1);
        if (variables != null && variables.containsKey(varName)) {
          resolvedArgs[key] = variables[varName];
        } else {
          resolvedArgs[key] = value;
        }
      } else {
        resolvedArgs[key] = value;
      }
    }
    
    return resolvedArgs;
  }
  
  /// 执行字段
  Future<dynamic> _executeField(String typeName, String fieldName, dynamic parent, Map<String, dynamic> args, Map<String, dynamic> context) async {
    // 检查解析器是否存在
    if (resolver == null) {
      throw Exception('No resolver found');
    }
    
    try {
      // 调用解析器
      dynamic result = await resolver.resolveField(typeName, fieldName, parent, args, context);
      return result;
    } catch (e) {
      throw Exception('Error executing field $typeName.$fieldName: ${e.toString()}');
    }
  }
  
  /// 执行子字段
  Future<Map<String, dynamic>> _executeSubFields(Map<String, dynamic> parent, List<Map<String, dynamic>> fields, Map<String, dynamic> variables, Map<String, dynamic> context) async {
    Map<String, dynamic> result = {};
    
    for (var field in fields) {
      String fieldName = field['name'];
      Map<String, dynamic> args = field['args'] ?? {};
      List<Map<String, dynamic>> subFields = field['fields'] ?? [];
      
      // 解析参数
      Map<String, dynamic> resolvedArgs = _resolveArgs(args, variables);
      
      // 从父对象中获取值
      dynamic fieldResult = parent[fieldName];
      
      // 如果没有值，尝试使用解析器
      if (fieldResult == null && resolver != null) {
        try {
          fieldResult = await resolver.resolveField(parent.runtimeType.toString(), fieldName, parent, resolvedArgs, context);
        } catch (e) {
          // 忽略解析器错误，使用 null
        }
      }
      
      // 处理嵌套字段
      if (subFields.isNotEmpty && fieldResult is Map) {
        fieldResult = await _executeSubFields(fieldResult, subFields, variables, context);
      } else if (subFields.isNotEmpty && fieldResult is List) {
        List<dynamic> listResult = [];
        for (var item in fieldResult) {
          if (item is Map) {
            listResult.add(await _executeSubFields(item, subFields, variables, context));
          } else {
            listResult.add(item);
          }
        }
        fieldResult = listResult;
      }
      
      result[fieldName] = fieldResult;
    }
    
    return result;
  }
  
  /// 找到匹配的大括号
  int _findMatchingBrace(String str) {
    int count = 1;
    for (int i = 1; i < str.length; i++) {
      if (str[i] == '{') {
        count++;
      } else if (str[i] == '}') {
        count--;
        if (count == 0) {
          return i;
        }
      }
    }
    return -1;
  }
  
  /// 找到匹配的小括号
  int _findMatchingParenthesis(String str) {
    int count = 1;
    for (int i = 1; i < str.length; i++) {
      if (str[i] == '(') {
        count++;
      } else if (str[i] == ')') {
        count--;
        if (count == 0) {
          return i;
        }
      }
    }
    return -1;
  }
  
  /// 分割字段
  List<String> _splitFields(String fieldsString) {
    List<String> fields = [];
    String currentField = '';
    int braceCount = 0;
    int parenthesisCount = 0;
    
    for (int i = 0; i < fieldsString.length; i++) {
      String char = fieldsString[i];
      
      if (char == ',' && braceCount == 0 && parenthesisCount == 0) {
        fields.add(currentField);
        currentField = '';
      } else {
        currentField += char;
        
        if (char == '{') {
          braceCount++;
        } else if (char == '}') {
          braceCount--;
        } else if (char == '(') {
          parenthesisCount++;
        } else if (char == ')') {
          parenthesisCount--;
        }
      }
    }
    
    if (currentField.isNotEmpty) {
      fields.add(currentField);
    }
    
    return fields;
  }
  
  /// 分割参数
  List<String> _splitArgs(String argsString) {
    List<String> args = [];
    String currentArg = '';
    int parenthesisCount = 0;
    
    for (int i = 0; i < argsString.length; i++) {
      String char = argsString[i];
      
      if (char == ',' && parenthesisCount == 0) {
        args.add(currentArg);
        currentArg = '';
      } else {
        currentArg += char;
        
        if (char == '(') {
          parenthesisCount++;
        } else if (char == ')') {
          parenthesisCount--;
        }
      }
    }
    
    if (currentArg.isNotEmpty) {
      args.add(currentArg);
    }
    
    return args;
  }
}
