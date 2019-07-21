import 'dart:io';

abstract class AbstractView {
  String toRaw(HttpRequest req, HttpResponse res, {Map extra});
}
