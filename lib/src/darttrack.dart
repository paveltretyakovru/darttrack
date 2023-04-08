import 'controller.dart';

/// Main function of the application
///
/// Start watch [dir] files changes and run [script] when is it happened.
void darttrack(String dir, String script) {
  try {
    Controller(dir, script);
  } on Exception catch (e) {
    print('Controller error: $e');
  }
}
