import 'package:Q/Q.dart';
import 'package:test/test.dart';

void main() {
  group('time unit parse tests', () {
    test('verify all', () {
      TimeUnit timeUnit = TimeUnit(10, TimeUnitType.HOURS);
      expect(timeUnit.value, 10);
      expect(timeUnit.duration, Duration(hours: 10));
      expect(timeUnit.type, TimeUnitType.HOURS);
      expect(timeUnit.toString(), '10h');

      expect(TimeUnit.Hours(10).toString(), '10h');
      expect(TimeUnit.parse('10h').toString(), '10h');
      expect(TimeUnit.parse('10ms').toString(), '10ms');
    });
  });
}
