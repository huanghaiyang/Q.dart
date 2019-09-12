import 'package:Q/src/request/RouterStage.dart';

abstract class RouterState {
  RouterStage get stage;

  set stage(RouterStage stage);

  factory RouterState() => _RouterState();
}

class _RouterState implements RouterState {
  RouterStage _stage;

  _RouterState();

  @override
  RouterStage get stage {
    return this._stage;
  }

  @override
  set stage(RouterStage stage) {
    this._stage = stage;
  }
}
