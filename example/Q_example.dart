import 'dart:io';

import 'package:Q/Q.dart';

main() {
  Application app = Application();
  app.route(Router("/users", 'get', (Context ctx,
      [HttpRequest req, HttpResponse res]) async {
    return {'name': 'huang'};
  }));
  app.listen(8081);
}
