/// GraphQL 注解类

/// 查询注解
/// 用于标记查询操作的解析器方法
class Query {
  /// 字段名称
  final String name;

  const Query({this.name});
}

/// 变更注解
/// 用于标记变更操作的解析器方法
class Mutation {
  /// 字段名称
  final String name;

  const Mutation({this.name});
}

/// 订阅注解
/// 用于标记订阅操作的解析器方法
class Subscription {
  /// 字段名称
  final String name;

  const Subscription({this.name});
}

/// GraphQL 类型注解
/// 用于标记 GraphQL 类型类
class GraphQLType {
  /// 类型名称
  final String name;

  const GraphQLType({this.name});
}

/// GraphQL 字段注解
/// 用于标记 GraphQL 类型的字段
class GraphQLField {
  /// 字段名称
  final String name;
  
  /// 字段类型
  final String type;

  const GraphQLField({this.name, this.type});
}
