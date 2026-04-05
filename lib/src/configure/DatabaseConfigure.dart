import 'package:Q/src/ApplicationConfiguration.dart';
import 'package:Q/src/configure/AbstractConfigure.dart';
import 'package:Q/src/configure/ApplicationConfigurationNames.dart';

abstract class DatabaseConfigure extends AbstractConfigure {
  factory DatabaseConfigure() => _DatabaseConfigure();

  String get type;
  set type(String type);

  DatabaseConnectionConfigure get connection;
  set connection(DatabaseConnectionConfigure connection);

  DatabasePoolConfigure get pool;
  set pool(DatabasePoolConfigure pool);

  DatabaseMigrationConfigure get migration;
  set migration(DatabaseMigrationConfigure migration);
}

class _DatabaseConfigure implements DatabaseConfigure {
  String _type;
  DatabaseConnectionConfigure _connection = DatabaseConnectionConfigure();
  DatabasePoolConfigure _pool = DatabasePoolConfigure();
  DatabaseMigrationConfigure _migration = DatabaseMigrationConfigure();

  _DatabaseConfigure();

  @override
  String get type => _type;

  @override
  set type(String type) => _type = type;

  @override
  DatabaseConnectionConfigure get connection => _connection;

  @override
  set connection(DatabaseConnectionConfigure connection) => _connection = connection;

  @override
  DatabasePoolConfigure get pool => _pool;

  @override
  set pool(DatabasePoolConfigure pool) => _pool = pool;

  @override
  DatabaseMigrationConfigure get migration => _migration;

  @override
  set migration(DatabaseMigrationConfigure migration) => _migration = migration;

  @override
  Future<dynamic> init(ApplicationConfiguration applicationConfiguration) async {
    _type = applicationConfiguration.get(DATABASE_TYPE);
    _connection.path = applicationConfiguration.get(DATABASE_CONNECTION_PATH);
    _connection.host = applicationConfiguration.get(DATABASE_CONNECTION_HOST);
    _connection.port = applicationConfiguration.get(DATABASE_CONNECTION_PORT);
    _connection.database = applicationConfiguration.get(DATABASE_CONNECTION_DATABASE);
    _connection.username = applicationConfiguration.get(DATABASE_CONNECTION_USERNAME);
    _connection.password = applicationConfiguration.get(DATABASE_CONNECTION_PASSWORD);
    _pool.maxConnections = applicationConfiguration.get(DATABASE_POOL_MAX_CONNECTIONS);
    _pool.minConnections = applicationConfiguration.get(DATABASE_POOL_MIN_CONNECTIONS);
    _pool.connectionTimeout = applicationConfiguration.get(DATABASE_POOL_CONNECTION_TIMEOUT);
    _pool.idleTimeout = applicationConfiguration.get(DATABASE_POOL_IDLE_TIMEOUT);
    _pool.maxLifetime = applicationConfiguration.get(DATABASE_POOL_MAX_LIFETIME);
    _migration.enabled = applicationConfiguration.get(DATABASE_MIGRATION_ENABLED);
    _migration.table = applicationConfiguration.get(DATABASE_MIGRATION_TABLE);
    _migration.autoRun = applicationConfiguration.get(DATABASE_MIGRATION_AUTO_RUN);
  }
}

abstract class DatabaseConnectionConfigure {
  factory DatabaseConnectionConfigure() => _DatabaseConnectionConfigure();

  String get path;
  set path(String path);

  String get host;
  set host(String host);

  int get port;
  set port(int port);

  String get database;
  set database(String database);

  String get username;
  set username(String username);

  String get password;
  set password(String password);
}

class _DatabaseConnectionConfigure implements DatabaseConnectionConfigure {
  String _path;
  String _host;
  int _port;
  String _database;
  String _username;
  String _password;

  _DatabaseConnectionConfigure();

  @override
  String get path => _path;

  @override
  set path(String path) => _path = path;

  @override
  String get host => _host;

  @override
  set host(String host) => _host = host;

  @override
  int get port => _port;

  @override
  set port(int port) => _port = port;

  @override
  String get database => _database;

  @override
  set database(String database) => _database = database;

  @override
  String get username => _username;

  @override
  set username(String username) => _username = username;

  @override
  String get password => _password;

  @override
  set password(String password) => _password = password;
}

abstract class DatabasePoolConfigure {
  factory DatabasePoolConfigure() => _DatabasePoolConfigure();

  int get maxConnections;
  set maxConnections(int maxConnections);

  int get minConnections;
  set minConnections(int minConnections);

  int get connectionTimeout;
  set connectionTimeout(int connectionTimeout);

  int get idleTimeout;
  set idleTimeout(int idleTimeout);

  int get maxLifetime;
  set maxLifetime(int maxLifetime);
}

class _DatabasePoolConfigure implements DatabasePoolConfigure {
  int _maxConnections;
  int _minConnections;
  int _connectionTimeout;
  int _idleTimeout;
  int _maxLifetime;

  _DatabasePoolConfigure();

  @override
  int get maxConnections => _maxConnections;

  @override
  set maxConnections(int maxConnections) => _maxConnections = maxConnections;

  @override
  int get minConnections => _minConnections;

  @override
  set minConnections(int minConnections) => _minConnections = minConnections;

  @override
  int get connectionTimeout => _connectionTimeout;

  @override
  set connectionTimeout(int connectionTimeout) => _connectionTimeout = connectionTimeout;

  @override
  int get idleTimeout => _idleTimeout;

  @override
  set idleTimeout(int idleTimeout) => _idleTimeout = idleTimeout;

  @override
  int get maxLifetime => _maxLifetime;

  @override
  set maxLifetime(int maxLifetime) => _maxLifetime = maxLifetime;
}

abstract class DatabaseMigrationConfigure {
  factory DatabaseMigrationConfigure() => _DatabaseMigrationConfigure();

  bool get enabled;
  set enabled(bool enabled);

  String get table;
  set table(String table);

  bool get autoRun;
  set autoRun(bool autoRun);
}

class _DatabaseMigrationConfigure implements DatabaseMigrationConfigure {
  bool _enabled;
  String _table;
  bool _autoRun;

  _DatabaseMigrationConfigure();

  @override
  bool get enabled => _enabled;

  @override
  set enabled(bool enabled) => _enabled = enabled;

  @override
  String get table => _table;

  @override
  set table(String table) => _table = table;

  @override
  bool get autoRun => _autoRun;

  @override
  set autoRun(bool autoRun) => _autoRun = autoRun;
}

