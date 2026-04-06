# 路由系统

Q.dart 提供了灵活强大的路由系统，支持 RESTful API、路由参数、路由组等功能。

## 基本路由

### GET 请求

```dart
app.get('/users', (Context context) async {
  return {'users': []};
});
```

### POST 请求

```dart
app.post('/users', (Context context) async {
  var data = context.request.data;
  // 处理数据...
  return {'status': 'created'};
});
```

### PUT 请求

```dart
app.put('/users/:id', (Context context) async {
  var id = context.pathVariables['id'];
  // 处理数据...
  return {'status': 'updated'};
});
```

### DELETE 请求

```dart
app.delete('/users/:id', (Context context) async {
  var id = context.pathVariables['id'];
  // 处理数据...
  return {'status': 'deleted'};
});
```

### PATCH 请求

```dart
app.patch('/users/:id', (Context context) async {
  var id = context.pathVariables['id'];
  // 处理数据...
  return {'status': 'updated'};
});
```

## 路由参数

### 基本参数

```dart
app.get('/users/:id', (Context context) async {
  var id = context.pathVariables['id'];
  return {'id': id};
});
```

### 多个参数

```dart
app.get('/users/:user_id/:name', (Context context) async {
  var userId = context.pathVariables['user_id'];
  var name = context.pathVariables['name'];
  return {'user_id': userId, 'name': name};
});
```

## 路由组

```dart
// 路由组
Router userRouter = Router('/users');
userRouter.get('/', (Context context) async {
  return {'users': []};
});
userRouter.get('/:id', (Context context) async {
  var id = context.pathVariables['id'];
  return {'id': id};
});

// 注册路由组
app.route(userRouter);
```

## 路由前缀

使用 Blueprint 可以为一组路由添加前缀：

```dart
// 创建 Blueprint
Blueprint userBlueprint = Blueprint('user', prefix: '/api/users');

// 添加路由
userBlueprint.get('/', (Context context) async {
  return {'users': []};
});
userBlueprint.get('/:id', (Context context) async {
  var id = context.pathVariables['id'];
  return {'id': id};
});

// 注册 Blueprint
app.registerBlueprint(userBlueprint);
```

## 注解式路由

Q.dart 支持通过注解来定义路由：

### 普通控制器

```dart
class UserController {
  @Get('/api/users')
  Future<dynamic> getUsers(Context context) async {
    return {'users': []};
  }
  
  @Post('/api/users')
  Future<dynamic> createUser(Context context) async {
    var data = context.request.data;
    return {'status': 'created'};
  }
}

// 扫描控制器
RouteScanner.scanClass(app, UserController);
```

### Blueprint 控制器

```dart
@BlueprintRoute('user_blueprint', prefix: '/api/users')
class UserBlueprintController {
  @Get('/')
  Future<dynamic> getUsers(Context context) async {
    return {'users': []};
  }
  
  @Get('/:id')
  Future<dynamic> getUserById(Context context, [HttpRequest req, HttpResponse res, @PathVariable('id') String id]) async {
    return {'id': id};
  }
}

// 扫描控制器
RouteScanner.scanClass(app, UserBlueprintController);
```

## 路由优先级

Q.dart 的路由系统会根据以下规则确定路由优先级：

1. **精确匹配**：完全匹配路径的路由优先级最高
2. **参数匹配**：包含路径参数的路由优先级次之
3. **通配符匹配**：包含通配符的路由优先级最低

此外，路由的长度也会影响优先级，更长的路由通常具有更高的优先级。

## 路由缓存

Q.dart 会自动缓存路由匹配结果，提高路由匹配的性能。缓存默认上限为 1000 条，可以在配置文件中修改。

## 路由命名

您可以为路由指定名称，方便在其他地方引用：

```dart
app.get('/users', (Context context) async {
  return {'users': []};
}, name: 'get_users');
```

## 路由处理函数

路由处理函数是一个异步函数，接收 `Context` 对象作为参数，可选地接收 `HttpRequest`、`HttpResponse` 和其他参数：

```dart
Future<dynamic> handler(Context context, [HttpRequest req, HttpResponse res, dynamic data]) async {
  // 处理请求
  return response;
}
```

## 路由重定向

您可以使用 `context.redirect()` 方法重定向请求：

```dart
app.get('/old-path', (Context context) async {
  return context.redirect('/new-path');
});

// 使用命名路由重定向
app.get('/login', (Context context) async {
  return context.redirectTo('dashboard');
});

app.get('/dashboard', (Context context) async {
  return {'message': 'Welcome to dashboard'};
}, name: 'dashboard');
```

## 路由错误处理

### 404 处理

```dart
app.addHandler(HttpStatus.notFound, (Context context) async {
  context.response.status = HttpStatus.notFound;
  return {'error': 'Not found'};
});
```

### 500 处理

```dart
app.addHandler(HttpStatus.internalServerError, (Context context) async {
  context.response.status = HttpStatus.internalServerError;
  return {'error': 'Internal server error'};
});
```
