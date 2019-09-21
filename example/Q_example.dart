import 'dart:io';

import 'package:Q/Q.dart';

Application app;

void main(List<String> arguments) async {
  await start(arguments);
}

void start(List<String> arguments) async {
  app = Application()..args(arguments);
  await app.init();
  // app.applicationContext.configuration.unSupportedContentTypes.add(ContentType('multipart', 'form-data'));
  // app.applicationContext.configuration.unSupportedMethods.add(HttpMethod.POST);
  // app.applicationContext.configuration.multipartConfigure.maxUploadSize = FileSizeUnits.MB(1);

  // multipart/form-data
  app.post("/multipart-form-data", (Context context,
      [HttpRequest req,
      HttpResponse res,
      @RequestParam("name") String name,
      @RequestParam("friends") List<String> friends,
      @RequestParam("file") List<MultipartFile> files,
      @RequestParam("file") File file,
      @RequestParam("age") int age]) async {
    return {
      'name': name,
      "friends": friends,
      "file_length": files.length,
      "file_bytes_length": await file.length(),
      "age": age
    };
  });

  app.get("/user", (Context context,
      [HttpRequest req, HttpResponse res]) async {
    return {'name': "peter"};
  });

  app.post("/user_redirect", (Context context,
      [HttpRequest req, HttpResponse res]) async {
    Map<String, String> map = Map();
    context.attributes.forEach((String key, Attribute value) {
      map[key] = value.value;
    });
    return map;
  }, name: 'user_redirect');

  app.post("/redirect", (Context context,
      [HttpRequest req, HttpResponse res]) async {
    return Redirect("/user_redirect", HttpMethod.POST,
        attributes: {"hello": "world"});
  });

  app.post("/redirect_name", (Context context,
      [HttpRequest req, HttpResponse res]) async {
    return Redirect("name:user_redirect", HttpMethod.POST,
        attributes: {"hello": "world"});
  });

  app.post("/redirect_user", (Context context,
      [HttpRequest req, HttpResponse res]) async {
    return Redirect("name:user", HttpMethod.GET,
        pathVariables: {"user_id": "1", "name": "peter"});
  });

  app.get("/user/:user_id/:name", (Context context,
      [HttpRequest req,
      HttpResponse res,
      @PathVariable("user_id") int userId,
      @PathVariable("name") String name]) async {
    return {'id': userId, 'name': name};
  }, name: 'user');

  app.post("/cookie", (Context context,
      [HttpRequest req,
      HttpResponse res,
      @CookieValue("name") String name]) async {
    return [
      {'name': name}
    ];
  });

  app.post("/header", (Context context,
      [HttpRequest req,
      HttpResponse res,
      @RequestHeader("Content-Type") String contentType]) async {
    return {'Content-Type': contentType};
  });

  app.post("/setSession", (Context context,
      [HttpRequest req, HttpResponse res]) async {
    req.session.putIfAbsent("name", () {
      return "peter";
    });
    return {"name": req.session["name"], "jsessionid": req.session.id};
  });

  app.post("/getSession", (Context context,
      [HttpRequest req,
      HttpResponse res,
      @SessionValue("name") String name]) async {
    return {"name": name};
  });

  // 请求头不含contentType
  app.post("/request_no_content_type", (Context context,
      [HttpRequest req, HttpResponse res]) async {
    return {'contentType': req.headers.contentType?.toString()};
  });

  app.post("/application_json", (Context context,
      [HttpRequest req, HttpResponse res]) async {
    return context.request.data;
  });

  app.get("path_params", (Context context,
      [HttpRequest req,
      HttpResponse res,
      @UrlParam('age') int age,
      @UrlParam('isHero') bool isHero,
      @UrlParam('friends') List<String> friends,
      @UrlParam('grandpa') String grandpa,
      @RequestParam('actors') List<String> actors]) async {
    return {
      'age': age,
      'isHero': isHero,
      'friends': friends,
      'grandpa': grandpa,
      'money': null,
      'actors': actors
    };
  });

  app.post("/x-www-form-urlencoded", (Context context,
      [HttpRequest req,
      HttpResponse res,
      @UrlParam('age') int age,
      @UrlParam('isHero') bool isHero,
      @UrlParam('friends') List<String> friends,
      @UrlParam('grandpa') String grandpa,
      @RequestParam('actors') List<String> actors]) async {
    return {
      'age': age,
      'isHero': isHero,
      'friends': friends,
      'grandpa': grandpa,
      'money': null,
      'actors': actors
    };
  });

  app.get("/router-timeout", (Context context,
      [HttpRequest req, HttpResponse res]) async {
    return await Future.delayed(Duration(milliseconds: 10), () {
      return {'timeout': 10};
    });
  }).setTimeout(RequestTimeout(Duration(milliseconds: 11), () async {
    return {'timeout': 11};
  }));

  app.get("/router-timeout-take-effect", (Context context,
      [HttpRequest req, HttpResponse res]) async {
    return await Future.delayed(Duration(milliseconds: 10), () {
      return {'timeout': 10};
    });
  }).setTimeout(RequestTimeout(Duration(milliseconds: 5), () async {
    return {'timeout': 5};
  }));

  await app.listen(8081);
}
