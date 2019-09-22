import 'package:Q/src/ApplicationConfiguration.dart';
import 'package:Q/src/aware/ApplicationConfigurationMixerAware.dart';

const _FINAL_CONFIGURATION_PRIORITY = 99;

class ApplicationConfigurationMixer
    implements ApplicationConfigurationMixerAware<List<ApplicationConfiguration>, ApplicationConfiguration> {
  ApplicationConfigurationMixer._();

  static ApplicationConfigurationMixer _instance;

  static ApplicationConfigurationMixer instance() {
    if (_instance == null) {
      _instance = ApplicationConfigurationMixer._();
    }
    return _instance;
  }

  @override
  Future<ApplicationConfiguration> mix(List<ApplicationConfiguration> configurations) async {
    configurations.sort((prev, next) => prev.priority - next.priority);
    Map<String, dynamic> values = Map();
    for (ApplicationConfiguration configuration in configurations) {
      values.addAll(configuration.values);
    }
    return ApplicationConfiguration(values, _FINAL_CONFIGURATION_PRIORITY);
  }
}
