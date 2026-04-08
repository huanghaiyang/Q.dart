import 'dart:mirrors';

import 'package:Q/Q.dart';
import 'package:test/test.dart';

void main() {
  group('ReflectHelper', () {
    void handler(@PathVariable('id') int ID) {}

    setUp(() {});

    test('reflect function annatation parameter', () {
      ReflectHelper.reflectParamAnnotation(handler, PathVariable, (ParameterMirror parameterMirror, InstanceMirror annotationMirror) {
        expect(parameterMirror.simpleName, 'ID');
        expect(annotationMirror.getField(Symbol(PATH_VARIABLE_NAME)).reflectee, 'id');
      });
    });
  });
}
