import 'dart:async';

/// 缓存接口
abstract class Cache<K, V> {
  /// 获取缓存值
  Future<V> get(K key);
  
  /// 设置缓存值
  Future<void> set(K key, V value, {Duration ttl});
  
  /// 删除缓存值
  Future<void> remove(K key);
  
  /// 清空缓存
  Future<void> clear();
  
  /// 检查缓存是否存在
  Future<bool> contains(K key);
  
  /// 获取缓存大小
  Future<int> size();
}

/// 缓存管理器
abstract class CacheManager {
  /// 获取缓存实例
  Future<Cache> getCache(String name);
  
  /// 关闭所有缓存
  Future<void> close();
}
