# Q.dart Framework

Q.dart 是一个基于 Dart 语言的高性能、安全的 Web 框架，提供了完整的 MVC 架构和丰富的安全功能。

## 特性

- **高性能**：基于 Dart 语言的异步特性，提供高性能的 HTTP 服务器
- **MVC 架构**：完整的 Model-View-Controller 架构
- **路由系统**：支持 RESTful API 和灵活的路由配置
- **中间件**：可扩展的中间件系统
- **安全功能**：
  - CSRF 保护
  - XSS 防护
  - 认证授权（JWT）
  - HTTPS 支持
- **数据库支持**：
  - 内置数据库连接池
  - ORM（对象关系映射）支持
  - 数据库迁移工具
  - 支持 SQLite、MySQL、PostgreSQL 等数据库
- **配置管理**：YAML 配置文件支持
- **国际化**：内置国际化支持

## 安装

### 1. 安装 Dart SDK

请先安装 Dart SDK 2.5.0 或更高版本。

### 2. 添加依赖

在 `pubspec.yaml` 文件中添加：

```yaml
dependencies:
  Q:
    path: /path/to/Q.dart
  # 其他依赖...
```

## 快速开始

### 1. 创建应用

```dart
import 'package:Q/Q.dart';

void main() {
  // 创建应用实例
  Application app = Application();
  
  // 初始化应用
  app.init();
  
  // 定义路由
  app.get('/hello', (Context context) async {
    return 'Hello, Q.dart!';
  });
  
  // 启动服务器
  app.listen(8080);
  print('Server started on port 8080');
}
```

### 2. 运行应用

```bash
dart main.dart
```

## 路由系统

### 基本路由

```dart
// GET 请求
app.get('/users', (Context context) async {
  return {'users': []};
});

// POST 请求
app.post('/users', (Context context) async {
  var data = context.request.data;
  // 处理数据...
  return {'status': 'created'};
});

// PUT 请求
app.put('/users/:id', (Context context) async {
  var id = context.pathVariables['id'];
  // 处理数据...
  return {'status': 'updated'};
});

// DELETE 请求
app.delete('/users/:id', (Context context) async {
  var id = context.pathVariables['id'];
  // 处理数据...
  return {'status': 'deleted'};
});

// PATCH 请求
app.patch('/users/:id', (Context context) async {
  var id = context.pathVariables['id'];
  // 处理数据...
  return {'status': 'updated'};
});
```

### 路由参数

```dart
app.get('/users/:id', (Context context) async {
  var id = context.pathVariables['id'];
  return {'id': id};
});
```

### 路由组

```dart
// 路由组
Router userRouter = Router('/users');
userRouter.get('/', (Context context) async {
  return {'users': []};
});
userRouter.get('/:id', (Context context) async {
  var id = context.pathVariables['id'];
  return {'id': id};
});

// 注册路由组
app.route(userRouter);
```

## 中间件

### 自定义中间件

```dart
class LoggerMiddleware implements Middleware {
  @override
  Future<bool> handle(Context context, Next next) async {
    print('Request: ${context.request.method} ${context.request.uri.path}');
    bool proceed = await next();
    print('Response: ${context.response.status}');
    return proceed;
  }
}

// 使用中间件
app.use(LoggerMiddleware());
```

## 安全功能

### 1. CSRF 保护

CSRF 保护已默认集成到框架中，无需额外配置。

**客户端使用**：
- 从响应头或 Cookie 中获取 CSRF Token
- 在发送 POST、PUT、DELETE、PATCH 请求时，在请求头中添加 `X-CSRF-Token`

**配置**：

在 `configure.yml` 中：

```yaml
security:
  csrf:
    enabled: true
    protectedMethods: [POST, PUT, DELETE, PATCH]
    tokenMaxAge: 3600000
    tokenHeader: X-CSRF-Token
    tokenCookie: csrf_token
```

### 2. XSS 防护

XSS 防护已默认集成到框架中，无需额外配置。

