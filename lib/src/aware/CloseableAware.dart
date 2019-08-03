abstract class CloseableAware<T, F> {
  Future<dynamic> close();

  Future<dynamic> onClose(F f);
}
