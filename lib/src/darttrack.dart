/// Copyright © 2023 Pavel Tretyakov. All rights reserved.

import 'controller.dart';

/// Main function of the application
///
/// Start watch [dir] files changes and run [script] when is it happened.
void darttrack(List<String> arguments) {
  try {
    Controller(arguments);
  } on Exception catch (e) {
    print('Controller error: $e');
  }
}
