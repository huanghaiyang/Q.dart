import 'dart:io';

import 'package:Q/src/aware/InterceptorContext.dart';
import 'package:Q/src/interceptor/AbstractInterceptor.dart';
import 'package:Q/src/security/auth/Authentication.dart';
import 'package:Q/src/security/auth/Authorization.dart';

/// 认证授权拦截器
class AuthInterceptor implements AbstractInterceptor {
  final Authentication authentication;
  final Authorization authorization;
  final List<String> publicPaths;
  final Map<String, List<String>> pathRoles;
  final String tokenHeader;

  AuthInterceptor._({
    this.authentication,
    this.authorization,
    this.publicPaths = const [],
    this.pathRoles = const {},
    this.tokenHeader = 'Authorization',
  });

  static AuthInterceptor _instance;

  static AuthInterceptor instance({
    Authentication authentication,
    Authorization authorization,
    List<String> publicPaths = const [],
    Map<String, List<String>> pathRoles = const {},
    String tokenHeader = 'Authorization',
  }) {
    return _instance ?? (_instance = AuthInterceptor._(
      authentication: authentication,
      authorization: authorization,
      publicPaths: publicPaths,
      pathRoles: pathRoles,
      tokenHeader: tokenHeader,
    ));
  }

  @override
  Future<bool> preHandle(HttpRequest req, HttpResponse res, InterceptorContext interceptorContext) async {
    String path = req.uri.path;

    // 检查是否是公开路径
    if (_isPublicPath(path)) {
      return true;
    }

    // 如果没有配置认证，允许访问
    if (authentication == null) {
      return true;
    }

    // 提取 token
    String token = authentication.extractToken(req);
    if (token == null) {
      token = req.headers.value(tokenHeader);
    }

    if (token == null) {
      res.statusCode = HttpStatus.unauthorized;
      res.write('Authentication required');
      await res.close();
      return false;
    }

    // 验证 token
    bool isValid = await authentication.validateToken(token);
    if (!isValid) {
      res.statusCode = HttpStatus.unauthorized;
      res.write('Invalid or expired token');
      await res.close();
      return false;
    }

    // 检查角色权限
    if (authorization != null && pathRoles.containsKey(path)) {
      // 从 token 中获取用户详情
      UserDetails userDetails = await authentication.getUserDetailsFromToken(token);
      if (userDetails == null) {
        res.statusCode = HttpStatus.forbidden;
        res.write('Unable to verify user permissions');
        await res.close();
        return false;
      }

      // 获取所需的角色
      List<String> requiredRoles = pathRoles[path];
      if (requiredRoles == null || requiredRoles.isEmpty) {
        return true;
      }

      // 检查用户是否拥有任意一个所需角色
      bool hasPermission = await authorization.hasAnyRole(userDetails, requiredRoles);
      if (!hasPermission) {
        res.statusCode = HttpStatus.forbidden;
        res.write('Access denied: insufficient permissions');
        await res.close();
        return false;
      }
    }

    return true;
  }

  @override
  void postHandle(HttpRequest req, HttpResponse res, InterceptorContext interceptorContext) {
    // 添加安全响应头
    res.headers.set('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate');
    res.headers.set('Pragma', 'no-cache');
    res.headers.set('Expires', '0');
  }

  bool _isPublicPath(String path) {
    for (String publicPath in publicPaths) {
      if (publicPath.endsWith('*')) {
        String prefix = publicPath.substring(0, publicPath.length - 1);
        if (path.startsWith(prefix)) {
          return true;
        }
      } else if (path == publicPath) {
        return true;
      }
    }
    return false;
  }
}
