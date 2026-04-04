import 'dart:io';

import 'package:Q/Q.dart';
import 'package:Q/src/security/auth/JwtAuthentication.dart';
import 'package:Q/src/security/auth/AuthInterceptor.dart';
import 'package:Q/src/security/auth/Authorization.dart';

Application app;

void main(List<String> arguments) async {
  await start(arguments);
}

void start(List<String> arguments) async {
  app = Application()..args(arguments);
  await app.init();

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
        passwordHash: 'hashed-password', // 实际应用中应该使用 SecurityUtils.hashPassword()
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
    publicPaths: ['/login', '/public', '/csrf-token'],
    pathRoles: {
      '/admin': ['ADMIN'],
      '/api/users': ['ADMIN', 'USER'],
    },
  );

  // 注册认证拦截器
  app.registryInterceptor(authInterceptor);

  // 健康检查
  app.get('/health', (Context context) async {
    return {'status': 'ok'};
  });

  // 公开路径
  app.get('/public', (Context context) async {
    return {'message': 'This is a public endpoint'}
  });

  // 登录端点
  app.post('/login', (Context context) async {
    var data = context.request.data;
    String username = data['username'];
    String password = data['password'];

    var result = await auth.authenticate(username, password);
    if (result.success) {
      return {
        'token': result.token,
        'user': result.userDetails.username,
        'roles': result.userDetails.roles,
      };
    } else {
      context.response.status = HttpStatus.unauthorized;
      return {'error': result.errorMessage};
    }
  });

  // 获取 CSRF Token
  app.get('/csrf-token', (Context context) async {
    return {'csrfToken': context.request.headers.value('X-CSRF-Token')};
  });

  // 受保护的 API 端点 - 需要认证
  app.get('/api/users', (Context context) async {
    return {
      'users': [
        {'id': 1, 'name': 'Admin User', 'role': 'ADMIN'},
        {'id': 2, 'name': 'Regular User', 'role': 'USER'},
      ]
    };
  });

  // 管理员专用端点 - 需要 ADMIN 角色
  app.get('/admin', (Context context) async {
    return {'message': 'Welcome, Admin!'}
  });

  // XSS 防护测试 - 自动转义 HTML
  app.post('/xss-test', (Context context) async {
    var data = context.request.data;
    String userInput = data['input'];
    return {'input': userInput, 'message': 'Input received'}
  });

  // 文件上传测试
  app.post('/upload', (Context context) async {
    if (context.request.data is MultipartValueMap) {
      MultipartValueMap data = context.request.data;
      List<Value> files = data['file'];
      for (Value value in files) {
        if (value is MultipartFile) {
          print('File: ${value.filename}, Size: ${value.size}');
        }
      }
    }
    return {'status': 'uploaded'}
  });

  // 启动服务器
  // 注意：HTTPS 需要在 configure.yml 中配置证书
  await app.listen(8081);
  print('Security example server started on port 8081');
  print('\nAvailable endpoints:');
  print('- GET  /health          - Health check');
  print('- GET  /public          - Public endpoint');
  print('- POST /login           - User login (username: admin/user, password: any)');
  print('- GET  /csrf-token      - Get CSRF token');
  print('- GET  /api/users       - Protected API (requires authentication)');
  print('- GET  /admin           - Admin only (requires ADMIN role)');
  print('- POST /xss-test        - XSS protection test');
  print('- POST /upload          - File upload test');
  print('\nTo test authentication:');
  print('1. POST /login with {"username": "admin", "password": "any"}');
  print('2. Copy the token from response');
  print('3. Add Authorization header: Bearer <token>');
  print('4. Access /api/users or /admin');
  print('\nTo test CSRF protection:');
  print('1. GET /csrf-token to get the token');
  print('2. Add X-CSRF-Token header to POST requests');
  print('\nTo test XSS protection:');
  print('1. POST /xss-test with {"input": "<script>alert(\'XSS\')</script>"}');
  print('2. Check that the script is properly escaped');
}