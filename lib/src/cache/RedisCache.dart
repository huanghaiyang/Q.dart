import 'dart:async';
import 'dart:convert';

import 'Cache.dart';

/// Redis 缓存实现
class RedisCache<K, V> implements Cache<K, V> {
  final RedisClient _client;
  final String _prefix;
  
  RedisCache(this._client, {String prefix = 'cache:'}) : _prefix = prefix;
  
  @override
  Future<V> get(K key) async {
    final value = await _client.get(_getKey(key));
    if (value == null) return null;
    return _deserialize(value) as V;
  }
  
  @override
  Future<void> set(K key, V value, {Duration ttl}) async {
    final redisKey = _getKey(key);
    final redisValue = _serialize(value);
    
    if (ttl != null) {
      await _client.setex(redisKey, ttl.inSeconds, redisValue);
    } else {
      await _client.set(redisKey, redisValue);
    }
  }
  
  @override
  Future<void> remove(K key) async {
    await _client.del([_getKey(key)]);
  }
  
  @override
  Future<void> clear() async {
    final keys = await _client.keys('$_prefix*');
    if (keys.isNotEmpty) {
      await _client.del(keys);
    }
  }
  
  @override
  Future<bool> contains(K key) async {
    final exists = await _client.exists(_getKey(key));
    return exists > 0;
  }
  
  @override
  Future<int> size() async {
    final keys = await _client.keys('$_prefix*');
    return keys.length;
  }
  
  /// 获取带前缀的键
  String _getKey(K key) => '$_prefix$key';
  
  /// 序列化值
  String _serialize(V value) {
    if (value is String) return value;
    return jsonEncode(value);
  }
  
  /// 反序列化值
  dynamic _deserialize(String value) {
    try {
      return jsonDecode(value);
    } catch (e) {
      return value;
    }
  }
}

/// Redis 客户端接口
abstract class RedisClient {
  Future<String> get(String key);
  Future<void> set(String key, String value);
  Future<void> setex(String key, int seconds, String value);
  Future<void> del(List<String> keys);
  Future<List<String>> keys(String pattern);
  Future<int> exists(String key);
  Future<void> close();
}
