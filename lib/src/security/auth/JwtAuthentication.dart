import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:Q/src/security/auth/Authentication.dart';
import 'package:Q/src/security/SecurityUtils.dart';
import 'package:crypto/crypto.dart';

/// JWT Token 认证实现
class JwtAuthentication implements Authentication {
  final String secretKey;
  final int tokenExpiration;
  final Map<String, UserCredentials> userStore;
  final String issuer;
  final String audience;
  final bool includeUserIdInToken;

  JwtAuthentication({
    this.secretKey,
    this.tokenExpiration = 3600,
    this.userStore = const {},
    this.issuer,
    this.audience,
    this.includeUserIdInToken = true,
  });

  @override
  Future<AuthenticationResult> authenticate(String username, String password) async {
    UserCredentials credentials = userStore[username];
    if (credentials == null) {
      return AuthenticationResult.failure('User not found');
    }

    if (!_verifyPassword(password, credentials.passwordHash)) {
      return AuthenticationResult.failure('Invalid password');
    }

    String token = _generateToken(username, credentials.roles, userId: credentials.userId);
    UserDetails userDetails = UserDetails(
      username: username,
      userId: credentials.userId,
      roles: credentials.roles,
      attributes: credentials.attributes,
    );

    return AuthenticationResult.success(
      token: token,
      userDetails: userDetails,
    );
  }

  @override
  Future<bool> validateToken(String token) async {
    try {
      Map<String, dynamic> payload = _decodeToken(token);
      if (payload == null) return false;

      // 验证过期时间
      int exp = payload['exp'];
      if (exp == null) return false;

      int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (now > exp) return false;

      // 验证签发时间（防止时间回溯攻击）
      int iat = payload['iat'];
      if (iat != null && iat > now + 60) {
        return false;
      }

      // 验证签发者（如果配置了）
      if (issuer != null) {
        String iss = payload['iss'];
        if (iss != issuer) return false;
      }

      // 验证受众（如果配置了）
      if (audience != null) {
        String aud = payload['aud'];
        if (aud != audience) return false;
      }

      // 验证签名
      String signature = _createSignature(token);
      String expectedSignature = token.split('.')[2];

      return signature == expectedSignature;
    } catch (e) {
      return false;
    }
  }

  @override
  String extractToken(HttpRequest req) {
    // 从 Authorization 头中提取 token
    String authHeader = req.headers.value('Authorization');
    if (authHeader != null && authHeader.startsWith('Bearer ')) {
      return authHeader.substring(7);
    }

    // 从查询参数中提取 token
    String token = req.uri.queryParameters['token'];
    if (token != null) return token;

    // 从 cookie 中提取 token
    for (Cookie cookie in req.cookies) {
      if (cookie.name == 'auth_token') {
        return cookie.value;
      }
    }

    return null;
  }

  @override
  Future<String> refreshToken(String token) async {
    bool isValid = await validateToken(token);
    if (!isValid) {
      throw Exception('Invalid token');
    }

    Map<String, dynamic> payload = _decodeToken(token);
    String username = payload['username'] ?? payload['sub'];
    String userId = payload['user_id']?.toString();
    List<String> roles = List<String>.from(payload['roles'] ?? []);

    return _generateToken(username, roles, userId: userId);
  }

  @override
  Future<void> revokeToken(String token) async {
    // 在实际应用中，这里应该将 token 加入黑名单
    // 简化实现，仅打印日志
    print('Token revoked: $token');
  }

  /// 从 token 中解析用户详情
  /// 
  /// [token] JWT token
  /// 
  /// 返回用户详情，如果 token 无效则返回 null
  Future<UserDetails> getUserDetailsFromToken(String token) async {
    try {
      // 先验证 token
      bool isValid = await validateToken(token);
      if (!isValid) {
        return null;
      }

      // 解析 token payload
      Map<String, dynamic> payload = _decodeToken(token);
      if (payload == null) {
        return null;
      }

      // 从 token payload 中提取用户信息
      String username = payload['username'] ?? payload['sub'];
      String userId = payload['user_id']?.toString();
      List<String> roles = List<String>.from(payload['roles'] ?? []);

      // 如果 token 中包含完整的用户信息，直接返回
      if (userId != null && username != null) {
        return UserDetails(
          username: username,
          userId: userId,
          roles: roles,
          attributes: {},
        );
      }

      // 否则从用户存储中获取完整的用户信息
      UserCredentials credentials = userStore[username];
      if (credentials == null) {
        return null;
      }

      return UserDetails(
        username: username,
        userId: credentials.userId,
        roles: roles,
        attributes: credentials.attributes,
      );
    } catch (e) {
      return null;
    }
  }

  String _generateToken(String username, List<String> roles, {String userId}) {
    Map<String, dynamic> header = {
      'alg': 'HS256',
      'typ': 'JWT',
    };

    int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Map<String, dynamic> payload = {
      'sub': username,
      'username': username,
      'roles': roles,
      'iat': now,
      'exp': now + tokenExpiration,
      'jti': _generateJti(),
    };

    // 添加可选的标准字段
    if (includeUserIdInToken && userId != null) {
      payload['user_id'] = userId;
    }

    if (issuer != null) {
      payload['iss'] = issuer;
    }

    if (audience != null) {
      payload['aud'] = audience;
    }

    String encodedHeader = _base64UrlEncode(jsonEncode(header));
    String encodedPayload = _base64UrlEncode(jsonEncode(payload));
    String signature = _createSignature('$encodedHeader.$encodedPayload');

    return '$encodedHeader.$encodedPayload.$signature';
  }

  /// 生成 JWT ID (JTI)
  String _generateJti() {
    return SecurityUtils.generateUuid();
  }

  Map<String, dynamic> _decodeToken(String token) {
    try {
      List<String> parts = token.split('.');
      if (parts.length != 3) return null;

      String payloadJson = _base64UrlDecode(parts[1]);
      return jsonDecode(payloadJson);
    } catch (e) {
      return null;
    }
  }

  String _createSignature(String data) {
    var hmac = Hmac(sha256, utf8.encode(secretKey));
    var digest = hmac.convert(utf8.encode(data));
    return _base64UrlEncode(digest.toString());
  }

  String _base64UrlEncode(String input) {
    return base64Url.encode(utf8.encode(input));
  }

  String _base64UrlDecode(String input) {
    return utf8.decode(base64Url.decode(input));
  }

  bool _verifyPassword(String password, String passwordHash) {
    // 简化实现，实际应该使用安全的密码哈希算法
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString() == passwordHash;
  }
}

/// 用户凭据
class UserCredentials {
  final String userId;
  final String passwordHash;
  final List<String> roles;
  final Map<String, dynamic> attributes;

  UserCredentials({
    this.userId,
    this.passwordHash,
    this.roles = const [],
    this.attributes = const {},
  });
}
