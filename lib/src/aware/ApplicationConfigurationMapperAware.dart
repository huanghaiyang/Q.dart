abstract class ApplicationConfigurationMapperAware<R, S, T> {
  Future<T> init();

  R get nodes;

  S get values;

  bool get isParsed;

  dynamic get(String key);
}
