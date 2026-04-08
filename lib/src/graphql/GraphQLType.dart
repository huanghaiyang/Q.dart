import 'package:Q/src/graphql/GraphQLField.dart';

/// GraphQL 类型抽象类
abstract class GraphQLType {
  /// 类型名称
  final String name;

  /// 构造函数
  GraphQLType(String name) : name = _sanitizeName(name) {
    _validateName(name);
  }

  /// 转换为 SDL 字符串
  String toSDL();
  
  /// 验证名称是否符合 GraphQL 规范
  static void _validateName(String name) {
    if (name == null || name.isEmpty) {
      throw ArgumentError('Type name cannot be null or empty');
    }
    // 检查是否是 GraphQL 保留关键字
    if (_isReservedKeyword(name)) {
      throw ArgumentError('Invalid type name: $name. It is a reserved GraphQL keyword.');
    }
    // GraphQL 类型名称必须以字母开头，只能包含字母、数字和下划线
    if (!RegExp(r'^[A-Za-z][A-Za-z0-9_]*$').hasMatch(name)) {
      throw ArgumentError('Invalid type name: $name. Type names must start with a letter and only contain letters, numbers, and underscores.');
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
  
  /// 清理名称，确保符合 GraphQL 规范
  static String _sanitizeName(String name) {
    if (name == null) return null;
    // 移除所有非法字符
    String sanitized = name.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_');
    // 确保以字母开头
    if (sanitized.isEmpty || !RegExp(r'^[A-Za-z]').hasMatch(sanitized)) {
      sanitized = 'Type_' + sanitized;
    }
    return sanitized;
  }
}

/// GraphQL 对象类型
class GraphQLObjectType extends GraphQLType {
  /// 字段定义
  final Map<String, GraphQLField> fields;

  /// 构造函数
  GraphQLObjectType(String name, {this.fields = const {}}) : super(name);

  @override
  String toSDL() {
    StringBuffer sdl = StringBuffer();
    sdl.writeln('type $name {');
    for (var field in fields.values) {
      sdl.writeln('  ${field.toSDL()}');
    }
    sdl.writeln('}');
    return sdl.toString();
  }
}

/// GraphQL 标量类型
class GraphQLScalarType extends GraphQLType {
  /// 构造函数
  GraphQLScalarType(String name) : super(name);

  @override
  String toSDL() {
    return 'scalar $name';
  }
}

/// GraphQL 接口类型
class GraphQLInterfaceType extends GraphQLType {
  /// 字段定义
  final Map<String, GraphQLField> fields;

  /// 构造函数
  GraphQLInterfaceType(String name, {this.fields = const {}}) : super(name);

  @override
  String toSDL() {
    StringBuffer sdl = StringBuffer();
    sdl.writeln('interface $name {');
    for (var field in fields.values) {
      sdl.writeln('  ${field.toSDL()}');
    }
    sdl.writeln('}');
    return sdl.toString();
  }
}

/// GraphQL 联合类型
class GraphQLUnionType extends GraphQLType {
  /// 成员类型
  final List<GraphQLType> types;

  /// 构造函数
  GraphQLUnionType(String name, {this.types = const []}) : super(name);

  @override
  String toSDL() {
    StringBuffer sdl = StringBuffer();
    sdl.write('union $name = ');
    sdl.write(types.map((type) => type.name).join(' | '));
    return sdl.toString();
  }
}

/// GraphQL 枚举类型
class GraphQLEnumType extends GraphQLType {
  /// 枚举值
  final List<String> values;

  /// 构造函数
  GraphQLEnumType(String name, {this.values = const []}) : super(name);

  @override
  String toSDL() {
    StringBuffer sdl = StringBuffer();
    sdl.writeln('enum $name {');
    for (var value in values) {
      sdl.writeln('  $value');
    }
    sdl.writeln('}');
    return sdl.toString();
  }
}

/// GraphQL 输入类型
class GraphQLInputObjectType extends GraphQLType {
  /// 字段定义
  final Map<String, GraphQLField> fields;

  /// 构造函数
  GraphQLInputObjectType(String name, {this.fields = const {}}) : super(name);

  @override
  String toSDL() {
    StringBuffer sdl = StringBuffer();
    sdl.writeln('input $name {');
    for (var field in fields.values) {
      sdl.writeln('  ${field.toSDL()}');
    }
    sdl.writeln('}');
    return sdl.toString();
  }
}
