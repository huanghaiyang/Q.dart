import 'package:Q/src/ApplicationConfiguration.dart';
import 'package:Q/src/configure/HttpRequestConfigure.dart';
import 'package:Q/src/configure/HttpResponseConfigure.dart';
import 'package:Q/src/configure/InterceptorConfigure.dart';
import 'package:Q/src/configure/MultipartConfigure.dart';
import 'package:Q/src/configure/RouterMappingConfigure.dart';

// 应用程序配置
abstract class Configuration {
  MultipartConfigure get multipartConfigure;

  RouterMappingConfigure get routerMappingConfigure;

  InterceptorConfigure get interceptorConfigure;

  HttpRequestConfigure get httpRequestConfigure;

  HttpResponseConfigure get httpResponseConfigure;

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
  Future<dynamic> init(ApplicationConfiguration applicationConfiguration) async {
    await Future.wait([
      _multipartConfigure.init(applicationConfiguration),
      _routerMappingConfigure.init(applicationConfiguration),
      _httpResponseConfigure.init(applicationConfiguration),
      _httpRequestConfigure.init(applicationConfiguration),
      _interceptorConfigure.init(applicationConfiguration)
    ]);
  }
}
