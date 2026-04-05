import 'package:Q/src/ApplicationConfiguration.dart';
import 'package:Q/src/configure/AbstractConfigure.dart';
import 'package:Q/src/configure/ApplicationConfigurationNames.dart';
import 'package:Q/src/configure/HttpsConfigure.dart';
import 'package:Q/src/utils/ConfigureUtil.dart';

abstract class SecurityConfigure extends AbstractConfigure {
  factory SecurityConfigure() => _SecurityConfigure();

  CsrfConfigure get csrfConfigure;
  set csrfConfigure(CsrfConfigure csrfConfigure);

  XssConfigure get xssConfigure;
  set xssConfigure(XssConfigure xssConfigure);

  AuthConfigure get authConfigure;
  set authConfigure(AuthConfigure authConfigure);

  HttpsConfigure get httpsConfigure;
  set httpsConfigure(HttpsConfigure httpsConfigure);

  SecurityHeadersConfigure get securityHeadersConfigure;
  set securityHeadersConfigure(SecurityHeadersConfigure securityHeadersConfigure);
}

class _SecurityConfigure implements SecurityConfigure {
  CsrfConfigure _csrfConfigure = CsrfConfigure();
  XssConfigure _xssConfigure = XssConfigure();
  AuthConfigure _authConfigure = AuthConfigure();
  HttpsConfigure _httpsConfigure = HttpsConfigure();
  SecurityHeadersConfigure _securityHeadersConfigure = SecurityHeadersConfigure();

  _SecurityConfigure();

  @override
  CsrfConfigure get csrfConfigure => _csrfConfigure;

  @override
  set csrfConfigure(CsrfConfigure csrfConfigure) => _csrfConfigure = csrfConfigure;

  @override
  XssConfigure get xssConfigure => _xssConfigure;

  @override
  set xssConfigure(XssConfigure xssConfigure) => _xssConfigure = xssConfigure;

  @override
  AuthConfigure get authConfigure => _authConfigure;

  @override
  set authConfigure(AuthConfigure authConfigure) => _authConfigure = authConfigure;

  @override
  HttpsConfigure get httpsConfigure => _httpsConfigure;

  @override
  set httpsConfigure(HttpsConfigure httpsConfigure) => _httpsConfigure = httpsConfigure;

  @override
  SecurityHeadersConfigure get securityHeadersConfigure => _securityHeadersConfigure;

  @override
  set securityHeadersConfigure(SecurityHeadersConfigure securityHeadersConfigure) => _securityHeadersConfigure = securityHeadersConfigure;

