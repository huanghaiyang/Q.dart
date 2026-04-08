/// GraphQL 参数类
class GraphQLArgument {
  /// 参数名称
  final String name;
  
  /// 参数类型
  final String type;
  
  /// 参数默认值
  final dynamic defaultValue;

  /// 构造函数
  GraphQLArgument({
    String name,
    this.type,
    this.defaultValue,
  }) : name = _sanitizeName(name) {
    _validateName(name);
  }

  /// 转换为 SDL 字符串
  String toSDL() {
    StringBuffer sdl = StringBuffer();
    sdl.write('$name: $type');
    
    if (defaultValue != null) {
      sdl.write(' = ');
      if (defaultValue is String) {
        // 转义字符串中的特殊字符
        String escapedValue = _escapeString(defaultValue);
        sdl.write('"$escapedValue"');
      } else {
        sdl.write(defaultValue);
      }
    }
    
    return sdl.toString();
  }
  
  /// 验证参数名称是否符合 GraphQL 规范
  static void _validateName(String name) {
    if (name == null || name.isEmpty) {
      throw ArgumentError('Argument name cannot be null or empty');
    }
    // 检查是否是 GraphQL 保留关键字
    if (_isReservedKeyword(name)) {
      throw ArgumentError('Invalid argument name: $name. It is a reserved GraphQL keyword.');
    }
    // GraphQL 参数名称必须以字母或下划线开头，只能包含字母、数字和下划线
    if (!RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(name)) {
      throw ArgumentError('Invalid argument name: $name. Argument names must start with a letter or underscore and only contain letters, numbers, and underscores.');
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
  
  /// 清理参数名称，确保符合 GraphQL 规范
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
  
  /// 转义字符串中的特殊字符
  static String _escapeString(String value) {
    if (value == null) return null;
    return value
      .replaceAll('\\', '\\\\')  // 转义反斜杠
      .replaceAll('"', '\\"')    // 转义双引号
      .replaceAll('\n', '\\n')     // 转义换行符
      .replaceAll('\r', '\\r')     // 转义回车符
      .replaceAll('\t', '\\t');    // 转义制表符
  }
}
