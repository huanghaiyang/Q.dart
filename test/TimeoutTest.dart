import 'dart:io';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:Q/Q.dart';
import 'package:Q/src/annotation/Route.dart';
import 'package:Q/src/annotation/Timeout.dart' as QTimeout;

void main() {
  Application app;
  final port = 8082;
  final baseUrl = 'http://localhost:$port';

  setUpAll(() async {
    // 创建应用
    app = Application()
      ..args(['--application.environment=dev', '--application.resourceDir=/test/example/resources']);
    await app.init();

    // 直接注册路由，不使用注解扫描
    app.get('/fast', (Context context, [HttpRequest req, HttpResponse res]) async {
      return 'Fast response';
    });

    app.get('/slow', (Context context, [HttpRequest req, HttpResponse res]) async {
      await Future.delayed(Duration(milliseconds: 200)); // 200ms 延迟，会超时
      return 'Slow response';
    }).setTimeout(RequestTimeout(
      Duration(milliseconds: 100), // 100ms 超时
      () async => 'Request timeout',
    ));

    app.get('/normal', (Context context, [HttpRequest req, HttpResponse res]) async {
      await Future.delayed(Duration(milliseconds: 100)); // 100ms 延迟，不会超时
      return 'Normal response';
    }).setTimeout(RequestTimeout(
      Duration(milliseconds: 500), // 500ms 超时
      () async => 'Request timeout',
    ));

    // 启动服务器
    app.listen(port);
    print('Test server started on port $port');
    
    // 等待应用启动完成
    await Future.delayed(Duration(milliseconds: 500));
  });

  tearDownAll(() async {
    if (app != null) {
      try {
        await app.close();
      } catch (e) {
        // 忽略关闭时的错误
      }
      app = null;
    }
    print('Test server stopped');
  });

  group('Timeout tests', () {
    test('Fast route without timeout should return immediately', () async {
      final response = await http.get(Uri.parse('$baseUrl/fast'));
      expect(response.statusCode, equals(200));
      expect(response.body, equals('"Fast response"')); // JSON 编码后的字符串
    });

    test('Slow route with timeout should timeout', () async {
      final startTime = DateTime.now();
      final response = await http.get(Uri.parse('$baseUrl/slow'));
      final duration = DateTime.now().difference(startTime);

      print('Slow route duration: ${duration.inMilliseconds}ms');
      print('Slow route response: ${response.body}');

      // 应该快速返回（超时），而不是等待 200ms（允许一定误差）
      expect(duration.inMilliseconds, lessThan(200));
      expect(response.body, equals('"Request timeout"')); // JSON 编码后的字符串
    });

    test('Normal route with sufficient timeout should complete', () async {
      final response = await http.get(Uri.parse('$baseUrl/normal'));
      expect(response.statusCode, equals(200));
      expect(response.body, equals('"Normal response"')); // JSON 编码后的字符串
    });
  });
}
