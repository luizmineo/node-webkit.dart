library filesystem;

import 'dart:async';
import 'dart:convert';


import 'src/filesystem/nodeFsWrapper.dart';
export 'src/filesystem/nodeFsWrapper.dart' show FileSystemException, FileStat, FileOutputStream;

abstract class FileSystemEntity {

  static Future<bool> isFile(String path) 
      => new NodeFsWrapper().stat(path).then((stat) => stat.isFile);

  static Future<bool> isDirectory(String path) 
      => new NodeFsWrapper().stat(path).then((stat) => stat.isDirectory);

  static Future<bool> isLink(String path) 
      => new NodeFsWrapper().stat(path).then((stat) => stat.isSymbolicLink);  
  
  static String parentOf(String path) => new NodeFsWrapper().dirname(path);



  final NodeFsWrapper _nodeFs;

  final String path;


  FileSystemEntity(this.path) 
      : _nodeFs = new NodeFsWrapper();

  FileSystemEntity._withNodeObj(this._nodeFs, this.path);

  String get absolutePath => _nodeFs.realPathSync(path);

  Directory get parent => new Directory(_nodeFs.dirname(path));

  Future<bool> exists() => _nodeFs.exists(path);

  Future<FileSystemEntity> rename(String newPath) {
    return _nodeFs.rename(path, newPath).then((_) => new File(newPath));
  }

  Future<FileStat> stat() => _nodeFs.stat(path);

  Future<FileStat> lstat() => _nodeFs.lstat(path);  

  FileStat statSync() => _nodeFs.statSync(path);

  FileStat lstatSync() => _nodeFs.lstatSync(path);  

  Future<FileSystemEntity> _delete({bool recursive: false});

  Future<FileSystemEntity> delete({bool recursive: false}) {
    _delete(recursive: recursive);
  }

}


class File extends FileSystemEntity {

  File(String path) 
      : super(path);

  File._withNodeObj(NodeFsWrapper nodeFs, String path)
      : super._withNodeObj(nodeFs, path);

  Future<File> create() {
    return exists().then((exists) {
      if (exists) {
        return this;
      } else {
        return _nodeFs.createFile(path).then((_) => this);
      }
    });
  }

  Future<File> _delete({bool recursive: false}) {
    if(recursive) {
      return new Directory(path)._delete(recursive: true).then((_) => this);
    }
    return _nodeFs.deleteFile(path).then((_) => this);
  }

  void _deleteSync({bool recursive: false}) {
    if(recursive) {

    }
    _nodeFs.deleteFileSync(path);
  }

  Future<DateTime> lastModified() {
    return _nodeFs.stat(path).then((stat) => stat.mtime);
  }

  Future<int> length() {
   return _nodeFs.stat(path).then((stat) => stat.size); 
  }

  Stream<List<int>> openRead([int start, int end]) {
    return _nodeFs.openRead(path, start: start, end: end);
  }

  Stream<String> openReadAsString([int start, int end]) {
    return _nodeFs.openReadAsString(path, start: start, end: end);
  }

  FileOutputStream<List<int>> openWrite({String flags: "w", int mode: 0666}) {
    return _nodeFs.openWrite(path, mode: mode, flags: flags);
  }

  FileOutputStream<String> openWriteAsString({String flags: "w", int mode: 0666, String encoding: "utf8"}) {
    return _nodeFs.openWriteAsString(path, mode: mode, flags: flags, encoding: encoding);
  }

  Future<List<int>> readAsBytes() {
    return _nodeFs.readFile(path);
  }

  Future<String> readAsString({String encoding: "utf8"}) {
    return _nodeFs.readFileAsString(path, encoding: encoding);
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
    return _nodeFs.writeFile(path, data, flags: flags, mode: mode).then((_) => this);
  }

  Future<File> writeAsString(String contents, 
              {String flags: "w", int mode: 0666, String encoding: "utf8"}) {
    return _nodeFs.writeFileAsString(path, contents, 
        flags: flags, mode: mode, encoding: encoding).then((_) => this);
  }
}


class Directory extends FileSystemEntity {
  
  Directory(String path) 
      : super(path);

  Directory._withNodeObj(NodeFsWrapper nodeFs, String path)
      : super._withNodeObj(nodeFs, path);


  Future<Directory> create() {
    return exists().then((exists) {
      if (exists) {
        return this;
      } else {
        return _nodeFs.createDir(path).then((_) => this);
      }
    });
  }

  Stream<FileSystemEntity> list({bool recursive: false}) {
    
    var controller;
    var paused = false;

    var queue = [this];
    var canceled = false;

    readDir() {
      if (paused || canceled) {
        return;
      }

      if (queue.isEmpty) {
        controller.close();
        return;
      }

      var dir = queue.removeAt(0);
      _nodeFs.readDir(dir.path).then((paths) {
        return Future.wait(
          paths.map((path) {
            return FileSystemEntity.isDirectory(path)
                .then((isDirectory) {
                  if (isDirectory) {
                    return new Directory(path);
                  }
                  return new File(path);
                });
          })
        ).then((entities) {
          if(canceled) {
            return;
          }

          entities.forEach((entity) {
            if(recursive && entity is Directory) {
              queue.add(entity);  
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

    _nodeFs.readDirSync(path).map((path) {


    });

    return files;
  }

  Future<Directory> _delete({bool recursive: false}) {
    if(!recursive) {
      return _nodeFs.deleteDir(path).then((_) => this);
    }

    return _nodeFs.readDir(path).then((paths) {
      if(paths.isEmpty) {
        return null;
      }
      return Future.wait(
        paths.map((path) {
          return FileSystemEntity.isDirectory(path)
              .then((isDirectory) {
                if (isDirectory) {
                  return new Directory(path);
                }
                return new File(path);
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
      return _nodeFs.deleteDir(path).then((_) => this);
    });
  }

  void _deleteSync({bool recursive: false}) {
    if(!recursive) {
      _nodeFs.deleteDirSync(path);
      return;
    }


  }
}
