import 'dart:mirrors';

import 'package:Q/src/annotation/Annotation.dart';
import 'package:Q/src/i18n/annotations/Locale.dart';

List<Type> SUPPORTED_ROUTER_HANDLER_PARAMETER_ANNOTATIONS = [
  PathVariable,
  CookieValue,
  AttributeValue,
  RequestHeader,
  RequestParam,
  UrlParam,
  SessionValue,
  Config,
  Body,
  RawBody,
  Locale,
];

List<ClassMirror> SUPPORTED_ROUTER_HANDLER_PARAMETER_ANNOTATION_CLASSES =
    List.from(SUPPORTED_ROUTER_HANDLER_PARAMETER_ANNOTATIONS.map((Type annotation) => reflectClass(annotation)));
