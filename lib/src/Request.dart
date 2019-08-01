import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/Context.dart';
import 'package:Q/src/Response.dart';
import 'package:Q/src/aware/BindApplicationAware.dart';
import 'package:Q/src/aware/ContextAware.dart';

abstract class Request extends BindApplicationAware<Application> with ContextAware<Context> {
  HttpRequest get req;

  Response get response;

  Map get data;

  set req(HttpRequest req);

  set response(Response response);

  set data(Map data);

  factory Request({Map data}) => _Request(data_: data);
}

class _Request implements Request {
  Application app_;

  HttpRequest req_;

  Context context_;

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
  set context(Context context) {
    this.context_ = context;
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
  Context get context {
    return this.context_;
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
