# Q.dart Framework

Q.dart 是一个基于 Dart 语言的高性能、安全的 Web 框架，提供了完整的 MVC 架构和丰富的安全功能。

## 特性

- **高性能**：基于 Dart 语言的异步特性，提供高性能的 HTTP 服务器
- **MVC 架构**：完整的 Model-View-Controller 架构
- **路由系统**：支持 RESTful API 和灵活的路由配置
- **中间件**：可扩展的中间件系统
- **安全功能**：CSRF 保护、XSS 防护、认证授权（JWT）、HTTPS 支持
- **数据库支持**：内置数据库连接池、ORM 支持、数据库迁移工具
- **配置管理**：YAML 配置文件和环境变量支持
- **国际化**：内置国际化支持
- **缓存系统**：支持内存缓存和分布式缓存

## 安装

### 1. 安装 Dart SDK

请先安装 Dart SDK 2.5.0 或更高版本。

### 2. 添加依赖

在 `pubspec.yaml` 文件中添加：

```yaml
dependencies:
  Q:
    path: /path/to/Q.dart
  # 其他依赖...
```

## 快速开始

### 1. 创建应用

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
  
  // 启动服务器
  app.listen(8080);
  print('Server started on port 8080');
}
```

### 2. 运行应用

```bash
dart main.dart
```

## 文档

详细的技术文档和使用指南已迁移到 [GitHub Pages](https://yourusername.github.io/Q.dart)。

### 文档内容

- **快速开始**：框架的基本使用方法
- **路由系统**：路由配置、参数处理、路由组等
- **中间件**：自定义中间件的创建和使用
- **安全功能**：CSRF 保护、XSS 防护、认证授权等
- **数据库集成**：连接池、ORM、数据库迁移等
- **配置管理**：配置文件和环境变量的使用
- **国际化**：多语言支持的配置和使用
- **缓存系统**：内存缓存和分布式缓存的使用
- **部署指南**：应用的构建和部署方法
- **API 参考**：框架的 API 文档

### 本地文档

您也可以在本地构建文档：

```bash
# 安装文档构建工具
npm install -g docsify-cli

# 进入文档目录
cd docs

# 启动本地文档服务器
docsify serve
```

然后访问 `http://localhost:3000` 查看文档。

## 示例项目

查看 `example` 目录中的示例项目，了解框架的使用方法。

## 贡献

欢迎贡献代码、报告问题或提出建议！

## 许可证

MIT License
