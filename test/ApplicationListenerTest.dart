import 'package:Q/Q.dart';
import 'package:Q/src/listener/ApplicationStartingListener.dart';
import 'package:Q/src/listener/ApplicationEnvironmentPreparedListener.dart';
import 'package:Q/src/listener/ApplicationContextInitializedListener.dart';
import 'package:Q/src/listener/ApplicationPreparedListener.dart';
import 'package:Q/src/listener/ApplicationReadyListener.dart';
import 'package:Q/src/listener/ApplicationFailedListener.dart';
import 'package:test/test.dart';

void main() {
  group('ApplicationListener', () {
    Application application;

    setUp(() {
      application = Application()
        ..args(['--application.environment=dev', '--application.resourceDir=/test/example/resources']);
    });

    test('Application lifecycle listen', () async {
      // 重新创建应用实例，确保它不是 null
      application = Application()
        ..args(['--application.environment=dev', '--application.resourceDir=/test/example/resources']);
      
      List<String> lifecycleEvents = [];

      // 添加各个生命周期监听器
      application.addListener(ApplicationStartingListener(() async {
        lifecycleEvents.add('STARTING');
        print('Application is starting...');
      }));

      application.addListener(ApplicationContextInitializedListener(() async {
        lifecycleEvents.add('CONTEXT_INITIALIZED');
        print('ApplicationContext initialized');
      }));

      application.addListener(ApplicationEnvironmentPreparedListener((environment) async {
        lifecycleEvents.add('ENVIRONMENT_PREPARED');
        print('Environment prepared: $environment');
      }));

      application.addListener(ApplicationPreparedListener(() async {
        lifecycleEvents.add('PREPARED');
        print('Application prepared');
      }));

      application.addListener(ApplicationStartUpListener(() async {
        lifecycleEvents.add('STARTUP');
        print('Application started up');
      }));

      application.addListener(ApplicationReadyListener(() async {
        lifecycleEvents.add('READY');
        print('Application ready');
      }));

      application.addListener(ApplicationCloseListener((dynamic prevCloseableResult) async {
        lifecycleEvents.add('CLOSE');
        print('Application closing');
      }));

      application.addListener(ApplicationFailedListener((error, {StackTrace stackTrace}) async {
        lifecycleEvents.add('FAILED');
        print('Application failed: $error');
      }));

      // 初始化应用
      await application.init();

      // 启动服务器
      application.listen(2333);

      // 等待一段时间，确保所有启动事件都被触发
      await Future.delayed(Duration(seconds: 1));

      // 验证启动相关事件是否按顺序触发
      expect(lifecycleEvents, containsAll(['STARTING', 'CONTEXT_INITIALIZED', 'ENVIRONMENT_PREPARED', 'PREPARED', 'STARTUP', 'READY']));
      expect(lifecycleEvents.indexOf('STARTING'), lessThan(lifecycleEvents.indexOf('CONTEXT_INITIALIZED')));
      expect(lifecycleEvents.indexOf('CONTEXT_INITIALIZED'), lessThan(lifecycleEvents.indexOf('ENVIRONMENT_PREPARED')));
      expect(lifecycleEvents.indexOf('ENVIRONMENT_PREPARED'), lessThan(lifecycleEvents.indexOf('PREPARED')));
      expect(lifecycleEvents.indexOf('PREPARED'), lessThan(lifecycleEvents.indexOf('STARTUP')));
      expect(lifecycleEvents.indexOf('STARTUP'), lessThan(lifecycleEvents.indexOf('READY')));

      // 关闭应用
      await application.close();

      // 等待一段时间，确保关闭事件被触发
      await Future.delayed(Duration(seconds: 1));

      // 验证关闭事件是否被触发
      expect(lifecycleEvents, contains('CLOSE'));
      expect(application.applicationContext.currentStage, ApplicationStage.STOPPED);
    });

    test('Application error listen', () async {
      // 重新创建应用实例，确保它不是 null
      application = Application()
        ..args(['--application.environment=dev', '--application.resourceDir=/test/example/resources']);
      
      List<String> events = [];

      // 添加错误监听器
      print('Adding error listener...');
      application.addListener(ApplicationErrorListener((error, {StackTrace stackTrace}) async {
        print('Error listener called with error: $error');
        events.add('ERROR');
        print('Error occurred: $error');
      }));

      // 初始化应用
      print('Initializing application...');
      await application.init();

      // 手动触发错误事件
      print('Triggering error event...');
      application.trigger(ApplicationListenerType.ERROR, ['Test error']);

      // 等待一段时间，确保错误事件被触发
      print('Waiting for error event...');
      await Future.delayed(Duration(milliseconds: 500));

      // 输出 events 列表
      print('Events list: $events');

      // 验证错误事件是否被触发
      expect(events, contains('ERROR'));
    });

    tearDown(() {
      application = null;
    });
  });
}
