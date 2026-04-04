import 'dart:async';
import 'dart:io';

import 'DatabaseConnection.dart';
import 'package:sqlite3/sqlite3.dart';

/// SQLite 数据库连接实现
class SqliteConnection implements DatabaseConnection {
  final String _databasePath;
  late File _databaseFile;
  Database _db;
  
  SqliteConnection({
    String databasePath,
  }) : _databasePath = databasePath {
    _db = null;
  }

  @override
  Future<List<Map<String, dynamic>>> query(String sql, {List<dynamic> params}) async {
    final db = await _openDatabase();
    final results = db.select(sql, params ?? []);
    return results.map((row) => _convertRowToMap(row)).toList();
  }

  @override
  Future<int> execute(String sql, {List<dynamic> params}) async {
    final db = await _openDatabase();
    final result = db.execute(sql, params ?? []);
    return result;
  }

  @override
  Future<int> insert(String sql, {List<dynamic> params}) async {
    final db = await _openDatabase();
    db.execute(sql, params ?? []);
    return db.lastInsertRowId;
  }

  @override
  Future<void> beginTransaction() async {
    final db = await _openDatabase();
    db.execute('BEGIN TRANSACTION');
  }

  @override
  Future<void> commit() async {
    final db = await _openDatabase();
    db.execute('COMMIT');
  }

  @override
  Future<void> rollback() async {
    final db = await _openDatabase();
    db.execute('ROLLBACK');
  }

  @override
  Future<void> close() async {
    if (_db != null) {
      _db.dispose();
      _db = null;
    }
  }

  @override
  bool get isOpen => _db != null;

  @override
  Map<String, dynamic> get connectionInfo {
    return {
      'type': 'SQLite',
      'databasePath': _databasePath,
    };
  }

  /// 打开数据库连接
  Future<Database> _openDatabase() async {
    if (_db == null) {
      _databaseFile = File(_databasePath);
      _db = sqlite3.open(_databasePath);
    }
    return _db;
  }

  /// 将 SQLite 行转换为 Map
  Map<String, dynamic> _convertRowToMap(Row row) {
    final Map<String, dynamic> result = {};
    for (int i = 0; i < row.columnCount; i++) {
      result[row.columnName(i)] = row[i];
    }
    return result;
  }
}
