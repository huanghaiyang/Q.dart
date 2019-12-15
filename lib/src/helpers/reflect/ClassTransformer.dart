import 'dart:mirrors';

import 'package:Q/Q.dart';
import 'package:Q/src/exception/RequiredAnnotationNotFoundException.dart';
import 'package:Q/src/exception/RequiredInitialValueMustBeProvidedException.dart';
import 'package:Q/src/utils/SymbolUtil.dart';

class ClassTransformer {
  static final String FUNC_FIELD = 'func';

  static dynamic fromMap(Map data, Type clazz) {
    ClassMirror classMirror = reflectClass(clazz);
    InstanceMirror instanceMirror = classMirror.newInstance(Symbol.empty, []);
    InstanceMirror sideEffectModelMirror = classMirror.metadata.firstWhere((InstanceMirror instanceMirror) {
      return instanceMirror.type == reflectClass(SideEffectModel);
    });
    if (sideEffectModelMirror != null) {
      InstanceMirror func = sideEffectModelMirror.getField(Symbol(FUNC_FIELD));
      if (func != null) {
        FunctionTypeMirror functionTypeMirror = func.type;
        functionTypeMirror.parameters.forEach((ParameterMirror parameterMirror) {
          instanceMirror.setField(parameterMirror.simpleName, reflectParameterValue(data, parameterMirror, instanceMirror));
        });
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
      for (var key in data.keys) {
        if (rules.containsKey(key)) {
          dynamic value = data[key];
          instanceMirror.setField(Symbol(key), value);
        }
      }
    }
    return instanceMirror.reflectee;
  }

  static dynamic reflectParameterValue(Map data, ParameterMirror parameterMirror, InstanceMirror instanceMirror) {
    if (!instanceMirror.type.declarations.containsKey(parameterMirror.simpleName)) {
      throw SideEffectModelReflectFunctionParameterNotMatchClassFieldException(name: SymbolUtil.toChars(parameterMirror.simpleName));
    }
    for (String key in data.keys) {
      if (SymbolUtil.toChars(parameterMirror.simpleName) == key) {
        dynamic value = data[key];
        Type parameterType = parameterMirror.type.reflectedType;
        ClassMirror parameterClassMirror = reflectClass(parameterType);
        if (parameterClassMirror == reflectClass(List) || parameterClassMirror == reflectClass(Set)) {
          Type subType = ReflectHelper.getSubType(parameterType);
          if (hasModel(subType)) {
            dynamic initialValue = instanceMirror.getField(Symbol(key)).reflectee;
            if (initialValue == null) {
              throw RequiredInitialValueMustBeProvidedException(name: key);
            }
            if (parameterClassMirror == reflectClass(List)) {
              List.from(value).forEach((dynamic val) {
                initialValue.add(fromMap(val, subType));
              });
              return initialValue;
            } else if (parameterClassMirror == reflectClass(Set)) {
              Set.from(value).forEach((dynamic val) {
                initialValue.add(fromMap(val, subType));
              });
              return initialValue;
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
