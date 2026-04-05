import 'dart:async';
import 'package:synchronized/synchronized.dart';

/// 速率限制器
class RateLimiter {
  final Map<String, List<DateTime>> _requests = {};
  final Lock _lock = Lock();
  final int maxRequests;
  final Duration window;
  
  RateLimiter({this.maxRequests = 100, this.window = const Duration(minutes: 1)});
  
  /// 检查是否允许请求
  Future<bool> allow(String key) async {
    return _lock.synchronized(() {
      final now = DateTime.now();
      final requests = _requests[key] ?? [];
      
      // 清理过期请求
      requests.removeWhere((time) => now.difference(time) > window);
      
      if (requests.length < maxRequests) {
        requests.add(now);
        _requests[key] = requests;
        return true;
      }
      
      return false;
    });
  }
  
  /// 重置指定键的速率限制
  Future<void> reset(String key) async {
    return _lock.synchronized(() {
      _requests.remove(key);
    });
  }
  
  /// 清空所有速率限制
  Future<void> clear() async {
    return _lock.synchronized(() {
      _requests.clear();
    });
  }
  
  /// 获取当前请求数
  Future<int> getRequestCount(String key) async {
    return _lock.synchronized(() {
      final now = DateTime.now();
      final requests = _requests[key] ?? [];
      
      // 清理过期请求
      requests.removeWhere((time) => now.difference(time) > window);
      _requests[key] = requests;
      
      return requests.length;
    });
  }
}
