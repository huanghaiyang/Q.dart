import 'package:Q/Q.dart';
import 'package:test/test.dart';

void main() {
  group('测试Application', () {
    Application application;

    setUp(() {
      application = Application();
    });

    test('Application单例模式', () {
      expect(application, Application());
    });
  });
}
