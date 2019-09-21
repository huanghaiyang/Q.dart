abstract class ApplicationConfigurationResourceFinderAware<T, R> {
  Future<R> search(T type);
}
