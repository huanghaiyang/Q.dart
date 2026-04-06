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

// 注解式路由示例 - UserController
class UserController {
  @Get('/api/annotated/users')
  Future<dynamic> getUsers(Context context) async {
    return {
      'message': 'Get all users (annotated)',
      'controller': 'UserController',
      'method': 'getUsers'
    };
  }
  
  @Get('/api/annotated/users/:id')
  Future<dynamic> getUserById(Context context, [HttpRequest req, HttpResponse res, @PathVariable('id') String id]) async {
    return {
      'message': 'Get user by id (annotated)',
      'id': id,
      'controller': 'UserController',
      'method': 'getUserById'
    };
  }
  
  @Post('/api/annotated/users')
  Future<dynamic> createUser(Context context) async {
    return {
      'message': 'Create user (annotated)',
      'controller': 'UserController',
      'method': 'createUser'
    };
  }
  
  @Put('/api/annotated/users/:id')
  Future<dynamic> updateUser(Context context, [HttpRequest req, HttpResponse res, @PathVariable('id') String id]) async {
    return {
      'message': 'Update user (annotated)',
      'id': id,
      'controller': 'UserController',
      'method': 'updateUser'
    };
  }
  
  @Delete('/api/annotated/users/:id')
  Future<dynamic> deleteUser(Context context, [HttpRequest req, HttpResponse res, @PathVariable('id') String id]) async {
    return {
      'message': 'Delete user (annotated)',
      'id': id,
      'controller': 'UserController',
      'method': 'deleteUser'
    };
  }
}

// 注解式路由示例 - ProductController
class ProductController {
  @Get('/api/annotated/products')
  Future<dynamic> getProducts(Context context) async {
    return {
      'message': 'Get all products (annotated)',
      'controller': 'ProductController',
      'method': 'getProducts'
    };
  }
  
  @Get('/api/annotated/products/:id')
  Future<dynamic> getProductById(Context context, [HttpRequest req, HttpResponse res, @PathVariable('id') String id]) async {
    return {
      'message': 'Get product by id (annotated)',
      'id': id,
      'controller': 'ProductController',
      'method': 'getProductById'
    };
  }
  
  @Post('/api/annotated/products')
  Future<dynamic> createProduct(Context context) async {
    return {
      'message': 'Create product (annotated)',
      'controller': 'ProductController',
      'method': 'createProduct'
    };
  }
}

// @BlueprintRoute注解示例 - AnnotatedBlueprintController
@BlueprintRoute('annotated_blueprint', prefix: '/api/annotated_blueprint')
class AnnotatedBlueprintController {
  @Get('/users')
  Future<dynamic> getUsers(Context context) async {
    return {
      'message': 'Get all users (@BlueprintRoute annotated)',
      'controller': 'AnnotatedBlueprintController',
      'method': 'getUsers',
      'blueprint': 'annotated_blueprint'
    };
  }
  
  @Get('/users/:id')
  Future<dynamic> getUserById(Context context, [HttpRequest req, HttpResponse res, @PathVariable('id') String id]) async {
    return {
      'message': 'Get user by id (@BlueprintRoute annotated)',
      'id': id,
      'controller': 'AnnotatedBlueprintController',
      'method': 'getUserById',
      'blueprint': 'annotated_blueprint'
    };
  }
  
  @Post('/users')
  Future<dynamic> createUser(Context context) async {
    return {
      'message': 'Create user (@BlueprintRoute annotated)',
      'controller': 'AnnotatedBlueprintController',
      'method': 'createUser',
      'blueprint': 'annotated_blueprint'
    };
  }
  
  @Put('/users/:id')
  Future<dynamic> updateUser(Context context, [HttpRequest req, HttpResponse res, @PathVariable('id') String id]) async {
    return {
      'message': 'Update user (@BlueprintRoute annotated)',
      'id': id,
      'controller': 'AnnotatedBlueprintController',
      'method': 'updateUser',
      'blueprint': 'annotated_blueprint'
    };
  }
  
  @Delete('/users/:id')
  Future<dynamic> deleteUser(Context context, [HttpRequest req, HttpResponse res, @PathVariable('id') String id]) async {
    return {
      'message': 'Delete user (@BlueprintRoute annotated)',
      'id': id,
      'controller': 'AnnotatedBlueprintController',
      'method': 'deleteUser',
      'blueprint': 'annotated_blueprint'
    };
  }
  
