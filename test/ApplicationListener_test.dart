import 'package:Q/Q.dart';
import 'package:test/test.dart';

void main() {
  group('ApplicationListener', () {
    Application application;

    setUp(() {
      application = Application()
        ..args(['--application.environment=dev'])
        ..init();
    });

    test('Application lifecycle listen', () async {
      int counter = 0;

      Future<int> count() async {
        counter++;
        return counter;
      }

      application.addListener(ApplicationStartUpListener(() async {
        await count();
      }));
      application.addListener(ApplicationStartUpListener(() async {
        await count();
      }));

      application.listen(8082);
      await Future.delayed(Duration(seconds: 1), () {
        expect(counter, 2);
      });

      application.addListener(ApplicationCloseListener((dynamic prevCloseableResult) async {
        dynamic result = await prevCloseableResult;
        print(result);
      }));

      await Future.delayed(Duration(seconds: 2), () {
        application.close();
      });

      await Future.delayed(Duration(seconds: 3), () {
        expect(application.applicationContext.currentStage, ApplicationStage.STOPPED);
      });
    });

    tearDown(() {
      application = null;
    });
  });
}
