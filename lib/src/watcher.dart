/// Copyright © 2023 Pavel Tretyakov. All rights reserved.

import 'dart:async';
import 'dart:io';
import 'types.dart';

/// Event types:
/// 1 - create
/// 2 - update
/// 4 - delete
/// 8 - rename

class Watcher {
  String path;

  /// propoginate watch change controller
  bool bubl = false;
  bool debug = false;

  late Directory directory;
  late Stream<FileSystemEvent> watchStream;
  late StreamSubscription<FileSystemEvent> subscription;

  ChangeHandler handler;

  Watcher(this.path, this.handler, this.debug) {
    directory = Directory(path);

    if (!directory.existsSync()) {
      throw Exception('Directory is not exists');
    }

    watch();
  }

  watch() {
    watchStream = directory.watch();

    if (debug) {
      print('Start watching "$path"...');
    }

    subscription = watchStream.listen(onChange);
  }

  stop() async {
    await subscription.cancel();
  }

  onChange(FileSystemEvent event) {
    if (bubl) return;
    bubl = true;

    Future.delayed(const Duration(milliseconds: 300), (() {
      handler(event);

      bubl = false;
    }));
  }
}
