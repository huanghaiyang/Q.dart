import 'package:Q/Q.dart';
import 'package:test/test.dart';

void main() {
  group('JSONHttpMessageConverter', () {
    JSONHttpMessageConverter jsonHttpMessageConverter;

    setUp(() {
      jsonHttpMessageConverter = JSONHttpMessageConverter.instance();
    });

    test('JSONHttpMessageConverter单例模式', () {
      expect(jsonHttpMessageConverter, JSONHttpMessageConverter.instance());
    });

    test('JSONHttpMessageConverter转换数据', () async {
      expect(await JSONHttpMessageConverter.instance().convert(1), '1');
      expect(await JSONHttpMessageConverter.instance().convert({'name': 'Q'}), '{"name":"Q"}');
      expect(await JSONHttpMessageConverter.instance().convert(["name", "age"]), '["name","age"]');
    });

    tearDown(() {
      jsonHttpMessageConverter = null;
    });
  });
}
