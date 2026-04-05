import 'dart:io';
import 'dart:mirrors';

import 'package:Q/Q.dart';
import 'package:Q/src/Method.dart';
import 'package:Q/src/Context.dart';
import 'package:Q/src/helpers/RouterHelper.dart';
import 'package:test/test.dart';
import 'package:matcher/matcher.dart';

@pragma('vm:entry-point')
class UnSupport {
  const UnSupport();
}

// 模拟HttpRequest类
class MockHttpRequest implements HttpRequest {
  final String method;
  final Uri uri;
  
  MockHttpRequest(String method, String path) : 
    this.method = method,
    this.uri = Uri.parse('http://localhost:8080$path');
  
  // 实现必要的方法和属性
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
  
  @override
  HttpResponse get response => null;
  
  @override
  HttpConnectionInfo get connectionInfo => null;
  
  @override
  List<Cookie> get cookies => [];
  
  @override
  HttpHeaders get headers => null;
  
  @override
  String get protocolVersion => 'HTTP/1.1';
  
  @override
  bool get persistentConnection => false;
  
  @override
  void detachSocket(Socket socket, {bool writeHeaders = true}) {}
  
  @override
  Future<Socket> detachSocketRaw() async => null;
  
  @override
  X509Certificate get certificate => null;
  
  @override
  String get remoteAddress => '127.0.0.1';
  
  @override
  int get remotePort => 12345;
  
  @override
  String get localAddress => '127.0.0.1';
  
  @override
  int get localPort => 8080;
}

void main() {
  group('RouterHelper', () {
    List<Router> routers;
    Router requestUserByIdAndNameRouter;

    setUp(() {
      routers = List();
      requestUserByIdAndNameRouter = 
          Router("/user/:id/:name", HttpMethod.POST, (Context context, [HttpRequest request, HttpResponse response]) async {
        return {};
      }, pathVariables: {"id": 1, "name": "peter"}, name: 'request_user_named_peter');

      routers.add(requestUserByIdAndNameRouter);
    });

    test('RouterHelper::applyPathVariables', () {
      Map<String, String> variables = RouterHelper.applyPathVariables('/user/1/peter', '/user/:id/:name');
      expect(variables, {"id": '1', "name": "peter"});
    });

    test('RouterHelper::reBuildPathByVariables', () {
      String requestPath = RouterHelper.reBuildPathByVariables(requestUserByIdAndNameRouter);
      expect(requestPath, '/user/1/peter');
    });

    tearDown(() {
      routers = null;
      requestUserByIdAndNameRouter = null;
    });
  });

  group('Router matching', () {
    Application app;

    setUp(() async {
      app = Application();
      app.args([]); // 设置命令行参数
      await app.init(); // 初始化应用
      
      // 添加测试路由
      app.get('/hello', (Context context, [HttpRequest request, HttpResponse response]) async {
        return 'Hello, World!';
      });
      
      app.get('/user/:id', (Context context, [HttpRequest request, HttpResponse response]) async {
        String id = context.router.getPathVariable('id');
        return 'User ID: $id';
      });
      
      app.post('/user', (Context context, [HttpRequest request, HttpResponse response]) async {
        return 'Create user';
      });
      
      app.get('/users/*', (Context context, [HttpRequest request, HttpResponse response]) async {
        return 'All users';
      });
    });

    test('should match exact route', () async {
      MockHttpRequest request = MockHttpRequest('GET', '/hello');
      List<Router> routers = Application.getRouters();
      Router matchedRouter = await RouterHelper.matchRouter(request, routers);
      expect(matchedRouter != null, true);
      expect(matchedRouter.path, '/hello');
      expect(matchedRouter.methodName, 'GET');
    });

    test('should match route with path parameters', () async {
      MockHttpRequest request = MockHttpRequest('GET', '/user/123');
      List<Router> routers = Application.getRouters();
      Router matchedRouter = await RouterHelper.matchRouter(request, routers);
      expect(matchedRouter != null, true);
      expect(matchedRouter.path, '/user/:id');
      expect(matchedRouter.methodName, 'GET');
      expect(matchedRouter.pathVariables['id'], '123');
    });

    test('should match route with different HTTP method', () async {
      MockHttpRequest request = MockHttpRequest('POST', '/user');
      List<Router> routers = Application.getRouters();
      Router matchedRouter = await RouterHelper.matchRouter(request, routers);
      expect(matchedRouter != null, true);
      expect(matchedRouter.path, '/user');
      expect(matchedRouter.methodName, 'POST');
    });

    test('should match wildcard route', () async {
      MockHttpRequest request = MockHttpRequest('GET', '/users/all');
      List<Router> routers = Application.getRouters();
      Router matchedRouter = await RouterHelper.matchRouter(request, routers);
      expect(matchedRouter != null, true);
      expect(matchedRouter.path, '/users/*');
      expect(matchedRouter.methodName, 'GET');
    });

    test('should throw exception for unknown route', () async {
      MockHttpRequest request = MockHttpRequest('GET', '/unknown');
      List<Router> routers = Application.getRouters();
      expect(() async {
        await RouterHelper.matchRouter(request, routers);
      }, throwsA(anything));
    });

    tearDown(() async {
      try {
        if (app != null) {
          await app.close();
          app = null;
        }
      } catch (e) {
        // 忽略关闭时的错误，确保测试能够正常完成
        print('Error closing app: $e');
        app = null;
      }
    });
  });

  group("checkoutRouterHandlerParameterAnnotations", () {
    test("expect exception", () async {
      try {
        Router("/", HttpMethod.POST, (Context context, 
            [HttpRequest request, 
            HttpResponse response, 
            @PathVariable("path") String path, 
            @CookieValue("cookie") String cookie, 
            @AttributeValue("attribute") String attribute, 
            @RequestHeader("header") String header, 
            @RequestParam("param") String param, 
            @UrlParam("urlParam") String urlParam, 
            @SessionValue("session") String session, 
            @UnSupport() String unSupport]) async {
          return {};
        });
      } catch (err) {
        expect(err is UnSupportRouterHandlerParameterAnnotationException, true);
      }
    });
  });
}
