import 'dart:io';
import 'dart:math';
import 'package:Q/src/Context.dart';
import 'package:Q/src/Middleware.dart';

/// 速率限制中间件
/// 用于限制客户端在一定时间内的请求数量，防止滥用
class RateLimitMiddleware implements Middleware {
  @override
  MiddlewareType type = MiddlewareType.BEFORE;
  @override
  int priority = 100; // 较高优先级
  @override
  String name = 'rate_limit';
  @override
  String group = 'security';

  /// 存储客户端的请求次数
  final Map<String, _RateLimitInfo> _rateLimits = {};
  
  /// 时间窗口（秒）
  final int windowSeconds;
  
  /// 每个时间窗口内的最大请求数
  final int maxRequests;
  
  /// 限制策略
  final RateLimitStrategy strategy;

  /// 构造函数
  /// [windowSeconds] 时间窗口（秒），默认为60
  /// [maxRequests] 每个时间窗口内的最大请求数，默认为100
  /// [strategy] 限制策略，默认为IP策略
  RateLimitMiddleware({
    this.windowSeconds = 60,
    this.maxRequests = 100,
    this.strategy = RateLimitStrategy.IP,
  });

  @override
  Future<Context> handle(Context context, Function onFinished, Function onError) async {
    // 获取客户端标识
    String clientId = _getClientId(context);
    
    // 清理过期的记录
    _cleanupExpired();
    
    // 检查是否超出限制
    if (_isRateLimited(clientId)) {
      // 超出限制，返回429错误
      context.response.status = HttpStatus.tooManyRequests;
      context.response.headers.add('X-RateLimit-Limit', '$maxRequests');
      context.response.headers.add('X-RateLimit-Remaining', '0');
      context.response.body = {
        'error': 'Too many requests',
        'message': 'Rate limit exceeded. Please try again later.',
      };
      return context;
    }
    
    // 记录请求
    _recordRequest(clientId);
    
    // 添加速率限制相关的响应头
    int remaining = maxRequests - (_rateLimits[clientId]?.count ?? 0);
    context.response.headers.add('X-RateLimit-Limit', '$maxRequests');
    context.response.headers.add('X-RateLimit-Remaining', '$remaining');
    context.response.headers.add('X-RateLimit-Window', '$windowSeconds');
    
    // 继续处理请求
    return await onFinished();
  }

  /// 获取客户端标识
  String _getClientId(Context context) {
    switch (strategy) {
      case RateLimitStrategy.IP:
        return context.request.req.connectionInfo.remoteAddress.address;
      case RateLimitStrategy.HEADER:
        return context.request.req.headers.value('X-Client-Id') ?? 
               context.request.req.connectionInfo.remoteAddress.address;
      case RateLimitStrategy.TOKEN:
        String token = context.request.req.headers.value('Authorization');
        return token?.replaceFirst('Bearer ', '') ?? 
               context.request.req.connectionInfo.remoteAddress.address;
      default:
        return context.request.req.connectionInfo.remoteAddress.address;
    }
  }

  /// 检查是否超出速率限制
  bool _isRateLimited(String clientId) {
    _RateLimitInfo info = _rateLimits[clientId];
    if (info == null) {
      return false;
    }
    
    // 检查是否在时间窗口内
    if (DateTime.now().difference(info.startTime).inSeconds < windowSeconds) {
      // 检查请求次数是否超过限制
      return info.count >= maxRequests;
    }
    
    return false;
  }

  /// 记录请求
  void _recordRequest(String clientId) {
    _RateLimitInfo info = _rateLimits[clientId];
    if (info == null || DateTime.now().difference(info.startTime).inSeconds >= windowSeconds) {
      // 新建记录或时间窗口已过期
      _rateLimits[clientId] = _RateLimitInfo(DateTime.now(), 1);
    } else {
      // 更新记录
      info.count++;
    }
  }

  /// 清理过期的记录
  void _cleanupExpired() {
    List<String> expiredKeys = [];
    DateTime now = DateTime.now();
    
    _rateLimits.forEach((key, info) {
      if (now.difference(info.startTime).inSeconds >= windowSeconds) {
        expiredKeys.add(key);
      }
    });
    
    for (String key in expiredKeys) {
      _rateLimits.remove(key);
    }
  }
}

/// 速率限制策略
enum RateLimitStrategy {
  IP,      // 基于IP地址
  HEADER,  // 基于自定义头
  TOKEN,   // 基于认证令牌
}

/// 速率限制信息
class _RateLimitInfo {
  final DateTime startTime;
  int count;

  _RateLimitInfo(this.startTime, this.count);
}
