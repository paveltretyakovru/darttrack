import 'dart:async';
import 'dart:io';

// ignore: todo
// TODO: Fix twice run script on remove file

typedef ChangeHandler = void Function(FileSystemEvent event);

/// Event types:
/// 1 - create
/// 2 - update
/// 4 - delete
/// 8 - rename

int calculate() {
  return 6 * 7;
}

void watch(String dir, String script) {
  try {
    Controller(dir, script);
  } on Exception catch(e) {
    print('Controller error: $e');
  }
}


class Controller {
  String path;
  String script;
  List<Watcher> watchers = [];

  late Directory root;

  Controller(this.path, this.script) {
    root = Directory(path);

    if (!root.existsSync()) {
      throw Exception('Directory "$path" is not exists');
    }

    watchers.add(Watcher(path, changeHandler));

    _scanRoot();
    _runScript();
  }

  changeHandler(FileSystemEvent event) {
    _scanRoot();
    _runScript();
  }

  _runScript() {
    Process.run('dart', ['run', script]).then((result) {
      stdout.write(result.stdout);
      stderr.write(result.stderr);
    });
  }

  _scanRoot() {
    // Scan to removed directories
    List<Watcher> watchersToDelete = [];
    for(var watcher in watchers) {
      if (!watcher.directory.existsSync()) {
        print('Removing watcher ${watcher.path}');
        watchersToDelete.add(watcher);
      }
    }

    // Stop and remove removed watchers
    print('To delte: $watchersToDelete');
    for(var watcher in watchersToDelete) {
      watcher.stop();
      watchers.remove(watcher);
    }

    // Scan to new directories
    for(FileSystemEntity entity in root.listSync(recursive: true)) {
      var find = watchers.where((element) => element.path == entity.path);

      if (entity is Directory && find.isEmpty) {
        watchers.add(Watcher(entity.path, changeHandler));
      }
    }
  }
}

class Watcher {
  String path;

  /// propoginate watch change controller
  bool bubl = false;

  late Directory directory;
  late Stream<FileSystemEvent> watchStream;
  late StreamSubscription<FileSystemEvent> subscription;

  ChangeHandler handler;

  Watcher(this.path, this.handler) {
    directory = Directory(path);

    if (!directory.existsSync()) {
      throw Exception('Directory is not exists');
    }

    watch();
  }

  watch() {
    watchStream = directory.watch();

    print('Start watching "$path"...');

    subscription = watchStream.listen(onChange);
  }

  stop() async {
    await subscription.cancel();
  }

  onChange(FileSystemEvent event) {
    if (bubl) return;
    bubl = true;

    Future.delayed(const Duration(milliseconds: 1000), (() {
      handler(event);

      bubl = false;
    }));
  }
}