import 'package:Q/Q.dart';
import 'package:test/test.dart';

void main() {
  group('ResourceHelper tests', () {
    test('verify resource directory path', () {
      expect(ResourceHelper.findResourceDirectory().indexOf(RegExp('Q.dart\\/lib\\/resources')) > 0, true);
    });
  });
}
