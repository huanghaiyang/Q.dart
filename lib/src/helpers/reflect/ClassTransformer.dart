import 'dart:mirrors';

import 'package:Q/Q.dart';
import 'package:Q/src/exception/RequiredAnnotationNotFoundException.dart';
import 'package:Q/src/utils/SymbolUtil.dart';

class ClassTransformer {
  static dynamic fromMap(Map data, Type clazz) async {
    ClassMirror classMirror = reflectClass(clazz);
    InstanceMirror modelAnnotationMirror = classMirror.metadata.firstWhere((InstanceMirror instanceMirror) {
      return instanceMirror.type == reflectClass(Model);
    });
    if (modelAnnotationMirror == null) {
      throw RequiredAnnotationNotFoundException(name: SymbolUtil.toChars(reflectClass(Model).qualifiedName));
    }
    Model model = modelAnnotationMirror.reflectee;
    Map<String, Type> rules = model.rules;
    InstanceMirror instanceMirror = classMirror.newInstance(Symbol.empty, []);
    for (var key in data.keys) {
      if (rules.containsKey(key)) {
        dynamic value = data[key];
        ClassMirror valueMirror = reflect(value).type;
        Type ruleType = rules[key];
        instanceMirror.setField(Symbol(key), value);
      }
    }
    return instanceMirror.reflectee;
  }
}
