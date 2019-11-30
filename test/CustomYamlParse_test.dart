import 'package:Q/Q.dart';
import 'package:test/test.dart';

void main() {
  group('custom yaml parse tests', () {
    test('verify parsed value', () {
      const String value = 'peter,park <array<string>>';
      expect(CustomYamlParserHelper.parseDefaultValues(value), ['peter', 'park']);
      expect(CustomYamlParserHelper.parseValueTypes(value).toString(), MapEntry<String, String>('array', 'string').toString());
      expect(CustomYamlParserHelper.parseValueTypes('peter <string>').key, 'string');
    });
    test('verify parsed custom yaml node', () async {
      CustomYamlParser yamlParser = CustomYamlParser('name: peter, park <array<string>>');
      List<CustomYamlNode> nodes = await yamlParser.parse();
      for (CustomYamlNode node in nodes) {
        expect(node.name, 'name');
        expect(node.type, 'array');
        expect(node.subType, 'string');
        expect(node.defaultValues, ['peter', 'park']);
      }
    });
  });
}