  @Get('/products')
  Future<dynamic> getProducts(Context context) async {
    return {
      'message': 'Get all products (@BlueprintRoute annotated)',
      'controller': 'AnnotatedBlueprintController',
      'method': 'getProducts',
      'blueprint': 'annotated_blueprint'
    };
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
    publicPaths: ['/login', '/public', '/health', '/csrf-token', '/user', '/i18n', '/request-example', '/text-request', '/xml-request', '/cors-example', '/error-example', 'path_params', '/redirect', '/redirect_name', '/redirect_user', '/user_redirect'],
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

  // multipart/form-data
  app.post("/multipart-form-data", (Context context,
      [HttpRequest req,
      HttpResponse res,
      @RequestParam("name") String name,
      @RequestParam("friends") List<String> friends,
      @RequestParam("file") List<MultipartFile> files,
      @RequestParam("file") File file,
      @RequestParam("age") int age]) async {
    return {
      'name': name,
      "friends": friends,
      "file_length": files.length,
      "file_bytes_length": await file.length(),
      "age": age
    };
  });

  app.get("/user", (Context context,
      [HttpRequest req, HttpResponse res]) async {
    return {'name': "peter"};
  });

  app.post("/user_redirect", (Context context,
      [HttpRequest req, HttpResponse res]) async {
    Map<String, String> map = Map();
    context.attributes.forEach((String key, Attribute value) {
      map[key] = value.value;
    });
    return map;
  }, name: 'user_redirect');

  app.post("/redirect", (Context context,
      [HttpRequest req, HttpResponse res]) async {
    return Redirect("/user_redirect", HttpMethod.POST,
        attributes: {"hello": "world"});
  });

  app.post("/redirect_name", (Context context,
      [HttpRequest req, HttpResponse res]) async {
    return Redirect("name:user_redirect", HttpMethod.POST,
        attributes: {"hello": "world"});
  });

  app.post("/redirect_user", (Context context,
      [HttpRequest req, HttpResponse res]) async {
    return Redirect("name:user", HttpMethod.GET,
        pathVariables: {"user_id": "1", "name": "peter"});
  });

  app.get("/user/:user_id/:name", (Context context,
      [HttpRequest req,
      HttpResponse res,
      @PathVariable("user_id") int userId,
      @PathVariable("name") String name]) async {
    return {'id': userId, 'name': name};
  }, name: 'user');

  app.post("/cookie", (Context context,
      [HttpRequest req,
      HttpResponse res,
      @CookieValue("name") String name]) async {
    return [
      {'name': name}
    ];
  });

  app.post("/header", (Context context,
      [HttpRequest req,
      HttpResponse res,
      @RequestHeader("Content-Type") String contentType]) async {
    return {'Content-Type': contentType};
  });

  app.post("/setSession", (Context context,
      [HttpRequest req, HttpResponse res]) async {
    req.session.putIfAbsent("name", () {
      return "peter";
    });
    return {"name": req.session["name"], "jsessionid": req.session.id};
  });

  app.post("/getSession", (Context context,
      [HttpRequest req,
      HttpResponse res,
      @SessionValue("name") String name]) async {
    return {"name": name};
  });

  // 请求头不含contentType
  app.post("/request_no_content_type", (Context context,
      [HttpRequest req, HttpResponse res]) async {
    return {'contentType': req.headers.contentType?.toString()};
  });

  app.post("/application_json", (Context context,
      [HttpRequest req, HttpResponse res]) async {
    return context.request.data;
  });

  app.get("path_params", (Context context,
      [HttpRequest req,
      HttpResponse res,
      @UrlParam('age') int age,
      @UrlParam('isHero') bool isHero,
      @UrlParam('friends') List<String> friends,
      @UrlParam('grandpa') String grandpa,
      @RequestParam('actors') List<String> actors]) async {
    return {
      'age': age,
      'isHero': isHero,
      'friends': friends,
      'grandpa': grandpa,
      'money': null,
      'actors': actors
    };
  });

  app.post("/x-www-form-urlencoded", (Context context,
      [HttpRequest req,
      HttpResponse res,
      @UrlParam('age') int age,
      @UrlParam('isHero') bool isHero,
      @UrlParam('friends') List<String> friends,
      @UrlParam('grandpa') String grandpa,
      @RequestParam('actors') List<String> actors]) async {
    return {
      'age': age,
      'isHero': isHero,
      'friends': friends,
      'grandpa': grandpa,
      'money': null,
      'actors': actors
    };
  });

  app.get("/router-timeout", (Context context,
      [HttpRequest req, HttpResponse res]) async {
    return await Future.delayed(Duration(milliseconds: 10), () {
      return {'timeout': 10};
    });
  }).setTimeout(RequestTimeout(Duration(milliseconds: 11), () async {
    return {'timeout': 11};
  }));

  app.get("/router-timeout-take-effect", (Context context,
      [HttpRequest req, HttpResponse res]) async {
    return await Future.delayed(Duration(milliseconds: 10), () {
      return {'timeout': 10};
    });
  }).setTimeout(RequestTimeout(Duration(milliseconds: 5), () async {
    return {'timeout': 5};
  }));

  // 国际化示例
  app.get("/i18n", (Context context, 
      [HttpRequest req, HttpResponse res, @Locale() String locale]) async {
    return {
      'message': 'Hello, World!',
      'locale': locale
    };
  });

  // Request注解示例
  app.get("/request-example", (Context context, 
      [HttpRequest req, HttpResponse res, @Request() Request request]) async {
    return {
      'method': request.method,
      'path': request.path,
      'hasRequest': request != null
    };
  });

  // 文本请求示例
  app.post("/text-request", (Context context, 
      [HttpRequest req, HttpResponse res]) async {
    return {
      'text': context.request.data['text'],
      'contentType': req.headers.contentType?.toString()
    };
  });

  // XML请求示例
  app.post("/xml-request", (Context context, 
      [HttpRequest req, HttpResponse res]) async {
    return {
      'xml': context.request.data['xml'],
      'contentType': req.headers.contentType?.toString()
    };
  });

  // 跨域请求示例
  app.get("/cors-example", (Context context, 
      [HttpRequest req, HttpResponse res]) async {
    return {
      'message': 'CORS enabled',
      'origin': req.headers.value('Origin')
    };
  });

  // 错误处理示例
  app.get("/error-example", (Context context, 
      [HttpRequest req, HttpResponse res]) async {
    throw Exception('Test error');
  });

  // Blueprint示例
  // 创建用户相关的Blueprint
  Blueprint userBlueprint = Blueprint('user', prefix: '/api/users');
  
  // 注册用户相关路由
  userBlueprint.get('', (Context context, [HttpRequest req, HttpResponse res]) async {
    return {
      'message': 'Get all users',
      'endpoint': 'userBlueprint'
    };
  });
  
  userBlueprint.get('/:id', (Context context, [HttpRequest req, HttpResponse res, @PathVariable('id') String id]) async {
    return {
      'message': 'Get user by id',
      'id': id,
      'endpoint': 'userBlueprint'
    };
  });
  
  userBlueprint.post('', (Context context, [HttpRequest req, HttpResponse res]) async {
    return {
      'message': 'Create user',
      'endpoint': 'userBlueprint'
    };
  });
  
  userBlueprint.put('/:id', (Context context, [HttpRequest req, HttpResponse res, @PathVariable('id') String id]) async {
    return {
      'message': 'Update user',
      'id': id,
      'endpoint': 'userBlueprint'
    };
  });
  
  userBlueprint.delete('/:id', (Context context, [HttpRequest req, HttpResponse res, @PathVariable('id') String id]) async {
    return {
      'message': 'Delete user',
      'id': id,
      'endpoint': 'userBlueprint'
    };
  });
  
  // 创建产品相关的Blueprint
  Blueprint productBlueprint = Blueprint('product', prefix: '/api/products');
  
  // 注册产品相关路由
  productBlueprint.get('', (Context context, [HttpRequest req, HttpResponse res]) async {
    return {
      'message': 'Get all products',
      'endpoint': 'productBlueprint'
    };
  });
  
  productBlueprint.get('/:id', (Context context, [HttpRequest req, HttpResponse res, @PathVariable('id') String id]) async {
    return {
      'message': 'Get product by id',
      'id': id,
      'endpoint': 'productBlueprint'
    };
  });
  
  // 注册Blueprint到应用
  app.registerBlueprint(userBlueprint);
  app.registerBlueprint(productBlueprint);

  // 注解式路由示例
  // 扫描带有路由注解的类
  RouteScanner.scanClass(app, UserController);
  RouteScanner.scanClass(app, ProductController);
  
  // 扫描带有@BlueprintRoute注解的类
  RouteScanner.scanClass(app, AnnotatedBlueprintController);

  await app.listen(8081);
  print('Q.dart Comprehensive Example Server started on port 8081');
  print('\n=== Available Endpoints ===');
  print('\nPublic Endpoints:');
  print('- GET  /health          - Health check');
  print('- GET  /public          - Public endpoint');
  print('- POST /login           - User login (username: admin/user, password: any)');
  print('- POST /refresh-token   - Refresh token');
  print('- GET  /csrf-token      - Get CSRF token');
  print('- GET  /hello           - Basic hello endpoint');
  print('- GET  /user            - Get user information');
  print('- GET  /user/:id        - Route parameters example');
  print('- GET  /user/:user_id/:name - Get user by ID and name');
  print('- GET  /search          - Query parameters example');
  print('- POST /form            - Form data example');
  print('- POST /json            - JSON data example');
  print('- POST /application_json - JSON request example');
  print('- GET  /path_params     - URL parameters example');
  print('- POST /x-www-form-urlencoded - Form data example');
  print('- GET  /router-timeout  - Router timeout example');
  print('- GET  /i18n            - Internationalization example');
  print('- GET  /request-example - Request annotation example');
  print('- POST /text-request    - Text request example');
  print('- POST /xml-request     - XML request example');
  print('- GET  /cors-example    - CORS example');
  print('- GET  /error-example   - Error handling example');
  print('- POST /redirect        - Redirect example');
  print('- POST /redirect_name   - Named redirect example');
  print('- POST /redirect_user   - Redirect with path variables example');
  print('- POST /user_redirect   - Redirect target example');
  print('\nProtected Endpoints:');
  print('- GET  /api/users       - Get all users (requires auth)');
  print('- POST /api/users       - Create user (requires ADMIN)');
  print('- GET  /admin           - Admin only endpoint (requires ADMIN)');
  print('- POST /xss-test        - XSS protection test (requires auth)');
  print('- POST /upload          - File upload test (requires auth)');
  print('- POST /multipart-form-data - File upload example (requires auth)');
  print('- POST /cookie          - Cookie example (requires auth)');
  print('- POST /header          - Request header example (requires auth)');
  print('- POST /setSession      - Set session example (requires auth)');
  print('- POST /getSession      - Get session example (requires auth)');
  print('- POST /request_no_content_type - No content type example (requires auth)');
  print('\nBlueprint Endpoints:');
  print('- GET  /api/users        - Get all users (userBlueprint)');
  print('- GET  /api/users/:id    - Get user by id (userBlueprint)');
  print('- POST /api/users        - Create user (userBlueprint)');
  print('- PUT  /api/users/:id    - Update user (userBlueprint)');
  print('- DELETE /api/users/:id  - Delete user (userBlueprint)');
  print('- GET  /api/products     - Get all products (productBlueprint)');
  print('- GET  /api/products/:id - Get product by id (productBlueprint)');
  print('\nAnnotated Routes:');
  print('- GET  /api/annotated/users        - Get all users (UserController)');
  print('- GET  /api/annotated/users/:id    - Get user by id (UserController)');
  print('- POST /api/annotated/users        - Create user (UserController)');
  print('- PUT  /api/annotated/users/:id    - Update user (UserController)');
  print('- DELETE /api/annotated/users/:id  - Delete user (UserController)');
  print('- GET  /api/annotated/products     - Get all products (ProductController)');
  print('- GET  /api/annotated/products/:id - Get product by id (ProductController)');
  print('- POST /api/annotated/products     - Create product (ProductController)');
  print('\n@BlueprintRoute Annotated Routes:');
  print('- GET  /api/annotated_blueprint/users        - Get all users (AnnotatedBlueprintController)');
  print('- GET  /api/annotated_blueprint/users/:id    - Get user by id (AnnotatedBlueprintController)');
  print('- POST /api/annotated_blueprint/users        - Create user (AnnotatedBlueprintController)');
  print('- PUT  /api/annotated_blueprint/users/:id    - Update user (AnnotatedBlueprintController)');
  print('- DELETE /api/annotated_blueprint/users/:id  - Delete user (AnnotatedBlueprintController)');
  print('- GET  /api/annotated_blueprint/products     - Get all products (AnnotatedBlueprintController)');
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
  print('\n6. Internationalization:');
  print('   - GET /i18n?locale=en - English locale');
  print('   - GET /i18n?locale=zh-CN - Chinese locale');
  print('\n7. Cross-Origin Requests:');
  print('   - Test from a different domain to see CORS headers');
  print('\n8. Request Types:');
  print('   - POST /text-request with Content-Type: text/plain');
  print('   - POST /xml-request with Content-Type: application/xml');
  print('\nServer is ready for testing!');
}


