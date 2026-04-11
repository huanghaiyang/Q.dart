import 'dart:async';
import 'dart:collection';

class ConnectionPool {
  // 最大并发连接数
  int _maxConcurrentConnections;
  
  // 连接超时时间
  Duration _connectionTimeout;
  
  // 可用连接队列
  final Queue<Connection> _availableConnections = Queue();
  
  // 正在使用的连接数
  int _inUseConnections = 0;
  
  // 等待连接的请求队列
  final Queue<Completer<Connection>> _waitQueue = Queue();
  
  // 连接池是否关闭
  bool _closed = false;
  
  // 统计信息
  int _totalConnectionsCreated = 0;
  int _totalConnectionsReleased = 0;
  int _totalConnectionsClosed = 0;
  
  ConnectionPool({
    int maxConcurrentConnections = 100,
    Duration connectionTimeout = const Duration(seconds: 30)
  }) : _maxConcurrentConnections = maxConcurrentConnections,
       _connectionTimeout = connectionTimeout;
  
  // 获取连接
  Future<Connection> acquire() async {
    if (_closed) {
      throw Exception('Connection pool is closed');
    }
    
    // 如果有可用连接，直接返回
    if (_availableConnections.isNotEmpty) {
      Connection connection = _availableConnections.removeFirst();
      // 检查连接是否有效
      if (connection.isValid) {
        _inUseConnections++;
        return connection;
      } else {
        // 连接无效，创建新连接
        Connection newConnection = Connection(this);
        _totalConnectionsCreated++;
        _inUseConnections++;
        return newConnection;
      }
    }
    
    // 检查是否超过最大并发连接数
    if (_inUseConnections < _maxConcurrentConnections) {
      // 未超过最大并发连接数，创建新连接
      Connection connection = Connection(this);
      _totalConnectionsCreated++;
      _inUseConnections++;
      return connection;
    } else {
      // 超过最大并发连接数，等待可用连接
      Completer<Connection> completer = Completer<Connection>();
      _waitQueue.add(completer);
      // 添加超时处理，避免无限等待
      Future.delayed(_connectionTimeout, () {
        if (!completer.isCompleted) {
          // 从等待队列中移除
          _waitQueue.remove(completer);
          completer.completeError(Exception('Connection acquisition timeout'));
        }
      });
      return completer.future;
    }
  }
  
  // 释放连接
  void release(Connection connection) {
    if (_closed) {
      connection.close();
      _totalConnectionsClosed++;
      return;
    }
    
    _inUseConnections--;
    _totalConnectionsReleased++;
    
    // 检查连接是否有效
    if (!connection.isValid) {
      // 连接无效，直接关闭
      connection.close();
      _totalConnectionsClosed++;
      return;
    }
    
    // 如果有等待的请求，直接分配连接
    if (_waitQueue.isNotEmpty) {
      Completer<Connection> completer = _waitQueue.removeFirst();
      try {
        completer.complete(connection);
      } catch (e) {
        // 忽略已完成的completer
        connection.close();
        _totalConnectionsClosed++;
      }
    } else {
      // 否则，将连接放回可用队列
      _availableConnections.add(connection);
    }
  }
  
  // 关闭连接池
  Future<void> close() async {
    _closed = true;
    
    // 拒绝所有等待的请求
    while (_waitQueue.isNotEmpty) {
      Completer<Connection> completer = _waitQueue.removeFirst();
      completer.completeError(Exception('Connection pool is closed'));
    }
    
    // 关闭所有可用连接
    while (_availableConnections.isNotEmpty) {
      Connection connection = _availableConnections.removeFirst();
      connection.close();
      _totalConnectionsClosed++;
    }
  }
  
  // 获取连接池状态
  Map<String, dynamic> getStatus() {
    return {
      'maxConcurrentConnections': _maxConcurrentConnections,
      'inUseConnections': _inUseConnections,
      'availableConnections': _availableConnections.length,
      'waitQueueLength': _waitQueue.length,
      'closed': _closed,
      'totalConnectionsCreated': _totalConnectionsCreated,
      'totalConnectionsReleased': _totalConnectionsReleased,
      'totalConnectionsClosed': _totalConnectionsClosed
    };
  }
  
  // 获取连接超时时间
  Duration get connectionTimeout {
    return _connectionTimeout;
  }
  
  // 获取最大并发连接数
  int get maxConcurrentConnections {
    return _maxConcurrentConnections;
  }
}

class Connection {
  // 连接所属的连接池
  final ConnectionPool pool;
  
  // 连接创建时间
  final DateTime createdAt;
  
  // 连接是否关闭
  bool _closed = false;
  
  Connection(this.pool)
    : createdAt = DateTime.now();
  
  // 关闭连接
  void close() {
    _closed = true;
  }
  
  // 检查连接是否有效
  bool get isValid {
    return !_closed && DateTime.now().difference(createdAt) < pool._connectionTimeout;
  }
  
  // 释放连接
  void release() {
    if (!_closed) {
      pool.release(this);
    }
  }
}
