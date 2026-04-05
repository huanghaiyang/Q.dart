import 'dart:async';
import 'package:synchronized/synchronized.dart';

import 'Cache.dart';
import 'InMemoryCache.dart';
import 'RedisCache.dart';
import 'SecureCacheWrapper.dart';
import 'RateLimiter.dart';
import 'package:Q/src/configure/CacheConfigure.dart';

/// 缓存管理器实现
class CacheManagerImpl implements CacheManager {
  final Map<String, Cache> _caches = {};
  final Lock _lock = Lock();
  RedisClient _redisClient;
  final RateLimiter _rateLimiter;
  final String _encryptionKey;
  final bool _enableSecurity;
  final Duration _defaultTtl;
  
  CacheManagerImpl({
    RedisClient redisClient,
    RateLimiter rateLimiter,
    String encryptionKey = 'default_encryption_key',
    bool enableSecurity = true,
    Duration defaultTtl,
  }) : 
    _redisClient = redisClient,
    _rateLimiter = rateLimiter ?? RateLimiter(),
    _encryptionKey = encryptionKey,
    _enableSecurity = enableSecurity,
    _defaultTtl = defaultTtl ?? Duration(seconds: 300);
  
  /// 从CacheConfigure创建CacheManagerImpl
  factory CacheManagerImpl.fromConfigure(CacheConfigure configure) {
    return CacheManagerImpl(
      redisClient: null, // Redis客户端需要单独设置
      rateLimiter: RateLimiter(
        maxRequests: configure.rateLimit.maxRequests,
        window: Duration(seconds: configure.rateLimit.window),
      ),
      encryptionKey: configure.security.encryptionKey,
      enableSecurity: configure.security.enabled,
      defaultTtl: Duration(seconds: configure.defaultTtl),
    );
  }
  
  @override
  Future<Cache> getCache(String name) async {
    return await _lock.synchronized(() async {
      if (!_caches.containsKey(name)) {
        Cache cache;
        if (_redisClient != null) {
          // 使用 Redis 缓存
          cache = RedisCache(_redisClient);
        } else {
          // 使用内存缓存
          cache = InMemoryCache(defaultTtl: _defaultTtl);
        }
        
        // 包装为安全缓存
        if (_enableSecurity) {
          cache = SecureCacheWrapper(
            cache,
            rateLimiter: _rateLimiter,
            encryptionKey: _encryptionKey
          );
        }
        
        _caches[name] = cache;
      }
      return _caches[name];
    });
  }
  
  @override
  Future<void> close() async {
    await _lock.synchronized(() async {
      for (final cache in _caches.values) {
        if (cache is RedisCache) {
          // 关闭 Redis 连接
        }
      }
      _caches.clear();
      if (_redisClient != null) {
        await _redisClient.close();
      }
    });
  }
  
  /// 设置 Redis 客户端
  void setRedisClient(RedisClient client) {
    _redisClient = client;
  }
  
  /// 获取所有缓存名称
  List<String> getCacheNames() {
    return _caches.keys.toList();
  }
  
  /// 获取速率限制器
  RateLimiter get rateLimiter => _rateLimiter;
  
  /// 启用/禁用安全功能
  bool get enableSecurity => _enableSecurity;
}
