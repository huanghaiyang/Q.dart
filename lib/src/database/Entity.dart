/// 实体注解
/// 用于标记数据库实体类
class Entity {
  /// 表名
  final String tableName;
  
  /// 主键字段名
  final String primaryKey;
  
  /// 是否自动生成 ID
  final bool autoIncrement;
  
  /// 表前缀
  final String tablePrefix;
  
  const Entity({
    this.tableName,
    this.primaryKey = 'id',
    this.autoIncrement = true,
    this.tablePrefix,
  });
}

/// 列注解
/// 用于标记实体类中的字段
class Column {
  /// 列名
  final String name;
  
  /// 数据库类型
  final String type;
  
  /// 是否为主键
  final bool isPrimaryKey;
  
  /// 是否自动递增
  final bool autoIncrement;
  
  /// 是否可为空
  final bool nullable;
  
  /// 默认值
  final dynamic defaultValue;
  
  /// 是否唯一
  final bool unique;
  
  /// 列长度
  final int length;
  
  /// 列注释
  final String comment;
  
  const Column({
    this.name,
    this.type,
    this.isPrimaryKey = false,
    this.autoIncrement = false,
    this.nullable = true,
    this.defaultValue,
    this.unique = false,
    this.length,
    this.comment,
  });
}

/// 索引注解
/// 用于标记需要创建索引的字段
class Index {
  /// 索引名
  final String name;
  
  /// 索引字段
  final List<String> fields;
  
  /// 是否唯一索引
  final bool unique;
  
  const Index({
    this.name,
    this.fields,
    this.unique = false,
  });
}

/// 关系注解
/// 用于标记实体之间的关系
class Relation {
  /// 关系类型
  final RelationType type;
  
  /// 目标实体类型
  final Type targetEntity;
  
  /// 外键字段名
  final String foreignKey;
  
  /// 目标字段名
  final String targetKey;
  
  /// 关系名称
  final String name;
  
  const Relation({
    this.type,
    this.targetEntity,
    this.foreignKey,
    this.targetKey,
    this.name,
  });
}

/// 关系类型枚举
enum RelationType {
  /// 一对一
  ONE_TO_ONE,
  
  /// 一对多
  ONE_TO_MANY,
  
  /// 多对一
  MANY_TO_ONE,
  
  /// 多对多
  MANY_TO_MANY,
}