  @override
  Future<dynamic> init(ApplicationConfiguration applicationConfiguration) async {
    _csrfConfigure.enabled = applicationConfiguration.get(SECURITY_CSRF_ENABLED);
    _csrfConfigure.protectedMethods = ConfigureUtil.convertToListString(applicationConfiguration.get(SECURITY_CSRF_PROTECTED_METHODS));
    _csrfConfigure.tokenMaxAge = applicationConfiguration.get(SECURITY_CSRF_TOKEN_MAX_AGE);
    _csrfConfigure.tokenHeader = applicationConfiguration.get(SECURITY_CSRF_TOKEN_HEADER);
    _csrfConfigure.tokenCookie = applicationConfiguration.get(SECURITY_CSRF_TOKEN_COOKIE);
    _xssConfigure.enabled = applicationConfiguration.get(SECURITY_XSS_ENABLED);
    _xssConfigure.blockRequest = applicationConfiguration.get(SECURITY_XSS_BLOCK_REQUEST);
    _xssConfigure.protectedContentTypes = ConfigureUtil.convertToListString(applicationConfiguration.get(SECURITY_XSS_PROTECTED_CONTENT_TYPES));
    _authConfigure.enabled = applicationConfiguration.get(SECURITY_AUTH_ENABLED);
    _authConfigure.publicPaths = ConfigureUtil.convertToListString(applicationConfiguration.get(SECURITY_AUTH_PUBLIC_PATHS));
    _authConfigure.pathRoles = ConfigureUtil.convertToMapStringList(applicationConfiguration.get(SECURITY_AUTH_PATH_ROLES));
    _authConfigure.tokenHeader = applicationConfiguration.get(SECURITY_AUTH_TOKEN_HEADER);
    _authConfigure.tokenExpiration = applicationConfiguration.get(SECURITY_AUTH_TOKEN_EXPIRATION);
    _securityHeadersConfigure.enabled = applicationConfiguration.get(SECURITY_HEADERS_ENABLED);
    _securityHeadersConfigure.xssProtection = applicationConfiguration.get(SECURITY_HEADERS_XSS_PROTECTION);
    _securityHeadersConfigure.contentTypeOptions = applicationConfiguration.get(SECURITY_HEADERS_CONTENT_TYPE_OPTIONS);
    _securityHeadersConfigure.frameOptions = applicationConfiguration.get(SECURITY_HEADERS_FRAME_OPTIONS);
    _securityHeadersConfigure.contentSecurityPolicy = applicationConfiguration.get(SECURITY_HEADERS_CONTENT_SECURITY_POLICY);
    _securityHeadersConfigure.contentSecurityPolicyValue = applicationConfiguration.get(SECURITY_HEADERS_CONTENT_SECURITY_POLICY_VALUE);
    _httpsConfigure.enabled = applicationConfiguration.get(HTTPS_ENABLED);
    _httpsConfigure.certificatePath = applicationConfiguration.get(HTTPS_CERTIFICATE_PATH);
    _httpsConfigure.privateKeyPath = applicationConfiguration.get(HTTPS_PRIVATE_KEY_PATH);
    _httpsConfigure.certificatePassword = applicationConfiguration.get(HTTPS_CERTIFICATE_PASSWORD);
    _httpsConfigure.enableHttp2 = applicationConfiguration.get(HTTPS_ENABLE_HTTP2);
    _httpsConfigure.enableTls13 = applicationConfiguration.get(HTTPS_ENABLE_TLS13);
    _httpsConfigure.tlsVersions = ConfigureUtil.convertToListString(applicationConfiguration.get(HTTPS_TLS_VERSIONS));
    _httpsConfigure.clientCertificateRequired = applicationConfiguration.get(HTTPS_CLIENT_CERTIFICATE_REQUIRED);
    _httpsConfigure.trustedCaCertificatePath = applicationConfiguration.get(HTTPS_TRUSTED_CA_CERTIFICATE_PATH);
  }
}

abstract class CsrfConfigure {
  factory CsrfConfigure() => _CsrfConfigure();

  bool get enabled;
  set enabled(bool enabled);

  List<String> get protectedMethods;
  set protectedMethods(List<String> protectedMethods);

  int get tokenMaxAge;
  set tokenMaxAge(int tokenMaxAge);

  String get tokenHeader;
  set tokenHeader(String tokenHeader);

  String get tokenCookie;
  set tokenCookie(String tokenCookie);
}

class _CsrfConfigure implements CsrfConfigure {
  bool _enabled;
  List<String> _protectedMethods;
  int _tokenMaxAge;
  String _tokenHeader;
  String _tokenCookie;

  _CsrfConfigure();

  @override
  bool get enabled => _enabled;

  @override
  set enabled(bool enabled) => _enabled = enabled;

  @override
  List<String> get protectedMethods => _protectedMethods;

  @override
  set protectedMethods(List<String> protectedMethods) => _protectedMethods = protectedMethods;

  @override
  int get tokenMaxAge => _tokenMaxAge;

  @override
  set tokenMaxAge(int tokenMaxAge) => _tokenMaxAge = tokenMaxAge;

  @override
  String get tokenHeader => _tokenHeader;

  @override
  set tokenHeader(String tokenHeader) => _tokenHeader = tokenHeader;

  @override
  String get tokenCookie => _tokenCookie;

  @override
  set tokenCookie(String tokenCookie) => _tokenCookie = tokenCookie;
}

abstract class XssConfigure {
  factory XssConfigure() => _XssConfigure();

  bool get enabled;
  set enabled(bool enabled);

  bool get blockRequest;
  set blockRequest(bool blockRequest);

  List<String> get protectedContentTypes;
  set protectedContentTypes(List<String> protectedContentTypes);
}

