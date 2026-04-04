import 'DatabaseConnectionPool.dart';

/// 迁移基类
abstract class Migration {
  /// 迁移版本号
  final int version;
  
  /// 迁移描述
  final String description;
  
  const Migration({
    this.version,
    this.description,
  });
  
  /// 向上迁移（升级数据库）
  /// 
  /// [connectionPool] 数据库连接池
  Future<void> up(DatabaseConnectionPool connectionPool);
  
  /// 向下迁移（降级数据库）
  /// 
  /// [connectionPool] 数据库连接池
  Future<void> down(DatabaseConnectionPool connectionPool);
}
