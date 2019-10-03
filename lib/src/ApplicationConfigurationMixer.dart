import 'package:Q/src/ApplicationConfiguration.dart';
import 'package:Q/src/aware/ApplicationConfigurationMixerAware.dart';
import 'package:Q/src/configure/ApplicationConfigurationMapper.dart';

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
  Future<ApplicationConfiguration> mix(List<ApplicationConfiguration> configurations,
      {ApplicationConfiguration defaultBootstrapConfiguration}) async {
    configurations.sort((prev, next) => prev.priority - next.priority);
    Map<String, dynamic> values = Map();
    if (defaultBootstrapConfiguration != null) {
      values.addAll(defaultBootstrapConfiguration.values);
    }
    for (ApplicationConfiguration configuration in configurations) {
      configuration.values.forEach((key, value) {
        values[key] = ApplicationConfigurationMapper.as(key, value);
      });
    }
    return ApplicationConfiguration(values, _FINAL_CONFIGURATION_PRIORITY);
  }
}
