import 'package:Q/src/ApplicationConfiguration.dart';
import 'package:Q/src/configure/AbstractConfigure.dart';
import 'package:Q/src/configure/ApplicationConfigurationNames.dart';
import 'package:Q/src/utils/ConfigureUtil.dart';

abstract class ServerConfigure extends AbstractConfigure {
  factory ServerConfigure() => _ServerConfigure();

  int get sessionTimeout;

  int get connectionTimeout;
  
  int get maxConcurrentConnections;
}

class _ServerConfigure implements ServerConfigure {
  int sessionTimeout_ = 30;

  int connectionTimeout_ = 30;
  
  int maxConcurrentConnections_ = 2000;

  @override
  int get sessionTimeout {
    return sessionTimeout_;
  }

  @override
  int get connectionTimeout {
    return connectionTimeout_;
  }
  
  @override
  int get maxConcurrentConnections {
    return maxConcurrentConnections_;
  }

  @override
  Future<dynamic> init(dynamic applicationConfiguration) async {
    // 从配置中获取会话超时时间，如果不存在则使用默认值 30 秒
    sessionTimeout_ = ConfigureUtil.parseIntConfig(
      applicationConfiguration.get(SERVER_SESSION_TIMEOUT),
      30,
      'sessionTimeout'
    );

    // 从配置中获取连接超时时间，如果不存在则使用默认值 30 秒
    connectionTimeout_ = ConfigureUtil.parseIntConfig(
      applicationConfiguration.get(SERVER_CONNECTION_TIMEOUT),
      30,
      'connectionTimeout'
    );
    
    // 从配置中获取最大并发连接数，如果不存在则使用默认值 1000
    maxConcurrentConnections_ = ConfigureUtil.parseIntConfig(
      applicationConfiguration.get(SERVER_MAX_CONCURRENT_CONNECTIONS),
      1000,
      'maxConcurrentConnections'
    );
  }
}
