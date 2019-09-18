abstract class ApplicationBootstrapArgsResolverAware<T, R, S> {
  Future<T> resolve();

  Future<S> define(S argParser, R commandStructure);
}
