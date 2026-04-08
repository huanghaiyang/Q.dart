import 'dart:io';

import 'package:Q/src/Context.dart';
import 'package:Q/src/aware/InterceptorContext.dart';
import 'package:Q/src/interceptor/AbstractInterceptor.dart';
import 'package:Q/src/security/csrf/CsrfTokenGenerator.dart';

/// CSRF 保护拦截器
class CsrfInterceptor implements AbstractInterceptor {
  static const String CSRF_TOKEN_HEADER = 'X-CSRF-Token';
  static const String CSRF_TOKEN_COOKIE = 'csrf_token';
  
  final List<String> protectedMethods;
  final bool enabled;
  final int tokenMaxAge;
  final bool cookieSecure;

  CsrfInterceptor._({
    this.protectedMethods = const ['POST', 'PUT', 'DELETE', 'PATCH'],
    this.enabled = true,
    this.tokenMaxAge = 3600000,
    this.cookieSecure = true,
  });

  static CsrfInterceptor _instance;

  static CsrfInterceptor instance({
    List<String> protectedMethods = const ['POST', 'PUT', 'DELETE', 'PATCH'],
    bool enabled = true,
    int tokenMaxAge = 3600000,
    bool cookieSecure = true,
  }) {
    return _instance ?? (_instance = CsrfInterceptor._(
      protectedMethods: protectedMethods,
      enabled: enabled,
      tokenMaxAge: tokenMaxAge,
      cookieSecure: cookieSecure,
    ));
  }

  @override
  Future<bool> preHandle(HttpRequest req, HttpResponse res, InterceptorContext interceptorContext) async {
    if (!enabled) {
      return true;
    }

    // GET 请求不需要验证 CSRF Token
    if (!protectedMethods.contains(req.method.toUpperCase())) {
      return true;
    }

    // 从请求头中获取 CSRF Token
    String requestToken = req.headers.value(CSRF_TOKEN_HEADER);
    
    // 从 Cookie 中获取 CSRF Token
    String cookieToken;
    for (Cookie cookie in req.cookies) {
      if (cookie.name == CSRF_TOKEN_COOKIE) {
        cookieToken = cookie.value;
        break;
      }
    }

    // 验证 Token
    if (requestToken == null || cookieToken == null) {
      res.statusCode = HttpStatus.forbidden;
      res.write('CSRF Token missing');
      await res.close();
      return false;
    }

    // 验证并提取 Token（同时检查过期和格式）
    String pureCookieToken = CsrfTokenGenerator.validateAndExtractToken(cookieToken, maxAge: tokenMaxAge);
    if (pureCookieToken == null) {
      res.statusCode = HttpStatus.forbidden;
      res.write('CSRF Token invalid or expired');
      await res.close();
      return false;
    }

    // 验证 Token 是否匹配
    if (requestToken != pureCookieToken) {
      res.statusCode = HttpStatus.forbidden;
      res.write('CSRF Token mismatch');
      await res.close();
      return false;
    }

    return true;
  }

  @override
  void postHandle(HttpRequest req, HttpResponse res, InterceptorContext interceptorContext) {
    // 生成新的 CSRF Token
    if (enabled) {
      String newToken = CsrfTokenGenerator.generateWithTimestamp();
      Cookie cookie = Cookie(CSRF_TOKEN_COOKIE, newToken);
      cookie.httpOnly = true;
      cookie.secure = cookieSecure;
      res.cookies.add(cookie);
    }
  }
}
