import 'dart:io';

class ApplicationHelper {
  // 确保response被正确的释放并关闭
  static Future<bool> makeSureResponseRelease(HttpResponse res) async {
    await res.flush();
    await res.close();
    return true;
  }
}
