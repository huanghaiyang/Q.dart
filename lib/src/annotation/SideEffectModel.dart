import 'dart:mirrors';

String SIDE_EFFECT_MODEL_NAME = "sideEffectModel";

typedef EffectFunction = InstanceMirror Function(InstanceMirror transformedReflectee);

@pragma('vm:entry-point')
class SideEffectModel {
  final Function func;

  final List<EffectFunction> effects;

  @pragma('vm:entry-point')
  const SideEffectModel(this.func, {this.effects});
}
