import 'package:Q/Q.dart';
import 'package:test/test.dart';

void main() {
  group('value convert test', () {
    test('verify convert to string', () {
      expect(ValueConvertHelper.convertValueToString([1, 2, 3]), '1,2,3');
      expect(ValueConvertHelper.convertValueToString(2), '2');
      expect(ValueConvertHelper.convertValueToString('peter'), 'peter');
    });
  });
}
