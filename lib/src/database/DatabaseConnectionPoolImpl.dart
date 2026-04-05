import 'dart:async';
import 'dart:collection';

import 'DatabaseConnection.dart';
import 'DatabaseConnectionPool.dart';
import 'package:synchronized/synchronized.dart';

/// 数据库连接池实现
class DatabaseConnectionPoolImpl implements DatabaseConnectionPool {
  final DatabasePoolConfig _config;
  final Future<DatabaseConnection> Function() _connectionFactory;
  
  final Queue<DatabaseConnection> _availableConnections = Queue();
  final Set<DatabaseConnection> _inUseConnections = Set();
  final Map<DatabaseConnection, DateTime> _connectionCreationTime = {};
  
  // 细粒度锁
  final Lock _connectionLock = Lock();
  final Lock _statusLock = Lock();
  
  // 连接创建计数器
  int _connectionCount = 0;
  
  DatabaseConnectionPoolImpl({
    DatabasePoolConfig config,
    Future<DatabaseConnection> Function() connectionFactory,
  }) : _config = config, _connectionFactory = connectionFactory {
    // 初始化最小连接数
    _initializeMinConnections();
  }

  /// 初始化最小连接数
  Future<void> _initializeMinConnections() async {
    if (_config.minConnections > 0) {
      await _connectionLock.synchronized(() async {
        for (int i = 0; i < _config.minConnections; i++) {
          if (_connectionCount < _config.maxConnections) {
            try {
              final connection = await _connectionFactory();
              _availableConnections.add(connection);
              _connectionCreationTime[connection] = DateTime.now();
              _connectionCount++;
            } catch (e) {
              print('Error creating initial connection: $e');
            }
          }
        }
      });
    }
  }

  @override
  Future<DatabaseConnection> getConnection() async {
    return await _connectionLock.synchronized(() async {
      // 尝试从可用连接队列获取
      if (_availableConnections.isNotEmpty) {
        final connection = _availableConnections.removeFirst();
        _inUseConnections.add(connection);
        return connection;
      }
      
      // 检查是否达到最大连接数
      if (_connectionCount >= _config.maxConnections) {
        // 等待可用连接（可选：添加超时机制）
        return await _waitForAvailableConnection();
      }
      
      // 创建新连接
      final connection = await _createConnection();
      _inUseConnections.add(connection);
      return connection;
    });
  }

  /// 等待可用连接
  Future<DatabaseConnection> _waitForAvailableConnection() async {
    final completer = Completer<DatabaseConnection>();
    
    // 简单的轮询策略，可根据需要优化为更高效的通知机制
    for (int i = 0; i < 5; i++) { // 最多尝试5次
      await Future.delayed(Duration(milliseconds: 100));
      
      if (_availableConnections.isNotEmpty) {
        final connection = _availableConnections.removeFirst();
        _inUseConnections.add(connection);
        completer.complete(connection);
        return connection;
      }
    }
    
    throw Exception('Maximum number of connections reached and no connections available');
  }

  /// 创建新连接
  Future<DatabaseConnection> _createConnection() async {
    final connection = await _connectionFactory();
    _connectionCreationTime[connection] = DateTime.now();
    _connectionCount++;
    return connection;
  }

  @override
  Future<void> releaseConnection(DatabaseConnection connection) async {
    await _connectionLock.synchronized(() async {
      if (!_inUseConnections.contains(connection)) {
        return;
      }
      
      _inUseConnections.remove(connection);
      
      // 检查连接是否过期
      final creationTime = _connectionCreationTime[connection];
      if (creationTime == null) {
        await _closeConnection(connection);
        return;
      }
      
      final age = DateTime.now().difference(creationTime).inMilliseconds;
      
      if (age > _config.maxLifetime || !connection.isOpen) {
        await _closeConnection(connection);
      } else {
        _availableConnections.add(connection);
      }
    });
  }

  /// 关闭连接并清理资源
  Future<void> _closeConnection(DatabaseConnection connection) async {
    try {
      await connection.close();
    } catch (e) {
      print('Error closing connection: $e');
    } finally {
      _connectionCreationTime.remove(connection);
      _connectionCount = _connectionCount > 0 ? _connectionCount - 1 : 0;
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
    await _connectionLock.synchronized(() async {
      // 关闭所有连接
      final allConnections = [..._availableConnections, ..._inUseConnections];
      for (final connection in allConnections) {
        await _closeConnection(connection);
      }
      
      _availableConnections.clear();
      _inUseConnections.clear();
      _connectionCreationTime.clear();
      _connectionCount = 0;
    });
  }

  @override
  Map<String, dynamic> get poolStatus {
    return {
      'availableConnections': _availableConnections.length,
      'inUseConnections': _inUseConnections.length,
      'totalConnections': _connectionCount,
      'maxConnections': _config.maxConnections,
      'minConnections': _config.minConnections,
    };
  }

  @override
  DatabasePoolConfig get config => _config;
}
