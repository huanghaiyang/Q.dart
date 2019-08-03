String HEADER_NAME = "name";

@pragma('vm:entry-point')
class RequestHeader {
  final String name;

  @pragma('vm:entry-point')
  const RequestHeader(this.name);
}
