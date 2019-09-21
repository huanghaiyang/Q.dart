abstract class ApplicationConfigurationMixerAware<T, R> {
  Future<R> mix(T configurations);
}
