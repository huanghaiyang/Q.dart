/// 路由注解的基类
class Route {
  /// 路由路径
  final String path;
  
  /// 路由名称
  final String name;
  
  const Route(this.path, {this.name});
}

/// GET请求路由注解
class Get extends Route {
  const Get(String path, {String name}) : super(path, name: name);
}

/// POST请求路由注解
class Post extends Route {
  const Post(String path, {String name}) : super(path, name: name);
}

/// PUT请求路由注解
class Put extends Route {
  const Put(String path, {String name}) : super(path, name: name);
}

/// DELETE请求路由注解
class Delete extends Route {
  const Delete(String path, {String name}) : super(path, name: name);
}

/// PATCH请求路由注解
class Patch extends Route {
  const Patch(String path, {String name}) : super(path, name: name);
}

/// Blueprint注解，用于标记一个类作为Blueprint
class BlueprintRoute {
  /// Blueprint的名称
  final String name;
  
  /// 路由前缀
  final String prefix;
  
  const BlueprintRoute(this.name, {this.prefix = ''});
}