**功能**：
- 自动转义 HTML 特殊字符
- 过滤 JavaScript 事件处理器
- 过滤危险的 HTML 标签
- 自动添加安全响应头

**配置**：

在 `configure.yml` 中：

```yaml
security:
  xss:
    enabled: true
    blockRequest: true
    protectedContentTypes:
      - application/x-www-form-urlencoded
      - application/json
      - multipart/form-data
```

### 3. 认证授权

**使用 JWT 认证**：

```dart
import 'package:Q/src/security/auth/JwtAuthentication.dart';
import 'package:Q/src/security/auth/RoleBasedAuthorization.dart';
import 'package:Q/src/security/auth/AuthInterceptor.dart';

// 创建 JWT 认证实例
JwtAuthentication auth = JwtAuthentication(
  secretKey: 'your-secret-key',
  tokenExpiration: 3600,
  userStore: {
    'admin': UserCredentials(
      userId: '1',
      passwordHash: 'hashed-password',
      roles: ['ADMIN'],
    ),
    'user': UserCredentials(
      userId: '2',
      passwordHash: 'hashed-password',
      roles: ['USER'],
    ),
  },
);

// 创建授权实例
RoleBasedAuthorization authorization = RoleBasedAuthorization(
  rolePermissions: {
    'ADMIN': ['users:read', 'users:write', 'users:delete'],
    'USER': ['users:read'],
  },
);

// 创建认证拦截器
AuthInterceptor authInterceptor = AuthInterceptor.instance(
  authentication: auth,
  authorization: authorization,
  publicPaths: ['/login', '/register'],
  pathRoles: {
    '/admin': ['ADMIN'],
    '/api/users': ['ADMIN', 'USER'],
  },
);

// 注册拦截器
app.registryInterceptor(authInterceptor);
```

**登录示例**：

```dart
app.post('/login', (Context context) async {
  var data = context.request.data;
  String username = data['username'];
  String password = data['password'];
  
  var result = await auth.authenticate(username, password);
  if (result.success) {
    return {
      'token': result.token,
      'user': result.userDetails.username,
    };
  } else {
    context.response.status = HttpStatus.unauthorized;
    return {'error': result.errorMessage};
  }
});
```

**配置**：

在 `configure.yml` 中：

```yaml
security:
  auth:
    enabled: true
    publicPaths:
      - /login
      - /register
    pathRoles:
      /admin: [ADMIN]
      /api/users: [ADMIN, USER]
    tokenHeader: Authorization
    tokenExpiration: 3600
```

### 4. HTTPS 支持

**配置**：

在 `configure.yml` 中：

```yaml
https:
  enabled: true
  certificatePath: /path/to/cert.pem
  privateKeyPath: /path/to/key.pem
  certificatePassword: your-password (可选)
  enableHttp2: true
  enableTls13: true
  tlsVersions: [TLSv1.2, TLSv1.3]
  clientCertificateRequired: false
  trustedCaCertificatePath: /path/to/ca.pem (可选)
```

**使用**：

```dart
// 启动 HTTPS 服务器
import 'package:Q/src/delegate/ApplicationHttpsServerDelegate.dart';

// 确保已在 configure.yml 中配置 HTTPS
app.listen(443); // HTTPS 默认端口
```

## 配置管理

### 配置文件

创建 `resource/configure.yml` 文件：

```yaml
# 服务器配置
server:
  port: 8080
  host: 0.0.0.0

# 安全配置
security:
  csrf:
    enabled: true
  xss:
    enabled: true
  auth:
    enabled: true

# HTTPS 配置
https:
  enabled: false

# 多环境配置
# 可以创建 configure-dev.yml, configure-prod.yml 等
```

### 环境变量

```bash
# 设置环境变量
export APP_ENV=dev

# 运行应用
dart main.dart
```

## 国际化

### 资源文件

创建 `resource/i18n` 目录，添加语言文件：

- `resource/i18n/messages_en.yml`
- `resource/i18n/messages_zh.yml`

### 使用

```dart
app.get('/hello', (Context context) async {
  String message = context.i18n('hello');
  return message;
});
```

