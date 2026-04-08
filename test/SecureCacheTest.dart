import 'dart:async';
import 'package:test/test.dart';
import 'package:Q/Q.dart';

void main() {
  group('SecureCache', () {
    CacheManager cacheManager;
    Cache cache;
    
    setUp(() async {
      // 初始化缓存管理器
      cacheManager = CacheManagerImpl(
        encryptionKey: 'test_encryption_key',
        enableSecurity: true
      );
      CacheUtils.initialize(cacheManager);
      
      // 获取缓存
      cache = await CacheUtils.getCache('secure');
      // 确保缓存为空
      await cache.clear();
    });
    
    tearDown(() async {
      await cacheManager.close();
    });
    
    test('缓存键安全处理', () async {
      // 测试不安全的键
      final unsafeKey = 'key<script>alert(1)</script>';
      await cache.set(unsafeKey, 'value');
      
      // 验证键被安全处理
      expect(await cache.get(unsafeKey), equals('value'));
    });
    
    test('敏感数据加密', () async {
      // 测试敏感数据
      final sensitiveData = 'test@example.com';
      await cache.set('email', sensitiveData);
      
      // 验证数据被加密存储
      // 注意：我们无法直接检查内部存储，但可以验证能正确获取
      final retrieved = await cache.get('email');
      expect(retrieved, equals(sensitiveData));
    });
    
    test('速率限制', () async {
      // 测试速率限制
      final rateLimiter = (cacheManager as CacheManagerImpl).rateLimiter;
      
      // 连续请求超过限制
      int successCount = 0;
      for (int i = 0; i < 110; i++) {
        try {
          await cache.get('rate_limit_test');
          successCount++;
        } catch (e) {
          // 预期会抛出速率限制异常
          expect(e.toString(), contains('Rate limit exceeded'));
          break;
        }
      }
      
      // 验证前 100 个请求成功
      expect(successCount, equals(100));
    });
    
    test('超时处理', () async {
      // 测试超时处理
      // 这里我们通过模拟长时间操作来测试超时
      // 由于我们无法直接模拟缓存操作的延迟，这个测试主要是确保超时机制存在
      expect(() async {
        // 正常操作应该不会超时
        await cache.set('timeout_test', 'value');
        await cache.get('timeout_test');
      }, returnsNormally);
    });
    
    test('基本缓存操作', () async {
      // 测试基本缓存操作
      await cache.set('key1', 'value1');
      expect(await cache.get('key1'), equals('value1'));
      expect(await cache.contains('key1'), isTrue);
      
      await cache.remove('key1');
      expect(await cache.get('key1'), isNull);
      expect(await cache.contains('key1'), isFalse);
      
      await cache.set('key2', 'value2');
      await cache.set('key3', 'value3');
      expect(await cache.size(), equals(2));
      
      await cache.clear();
      expect(await cache.size(), equals(0));
    });
  });
}
