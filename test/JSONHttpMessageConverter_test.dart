import 'package:Q/Q.dart';
import 'package:test/test.dart';

void main() {
  group('JSONHttpMessageConverter', () {
    JSONHttpMessageConverter jsonHttpMessageConverter;

    setUp(() {
      jsonHttpMessageConverter = JSONHttpMessageConverter.getInstance();
    });

    test('JSONHttpMessageConverter单例模式', () {
      expect(jsonHttpMessageConverter, JSONHttpMessageConverter.getInstance());
    });

    test('JSONHttpMessageConverter转换数据', () async {
      expect(await JSONHttpMessageConverter.getInstance().convert(1), '1');
      expect(await JSONHttpMessageConverter.getInstance().convert({'name': 'Q'}), '{"name":"Q"}');
      expect(await JSONHttpMessageConverter.getInstance().convert(["name", "age"]), '["name","age"]');
    });
  });
}
