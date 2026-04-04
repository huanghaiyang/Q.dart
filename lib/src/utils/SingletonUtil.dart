/// 单例模式工具类
/// 提供统一的单例模式实现
class SingletonUtil {
  /// 获取或创建单例实例
  /// 
  /// [creator] 创建实例的函数
  /// [instance] 当前实例
  /// 
  /// 返回单例实例
  static T getInstance<T>(T instance, T Function() creator) {
    return instance ?? creator();
  }
}
