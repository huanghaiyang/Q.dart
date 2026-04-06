# 中间件

中间件是 Q.dart 框架中的一个重要概念，它可以在请求处理过程中执行一些操作，例如日志记录、认证授权、CORS 处理等。

## 什么是中间件

中间件是一个实现了 `Middleware` 接口的类，它可以在请求到达路由处理函数之前或之后执行一些操作。

## 创建中间件

要创建中间件，您需要实现 `Middleware` 接口：

```dart
import 'package:Q/Q.dart';

class LoggerMiddleware implements Middleware {
  @override
  Future<bool> handle(Context context, Next next) async {
    // 请求处理前的操作
    print('Request: ${context.request.method} ${context.request.uri.path}');
    
    // 继续处理请求
    bool proceed = await next();
    
    // 请求处理后的操作
    print('Response: ${context.response.status}');
    
    return proceed;
  }
}
```

## 使用中间件

### 全局中间件

全局中间件会应用到所有请求：

```dart
app.use(LoggerMiddleware());
```

### 路由级中间件

路由级中间件只应用到特定路由：

```dart
app.get('/protected', (Context context) async {
  return {'message': 'Protected resource'};
}, middleware: [AuthMiddleware()]);
```

### 中间件链

您可以创建中间件链，多个中间件会按顺序执行：

```dart
app.use([
  LoggerMiddleware(),
  AuthMiddleware(),
  CorsMiddleware()
]);
```

## 内置中间件

Q.dart 提供了一些内置中间件：

### LoggerMiddleware

日志中间件，用于记录请求和响应信息：

```dart
app.use(LoggerMiddleware());
```

### CorsMiddleware

CORS 中间件，用于处理跨域请求：

```dart
app.use(CorsMiddleware());
```

### CsrfMiddleware

CSRF 保护中间件，用于防止 CSRF 攻击：

```dart
app.use(CsrfMiddleware());
```

### XssMiddleware

XSS 防护中间件，用于防止 XSS 攻击：

```dart
app.use(XssMiddleware());
```

## 中间件执行顺序

中间件的执行顺序如下：

1. 全局中间件（按注册顺序）
2. 路由级中间件（按注册顺序）
3. 路由处理函数
4. 路由级中间件（反向顺序）
5. 全局中间件（反向顺序）

## 中间件的返回值

中间件的 `handle` 方法返回一个 `Future<bool>`，表示是否继续处理请求：

- `true`：继续处理请求
- `false`：停止处理请求

## 中间件中的错误处理

您可以在中间件中捕获和处理错误：

```dart
class ErrorHandlerMiddleware implements Middleware {
  @override
  Future<bool> handle(Context context, Next next) async {
    try {
      return await next();
    } catch (e) {
      print('Error: $e');
      context.response.status = HttpStatus.internalServerError;
      context.response.body = {'error': 'Internal server error'};
      return false;
    }
  }
}
```

## 中间件的最佳实践

1. **单一职责**：每个中间件只负责一个功能
2. **可配置性**：中间件应该支持配置
3. **错误处理**：中间件应该处理自己的错误
4. **文档**：为中间件提供清晰的文档
5. **测试**：为中间件编写测试

## 示例：认证中间件

```dart
class AuthMiddleware implements Middleware {
  @override
  Future<bool> handle(Context context, Next next) async {
    String token = context.request.req.headers.value('Authorization');
    
    if (token == null || !token.startsWith('Bearer ')) {
      context.response.status = HttpStatus.unauthorized;
      context.response.body = {'error': 'Unauthorized'};  
      return false;
    }
    
    // 验证 token
    String jwt = token.substring(7);
    try {
      // 验证 JWT token
      // ...
      
      // 将用户信息存储到上下文
      context.setState('user', {'id': 1, 'name': 'John'});
      
      return await next();
    } catch (e) {
      context.response.status = HttpStatus.unauthorized;
      context.response.body = {'error': 'Invalid token'};
      return false;
    }
  }
}
```
