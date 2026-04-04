import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// 安全工具类
/// 提供密码哈希、加密、随机数生成等安全功能
class SecurityUtils {
  static final Random _random = Random.secure();

  /// 生成安全的随机字符串
  /// 
  /// [length] 字符串长度
  static String generateSecureRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(_random.nextInt(chars.length)),
      ),
    );
  }

  /// 生成随机字节
  /// 
  /// [length] 字节长度
  static List<int> generateSecureRandomBytes(int length) {
    return List<int>.generate(length, (_) => _random.nextInt(256));
  }

  /// 使用 PBKDF2 算法哈希密码
  /// 
  /// [password] 密码
  /// [salt] 盐值（如果不提供则自动生成）
  /// [iterations] 迭代次数（默认为 10000）
  static String hashPassword(String password, {String salt, int iterations = 10000}) {
    if (salt == null) {
      salt = generateSecureRandomString(16);
    }

    var bytes = utf8.encode(password + salt);
    var digest = sha256.convert(bytes);

    // 多次迭代
    for (int i = 1; i < iterations; i++) {
      digest = sha256.convert(utf8.encode(digest.toString() + salt));
    }

    // 返回 salt:hash 格式
    return '$salt:${digest.toString()}';
  }

  /// 验证密码
  /// 
  /// [password] 待验证的密码
  /// [hashedPassword] 已哈希的密码（salt:hash 格式）
  /// [iterations] 迭代次数（默认为 10000）
  static bool verifyPassword(String password, String hashedPassword, {int iterations = 10000}) {
    try {
      List<String> parts = hashedPassword.split(':');
      if (parts.length != 2) return false;

      String salt = parts[0];
      String expectedHash = parts[1];

      String actualHash = hashPassword(password, salt: salt, iterations: iterations);
      String actualHashValue = actualHash.split(':')[1];

      return expectedHash == actualHashValue;
    } catch (e) {
      return false;
    }
  }

  /// 计算 HMAC
  /// 
  /// [data] 数据
  /// [key] 密钥
  static String hmac(String data, String key) {
    var hmac = Hmac(sha256, utf8.encode(key));
    var digest = hmac.convert(utf8.encode(data));
    return digest.toString();
  }

  /// 生成 UUID
  static String generateUuid() {
    return '${_randomHex(8)}-${_randomHex(4)}-4${_randomHex(3)}-${_randomHex(4)}-${_randomHex(12)}';
  }

  static String _randomHex(int length) {
    const chars = '0123456789abcdef';
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(_random.nextInt(chars.length)),
      ),
    );
  }

  /// 安全地比较两个字符串（防止时序攻击）
  static bool secureCompare(String a, String b) {
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }

    return result == 0;
  }

  /// 转义正则表达式特殊字符
  static String escapeRegExp(String input) {
    return input.replaceAllMapped(
      RegExp(r'[.*+?^${}()|[\]\\]'),
      (match) => '\\${match.group(0)}',
    );
  }

  /// 检查密码强度
  /// 
  /// 返回密码强度等级：0-弱, 1-中等, 2-强, 3-非常强
  static int checkPasswordStrength(String password) {
    if (password == null || password.isEmpty) return 0;

    int score = 0;

    // 长度检查
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // 复杂度检查
    if (RegExp(r'[a-z]').hasMatch(password) && RegExp(r'[A-Z]').hasMatch(password)) {
      score++;
    }

    if (RegExp(r'[0-9]').hasMatch(password)) {
      score++;
    }

    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      score++;
    }

    // 归一化到 0-3
    if (score <= 2) return 0;
    if (score <= 3) return 1;
    if (score <= 4) return 2;
    return 3;
  }
}
