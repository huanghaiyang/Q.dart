String PARAM_NAME = "name";

@pragma('vm:entry-point')
class RequestParam {
  final String name;

  @pragma('vm:entry-point')
  const RequestParam(this.name);
}
