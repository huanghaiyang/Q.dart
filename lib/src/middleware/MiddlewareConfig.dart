import 'package:Q/src/Middleware.dart';

/// 中间件配置类
/// 用于更灵活地配置中间件的参数
class MiddlewareConfig {
  /// 中间件类型
  final Type middlewareType;
  
  /// 中间件实例
  final Middleware middleware;
  
  /// 中间件优先级
  final int priority;
  
  /// 中间件名称
  final String name;
  
  /// 中间件分组
  final String group;
  
  /// 中间件类型
  final MiddlewareType type;
  
  /// 构造函数
  /// [middlewareType] 中间件类型
  /// [middleware] 中间件实例
  /// [priority] 中间件优先级
  /// [name] 中间件名称
  /// [group] 中间件分组
  /// [type] 中间件类型（BEFORE 或 AFTER）
  MiddlewareConfig({
    this.middlewareType,
    this.middleware,
    this.priority,
    this.name,
    this.group,
    this.type,
  });
  
  /// 从中间件实例创建配置
  factory MiddlewareConfig.fromMiddleware(Middleware middleware) {
    return MiddlewareConfig(
      middleware: middleware,
      priority: middleware.priority,
      name: middleware.name,
      group: middleware.group,
      type: middleware.type,
    );
  }
}
