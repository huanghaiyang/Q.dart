import 'package:Q/src/Application.dart';
import 'package:Q/src/Resource.dart';
import 'package:Q/src/aware/ResourceAware.dart';
import 'package:Q/src/delegate/AbstractDelegate.dart';

abstract class ApplicationResourceDelegate extends ResourceAware<String, Resource> with AbstractDelegate {
  factory ApplicationResourceDelegate(Application application) => _ApplicationResourceDelegate(application);
}

class _ApplicationResourceDelegate implements ApplicationResourceDelegate {
  final Application application_;

  _ApplicationResourceDelegate(this.application_);

  @override
  Future<dynamic> flush(String pattern) {}

  @override
  void resource(String pattern, Resource resource) {}
}
