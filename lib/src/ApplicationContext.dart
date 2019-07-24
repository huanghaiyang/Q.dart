import 'package:Q/src/Configuration.dart';

abstract class ApplicationContext {
  Configuration get configuration;

  factory ApplicationContext() => _ApplicationContext();
}

class _ApplicationContext implements ApplicationContext {
  Configuration configuration_ = Configuration();

  _ApplicationContext();

  @override
  Configuration get configuration {
    return this.configuration_;
  }
}
