import 'package:Q/Q.dart';
import 'package:test/test.dart';

void main() {
  group('size unit parse tests', () {
    test('verify all', () {
      SizeUnit unit = SizeUnit.parse('10kb');
      expect(unit.bytes, 80);
      expect(unit.type, SizeUnitType.KB);
      expect(unit.toString(), '10.0kb');
    });
  });
}
