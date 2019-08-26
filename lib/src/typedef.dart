import 'package:Q/src/Application.dart';

typedef ApplicationStartUpCallback = Future<dynamic> Function(Application application);

typedef ApplicationCloseCallback = void Function(Application application, [Future<dynamic> prevCloseableResult]);
