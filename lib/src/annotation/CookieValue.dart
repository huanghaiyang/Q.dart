String COOKIE_NAME = "name";

@pragma('vm:entry-point')
class CookieValue {
  final String name;

  @pragma('vm:entry-point')
  const CookieValue(this.name);
}
