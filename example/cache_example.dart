import 'dart:async';
import 'package:Q/Q.dart';

void main() async {
  // 初始化缓存管理器
  final cacheManager = CacheManagerImpl();
  CacheUtils.initialize(cacheManager);
  
  // 测试内存缓存
  print('=== 测试内存缓存 ===');
  
  // 获取全局缓存
  final cache = await CacheUtils.globalCache;
  
  // 设置缓存
  await cache.set('key1', 'value1');
  await cache.set('key2', 'value2', ttl: Duration(seconds: 2));
  
  // 获取缓存
  print('key1: ${await cache.get('key1')}');
  print('key2: ${await cache.get('key2')}');
  print('key3: ${await cache.get('key3')}');
  
  // 检查缓存是否存在
  print('key1 exists: ${await cache.contains('key1')}');
  print('key3 exists: ${await cache.contains('key3')}');
  
  // 获取缓存大小
  print('Cache size: ${await cache.size()}');
  
  // 等待 3 秒，让 key2 过期
  print('等待 3 秒...');
  await Future.delayed(Duration(seconds: 3));
  
  // 再次获取 key2
  print('key2 after expiration: ${await cache.get('key2')}');
  print('key2 exists after expiration: ${await cache.contains('key2')}');
  
  // 获取缓存大小（应该减少）
  print('Cache size after expiration: ${await cache.size()}');
  
  // 删除缓存
  await cache.remove('key1');
  print('key1 after remove: ${await cache.get('key1')}');
  
  // 清空缓存
  await cache.clear();
  print('Cache size after clear: ${await cache.size()}');
  
  // 测试多个缓存实例
  print('\n=== 测试多个缓存实例 ===');
  
  final userCache = await CacheUtils.getCache('user');
  final productCache = await CacheUtils.getCache('product');
  
  await userCache.set('user1', {'id': 1, 'name': 'John'});
  await productCache.set('product1', {'id': 1, 'name': 'Product 1'});
  
  print('User cache size: ${await userCache.size()}');
  print('Product cache size: ${await productCache.size()}');
  print('User 1: ${await userCache.get('user1')}');
  print('Product 1: ${await productCache.get('product1')}');
  
  // 关闭缓存管理器
  await cacheManager.close();
  
  print('\n缓存测试完成！');
}
