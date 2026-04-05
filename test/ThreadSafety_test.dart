import 'dart:async';
import 'package:test/test.dart';
import 'package:synchronized/synchronized.dart';

void main() {
  group('线程安全测试', () {
    test('Lock 同步测试', () async {
      final lock = Lock();
      int counter = 0;
      
      // 并发执行 100 次增量操作
      final futures = List.generate(100, (i) async {
        await lock.synchronized(() async {
          final temp = counter;
          await Future.delayed(Duration(milliseconds: 1));
          counter = temp + 1;
        });
      });
      
      await Future.wait(futures);
      
      // 验证计数器正确
      expect(counter, equals(100));
    });
    
    test('多个锁实例测试', () async {
      final lock1 = Lock();
      final lock2 = Lock();
      int counter1 = 0;
      int counter2 = 0;
      
      // 使用不同的锁并发执行
      final futures1 = List.generate(50, (i) async {
        await lock1.synchronized(() async {
          counter1++;
        });
      });
      
      final futures2 = List.generate(50, (i) async {
        await lock2.synchronized(() async {
          counter2++;
        });
      });
      
      await Future.wait([...futures1, ...futures2]);
      
      expect(counter1, equals(50));
      expect(counter2, equals(50));
    });
  });
}
