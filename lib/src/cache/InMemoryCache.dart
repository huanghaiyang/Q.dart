import 'dart:async';
import 'dart:collection';
import 'package:synchronized/synchronized.dart';

import 'Cache.dart';

/// 缓存条目
class _CacheEntry<V> {
  final V value;
  final DateTime createdAt;
  final Duration ttl;
  
  _CacheEntry(this.value, this.ttl) : createdAt = DateTime.now();
  
  bool get isExpired => ttl != null && DateTime.now().difference(createdAt) > ttl;
}

/// 内存缓存实现
class InMemoryCache<K, V> implements Cache<K, V> {
  final Map<K, _CacheEntry<V>> _cache = {};
  final Lock _lock = Lock();
  final Duration defaultTtl;
  
  InMemoryCache({this.defaultTtl});
  
  @override
  Future<V> get(K key) async {
    return _lock.synchronized(() async {
      final entry = _cache[key];
      if (entry == null || entry.isExpired) {
        _cache.remove(key);
        return null;
      }
      return entry.value;
    });
  }
  
  @override
  Future<void> set(K key, V value, {Duration ttl}) async {
    return _lock.synchronized(() async {
      _cache[key] = _CacheEntry(value, ttl ?? defaultTtl);
    });
  }
  
  @override
  Future<void> remove(K key) async {
    return _lock.synchronized(() async {
      _cache.remove(key);
    });
  }
  
  @override
  Future<void> clear() async {
    return _lock.synchronized(() async {
      _cache.clear();
    });
  }
  
  @override
  Future<bool> contains(K key) async {
    return _lock.synchronized(() async {
      final entry = _cache[key];
      if (entry == null || entry.isExpired) {
        _cache.remove(key);
        return false;
      }
      return true;
    });
  }
  
  @override
  Future<int> size() async {
    return _lock.synchronized(() async {
      // 清理过期条目
      final now = DateTime.now();
      _cache.removeWhere((key, entry) => entry.isExpired);
      return _cache.length;
    });
  }
  
  /// 清理过期条目
  Future<void> cleanExpired() async {
    return _lock.synchronized(() async {
      _cache.removeWhere((key, entry) => entry.isExpired);
    });
  }
}
