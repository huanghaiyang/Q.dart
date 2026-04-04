import 'dart:async';
import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/aware/ApplicationHttpServerAware.dart';
import 'package:Q/src/configure/HttpsConfigure.dart';

/// HTTPS 服务器委托类
class ApplicationHttpsServerDelegate implements ApplicationHttpServerAware {
  final Application application;
  HttpServer _server;

  ApplicationHttpsServerDelegate(this.application);

  @override
  Future<void> listen(int port, {InternetAddress internetAddress}) async {
    HttpsConfigure httpsConfigure =
        Application.getApplicationContext().configuration.httpsConfigure;

    if (httpsConfigure == null || !httpsConfigure.enabled) {
      throw StateError('HTTPS is not enabled. Please configure HTTPS settings.');
    }

    if (!httpsConfigure.isValid()) {
      throw StateError('Invalid HTTPS configuration. Please check certificate and key paths.');
    }

    // 读取证书和私钥
    SecurityContext securityContext = SecurityContext();

    try {
      String certificate = await httpsConfigure.getCertificate();
      String privateKey = await httpsConfigure.getPrivateKey();

      if (certificate == null || privateKey == null) {
        throw StateError('Failed to load certificate or private key.');
      }

      securityContext.useCertificateChainBytes(utf8.encode(certificate));
      securityContext.usePrivateKeyBytes(utf8.encode(privateKey),
          password: httpsConfigure.certificatePassword);

      // 如果需要验证客户端证书
      if (httpsConfigure.clientCertificateRequired) {
        securityContext.setClientAuthorities(
          httpsConfigure.trustedCaCertificatePath,
        );
      }
    } catch (e) {
      throw StateError('Failed to initialize HTTPS: $e');
    }

    // 创建 HTTPS 服务器
    InternetAddress address = internetAddress ?? InternetAddress.anyIPv4;

    _server = await HttpServer.bindSecure(
      address,
      port,
      securityContext,
      shared: true,
    );

    print('Q.dart.server starting on HTTPS port $port.');

    // 处理请求
    await for (HttpRequest request in _server) {
      _handleRequest(request);
    }
  }

  void _handleRequest(HttpRequest request) async {
    try {
      // 添加 HSTS 头（HTTP Strict Transport Security）
      request.response.headers.set(
        'Strict-Transport-Security',
        'max-age=31536000; includeSubDomains',
      );

      // 创建上下文并处理请求
      // 这里应该调用框架的请求处理逻辑
      // 简化实现
      request.response.statusCode = HttpStatus.ok;
      request.response.write('HTTPS Server Running');
      await request.response.close();
    } catch (e) {
      print('Error handling HTTPS request: $e');
      request.response.statusCode = HttpStatus.internalServerError;
      await request.response.close();
    }
  }

  @override
  Future<void> close() async {
    if (_server != null) {
      await _server.close();
      _server = null;
    }
  }

  @override
  bool get isRunning => _server != null;
}
