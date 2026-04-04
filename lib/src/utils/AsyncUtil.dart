import 'dart:async';

/// 异步工具类，提供替代 curie 和 todash 的函数
class AsyncUtil {
  /// 按顺序执行函数列表，只要有一个返回 false 就停止并返回 false
  static Future<bool> everySeries(List<Function> functions) async {
    for (var func in functions) {
      bool result = await func();
      if (!result) {
        return false;
      }
    }
    return true;
  }

  /// 按顺序执行函数列表，不关心返回值
  static Future<void> eachSeries(List<Function> functions) async {
    for (var func in functions) {
      await func();
    }
  }

  /// 按顺序执行函数列表，将前一个函数的返回值作为下一个函数的参数
  static Future<dynamic> waterfall(List<Function> functions) async {
    dynamic result;
    for (var func in functions) {
      result = await func(result);
    }
    return result;
  }

  /// 限制并发执行的函数数量，只要有一个返回 true 就停止
  static Future<void> someLimit(List<Function> functions, int limit, Function(Map<int, bool> result) callback) async {
    Map<int, bool> results = {};
    int index = 0;
    int running = 0;
    Completer<void> completer = Completer<void>();

    void processNext() {
      if (index >= functions.length && running == 0) {
        callback(results);
        completer.complete();
        return;
      }

      while (running < limit && index < functions.length) {
        int currentIndex = index;
        index++;
        running++;

        functions[currentIndex]().then((bool result) {
          results[currentIndex] = result;
          running--;
          
          // 检查是否有任何结果为 true
          if (result) {
            callback(results);
            completer.complete();
          } else {
            processNext();
          }
        }).catchError((error) {
          results[currentIndex] = false;
          running--;
          processNext();
        });
      }
    }

    processNext();
    await completer.future;
  }

  /// 生成指定范围内的整数列表
  static List<int> range(int start, int end) {
    List<int> result = [];
    for (int i = start; i < end; i++) {
      result.add(i);
    }
    return result;
  }
}
