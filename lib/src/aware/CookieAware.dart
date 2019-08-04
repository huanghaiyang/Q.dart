abstract class CookieAware<T> {
  T getCookie(String name);

  Iterable<T> getCookiesBy(String domain);

  bool hasCookie(String name);

  List<T> get cookies;

  List<String> get cookieNames;
}
