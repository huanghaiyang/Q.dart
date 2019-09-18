abstract class ApplicationBootstrapArgsResolverAware<T, R, S> {
  Future<T> resolve();

  Future<S> define(R commandStructure);
}
