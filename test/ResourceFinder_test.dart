import 'package:Q/Q.dart';
import 'package:test/test.dart';

void main() {
  group('search application configuration resources tests', () {
    test('verify resource files path', () async {
      Map<String, String> paths =
          await ApplicationConfigurationResourceFinder().search(ResourceFileTypes.YML, ApplicationEnvironment("dev", true));
      for (String value in ['application.yml', 'application-dev.yml']) {
        expect(paths.keys.contains(value), true);
      }
    });
  });
}
