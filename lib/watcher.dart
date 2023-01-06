import 'dart:io';

int calculate() {
  return 6 * 7;
}

void watch() {
  File file = File('bin/test.txt');
  Directory directory = Directory('lib');

  file.exists().then((value) => print('File exists: $value'));
  directory.exists().then((value) => print('Directory exists: $value'));

  Stream<FileSystemEvent> fileStream = file.watch();
  Stream<FileSystemEvent> directoryStream = directory.watch(recursive: true);

  fileStream.listen((event) {
    print('File stream event ${event.type}');
  });

  // here i am
  bool watching = false;
  directoryStream.listen((event) {
    if (watching) return;
    watching = true;

    Future.delayed(const Duration(milliseconds: 300), (() {
      print('Directory stream event ${event.type}');  
      watching = false;
    }));
  });
}