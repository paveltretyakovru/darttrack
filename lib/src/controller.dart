/// Copyright © 2023 Pavel Tretyakov. All rights reserved.

import 'dart:io';
import 'package:argenius/argenius.dart';

import 'watcher.dart';

const undefinedSroucesMessage = '''
Watch sources is not defined.
Use --watch argument or first nonamed argument to watch directory changes.

Example:

dartrack --watch ./watch/this/dir/to/changes ...

or:

dratrack ./watch/this/dir/to/changes ...
''';

const undefinedScriptMessage = '''
Script to run is not defined.
Use --script argument or second nonamed argument to run script,

Examples:

drtrack ./watch/dir ./path/to/run/script.dart
---
drtrack ./watch/dir --script ./path/to/run/script.dart
---
drtrack --watch ./watch/dir --script ./path/to/run/script.dart
''';

class Controller {
  bool _compiling = false;
  Process? _process;
  Future<dynamic>? _errstream;
  Future<dynamic>? _outstream;

  String? exec;
  String? script;
  late String rootPath;
  List<Watcher> watchers = [];

  late Directory root;

  Controller(List<String> arguments) {
    _praseArguments(arguments);

    root = Directory(rootPath);

    if (!root.existsSync()) {
      throw Exception('Directory "$rootPath" is not exists');
    }

    watchers.add(Watcher(rootPath, changeHandler, false));

    _scanRoot(debug: false);
    _runHandler();
  }

  changeHandler(FileSystemEvent event) {
    _scanRoot();
    _runHandler();
  }

  _runHandler() {
    if (script != null) {
      _runScript(script as String);
    } else if (exec != null) {
      _runExec(exec as String);
    }
  }

  _praseArguments(List<String> arguments) {
    argenius.parse(arguments);

    print('watch: ${argenius.named['watch']}');
    print('script: ${argenius.named['script']}');
    print('named: ${argenius.named}');

    if (argenius.named['watch'] != null) {
      rootPath = argenius.named['watch'] as String;
    } else if (argenius.ordered.isNotEmpty) {
      rootPath = argenius.ordered[0];
    } else {
      throw Exception(undefinedSroucesMessage);
    }

    exec = argenius.named['exec'];

    if (argenius.named['script'] != null) {
      script = argenius.named['script'];
    } else if (argenius.ordered.asMap().containsKey(1)) {
      script = argenius.ordered[1];
    }
  }

  _runScript(String commandToRun) async {
    if (!_compiling) {
      _compiling = true;

      if (_process != null && _process!.kill()) {
        print('Proccess (${_process!.pid}) is killed');
      }

      print('Starting script...');

      if (_outstream != null) {
        await _outstream;
        await _errstream;
      }

      Process.start('dart', ['run', commandToRun]).then((result) {
        print('Script started (pid=${result.pid}). Watching changes...');

        _process = result;
        _compiling = false;

        // For dark days
        // result.stdout.listen((List<int> data) {
        //   print('Data ${utf8.decode(data)}');
        // });

        _outstream = stdout.addStream(result.stdout);
        _errstream = stderr.addStream(result.stderr);
      }).onError((error, stackTrace) {
        _compiling = false;
        print('Run script error ($error). Watching changes...');
      });
    }
  }

  _runExec(String scriptToRun) async {
    List<String> args = Argenius.stringToList(scriptToRun);

    if (!_compiling && args.isNotEmpty) {
      String cmd = args.removeAt(0);

      _compiling = true;

      if (_process != null && _process!.kill()) {
        print('Proccess (${_process!.pid}) is killed');
      }

      print('Starting script...');

      if (_outstream != null) {
        await _outstream;
        await _errstream;
      }

      Process.start(cmd, args).then((result) {
        print('Executing $cmd with arguments $args');
        print('Script started (pid=${result.pid}). Watching changes...');

        _process = result;
        _compiling = false;

        _outstream = stdout.addStream(result.stdout);
        _errstream = stderr.addStream(result.stderr);
      }).onError((error, stackTrace) {
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
