# Q.dart 示例应用

本目录包含 Q.dart 框架的示例应用。

## 可用示例

### 1. 基本示例 (Q_example.dart)

展示框架核心功能的基本示例：
- 路由
- 请求参数
- 文件上传
- 重定向
- 会话管理
- 超时处理

### 2. 安全示例 (security_example.dart)

展示安全功能的示例：
- JWT 认证
- 基于角色的授权
- CSRF 保护
- XSS 防护
- 文件上传

### 3. 综合示例 (comprehensive_example.dart)

展示框架所有主要功能的综合示例：
- 基本路由
- 请求参数（路径、查询、表单）
- JSON 处理
- 文件上传
- 认证和授权
- 安全功能（CSRF、XSS）
- 错误处理
- 中间件
- 重定向

## 运行示例

### 1. 安装依赖

首先，确保安装了所有依赖：

```bash
cd /Users/huang/work/Q.dart
PUB_HOSTED_URL=https://pub.dartlang.org pub get
```

### 2. 运行基本示例

```bash
cd /Users/huang/work/Q.dart
dart example/Q_example.dart
```

服务器将在端口 8081 上启动。

### 3. 运行安全示例

```bash
cd /Users/huang/work/Q.dart
dart example/security_example.dart
```

服务器将在端口 8081 上启动。

### 4. 运行综合示例

```bash
cd /Users/huang/work/Q.dart
dart example/comprehensive_example.dart
```

服务器将在端口 8081 上启动。

## 测试示例

### 基本示例

可用端点：
- `GET /user` - 获取用户信息
- `POST /multipart-form-data` - 文件上传测试
- `POST /cookie` - Cookie 测试
- `POST /header` - 头信息测试
- `POST /setSession` - 设置会话
- `POST /getSession` - 获取会话
- `POST /application_json` - JSON 测试
- `GET /path_params` - 查询参数
- `POST /x-www-form-urlencoded` - 表单数据测试
- `GET /router-timeout` - 超时测试

### 安全示例

可用端点：
- `GET /health` - 健康检查
- `GET /public` - 公开端点
- `POST /login` - 用户登录
- `GET /csrf-token` - 获取 CSRF token
- `GET /api/users` - 受保护的 API
- `GET /admin` - 管理员专用
- `POST /xss-test` - XSS 防护测试
- `POST /upload` - 文件上传测试

### 综合示例

可用端点：
- **公开：**
  - `GET /health` - 健康检查
  - `GET /public` - 公开端点
  - `POST /login` - 用户登录
  - `POST /refresh-token` - 刷新 token
  - `GET /csrf-token` - 获取 CSRF token
  - `GET /hello` - 基本 hello 端点
  - `GET /user/:id` - 路由参数
  - `GET /search` - 查询参数
  - `POST /form` - 表单数据
  - `POST /json` - JSON 数据
  - `GET /redirect` - 重定向示例

- **受保护：**
  - `GET /api/users` - 获取所有用户
  - `POST /api/users` - 创建用户（仅管理员）
  - `GET /admin` - 管理员专用
  - `POST /xss-test` - XSS 防护测试
  - `POST /upload` - 文件上传测试

## 认证

对于安全示例，使用以下凭证：

- **管理员：**
  - 用户名：`admin`
  - 密码：任意（为了测试简化了密码验证）
  - 角色：`ADMIN`

- **用户：**
  - 用户名：`user`
  - 密码：任意
  - 角色：`USER`

## HTTPS 配置

要启用 HTTPS，请更新 `configure.yml` 文件：

```yaml
https:
  enabled: true
  certificatePath: /path/to/cert.pem
  privateKeyPath: /path/to/key.pem
  enableHttp2: true
  enableTls13: true
```

## 环境配置

您可以使用 `APP_ENV` 环境变量指定环境：

```bash
APP_ENV=dev dart example/comprehensive_example.dart
```

这将使用 `resources/application-dev.yml` 中的配置。

## 故障排查

### 端口已被占用

如果端口 8081 已被占用，您可以在示例文件中更改端口：

```dart
await app.listen(8082); // 更改为不同的端口
```

### 依赖未找到

确保您已在项目根目录中运行 `pub get`。

### 安全功能不工作

确保安全拦截器在应用中正确初始化。

## 许可证

MIT 许可证
