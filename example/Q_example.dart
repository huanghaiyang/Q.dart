import 'dart:io';

import 'package:Q/Q.dart';

main() {
  Application app = Application();

  // app.applicationContext.configuration.unSupportedContentTypes.add(ContentType('multipart', 'form-data'));
  app.route(Router("/users", 'get', (Context ctx, [HttpRequest req, HttpResponse res]) async {
    return {'name': 'huang'};
  }));

  app.route(Router("/upload", 'post', (Context ctx, [HttpRequest req, HttpResponse res]) async {
    return {'name': 'huang'};
  }));

  app.route(Router("/user", 'post', (Context ctx, [HttpRequest req, HttpResponse res]) async {
    return {'success': true};
  }));

  app.route(Router("/user_redirect", 'post', (Context ctx, [HttpRequest req, HttpResponse res]) async {
    Map<String, String> map = Map();
    ctx.attributes.forEach((String key, Attribute value) {
      map[key] = value.value;
    });
    return map;
  }, name: 'user_redirect'));

  app.route(Router("/redirect", 'post', (Context ctx, [HttpRequest req, HttpResponse res]) async {
    return Redirect("/user_redirect", 'post', [Attribute('hello', 'world')]);
  }));

  app.route(Router("/redirect_name", 'post', (Context ctx, [HttpRequest req, HttpResponse res]) async {
    return Redirect("name:user_redirect", 'post', [Attribute('hello', 'world')]);
  }));

  app.route(Router("/user/:user_id", 'get', (Context ctx, [HttpRequest req, HttpResponse res, @PathVariable() int userId]) async {
    return {'name': 'huang'};
  }));

  app.listen(8081);
}
