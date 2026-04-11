import 'dart:async';
import 'package:Q/src/Router.dart';
import 'ConnectionPool.dart';

const int MAX_CONCURRENT_CONNECTIONS = 1000;

class RouterConnectionPool {
  // 全局连接池
  final ConnectionPool _globalPool;
  
  // 构造函数
  RouterConnectionPool({
    int maxConcurrentConnections = MAX_CONCURRENT_CONNECTIONS,
    Duration connectionTimeout = const Duration(seconds: 30)
  }) : _globalPool = ConnectionPool(
          maxConcurrentConnections: maxConcurrentConnections,
          connectionTimeout: connectionTimeout
        );
  
  // 获取连接
  Future<Connection> acquireConnection() async {
    return await _globalPool.acquire();
  }
  
  // 释放连接
  void releaseConnection(Connection connection) {
    _globalPool.release(connection);
  }
  
  // 关闭连接池
  Future<void> close() async {
    await _globalPool.close();
  }
  
  // 获取连接池状态
  Map<String, dynamic> getStatus() {
    return _globalPool.getStatus();
  }
  
  // 获取连接超时时间
  Duration get connectionTimeout {
    return _globalPool.connectionTimeout;
  }
  
  // 获取最大并发连接数
  int get maxConcurrentConnections {
    return _globalPool.maxConcurrentConnections;
  }
}
