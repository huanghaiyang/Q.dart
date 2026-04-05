// 路由Trie树，用于高效存储和匹配路由
// 支持路径参数（如/users/:id）和通配符（如/users/*）
import 'dart:io';

import 'package:Q/src/Router.dart';
import 'package:Q/src/Method.dart';
import 'package:Q/src/helpers/HttpMethodHelper.dart';

class RouterTrieNode {
  final String pathSegment;
  final bool isParameter;
  final bool isWildcard;
  final Map<String, RouterTrieNode> children = {};
  final Map<HttpMethod, Router> routers = {};

  RouterTrieNode(this.pathSegment, {this.isParameter = false, this.isWildcard = false});

  /**
   * 计算路由优先级
   * 优先级规则：
   * 1. 精确匹配 > 路径参数 > 通配符
   * 2. 路径段越多优先级越高
   */
  int calculatePriority(String path) {
    List<String> segments = path.split('/').where((s) => s.isNotEmpty).toList();
    int priority = 0;
    
    for (String segment in segments) {
      if (segment == '*') {
        priority += 1;
      } else if (segment.startsWith(':')) {
        priority += 2;
      } else {
        priority += 3;
      }
    }
    
    // 路径段数量也影响优先级
    priority += segments.length * 10;
    
    return priority;
  }
}

class RouterTrie {
  final RouterTrieNode root = RouterTrieNode('');

  /**
   * 添加路由到Trie树
   */
  void addRouter(Router router) {
    List<String> segments = _splitPath(router.path);
    RouterTrieNode current = root;

    for (String segment in segments) {
      bool isParameter = segment.startsWith(':');
      bool isWildcard = segment == '*';
      String key = isParameter ? ':param' : isWildcard ? '*' : segment;

      if (!current.children.containsKey(key)) {
        current.children[key] = RouterTrieNode(segment, isParameter: isParameter, isWildcard: isWildcard);
      }
      current = current.children[key];
    }

    current.routers[router.method] = router;
  }

  /**
   * 匹配路由
   */
  Router matchRouter(HttpRequest request) {
    String path = request.uri.path;
    String method = request.method.toUpperCase();
    List<String> segments = _splitPath(path);

    List<Router> matches = [];
    _matchSegments(root, segments, 0, method, matches);

    // 确保只保留匹配HTTP方法的路由
    HttpMethod httpMethod = HttpMethodHelper.fromMethod(method);
    matches = matches.where((router) => router.method == httpMethod).toList();

    // 按优先级排序，选择优先级最高的路由
    if (matches.isNotEmpty) {
      matches.sort((a, b) {
        int priorityA = root.calculatePriority(a.path);
        int priorityB = root.calculatePriority(b.path);
        return priorityB.compareTo(priorityA); // 降序排列
      });
      return matches[0];
    }

    return null;
  }

  /**
   * 递归匹配路径段，收集所有可能的匹配
   */
  void _matchSegments(RouterTrieNode node, List<String> segments, int index, String method, List<Router> matches) {
    if (index == segments.length) {
      Router router = node.routers[HttpMethodHelper.fromMethod(method)];
      if (router != null) {
        matches.add(router);
      }
      return;
    }

    String currentSegment = segments[index];

    // 1. 尝试匹配精确路径
    if (node.children.containsKey(currentSegment)) {
      _matchSegments(node.children[currentSegment], segments, index + 1, method, matches);
    }

    // 2. 尝试匹配路径参数
    if (node.children.containsKey(':param')) {
      _matchSegments(node.children[':param'], segments, index + 1, method, matches);
    }

    // 3. 尝试匹配通配符
    if (node.children.containsKey('*')) {
      Router router = node.children['*'].routers[HttpMethodHelper.fromMethod(method)];
      if (router != null) {
        matches.add(router);
      }
    }
  }

  /**
   * 分割路径为段
   */
  List<String> _splitPath(String path) {
    List<String> segments = path.split('/');
    // 移除空段
    return segments.where((segment) => segment.isNotEmpty).toList();
  }
}
