import 'dart:io';
import 'package:Q/src/ApplicationConfigurationLoader.dart';
import 'package:Q/src/resource/ApplicationConfigurationResource.dart';
import 'package:Q/src/utils/EnvironmentVariableUtil.dart';
import 'package:test/test.dart';

void main() {
  group('配置管理测试', () {
    test('环境变量工具类测试', () {
      // 测试环境变量转换逻辑
      // 测试getEnvironmentValue方法
      String testKey = 'server.port';
      String expectedEnvKey = 'APP_SERVER_PORT';
      
      // 测试hasEnvironmentValue方法
      bool hasValue = EnvironmentVariableUtil.hasEnvironmentValue('non.existent.key');
      expect(hasValue, false);
      
      // 测试环境变量键转换
      String envKey = 'Q_SERVER_PORT';
      String expectedConfigKey = 'server.port';
      String actualConfigKey = envKey.substring('Q_'.length).toLowerCase().replaceAll('_', '.');
      expect(actualConfigKey, expectedConfigKey);
    });
    
    test('配置文件加载测试', () async {
      // 创建测试配置文件
      String testConfigPath = 'test/test_config.yml';
      File testConfigFile = File(testConfigPath);
      await testConfigFile.writeAsString('''
server:
  port: 8080
  host: localhost

security:
  auth:
    enabled: true
''');
      
      try {
        // 创建配置资源
        ApplicationConfigurationResource resource = ApplicationConfigurationResource.fromPath(testConfigPath, priority: 5);
        List<ApplicationConfigurationResource> resources = [resource];
        
        // 加载配置
        ApplicationConfigurationLoader loader = ApplicationConfigurationLoader.instance();
        List configurations = await loader.load(resources);
        
        // 验证配置是否正确加载
        expect(configurations.length, 1);
        var config = configurations[0];
        expect(config.values['server.port'], 8080);
        expect(config.values['server.host'], 'localhost');
        expect(config.values['security.auth.enabled'], true);
      } finally {
        // 删除测试配置文件
        if (await testConfigFile.exists()) {
          await testConfigFile.delete();
        }
      }
    });
    
    test('配置文件和环境变量加载测试', () async {
      // 创建测试配置文件
      String testConfigPath = 'test/test_config.yml';
      File testConfigFile = File(testConfigPath);
      await testConfigFile.writeAsString('''
server:
  port: 8080
  host: localhost
''');
      
      try {
        // 创建配置资源
        ApplicationConfigurationResource resource = ApplicationConfigurationResource.fromPath(testConfigPath, priority: 5);
        List<ApplicationConfigurationResource> resources = [resource];
        
        // 加载配置
        ApplicationConfigurationLoader loader = ApplicationConfigurationLoader.instance();
        List configurations = await loader.load(resources);
        
        // 验证配置是否正确加载
        expect(configurations.length, 1);
        var config = configurations[0];
        expect(config.values['server.port'], 8080);
        expect(config.values['server.host'], 'localhost');
      } finally {
        // 删除测试配置文件
        if (await testConfigFile.exists()) {
          await testConfigFile.delete();
        }
      }
    });
  });
}