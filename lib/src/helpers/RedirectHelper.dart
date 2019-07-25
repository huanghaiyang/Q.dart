import 'package:Q/src/Application.dart';
import 'package:Q/src/Redirect.dart';
import 'package:Q/src/Router.dart';

Pattern NAME_PATTERN = RegExp("name:");

class RedirectHelper {
  static Router matchRouter(Redirect redirect) {
    Router router;
    if (redirect.path.startsWith(NAME_PATTERN)) {
      List<Router> routers = Application.getRouters();
      for (int i = 0; i < routers.length; i++) {
        if (routers[i].name == redirect.path.replaceFirst(NAME_PATTERN, '')) {
          router = routers[i];
          break;
        }
      }
    }
    return router;
  }
}
