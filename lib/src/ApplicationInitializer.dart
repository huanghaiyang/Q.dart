import 'dart:io';

import 'package:Q/Q.dart';
import 'package:Q/src/Application.dart';
import 'package:Q/src/ApplicationBootstrapArgsResolver.dart';
import 'package:Q/src/ApplicationConfiguration.dart';
import 'package:Q/src/ApplicationConfigurationLoader.dart';
import 'package:Q/src/ApplicationConfigurationMixer.dart';
import 'package:Q/src/ApplicationConfigurationResourceResolver.dart';
import 'package:Q/src/ApplicationConfigurationResourceValidator.dart';
import 'package:Q/src/ApplicationContext.dart';
import 'package:Q/src/ApplicationEnvironment.dart';
import 'package:Q/src/ApplicationEnvironmentResolver.dart';
import 'package:Q/src/configure/ApplicationConfigurationMapper.dart';
import 'package:Q/src/converter/JSONHttpMessageConverter.dart';
import 'package:Q/src/converter/StringHttpMessageConverter.dart';
import 'package:Q/src/handler/NotFoundHandler.dart';
import 'package:Q/src/handler/OKHandler.dart';
import 'package:Q/src/interceptor/HttpRequestInterceptorChain.dart';
import 'package:Q/src/interceptor/I18nInterceptor.dart';
import 'package:Q/src/interceptor/UnSupportedContentTypeInterceptor.dart';
import 'package:Q/src/interceptor/UnSupportedMethodInterceptor.dart';
import 'package:Q/src/interceptor/CorsInterceptor.dart';
import 'package:Q/src/interceptor/HttpPrefetchInterceptor.dart';
import 'package:Q/src/security/csrf/CsrfInterceptor.dart';
import 'package:Q/src/security/xss/XssInterceptor.dart';
import 'package:Q/src/resolver/ApplicationJsonResolver.dart';
import 'package:Q/src/resolver/DefaultRequestResolver.dart';
import 'package:Q/src/resolver/FormDataResolver.dart';
import 'package:Q/src/resolver/MultipartFormDataResolver.dart';
import 'package:Q/src/resolver/ResolverType.dart';
import 'package:Q/src/resolver/X3WFormUrlEncodedResolver.dart';
import 'package:Q/src/resource/ApplicationConfigurationResource.dart';

abstract class ApplicationInitializer {
  Application get application;

  Future<void> init();

  ApplicationContext createApplicationContext();

  factory ApplicationInitializer(Application application) => _ApplicationInitializer(application);
}

class _ApplicationInitializer implements ApplicationInitializer {
  final Application _application;

  final ApplicationBootstrapArgsResolver applicationBootstrapArgsResolver = ApplicationBootstrapArgsResolver.instance();

  final ApplicationEnvironmentResolver applicationEnvironmentResolver = ApplicationEnvironmentResolver.instance();

  final ApplicationConfigurationResourceResolver applicationConfigurationResourceResolver =
      ApplicationConfigurationResourceResolver.instance();

  final ApplicationConfigurationLoader applicationConfigurationLoader = ApplicationConfigurationLoader.instance();

  final ApplicationConfigurationMixer applicationConfigurationMixer = ApplicationConfigurationMixer.instance();

  final ApplicationConfigurationResourceValidator applicationConfigurationResourceValidator =
      ApplicationConfigurationResourceValidator.instance();

  final ApplicationConfigurationMapper applicationConfigurationMapper = ApplicationConfigurationMapper.instance();

  _ApplicationInitializer(this._application);

  @override
  Application get application {
    return this._application;
  }

  @override
  Future<void> init() async {
    try {
      // 应用启动前
      this.application.trigger(ApplicationListenerType.STARTING, []);

      this.createApplicationContext();
      // 应用上下文初始化完成
      this.application.trigger(ApplicationListenerType.CONTEXT_INITIALIZED, []);

      ApplicationConfiguration defaultBootstrapConfiguration = await applicationConfigurationMapper.init();
      Map<String, dynamic> bootstrapArguments = await this.applicationBootstrapArgsResolver.resolve(this.application);
      ApplicationEnvironment environment = await this.applicationEnvironmentResolver.resolve(bootstrapArguments);
      // 环境准备完成
      this.application.trigger(ApplicationListenerType.ENVIRONMENT_PREPARED, [environment]);

      List<ApplicationConfigurationResource> resources = await this.applicationConfigurationResourceResolver.resolve(environment);
      await this.applicationConfigurationResourceValidator.check(resources);
      List<ApplicationConfiguration> configurations = await this.applicationConfigurationLoader.load(resources);
      ApplicationConfiguration configuration = 
          await this.applicationConfigurationMixer.mix(configurations, defaultBootstrapConfiguration: defaultBootstrapConfiguration);
      await this.initConfiguration(configuration);

      this.initHandlers();
      this.initConverters();
      this.initInterceptors();
      this.initResolvers();

      // 应用准备完成
      this.application.trigger(ApplicationListenerType.PREPARED, []);
      // 应用启动完成
      this.application.trigger(ApplicationListenerType.STARTUP, []);
      // 应用准备就绪
      this.application.trigger(ApplicationListenerType.READY, []);
    } catch (e, stackTrace) {
      // 应用启动失败
      this.application.trigger(ApplicationListenerType.FAILED, [e, stackTrace]);
      rethrow;
    }
  }

