import 'package:Q/Q.dart';
import 'package:test/test.dart';

void main() {
  group('custom yaml parse tests', () {
    test('verify parsed value', () {
      const String value = '{peter}{park}<array<string>>';
      expect(CustomYamlPaserHelper.parseDefaultValues(value), ['peter', 'park']);
      expect(CustomYamlPaserHelper.parseValueTypes(value).toString(), MapEntry<String, String>('array', 'string').toString());
      expect(CustomYamlPaserHelper.parseValueTypes('{peter}<string>').key, 'string');
    });
  });
}
