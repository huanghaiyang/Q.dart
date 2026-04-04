import 'package:Q/src/configure/HttpsConfigure.dart';
import 'package:Q/src/security/auth/Authentication.dart';
import 'package:Q/src/security/auth/Authorization.dart';

/// 安全配置类
/// 整合所有安全相关的配置
class SecurityConfigure {
  /// CSRF 保护配置
  final CsrfConfigure csrfConfigure;

  /// XSS 防护配置
  final XssConfigure xssConfigure;

  /// 认证授权配置
  final AuthConfigure authConfigure;

  /// HTTPS 配置
  final HttpsConfigure httpsConfigure;

  /// 安全响应头配置
  final SecurityHeadersConfigure securityHeadersConfigure;

  SecurityConfigure({
    this.csrfConfigure,
    this.xssConfigure,
    this.authConfigure,
    this.httpsConfigure,
    this.securityHeadersConfigure,
  });

  /// 从配置映射创建安全配置
  factory SecurityConfigure.fromMap(Map<String, dynamic> map) {
    return SecurityConfigure(
      csrfConfigure: map['csrf'] != null
          ? CsrfConfigure.fromMap(map['csrf'])
          : CsrfConfigure(),
      xssConfigure: map['xss'] != null
          ? XssConfigure.fromMap(map['xss'])
          : XssConfigure(),
      authConfigure: map['auth'] != null
          ? AuthConfigure.fromMap(map['auth'])
          : AuthConfigure(),
      httpsConfigure: map['https'] != null
          ? HttpsConfigure.fromMap(map['https'])
          : HttpsConfigure(),
      securityHeadersConfigure: map['securityHeaders'] != null
          ? SecurityHeadersConfigure.fromMap(map['securityHeaders'])
          : SecurityHeadersConfigure(),
    );
  }
}

/// CSRF 保护配置
class CsrfConfigure {
  final bool enabled;
  final List<String> protectedMethods;
  final int tokenMaxAge;
  final String tokenHeader;
  final String tokenCookie;

  CsrfConfigure({
    this.enabled = true,
    this.protectedMethods = const ['POST', 'PUT', 'DELETE', 'PATCH'],
    this.tokenMaxAge = 3600000,
    this.tokenHeader = 'X-CSRF-Token',
    this.tokenCookie = 'csrf_token',
  });

  factory CsrfConfigure.fromMap(Map<String, dynamic> map) {
    return CsrfConfigure(
      enabled: map['enabled'] ?? true,
      protectedMethods: map['protectedMethods'] != null
          ? List<String>.from(map['protectedMethods'])
          : const ['POST', 'PUT', 'DELETE', 'PATCH'],
      tokenMaxAge: map['tokenMaxAge'] ?? 3600000,
      tokenHeader: map['tokenHeader'] ?? 'X-CSRF-Token',
      tokenCookie: map['tokenCookie'] ?? 'csrf_token',
    );
  }
}

/// XSS 防护配置
class XssConfigure {
  final bool enabled;
  final bool blockRequest;
  final List<String> protectedContentTypes;

  XssConfigure({
    this.enabled = true,
    this.blockRequest = true,
    this.protectedContentTypes = const [
      'application/x-www-form-urlencoded',
      'application/json',
      'multipart/form-data',
    ],
  });

  factory XssConfigure.fromMap(Map<String, dynamic> map) {
    return XssConfigure(
      enabled: map['enabled'] ?? true,
      blockRequest: map['blockRequest'] ?? true,
      protectedContentTypes: map['protectedContentTypes'] != null
          ? List<String>.from(map['protectedContentTypes'])
          : const [
              'application/x-www-form-urlencoded',
              'application/json',
              'multipart/form-data',
            ],
    );
  }
}

/// 认证授权配置
class AuthConfigure {
  final bool enabled;
  final List<String> publicPaths;
  final Map<String, List<String>> pathRoles;
  final String tokenHeader;
  final int tokenExpiration;

  AuthConfigure({
    this.enabled = true,
    this.publicPaths = const [],
    this.pathRoles = const {},
    this.tokenHeader = 'Authorization',
    this.tokenExpiration = 3600,
  });

  factory AuthConfigure.fromMap(Map<String, dynamic> map) {
    return AuthConfigure(
      enabled: map['enabled'] ?? true,
      publicPaths: map['publicPaths'] != null
          ? List<String>.from(map['publicPaths'])
          : const [],
      pathRoles: map['pathRoles'] != null
          ? Map<String, List<String>>.from(
              map['pathRoles'].map((k, v) => MapEntry(k, List<String>.from(v))),
            )
          : const {},
      tokenHeader: map['tokenHeader'] ?? 'Authorization',
      tokenExpiration: map['tokenExpiration'] ?? 3600,
    );
  }
}

/// 安全响应头配置
class SecurityHeadersConfigure {
  final bool enabled;
  final bool xssProtection;
  final bool contentTypeOptions;
  final bool frameOptions;
  final bool contentSecurityPolicy;
  final String contentSecurityPolicyValue;

  SecurityHeadersConfigure({
    this.enabled = true,
    this.xssProtection = true,
    this.contentTypeOptions = true,
    this.frameOptions = true,
    this.contentSecurityPolicy = true,
    this.contentSecurityPolicyValue = "default-src 'self'",
  });

  factory SecurityHeadersConfigure.fromMap(Map<String, dynamic> map) {
    return SecurityHeadersConfigure(
      enabled: map['enabled'] ?? true,
      xssProtection: map['xssProtection'] ?? true,
      contentTypeOptions: map['contentTypeOptions'] ?? true,
      frameOptions: map['frameOptions'] ?? true,
      contentSecurityPolicy: map['contentSecurityPolicy'] ?? true,
      contentSecurityPolicyValue:
          map['contentSecurityPolicyValue'] ?? "default-src 'self'",
    );
  }
}
