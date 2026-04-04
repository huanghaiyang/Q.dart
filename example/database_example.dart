import 'dart:io';

import 'package:Q/Q.dart';
import 'package:Q/src/database/Database.dart';
import 'package:Q/src/database/Entity.dart';
import 'package:Q/src/database/Repository.dart';
import 'package:Q/src/database/Migration.dart';
import 'package:Q/src/database/SqliteConnection.dart';
import 'package:Q/src/database/MySQLConnection.dart';
import 'package:Q/src/database/DatabaseConnectionPoolImpl.dart';
import 'package:Q/src/database/DatabaseConnectionPool.dart';

/// 用户实体
@Entity(tableName: 'users')
class User {
  @Column(isPrimaryKey: true, autoIncrement: true)
  int id;
  
  @Column(length: 100, nullable: false)
  String username;
  
  @Column(length: 255, nullable: false)
  String email;
  
  @Column(length: 255, nullable: false)
  String passwordHash;
  
  @Column(length: 50, nullable: false)
  String role;
  
  @Column(nullable: true)
  DateTime createdAt;
  
  @Column(nullable: true)
  DateTime updatedAt;
  
  User() {
    id = 0;
    username = '';
    email = '';
    passwordHash = '';
    role = 'USER';
    createdAt = null;
    updatedAt = null;
  }
}

/// 用户 Repository
class UserRepository extends BaseRepository<User> {
  UserRepository(DatabaseConnectionPool connectionPool)
      : super(
          connectionPool: connectionPool,
          tableName: 'users',
          primaryKey: 'id',
        );

  /// 根据用户名查找用户
  Future<User> findByUsername(String username) async {
    final results = await findWhere(
      where: 'username = ?',
      params: [username],
      limit: 1,
    );
    
    if (results.isEmpty) {
      return User();
    }
    return results.first;
  }

  /// 根据邮箱查找用户
  Future<User> findByEmail(String email) async {
    final results = await findWhere(
      where: 'email = ?',
      params: [email],
      limit: 1,
    );
    
    if (results.isEmpty) {
      return User();
    }
    return results.first;
  }

  /// 查找所有管理员用户
  Future<List<User>> findAdmins() async {
    return await findWhere(
      where: 'role = ?',
      params: ['ADMIN'],
    );
  }

  @override
  User _mapToEntity(Map<String, dynamic> record) {
    final user = User();
    user.id = record['id'] ?? 0;
    user.username = record['username'] ?? '';
    user.email = record['email'] ?? '';
    user.passwordHash = record['password_hash'] ?? '';
    user.role = record['role'] ?? 'USER';
    
    if (record['created_at'] != null) {
      user.createdAt = DateTime.fromMillisecondsSinceEpoch(record['created_at'] * 1000);
    }
    if (record['updated_at'] != null) {
      user.updatedAt = DateTime.fromMillisecondsSinceEpoch(record['updated_at'] * 1000);
    }
    
    return user;
  }

  @override
  Map<String, dynamic> _entityToMap(User entity) {
    final Map<String, dynamic> map = {};
    if (entity.id != 0) map['id'] = entity.id;
    map['username'] = entity.username;
    map['email'] = entity.email;
    map['password_hash'] = entity.passwordHash;
    map['role'] = entity.role;
    
    if (entity.createdAt != null) {
      map['created_at'] = entity.createdAt.millisecondsSinceEpoch ~/ 1000;
    }
    if (entity.updatedAt != null) {
      map['updated_at'] = entity.updatedAt.millisecondsSinceEpoch ~/ 1000;
    }
    
    return map;
  }

  @override
  dynamic _getIdValue(User entity) {
    return entity.id == 0 ? null : entity.id;
  }

  @override
  void _setIdValue(User entity, dynamic id) {
    entity.id = id;
  }
}

/// 用户表迁移
class CreateUserTable extends Migration {
  const CreateUserTable() : super(
          version: 1,
          description: 'Create users table',
        );

