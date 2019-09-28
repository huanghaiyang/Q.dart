import 'package:Q/Q.dart';
import 'package:test/test.dart';

void main() {
  group('custom yaml parse tests', () {
    test('verify parsed value', () {
      const String value = 'peter,park <array<string>>';
      expect(CustomYamlPaserHelper.parseDefaultValues(value), ['peter', 'park']);
      expect(CustomYamlPaserHelper.parseValueTypes(value).toString(), MapEntry<String, String>('array', 'string').toString());
      expect(CustomYamlPaserHelper.parseValueTypes('peter <string>').key, 'string');
    });
    test('verify parsed custom yaml node', () async {
      CustomYamlPaser yamlPaser = CustomYamlPaser('name: peter, park <array<string>>');
      List<CustomYamlNode> nodes = await yamlPaser.parse();
      for (CustomYamlNode node in nodes) {
        expect(node.name, 'name');
        expect(node.type, 'array');
        expect(node.subType, 'string');
        expect(node.defaultValues, ['peter', 'park']);
      }
    });
  });
}
