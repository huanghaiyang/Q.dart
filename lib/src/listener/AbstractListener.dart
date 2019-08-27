abstract class AbstractListener<T> {
  Future<dynamic> execute(T payload);
}
