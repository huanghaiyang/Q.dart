import 'dart:async';
import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/Request.dart';
import 'package:Q/src/aware/HttpRequestResolverAware.dart';
import 'package:Q/src/delegate/AbstractDelegate.dart';
import 'package:Q/src/exception/NoMatchRequestResolverException.dart';
import 'package:Q/src/resolver/AbstractResolver.dart';
import 'package:Q/src/resolver/ResolverType.dart';
import 'package:curie/curie.dart';

abstract class HttpRequestResolverDelegate extends HttpRequestResolverAware<AbstractResolver, Request, ResolverType> with AbstractDelegate {
  factory HttpRequestResolverDelegate(Application application) => _HttpRequestResolverDelegate(application);

  factory HttpRequestResolverDelegate.from(Application application) {
    return application.getDelegate(HttpRequestResolverDelegate);
  }
}

class _HttpRequestResolverDelegate implements HttpRequestResolverDelegate {
  final Application application;

  _HttpRequestResolverDelegate(this.application);

  @override
  void addResolver(ResolverType type, AbstractResolver resolver) {
    this.application.resolvers[type] = resolver;
  }

  // 匹配请求的content-type
  @override
  Future<AbstractResolver> matchResolver(HttpRequest req) async {
    if (this.application.resolvers.isEmpty) {
      return null;
    }
    List<Function> functions = List();
    List<ResolverType> keys = List.from(this.application.resolvers.keys);
    for (int i = 0; i < keys.length; i++) {
      ResolverType resolverType = keys[i];
      functions.add(() async {
        return await this.application.resolvers[resolverType].match(req);
      });
    }
    Completer<AbstractResolver> completer = Completer();
    await someLimit(functions, 5, (Map<int, bool> result) {
      if (result.values.every((v) => !v)) {
        completer.complete(null);
      } else {
        for (MapEntry entry in result.entries) {
          if (entry.value) {
            completer.complete(this.application.resolvers[keys[entry.key]]);
            break;
          }
        }
      }
    });
    return completer.future;
  }

  // 预处理请求
  @override
  Future<Request> resolveRequest(HttpRequest req) async {
    AbstractResolver resolver = await this.matchResolver(req);
    if (resolver != null) {
      return resolver.resolve(req);
    } else {
      return throw NoMatchRequestResolverException(contentType: req.headers.contentType);
    }
  }
}
