import 'dart:io';

import 'package:Q/src/Request.dart';
import 'package:Q/src/helpers/QueryHelper.dart';
import 'package:Q/src/resolver/AbstractResolver.dart';
import 'package:Q/src/utils/RequestUtil.dart';

class FormDataResolver implements AbstractResolver {
  FormDataResolver._();

  static FormDataResolver _instance;

  static FormDataResolver instance() {
    return _instance ?? (_instance = FormDataResolver._());
  }

  @override
  Future<bool> match(HttpRequest req) async {
    ContentType contentType = req.headers.contentType;
    if (contentType == null) return false;
    return contentType.mimeType.toLowerCase().startsWith(RegExp('application/form-data'));
  }

  @override
  Future<Request> resolve(HttpRequest req) async {
    Map data = Map();
    String query = await RequestUtil.getRequestBodyString(req);
    if (query.isNotEmpty) {
      Uri uri = Uri(query: query);
      data = Map.from(uri.queryParametersAll);
      data = QueryHelper.fixData(data);
    }
    Request request = Request(data: data);
    return request;
  }
}
