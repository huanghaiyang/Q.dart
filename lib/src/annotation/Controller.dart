@pragma('vm:entry-point')
class Controller {
  final String value;

  const factory Controller(String value) = Controller._;

  const Controller._(this.value);
}
