# Q.dart-轻量级Dart服务端框架
### Keep on developing

## How to use
```dart
import 'dart:io';

import 'package:Q/Q.dart';

main() {
  Application app = Application();
  app.router(Router("/users", 'get', (Context ctx,
      [HttpRequest req, HttpResponse res]) {
    return {'name': 'huang'};
  }));
  app.listen(8081);
}

```