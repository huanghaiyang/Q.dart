import 'dart:async';

import 'DatabaseConnection.dart';
import 'DatabaseConnectionPool.dart';

/// 数据库连接池实现
class DatabaseConnectionPoolImpl implements DatabaseConnectionPool {
  final DatabasePoolConfig _config;
  final Future<DatabaseConnection> Function() _connectionFactory;
  
  List<DatabaseConnection> _availableConnections = [];
  List<DatabaseConnection> _inUseConnections = [];
  final Map<DatabaseConnection, DateTime> _connectionCreationTime = {};
  
  DatabaseConnectionPoolImpl({
    DatabasePoolConfig config,
    Future<DatabaseConnection> Function() connectionFactory,
  }) : _config = config, _connectionFactory = connectionFactory;

  @override
  Future<DatabaseConnection> getConnection() async {
    // 检查是否有可用连接
    if (_availableConnections.isNotEmpty) {
      final connection = _availableConnections.removeLast();
      _inUseConnections.add(connection);
      return connection;
    }
    
    // 检查是否达到最大连接数
    if (_inUseConnections.length >= _config.maxConnections) {
      throw Exception('Maximum number of connections reached');
    }
    
    // 创建新连接
    final connection = await _connectionFactory();
    _connectionCreationTime[connection] = DateTime.now();
    _inUseConnections.add(connection);
    return connection;
  }

  @override
  Future<void> releaseConnection(DatabaseConnection connection) async {
    if (!_inUseConnections.contains(connection)) {
      return;
    }
    
    _inUseConnections.remove(connection);
    
    // 检查连接是否过期
    final creationTime = _connectionCreationTime[connection];
    if (creationTime == null) {
      await connection.close();
      _connectionCreationTime.remove(connection);
      return;
    }
    
    final age = DateTime.now().difference(creationTime).inMilliseconds;
    
    if (age > _config.maxLifetime) {
      await connection.close();
      _connectionCreationTime.remove(connection);
    } else {
      _availableConnections.add(connection);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> query(String sql, {List<dynamic> params}) async {
    final connection = await getConnection();
    try {
      final result = await connection.query(sql, params: params);
      return result;
    } finally {
      await releaseConnection(connection);
    }
  }

  @override
  Future<int> execute(String sql, {List<dynamic> params}) async {
    final connection = await getConnection();
    try {
      final result = await connection.execute(sql, params: params);
      return result;
    } finally {
      await releaseConnection(connection);
    }
  }

  @override
  Future<int> insert(String sql, {List<dynamic> params}) async {
    final connection = await getConnection();
    try {
      final result = await connection.insert(sql, params: params);
      return result;
    } finally {
      await releaseConnection(connection);
    }
  }

  @override
  Future<T> transaction<T>(Future<T> Function(DatabaseConnection connection) callback) async {
    final connection = await getConnection();
    try {
      await connection.beginTransaction();
      final result = await callback(connection);
      await connection.commit();
      return result;
    } catch (e) {
      await connection.rollback();
      rethrow;
    } finally {
      await releaseConnection(connection);
    }
  }

  @override
  Future<void> close() async {
    // 关闭所有连接
    for (final connection in [..._availableConnections, ..._inUseConnections]) {
      try {
        await connection.close();
      } catch (e) {
        print('Error closing connection: $e');
      }
    }
    
    _availableConnections.clear();
    _inUseConnections.clear();
    _connectionCreationTime.clear();
  }

  @override
  Map<String, dynamic> get poolStatus {
    return {
      'availableConnections': _availableConnections.length,
      'inUseConnections': _inUseConnections.length,
      'totalConnections': _availableConnections.length + _inUseConnections.length,
      'maxConnections': _config.maxConnections,
      'minConnections': _config.minConnections,
    };
  }

  @override
  DatabasePoolConfig get config => _config;
}
