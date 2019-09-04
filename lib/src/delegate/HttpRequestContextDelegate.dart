import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/Context.dart';
import 'package:Q/src/Request.dart';
import 'package:Q/src/Response.dart';
import 'package:Q/src/aware/HttpRequestContextAware.dart';
import 'package:Q/src/delegate/AbstractDelegate.dart';
import 'package:Q/src/interceptor/HttpRequestInterceptorState.dart';

abstract class HttpRequestContextDelegate extends AbstractDelegate with HttpRequestContextAware<Context> {
  factory HttpRequestContextDelegate(Application application) => _HttpRequestContextDelegate(application);

  factory HttpRequestContextDelegate.from(Application application) {
    return application.getDelegate(HttpRequestContextDelegate);
  }
}

class _HttpRequestContextDelegate implements HttpRequestContextDelegate {
  final Application application;

  _HttpRequestContextDelegate(this.application);

  // 创建上下文
  @override
  Future<Context> createContext(HttpRequest req, HttpResponse res, {HttpRequestInterceptorState interceptorState}) async {
    Response response = Response();
    Request request = await this.application.resolveRequest(req);
    request.req = req;
    response.res = res;
    Context context = Context(request, response, this.application, interceptorState: interceptorState);
    request.context = response.context = context;
    request.response = response;
    response.request = request;
    return context;
  }
}
