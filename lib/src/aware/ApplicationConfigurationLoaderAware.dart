abstract class ApplicationConfigurationLoaderAware<T, R> {
  Future<R> load(T resources);
}
