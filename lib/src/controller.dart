import 'dart:io';

import 'package:watcher/src/watcher.dart';

class Controller {
  bool _compiling = false;
  Process? _process;
  Future<dynamic>? _errstream;
  Future<dynamic>? _outstream;

  String script;
  String rootPath;
  List<Watcher> watchers = [];

  late Directory root;

  Controller(this.rootPath, this.script) {
    root = Directory(rootPath);

    if (!root.existsSync()) {
      throw Exception('Directory "$rootPath" is not exists');
    }

    watchers.add(Watcher(rootPath, changeHandler, false));

    _scanRoot(debug: false);
    _runScript();
  }

  changeHandler(FileSystemEvent event) {
    _scanRoot();
    _runScript();
  }

  _runScript() async {
    if (!_compiling) {
      _compiling = true;

      File scriptFile = File(script);

      if (!scriptFile.existsSync()) {
        throw Exception('Script "$script" is not exists');
      }

      if (_process != null && _process!.kill()) {        
        print('Proccess (${_process!.pid}) is killed');
      }

      print('Starting script...');

      if (_outstream != null) {
        await _outstream;
        await _errstream;
      }

      Process
        .start('dart', ['run', script])
        .then((result) {
          print('Script started (pid=${result.pid}). Watching changes...');

          _process = result;
          _compiling = false;

          _outstream = stdout.addStream(result.stdout);
          _errstream = stderr.addStream(result.stderr);
        })
        .onError((error, stackTrace) {
          _compiling = false;
          print('Run script error ($error). Watching changes...');
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
