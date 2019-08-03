import 'package:Q/src/Redirect.dart';
import 'package:Q/src/Router.dart';

Pattern NAME_PATTERN = RegExp("name:");

Pattern PATH_PATTERN = RegExp("path:");

class RedirectHelper {
  static Future<Router> matchRouter(Redirect redirect, List<Router> routers) async {
    String address = redirect.address;
    Router matchedRouter;
    if (address.startsWith(NAME_PATTERN)) {
      for (int i = 0; i < routers.length; i++) {
        if (routers[i].name == redirect.name) {
          matchedRouter = routers[i];
          break;
        }
      }
    } else if (address.startsWith(PATH_PATTERN)) {
      await for (Router router in Stream.fromIterable(routers)) {
        bool hasMatch = await router.matchPath(redirect.path);
        if (hasMatch) {
          matchedRouter = router;
        }
      }
    }
    if (matchedRouter != null) {
      if (matchedRouter.method == redirect.method) {
        return matchedRouter;
      }
    }
    return null;
  }
}
