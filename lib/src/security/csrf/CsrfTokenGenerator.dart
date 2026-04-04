import 'dart:math';

/// CSRF Token 生成器
class CsrfTokenGenerator {
  static const String _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  static final Random _rnd = Random();

  /// 生成 CSRF Token
  /// 
  /// [length] token 长度，默认为 32
  static String generate({int length = 32}) {
    return String.fromCharCodes(Iterable.generate(
      length,
      (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length)),
    ));
  }

  /// 生成带时间戳的 CSRF Token
  static String generateWithTimestamp({int length = 32}) {
    String token = generate(length: length);
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$token:$timestamp';
  }

  /// 验证 Token 是否过期
  /// 
  /// [tokenWithTimestamp] 带时间戳的 token
  /// [maxAge] 最大有效期（毫秒），默认为 1 小时
  static bool isExpired(String tokenWithTimestamp, {int maxAge = 3600000}) {
    try {
      List<String> parts = tokenWithTimestamp.split(':');
      if (parts.length != 2) return true;
      
      int timestamp = int.parse(parts[1]);
      int now = DateTime.now().millisecondsSinceEpoch;
      return (now - timestamp) > maxAge;
    } catch (e) {
      return true;
    }
  }

  /// 验证并提取 Token
  /// 
  /// [tokenWithTimestamp] 带时间戳的 token
  /// [maxAge] 最大有效期（毫秒），默认为 1 小时
  /// 
  /// 返回提取的纯 token，如果 token 无效或已过期则返回 null
  static String validateAndExtractToken(String tokenWithTimestamp, {int maxAge = 3600000}) {
    try {
      List<String> parts = tokenWithTimestamp.split(':');
      if (parts.length != 2) return null;
      
      int timestamp = int.parse(parts[1]);
      int now = DateTime.now().millisecondsSinceEpoch;
      
      // 检查是否过期
      if ((now - timestamp) > maxAge) {
        return null;
      }
      
      // 返回纯 token
      return parts[0];
    } catch (e) {
      return null;
    }
  }

  /// 从带时间戳的 token 中提取纯 token
  static String extractToken(String tokenWithTimestamp) {
    try {
      return tokenWithTimestamp.split(':')[0];
    } catch (e) {
      return tokenWithTimestamp;
    }
  }
}
