abstract class ApplicationConfigurationMapperAware<R, S, T, W> {
  Future<T> init();

  R get nodes;

  S get values;

  bool get isParsed;

  W convertAs(String key, String value);
}
