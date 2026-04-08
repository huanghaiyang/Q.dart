import 'dart:math';
import 'dart:convert';
import 'package:uuid/uuid.dart';

/// CSRF 令牌生成器
class CsrfTokenGenerator {
  static const String _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  static final Random _rnd = Random();
  
  /// 生成 CSRF 令牌
  static String generate({int length = 32}) {
    return String.fromCharCodes(Iterable.generate(
      length,
      (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length)),
    ));
  }
  
  /// 生成带过期时间的令牌
  static String generateWithExpiry({int length = 32, int expirySeconds = 3600}) {
    final token = generate(length: length);
    final expiry = DateTime.now().add(Duration(seconds: expirySeconds)).millisecondsSinceEpoch;
    final payload = {'token': token, 'expiry': expiry};
    return base64UrlEncode(utf8.encode(jsonEncode(payload)));
  }
  
  /// 生成带时间戳的令牌
  static String generateWithTimestamp({int length = 32}) {
    return generateWithExpiry(length: length);
  }
  
  /// 提取令牌
  static String extractToken(String token) {
    try {
      final decoded = utf8.decode(base64Url.decode(token));
      final payload = jsonDecode(decoded);
      return payload['token'];
    } catch (e) {
      return token;
    }
  }
  
  /// 检查令牌是否过期
  static bool isExpired(String token, {int maxAge = 3600}) {
    try {
      final decoded = utf8.decode(base64Url.decode(token));
      final payload = jsonDecode(decoded);
      final expiry = payload['expiry'];
      // 检查 expiry 是否为数字
      if (expiry is num) {
        return expiry < DateTime.now().millisecondsSinceEpoch;
      }
      return true;
    } catch (e) {
      return true;
    }
  }
  
  /// 验证令牌
  static bool validateToken(String token, String expectedToken) {
    final extractedToken = extractToken(token);
    return extractedToken == expectedToken;
  }
  
  /// 验证并提取令牌
  static String validateAndExtractToken(String token, {int maxAge = 3600}) {
    if (isExpired(token, maxAge: maxAge)) {
      throw Exception('Token expired');
    }
    return extractToken(token);
  }
}
