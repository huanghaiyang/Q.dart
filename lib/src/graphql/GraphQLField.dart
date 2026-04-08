import 'package:Q/src/graphql/GraphQLArgument.dart';

/// GraphQL 字段类
class GraphQLField {
  /// 字段名称
  final String name;
  
  /// 字段类型
  final String type;
  
  /// 字段参数
  final Map<String, GraphQLArgument> arguments;
  
  /// 解析器函数
  final Function resolver;

  /// 构造函数
  GraphQLField({
    String name,
    this.type,
    this.arguments = const {},
    this.resolver,
  }) : name = _sanitizeName(name) {
    _validateName(name);
  }

  /// 转换为 SDL 字符串
  String toSDL() {
    StringBuffer sdl = StringBuffer();
    sdl.write('$name');
    
    if (arguments.isNotEmpty) {
      sdl.write('(');
      sdl.write(arguments.values.map((arg) => arg.toSDL()).join(', '));
      sdl.write(')');
    }
    
    sdl.write(': $type');
    
    return sdl.toString();
  }
  
  /// 验证字段名称是否符合 GraphQL 规范
  static void _validateName(String name) {
    if (name == null || name.isEmpty) {
      throw ArgumentError('Field name cannot be null or empty');
    }
    // 检查是否是 GraphQL 保留关键字
    if (_isReservedKeyword(name)) {
      throw ArgumentError('Invalid field name: $name. It is a reserved GraphQL keyword.');
    }
    // GraphQL 字段名称必须以字母或下划线开头，只能包含字母、数字和下划线
    if (!RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(name)) {
      throw ArgumentError('Invalid field name: $name. Field names must start with a letter or underscore and only contain letters, numbers, and underscores.');
    }
  }
  
  /// 检查是否是 GraphQL 保留关键字
  static bool _isReservedKeyword(String name) {
    const reservedKeywords = {
      'query', 'mutation', 'subscription', 'fragment', 'on',
      'true', 'false', 'null', 'scalar', 'type', 'interface',
      'union', 'enum', 'input', 'extend', 'directive', 'schema',
      'implements', 'repeatable', 'default', 'specifiedBy'
    };
    return reservedKeywords.contains(name.toLowerCase());
  }
  
  /// 清理字段名称，确保符合 GraphQL 规范
  static String _sanitizeName(String name) {
    if (name == null) return null;
    // 移除所有非法字符
    String sanitized = name.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_');
    // 确保以字母或下划线开头
    if (sanitized.isEmpty || !RegExp(r'^[A-Za-z_]').hasMatch(sanitized)) {
      sanitized = '_' + sanitized;
    }
    return sanitized;
  }
}
