import 'dart:io';
import 'dart:mirrors';

import 'package:Q/src/aware/HttpRequestInterceptorChainAware.dart';
import 'package:Q/src/exception/DuplicateInterceptorRegistryException.dart';
import 'package:Q/src/interceptor/AbstractInterceptor.dart';
import 'package:Q/src/interceptor/HttpRequestInterceptorState.dart';
import 'package:curie/curie.dart';

abstract class HttpRequestInterceptorChain extends HttpRequestInterceptorChainAware<HttpRequestInterceptorState> {
  Future<dynamic> applyPreHandle(HttpRequest httpRequest, HttpResponse httpResponse, HttpRequestInterceptorState interceptorState);

  Future<dynamic> applyPostHandle(HttpRequest httpRequest, HttpResponse httpResponse, HttpRequestInterceptorState interceptorState);

  void add(AbstractInterceptor interceptor);

  factory HttpRequestInterceptorChain(List<AbstractInterceptor> interceptors) => _HttpRequestInterceptorChain(interceptors);
}

class _HttpRequestInterceptorChain implements HttpRequestInterceptorChain {
  List<AbstractInterceptor> interceptors_;

  _HttpRequestInterceptorChain(this.interceptors_);

  @override
  Future<dynamic> applyPreHandle(HttpRequest httpRequest, HttpResponse httpResponse, HttpRequestInterceptorState interceptorState) async {
    interceptorState.total = this.interceptors_.length;
    List<Function> functions = List();
    for (int i = 0; i < this.interceptors_.length; i++) {
      functions.add(() async {
        interceptorState.preProcessIndex = i;
        bool suspend;
        try {
          suspend = await this.interceptors_[i].preHandle(httpRequest, httpResponse, interceptorState);
        } catch (error, stackTrace) {
          // 如果拦截器执行preHandler时抛出异常，则终止请求
          suspend = true;
          this.onError(error, stackTrace: stackTrace);
        }
        return suspend;
      });
    }
    bool suspend = await everySeries(functions);
    interceptorState.preProcessSuspend = suspend;
    return suspend;
  }

  @override
  Future<dynamic> applyPostHandle(HttpRequest httpRequest, HttpResponse httpResponse, HttpRequestInterceptorState interceptorState) async {
    List<Function> functions = List();
    for (int i = this.interceptors_.length - 1; i >= 0; i--) {
      functions.add(() async {
        interceptorState.postProcessIndex = i;
        return this.interceptors_[i].postHandle(httpRequest, httpResponse, interceptorState);
      });
    }
    // 处理每一个拦截器的后置处理方法
    await eachSeries(functions);
  }

  @override
  void add(AbstractInterceptor interceptor) {
    if (this.interceptors_.isNotEmpty) {
      AbstractInterceptor existInterceptor = this.interceptors_.firstWhere((item) {
        return reflect(item).type.reflectedType == reflect(interceptor).type.reflectedType;
      });
      if (existInterceptor != null) {
        throw DuplicateInterceptorRegistryException(interceptor: interceptor);
      }
    }
    this.interceptors_.add(interceptor);
  }

  @override
  void onError(Error error, {StackTrace stackTrace}) {
    print('Exception details:\n $error');
    print('Stack trace:\n $stackTrace');
  }
}
