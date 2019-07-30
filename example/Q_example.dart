import 'dart:io';

import 'package:Q/Q.dart';

main() {
  Application app = Application();

  // app.applicationContext.configuration.unSupportedContentTypes.add(ContentType('multipart', 'form-data'));
  // app.applicationContext.configuration.unSupportedMethods.add(POST);
  app.route(Router("/users", HttpMethod.GET, (Context ctx, [HttpRequest req, HttpResponse res]) async {
    return {'name': 'huang'};
  }));

  app.route(Router("/upload", HttpMethod.POST, (Context ctx, [HttpRequest req, HttpResponse res]) async {
    return {'name': 'huang'};
  }));

  app.route(Router("/user", HttpMethod.POST, (Context ctx, [HttpRequest req, HttpResponse res]) async {
    return {'success': true};
  }));

  app.route(Router("/user_redirect", HttpMethod.POST, (Context ctx, [HttpRequest req, HttpResponse res]) async {
    Map<String, String> map = Map();
    ctx.attributes.forEach((String key, Attribute value) {
      map[key] = value.value;
    });
    return map;
  }, name: 'user_redirect'));

  app.route(Router("/redirect", HttpMethod.POST, (Context ctx, [HttpRequest req, HttpResponse res]) async {
    return Redirect("/user_redirect", HttpMethod.POST, attributes: [Attribute('hello', 'world')]);
  }));

  app.route(Router("/redirect_name", HttpMethod.POST, (Context ctx, [HttpRequest req, HttpResponse res]) async {
    return Redirect("name:user_redirect", HttpMethod.POST, attributes: [Attribute('hello', 'world')]);
  }));

  app.route(Router("/redirect_user", HttpMethod.POST, (Context ctx, [HttpRequest req, HttpResponse res]) async {
    return Redirect("name:user", HttpMethod.GET, pathVariables: {"user_id": "1", "name": "huang"});
  }));

  app.route(Router("/user/:user_id/:name", HttpMethod.GET, (Context ctx,
      [HttpRequest req, HttpResponse res, @PathVariable("user_id") int userId, @PathVariable("name") String name]) async {
    return {'id': userId, 'name': name};
  }, name: 'user'));

  app.listen(8081);
}
