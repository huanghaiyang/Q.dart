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
  app.listen(8081);
}
