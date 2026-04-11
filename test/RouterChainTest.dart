import 'package:Q/src/Router.dart';
import 'package:Q/src/Method.dart';
import 'package:Q/src/request/RouterChain.dart';
import 'package:Q/src/request/RouterState.dart';
import 'package:Q/src/exception/RouterNotFoundOfRouterChainException.dart';
import 'package:test/test.dart';

void main() {
  group('RouterChain', () {
    RouterChain routerChain;
    Router router1;
    Router router2;
    Router router3;

    setUp(() {
      routerChain = RouterChain();
      router1 = Router('/test1', HttpMethod.GET, (context, [request, response]) async => null);
      router2 = Router('/test2', HttpMethod.POST, (context, [request, response]) async => null);
      router3 = Router('/test3', HttpMethod.PUT, (context, [request, response]) async => null);
    });

    test('should add router using nextRouter', () {
      routerChain.nextRouter(router1);
      expect(routerChain.length, 1);
      expect(routerChain.getRouter(0), router1);
    });

    test('should add router using addRouter', () {
      routerChain.addRouter(router1);
      expect(routerChain.length, 1);
      expect(routerChain.getRouter(0), router1);
    });

    test('should add router at specific index', () {
      routerChain.addRouter(router1);
      routerChain.addRouter(router3);
      routerChain.addRouterAt(1, router2);
      expect(routerChain.length, 3);
      expect(routerChain.getRouter(0), router1);
      expect(routerChain.getRouter(1), router2);
      expect(routerChain.getRouter(2), router3);
    });

    test('should throw ArgumentError when adding router at invalid index', () {
      expect(() => routerChain.addRouterAt(-1, router1), throwsArgumentError);
      expect(() => routerChain.addRouterAt(1, router1), throwsArgumentError);
    });

    test('should remove router', () {
      routerChain.addRouter(router1);
      routerChain.addRouter(router2);
      routerChain.removeRouter(router1);
      expect(routerChain.length, 1);
      expect(routerChain.getRouter(0), router2);
    });

    test('should remove router at specific index', () {
      routerChain.addRouter(router1);
      routerChain.addRouter(router2);
      routerChain.addRouter(router3);
      routerChain.removeRouterAt(1);
      expect(routerChain.length, 2);
      expect(routerChain.getRouter(0), router1);
      expect(routerChain.getRouter(1), router3);
    });

    test('should throw RouterNotFoundOfRouterChainException when removing router at invalid index', () {
      expect(() => routerChain.removeRouterAt(0), throwsA(isA<RouterNotFoundOfRouterChainException>()));
      routerChain.addRouter(router1);
      expect(() => routerChain.removeRouterAt(1), throwsA(isA<RouterNotFoundOfRouterChainException>()));
    });

    test('should get router at specific index', () {
      routerChain.addRouter(router1);
      routerChain.addRouter(router2);
      expect(routerChain.getRouter(0), router1);
      expect(routerChain.getRouter(1), router2);
    });

    test('should throw RouterNotFoundOfRouterChainException when getting router at invalid index', () {
      expect(() => routerChain.getRouter(0), throwsA(isA<RouterNotFoundOfRouterChainException>()));
      routerChain.addRouter(router1);
      expect(() => routerChain.getRouter(1), throwsA(isA<RouterNotFoundOfRouterChainException>()));
    });

    test('should get all routers', () {
      routerChain.addRouter(router1);
      routerChain.addRouter(router2);
      List<Router> routers = routerChain.getRouters();
      expect(routers.length, 2);
      expect(routers[0], router1);
      expect(routers[1], router2);
    });

    test('should get current state', () {
      expect(routerChain.currentState, null);
      routerChain.addRouter(router1);
      expect(routerChain.currentState, isA<RouterState>());
    });

    test('should get state at specific index', () {
      expect(routerChain.getState(0), null);
      routerChain.addRouter(router1);
      expect(routerChain.getState(0), isA<RouterState>());
    });

    test('should throw RouterNotFoundOfRouterChainException when getting state at invalid index', () {
      routerChain.addRouter(router1);
      expect(() => routerChain.getState(1), throwsA(isA<RouterNotFoundOfRouterChainException>()));
    });

    test('should set and get next router chain', () {
      RouterChain nextChain = RouterChain();
      routerChain.next = nextChain;
      expect(routerChain.next, nextChain);
    });

    test('should check if has next router chain', () {
      expect(routerChain.hasNext(), false);
      RouterChain nextChain = RouterChain();
      routerChain.next = nextChain;
      expect(routerChain.hasNext(), true);
    });

    test('should build router chain', () {
      routerChain.addRouter(router1);
      RouterChain builtChain = routerChain.build();
      expect(builtChain, routerChain);
      expect(builtChain.length, 1);
    });

    test('should clear router chain', () {
      routerChain.addRouter(router1);
      RouterChain nextChain = RouterChain();
      routerChain.next = nextChain;
      routerChain.clear();
      expect(routerChain.length, 0);
      expect(routerChain.next, null);
    });

    test('should get length and index', () {
      expect(routerChain.length, 0);
      expect(routerChain.index, 0);
      routerChain.addRouter(router1);
      expect(routerChain.length, 1);
      expect(routerChain.index, 1);
    });

    tearDown(() {
      routerChain = null;
      router1 = null;
      router2 = null;
      router3 = null;
    });
  });
}
