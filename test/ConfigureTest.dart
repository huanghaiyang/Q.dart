import 'package:Q/Q.dart';

void main() async {
  // 创建应用实例
  Application app = Application();
  
  // 设置命令行参数
  app.args([]);
  
  // 初始化应用（会自动初始化配置）
  await app.init();
  
  // 测试数据库配置
  print('=== 数据库配置 ===');
  var databaseConfigure = app.applicationContext.configuration.databaseConfigure;
  print('数据库类型: ${databaseConfigure.type}');
  print('数据库路径: ${databaseConfigure.connection.path}');
  print('数据库主机: ${databaseConfigure.connection.host}');
  print('数据库端口: ${databaseConfigure.connection.port}');
  print('连接池最大连接数: ${databaseConfigure.pool.maxConnections}');
  print('连接池最小连接数: ${databaseConfigure.pool.minConnections}');
  print('迁移是否启用: ${databaseConfigure.migration.enabled}');
  print('迁移表名: ${databaseConfigure.migration.table}');
  print('是否自动运行迁移: ${databaseConfigure.migration.autoRun}');
  
  // 测试缓存配置
  print('\n=== 缓存配置 ===');
  var cacheConfigure = app.applicationContext.configuration.cacheConfigure;
  print('缓存是否启用: ${cacheConfigure.enabled}');
  print('默认TTL: ${cacheConfigure.defaultTtl}');
  print('安全是否启用: ${cacheConfigure.security.enabled}');
  print('加密密钥: ${cacheConfigure.security.encryptionKey}');
  print('速率限制是否启用: ${cacheConfigure.rateLimit.enabled}');
  print('最大请求数: ${cacheConfigure.rateLimit.maxRequests}');
  print('时间窗口: ${cacheConfigure.rateLimit.window}');
  print('Redis是否启用: ${cacheConfigure.redis.enabled}');
  print('Redis主机: ${cacheConfigure.redis.host}');
  print('Redis端口: ${cacheConfigure.redis.port}');
  
  // 测试安全配置
  print('\n=== 安全配置 ===');
  var securityConfigure = app.applicationContext.configuration.securityConfigure;
  print('CSRF是否启用: ${securityConfigure.csrfConfigure.enabled}');
  print('CSRF保护方法: ${securityConfigure.csrfConfigure.protectedMethods}');
  print('CSRF令牌最大年龄: ${securityConfigure.csrfConfigure.tokenMaxAge}');
  print('CSRF令牌头部: ${securityConfigure.csrfConfigure.tokenHeader}');
  print('CSRF令牌Cookie: ${securityConfigure.csrfConfigure.tokenCookie}');
  print('XSS是否启用: ${securityConfigure.xssConfigure.enabled}');
  print('XSS是否阻止请求: ${securityConfigure.xssConfigure.blockRequest}');
  print('XSS保护的内容类型: ${securityConfigure.xssConfigure.protectedContentTypes}');
  print('认证是否启用: ${securityConfigure.authConfigure.enabled}');
  print('认证令牌头部: ${securityConfigure.authConfigure.tokenHeader}');
  print('认证令牌过期时间: ${securityConfigure.authConfigure.tokenExpiration}');
  
  // 测试HTTPS配置
  print('\n=== HTTPS配置 ===');
  var httpsConfigure = app.applicationContext.configuration.securityConfigure.httpsConfigure;
  print('HTTPS是否启用: ${httpsConfigure.enabled}');
  print('是否启用HTTP/2: ${httpsConfigure.enableHttp2}');
  print('是否启用TLS 1.3: ${httpsConfigure.enableTls13}');
  print('TLS版本: ${httpsConfigure.tlsVersions}');
  print('是否需要客户端证书: ${httpsConfigure.clientCertificateRequired}');
  
  print('\n配置测试完成！');
  
  // 销毁应用实例，释放资源
  try {
    if (app != null) {
      await app.close();
      app = null;
    }
  } catch (e) {
    // 忽略关闭时的错误，确保测试能够正常完成
    print('Error closing app: $e');
    app = null;
  }
}
