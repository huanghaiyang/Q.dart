abstract class InterceptorRegistryAware<T> {
  void registryInterceptor(T interceptor);

  void registryInterceptors(Iterable<T> interceptors);
}
