import 'dart:io';
import 'dart:mirrors';

import 'package:Q/src/Router.dart';
import 'package:Q/src/annotation/RequestParam.dart';
import 'package:Q/src/helpers/ReflectHelper.dart';
import 'package:Q/src/multipart/MultipartValueMap.dart';
import 'package:Q/src/query/CommonValue.dart';
import 'package:Q/src/query/MultipartFile.dart';

class RequestParamHelper {
  // 通过反射获取使用RequestParam注解的参数
  static dynamic reflectRequestParam(Router router, ParameterMirror parameterMirror, InstanceMirror annotationMirror) {
    if (annotationMirror != null) {
      String name = annotationMirror.getField(Symbol(PARAM_NAME)).reflectee;
      if (name == null) return null;
      Map data = router?.context?.request?.data;
      if (data == null) return null;
      // 参数类型
      Type parameterType = parameterMirror.type.reflectedType;
      // multipart/form-data类型
      if (data is MultipartValueMap) {
        List values = data.get(name);
        // 值类型
        Type valueType = ReflectHelper.reflectSubType(reflect(values).type.reflectedType);
        if (reflectClass(valueType) == reflectClass(CommonValue)) {
          return ReflectHelper.reflectParameterValues(parameterType, data.getValues(name));
        } else if (reflectClass(valueType) == reflectClass(MultipartFile)) {
          Type parameterSubType = ReflectHelper.reflectSubType(parameterType);
          bool isCollection;
          if (parameterSubType != null) {
            isCollection = true;
          } else {
            parameterSubType = parameterType;
            isCollection = false;
          }
          if (reflectClass(parameterSubType) == reflectClass(File)) {
            if (isCollection) {
              return data.getFiles(name);
            } else {
              return data.getFirstFile(name);
            }
          } else if (reflectClass(parameterSubType) == reflectClass(MultipartFile)) {
            if (isCollection) {
              return values;
            } else {
              return values.first;
            }
          }
        }
      } else {
        if (data.containsKey(name)) {
          return ReflectHelper.reflectParameterValues(parameterType, data[name]);
        }
      }
    }
  }
}
