import 'dart:io';
import 'dart:math';

Future<File> createTempFile(List<int> data) async {
  Directory tempDir = await Directory.systemTemp.createTemp('q_temp_dir');
  File tempFile = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_${Random.secure().nextInt(2 ^ 16)}.jpg');
  return tempFile.writeAsBytes(data);
}
