import 'package:Q/src/Application.dart';

abstract class AbstractDelegate {
  factory AbstractDelegate.from(Application application) => _AbstractDelegate.from(application);
}

class _AbstractDelegate implements AbstractDelegate {
  factory _AbstractDelegate.from(Application application) => null;
}
