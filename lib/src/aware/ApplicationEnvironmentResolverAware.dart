abstract class ApplicationEnvironmentResolverAware<T> {
  Future<T> resolve();

  Future<T> get();
}
