import 'dart:io';

import 'package:watcher/src/watcher.dart';

class Controller {
  bool runned = false;
  String path;
  String script;
  List<Watcher> watchers = [];

  late Directory root;

  Controller(this.path, this.script) {
    root = Directory(path);

    if (!root.existsSync()) {
      throw Exception('Directory "$path" is not exists');
    }

    watchers.add(Watcher(path, changeHandler, false));

    _scanRoot(debug: false);
    _runScript();
  }

  changeHandler(FileSystemEvent event) {
    _scanRoot();
    _runScript();
  }

  _runScript() {
    if (!runned) {
      runned = true;

      print('Script runing...');
      Process.run('dart', ['run', script]).then((result) {
        stdout.write(result.stdout);
        stderr.write(result.stderr);

        runned = false;
        print('Watching changes...');
      }).onError((error, stackTrace) {
        runned = false;
        print('Watching changes...');
      });
    }
  }

  _scanRoot({bool debug = true}) {
    // Scan to removed directories
    List<Watcher> watchersToDelete = [];
    for (var watcher in watchers) {
      if (!watcher.directory.existsSync()) {
        watchersToDelete.add(watcher);
      }
    }

    // Stop and remove removed watchers
    for (var watcher in watchersToDelete) {
      watcher.stop();
      watchers.remove(watcher);
    }

    // Scan to new directories
    for (FileSystemEntity entity in root.listSync(recursive: true)) {
      var find = watchers.where((element) => element.path == entity.path);

      if (entity is Directory && find.isEmpty) {
        watchers.add(Watcher(entity.path, changeHandler, debug));
      }
    }
  }
}