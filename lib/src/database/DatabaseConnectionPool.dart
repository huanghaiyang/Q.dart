import 'dart:async';

import 'DatabaseConnection.dart';

/// 数据库连接池配置
class DatabasePoolConfig {
  /// 最大连接数
  final int maxConnections;
  
  /// 最小空闲连接数
  final int minConnections;
  
  /// 连接超时时间（毫秒）
  final int connectionTimeout;
  
  /// 空闲连接超时时间（毫秒）
  final int idleTimeout;
  
  /// 最大连接生命周期（毫秒）
  final int maxLifetime;
  
  DatabasePoolConfig({
    this.maxConnections = 10,
    this.minConnections = 2,
    this.connectionTimeout = 30000,
    this.idleTimeout = 600000,
    this.maxLifetime = 1800000,
  });
}

/// 数据库连接池接口
abstract class DatabaseConnectionPool {
  /// 获取一个数据库连接
  /// 
  /// 返回数据库连接
  Future<DatabaseConnection> getConnection();

  /// 释放数据库连接回连接池
  /// 
  /// [connection] 要释放的连接
  Future<void> releaseConnection(DatabaseConnection connection);

  /// 执行查询（自动获取和释放连接）
  /// 
  /// [sql] SQL 语句
  /// [params] 查询参数
  /// 
  /// 返回查询结果列表
  Future<List<Map<String, dynamic>>> query(String sql, {List<dynamic> params});

  /// 执行更新（自动获取和释放连接）
  /// 
  /// [sql] SQL 语句
  /// [params] 查询参数
  /// 
  /// 返回影响的行数
  Future<int> execute(String sql, {List<dynamic> params});

  /// 执行插入（自动获取和释放连接）
  /// 
  /// [sql] SQL 语句
  /// [params] 查询参数
  /// 
  /// 返回插入的 ID
  Future<int> insert(String sql, {List<dynamic> params});

  /// 执行事务（自动获取和释放连接）
  /// 
  /// [callback] 事务回调函数
  /// 
  /// 返回事务执行结果
  Future<T> transaction<T>(Future<T> Function(DatabaseConnection connection) callback);

  /// 关闭连接池
  Future<void> close();

  /// 获取连接池状态
  Map<String, dynamic> get poolStatus;

  /// 获取连接池配置
  DatabasePoolConfig get config;
}
