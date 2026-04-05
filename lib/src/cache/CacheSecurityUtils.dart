import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// 缓存安全工具类
class CacheSecurityUtils {
  /// 对缓存键进行安全处理
  static String sanitizeKey(String key) {
    // 移除特殊字符
    final sanitized = key.replaceAll(RegExp(r'[<>"/\\]'), '_');
    // 限制长度
    return sanitized.substring(0, sanitized.length > 100 ? 100 : sanitized.length);
  }
  
  /// 生成安全的缓存键
  static String generateSafeKey(String prefix, String input) {
    final sanitized = sanitizeKey(input);
    final hash = md5.convert(utf8.encode(sanitized)).toString();
    return '$prefix:$hash';
  }
  
  /// 检查数据是否敏感
  static bool isSensitiveData(dynamic data) {
    if (data is String) {
      // 检查常见敏感数据模式
      final patterns = [
        RegExp(r'^[0-9]{16,19}$'), // 信用卡号
        RegExp(r'^[0-9]{3,4}$'), // CVV
        RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$'), // 邮箱
        RegExp(r'^\d{4}-\d{2}-\d{2}$'), // 日期
        RegExp(r'^[0-9]{9,12}$'), // 手机号
      ];
      return patterns.any((pattern) => pattern.hasMatch(data));
    }
    return false;
  }
  
  /// 生成随机盐值
  static String generateSalt() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(16, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
  }
  
  /// 简单的加密（用于演示，生产环境应使用更安全的加密方法）
  static String encrypt(String data, String key) {
    final salt = generateSalt();
    final combined = '$salt:$data';
    final hash = md5.convert(utf8.encode(combined + key)).toString();
    return base64Encode(utf8.encode('$salt:$hash:$data'));
  }
  
  /// 简单的解密
  static String decrypt(String encrypted, String key) {
    try {
      final decoded = utf8.decode(base64Decode(encrypted));
      final parts = decoded.split(':');
      if (parts.length < 3) return null;
      final salt = parts[0];
      final hash = parts[1];
      final data = parts.sublist(2).join(':');
      
      // 验证哈希
      final expectedHash = md5.convert(utf8.encode('$salt:$data' + key)).toString();
      if (hash != expectedHash) return null;
      
      return data;
    } catch (e) {
      return null;
    }
  }
}
