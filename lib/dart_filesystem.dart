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

  bool existsSync() => fs.existsSync(path);

  Future<FileSystemEntity> rename(String newPath) {
    return fs.rename(path, newPath).then((_) { 
      return fs.stat(newPath)
          .then((stat) {
            if (stat.isDirectory) {
              return new Directory(newPath);
            } else if (stat.isSymbolicLink) {
              return new Link(newPath);
            } else {
              return new File(newPath);
            }
          });
    });
  }

  FileSystemEntity renameSync(String newPath) {
    fs.renameSync(path, newPath);
    
    var stat = fs.statSync(newPath);
    if (stat.isDirectory) {
      return new Directory(newPath);
    } else if (stat.isSymbolicLink) {
      return new Link(newPath);
    } else {
      return new File(newPath);
    }
  }

  Future<fs.FileStat> stat() => fs.stat(path);

  Future<fs.FileStat> lstat() => fs.lstat(path);  

  fs.FileStat statSync() => fs.statSync(path);

  fs.FileStat lstatSync() => fs.lstatSync(path);  

  Future<DateTime> lastModified() {
    return fs.stat(path).then((stat) => stat.mtime);
  }

  DateTime lastModifiedSync() => fs.statSync(path).mtime;

  Future<FileSystemEntity> _delete({bool recursive: false});

  Future<FileSystemEntity> delete({bool recursive: false}) {
    return _delete(recursive: recursive);
  }

}


class File extends FileSystemEntity {

  File(String path) 
      : super(path);

  File get absolute => new File(fs.realPathSync(path));

  String get ext => pathModule.extname(path);

  Future<File> create({bool recursive: false}) {
    return exists().then((exists) {
      if (exists) {
        return this;
      } else {
        if (!recursive) {
          return fs.createFile(path).then((_) => this);
        } else {
          return parent.create(recursive: true)
            .then((_) => fs.createFile(path)).then((_) => this);
        }
      }
    });
  }

