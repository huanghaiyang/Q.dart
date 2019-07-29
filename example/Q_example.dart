import 'dart:io';

import 'package:Q/Q.dart';

main() {
  Application app = Application();

  // app.applicationContext.configuration.unSupportedContentTypes.add(ContentType('multipart', 'form-data'));
  app.route(Router("/users", GET, (Context ctx, [HttpRequest req, HttpResponse res]) async {
    return {'name': 'huang'};
  }));

  app.route(Router("/upload", POST, (Context ctx, [HttpRequest req, HttpResponse res]) async {
    return {'name': 'huang'};
  }));

//  app.route(Router("/upload", 'take', (Context ctx, [HttpRequest req, HttpResponse res]) async {
//    return {'name': 'huang'};
//  }));

  app.route(Router("/user", POST, (Context ctx, [HttpRequest req, HttpResponse res]) async {
    return {'success': true};
  }));

  app.route(Router("/user_redirect", POST, (Context ctx, [HttpRequest req, HttpResponse res]) async {
    Map<String, String> map = Map();
    ctx.attributes.forEach((String key, Attribute value) {
      map[key] = value.value;
    });
    return map;
  }, name: 'user_redirect'));

  app.route(Router("/redirect", POST, (Context ctx, [HttpRequest req, HttpResponse res]) async {
    return Redirect("/user_redirect", POST, attributes: [Attribute('hello', 'world')]);
  }));

  app.route(Router("/redirect_name", POST, (Context ctx, [HttpRequest req, HttpResponse res]) async {
    return Redirect("name:user_redirect", POST, attributes: [Attribute('hello', 'world')]);
  }));

  app.route(Router("/user/:user_id/:name", GET, (Context ctx,
      [HttpRequest req, HttpResponse res, @PathVariable("user_id") int userId, @PathVariable("name") String name]) async {
    return {'id': userId, 'name': name};
  }));

  app.listen(8081);
}