## 错误处理

### 自定义错误处理

```dart
app.addHandler(HttpStatus.notFound, (Context context) async {
  context.response.status = HttpStatus.notFound;
  return {'error': 'Not found'};
});

app.addHandler(HttpStatus.internalServerError, (Context context) async {
  context.response.status = HttpStatus.internalServerError;
  return {'error': 'Internal server error'};
});
```

## 文件上传

```dart
app.post('/upload', (Context context) async {
  if (context.request.data is MultipartValueMap) {
    MultipartValueMap data = context.request.data;
    List<Value> files = data['file'];
    for (Value value in files) {
      if (value is MultipartFile) {
        // 处理文件
        print('File: ${value.filename}, Size: ${value.size}');
      }
    }
  }
  return {'status': 'uploaded'};
});
```

## 数据库集成

Q.dart 提供了完整的数据库支持，包括连接池、ORM 和迁移工具。

### 1. 数据库连接池

**创建连接池**：

```dart
import 'package:Q/src/database/Database.dart';

// 创建连接池配置
DatabasePoolConfig config = DatabasePoolConfig(
  maxConnections: 10,
  minConnections: 2,
  connectionTimeout: 30000,
  idleTimeout: 600000,
  maxLifetime: 1800000,
);

// 创建连接池
DatabaseConnectionPool pool = DatabaseConnectionPoolImpl(
  config: config,
  connectionFactory: () async {
    // 返回数据库连接
    return SqliteConnection(databasePath: 'database.db');
  },
);
```

**使用连接池**：

```dart
// 查询
List<Map<String, dynamic>> results = await pool.query(
  'SELECT * FROM users WHERE role = ?',
  params: ['ADMIN'],
);

// 执行
int affectedRows = await pool.execute(
  'UPDATE users SET role = ? WHERE id = ?',
  params: ['ADMIN', 1],
);

// 插入
int insertedId = await pool.insert(
  'INSERT INTO users (username, email) VALUES (?, ?)',
  params: ['john', 'john@example.com'],
);

// 事务
await pool.transaction((connection) async {
  await connection.execute('INSERT INTO users (username) VALUES (?)', params: ['user1']);
  await connection.execute('INSERT INTO users (username) VALUES (?)', params: ['user2']);
});
```

### 2. ORM（对象关系映射）

**定义实体**：

```dart
import 'package:Q/src/database/Entity.dart';

@Entity(tableName: 'users')
class User {
  @Column(isPrimaryKey: true, autoIncrement: true)
  int? id;
  
  @Column(length: 100, nullable: false)
  String username;
  
  @Column(length: 255, nullable: false)
  String email;
  
  @Column(length: 255, nullable: false)
  String passwordHash;
  
  @Column(length: 50, nullable: false)
  String role;
  
  @Column(nullable: true)
  DateTime? createdAt;
  
  @Column(nullable: true)
  DateTime? updatedAt;
}
```

**创建 Repository**：

```dart
import 'package:Q/src/database/Repository.dart';

class UserRepository extends BaseRepository<User> {
  UserRepository({
    required DatabaseConnectionPool connectionPool,
  }) : super(
          connectionPool: connectionPool,
          tableName: 'users',
          primaryKey: 'id',
        );

  @override
  User _mapToEntity(Map<String, dynamic> record) {
    return User()
      ..id = record['id']
      ..username = record['username']
      ..email = record['email']
      ..passwordHash = record['password_hash']
      ..role = record['role']
      ..createdAt = record['created_at'] != null 
          ? DateTime.parse(record['created_at']) 
          : null
      ..updatedAt = record['updated_at'] != null 
          ? DateTime.parse(record['updated_at']) 
          : null;
  }

  @override
  Map<String, dynamic> _entityToMap(User entity) {
    return {
      'id': entity.id,
      'username': entity.username,
      'email': entity.email,
      'password_hash': entity.passwordHash,
      'role': entity.role,
      'created_at': entity.createdAt?.toIso8601String(),
      'updated_at': entity.updatedAt?.toIso8601String(),
    };
  }

  @override
  dynamic _getIdValue(User entity) => entity.id;

  @override
  void _setIdValue(User entity, dynamic id) {
    entity.id = id;
  }

  /// 根据用户名查找用户
  Future<User?> findByUsername(String username) async {
    final results = await findWhere(
      where: 'username = ?',
      params: [username],
      limit: 1,
    );
    return results.isEmpty ? null : results.first;
  }

  /// 根据邮箱查找用户
  Future<User?> findByEmail(String email) async {
    final results = await findWhere(
      where: 'email = ?',
      params: [email],
      limit: 1,
    );
    return results.isEmpty ? null : results.first;
  }

  /// 查找所有管理员用户
  Future<List<User>> findAdmins() async {
    return await findWhere(
      where: 'role = ?',
      params: ['ADMIN'],
    );
  }
}
```

