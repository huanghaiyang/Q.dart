import 'dart:io';
import 'dart:typed_data';
import 'package:Q/src/Request.dart';
import 'package:Q/src/resolver/AbstractResolver.dart';
import 'package:Q/src/resolver/ApplicationJsonResolver.dart';
import 'package:Q/src/resolver/FormDataResolver.dart';
import 'package:Q/src/resolver/TextResolver.dart';
import 'package:Q/src/resolver/XmlResolver.dart';
import 'package:Q/src/resolver/X3WFormUrlEncodedResolver.dart';
import 'package:test/test.dart';

class MockHttpRequest implements HttpRequest {
  final List<List<int>> body;
  final String method;
  final Uri uri;
  final List<Cookie> cookies = [];
  final MockHttpHeaders headers = MockHttpHeaders();
  
  MockHttpRequest(ContentType contentType, this.body, [this.method = 'POST', Uri uri]) : 
    this.uri = uri ?? Uri.parse('http://localhost:8080/test') {
    if (contentType != null) {
      headers.add('Content-Type', contentType.toString());
    }
  }
  
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
  
  @override
  HttpResponse get response => null;
  
  @override
  HttpConnectionInfo get connectionInfo => null;
  
  @override
  String get protocolVersion => 'HTTP/1.1';
  
  @override
  bool get persistentConnection => false;
  
  @override
  void detachSocket(Socket socket, {bool writeHeaders = true}) {}
  
  @override
  Future<Socket> detachSocketRaw() async => null;
  
  @override
  X509Certificate get certificate => null;
  
  @override
  String get remoteAddress => '127.0.0.1';
  
  @override
  int get remotePort => 12345;
  
  @override
  String get localAddress => '127.0.0.1';
  
  @override
  int get localPort => 8080;
  
  @override
  Future<List<Uint8List>> toList() async {
    return body.map((list) => Uint8List.fromList(list)).toList();
  }
}

class MockHttpHeaders implements HttpHeaders {
  final Map<String, List<String>> _headers = {};
  
  @override
  List<String> operator [](String name) => _headers[name.toLowerCase()];
  
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    String key = preserveHeaderCase ? name : name.toLowerCase();
    if (!_headers.containsKey(key)) {
      _headers[key] = [];
    }
    _headers[key].add(value.toString());
  }
  
  @override
  ContentType get contentType {
    List<String> values = _headers['content-type'];
    if (values != null && values.isNotEmpty) {
      return ContentType.parse(values.first);
    }
    return null;
  }
  
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('Resolver Tests', () {
    test('JsonResolver should match JSON content type', () async {
      AbstractResolver resolver = JsonResolver.instance();
      HttpRequest req = MockHttpRequest(ContentType.json, []);
      bool matched = await resolver.match(req);
      expect(matched, true);
    });
    
    test('JsonResolver should resolve JSON data', () async {
      AbstractResolver resolver = JsonResolver.instance();
      String jsonData = '{"name": "test", "value": 123}';
      HttpRequest req = MockHttpRequest(ContentType.json, [jsonData.codeUnits]);
      Request request = await resolver.resolve(req);
      expect(request.data['name'], 'test');
      expect(request.data['value'], 123);
    });
    
    test('TextResolver should match text/plain content type', () async {
      AbstractResolver resolver = TextResolver.instance();
      HttpRequest req = MockHttpRequest(ContentType('text', 'plain'), []);
      bool matched = await resolver.match(req);
      expect(matched, true);
    });
    
    test('TextResolver should resolve text data', () async {
      AbstractResolver resolver = TextResolver.instance();
      String textData = 'Hello, World!';
      HttpRequest req = MockHttpRequest(ContentType('text', 'plain'), [textData.codeUnits]);
      Request request = await resolver.resolve(req);
      expect(request.data['text'], 'Hello, World!');
    });
    
    test('XmlResolver should match application/xml content type', () async {
      AbstractResolver resolver = XmlResolver.instance();
      HttpRequest req = MockHttpRequest(ContentType('application', 'xml'), []);
      bool matched = await resolver.match(req);
      expect(matched, true);
    });
    
    test('XmlResolver should resolve XML data', () async {
      AbstractResolver resolver = XmlResolver.instance();
      String xmlData = '<root><name>test</name></root>';
      HttpRequest req = MockHttpRequest(ContentType('application', 'xml'), [xmlData.codeUnits]);
      Request request = await resolver.resolve(req);
      expect(request.data['xml'], '<root><name>test</name></root>');
    });
    
    test('X3WFormUrlEncodedResolver should match application/x-www-form-urlencoded content type', () async {
      AbstractResolver resolver = X3WFormUrlEncodedResolver.instance();
      HttpRequest req = MockHttpRequest(ContentType('application', 'x-www-form-urlencoded'), []);
      bool matched = await resolver.match(req);
      expect(matched, true);
    });
    
    test('X3WFormUrlEncodedResolver should resolve form data', () async {
      AbstractResolver resolver = X3WFormUrlEncodedResolver.instance();
      String formData = 'name=test&value=123';
      HttpRequest req = MockHttpRequest(ContentType('application', 'x-www-form-urlencoded'), [formData.codeUnits]);
      Request request = await resolver.resolve(req);
      expect(request.data['name'], ['test']);
      expect(request.data['value'], ['123']);
    });
    
    test('FormDataResolver should match application/form-data content type', () async {
      AbstractResolver resolver = FormDataResolver.instance();
      HttpRequest req = MockHttpRequest(ContentType('application', 'form-data'), []);
      bool matched = await resolver.match(req);
      expect(matched, true);
    });
    
    test('FormDataResolver should resolve form data', () async {
      AbstractResolver resolver = FormDataResolver.instance();
      String formData = 'name=test&value=123';
      HttpRequest req = MockHttpRequest(ContentType('application', 'form-data'), [formData.codeUnits]);
      Request request = await resolver.resolve(req);
      expect(request.data['name'], ['test']);
      expect(request.data['value'], ['123']);
    });
  });
}
