import 'dart:io';
import 'package:Q/src/i18n/I18nResourceBundle.dart';

class I18nManager {
  static final I18nManager _instance = I18nManager._();
  static const String LOCALE_COOKIE_NAME = 'locale';
  static const String LOCALE_HEADER_NAME = 'Accept-Language';
  static const String LOCALE_PARAM_NAME = 'locale';

  factory I18nManager() {
    return _instance;
  }

  I18nManager._() {
    I18nResourceBundle.init();
  }

  /// 从请求中获取语言设置
  String getLocaleFromRequest(HttpRequest request) {
    // 1. 从查询参数获取
    if (request.uri.queryParameters.containsKey(LOCALE_PARAM_NAME)) {
      String locale = request.uri.queryParameters[LOCALE_PARAM_NAME];
      if (_isValidLocale(locale)) {
        return locale;
      }
    }

    // 2. 从Cookie获取
    for (Cookie cookie in request.cookies) {
      if (cookie.name == LOCALE_COOKIE_NAME) {
        String locale = cookie.value;
        if (_isValidLocale(locale)) {
          return locale;
        }
      }
    }

    // 3. 从请求头获取
    try {
      if (request.headers != null && request.headers[LOCALE_HEADER_NAME] != null && request.headers[LOCALE_HEADER_NAME].isNotEmpty) {
        String acceptLanguage = request.headers[LOCALE_HEADER_NAME].first;
        List<String> locales = acceptLanguage.split(',');
        for (String locale in locales) {
          String cleanLocale = locale.split(';').first.trim();
          if (_isValidLocale(cleanLocale)) {
            return cleanLocale;
          }
        }
      }
    } catch (e) {
      // 忽略头信息解析错误
      print('Error parsing accept language header: $e');
    }

    // 4. 返回默认语言
    return I18nResourceBundle.getDefaultLocale();
  }

  /// 设置响应的语言Cookie
  void setLocaleCookie(HttpResponse response, String locale) {
    if (_isValidLocale(locale)) {
      Cookie cookie = Cookie(LOCALE_COOKIE_NAME, locale);
      cookie.path = '/';
      cookie.maxAge = 60 * 60 * 24 * 30; // 30天
      response.cookies.add(cookie);
    }
  }

  /// 验证语言代码是否有效
  bool _isValidLocale(String locale) {
    if (locale == null || locale.isEmpty) {
      return false;
    }
    // 简单验证：语言代码格式为xx或xx-XX
    RegExp regex = RegExp(r'^[a-z]{2}(-[A-Z]{2})?$');
    return regex.hasMatch(locale);
  }

  /// 获取国际化字符串
  String getMessage(String key, {String locale, Map<String, dynamic> params}) {
    return I18nResourceBundle.getString(key, locale: locale, params: params);
  }

  /// 设置默认语言
  void setDefaultLocale(String locale) {
    if (_isValidLocale(locale)) {
      I18nResourceBundle.setDefaultLocale(locale);
    }
  }

  /// 获取默认语言
  String getDefaultLocale() {
    return I18nResourceBundle.getDefaultLocale();
  }
}
