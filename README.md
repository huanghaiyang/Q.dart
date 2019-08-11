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

Application app;

void main() {
  start();
}

void start() {
  app = Application();

  // app.applicationContext.configuration.unSupportedContentTypes.add(ContentType('multipart', 'form-data'));
  // app.applicationContext.configuration.unSupportedMethods.add(HttpMethod.POST);

  // multipart/form-data
  app.route(Router("/multipart-form-data", HttpMethod.POST, (Context context,
      [HttpRequest req,
      HttpResponse res,
      @RequestParam("name") String name,
      @RequestParam("friends") List<String> friends,
      @RequestParam("file") List<MultipartFile> files,
      @RequestParam("file") File file,
      @RequestParam("age") int age]) async {
    return {'name': name, "friends": friends, "file_length": files.length, "file_bytes_length": await file.length(), "age": age};
  }));

  app.route(Router("/user", HttpMethod.GET, (Context context, [HttpRequest req, HttpResponse res]) async {
    return {'name': "peter"};
  }));

  app.route(Router("/user_redirect", HttpMethod.POST, (Context context, [HttpRequest req, HttpResponse res]) async {
    Map<String, String> map = Map();
    context.attributes.forEach((String key, Attribute value) {
      map[key] = value.value;
    });
    return map;
  }, name: 'user_redirect'));

  app.route(Router("/redirect", HttpMethod.POST, (Context context, [HttpRequest req, HttpResponse res]) async {
    return Redirect("/user_redirect", HttpMethod.POST, attributes: [Attribute('hello', 'world')]);
  }));

  app.route(Router("/redirect_name", HttpMethod.POST, (Context context, [HttpRequest req, HttpResponse res]) async {
    return Redirect("name:user_redirect", HttpMethod.POST, attributes: [Attribute('hello', 'world')]);
  }));

  app.route(Router("/redirect_user", HttpMethod.POST, (Context context, [HttpRequest req, HttpResponse res]) async {
    return Redirect("name:user", HttpMethod.GET, pathVariables: {"user_id": "1", "name": "peter"});
  }));

  app.route(Router("/user/:user_id/:name", HttpMethod.GET, (Context context,
      [HttpRequest req, HttpResponse res, @PathVariable("user_id") int userId, @PathVariable("name") String name]) async {
    return {'id': userId, 'name': name};
  }, name: 'user'));

  app.route(
      Router("/cookie", HttpMethod.POST, (Context context, [HttpRequest req, HttpResponse res, @CookieValue("name") String name]) async {
    return [
      {'name': name}
    ];
  }));

  app.route(Router("/header", HttpMethod.POST, (Context context,
      [HttpRequest req, HttpResponse res, @RequestHeader("Content-Type") String contentType]) async {
    return {'Content-Type': contentType};
  }));

  app.route(Router("/setSession", HttpMethod.POST, (Context context, [HttpRequest req, HttpResponse res]) async {
    req.session.putIfAbsent("name", () {
      return "peter";
    });
    return {"name": req.session["name"], "jsessionid": req.session.id};
  }));

  app.route(Router("/getSession", HttpMethod.POST, (Context context,
      [HttpRequest req, HttpResponse res, @SessionValue("name") String name]) async {
    return {"name": name};
  }));

  // 请求头不含contentType
  app.route(Router("/request_no_content_type", HttpMethod.POST, (Context context, [HttpRequest req, HttpResponse res]) async {
    return {'contentType': req.headers.contentType?.toString()};
  }));

  app.route(Router("/application_json", HttpMethod.POST, (Context context, [HttpRequest req, HttpResponse res]) async {
    return context.request.data;
  }));

  app.route(Router("/path_params", HttpMethod.GET, (Context context,
      [HttpRequest req,
      HttpResponse res,
      @UrlParam('age') int age,
      @UrlParam('isHero') bool isHero,
      @UrlParam('friends') List<String> friends,
      @UrlParam('grandpa') String grandpa,
      @RequestParam('actors') List<String> actors]) async {
    return {'age': age, 'isHero': isHero, 'friends': friends, 'grandpa': grandpa, 'money': null, 'actors': actors};
  }));

  app.route(Router("/x-www-form-urlencoded", HttpMethod.POST, (Context context,
      [HttpRequest req,
      HttpResponse res,
      @UrlParam('age') int age,
      @UrlParam('isHero') bool isHero,
      @UrlParam('friends') List<String> friends,
      @UrlParam('grandpa') String grandpa,
      @RequestParam('actors') List<String> actors]) async {
    return {'age': age, 'isHero': isHero, 'friends': friends, 'grandpa': grandpa, 'money': null, 'actors': actors};
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
+ `Attribute` 当前请求上下文共享参数
+ `Configuration` 应用程序配置
+ `ApplicationContext` 当前应用程序上下文
