import 'package:Q/src/Application.dart';
import 'package:Q/src/Configuration.dart';
import 'package:Q/src/aware/BindApplicationAware.dart';

abstract class ApplicationContext extends BindApplicationAware<Application> {
  Configuration get configuration;

  String get applicationName;

  String get displayName;

  DateTime get startTime;

  set applicationName(String applicationName);

  set displayName(String displayName);

  factory ApplicationContext(Application application) => _ApplicationContext(application);
}

class _ApplicationContext implements ApplicationContext {
  Configuration configuration_ = Configuration();

  String applicationName_;

  String displayName_;

  DateTime startTime_ = DateTime.now();

  Application _application;

  _ApplicationContext(this._application);

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

  @override
  set app(Application application) {
    this._application = application;
  }

  @override
  Application get app {
    return this._application;
  }
}
