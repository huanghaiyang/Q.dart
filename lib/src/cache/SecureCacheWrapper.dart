import 'dart:async';
import 'package:synchronized/synchronized.dart';

import 'Cache.dart';
import 'CacheSecurityUtils.dart';
import 'RateLimiter.dart';
import 'TimeoutException.dart';

/// 安全缓存包装器
class SecureCacheWrapper<K, V> implements Cache<K, V> {
  final Cache<K, V> _delegate;
  final RateLimiter _rateLimiter;
  final String _encryptionKey;
  final Lock _lock = Lock();
  
  SecureCacheWrapper(this._delegate, {
    RateLimiter rateLimiter,
    String encryptionKey = 'default_encryption_key'
  }) : 
    _rateLimiter = rateLimiter ?? RateLimiter(),
    _encryptionKey = encryptionKey;
  
  @override
  Future<V> get(K key) async {
    // 检查速率限制
    final keyStr = key.toString();
    if (!await _rateLimiter.allow('get:$keyStr')) {
      throw Exception('Rate limit exceeded');
    }
    
    // 安全处理键
    final safeKey = _sanitizeKey(key);
    
    // 带超时的操作
    return _withTimeout(() async {
      final value = await _delegate.get(safeKey as K);
      // 如果是加密数据，解密
      if (value is String && value.startsWith('encrypted:')) {
        final encrypted = value.substring(10);
        final decrypted = CacheSecurityUtils.decrypt(encrypted, _encryptionKey);
        return decrypted as V;
      }
      return value;
    });
  }
  
  @override
  Future<void> set(K key, V value, {Duration ttl}) async {
    // 检查速率限制
    final keyStr = key.toString();
    if (!await _rateLimiter.allow('set:$keyStr')) {
      throw Exception('Rate limit exceeded');
    }
    
    // 安全处理键
    final safeKey = _sanitizeKey(key);
    
    // 检查并处理敏感数据
    V processedValue = value;
    if (CacheSecurityUtils.isSensitiveData(value)) {
      final encrypted = CacheSecurityUtils.encrypt(value.toString(), _encryptionKey);
      processedValue = ('encrypted:$encrypted') as V;
    }
    
    // 带超时的操作
    return _withTimeout(() async {
      await _delegate.set(safeKey as K, processedValue, ttl: ttl);
    });
  }
  
  @override
  Future<void> remove(K key) async {
    // 检查速率限制
    final keyStr = key.toString();
    if (!await _rateLimiter.allow('remove:$keyStr')) {
      throw Exception('Rate limit exceeded');
    }
    
    // 安全处理键
    final safeKey = _sanitizeKey(key);
    
    // 带超时的操作
    return _withTimeout(() async {
      await _delegate.remove(safeKey as K);
    });
  }
  
  @override
  Future<void> clear() async {
    // 检查速率限制
    if (!await _rateLimiter.allow('clear')) {
      throw Exception('Rate limit exceeded');
    }
    
    // 带超时的操作
    return _withTimeout(() async {
      await _delegate.clear();
    });
  }
  
  @override
  Future<bool> contains(K key) async {
    // 检查速率限制
    final keyStr = key.toString();
    if (!await _rateLimiter.allow('contains:$keyStr')) {
      throw Exception('Rate limit exceeded');
    }
    
    // 安全处理键
    final safeKey = _sanitizeKey(key);
    
    // 带超时的操作
    return _withTimeout(() async {
      return await _delegate.contains(safeKey as K);
    });
  }
  
  @override
  Future<int> size() async {
    // 检查速率限制
    if (!await _rateLimiter.allow('size')) {
      throw Exception('Rate limit exceeded');
    }
    
    // 带超时的操作
    return _withTimeout(() async {
      return await _delegate.size();
    });
  }
  
  /// 安全处理键
  dynamic _sanitizeKey(K key) {
    if (key is String) {
      return CacheSecurityUtils.sanitizeKey(key);
    }
    return key;
  }
  
  /// 带超时的操作
  Future<T> _withTimeout<T>(Future<T> Function() action, {Duration timeout = const Duration(seconds: 5)}) async {
    return Future.any([
      action(),
      Future.delayed(timeout, () => throw TimeoutException('Cache operation timed out'))
    ]);
  }
}