class _XssConfigure implements XssConfigure {
  bool _enabled;
  bool _blockRequest;
  List<String> _protectedContentTypes;

  _XssConfigure();

  @override
  bool get enabled => _enabled;

  @override
  set enabled(bool enabled) => _enabled = enabled;

  @override
  bool get blockRequest => _blockRequest;

  @override
  set blockRequest(bool blockRequest) => _blockRequest = blockRequest;

  @override
  List<String> get protectedContentTypes => _protectedContentTypes;

  @override
  set protectedContentTypes(List<String> protectedContentTypes) => _protectedContentTypes = protectedContentTypes;
}

abstract class AuthConfigure {
  factory AuthConfigure() => _AuthConfigure();

  bool get enabled;
  set enabled(bool enabled);

  List<String> get publicPaths;
  set publicPaths(List<String> publicPaths);

  Map<String, List<String>> get pathRoles;
  set pathRoles(Map<String, List<String>> pathRoles);

  String get tokenHeader;
  set tokenHeader(String tokenHeader);

  int get tokenExpiration;
  set tokenExpiration(int tokenExpiration);
}

class _AuthConfigure implements AuthConfigure {
  bool _enabled;
  List<String> _publicPaths;
  Map<String, List<String>> _pathRoles;
  String _tokenHeader;
  int _tokenExpiration;

  _AuthConfigure();

  @override
  bool get enabled => _enabled;

  @override
  set enabled(bool enabled) => _enabled = enabled;

  @override
  List<String> get publicPaths => _publicPaths;

  @override
  set publicPaths(List<String> publicPaths) => _publicPaths = publicPaths;

  @override
  Map<String, List<String>> get pathRoles => _pathRoles;

  @override
  set pathRoles(Map<String, List<String>> pathRoles) => _pathRoles = pathRoles;

  @override
  String get tokenHeader => _tokenHeader;

  @override
  set tokenHeader(String tokenHeader) => _tokenHeader = tokenHeader;

  @override
  int get tokenExpiration => _tokenExpiration;

  @override
  set tokenExpiration(int tokenExpiration) => _tokenExpiration = tokenExpiration;
}

abstract class SecurityHeadersConfigure {
  factory SecurityHeadersConfigure() => _SecurityHeadersConfigure();

  bool get enabled;
  set enabled(bool enabled);

  bool get xssProtection;
  set xssProtection(bool xssProtection);

  bool get contentTypeOptions;
  set contentTypeOptions(bool contentTypeOptions);

  bool get frameOptions;
  set frameOptions(bool frameOptions);

  bool get contentSecurityPolicy;
  set contentSecurityPolicy(bool contentSecurityPolicy);

  String get contentSecurityPolicyValue;
  set contentSecurityPolicyValue(String contentSecurityPolicyValue);
}

class _SecurityHeadersConfigure implements SecurityHeadersConfigure {
  bool _enabled;
  bool _xssProtection;
  bool _contentTypeOptions;
  bool _frameOptions;
  bool _contentSecurityPolicy;
  String _contentSecurityPolicyValue;

  _SecurityHeadersConfigure();

  @override
  bool get enabled => _enabled;

  @override
  set enabled(bool enabled) => _enabled = enabled;

  @override
  bool get xssProtection => _xssProtection;

  @override
  set xssProtection(bool xssProtection) => _xssProtection = xssProtection;

  @override
  bool get contentTypeOptions => _contentTypeOptions;

  @override
  set contentTypeOptions(bool contentTypeOptions) => _contentTypeOptions = contentTypeOptions;

  @override
  bool get frameOptions => _frameOptions;

  @override
  set frameOptions(bool frameOptions) => _frameOptions = frameOptions;

  @override
  bool get contentSecurityPolicy => _contentSecurityPolicy;

  @override
  set contentSecurityPolicy(bool contentSecurityPolicy) => _contentSecurityPolicy = contentSecurityPolicy;

  @override
  String get contentSecurityPolicyValue => _contentSecurityPolicyValue;

  @override
  set contentSecurityPolicyValue(String contentSecurityPolicyValue) => _contentSecurityPolicyValue = contentSecurityPolicyValue;
}

