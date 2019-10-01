import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/Router.dart';
import 'package:Q/src/aware/RouteAware.dart';
import 'package:Q/src/delegate/AbstractDelegate.dart';

abstract class ApplicationRouteDelegate extends RouteAware<Router> with AbstractDelegate {
  factory ApplicationRouteDelegate(Application application) => _ApplicationRouteDelegate(application);

  factory ApplicationRouteDelegate.from(Application application) {
    return application.getDelegate(ApplicationRouteDelegate);
  }
}

class _ApplicationRouteDelegate implements ApplicationRouteDelegate {
  final Application application_;

  _ApplicationRouteDelegate(this.application_);

// 添加路由
  @override
  void route(Router router) {
    this.application_.routers.add(router);
    // 查找路由的响应结果转换器
    router.converter = this.application_.converters[router?.produceType != null
        ? router.produceType
        : Application.getApplicationContext().configuration.httpResponseConfigure.defaultProducedType];
    router.handlerAdapter = this.application_.handlers[HttpStatus.ok];
  }

  // 同时添加多个路由
  @override
  void routes(Iterable<Router> routers) {
    routers.forEach((router) => this.route(router));
  }
}
