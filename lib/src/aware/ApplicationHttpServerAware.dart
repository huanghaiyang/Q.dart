import 'dart:io';

abstract class ApplicationHttpServerAware {
  void listen(int port, {InternetAddress internetAddress});
}
