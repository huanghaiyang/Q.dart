class ApplicationConfigurationTree {
  ApplicationConfigurationTree._();

  static ApplicationConfigurationTree _instance;

  static ApplicationConfigurationTree instance() {
    if (_instance == null) {
      _instance = ApplicationConfigurationTree._();
    }
    return _instance;
  }

  Map tree = Map.unmodifiable({
    'application': {
      'environment': 'dev',
      'configuration': {
        'interceptor': {
          'timeout',
        }
      }
    }
  });
}
