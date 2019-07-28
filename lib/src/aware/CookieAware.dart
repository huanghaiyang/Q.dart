abstract class CookieAware<T> {
  T getBookie(String name);

  Iterable<T> getBookiesBy(String domain);

  bool hasCookie(String name);

  List<T> get cookies;

  List<String> get cookieNames;
}
