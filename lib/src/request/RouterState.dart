import 'package:Q/src/request/RouterStage.dart';

abstract class RouterState {
  RouterStage get stage;

  set stage(RouterStage stage);

  bool get matched;

  set matched(bool matched);

  DateTime get matchTime;

  set matchTime(DateTime matchTime);

  String get matchedRouterName;

  set matchedRouterName(String matchedRouterName);

  bool get fromCache;

  set fromCache(bool fromCache);

  Map<String, String> get pathParameters;

  set pathParameters(Map<String, String> pathParameters);

  factory RouterState() => _RouterState();
}

class _RouterState implements RouterState {
  RouterStage _stage;
  bool _matched = false;
  DateTime _matchTime;
  String _matchedRouterName;
  bool _fromCache = false;
  Map<String, String> _pathParameters = {};

  _RouterState();

  @override
  RouterStage get stage {
    return this._stage;
  }

  @override
  set stage(RouterStage stage) {
    this._stage = stage;
  }

  @override
  bool get matched {
    return this._matched;
  }

  @override
  set matched(bool matched) {
    this._matched = matched;
  }

  @override
  DateTime get matchTime {
    return this._matchTime;
  }

  @override
  set matchTime(DateTime matchTime) {
    this._matchTime = matchTime;
  }

  @override
  String get matchedRouterName {
    return this._matchedRouterName;
  }

  @override
  set matchedRouterName(String matchedRouterName) {
    this._matchedRouterName = matchedRouterName;
  }

  @override
  bool get fromCache {
    return this._fromCache;
  }

  @override
  set fromCache(bool fromCache) {
    this._fromCache = fromCache;
  }

  @override
  Map<String, String> get pathParameters {
    return this._pathParameters;
  }

  @override
  set pathParameters(Map<String, String> pathParameters) {
    this._pathParameters = pathParameters;
  }
}