**使用 Repository**：

```dart
// 创建 Repository
UserRepository userRepository = UserRepository(
  connectionPool: pool,
);

// 查找所有用户
List<User> users = await userRepository.findAll();

// 根据 ID 查找用户
User? user = await userRepository.findById(1);

// 根据条件查找用户
List<User> admins = await userRepository.findWhere(
  where: 'role = ?',
  params: ['ADMIN'],
  orderBy: 'created_at DESC',
  limit: 10,
);

// 保存用户（插入或更新）
User newUser = User()
  ..username = 'john'
  ..email = 'john@example.com'
  ..passwordHash = 'hashed_password'
  ..role = 'USER'
  ..createdAt = DateTime.now()
  ..updatedAt = DateTime.now();
await userRepository.save(newUser);

// 更新用户
user.email = 'newemail@example.com';
user.updatedAt = DateTime.now();
await userRepository.update(user);

// 删除用户
await userRepository.delete(user);

// 统计用户数量
int count = await userRepository.count();

// 检查用户是否存在
bool exists = await userRepository.exists(
  where: 'username = ?',
  params: ['john'],
);
```

### 3. 数据库迁移

**创建迁移**：

```dart
import 'package:Q/src/database/Migration.dart';

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
```

**运行迁移**：

```dart
import 'package:Q/src/database/MigrationRunner.dart';

// 创建迁移列表
List<Migration> migrations = [
  CreateUserTable(),
  AddUserEmailIndex(),
];

// 创建迁移运行器
MigrationRunner runner = MigrationRunner(
  connectionPool: pool,
  migrations: migrations,
);

// 运行所有待执行的迁移
await runner.run();

// 回滚到指定版本
await runner.rollback(0);

// 获取迁移状态
Map<String, dynamic> status = await runner.getStatus();
print('Current version: ${status['currentVersion']}');
print('Pending migrations: ${status['pendingMigrations']}');
```

### 4. 支持的数据库

Q.dart 支持以下数据库：

- **SQLite**：使用 `SqliteConnection`
- **MySQL**：使用 `MySQLConnection`
- **PostgreSQL**：需要集成 `postgres` 包

**SQLite 示例**：

```dart
import 'package:Q/src/database/Database.dart';

DatabaseConnectionPool pool = DatabaseConnectionPoolImpl(
  config: DatabasePoolConfig(),
  connectionFactory: () async {
    return SqliteConnection(databasePath: 'database.db');
  },
);
```

**MySQL 示例**：

```dart
import 'package:Q/src/database/Database.dart';

DatabaseConnectionPool pool = DatabaseConnectionPoolImpl(
  config: DatabasePoolConfig(),
  connectionFactory: () async {
    return MySQLConnection(
      host: 'localhost',
      port: 3306,
      database: 'mydb',
      username: 'user',
      password: 'password',
    );
  },
);
```

### 5. 数据库配置

在 `configure.yml` 中配置数据库：

```yaml
database:
  type: sqlite
  connection:
    path: database.db
  pool:
    maxConnections: 10
    minConnections: 2
    connectionTimeout: 30000
    idleTimeout: 600000
    maxLifetime: 1800000
  migrations:
    enabled: true
    table: schema_migrations
    autoRun: true
```

