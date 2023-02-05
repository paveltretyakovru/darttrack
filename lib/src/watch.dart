import 'package:watcher/src/controller.dart';

void watch(String dir, String script) {
  try {
    Controller(dir, script);
  } on Exception catch (e) {
    print('Controller error: $e');
  }
}