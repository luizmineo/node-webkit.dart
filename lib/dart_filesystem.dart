library dart_filesystem;

import 'dart:async';
import 'dart:convert';

import 'package:node-webkit/path.dart' as pathModule;
import 'package:node-webkit/node_filesystem.dart' as fs;


abstract class FileSystemEntity {

  static Future<bool> isFile(String path) 
      => fs.stat(path).then((stat) => stat.isFile);

  static bool isFileSync(String path) 
      => fs.statSync(path).isFile;

  static Future<bool> isDirectory(String path) 
      => fs.stat(path).then((stat) => stat.isDirectory);

  static bool isDirectorySync(String path) 
      => fs.statSync(path).isDirectory;

  static Future<bool> isLink(String path) 
      => fs.stat(path).then((stat) => stat.isSymbolicLink);  
  
  static bool isLinkSync(String path) 
      => fs.statSync(path).isSymbolicLink;  

  static String parentOf(String path) => pathModule.dirname(path);

  final String path;


  FileSystemEntity(this.path);

  String get absolutePath => fs.realPathSync(path);

  String get name => pathModule.basename(path);

  Directory get parent => new Directory(pathModule.dirname(path));

  Future<bool> exists() => fs.exists(path);

  Future<FileSystemEntity> rename(String newPath) {
    return fs.rename(path, newPath).then((_) => new File(newPath));
  }

  Future<fs.FileStat> stat() => fs.stat(path);

  Future<fs.FileStat> lstat() => fs.lstat(path);  

  fs.FileStat statSync() => fs.statSync(path);

  fs.FileStat lstatSync() => fs.lstatSync(path);  

  Future<FileSystemEntity> _delete({bool recursive: false});

  Future<FileSystemEntity> delete({bool recursive: false}) {
    _delete(recursive: recursive);
  }

}


class File extends FileSystemEntity {

  File(String path) 
      : super(path);

  String get ext => pathModule.extname(path);

  Future<File> create() {
    return exists().then((exists) {
      if (exists) {
        return this;
      } else {
        return fs.createFile(path).then((_) => this);
      }
    });
  }

  Future<File> _delete({bool recursive: false}) {
    if(recursive) {
      return new Directory(path)._delete(recursive: true).then((_) => this);
    }
    return fs.deleteFile(path).then((_) => this);
  }

  void _deleteSync({bool recursive: false}) {
    if(recursive) {
      return new Directory(path)._deleteSync(recursive: true);
    }
    fs.deleteFileSync(path);
  }

  Future<DateTime> lastModified() {
    return fs.stat(path).then((stat) => stat.mtime);
  }

  Future<int> length() {
   return fs.stat(path).then((stat) => stat.size); 
  }

  Stream<List<int>> openRead([int start, int end]) {
    return fs.openRead(path, start: start, end: end);
  }

  Stream<String> openReadAsString([int start, int end]) {
    return fs.openReadAsString(path, start: start, end: end);
  }

  fs.FileOutputStream<List<int>> openWrite({String flags: "w", int mode: 0666}) {
    return fs.openWrite(path, mode: mode, flags: flags);
  }

  fs.FileOutputStream<String> openWriteAsString({String flags: "w", int mode: 0666, String encoding: "utf8"}) {
    return fs.openWriteAsString(path, mode: mode, flags: flags, encoding: encoding);
  }

  Future<List<int>> readAsBytes() {
    return fs.readFile(path);
  }

  Future<String> readAsString({String encoding: "utf8"}) {
    return fs.readFileAsString(path, encoding: encoding);
  }

  List<String> _decodeLines(String data) {
    var list = [];
    var controller = new StreamController(sync: true);
    var error = null;

    controller.stream
        .transform(new LineSplitter())
        .listen((line) => list.add(line), onError: (e) => error = e);
    controller.add(data);
    controller.close();
    if (error != null) {
      throw error;
    }

    return list;
  }

  Future<List<String>> readAsLines({String encoding: "utf8"}) {
    return readAsString(encoding: encoding).then((data) {
      return _decodeLines(data);
    });
  }

  Future<File> writeAsBytes(List<int> data, {String flags: "w", int mode: 0666}) {
    return fs.writeFile(path, data, flags: flags, mode: mode).then((_) => this);
  }

