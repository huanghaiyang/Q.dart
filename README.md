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

Q.dart 支持与任何 Dart 数据库库集成，例如：

- `sqflite` (SQLite)
- `postgres` (PostgreSQL)
- `mysql1` (MySQL)
- `mongo_dart` (MongoDB)

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
