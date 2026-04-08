/// GraphQL 解析器类
/// 用于处理 GraphQL 查询的解析逻辑
class _GraphQLResolver {
  /// 解析器映射
  final Map<String, Map<String, Function>> resolvers;

  /// 构造函数
  _GraphQLResolver({this.resolvers = const {}});

  /// 添加类型解析器
  void addTypeResolver(String typeName, Map<String, Function> typeResolvers) {
    resolvers[typeName] = typeResolvers;
  }

  /// 添加字段解析器
  void addFieldResolver(String typeName, String fieldName, Function resolver) {
    if (!resolvers.containsKey(typeName)) {
      resolvers[typeName] = {};
    }
    resolvers[typeName][fieldName] = resolver;
  }

  /// 获取类型解析器
  Map<String, Function> getTypeResolver(String typeName) {
    return resolvers[typeName] ?? {};
  }

  /// 获取字段解析器
  Function getFieldResolver(String typeName, String fieldName) {
    Map<String, Function> typeResolvers = getTypeResolver(typeName);
    return typeResolvers[fieldName];
  }

  /// 解析字段
  Future<dynamic> resolveField(String typeName, String fieldName, dynamic parent, Map<String, dynamic> args, Map<String, dynamic> context) async {
    // 检查类型名称是否为空
    if (typeName == null || typeName.isEmpty) {
      throw Exception('Type name cannot be null or empty');
    }
    
    // 检查字段名称是否为空
    if (fieldName == null || fieldName.isEmpty) {
      throw Exception('Field name cannot be null or empty');
    }
    
    // 检查参数是否为 null
    args ??= {};
    
    // 获取解析器
    Function resolver = getFieldResolver(typeName, fieldName);
    
    if (resolver != null) {
      try {
        // 执行解析器
        dynamic result = await resolver(parent, args, context);
        return result;
      } catch (e) {
        throw Exception('Error executing resolver for $typeName.$fieldName: ${e.toString()}');
      }
    }
    
    // 如果没有找到解析器，尝试从父对象中获取字段
    if (parent is Map && parent.containsKey(fieldName)) {
      return parent[fieldName];
    }
    
    // 尝试从父对象的属性中获取字段（对于非 Map 类型）
    if (parent != null) {
      try {
        InstanceMirror instanceMirror = reflect(parent);
        Symbol fieldSymbol = Symbol(fieldName);
        if (instanceMirror.type.declarations.containsKey(fieldSymbol)) {
          return instanceMirror.getField(fieldSymbol).reflectee;
        }
      } catch (e) {
        // 忽略反射错误
      }
    }
    
    // 字段不存在
    throw Exception('Field $fieldName not found in type $typeName');
  }
}
