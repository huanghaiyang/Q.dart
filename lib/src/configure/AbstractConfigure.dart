/**
 * 配置抽象类，定义了所有配置类的基本接口
 * 
 * 所有具体的配置类都应该继承自此类，并实现init方法来初始化配置
 */
import 'package:Q/src/ApplicationConfiguration.dart';

abstract class AbstractConfigure {
  /**
   * 初始化配置
   * 
   * @param applicationConfiguration 应用配置对象
   * @return 初始化结果
   */
  Future<dynamic> init(ApplicationConfiguration applicationConfiguration);
}
