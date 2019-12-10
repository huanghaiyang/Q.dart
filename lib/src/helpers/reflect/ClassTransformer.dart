import 'dart:mirrors';

import 'package:Q/Q.dart';
import 'package:Q/src/utils/SymbolUtil.dart';

class ClassTransformer {
  static String MODEL_METHOD = '_model';

  // TODO reflect _.model method
  static dynamic fromMap(Map data, Type clazz) async {
    ClassMirror classMirror = reflectClass(clazz);
    Map<Symbol, DeclarationMirror> declarations = classMirror.declarations;
    Symbol MODEL_METHOD_SYMBOL = Symbol('${SymbolUtil.toChars(classMirror.simpleName)}.${MODEL_METHOD}');
    if (!declarations.keys.map((Symbol key) {
      return key.toString();
    }).contains(MODEL_METHOD_SYMBOL.toString())) {
      throw RequiredMethodNotFoundException(name: MODEL_METHOD_SYMBOL.toString());
    }
    // why method parameters is null
    MethodMirror modelMethodMirror;
    for (Symbol key in declarations.keys) {
      if (key.toString().endsWith(MODEL_METHOD_SYMBOL.toString())) {
        modelMethodMirror = declarations[key];
      }
    }
    List positionalArguments = List();
    InstanceMirror instanceMirror = classMirror.newInstance(MODEL_METHOD_SYMBOL, []);
    for (var key in data.keys) {
      dynamic value = data[key];
      ClassMirror valueMirror = reflect(value).type;
      Symbol fieldName = Symbol(key);
    }
    return instanceMirror.reflectee;
  }
}
