String MODEL_NAME = "model";

@deprecated
@pragma('vm:entry-point')
class Model {
  final Map<String, Type> rules;

  @pragma('vm:entry-point')
  const Model(this.rules);
}
