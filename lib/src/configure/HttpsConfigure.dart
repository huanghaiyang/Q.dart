import 'dart:io';

/// HTTPS 配置类
class HttpsConfigure {
  /// 是否启用 HTTPS
  final bool enabled;

  /// 证书文件路径
  final String certificatePath;

  /// 私钥文件路径
  final String privateKeyPath;

  /// 证书密码（如果有）
  final String certificatePassword;

  /// 是否启用 HTTP/2
  final bool enableHttp2;

  /// 是否启用 TLS 1.3
  final bool enableTls13;

  /// 允许的 TLS 版本
  final List<String> tlsVersions;

  /// 允许的加密套件
  final List<String> cipherSuites;

  /// 是否验证客户端证书
  final bool clientCertificateRequired;

  /// 受信任的 CA 证书路径（用于客户端证书验证）
  final String trustedCaCertificatePath;

  HttpsConfigure({
    this.enabled = false,
    this.certificatePath,
    this.privateKeyPath,
    this.certificatePassword,
    this.enableHttp2 = true,
    this.enableTls13 = true,
    this.tlsVersions = const ['TLSv1.2', 'TLSv1.3'],
    this.cipherSuites,
    this.clientCertificateRequired = false,
    this.trustedCaCertificatePath,
  });

  /// 从配置映射创建 HTTPS 配置
  factory HttpsConfigure.fromMap(Map<String, dynamic> map) {
    return HttpsConfigure(
      enabled: map['enabled'] ?? false,
      certificatePath: map['certificatePath'],
      privateKeyPath: map['privateKeyPath'],
      certificatePassword: map['certificatePassword'],
      enableHttp2: map['enableHttp2'] ?? true,
      enableTls13: map['enableTls13'] ?? true,
      tlsVersions: map['tlsVersions'] != null
          ? List<String>.from(map['tlsVersions'])
          : const ['TLSv1.2', 'TLSv1.3'],
      cipherSuites: map['cipherSuites'] != null
          ? List<String>.from(map['cipherSuites'])
          : null,
      clientCertificateRequired: map['clientCertificateRequired'] ?? false,
      trustedCaCertificatePath: map['trustedCaCertificatePath'],
    );
  }

  /// 验证配置是否有效
  bool isValid() {
    if (!enabled) return true;

    if (certificatePath == null || certificatePath.isEmpty) {
      return false;
    }

    if (privateKeyPath == null || privateKeyPath.isEmpty) {
      return false;
    }

    // 检查证书文件是否存在
    File certFile = File(certificatePath);
    if (!certFile.existsSync()) {
      return false;
    }

    // 检查私钥文件是否存在
    File keyFile = File(privateKeyPath);
    if (!keyFile.existsSync()) {
      return false;
    }

    return true;
  }

  /// 获取证书文件内容
  Future<String> getCertificate() async {
    if (certificatePath == null) return null;
    File file = File(certificatePath);
    if (!await file.exists()) return null;
    return await file.readAsString();
  }

  /// 获取私钥文件内容
  Future<String> getPrivateKey() async {
    if (privateKeyPath == null) return null;
    File file = File(privateKeyPath);
    if (!await file.exists()) return null;
    return await file.readAsString();
  }
}
