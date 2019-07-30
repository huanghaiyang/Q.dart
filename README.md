# Q.dart-轻量级Dart服务端框架
### 开发中

## 参考
+ spring-framework
+ koa
+ egg.js

## 使用方式
```dart
import 'dart:io';

import 'package:Q/Q.dart';

main() {
  Application app = Application();

  // app.applicationContext.configuration.unSupportedContentTypes.add(ContentType('multipart', 'form-data'));
  // app.applicationContext.configuration.unSupportedMethods.add(HttpMethod.POST);
  app.route(Router("/users", HttpMethod.GET, (Context ctx, [HttpRequest req, HttpResponse res]) async {
    return {'name': 'huang'};
  }));

  app.route(Router("/upload", HttpMethod.POST, (Context ctx, [HttpRequest req, HttpResponse res]) async {
    return {'name': 'huang'};
  }));

  app.route(Router("/user", HttpMethod.POST, (Context ctx, [HttpRequest req, HttpResponse res]) async {
    return {'success': true};
  }));

  app.route(Router("/user_redirect", HttpMethod.POST, (Context ctx, [HttpRequest req, HttpResponse res]) async {
    Map<String, String> map = Map();
    ctx.attributes.forEach((String key, Attribute value) {
      map[key] = value.value;
    });
    return map;
  }, name: 'user_redirect'));

  app.route(Router("/redirect", HttpMethod.POST, (Context ctx, [HttpRequest req, HttpResponse res]) async {
    return Redirect("/user_redirect", HttpMethod.POST, attributes: [Attribute('hello', 'world')]);
  }));

  app.route(Router("/redirect_name", HttpMethod.POST, (Context ctx, [HttpRequest req, HttpResponse res]) async {
    return Redirect("name:user_redirect", HttpMethod.POST, attributes: [Attribute('hello', 'world')]);
  }));

  app.route(Router("/redirect_user", HttpMethod.POST, (Context ctx, [HttpRequest req, HttpResponse res]) async {
    return Redirect("name:user", HttpMethod.GET, pathVariables: {"user_id": "1", "name": "huang"});
  }));

  app.route(Router("/user/:user_id/:name", HttpMethod.GET, (Context ctx,
      [HttpRequest req, HttpResponse res, @PathVariable("user_id") int userId, @PathVariable("name") String name]) async {
    return {'id': userId, 'name': name};
  }, name: 'user'));

  app.listen(8081);
}

```

## 概念

+ `Context` 请求上下文，封装了`Request`和`Response`
+ `Request` 封装`HttpRequest`
+ `Response` 封装`HttpResponse`
+ `Router` 路由匹配及请求处理
+ `Resolver` 请求处理器，将`HttpRequest`解析成对应的`Request`
+ `MiddleWare` 中间件 ， 分为路由前置中间件和路由后置中间件，中间件执行没有顺序
+ `Interceptor` 拦截器，包含方法`preHandle`和`postHandle`,在路由前后执行
+ `Attribute` 当前请求上下文共享参数
+ `Configuration` 应用程序配置
+ `ApplicationContext` 当前应用程序上下文
