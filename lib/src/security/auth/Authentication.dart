import 'dart:io';

/// 认证接口
/// 定义用户认证的基本方法
abstract class Authentication {
  /// 验证用户凭据
  /// 
  /// [username] 用户名
  /// [password] 密码
  /// 
  /// 返回认证结果，包含用户信息和 token
  Future<AuthenticationResult> authenticate(String username, String password);

  /// 验证 Token
  /// 
  /// [token] 认证 token
  /// 
  /// 返回是否有效
  Future<bool> validateToken(String token);

  /// 从请求中提取 Token
  /// 
  /// [req] HTTP 请求
  /// 
  /// 返回 token 字符串，如果没有则返回 null
  String extractToken(HttpRequest req);

  /// 刷新 Token
  /// 
  /// [token] 旧的 token
  /// 
  /// 返回新的 token
  Future<String> refreshToken(String token);

  /// 注销 Token
  /// 
  /// [token] 要注销的 token
  Future<void> revokeToken(String token);

  /// 从 token 中解析用户详情
  /// 
  /// [token] JWT token
  /// 
  /// 返回用户详情，如果 token 无效则返回 null
  Future<UserDetails> getUserDetailsFromToken(String token);
}

/// 认证结果
class AuthenticationResult {
  final bool success;
  final String token;
  final UserDetails userDetails;
  final String errorMessage;

  AuthenticationResult({
    this.success = false,
    this.token,
    this.userDetails,
    this.errorMessage,
  });

  factory AuthenticationResult.success({
    String token,
    UserDetails userDetails,
  }) {
    return AuthenticationResult(
      success: true,
      token: token,
      userDetails: userDetails,
    );
  }

  factory AuthenticationResult.failure(String errorMessage) {
    return AuthenticationResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// 用户详情
class UserDetails {
  final String username;
  final String userId;
  final List<String> roles;
  final Map<String, dynamic> attributes;

  UserDetails({
    this.username,
    this.userId,
    this.roles = const [],
    this.attributes = const {},
  });

  bool hasRole(String role) {
    return roles.contains(role);
  }

  bool hasAnyRole(List<String> roles) {
    return roles.any((role) => this.roles.contains(role));
  }
}
