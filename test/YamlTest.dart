import 'dart:io';

import 'package:Q/Q.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('yaml tests', () {
    test('decode yaml contents to map', () async {
      Map map = YamlUtil.convertDocumentToMap(
          loadYamlDocument(await File('${Directory.current.path}/test/example/resources/application-dev.yml').readAsString()));
      // map has application key
      expect(map['security'], isNotNull);
    });
  });
}
