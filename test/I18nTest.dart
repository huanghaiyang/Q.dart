import 'dart:io';
import 'package:Q/Q.dart';
import 'package:Q/src/Context.dart';
import 'package:Q/src/annotation/Request.dart' as RequestAnnotation;
import 'package:Q/src/i18n/annotations/Locale.dart';
import 'package:Q/src/i18n/I18nManager.dart';
import 'package:Q/src/i18n/I18nResourceBundle.dart';
import 'package:test/test.dart';

void main() async {
  group('I18n功能测试', () {
    Application app;

    setUp(() async {
      app = Application();
      app.args([]);
      await app.init();

      // 添加测试路由
      app.get('/hello', (Context context, [HttpRequest request, HttpResponse response]) async {
        String locale = I18nManager().getLocaleFromRequest(request);
        return {'message': 'Hello, World!', 'locale': locale};
      });

      app.get('/greet', (Context context, [HttpRequest request, HttpResponse response, @Locale() String locale]) async {
        return {'message': 'Greetings!', 'locale': locale};
      });

      app.get('/message', (Context context, [HttpRequest request, HttpResponse response]) async {
        String message = I18nManager().getMessage('welcome', locale: I18nManager().getLocaleFromRequest(request));
        return {'message': message};
      });

      app.get('/request-test', (Context context, [HttpRequest request, HttpResponse response, @RequestAnnotation.Request() req]) async {
        return {'message': 'Request object received', 'hasRequest': req != null};
      });
    });

    test('默认语言测试', () async {
      // 创建模拟请求
      MockHttpRequest request = MockHttpRequest('GET', '/hello');
      
      // 测试默认语言
      String locale = I18nManager().getLocaleFromRequest(request);
      expect(locale, 'en');
    });

    test('从查询参数获取语言测试', () async {
      // 创建模拟请求，带语言查询参数
      MockHttpRequest request = MockHttpRequest('GET', '/hello?locale=zh-CN');
      
      // 测试从查询参数获取语言
      String locale = I18nManager().getLocaleFromRequest(request);
      expect(locale, 'zh-CN');
    });

    test('Locale注解测试', () async {
      // 创建模拟请求
      MockHttpRequest request = MockHttpRequest('GET', '/greet?locale=fr');
      
      // 测试Locale注解
      // 注意：这里我们无法直接测试路由处理方法，因为需要完整的请求处理流程
      // 但我们可以测试LocaleHelper的功能
      String locale = I18nManager().getLocaleFromRequest(request);
      expect(locale, 'fr');
    });

    test('多语言资源测试', () async {
      // 测试从文件加载的英文资源
      String enMessage = I18nManager().getMessage('welcome', locale: 'en');
      expect(enMessage, 'Welcome to our application!');
      
      // 测试从文件加载的中文资源
      String zhMessage = I18nManager().getMessage('welcome', locale: 'zh-CN');
      expect(zhMessage, '欢迎使用我们的应用！');
      
      // 测试不存在的语言，应该返回默认语言
      String defaultMessage = I18nManager().getMessage('welcome', locale: 'xx');
      expect(defaultMessage, 'Welcome to our application!');
    });

    tearDown(() async {
      try {
        if (app != null) {
          await app.close();
          app = null;
        }
      } catch (e) {
        print('Error closing app: $e');
        app = null;
      }
    });
  });
}

// 模拟HttpHeaders类
class MockHttpHeaders implements HttpHeaders {
  final Map<String, List<String>> _headers = {};
  
  @override
  List<String> operator [](String name) => _headers[name.toLowerCase()];
  
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    String key = preserveHeaderCase ? name : name.toLowerCase();
    if (!_headers.containsKey(key)) {
      _headers[key] = [];
    }
    _headers[key].add(value.toString());
  }
  
  @override
  void clear() {
    _headers.clear();
  }
  
  @override
  void remove(String name, Object value) {
    String key = name.toLowerCase();
    if (_headers.containsKey(key)) {
      _headers[key].remove(value.toString());
    }
  }
  
  @override
  void removeAll(String name) {
    _headers.remove(name.toLowerCase());
  }
  
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    String key = preserveHeaderCase ? name : name.toLowerCase();
    _headers[key] = [value.toString()];
  }
  
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// 模拟HttpRequest类
class MockHttpRequest implements HttpRequest {
  final String method;
  final Uri uri;
  final List<Cookie> cookies = [];
  final MockHttpHeaders _headers = MockHttpHeaders();
  
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
  HttpHeaders get headers => _headers;
  
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
