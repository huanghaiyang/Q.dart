import 'dart:async';

/// 数据库连接接口
abstract class DatabaseConnection {
  /// 执行 SQL 查询
  /// 
  /// [sql] SQL 语句
  /// [params] 查询参数
  /// 
  /// 返回查询结果列表
  Future<List<Map<String, dynamic>>> query(String sql, {List<dynamic> params});

  /// 执行 SQL 更新
  /// 
  /// [sql] SQL 语句
  /// [params] 查询参数
  /// 
  /// 返回影响的行数
  Future<int> execute(String sql, {List<dynamic> params});

  /// 执行 SQL 插入
  /// 
  /// [sql] SQL 语句
  /// [params] 查询参数
  /// 
  /// 返回插入的 ID
  Future<int> insert(String sql, {List<dynamic> params});

  /// 开始事务
  Future<void> beginTransaction();

  /// 提交事务
  Future<void> commit();

  /// 回滚事务
  Future<void> rollback();

  /// 关闭连接
  Future<void> close();

  /// 检查连接是否打开
  bool get isOpen;

  /// 获取连接信息
  Map<String, dynamic> get connectionInfo;
}
