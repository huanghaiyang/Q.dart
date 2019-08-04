String SESSION_NAME = "name";

@pragma('vm:entry-point')
class SessionValue {
  final String name;

  @pragma('vm:entry-point')
  const SessionValue(this.name);
}
