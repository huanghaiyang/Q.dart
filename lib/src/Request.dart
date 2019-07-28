import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/Context.dart';
import 'package:Q/src/Response.dart';
import 'package:Q/src/aware/BindApplicationAware.dart';

abstract class Request extends BindApplicationAware<Application> {
  HttpRequest get req;

  Context get ctx;

  Response get response;

  Map get data;

  set req(HttpRequest req);

  set ctx(Context ctx);

  set response(Response response);

  set data(Map data);

  factory Request({Map data}) => _Request(data_: data);
}

class _Request implements Request {
  Application app_;

  HttpRequest req_;

  Context ctx_;

  Response response_;

  Map data_;

  _Request({this.data_});

  @override
  set data(Map data) {
    this.data_ = data;
  }

  @override
  set response(Response response) {
    this.response_ = response;
  }

  @override
  set ctx(Context ctx) {
    this.ctx_ = ctx;
  }

  @override
  set req(HttpRequest req) {
    this.req_ = req;
  }

  @override
  set app(Application app) {
    this.app_ = app;
  }

  @override
  Map get data {
    return this.data_;
  }

  @override
  Response get response {
    return this.response_;
  }

  @override
  Context get ctx {
    return this.ctx_;
  }

  @override
  HttpRequest get req {
    return this.req_;
  }

  @override
  Application get app {
    return this.app_;
  }
}
