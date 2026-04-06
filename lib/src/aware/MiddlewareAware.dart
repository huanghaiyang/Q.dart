import 'package:Q/src/Middleware.dart';

/// 中间件管理接口
/// 提供中间件的添加、获取、移除等操作
abstract class MiddlewareAware<T extends Middleware> {
  /// 加入一个中间件
  void use(T middleware);

  /// 使用中间件配置添加中间件
  void useWithConfig(T middleware, {
    int priority,
    String name,
    String group,
    MiddlewareType type,
  });

  /// 批量添加中间件
  void useAll(Iterable<T> middlewares);

  /// 按分组获取中间件
  List<T> getMiddlewaresByGroup(String group);

  /// 按分组移除中间件
  void removeMiddlewaresByGroup(String group);

  /// 按名称获取中间件
  T getMiddlewareByName(String name);

  /// 按名称移除中间件
  void removeMiddlewareByName(String name);

  /// 按类型获取中间件
  List<T> getMiddlewaresByType(MiddlewareType type);

  /// 移除所有中间件
  void clearMiddlewares();
}
