import 'dart:io';

import 'package:Q/src/Context.dart';
import 'package:Q/src/Request.dart';
import 'package:Q/src/ResponseEntry.dart';
import 'package:Q/src/aware/ContextAware.dart';
import 'package:Q/src/aware/StatusAware.dart';

String _FINE = 'fine';

abstract class Response extends StatusAware with ContextAware<Context> {
  set res(HttpResponse res);

  set request(Request request);

  set responseEntry(ResponseEntry responseEntry);

  HttpResponse get res;

  Request get request;

  ResponseEntry get responseEntry;

  factory Response([HttpResponse res, Request request, Context context, ResponseEntry responseEntry]) =>
      _Response(res, request, context, responseEntry);
}

class _Response implements Response {
  HttpResponse res_;

  Request request_;

  Context context_;

  int status_ = HttpStatus.ok;

  String _statusText = _FINE;

  ResponseEntry responseEntry_;

  _Response([this.res_, this.request_, this.context_, this.responseEntry_]);

  @override
  ResponseEntry get responseEntry {
    return this.responseEntry_;
  }

  @override
  Context get context {
    return this.context_;
  }

  @override
  Request get request {
    return this.request_;
  }

  @override
  HttpResponse get res {
    return this.res_;
  }

  @override
  set responseEntry(ResponseEntry responseEntry) {
    this.responseEntry_ = responseEntry;
  }

  @override
  set context(Context context) {
    this.context_ = context;
  }

  @override
  set request(Request request) {
    this.request_ = request;
  }

  @override
  set res(HttpResponse res) {
    this.res_ = res;
  }

  @override
  set status(int status) {
    this.status_ = status;
  }

  @override
  int get status {
    return this.status_;
  }

  @override
  set statusText(String statusText) {
    this._statusText = statusText;
  }

  @override
  String get statusText {
    return this._statusText;
  }
}
