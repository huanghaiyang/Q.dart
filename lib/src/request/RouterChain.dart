import 'package:Q/src/Router.dart';
import 'package:Q/src/exception/RouterNotFoundOfRouterChainException.dart';
import 'package:Q/src/request/RouterState.dart';

abstract class RouterChain {
  void nextRouter(Router next);

  int get length;

  int get index;

  RouterState get currentState;

  RouterState getState(int index);

  RouterChain get next;

  set next(RouterChain next);

  factory RouterChain() => _RouterChain();
}

class _RouterChain implements RouterChain {
  List<Router> routers = List();

  RouterChain next_;

  _RouterChain();

  @override
  void nextRouter(Router next) {
    this.routers.add(next);
  }

  @override
  int get length {
    return routers.length;
  }

  @override
  RouterState get currentState {
    if (this.routers.isEmpty) {
      return null;
    }
    return this.routers[length - 1].state;
  }

  @override
  RouterState getState(int index) {
    if (this.routers.isEmpty) {
      return null;
    }
    if (index > this.length - 1) {
      throw RouterNotFoundOfRouterChainException(index: index);
    }
    return this.routers[index].state;
  }

  @override
  RouterChain get next {
    return this.next_;
  }

  @override
  set next(RouterChain next) {
    this.next_ = next;
  }

  @override
  int get index {
    return this.length;
  }
}
