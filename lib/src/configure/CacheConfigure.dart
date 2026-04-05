import 'package:Q/src/ApplicationConfiguration.dart';
import 'package:Q/src/configure/AbstractConfigure.dart';
import 'package:Q/src/configure/ApplicationConfigurationNames.dart';

abstract class CacheConfigure extends AbstractConfigure {
  factory CacheConfigure() => _CacheConfigure();

  bool get enabled;
  set enabled(bool enabled);

  int get defaultTtl;
  set defaultTtl(int defaultTtl);

  CacheSecurityConfigure get security;
  set security(CacheSecurityConfigure security);

  CacheRateLimitConfigure get rateLimit;
  set rateLimit(CacheRateLimitConfigure rateLimit);

  CacheRedisConfigure get redis;
  set redis(CacheRedisConfigure redis);
}

class _CacheConfigure implements CacheConfigure {
  bool _enabled;
  int _defaultTtl;
  CacheSecurityConfigure _security = CacheSecurityConfigure();
  CacheRateLimitConfigure _rateLimit = CacheRateLimitConfigure();
  CacheRedisConfigure _redis = CacheRedisConfigure();

  _CacheConfigure();

  @override
  bool get enabled => _enabled;

  @override
  set enabled(bool enabled) => _enabled = enabled;

  @override
  int get defaultTtl => _defaultTtl;

  @override
  set defaultTtl(int defaultTtl) => _defaultTtl = defaultTtl;

  @override
  CacheSecurityConfigure get security => _security;

  @override
  set security(CacheSecurityConfigure security) => _security = security;

  @override
  CacheRateLimitConfigure get rateLimit => _rateLimit;

  @override
  set rateLimit(CacheRateLimitConfigure rateLimit) => _rateLimit = rateLimit;

  @override
  CacheRedisConfigure get redis => _redis;

  @override
  set redis(CacheRedisConfigure redis) => _redis = redis;

  @override
  Future<dynamic> init(ApplicationConfiguration applicationConfiguration) async {
    _enabled = applicationConfiguration.get(CACHE_ENABLED);
    _defaultTtl = applicationConfiguration.get(CACHE_DEFAULT_TTL);
    _security.enabled = applicationConfiguration.get(CACHE_SECURITY_ENABLED);
    _security.encryptionKey = applicationConfiguration.get(CACHE_SECURITY_ENCRYPTION_KEY);
    _rateLimit.enabled = applicationConfiguration.get(CACHE_RATE_LIMIT_ENABLED);
    _rateLimit.maxRequests = applicationConfiguration.get(CACHE_RATE_LIMIT_MAX_REQUESTS);
    _rateLimit.window = applicationConfiguration.get(CACHE_RATE_LIMIT_WINDOW);
    _redis.enabled = applicationConfiguration.get(CACHE_REDIS_ENABLED);
    _redis.host = applicationConfiguration.get(CACHE_REDIS_HOST);
    _redis.port = applicationConfiguration.get(CACHE_REDIS_PORT);
    _redis.password = applicationConfiguration.get(CACHE_REDIS_PASSWORD);
    _redis.db = applicationConfiguration.get(CACHE_REDIS_DB);
  }
}

abstract class CacheSecurityConfigure {
  factory CacheSecurityConfigure() => _CacheSecurityConfigure();

  bool get enabled;
  set enabled(bool enabled);

  String get encryptionKey;
  set encryptionKey(String encryptionKey);
}

class _CacheSecurityConfigure implements CacheSecurityConfigure {
  bool _enabled;
  String _encryptionKey;

  _CacheSecurityConfigure();

  @override
  bool get enabled => _enabled;

  @override
  set enabled(bool enabled) => _enabled = enabled;

  @override
  String get encryptionKey => _encryptionKey;

  @override
  set encryptionKey(String encryptionKey) => _encryptionKey = encryptionKey;
}

abstract class CacheRateLimitConfigure {
  factory CacheRateLimitConfigure() => _CacheRateLimitConfigure();

  bool get enabled;
  set enabled(bool enabled);

  int get maxRequests;
  set maxRequests(int maxRequests);

  int get window;
  set window(int window);
}

class _CacheRateLimitConfigure implements CacheRateLimitConfigure {
  bool _enabled;
  int _maxRequests;
  int _window;

  _CacheRateLimitConfigure();

  @override
  bool get enabled => _enabled;

  @override
  set enabled(bool enabled) => _enabled = enabled;

  @override
  int get maxRequests => _maxRequests;

  @override
  set maxRequests(int maxRequests) => _maxRequests = maxRequests;

  @override
  int get window => _window;

  @override
  set window(int window) => _window = window;
}

abstract class CacheRedisConfigure {
  factory CacheRedisConfigure() => _CacheRedisConfigure();

  bool get enabled;
  set enabled(bool enabled);

  String get host;
  set host(String host);

  int get port;
  set port(int port);

  String get password;
  set password(String password);

  int get db;
  set db(int db);
}

class _CacheRedisConfigure implements CacheRedisConfigure {
  bool _enabled;
  String _host;
  int _port;
  String _password;
  int _db;

  _CacheRedisConfigure();

  @override
  bool get enabled => _enabled;

  @override
  set enabled(bool enabled) => _enabled = enabled;

  @override
  String get host => _host;

  @override
  set host(String host) => _host = host;

  @override
  int get port => _port;

  @override
  set port(int port) => _port = port;

  @override
  String get password => _password;

  @override
  set password(String password) => _password = password;

  @override
  int get db => _db;

  @override
  set db(int db) => _db = db;
}

