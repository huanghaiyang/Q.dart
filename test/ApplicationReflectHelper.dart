import 'package:Q/Q.dart';
import 'package:test/test.dart';

void main() {
  group('ApplicationReflectHelper', () {
    Application application;
    setUp(() {
      application = Application();
    });

    test('ApplicationReflectHelper', () {
      ApplicationRouteDelegate applicationRouteDelegate = ApplicationRouteDelegate(application);
      AbstractDelegate abstractDelegate = ApplicationReflectHelper.getDelegate(ApplicationRouteDelegate, [
        ApplicationClosableDelegate(application),
        ApplicationLifecycleDelegate(application),
        ApplicationResourceDelegate(application),
        ApplicationSimplifyRouteDelegate(application),
        HttpRequestLifecycleDelegate(application),
        applicationRouteDelegate
      ]);
      expect(abstractDelegate, applicationRouteDelegate);
    });
  });
}
