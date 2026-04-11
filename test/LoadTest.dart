import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:Q/Q.dart';
import 'package:test/test.dart';
import 'TestHelper.dart';

void main() {
  group('压力测试', () {
    Application server;
    const String host = 'localhost';
    const int port = 8081;
    
    setUpAll(() async {
      // 启动测试服务器
      server = await startTestServer();
    });
    
    tearDownAll(() async {
      // 关闭服务器
      if (server != null) {
        await server.close();
        print('服务器已关闭');
      }
    });
    
    test('路由连接池性能测试', () async {
      // 测试配置
      const int totalRequests = 10000;
      const int concurrentRequests = 1000;
      const int maxRetries = 3;
      
      print('开始压力测试...');
      print('总请求数: $totalRequests');
      print('并发请求数: $concurrentRequests');
      print('目标服务器: http://$host:$port');
      print('最大重试次数: $maxRetries');
      
      // 记录开始时间
      final startTime = DateTime.now();
      
      // 记录成功和失败的请求数
      int successCount = 0;
      int failureCount = 0;
      
      // 记录响应时间
      List<int> responseTimes = [];
      
      // 创建并发请求
      int requestsSent = 0;
      List<Future<void>> futures = [];
      
      print('开始发送请求...');
      
      // 发送所有请求
      for (int i = 0; i < totalRequests; i++) {
        final requestId = i + 1;
        print('发送请求 $requestId');
        final future = sendRequest(host, port, requestId, (int time) {
          successCount++;
          responseTimes.add(time);
          print('请求 $requestId 成功，响应时间: $time ms');
        }, () {
          failureCount++;
          print('请求 $requestId 失败');
        });
        futures.add(future);
        
        // 控制并发数
        if (futures.length >= concurrentRequests) {
          // 等待至少一个请求完成
          await Future.any(futures);
          // 过滤掉已完成的请求
          final newFutures = <Future<void>>[];
          for (var f in futures) {
            try {
              // 尝试检查 Future 是否已完成
              if (!await f.then((_) => true).timeout(Duration(milliseconds: 10), onTimeout: () => false)) {
                newFutures.add(f);
              }
            } catch (e) {
              // 忽略错误，继续处理
            }
          }
          futures = newFutures;
        }
        
        // 每发送20个请求，等待一段时间
        if ((i + 1) % 20 == 0) {
          await Future.delayed(Duration(milliseconds: 200)); // 等待200ms
        }
        
        // 每发送100个请求，等待更长时间
        if ((i + 1) % 100 == 0) {
          await Future.delayed(Duration(milliseconds: 500)); // 等待500ms
        }
      }
      
      print('所有请求已发送，等待完成...');
      
      // 等待所有请求完成
      if (futures.isNotEmpty) {
        await Future.wait(futures);
      }
      
      print('所有请求已完成');
      
      // 记录结束时间
      final endTime = DateTime.now();
      final totalTime = endTime.difference(startTime).inMilliseconds;
      
      // 计算统计数据
      int minTime = responseTimes.isNotEmpty ? responseTimes.reduce(min) : 0;
      int maxTime = responseTimes.isNotEmpty ? responseTimes.reduce(max) : 0;
      double avgTime = responseTimes.isNotEmpty 
          ? responseTimes.reduce((a, b) => a + b) / responseTimes.length 
          : 0;
      
      // 打印测试结果
      print('\n压力测试完成!');
      print('总耗时: ${totalTime}ms');
      print('成功请求: $successCount');
      print('失败请求: $failureCount');
      print('请求成功率: ${(successCount / totalRequests * 100).toStringAsFixed(2)}%');
      print('平均响应时间: ${avgTime.toStringAsFixed(2)}ms');
      print('最小响应时间: ${minTime}ms');
      print('最大响应时间: ${maxTime}ms');
      print('QPS: ${(totalRequests / (totalTime / 1000)).toStringAsFixed(2)}');
      
      // 验证测试结果
      expect(successCount, greaterThan(0), reason: '至少有一个请求成功');
      expect(failureCount, lessThan(totalRequests), reason: '失败请求数不应等于总请求数');
      expect(avgTime, lessThan(1000), reason: '平均响应时间应小于 1000ms');
    });
  });
}

Future<Application> startTestServer() async {
  // 创建应用
  final application = await TestHelper.initTestApplication();
  // 初始化应用
  await application.init();
  
  // 注册测试路由
  application.get('/user', (Context context, [HttpRequest req, HttpResponse res]) async {
    return {"name": "peter"};
  });
  
  application.get('/path_params', (Context context, [HttpRequest req, HttpResponse res]) async {
    var queryParams = req.uri.queryParametersAll;
    return {
      "age": int.tryParse(queryParams['age']?.first ?? ''),
      "isHero": queryParams['isHero']?.first?.toLowerCase() == 'true',
      "friends": queryParams['friends'],
      "grandpa": queryParams.containsKey('grandpa') ? '' : null,
      "money": queryParams['money']?.first,
      "actors": queryParams['actors']
    };
  });
  
  application.get('/router-timeout', (Context context, [HttpRequest req, HttpResponse res]) async {
    await Future.delayed(Duration(milliseconds: 10));
    return {'timeout': 10};
  });
  
  // 启动服务器
  application.listen(8081);
  print('测试服务器已启动，监听端口 8081');
  
  // 等待服务器启动完成
  await Future.delayed(Duration(milliseconds: 1000));
  
  return application;
}

Future<void> sendRequest(String host, int port, int requestId, Function(int) onSuccess, Function() onFailure) async {
  final requestStartTime = DateTime.now();
  try {
    // 创建 HTTP 客户端
    final client = HttpClient();
    
    // 随机选择一个路由
    final routes = ['/user', '/path_params', '/router-timeout'];
    final random = Random();
    final route = routes[random.nextInt(routes.length)];
    
    // 创建请求
    final request = await client.get(host, port, route);
    
    // 发送请求并获取响应
    final response = await request.close();
    
    // 读取响应内容
    await response.drain();
    
    // 计算响应时间
    final requestEndTime = DateTime.now();
    final responseTime = requestEndTime.difference(requestStartTime).inMilliseconds;
    
    // 关闭客户端
    client.close();
    
    // 回调成功
    onSuccess(responseTime);
    
    // 每100个请求打印一次进度
    if (requestId % 100 == 0) {
      print('已完成 $requestId 个请求');
    }
  } catch (e) {
    // 回调失败
    onFailure();
    print('请求 $requestId 失败: $e');
  }
}
