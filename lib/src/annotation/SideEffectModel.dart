String SIDE_EFFECT_MODEL_NAME = "sideEffectModel";

@pragma('vm:entry-point')
class SideEffectModel {
  final Function func;

  @pragma('vm:entry-point')
  const SideEffectModel(this.func);
}
