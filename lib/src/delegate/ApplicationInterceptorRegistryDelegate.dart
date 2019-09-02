import 'package:Q/src/Application.dart';
import 'package:Q/src/aware/InterceptorRegistryAware.dart';
import 'package:Q/src/delegate/AbstractDelegate.dart';
import 'package:Q/src/exception/IllegalArgumentException.dart';
import 'package:Q/src/helpers/interceptor/InterceptorHelper.dart';
import 'package:Q/src/interceptor/AbstractInterceptor.dart';

abstract class ApplicationInterceptorRegistryDelegate extends InterceptorRegistryAware<AbstractInterceptor> with AbstractDelegate {
  factory ApplicationInterceptorRegistryDelegate(Application application) => _ApplicationInterceptorRegistryDelegate(application);

  factory ApplicationInterceptorRegistryDelegate.from(Application application) {
    return application.getDelegate(ApplicationInterceptorRegistryDelegate);
  }
}

class _ApplicationInterceptorRegistryDelegate implements ApplicationInterceptorRegistryDelegate {
  final Application application;

  _ApplicationInterceptorRegistryDelegate(this.application);

  // 拦截器注册
  @override
  void registryInterceptor(AbstractInterceptor interceptor) {
    if (interceptor == null) {
      throw IllegalArgumentException(message: '(AbstractInterceptor interceptor) argument could not be null.');
    }
    this.application.httpRequestInterceptorChain.add(interceptor);
  }

  // 注册多个拦截器
  @override
  void registryInterceptors(Iterable<AbstractInterceptor> interceptors) {
    if (InterceptorHelper.canRegistry(interceptors)) {
      List.from(interceptors).forEach((interceptor) => this.registryInterceptor(interceptor));
    }
  }
}
