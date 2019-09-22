abstract class ApplicationConfigurationResourceResolverAware<T, R> {
  Future<R> resolve(T environment);
}