  // 初始化默认处理器
  initHandlers() {
    this.application.addHandler(HttpStatus.notFound, NotFoundHandler.instance());
    this.application.addHandler(HttpStatus.ok, OKHandler.instance());
  }

  // 初始化转换器
  initConverters() {
    this.application.addConverter(ContentType.json, JSONHttpMessageConverter.instance());
    this.application.addConverter(ContentType.text, StringHttpMessageConverter.instance());
    this.application.addConverter(ContentType.html, StringHttpMessageConverter.instance());
  }

  // 内置拦截器初始化
  initInterceptors() {
    final config = this.application.applicationContext.configuration.securityConfigure;
    final csrf = config.csrfConfigure;
    final xss = config.xssConfigure;
    final headers = config.securityHeadersConfigure;

    // 打印调试信息
    print('CSRF enabled: ${csrf.enabled}');
    print('CSRF protected methods: ${csrf.protectedMethods}');
    print('CSRF token max age: ${csrf.tokenMaxAge}');
    print('Cookie secure: ${config.httpsConfigure.enabled}');
    print('XSS enabled: ${xss.enabled}');
    print('XSS block request: ${xss.blockRequest}');
    print('XSS protected content types: ${xss.protectedContentTypes}');

    // 构建安全头部配置
    final securityHeaders = <String, String>{};
    if (headers != null && headers.enabled) {
      if (headers.xssProtection) {
        securityHeaders['X-XSS-Protection'] = '1; mode=block';
      }
      if (headers.contentTypeOptions) {
        securityHeaders['X-Content-Type-Options'] = 'nosniff';
      }
      if (headers.frameOptions) {
        securityHeaders['X-Frame-Options'] = 'DENY';
      }
      if (headers.contentSecurityPolicy) {
        securityHeaders['Content-Security-Policy'] = headers.contentSecurityPolicyValue ?? "default-src 'self'";
      }
    }

    this.application.httpRequestInterceptorChain = HttpRequestInterceptorChain([
      CorsInterceptor.instance(),
      I18nInterceptor.instance(),
      XssInterceptor.instance(
        enabled: xss.enabled,
        blockRequest: xss.blockRequest,
        protectedContentTypes: xss.protectedContentTypes,
        securityHeaders: securityHeaders
      ),
      CsrfInterceptor.instance(
        enabled: csrf.enabled,
        protectedMethods: csrf.protectedMethods,
        tokenMaxAge: csrf.tokenMaxAge,
        cookieSecure: config.httpsConfigure.enabled
      ),
      UnSupportedContentTypeInterceptor.instance(),
      UnSupportedMethodInterceptor.instance(),
      HttpPrefetchInterceptor.instance()
    ]);
  }

  // 初始化内置解析器
  initResolvers() {
    this.application.addResolver(ResolverType.MULTIPART, MultipartResolver.instance());
    this.application.addResolver(ResolverType.JSON, JsonResolver.instance());
    this.application.addResolver(ResolverType.FORM_URLENCODED, X3WFormUrlEncodedResolver.instance());
    this.application.addResolver(ResolverType.FORM_DATA, FormDataResolver.instance());
    this.application.addResolver(ResolverType.TEXT, TextResolver.instance());
    this.application.addResolver(ResolverType.XML, XmlResolver.instance());
    this.application.addResolver(ResolverType.DEFAULT, DefaultRequestResolver.instance());
  }

  @override
  createApplicationContext() {
    ApplicationContext applicationContext = ApplicationContext(this.application);
    this.application.applicationContext = applicationContext;
    return applicationContext;
  }

  Future<dynamic> initConfiguration(ApplicationConfiguration applicationConfiguration) async {
    return this.application.applicationContext.configuration.init(applicationConfiguration);
  }
}
