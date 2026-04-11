import 'package:Q/Q.dart';

class TestHelper {
  /// 初始化测试应用
  static Future<Application> initTestApplication() async {
    Application application = Application();
    // 设置命令行参数
    application.args(['--application.environment=dev', '--application.resourceDir=/test/example/resources']);
    // 初始化应用
    await application.init();
    return application;
  }
  
  /// 启动测试服务器
  static void startTestServer(Application application, int port) {
    application.listen(port);
  }
  
  /// 等待应用启动完成
  static Future<void> waitForApplicationStart() async {
    await Future.delayed(Duration(milliseconds: 500));
  }
  
  /// 关闭测试应用
  static Future<void> closeTestApplication(Application application) async {
    if (application != null) {
      try {
        await application.close();
      } catch (e) {
        // 忽略关闭时的错误
      }
    }
  }
}
