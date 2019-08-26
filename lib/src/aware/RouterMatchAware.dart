abstract class RouterMatchAware<R, T> {
  Future<bool> match(R request);

  Future<bool> matchPath(String path);

  Future<bool> matchRedirect(T redirect);
}
