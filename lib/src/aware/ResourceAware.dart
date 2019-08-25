abstract class ResourceAware<R, T> {
  void resource(R pattern, T resource);

  Future<dynamic> flush(R pattern);
}
