import 'dart:async';

import 'DatabaseConnectionPool.dart';
import 'Migration.dart';

/// 迁移运行器配置
class MigrationRunnerConfig {
  /// 迁移表名
  final String migrationTable;
  
  /// 是否自动创建迁移表
  final bool autoCreateMigrationTable;
  
  MigrationRunnerConfig({
    this.migrationTable = 'schema_migrations',
    this.autoCreateMigrationTable = true,
  });
}

/// 迁移运行器
class MigrationRunner {
  final DatabaseConnectionPool _connectionPool;
  final List<Migration> _migrations;
  final MigrationRunnerConfig _config;
  
  MigrationRunner({
    DatabaseConnectionPool connectionPool,
    List<Migration> migrations,
    MigrationRunnerConfig config,
  }) : _connectionPool = connectionPool,
       _migrations = migrations,
       _config = config;

  /// 运行所有待执行的迁移
  Future<void> run() async {
    if (_config.autoCreateMigrationTable) {
      await _createMigrationTable();
    }
    
    final currentVersion = await _getCurrentVersion();
    final pendingMigrations = _migrations
        .where((migration) => migration.version > currentVersion)
        .toList();
    
    if (pendingMigrations.isEmpty) {
      print('Database is up to date. Current version: $currentVersion');
      return;
    }
    
    print('Running ${pendingMigrations.length} migration(s)...');
    
    for (final migration in pendingMigrations) {
      print('Running migration ${migration.version}: ${migration.description}');
      await _runMigration(migration);
      await _recordMigration(migration);
      print('Migration ${migration.version} completed');
    }
    
    final newVersion = await _getCurrentVersion();
    print('Database migrated to version $newVersion');
  }

  /// 回滚迁移到指定版本
  Future<void> rollback(int targetVersion) async {
    final currentVersion = await _getCurrentVersion();
    
    if (currentVersion <= targetVersion) {
      print('Database is already at version $currentVersion');
      return;
    }
    
    final migrationsToRollback = _migrations
        .where((migration) => 
            migration.version > targetVersion && 
            migration.version <= currentVersion)
        .toList()
        .reversed;
    
    print('Rolling back ${migrationsToRollback.length} migration(s)...');
    
    for (final migration in migrationsToRollback) {
      print('Rolling back migration ${migration.version}: ${migration.description}');
      await _runDownMigration(migration);
      await _removeMigration(migration);
      print('Migration ${migration.version} rolled back');
    }
    
    print('Database rolled back to version $targetVersion');
  }

  /// 创建迁移表
  Future<void> _createMigrationTable() async {
    final tableExists = await _tableExists(_config.migrationTable);
    
    if (!tableExists) {
      await _connectionPool.execute('''
        CREATE TABLE ${_config.migrationTable} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          version INTEGER NOT NULL UNIQUE,
          description TEXT NOT NULL,
          executed_at INTEGER NOT NULL
        )
      ''');
      print('Migration table created: ${_config.migrationTable}');
    }
  }

  /// 检查表是否存在
  Future<bool> _tableExists(String tableName) async {
    final results = await _connectionPool.query(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      params: [tableName],
    );
    return results.isNotEmpty;
  }

  /// 获取当前数据库版本
  Future<int> _getCurrentVersion() async {
    final results = await _connectionPool.query(
      'SELECT MAX(version) as version FROM ${_config.migrationTable}',
    );
    
    if (results.isEmpty || results.first['version'] == null) {
      return 0;
    }
    
    return results.first['version'] as int;
  }

  /// 运行向上迁移
  Future<void> _runMigration(Migration migration) async {
    await _connectionPool.transaction((connection) async {
      await migration.up(_connectionPool);
    });
  }

  /// 运行向下迁移
  Future<void> _runDownMigration(Migration migration) async {
    await _connectionPool.transaction((connection) async {
      await migration.down(_connectionPool);
    });
  }

  /// 记录已执行的迁移
  Future<void> _recordMigration(Migration migration) async {
    await _connectionPool.execute(
      'INSERT INTO ${_config.migrationTable} (version, description, executed_at) VALUES (?, ?, ?)',
      params: [
        migration.version,
        migration.description,
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
      ],
    );
  }

  /// 移除迁移记录
  Future<void> _removeMigration(Migration migration) async {
    await _connectionPool.execute(
      'DELETE FROM ${_config.migrationTable} WHERE version = ?',
      params: [migration.version],
    );
  }

  /// 获取迁移状态
  Future<Map<String, dynamic>> getStatus() async {
    final currentVersion = await _getCurrentVersion();
    final pendingMigrations = _migrations
        .where((migration) => migration.version > currentVersion)
        .toList()
        .length;
    
    return {
      'currentVersion': currentVersion,
      'latestVersion': _migrations.isEmpty ? 0 : _migrations.last.version,
      'pendingMigrations': pendingMigrations,
      'totalMigrations': _migrations.length,
      'isUpToDate': pendingMigrations == 0,
    };
  }
}
