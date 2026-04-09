import 'dart:async';

import 'DatabaseConnection.dart';
import 'package:mysql1/mysql1.dart';

/// MySQL 数据库连接实现
class MySQLConnection implements DatabaseConnection {
  final String _host;
  final int _port;
  final String _database;
  final String _username;
  final String _password;
  MySqlConnection _connection;
  
  MySQLConnection({
    String host,
    int port = 3306,
    String database,
    String username,
    String password,
  }) : _host = host,
       _port = port,
       _database = database,
       _username = username,
       _password = password {
    _connection = null;
  }

  @override
  Future<List<Map<String, dynamic>>> query(String sql, {List<dynamic> params}) async {
    final connection = await _openConnection();
    final results = await connection.query(sql, params ?? []);
    return results.map((row) => _convertRowToMap(row)).toList();
  }

  @override
  Future<int> execute(String sql, {List<dynamic> params}) async {
    final connection = await _openConnection();
    final result = await connection.query(sql, params ?? []);
    return result.length;
  }

  @override
  Future<int> insert(String sql, {List<dynamic> params}) async {
    final connection = await _openConnection();
    final result = await connection.query(sql, params ?? []);
    // 尝试获取插入的 ID
    if (result.isNotEmpty) {
      final row = result.first;
      // 对于 mysql1 包，Row 没有 keys 方法，需要使用索引访问
      try {
        // 假设第一个字段是 ID
        final id = row[0];
        if (id is int) {
          return id;
        }
      } catch (e) {
        // 忽略错误
      }
    }
    return 0;
  }

  @override
  Future<void> beginTransaction() async {
    final connection = await _openConnection();
    await connection.transaction((ctx) async {
      // 事务开始
    });
  }

  @override
  Future<void> commit() async {
    // MySQL 事务在 transaction 方法中自动提交
  }

  @override
  Future<void> rollback() async {
    // MySQL 事务在 transaction 方法中自动回滚
  }

  @override
  Future<void> close() async {
    if (_connection != null) {
      await _connection.close();
      _connection = null;
    }
  }

  @override
  bool get isOpen => _connection != null;

  @override
  Map<String, dynamic> get connectionInfo {
    return {
      'type': 'MySQL',
      'host': _host,
      'port': _port,
      'database': _database,
      'username': _username,
    };
  }

  /// 打开数据库连接
  Future<MySqlConnection> _openConnection() async {
    if (_connection == null) {
      _connection = await MySqlConnection.connect(ConnectionSettings(
        host: _host,
        port: _port,
        db: _database,
        user: _username,
        password: _password,
      ));
    }
    return _connection;
  }

  /// 将 MySQL 行转换为 Map
  Map<String, dynamic> _convertRowToMap(Row row) {
    final Map<String, dynamic> result = {};
    for (var i = 0; i < row.fields.length; i++) {
      result[row.fields[i].name] = row[i];
    }
    return result;
  }
}
