import 'package:Q/src/Router.dart';
import 'package:Q/src/exception/RouterNotFoundOfRouterChainException.dart';
import 'package:Q/src/helpers/RouterHelper.dart';
import 'package:Q/src/request/RouterState.dart';

abstract class RouterChain {
  void nextRouter(Router next);
  
  void addRouter(Router router);
  
  void addRouterAt(int index, Router router);
  
  void removeRouter(Router router);
  
  void removeRouterAt(int index);
  
  Router getRouter(int index);
  
  List<Router> getRouters();

  int get length;

  int get index;

  RouterState get currentState;

  RouterState getState(int index);

  RouterChain get next;

  set next(RouterChain next);
  
  bool hasNext();
  
  RouterChain build();
  
  void clear();

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
  void addRouter(Router router) {
    // 验证路由的合法性
    if (router == null) {
      throw ArgumentError('Router cannot be null');
    }
    // 验证路由路径的合法性
    if (!RouterHelper.checkPathAvailable(router.path)) {
      throw ArgumentError('Invalid router path');
    }
    // 验证路由处理函数的合法性
    if (router.handle == null) {
      throw ArgumentError('Router handle cannot be null');
    }
    this.routers.add(router);
  }
  
  @override
  void addRouterAt(int index, Router router) {
    if (index < 0 || index > this.length) {
      throw ArgumentError('Index out of range');
    }
    // 验证路由的合法性
    if (router == null) {
      throw ArgumentError('Router cannot be null');
    }
    // 验证路由路径的合法性
    if (!RouterHelper.checkPathAvailable(router.path)) {
      throw ArgumentError('Invalid router path');
    }
    // 验证路由处理函数的合法性
    if (router.handle == null) {
      throw ArgumentError('Router handle cannot be null');
    }
    this.routers.insert(index, router);
  }
  
  @override
  void removeRouter(Router router) {
    this.routers.remove(router);
  }
  
  @override
  void removeRouterAt(int index) {
    if (index < 0 || index >= this.length) {
      throw RouterNotFoundOfRouterChainException(index: index);
    }
    this.routers.removeAt(index);
  }
  
  @override
  Router getRouter(int index) {
    if (index < 0 || index >= this.length) {
      throw RouterNotFoundOfRouterChainException(index: index);
    }
    return this.routers[index];
  }
  
  @override
  List<Router> getRouters() {
    return List.unmodifiable(this.routers);
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
    if (index < 0 || index >= this.length) {
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
  bool hasNext() {
    return this.next_ != null;
  }
  
  @override
  RouterChain build() {
    return this;
  }
  
  @override
  void clear() {
    this.routers.clear();
    this.next_ = null;
  }

  @override
  int get index {
    return this.length;
  }
}
