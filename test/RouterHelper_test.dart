import 'dart:io';

import 'package:Q/Q.dart';
import 'package:test/test.dart';

@pragma('vm:entry-point')
class UnSupport {
  const UnSupport();
}

void main() {
  group('RouterHelper', () {
    List<Router> routers;
    Router requestUserByIdAndNameRouter;

    setUp(() {
      routers = List();
      requestUserByIdAndNameRouter = Router("/user/:id/:name", HttpMethod.POST, (Context context,
          [HttpRequest request, HttpResponse response]) async {
        return {};
      }, pathVariables: {"id": 1, "name": "peter"}, name: 'request_user_named_peter');

      routers.add(requestUserByIdAndNameRouter);
    });

    test('RouterHelper::applyPathVariables', () {
      Map<String, String> variables =
          RouterHelper.applyPathVariables('/user/1/peter', '/user/:id/:name');
      expect(variables, {"id": '1', "name": "peter"});
    });

    test('RouterHelper::reBuildPathByVariables', () {
      String requestPath = RouterHelper.reBuildPathByVariables(requestUserByIdAndNameRouter);
      expect(requestPath, '/user/1/peter');
    });

    test('RouterHelper::matchRedirect', () async {
      expect(
          await RouterHelper.matchRedirect(
              Redirect("path:/user/1/peter", HttpMethod.POST), routers),
          requestUserByIdAndNameRouter);
      expect(
          await RouterHelper.matchRedirect(
              Redirect("name:request_user_named_peter", HttpMethod.POST), routers),
          requestUserByIdAndNameRouter);

      expect(
          await RouterHelper.matchRedirect(Redirect("path:/user/1/peter", HttpMethod.GET), routers),
          null);
      expect(
          await RouterHelper.matchRedirect(
              Redirect("name:request_user_named_peter_1", HttpMethod.POST), routers),
          null);
    });

    tearDown(() {
      routers = null;
      requestUserByIdAndNameRouter = null;
    });
  });

  group("checkoutRouterHandlerParameterAnnotations", () {
    test("expect exception", () {
      try {
        Router("/", HttpMethod.POST, (Context context,
            [HttpRequest request,
            HttpResponse response,
            @PathVariable("path") String path,
            @CookieValue("cookie") String cookie,
            @AttributeValue("attribute") String attribute,
            @RequestHeader("header") String header,
            @RequestParam("param") String param,
            @UrlParam("urlParam") String urlParam,
            @SessionValue("session") String session,
            @UnSupport() String unSupport]) async {
          return {};
        });
      } catch (err) {
        expect(err is UnSupportRouterHandlerParameterAnnotationException, true);
      }
    });
  });
}
