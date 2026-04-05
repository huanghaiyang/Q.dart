import 'Cache.dart';
import 'CacheManagerImpl.dart';
import 'package:Q/src/configure/CacheConfigure.dart';

/// 缓存工具类
class CacheUtils {
  static CacheManager _cacheManager;
  static Map<String, Cache> _cacheInstances = {};
  
  /// 初始化缓存管理器
  static void initialize(CacheManager cacheManager) {
    _cacheManager = cacheManager;
  }
  
  /// 从配置初始化缓存管理器
  static void initializeFromConfigure(CacheConfigure configure) {
    _cacheManager = CacheManagerImpl.fromConfigure(configure);
  }
  
  /// 获取缓存管理器
  static CacheManager get cacheManager {
    if (_cacheManager == null) {
      throw Exception('CacheManager not initialized');
    }
    return _cacheManager;
  }
  
  /// 获取缓存实例
  static Future<Cache> getCache(String name) async {
    if (!_cacheInstances.containsKey(name)) {
      _cacheInstances[name] = await cacheManager.getCache(name);
    }
    return _cacheInstances[name];
  }
  
  /// 全局缓存
  static Future<Cache> get globalCache async {
    return await getCache('global');
  }
  
  /// 设置缓存
  static Future<void> set(key, value, {Duration ttl}) async {
    final cache = await globalCache;
    return cache.set(key, value, ttl: ttl);
  }
  
  /// 获取缓存
  static Future get(key) async {
    final cache = await globalCache;
    return cache.get(key);
  }
  
  /// 删除缓存
  static Future<void> remove(key) async {
    final cache = await globalCache;
    return cache.remove(key);
  }
  
  /// 检查缓存是否存在
  static Future<bool> contains(key) async {
    final cache = await globalCache;
    return cache.contains(key);
  }
  
  /// 清空全局缓存
  static Future<void> clear() async {
    final cache = await globalCache;
    return cache.clear();
  }
}
