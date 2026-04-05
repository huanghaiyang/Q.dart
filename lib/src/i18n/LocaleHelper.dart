import 'dart:io';
import 'dart:mirrors';
import 'package:Q/src/Context.dart';
import 'package:Q/src/i18n/I18nManager.dart';
import 'package:Q/src/i18n/annotations/Locale.dart';

class LocaleHelper {
  static Future<dynamic> reflectLocale(Context context, HttpRequest request, HttpResponse response) async {
    return I18nManager().getLocaleFromRequest(request);
  }

  static Future<dynamic> reflectLocaleParameter(Context context, ParameterMirror parameterMirror, InstanceMirror instanceMirror) async {
    // 检查是否有Locale注解
    bool hasLocaleAnnotation = false;
    for (InstanceMirror annotation in parameterMirror.metadata) {
      if (annotation.type == reflectClass(Locale)) {
        hasLocaleAnnotation = true;
        break;
      }
    }

    if (!hasLocaleAnnotation) {
      return null;
    }

    // 获取当前语言设置
    return I18nManager().getLocaleFromRequest(context.request.req);
  }
}
