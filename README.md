# Q.dart-轻量级Dart服务端框架
### Keep on developing

## 使用方式
```dart
import 'dart:io';

import 'package:Q/Q.dart';

main() {
  Application app = Application();
  app.router(Router("/users", 'get', (Context ctx,
      [HttpRequest req, HttpResponse res]) {
    return {'name': 'huang'};
  }));
  app.listen(8081);
}

```

## 概念

+ `Context` 请求上下文，封装了请求和响应
+ `Router` 路由匹配及请求处理
+ `MiddleWare` 中间件 ， 分为路由前置中间件和路由后置中间件，中间件执行没有顺序
+ `Interceptor` 拦截器，包含方法`preHandle`和`postHandle`,在路由前后执行
