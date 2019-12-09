import 'dart:mirrors';

class ClassTransformer {
  // TODO reflect _.model method
  static dynamic fromMap(Map data, Type clazz) async {
    ClassMirror classMirror = reflectClass(clazz);
    Map<Symbol, DeclarationMirror> declarations = classMirror.declarations;
    InstanceMirror instanceMirror = classMirror.newInstance(Symbol.empty, []);
    for (var key in data.keys) {
      dynamic value = data[key];
      ClassMirror valueMirror = reflect(value).type;
      Symbol fieldName = Symbol(key);
      // check field name
      if (declarations.containsKey(fieldName)) {
        // check field type
        instanceMirror.setField(fieldName, value);
      }
    }
    return instanceMirror.reflectee;
  }
}
