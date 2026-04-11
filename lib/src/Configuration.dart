import 'package:Q/src/ApplicationConfiguration.dart';
import 'package:Q/src/configure/HttpRequestConfigure.dart';
import 'package:Q/src/configure/HttpResponseConfigure.dart';
import 'package:Q/src/configure/InterceptorConfigure.dart';
import 'package:Q/src/configure/MultipartConfigure.dart';
import 'package:Q/src/configure/RouterMappingConfigure.dart';
import 'package:Q/src/configure/DatabaseConfigure.dart';
import 'package:Q/src/configure/CacheConfigure.dart';
import 'package:Q/src/configure/SecurityConfigure.dart';
import 'package:Q/src/configure/ServerConfigure.dart';

// 应用程序配置
abstract class Configuration {
  MultipartConfigure get multipartConfigure;

  RouterMappingConfigure get routerMappingConfigure;

  InterceptorConfigure get interceptorConfigure;

  HttpRequestConfigure get httpRequestConfigure;

  HttpResponseConfigure get httpResponseConfigure;

  DatabaseConfigure get databaseConfigure;

  CacheConfigure get cacheConfigure;

  SecurityConfigure get securityConfigure;

  ServerConfigure get serverConfigure;

  Future<dynamic> init(ApplicationConfiguration applicationConfiguration);

  factory Configuration() => _Configuration();
}

class _Configuration implements Configuration {
  _Configuration();

  MultipartConfigure _multipartConfigure = MultipartConfigure();

  RouterMappingConfigure _routerMappingConfigure = RouterMappingConfigure();

  InterceptorConfigure _interceptorConfigure = InterceptorConfigure();

  HttpRequestConfigure _httpRequestConfigure = HttpRequestConfigure();

  HttpResponseConfigure _httpResponseConfigure = HttpResponseConfigure();

  DatabaseConfigure _databaseConfigure = DatabaseConfigure();

  CacheConfigure _cacheConfigure = CacheConfigure();

  SecurityConfigure _securityConfigure = SecurityConfigure();

  ServerConfigure _serverConfigure = ServerConfigure();

  @override
  MultipartConfigure get multipartConfigure {
    return this._multipartConfigure;
  }

  @override
  RouterMappingConfigure get routerMappingConfigure {
    return this._routerMappingConfigure;
  }

  @override
  InterceptorConfigure get interceptorConfigure {
    return this._interceptorConfigure;
  }

  @override
  HttpRequestConfigure get httpRequestConfigure {
    return this._httpRequestConfigure;
  }

  @override
  HttpResponseConfigure get httpResponseConfigure {
    return this._httpResponseConfigure;
  }

  @override
  DatabaseConfigure get databaseConfigure {
    return this._databaseConfigure;
  }

  @override
  CacheConfigure get cacheConfigure {
    return this._cacheConfigure;
  }

  @override
  SecurityConfigure get securityConfigure {
    return this._securityConfigure;
  }

  @override
  ServerConfigure get serverConfigure {
    return this._serverConfigure;
  }

  @override
  Future<dynamic> init(ApplicationConfiguration applicationConfiguration) async {
    await Future.wait([
      _multipartConfigure.init(applicationConfiguration),
      _routerMappingConfigure.init(applicationConfiguration),
      _httpResponseConfigure.init(applicationConfiguration),
      _httpRequestConfigure.init(applicationConfiguration),
      _interceptorConfigure.init(applicationConfiguration),
      _databaseConfigure.init(applicationConfiguration),
      _cacheConfigure.init(applicationConfiguration),
      _securityConfigure.init(applicationConfiguration),
      _serverConfigure.init(applicationConfiguration),
    ]);
  }
}