  Future<File> writeAsString(String contents, 
              {String flags: "w", int mode: 0666, String encoding: "utf8"}) {
    return fs.writeFileAsString(path, contents, 
        flags: flags, mode: mode, encoding: encoding).then((_) => this);
  }
}


class Directory extends FileSystemEntity {
  
  Directory(String path) 
      : super(path);


  Future<Directory> create({recursive: false}) {
    return exists().then((exists) {
      if (exists) {
        return this;
      } else {
        if (!recursive) {
          return fs.createDir(path).then((_) => this);
        }

        return parent.create(recursive: true)
            .then((_) => fs.createDir(path)).then((_) => this);
      }
    });
  }

  Stream<FileSystemEntity> list({bool recursive: false}) {
    
    var controller;
    var paused = false;

    var stack = [this];
    var canceled = false;

    readDir() {
      if (paused || canceled) {
        return;
      }

      if (stack.isEmpty) {
        controller.close();
        return;
      }

      var dir = stack.removeAt(0);
      fs.readDir(dir.path).then((filenames) {

        return Future.wait(
          filenames.map((filename) {

            var filePath = pathModule.join([dir.path, filename]);

            return FileSystemEntity.isDirectory(filePath)
                .then((isDirectory) {
                  if (isDirectory) {
                    return new Directory(filePath);
                  }
                  return new File(filePath);
                });
          })
        ).then((entities) {
          if(canceled) {
            return;
          }

          var stackPos = 0;
          entities.forEach((entity) {
            if(recursive && entity is Directory) {
              stack.insert(stackPos++, entity);  
            }
            controller.add(entity);
          });
        });
      }).then((_) => readDir())
      .catchError((error) {
        controller.addError(error);
        controller.close();
      });
    }

    var onStart = () {
      readDir();
    };

    var onPause = () => paused = true;

    var onResume = () {
      paused = false;
      readDir();
    };

    var onCancel = () {
      canceled = true;
    };

    controller = new StreamController<FileSystemEntity>(
        onListen: onStart,
        onPause: onPause,
        onResume: onResume,
        onCancel: onCancel);

    return controller.stream;
  }

  List<FileSystemEntity> listSync({bool recursive: false}) {
    
    var files = [];
    var subdirs = [];
    fs.readDirSync(path).map((filename) {
      var filePath = pathModule.join([path, filename]);
      if (FileSystemEntity.isDirectorySync(filePath)) {
        return new Directory(filePath);
      }
      return new File(filePath);
    }).forEach((entity) {
      files.add(entity);
      if(recursive && entity is Directory) {
        subdirs.add(entity);
      }
    });

    subdirs.forEach((dir) => files.addAll(dir.listSync(recursive: true)));

    return files;
  }

  Future<Directory> _delete({bool recursive: false}) {
    if(!recursive) {
      return fs.deleteDir(path).then((_) => this);
    }

    return fs.readDir(path).then((filenames) {
      if(filenames.isEmpty) {
        return null;
      }
      return Future.wait(
        filenames.map((filename) {
          var filePath = pathModule.join([path, filename]);
          return FileSystemEntity.isDirectory(filePath)
              .then((isDirectory) {
                if (isDirectory) {
                  return new Directory(filePath);
                }
                return new File(filePath);
              });
        })
      ).then((entities) {
        var subDirs = [];
        var files = [];
        entities.forEach((entity) {
          if(entity is Directory) {
            subDirs.add(entity);
          } else {
            files.add(entity);
          }
        });

        return Future.forEach(subDirs, (subDir) 
            => subDir._delete(recursive: true))
                .then((_) 
                  => Future.forEach(files, (file) => file._delete())
                );
      });
    }).then((_) {
      return fs.deleteDir(path).then((_) => this);
    });
  }

  void _deleteSync({bool recursive: false}) {
    if(!recursive) {
      fs.deleteDirSync(path);
      return;
    }

    var files = [];
    var subdirs = [];
    fs.readDirSync(path).map((filename) {
      var filePath = pathModule.join([path, filename]);
      if (FileSystemEntity.isDirectorySync(filePath)) {
        return new Directory(filePath);
      }
      return new File(filePath);
    }).forEach((entity) {
      files.add(entity);
      if(recursive && entity is Directory) {
        subdirs.add(entity);
      }
    });

    subdirs.forEach((dir) => dir._deleteSync(recursive: true));
    files.forEach((file) => file._deleteSync());
    fs.deleteDirSync(path);
  }
}
