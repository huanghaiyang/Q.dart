import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/Context.dart';
import 'package:Q/src/Request.dart';
import 'package:Q/src/ResponseEntry.dart';
import 'package:Q/src/aware/BindApplicationAware.dart';
import 'package:Q/src/aware/StatusAware.dart';

String _FINE = 'fine';

abstract class Response extends BindApplicationAware<Application> with StatusAware {
  set res(HttpResponse res);

  set request(Request request);

  set ctx(Context ctx);

  set responseEntry(ResponseEntry responseEntry);

  HttpResponse get res;

  Request get request;

  Context get ctx;

  ResponseEntry get responseEntry;

  factory Response([Application app, HttpResponse res, Request request, Context ctx, ResponseEntry responseEntry]) =>
      _Response(app, res, request, ctx, responseEntry);
}

class _Response implements Response {
  Application app_;

  HttpResponse res_;

  Request request_;

  Context ctx_;

  int status_ = HttpStatus.ok;

  String _statusText = _FINE;

  ResponseEntry responseEntry_;

  _Response([this.app_, this.res_, this.request_, this.ctx_, this.responseEntry_]);

  @override
  ResponseEntry get responseEntry {
    return this.responseEntry_;
  }

  @override
  Context get ctx {
    return this.ctx_;
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
  Application get app {
    return this.app_;
  }

  @override
  set responseEntry(ResponseEntry responseEntry) {
    this.responseEntry_ = responseEntry;
  }

  @override
  set ctx(Context ctx) {
    this.ctx_ = ctx;
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
  set app(Application app) {
    this.app_ = app;
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
