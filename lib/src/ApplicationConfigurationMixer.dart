import 'package:Q/src/ApplicationConfiguration.dart';
import 'package:Q/src/aware/ApplicationConfigurationMixerAware.dart';

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
  Future<ApplicationConfiguration> mix(List<ApplicationConfiguration> configurations) async {}
}
