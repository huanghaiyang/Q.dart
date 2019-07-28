import 'package:Q/src/Configuration.dart';

abstract class ApplicationContext {
  Configuration get configuration;

  String get applicationName;

  String get displayName;

  DateTime get startTime;

  set applicationName(String applicationName);

  set displayName(String displayName);

  factory ApplicationContext() => _ApplicationContext();
}

class _ApplicationContext implements ApplicationContext {
  Configuration configuration_ = Configuration();

  String applicationName_;

  String displayName_;

  DateTime startTime_ = DateTime.now();

  _ApplicationContext();

  @override
  Configuration get configuration {
    return this.configuration_;
  }

  @override
  DateTime get startTime {
    return this.startTime_;
  }

  @override
  String get displayName {
    return this.displayName_;
  }

  @override
  String get applicationName {
    return this.applicationName_;
  }

  @override
  set displayName(String displayName) {
    this.displayName_ = displayName;
  }

  @override
  set applicationName(String applicationName) {
    this.applicationName_ = applicationName;
  }
}
