import 'controller.dart';

void darttrack(String dir, String script) {
  try {
    Controller(dir, script);
  } on Exception catch (e) {
    print('Controller error: $e');
  }
}