  void createSync({bool recursive: false}) {
    if (!existsSync()) {
      if (recursive) {
        parent.createSync(recursive: true);
      }
      fs.createFileSync(path);
    }
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

  Future<int> length() {
   return fs.stat(path).then((stat) => stat.size); 
  }

  int lengthSync() => fs.statSync(path).size;

  Stream<List<int>> openRead([int start, int end]) {
    return fs.openRead(path, start: start, end: end);
  }

  Stream<String> openReadAsString([int start, int end]) {
    return fs.openReadAsString(path, start: start, end: end);
  }

  fs.FileInputStream<List<int>> openReadSync([int start, int end]) {
    return fs.openReadSync(path, start: start, end: end);
  }

  fs.FileInputStream<String> openReadSyncAsString([int start, int end]) {
    return fs.openReadSyncAsString(path, start: start, end: end);
  }

  fs.FileOutputStream<List<int>> openWrite({String flags, int mode}) {
    return fs.openWrite(path, mode: mode, flags: flags);
  }

  fs.FileOutputStream<String> openWriteAsString({String flags, int mode, String encoding: "utf8"}) {
    return fs.openWriteAsString(path, mode: mode, flags: flags, encoding: encoding);
  }

  Future<List<int>> readAsBytes() {
    return fs.readFile(path);
  }

  List<int> readAsBytesSync() => fs.readFileSync(path);

  Future<String> readAsString({String encoding: "utf8"}) {
    return fs.readFileAsString(path, encoding: encoding);
  }

  String readAsStringSync({String encoding: "utf8"}) {
    return fs.readFileAsStringSync(path, encoding: encoding);
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

  List<String> readAsLinesSync({String encoding: "utf8"}) {
    return _decodeLines(readAsStringSync(encoding: encoding));
  }

  Future<File> writeAsBytes(List<int> data, {String flags, int mode}) {
    return fs.writeFile(path, data, flags: flags, mode: mode).then((_) => this);
  }

  void writeAsBytesSync(List<int> data, {String flags, int mode}) {
    fs.writeFileSync(path, data, flags: flags, mode: mode);
  }

  Future<File> writeAsString(String contents, 
              {String flags, int mode, String encoding: "utf8"}) {
    return fs.writeFileAsString(path, contents, 
        flags: flags, mode: mode, encoding: encoding).then((_) => this);
  }

  void writeAsStringSync(String contents, 
              {String flags, int mode, String encoding: "utf8"}) {
    return fs.writeFileAsStringSync(path, contents, 
        flags: flags, mode: mode, encoding: encoding);
  }
}

class Link extends FileSystemEntity {
  
  Link(String path) 
      : super(path);


  Future<Link> create(String target, {recursive: false}) {
    return exists().then((exists) {
      if (exists) {
        return this;
      } else {
        if (!recursive) {
          return fs.symlink(path, target).then((_) => this);
        } else {
          return parent.create(recursive: true)
            .then((_) => fs.symlink(path, target)).then((_) => this);
        }
      }
    });
  }

  void createSync(String target, {bool recursive: false}) {
    if (!existsSync()) {
      if (recursive) {
        parent.createSync(recursive: true);
      }
      fs.symlinkSync(path, target);
    }
  }

  Future<Link> _delete({bool recursive: false}) {
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

  Future<String> target() => fs.readlink(path);
  
  String targetSync() => fs.readlinkSync(path);

  Future<Link> update(String target) => fs.symlink(path, target);

  void updateSync(String target) => fs.symlinkSync(path, target);
  
}


class Directory extends FileSystemEntity {
  
  Directory(String path) 
      : super(path);


  Future<Directory> create({bool recursive: false}) {
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

  void createSync({bool recursive: false}) {
    if (!existsSync()) {
      if (recursive) {
        parent.createSync(recursive: true);
      }
      fs.createDirSync(path);
    }
  }

  Stream<FileSystemEntity> list({bool recursive: false, bool followLinks: true}) {
    
    var controller;
    var paused = false;

    var state = null;

    var canceled = false;

    doStat(fpath) {
      if (followLinks) {
        return fs.stat(fpath);
      }
      return fs.lstat(fpath);
    };

    saveState() {
      state = new Completer();
      return state.future;
    };

    var handleDir;

    listEntity(Directory parent, String filename) {
      var filePath = pathModule.join([parent.path, filename]);

      return doStat(filePath)
          .then((stat) {
            var entity;
            if (stat.isDirectory) {
              entity = new Directory(filePath);
            } else if (stat.isSymbolicLink) {
              entity = new Link(filePath);
            } else {
              entity = new File(filePath);
            }

            if (!canceled) {
              controller.add(entity);
              if (recursive && entity is Directory) {
                return handleDir(entity);
              }
            }

          });
    } 

    listDir(Directory dir) {
      return fs.readDir(dir.path).then((filenames) {
        return Future.forEach(filenames, (filename) {
            if (canceled) {
              return null;
            }
            if (paused) {
              return saveState().then((_) => listEntity(dir, filename));
            }
             
            return listEntity(dir, filename);           
          });
      });
    }

    handleDir = (Directory dir) {
      if (canceled) {
        return null;
      }

      Future f;
      if (paused) {
        f = saveState().then((_) => listDir(dir));
      } else {
        f = listDir(dir);
      }

      return f.catchError((error) {
        controller.addError(error);
      });
    };

    onStart() {
      handleDir(this).then((_) {
        if (!canceled) {
          controller.close();
        }
      });
    };

    onPause() => paused = true;

    onResume() {
      paused = false;
      if (state != null) {
        state.complete();
        state = null;
      }
    };

    onCancel() {
      canceled = true;
      state = null;
      controller = null;
    };

    controller = new StreamController<FileSystemEntity>(
        onListen: onStart,
        onPause: onPause,
        onResume: onResume,
        onCancel: onCancel);

    return controller.stream;
  }

  List<FileSystemEntity> listSync({bool recursive: false, bool followLinks: true}) {
    
    var files = [];

    var doStat = (fpath) {
      if (followLinks) {
        return fs.statSync(fpath);
      }
      return fs.lstatSync(fpath);
    };

    fs.readDirSync(path).map((filename) {
      var filePath = pathModule.join([path, filename]);
      var stat = doStat(filePath);
      if (stat.isDirectory) {
        return new Directory(filePath);
      } else if (stat.isSymbolicLink) {
        return new Link(filePath);
      } else {
        return new File(filePath);
      }
    }).forEach((entity) {
      files.add(entity);
      if(recursive && entity is Directory) {
        files.addAll(entity.listSync(recursive: true));
      }
    });

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
          return fs.lstat(filePath)
              .then((stat) {
                if (stat.isDirectory) {
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
      if (fs.lstatSync(filePath).isDirectory) {
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
