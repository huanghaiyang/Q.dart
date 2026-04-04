import 'dart:io';

import 'package:Q/src/aware/InterceptorContext.dart';
import 'package:Q/src/interceptor/AbstractInterceptor.dart';
import 'package:Q/src/security/xss/XssFilter.dart';

/// XSS 防护拦截器
class XssInterceptor implements AbstractInterceptor {
  final bool enabled;
  final bool blockRequest;
  final List<String> protectedContentTypes;

  XssInterceptor._({
    this.enabled = true,
    this.blockRequest = true,
    this.protectedContentTypes = const [
      'application/x-www-form-urlencoded',
      'application/json',
      'multipart/form-data',
    ],
  });

  static XssInterceptor _instance;

  static XssInterceptor instance({
    bool enabled = true,
    bool blockRequest = true,
    List<String> protectedContentTypes = const [
      'application/x-www-form-urlencoded',
      'application/json',
      'multipart/form-data',
    ],
  }) {
    return _instance ?? (_instance = XssInterceptor._(
      enabled: enabled,
      blockRequest: blockRequest,
      protectedContentTypes: protectedContentTypes,
    ));
  }

  @override
  Future<bool> preHandle(HttpRequest req, HttpResponse res, InterceptorContext interceptorContext) async {
    if (!enabled) {
      return true;
    }

    // 检查内容类型是否需要保护
    ContentType contentType = req.headers.contentType;
    if (contentType != null && !protectedContentTypes.contains(contentType.mimeType)) {
      return true;
    }

    // 检查 URL 参数
    Map<String, String> queryParams = req.uri.queryParameters;
    for (String key in queryParams.keys) {
      String value = queryParams[key];
      if (value != null && XssFilter.containsXss(value)) {
        if (blockRequest) {
          res.statusCode = HttpStatus.badRequest;
          res.write('XSS attack detected in query parameter: $key');
          await res.close();
          return false;
        }
      }
    }

    // 检查请求头
    req.headers.forEach((String headerName, List<String> headerValues) {
      if (headerValues != null) {
        for (String value in headerValues) {
          if (value != null && XssFilter.containsXss(value)) {
            if (blockRequest) {
              res.statusCode = HttpStatus.badRequest;
              res.write('XSS attack detected in header: $headerName');
              res.close();
              return;
            }
          }
        }
      }
    });

    return true;
  }

  @override
  void postHandle(HttpRequest req, HttpResponse res, InterceptorContext interceptorContext) {
    // 添加安全响应头
    if (enabled) {
      res.headers.set('X-XSS-Protection', '1; mode=block');
      res.headers.set('X-Content-Type-Options', 'nosniff');
      res.headers.set('X-Frame-Options', 'DENY');
      res.headers.set('Content-Security-Policy', "default-src 'self'");
    }
  }
}
