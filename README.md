# Q.dart-轻量级Dart服务端框架
### 开发中

## 参考
+ spring-framework
+ koa
+ egg.js

#### 实践是最好的学习方式，是检验自我能力的标准

## 使用方式
```dart
import 'dart:io';

import 'package:Q/Q.dart';

main() {
  Application app = Application();
  app.route(Router("/users", 'get', (Context ctx,
      [HttpRequest req, HttpResponse res]) {
    return {'name': 'huang'};
  }));
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
