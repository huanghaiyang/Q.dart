import 'dart:io';
import 'package:Q/src/ApplicationConfiguration.dart';
import 'package:Q/src/configure/AbstractConfigure.dart';
import 'package:Q/src/configure/ApplicationConfigurationNames.dart';
import 'package:Q/src/utils/ConfigureUtil.dart';

abstract class HttpsConfigure extends AbstractConfigure {
  factory HttpsConfigure() => _HttpsConfigure();

  bool get enabled;
  set enabled(bool enabled);

  String get certificatePath;
  set certificatePath(String certificatePath);

  String get privateKeyPath;
  set privateKeyPath(String privateKeyPath);

  String get certificatePassword;
  set certificatePassword(String certificatePassword);

  bool get enableHttp2;
  set enableHttp2(bool enableHttp2);

  bool get enableTls13;
  set enableTls13(bool enableTls13);

  List<String> get tlsVersions;
  set tlsVersions(List<String> tlsVersions);

  List<String> get cipherSuites;
  set cipherSuites(List<String> cipherSuites);

  bool get clientCertificateRequired;
  set clientCertificateRequired(bool clientCertificateRequired);

  String get trustedCaCertificatePath;
  set trustedCaCertificatePath(String trustedCaCertificatePath);

  bool isValid();
  Future<String> getCertificate();
  Future<String> getPrivateKey();
}

class _HttpsConfigure implements HttpsConfigure {
  bool _enabled;
  String _certificatePath;
  String _privateKeyPath;
  String _certificatePassword;
  bool _enableHttp2;
  bool _enableTls13;
  List<String> _tlsVersions;
  List<String> _cipherSuites;
  bool _clientCertificateRequired;
  String _trustedCaCertificatePath;

  _HttpsConfigure();

  @override
  bool get enabled => _enabled;

  @override
  set enabled(bool enabled) => _enabled = enabled;

  @override
  String get certificatePath => _certificatePath;

  @override
  set certificatePath(String certificatePath) => _certificatePath = certificatePath;

  @override
  String get privateKeyPath => _privateKeyPath;

  @override
  set privateKeyPath(String privateKeyPath) => _privateKeyPath = privateKeyPath;

  @override
  String get certificatePassword => _certificatePassword;

  @override
  set certificatePassword(String certificatePassword) => _certificatePassword = certificatePassword;

  @override
  bool get enableHttp2 => _enableHttp2;

  @override
  set enableHttp2(bool enableHttp2) => _enableHttp2 = enableHttp2;

  @override
  bool get enableTls13 => _enableTls13;

  @override
  set enableTls13(bool enableTls13) => _enableTls13 = enableTls13;

  @override
  List<String> get tlsVersions => _tlsVersions;

  @override
  set tlsVersions(List<String> tlsVersions) => _tlsVersions = tlsVersions;

  @override
  List<String> get cipherSuites => _cipherSuites;

  @override
  set cipherSuites(List<String> cipherSuites) => _cipherSuites = cipherSuites;

  @override
  bool get clientCertificateRequired => _clientCertificateRequired;

  @override
  set clientCertificateRequired(bool clientCertificateRequired) => _clientCertificateRequired = clientCertificateRequired;

  @override
  String get trustedCaCertificatePath => _trustedCaCertificatePath;

  @override
  set trustedCaCertificatePath(String trustedCaCertificatePath) => _trustedCaCertificatePath = trustedCaCertificatePath;

  @override
  Future<dynamic> init(ApplicationConfiguration applicationConfiguration) async {
    _enabled = applicationConfiguration.get(HTTPS_ENABLED);
    _certificatePath = applicationConfiguration.get(HTTPS_CERTIFICATE_PATH);
    _privateKeyPath = applicationConfiguration.get(HTTPS_PRIVATE_KEY_PATH);
    _certificatePassword = applicationConfiguration.get(HTTPS_CERTIFICATE_PASSWORD);
    _enableHttp2 = applicationConfiguration.get(HTTPS_ENABLE_HTTP2);
    _enableTls13 = applicationConfiguration.get(HTTPS_ENABLE_TLS13);
    _tlsVersions = ConfigureUtil.convertToListString(applicationConfiguration.get(HTTPS_TLS_VERSIONS));
    _clientCertificateRequired = applicationConfiguration.get(HTTPS_CLIENT_CERTIFICATE_REQUIRED);
    _trustedCaCertificatePath = applicationConfiguration.get(HTTPS_TRUSTED_CA_CERTIFICATE_PATH);
  }

  @override
  bool isValid() {
    if (!enabled) return true;

    if (certificatePath == null || certificatePath.isEmpty) {
      return false;
    }

    if (privateKeyPath == null || privateKeyPath.isEmpty) {
      return false;
    }

    // 检查证书文件是否存在
    File certFile = File(certificatePath);
    if (!certFile.existsSync()) {
      return false;
    }

    // 检查私钥文件是否存在
    File keyFile = File(privateKeyPath);
    if (!keyFile.existsSync()) {
      return false;
    }

    return true;
  }

  @override
  Future<String> getCertificate() async {
    if (certificatePath == null) return null;
    File file = File(certificatePath);
    if (!await file.exists()) return null;
    return await file.readAsString();
  }

  @override
  Future<String> getPrivateKey() async {
    if (privateKeyPath == null) return null;
    File file = File(privateKeyPath);
    if (!await file.exists()) return null;
    return await file.readAsString();
  }
}

