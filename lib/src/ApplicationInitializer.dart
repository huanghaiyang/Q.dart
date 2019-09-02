import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/ApplicationContext.dart';
import 'package:Q/src/converter/JSONHttpMessageConverter.dart';
import 'package:Q/src/converter/StringHttpMessageConverter.dart';
import 'package:Q/src/handler/NotFoundHandler.dart';
import 'package:Q/src/handler/OKHandler.dart';
import 'package:Q/src/interceptor/HttpRequestInterceptorChain.dart';
import 'package:Q/src/interceptor/I18nInterceptor.dart';
import 'package:Q/src/interceptor/UnSupportedContentTypeInterceptor.dart';
import 'package:Q/src/interceptor/UnSupportedMethodInterceptor.dart';
import 'package:Q/src/resolver/ApplicationJsonResolver.dart';
import 'package:Q/src/resolver/DefaultRequestResolver.dart';
import 'package:Q/src/resolver/MultipartFormDataResolver.dart';
import 'package:Q/src/resolver/ResolverType.dart';
import 'package:Q/src/resolver/X3WFormUrlEncodedResolver.dart';

abstract class ApplicationInitializer {
  Application get application;

  init();

  createApplicationContext();

  factory ApplicationInitializer(Application application) => _ApplicationInitializer(application);
}

class _ApplicationInitializer implements ApplicationInitializer {
  final Application _application;

  _ApplicationInitializer(this._application);

  @override
  Application get application {
    return this._application;
  }

  @override
  init() {
    this.createApplicationContext();
    this.initHandlers();
    this.initConverters();
    this.initInterceptors();
    this.initResolvers();
  }

  // 初始化默认处理器
  initHandlers() {
    this.application.addHandler(HttpStatus.notFound, NotFoundHandler.getInstance());
    this.application.addHandler(HttpStatus.ok, OKHandler.getInstance());
  }

  // 初始化转换器
  initConverters() {
    this.application.addConverter(ContentType.json, JSONHttpMessageConverter.getInstance());
    this.application.addConverter(ContentType.text, StringHttpMessageConverter.getInstance());
    this.application.addConverter(ContentType.html, StringHttpMessageConverter.getInstance());
  }

  // 内置拦截器初始化
  initInterceptors() {
    this.application.httpRequestInterceptorChain = HttpRequestInterceptorChain(
        [I18nInterceptor.getInstance(), UnSupportedContentTypeInterceptor.getInstance(), UnSupportedMethodInterceptor.getInstance()]);
  }

  // 初始化内置解析器
  initResolvers() {
    this.application.addResolver(ResolverType.MULTIPART, MultipartResolver.getInstance());
    this.application.addResolver(ResolverType.JSON, JsonResolver.getInstance());
    this.application.addResolver(ResolverType.FORM_URLENCODED, X3WFormUrlEncodedResolver.getInstance());
    this.application.addResolver(ResolverType.DEFAULT, DefaultRequestResolver.getInstance());
  }

  @override
  createApplicationContext() {
    this.application.applicationContext = ApplicationContext(this.application);
  }
}