  @override
  Future<void> up(DatabaseConnectionPool connectionPool) async {
    await connectionPool.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username VARCHAR(100) NOT NULL UNIQUE,
        email VARCHAR(255) NOT NULL UNIQUE,
        password_hash VARCHAR(255) NOT NULL,
        role VARCHAR(50) NOT NULL DEFAULT 'USER',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  @override
  Future<void> down(DatabaseConnectionPool connectionPool) async {
    await connectionPool.execute('DROP TABLE users');
  }
}

/// 添加索引迁移
class AddUserEmailIndex extends Migration {
  const AddUserEmailIndex() : super(
          version: 2,
          description: 'Add index on users.email',
        );

  @override
  Future<void> up(DatabaseConnectionPool connectionPool) async {
    await connectionPool.execute('''
      CREATE INDEX idx_users_email ON users(email)
    ''');
  }

  @override
  Future<void> down(DatabaseConnectionPool connectionPool) async {
    await connectionPool.execute('''
      DROP INDEX idx_users_email
    ''');
  }
}

Application app;
DatabaseConnectionPool connectionPool;
UserRepository userRepository;

void main(List<String> arguments) async {
  await start(arguments);
}

void start(List<String> arguments) async {
  app = Application()..args(arguments);
  await app.init();

  // 初始化数据库连接
  await _initDatabase();

  // 健康检查
  app.get('/health', (Context context, [HttpRequest req, HttpResponse res]) async {
    return {'status': 'ok', 'database': connectionPool != null ? 'connected' : 'disconnected'};
  });

  // 创建用户
  app.post('/users', (Context context, [HttpRequest req, HttpResponse res]) async {
    var data = context.request.data;
    String username = data['username'];
    String email = data['email'];
    String password = data['password'];
    String role = data['role'] ?? 'USER';

    // 这里应该使用真实的密码哈希
    String passwordHash = 'hashed_$password';

    final user = User()
      ..username = username
      ..email = email
      ..passwordHash = passwordHash
      ..role = role
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    final savedUser = await userRepository.insert(user);

    return {
      'message': 'User created successfully',
      'user': {
        'id': savedUser.id,
        'username': savedUser.username,
        'email': savedUser.email,
        'role': savedUser.role,
      },
    };
  });

  // 获取用户列表
  app.get('/users', (Context context, [HttpRequest req, HttpResponse res]) async {
    final users = await userRepository.findAll();

    return {
      'users': users.map((user) => {
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'role': user.role,
      }).toList(),
      'total': users.length,
    };
  });

  // 根据 ID 获取用户
  app.get('/users/:id', (Context context, [HttpRequest req, HttpResponse res, @PathVariable('id') String id]) async {
    final user = await userRepository.findById(int.parse(id));

    if (user == null) {
      context.response.status = HttpStatus.notFound;
      return {'error': 'User not found'};
    }

    return {
      'id': user.id,
      'username': user.username,
      'email': user.email,
      'role': user.role,
    };
  });

  // 更新用户
  app.put('/users/:id', (Context context, [HttpRequest req, HttpResponse res, @PathVariable('id') String id]) async {
    var data = context.request.data;
    String email = data['email'];
    String role = data['role'];

    final user = await userRepository.findById(int.parse(id));
    if (user == null) {
      context.response.status = HttpStatus.notFound;
      return {'error': 'User not found'};
    }
    
    if (email != null) user.email = email;
    if (role != null) user.role = role;
    user.updatedAt = DateTime.now();
    await userRepository.update(user);

    return {
      'message': 'User updated successfully',
      'user': {
        'id': user.id,
        'email': user.email,
        'role': user.role,
      },
    };
  });

  // 删除用户
  app.delete('/users/:id', (Context context, [HttpRequest req, HttpResponse res, @PathVariable('id') String id]) async {
    final success = await userRepository.deleteById(int.parse(id));

    if (!success) {
      context.response.status = HttpStatus.notFound;
      return {'error': 'User not found'};
    }

    return {
      'message': 'User deleted successfully',
      'id': int.parse(id),
    };
  });

  // 运行数据库迁移
  app.post('/migrate', (Context context, [HttpRequest req, HttpResponse res]) async {
    final migrations = [
      CreateUserTable(),
      AddUserEmailIndex(),
    ];
    final runner = MigrationRunner(
      connectionPool: connectionPool,
      migrations: migrations,
    );
    await runner.run();

    return {
      'message': 'Migration completed successfully',
    };
  });

  // 回滚数据库迁移
  app.post('/migrate/rollback', (Context context, [HttpRequest req, HttpResponse res]) async {
    var data = context.request.data;
    int targetVersion = data['version'] ?? 0;

    final migrations = [
      CreateUserTable(),
      AddUserEmailIndex(),
    ];
    final runner = MigrationRunner(
      connectionPool: connectionPool,
      migrations: migrations,
    );
    await runner.rollback(targetVersion);

    return {
      'message': 'Migration rolled back successfully',
      'targetVersion': targetVersion,
    };
  });

  // 获取迁移状态
  app.get('/migrate/status', (Context context, [HttpRequest req, HttpResponse res]) async {
    final migrations = [
      CreateUserTable(),
      AddUserEmailIndex(),
    ];
    final runner = MigrationRunner(
      connectionPool: connectionPool,
      migrations: migrations,
    );
    final status = await runner.getStatus();

    return status;
  });

  // 启动服务器
  await app.listen(8082);
  print('Database example server started on port 8082');
  print('\n=== Available Endpoints ===');
  print('\nDatabase Endpoints:');
  print('- GET  /health              - Health check');
  print('- POST /users              - Create user');
  print('- GET  /users              - Get all users');
  print('- GET  /users/:id           - Get user by ID');
  print('- PUT  /users/:id           - Update user');
  print('- DELETE /users/:id        - Delete user');
  print('\nMigration Endpoints:');
  print('- POST /migrate             - Run migrations');
  print('- POST /migrate/rollback     - Rollback migrations');
  print('- GET  /migrate/status       - Get migration status');
  print('\n=== Usage Example ===');
  print('\n1. Create a user:');
  print('   POST /users with {"username": "john", "email": "john@example.com", "password": "secret"}');
  print('\n2. Get all users:');
  print('   GET /users');
  print('\n3. Get user by ID:');
  print('   GET /users/1');
  print('\n4. Update user:');
  print('   PUT /users/1 with {"email": "newemail@example.com"}');
  print('\n5. Delete user:');
  print('   DELETE /users/1');
  print('\n6. Run migrations:');
  print('   POST /migrate');
  print('\nServer is ready for testing!');
}

/// 初始化数据库连接
Future<void> _initDatabase() async {
  // 选择数据库类型：SQLite 或 MySQL
  final dbType = 'sqlite'; // 或 'mysql'

  if (dbType == 'sqlite') {
    // SQLite 连接
    final sqlitePath = 'example.db';
    final connectionFactory = () async {
      return SqliteConnection(databasePath: sqlitePath);
    };
    
    connectionPool = DatabaseConnectionPoolImpl(
      config: DatabasePoolConfig(
        maxConnections: 10,
        minConnections: 2,
        maxLifetime: 3600000, // 1 hour
      ),
      connectionFactory: connectionFactory,
    );
  } else {
    // MySQL 连接
    final connectionFactory = () async {
      return MySQLConnection(
        host: 'localhost',
        port: 3306,
        database: 'test',
        username: 'root',
        password: 'password',
      );
    };
    
    connectionPool = DatabaseConnectionPoolImpl(
      config: DatabasePoolConfig(
        maxConnections: 10,
        minConnections: 2,
        maxLifetime: 3600000, // 1 hour
      ),
      connectionFactory: connectionFactory,
    );
  }

  // 初始化 UserRepository
  userRepository = UserRepository(connectionPool: connectionPool);
  print('Database initialized successfully');
}
