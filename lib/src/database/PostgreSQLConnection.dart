import 'dart:async';
import 'package:postgres/postgres.dart' as pg;
import 'DatabaseConnection.dart';

class PostgreSQLConnection implements DatabaseConnection {
  final String _host;
  final int _port;
  final String _database;
  final String _username;
  final String _password;
  pg.PostgreSQLConnection _connection;

  PostgreSQLConnection({
    String host,
    int port = 5432,
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
    final results = await connection.mappedResultsQuery(sql, substitutionValues: params != null ? _convertParamsToMap(params) : null);
    return _convertResultsToMapList(results);
  }

  @override
  Future<int> execute(String sql, {List<dynamic> params}) async {
    final connection = await _openConnection();
    final result = await connection.execute(sql, substitutionValues: params != null ? _convertParamsToMap(params) : null);
    return result.affectedRowCount;
  }

  @override
  Future<int> insert(String sql, {List<dynamic> params}) async {
    final connection = await _openConnection();
    final results = await connection.mappedResultsQuery(sql, substitutionValues: params != null ? _convertParamsToMap(params) : null);
    if (results.isNotEmpty) {
      final firstRow = results.first;
      for (final key in firstRow.keys) {
        final value = firstRow[key];
        if (value is int) {
          return value;
        }
      }
    }
    return 0;
  }

  @override
  Future<void> beginTransaction() async {
    final connection = await _openConnection();
    await connection.execute('BEGIN');
  }

  @override
  Future<void> commit() async {
    final connection = await _openConnection();
    await connection.execute('COMMIT');
  }

  @override
  Future<void> rollback() async {
    final connection = await _openConnection();
    await connection.execute('ROLLBACK');
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
      'type': 'PostgreSQL',
      'host': _host,
      'port': _port,
      'database': _database,
      'username': _username,
    };
  }

  Future<pg.PostgreSQLConnection> _openConnection() async {
    if (_connection == null) {
      _connection = pg.PostgreSQLConnection(
        _host,
        _port,
        _database,
        username: _username,
        password: _password,
      );
      await _connection.open();
    }
    return _connection;
  }

  Map<String, dynamic> _convertParamsToMap(List<dynamic> params) {
    final result = <String, dynamic>{};
    for (int i = 0; i < params.length; i++) {
      result['@${i + 1}'] = params[i];
    }
    return result;
  }

  List<Map<String, dynamic>> _convertResultsToMapList(List<Map<String, Map<String, dynamic>>> results) {
    return results.map((row) {
      final map = <String, dynamic>{};
      for (final tableName in row.keys) {
        final tableRow = row[tableName];
        if (tableRow != null) {
          map.addAll(tableRow);
        }
      }
      return map;
    }).toList();
  }
}
