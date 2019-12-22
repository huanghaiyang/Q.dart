import 'dart:mirrors';

import 'package:Q/Q.dart';
import 'package:Q/src/exception/RequiredAnnotationNotFoundException.dart';
import 'package:Q/src/exception/RequiredInitialValueMustBeProvidedException.dart';
import 'package:Q/src/utils/SymbolUtil.dart';
import 'package:curie/curie.dart';

class ClassTransformer {
  static final String FUNC_FIELD = 'func';

  static final String EFFECT_FIELDS = 'effects';

  static dynamic fromMap(Map data, Type clazz) async {
    ClassMirror classMirror = reflectClass(clazz);
    InstanceMirror instanceMirror = classMirror.newInstance(Symbol.empty, []);
    InstanceMirror sideEffectModelMirror = classMirror.metadata.firstWhere((InstanceMirror instanceMirror) {
      return instanceMirror.type == reflectClass(SideEffectModel);
    });
    if (sideEffectModelMirror != null) {
      InstanceMirror func = sideEffectModelMirror.getField(Symbol(FUNC_FIELD));
      if (func != null) {
        FunctionTypeMirror functionTypeMirror = func.type;
        List<Future> futures = List();
        functionTypeMirror.parameters.forEach((ParameterMirror parameterMirror) {
          futures.add(() async {
            instanceMirror.setField(parameterMirror.simpleName, await reflectParameterValue(data, parameterMirror, instanceMirror));
            return true;
          }());
        });
        await Future.wait(futures);
      } else {
        throw RequiredFieldNotFoundException(name: FUNC_FIELD);
      }
      InstanceMirror effectsMirror = sideEffectModelMirror.getField(Symbol(EFFECT_FIELDS));
      if (effectsMirror != null) {
        List<EffectFunction> effects = effectsMirror.reflectee;
        if (effects != null) {
          effects = List.from(effects);
          if (effects != null) {
            if (effects.isNotEmpty) {
              EffectFunction firstEffect = effects[0];
              effects[0] = (dynamic value) {
                InstanceMirror effectResult = Function.apply(firstEffect, [instanceMirror]);
                return effectResult;
              };
              InstanceMirror result = await waterfall(effects);
              return result.reflectee;
            }
          }
        }
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

  static dynamic reflectParameterValue(Map data, ParameterMirror parameterMirror, InstanceMirror instanceMirror) async {
    if (!instanceMirror.type.declarations.containsKey(parameterMirror.simpleName)) {
      throw SideEffectModelReflectFunctionParameterNotMatchClassFieldException(name: SymbolUtil.toChars(parameterMirror.simpleName));
    }
    await for (String key in Stream.fromIterable(List.from(data.keys))) {
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
              List<Future> futures = List();
              List.from(value).forEach((dynamic val) async {
                futures.add(() async {
                  return await fromMap(val, subType);
                }());
              });
              initialValue.addAll(await Future.wait(futures));
              return initialValue;
            } else if (parameterClassMirror == reflectClass(Set)) {
              List<Future> futures = List();
              Set.from(value).forEach((dynamic val) async {
                futures.add(() async {
                  return await fromMap(val, subType);
                }());
              });
              initialValue.addAll(await Future.wait(futures));
            }
          } else {
            return ReflectHelper.reflectCollection(parameterMirror.type.reflectedType, subType, value);
          }
        }
        if (hasModel(parameterMirror.type.reflectedType)) {
          return await fromMap(value, reflectClass(SideEffectModel).reflectedType);
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
