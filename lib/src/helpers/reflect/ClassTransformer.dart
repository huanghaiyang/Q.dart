import 'dart:mirrors';

import 'package:Q/Q.dart';
import 'package:Q/src/exception/RequiredAnnotationNotFoundException.dart';
import 'package:Q/src/utils/SymbolUtil.dart';

class ClassTransformer {
  static final String FUNC_FIELD = 'func';

  static dynamic fromMap(Map data, Type clazz) {
    ClassMirror classMirror = reflectClass(clazz);
    InstanceMirror sideEffectModelMirror = classMirror.metadata.firstWhere((InstanceMirror instanceMirror) {
      return instanceMirror.type == reflectClass(SideEffectModel);
    });
    if (sideEffectModelMirror != null) {
      InstanceMirror func = sideEffectModelMirror.getField(Symbol(FUNC_FIELD));
      if (func != null) {
        FunctionTypeMirror functionTypeMirror = func.type;
        List<ParameterMirror> positionalParameters = List.from(functionTypeMirror.parameters.where((ParameterMirror parameterMirror) {
          return !parameterMirror.isOptional && !parameterMirror.isNamed;
        }));
        List<ParameterMirror> namedParameters = List.from(functionTypeMirror.parameters.where((ParameterMirror parameterMirror) {
          return parameterMirror.isNamed;
        }));
        List positionalArguments = List.from(positionalParameters.map((ParameterMirror parameterMirror) {
          return reflectParameterValue(data, parameterMirror);
        }));
        Map namedArguments = Map();
        namedParameters.forEach((ParameterMirror parameterMirror) {
          namedArguments[parameterMirror.simpleName] = reflectParameterValue(data, parameterMirror);
        });
        return Function.apply(func.reflectee, positionalArguments, Map<Symbol, dynamic>.from(namedArguments));
      } else {
        throw RequiredFieldNotFoundException(name: FUNC_FIELD);
      }
    } else {
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

  static dynamic reflectParameterValue(Map data, ParameterMirror parameterMirror) {
    for (String key in data.keys) {
      if (SymbolUtil.toChars(parameterMirror.simpleName) == key) {
        dynamic value = data[key];
        Type parameterType = parameterMirror.type.reflectedType;
        ClassMirror parameterClassMirror = reflectClass(parameterType);
        if (parameterClassMirror == reflectClass(List) || parameterClassMirror == reflectClass(Set)) {
          Type subType = ReflectHelper.getSubType(parameterType);
          if (hasModel(subType)) {
            /**
             * TODO type 'List<dynamic>' is not a subtype of type 'List<Person>'
             *
             * fuck
             */
            if (parameterClassMirror == reflectClass(List)) {
              List collection = parameterClassMirror.newInstance(Symbol.empty, []).reflectee;
              List.from(value).forEach((dynamic val) {
                collection.add(fromMap(val, subType));
              });
              return collection;
            } else if (parameterClassMirror == reflectClass(Set)) {
              return Set.from(Set.from(value).map((dynamic val) {
                return fromMap(val, subType);
              }));
            }
          } else {
            return ReflectHelper.reflectCollection(parameterMirror.type.reflectedType, subType, value);
          }
        }
        if (hasModel(parameterMirror.type.reflectedType)) {
          return fromMap(value, reflectClass(SideEffectModel).reflectedType);
        }
        return ReflectHelper.reflectParameterValue(parameterType, value.toString());
      }
    }
  }

  static bool hasModel(Type type) {
    return reflectClass(type).metadata.map((InstanceMirror instanceMirror) {
      return instanceMirror.type;
    }).contains(reflectClass(SideEffectModel));
  }
}
