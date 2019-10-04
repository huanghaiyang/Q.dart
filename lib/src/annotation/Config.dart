String CONFIG_NAME = "config";

@pragma('vm:entry-point')
class Config {
  final String name;

  @pragma('vm:entry-point')
  const Config(this.name);
}