## 部署

### 1. 构建应用

```bash
# 构建应用
dart compile exe main.dart -o app

# 运行应用
./app
```

### 2. Docker 部署

创建 `Dockerfile`：

```dockerfile
FROM dart:stable

WORKDIR /app

COPY . .

RUN dart pub get

RUN dart compile exe main.dart -o app

EXPOSE 8080

CMD ["./app"]
```

构建和运行：

```bash
docker build -t qdart-app .
docker run -p 8080:8080 qdart-app
```

## 示例项目

### 基本应用

```dart
import 'dart:io';
import 'package:Q/Q.dart';

void main() {
  Application app = Application();
  app.init();
  
  // 健康检查
  app.get('/health', (Context context) async {
    return {'status': 'ok'};
  });
  
  // API 路由
  app.get('/api/users', (Context context) async {
    return {
      'users': [
        {'id': 1, 'name': 'User 1'},
        {'id': 2, 'name': 'User 2'},
      ]
    };
  });
  
  // 启动服务器
  app.listen(8080);
  print('Server started on port 8080');
}
```

### 安全应用

```dart
import 'dart:io';
import 'package:Q/Q.dart';
import 'package:Q/src/security/auth/JwtAuthentication.dart';
import 'package:Q/src/security/auth/RoleBasedAuthorization.dart';
import 'package:Q/src/security/auth/AuthInterceptor.dart';

void main() {
  Application app = Application();
  app.init();
  
  // 创建认证和授权
  JwtAuthentication auth = JwtAuthentication(
    secretKey: 'your-secret-key',
    userStore: {
      'admin': UserCredentials(
        userId: '1',
        passwordHash: 'hashed-password',
        roles: ['ADMIN'],
      ),
    },
  );
  
  RoleBasedAuthorization authorization = RoleBasedAuthorization();
  
  // 注册认证拦截器
  app.registryInterceptor(AuthInterceptor.instance(
    authentication: auth,
    authorization: authorization,
    publicPaths: ['/login'],
    pathRoles: {
      '/admin': ['ADMIN'],
    },
  ));
  
  // 登录路由
  app.post('/login', (Context context) async {
    var data = context.request.data;
    var result = await auth.authenticate(data['username'], data['password']);
    if (result.success) {
      return {'token': result.token};
    } else {
      context.response.status = HttpStatus.unauthorized;
      return {'error': 'Invalid credentials'};
    }
  });
  
  // 受保护的路由
  app.get('/admin', (Context context) async {
    return {'message': 'Welcome, admin!'};
  });
  
  // 启动服务器
  app.listen(8080);
  print('Server started on port 8080');
}
```

## 性能优化

1. **使用连接池**：对于数据库连接等资源，使用连接池减少创建和销毁的开销
2. **缓存**：使用内存缓存或分布式缓存缓存频繁访问的数据
3. **异步处理**：充分利用 Dart 的异步特性，避免阻塞操作
4. **代码优化**：减少不必要的计算和对象创建
5. **负载均衡**：在生产环境中使用负载均衡器分散流量

## 故障排查

### 常见问题

1. **404 Not Found**：检查路由配置是否正确
2. **401 Unauthorized**：检查认证 token 是否有效
3. **403 Forbidden**：检查用户是否有权限访问资源
4. **500 Internal Server Error**：检查服务器端代码是否有错误
5. **CSRF Token 错误**：确保客户端正确发送 CSRF Token

### 日志

```dart
// 添加日志中间件
class LoggingMiddleware implements Middleware {
  @override
  Future<bool> handle(Context context, Next next) async {
    print('${DateTime.now()} - ${context.request.method} ${context.request.uri.path}');
    bool result = await next();
    print('${DateTime.now()} - ${context.response.status}');
    return result;
  }
}

app.use(LoggingMiddleware());
```

## 贡献

欢迎贡献代码、报告问题或提出建议！

## 许可证

MIT License
