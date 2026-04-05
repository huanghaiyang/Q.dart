import 'dart:io';

import 'package:Q/src/aware/InterceptorContext.dart';
import 'package:Q/src/i18n/I18nManager.dart';
import 'package:Q/src/interceptor/AbstractInterceptor.dart';

class I18nInterceptor implements AbstractInterceptor {
  I18nInterceptor._();

  static I18nInterceptor _instance;

  static I18nInterceptor instance() {
    return _instance ?? (_instance = I18nInterceptor._());
  }

  @override
  Future<bool> preHandle(HttpRequest req, HttpResponse res, InterceptorContext interceptorContext) async {
    // 获取语言设置
    String locale = I18nManager().getLocaleFromRequest(req);
    
    // 设置语言Cookie
    I18nManager().setLocaleCookie(res, locale);
    
    // 将语言设置存储在上下文环境中
    if (interceptorContext != null) {
      interceptorContext.setState('locale', locale);
    }
    
    return true;
  }

  @override
  void postHandle(HttpRequest req, HttpResponse res, InterceptorContext interceptorContext) {}
}
