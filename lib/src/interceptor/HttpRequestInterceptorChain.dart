import 'dart:io';

import 'package:Q/src/aware/HttpRequestInterceptorChainAware.dart';
import 'package:Q/src/interceptor/AbstractInterceptor.dart';
import 'package:curie/curie.dart';

abstract class HttpRequestInterceptorChain extends HttpRequestInterceptorChainAware<HttpRequestInterceptorChain> {
  int get currentIndex;

  Future<dynamic> applyPreHandle(HttpRequest httpRequest, HttpResponse httpResponse, HttpRequestInterceptorChain interceptorChain);

  Future<dynamic> applyPostHandle(HttpRequest httpRequest, HttpResponse httpResponse, HttpRequestInterceptorChain interceptorChain);

  void add(AbstractInterceptor interceptor);

  factory HttpRequestInterceptorChain(List<AbstractInterceptor> interceptors) => _HttpRequestInterceptorChain(interceptors);
}

class _HttpRequestInterceptorChain implements HttpRequestInterceptorChain {
  List<AbstractInterceptor> interceptors_;

  int currentIndex_;

  _HttpRequestInterceptorChain(this.interceptors_);

  @override
  Future<dynamic> applyPreHandle(HttpRequest httpRequest, HttpResponse httpResponse, HttpRequestInterceptorChain interceptorChain) async {
    List<Function> functions = List();
    for (int i = 0; i < this.interceptors_.length; i++) {
      functions.add(() async {
        bool suspend;
        try {
          currentIndex_ = i;
          suspend = await this.interceptors_[i].preHandle(httpRequest, httpResponse);
        } catch (e, s) {
          // 如果拦截器执行preHandler时抛出异常，则终止请求
          suspend = true;
          print('Exception details:\n $e');
          print('Stack trace:\n $s');
        }
        return suspend;
      });
    }
    bool suspend = await everySeries(functions);
    return suspend;
  }

  @override
  Future<dynamic> applyPostHandle(HttpRequest httpRequest, HttpResponse httpResponse, HttpRequestInterceptorChain interceptorChain) async {
    List<Function> functions = List();
    for (int i = this.interceptors_.length - 1; i >= 0; i--) {
      functions.add(() async {
        currentIndex_ = i;
        return this.interceptors_[i].postHandle(httpRequest, httpResponse);
      });
    }
    // 处理每一个拦截器的后置处理方法
    await eachSeries(functions);
  }

  @override
  void add(AbstractInterceptor interceptor) {
    this.interceptors_.add(interceptor);
  }

  @override
  int get currentIndex {
    return currentIndex_;
  }
}
