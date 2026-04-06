# Q.dart Framework

Q.dart 是一个基于 Dart 语言的高性能、安全的 Web 框架，提供了完整的 MVC 架构和丰富的安全功能。

## 特性

- **高性能**：基于 Dart 语言的异步特性，提供高性能的 HTTP 服务器
- **MVC 架构**：完整的 Model-View-Controller 架构
- **路由系统**：支持 RESTful API 和灵活的路由配置
- **中间件**：可扩展的中间件系统
- **安全功能**：
  - CSRF 保护
  - XSS 防护
  - 认证授权（JWT）
  - HTTPS 支持
- **数据库支持**：
  - 内置数据库连接池
  - ORM（对象关系映射）支持
  - 数据库迁移工具
  - 支持 SQLite、MySQL、PostgreSQL 等数据库
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

请查看 [快速开始](quickstart.md) 章节，了解如何创建和运行第一个 Q.dart 应用。

## 示例项目

查看 `example` 目录中的示例项目，了解框架的使用方法。

## 贡献

欢迎贡献代码、报告问题或提出建议！

## 许可证

MIT License
