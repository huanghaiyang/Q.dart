# 快速开始

本章节将帮助您快速创建和运行第一个 Q.dart 应用。

## 1. 环境准备

首先，确保您已经安装了 Dart SDK 2.5.0 或更高版本。您可以从 [Dart 官网](https://dart.dev/get-dart) 下载并安装。

## 2. 创建项目

### 2.1 创建目录结构

创建一个新的目录作为您的项目根目录，例如 `my-qdart-app`：

```bash
mkdir my-qdart-app
cd my-qdart-app
```

### 2.2 初始化项目

使用 `dart create` 命令初始化一个新的 Dart 项目：

```bash
dart create .
```

### 2.3 添加 Q.dart 依赖

编辑 `pubspec.yaml` 文件，添加 Q.dart 依赖：

```yaml
dependencies:
  Q:
    path: /path/to/Q.dart
  # 其他依赖...
```

## 3. 创建应用

### 3.1 创建主文件

创建 `bin/main.dart` 文件，这是应用的入口点：

```dart
import 'package:Q/Q.dart';

void main() {
  // 创建应用实例
  Application app = Application();
  
  // 初始化应用
  app.init();
  
  // 定义路由
  app.get('/hello', (Context context) async {
    return 'Hello, Q.dart!';
  });
  
  // 健康检查
  app.get('/health', (Context context) async {
    return {'status': 'ok', 'time': DateTime.now().toIso8601String()};
  });
  
  // API 路由
  app.get('/api/users', (Context context) async {
    return {
      'users': [
        {'id': 1, 'name': 'User 1'},
        {'id': 2, 'name': 'User 2'},
      ]
    };
  });
  
  // 启动服务器
  app.listen(8080);
  print('Server started on port 8080');
  print('Available endpoints:');
  print('- GET /hello     - Hello world example');
  print('- GET /health    - Health check');
  print('- GET /api/users - Get users');
}
```

## 4. 运行应用

### 4.1 安装依赖

在项目根目录运行：

```bash
dart pub get
```

### 4.2 运行应用

```bash
dart run
```

### 4.3 访问应用

应用启动后，您可以通过以下 URL 访问：

- `http://localhost:8080/hello` - 查看 Hello World 示例
- `http://localhost:8080/health` - 查看健康检查
- `http://localhost:8080/api/users` - 查看用户列表

## 5. 下一步

- 了解 [路由系统](core/routing.md) 的更多功能
- 学习如何创建 [中间件](core/middleware.md)
- 探索 [安全功能](core/security.md) 的使用
- 了解如何使用 [数据库](database/connection-pool.md) 功能

## 常见问题

### Q: 应用启动失败，提示找不到 Q 包

**A:** 请确保您在 `pubspec.yaml` 中正确配置了 Q.dart 的路径。

### Q: 端口 8080 已被占用

**A:** 您可以在 `app.listen()` 方法中指定其他端口，例如 `app.listen(3000)`。

### Q: 如何访问请求参数

**A:** 您可以通过 `context.request.data` 访问请求体数据，通过 `context.pathVariables` 访问路径参数，通过 `context.request.query` 访问查询参数。
