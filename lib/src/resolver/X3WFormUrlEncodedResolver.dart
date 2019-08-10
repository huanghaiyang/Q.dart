import 'dart:async';
import 'dart:io';

import 'package:Q/src/Request.dart';
import 'package:Q/src/helpers/QueryHelper.dart';
import 'package:Q/src/resolver/AbstractResolver.dart';
import 'package:Q/src/utils/ListUtil.dart';

class X3WFormUrlEncodedResolver extends AbstractResolver {
  X3WFormUrlEncodedResolver._();

  static X3WFormUrlEncodedResolver _instance;

  static X3WFormUrlEncodedResolver getInstance() {
    if (_instance == null) {
      _instance = X3WFormUrlEncodedResolver._();
    }
    return _instance;
  }

  @override
  Future<bool> match(HttpRequest req) async {
    ContentType contentType = req.headers.contentType;
    if (contentType == null) return false;
    return contentType.mimeType.toLowerCase().startsWith(RegExp('application/x-www-form-urlencoded'));
  }

  @override
  Future<Request> resolve(HttpRequest req) async {
    Map data = Map();
    String query = String.fromCharCodes(concat(await req.toList()));
    if (query.isNotEmpty) {
      Uri uri = Uri(query: query);
      data = Map.from(uri.queryParametersAll);
      data = QueryHelper.fixData(data);
    }
    Request request = Request(data: data);
    return request;
  }
}
