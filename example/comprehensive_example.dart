import 'dart:io';

import 'package:Q/Q.dart';
import 'package:Q/src/security/auth/JwtAuthentication.dart';
import 'package:Q/src/security/auth/AuthInterceptor.dart';
import 'package:Q/src/security/auth/Authorization.dart';
import 'package:Q/src/multipart/MultipartValueMap.dart';
import 'package:Q/src/query/Value.dart';
import 'package:Q/src/query/MultipartFile.dart';
import 'package:Q/src/Redirect.dart';
import 'package:Q/src/Method.dart';
import 'package:Q/src/annotation/PathVariable.dart';
import 'package:Q/src/annotation/RequestParam.dart';

// 自定义中间件
class LoggerMiddleware implements Middleware {
  @override
  MiddlewareType type = MiddlewareType.AFTER;

  @override
  Future<Context> handle(Context context, Function onFinished, Function onError) async {
    print('${DateTime.now()} - ${context.request.req.method} ${context.request.req.uri.path}');
    Context result = await onFinished();
    print('${DateTime.now()} - ${result.response.status}');
    return result;
  }
}

Application app;

void main(List<String> arguments) async {
  await start(arguments);
}

void start(List<String> arguments) async {
  app = Application()..args(arguments);
  await app.init();

  // 注册中间件
  app.use(LoggerMiddleware());

  // 创建 JWT 认证实例
  JwtAuthentication auth = JwtAuthentication(
    secretKey: 'your-secret-key',
    tokenExpiration: 3600,
    issuer: 'https://example.com',
    audience: 'https://api.example.com',
    includeUserIdInToken: true,
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
  Authorization authorization = RoleBasedAuthorization();

  // 创建认证拦截器
  AuthInterceptor authInterceptor = AuthInterceptor.instance(
    authentication: auth,
    authorization: authorization,
    publicPaths: ['/login', '/public', '/health', '/csrf-token'],
    pathRoles: {
      '/admin': ['ADMIN'],
      '/api/users': ['ADMIN', 'USER'],
      '/api/users/*': ['ADMIN'],
    },
  );

  // 注册认证拦截器
  app.registryInterceptor(authInterceptor);

  // 健康检查
  app.get('/health', (Context context, [HttpRequest req, HttpResponse res]) async {
    return {'status': 'ok', 'time': DateTime.now().toIso8601String()};
  });

  // 公开路径
  app.get('/public', (Context context, [HttpRequest req, HttpResponse res]) async {
    return {
      'message': 'This is a public endpoint',
      'timestamp': DateTime.now().toIso8601String()
    };
  });

  // 登录端点
  app.post('/login', (Context context, [HttpRequest req, HttpResponse res]) async {
    var data = context.request.data;
    String username = data['username'];
    String password = data['password'];

    var result = await auth.authenticate(username, password);
    if (result.success) {
      return {
        'token': result.token,
        'user': result.userDetails.username,
        'userId': result.userDetails.userId,
        'roles': result.userDetails.roles,
        'expiresIn': 3600
      };
    } else {
      context.response.status = HttpStatus.unauthorized;
      return {'error': result.errorMessage};
    }
  });

  // 刷新 token
  app.post('/refresh-token', (Context context, [HttpRequest req, HttpResponse res]) async {
    String token = context.request.req.headers.value('Authorization')?.replaceAll('Bearer ', '');
    if (token == null) {
      context.response.status = HttpStatus.badRequest;
      return {'error': 'Token required'};
    }

    try {
      String newToken = await auth.refreshToken(token);
      return {'token': newToken, 'expiresIn': 3600};
    } catch (e) {
      context.response.status = HttpStatus.unauthorized;
      return {'error': 'Invalid token'};
    }
  });

  // 获取 CSRF Token
  app.get('/csrf-token', (Context context, [HttpRequest req, HttpResponse res]) async {
    return {
      'csrfToken': context.request.req.headers.value('X-CSRF-Token'),
      'timestamp': DateTime.now().toIso8601String()
    };
  });

  // 基本路由示例
  app.get('/hello', (Context context, [HttpRequest req, HttpResponse res]) async {
    return {'message': 'Hello, Q.dart!'};
  });

  // 路由参数
  app.get('/user/:id', (Context context, [HttpRequest req, HttpResponse res, @PathVariable('id') String id]) async {
    return {'userId': id, 'message': 'User found'};
  });

  // 查询参数
  app.get('/search', (Context context, [HttpRequest req, HttpResponse res, @RequestParam('q') String query, @RequestParam('page') int page]) async {
    return {'query': query, 'page': page, 'results': []};
  });

  // 表单数据
  app.post('/form', (Context context, [HttpRequest req, HttpResponse res, @RequestParam('name') String name, @RequestParam('age') int age]) async {
    return {'name': name, 'age': age, 'message': 'Form submitted'};
  });

  // JSON 数据
  app.post('/json', (Context context, [HttpRequest req, HttpResponse res]) async {
    var data = context.request.data;
    return {'received': data, 'message': 'JSON received'};
  });

  // 受保护的 API 端点 - 需要认证
  app.get('/api/users', (Context context, [HttpRequest req, HttpResponse res]) async {
    return {
      'users': [
        {'id': 1, 'name': 'Admin User', 'role': 'ADMIN'},
        {'id': 2, 'name': 'Regular User', 'role': 'USER'},
      ],
      'total': 2
    };
  });

  // 管理员专用端点 - 需要 ADMIN 角色
  app.get('/admin', (Context context, [HttpRequest req, HttpResponse res]) async {
    return {
      'message': 'Welcome, Admin!',
      'privileges': ['manage_users', 'manage_settings', 'view_logs']
    };
  });

  // 管理员创建用户
  app.post('/api/users', (Context context, [HttpRequest req, HttpResponse res]) async {
    var data = context.request.data;
    return {
      'id': 3,
      'name': data['name'],
      'role': data['role'],
      'message': 'User created'
    };
  });

  // XSS 防护测试 - 自动转义 HTML
  app.post('/xss-test', (Context context, [HttpRequest req, HttpResponse res]) async {
    var data = context.request.data;
    String userInput = data['input'];
    return {
      'input': userInput,
      'message': 'Input received and sanitized',
      'timestamp': DateTime.now().toIso8601String()
    };
  });

  // 文件上传测试
  app.post('/upload', (Context context, [HttpRequest req, HttpResponse res]) async {
    if (context.request.data is MultipartValueMap) {
      MultipartValueMap data = context.request.data;
      List<Value> files = data['file'];
      List<Map<String, dynamic>> uploadedFiles = [];
      
      for (Value value in files) {
        if (value is MultipartFile) {
          uploadedFiles.add({
            'filename': value.originalName,
            'size': value.size,
            'contentType': value.contentType?.toString()
          });
        }
      }
      
      return {
        'status': 'uploaded',
        'files': uploadedFiles,
        'total': uploadedFiles.length
      };
    }
    return {'status': 'no files uploaded'};
  });

  // 重定向示例
  app.get('/redirect', (Context context, [HttpRequest req, HttpResponse res]) async {
    return Redirect('/hello', HttpMethod.GET);
  });

  // 错误处理 - 使用默认的错误处理器
  // 框架已经内置了基本的错误处理机制

  // 启动服务器
  await app.listen(8081);
  print('Comprehensive example server started on port 8081');
  print('\n=== Available Endpoints ===');
  print('\nPublic Endpoints:');
  print('- GET  /health          - Health check');
  print('- GET  /public          - Public endpoint');
  print('- POST /login           - User login (username: admin/user, password: any)');
  print('- POST /refresh-token   - Refresh token');
  print('- GET  /csrf-token      - Get CSRF token');
  print('- GET  /hello           - Basic hello endpoint');
  print('- GET  /user/:id        - Route parameters example');
  print('- GET  /search          - Query parameters example');
  print('- POST /form            - Form data example');
  print('- POST /json            - JSON data example');
  print('- GET  /redirect        - Redirect example');
  print('\nProtected Endpoints:');
  print('- GET  /api/users       - Get all users (requires auth)');
  print('- POST /api/users       - Create user (requires ADMIN)');
  print('- GET  /admin           - Admin only endpoint (requires ADMIN)');
  print('- POST /xss-test        - XSS protection test (requires auth)');
  print('- POST /upload          - File upload test (requires auth)');
  print('\n=== Testing Guide ===');
  print('\n1. Authentication:');
  print('   - POST /login with {"username": "admin", "password": "any"}');
  print('   - Use the returned token in Authorization header: Bearer <token>');
  print('\n2. CSRF Protection:');
  print('   - GET /csrf-token to get the token');
  print('   - Add X-CSRF-Token header to POST requests');
  print('\n3. XSS Protection:');
  print('   - POST /xss-test with {"input": "<script>alert(\'XSS\')</script>"}');
  print('   - Check that the script is properly escaped');
  print('\n4. File Upload:');
  print('   - POST /upload with multipart/form-data');
  print('   - Include a file field named "file"');
  print('\n5. Role-Based Access:');
  print('   - Try accessing /admin with user role (should fail)');
  print('   - Try accessing /admin with admin role (should succeed)');
  print('\nServer is ready for testing!');
}