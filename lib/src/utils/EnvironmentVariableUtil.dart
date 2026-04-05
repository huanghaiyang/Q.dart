import 'dart:io';

/// 环境变量工具类，用于从环境变量加载配置值
class EnvironmentVariableUtil {
  static const String ENV_PREFIX = 'Q_';
  
  /// 从环境变量加载配置
  static Map<String, dynamic> loadFromEnvironment() {
    Map<String, dynamic> envConfig = {};
    
    // 遍历所有环境变量
    Platform.environment.forEach((key, value) {
      // 只处理以APP_开头的环境变量
      if (key.startsWith(ENV_PREFIX)) {
        // 移除前缀并转换为小写
        String configKey = key.substring(ENV_PREFIX.length).toLowerCase();
        // 将下划线转换为点，符合配置文件的路径格式
        configKey = configKey.replaceAll('_', '.');
        // 将值添加到配置映射中
        envConfig[configKey] = value;
      }
    });
    
    return envConfig;
  }
  
  /// 从环境变量获取特定配置值
  static String getEnvironmentValue(String key) {
    String envKey = ENV_PREFIX + key.toUpperCase().replaceAll('.', '_');
    return Platform.environment[envKey];
  }
  
  /// 检查环境变量是否存在
  static bool hasEnvironmentValue(String key) {
    String envKey = ENV_PREFIX + key.toUpperCase().replaceAll('.', '_');
    return Platform.environment.containsKey(envKey);
  }
}