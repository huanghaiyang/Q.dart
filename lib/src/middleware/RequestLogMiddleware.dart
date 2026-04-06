import 'dart:io';
import 'package:Q/src/Context.dart';
import 'package:Q/src/Middleware.dart';

/// 请求日志中间件
/// 用于记录请求的详细信息，包括请求方法、路径、状态码、响应时间等
class RequestLogMiddleware implements Middleware {
  @override
  MiddlewareType type = MiddlewareType.AFTER;
  @override
  int priority = 50;
  @override
  String name = 'request_log';
  @override
  String group = 'logging';

  /// 是否记录请求体
  final bool logRequestBody;
  
  /// 是否记录响应体
  final bool logResponseBody;
  
  /// 最大日志长度
  final int maxLogLength;

  /// 构造函数
  /// [logRequestBody] 是否记录请求体，默认为false
  /// [logResponseBody] 是否记录响应体，默认为false
  /// [maxLogLength] 最大日志长度，默认为1000
  RequestLogMiddleware({
    this.logRequestBody = false,
    this.logResponseBody = false,
    this.maxLogLength = 1000,
  });

  @override
  Future<Context> handle(Context context, Function onFinished, Function onError) async {
    // 记录开始时间
    DateTime startTime = DateTime.now();
    
    // 继续处理请求
    Context result = await onFinished();
    
    // 计算响应时间
    Duration responseTime = DateTime.now().difference(startTime);
    
    // 构建日志消息
    StringBuffer logBuffer = StringBuffer();
    logBuffer.write('[${DateTime.now().toIso8601String()}] ');
    logBuffer.write('${result.request.req.method} ');
    logBuffer.write('${result.request.req.uri.path} ');
    logBuffer.write('${result.response.status} ');
    logBuffer.write('${responseTime.inMilliseconds}ms ');
    logBuffer.write('${result.request.req.connectionInfo.remoteAddress.address} ');
    logBuffer.write('${result.request.req.headers.value('User-Agent') ?? '-'}');
    
    // 记录请求体
    if (logRequestBody && result.request.data != null) {
      String requestBody = result.request.data.toString();
      if (requestBody.length > maxLogLength) {
        requestBody = requestBody.substring(0, maxLogLength) + '...';
      }
      logBuffer.write('\nRequest Body: $requestBody');
    }
    
    // 记录响应体
    if (logResponseBody && result.response.body != null) {
      String responseBody = result.response.body.toString();
      if (responseBody.length > maxLogLength) {
        responseBody = responseBody.substring(0, maxLogLength) + '...';
      }
      logBuffer.write('\nResponse Body: $responseBody');
    }
    
    // 输出日志
    print(logBuffer.toString());
    
    return result;
  }
}
