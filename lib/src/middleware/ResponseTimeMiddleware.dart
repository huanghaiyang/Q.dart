import 'dart:io';
import 'package:Q/src/Context.dart';
import 'package:Q/src/Middleware.dart';

/// 响应时间中间件
/// 用于计算请求的响应时间，并将其添加到响应头中
class ResponseTimeMiddleware implements Middleware {
  @override
  MiddlewareType type = MiddlewareType.AFTER;
  @override
  int priority = 60;
  @override
  String name = 'response_time';
  @override
  String group = 'performance';

  /// 响应头名称
  final String headerName;

  /// 构造函数
  /// [headerName] 响应头名称，默认为 'X-Response-Time'
  ResponseTimeMiddleware({
    this.headerName = 'X-Response-Time',
  });

  @override
  Future<Context> handle(Context context, Function onFinished, Function onError) async {
    // 记录开始时间
    DateTime startTime = DateTime.now();
    
    // 继续处理请求
    Context result = await onFinished();
    
    // 计算响应时间
    Duration responseTime = DateTime.now().difference(startTime);
    
    // 将响应时间添加到响应头
    result.response.headers.add(headerName, '${responseTime.inMilliseconds}ms');
    
    return result;
  }
}
