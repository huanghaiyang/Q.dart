import 'dart:io';

import 'package:Q/Q.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('yaml tests', () {
    test('decode yaml contents to map', () async {
      Map map = YamlUtil.convertDocumentToMap(
          loadYamlDocument(await File('${Directory.current.path}/test/example/application.yml').readAsString()));
      expect(map, {
        'application': {
          'environment': 'dev',
          'configuration': {
            'interceptor': {'timeout': '20ms'}
          }
        }
      });
    });
  });
}
