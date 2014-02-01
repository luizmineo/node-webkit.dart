/**
 * Classes to handle filesystem operations.
 *
 * This library is designed to look and behave as close as possible
 * to the dart:io package.
 */
library dart_filesystem;

import 'dart:async';
import 'dart:convert';

import 'package:node_webkit/path.dart' as pathModule;
import 'package:node_webkit/node_filesystem.dart' as fs;

/**
 * A [FileSystemEntity] is a common super class for [File], [Link] and [Directory] objects.
 *
 * [FileSystemEntity] objects are returned from directory listing operations. 
 * To determine if a FileSystemEntity is a [File] or a [Directory], perform a type check:
 *
 *     if (entity is File) (entity as File).readAsStringSync();
 *
 */
abstract class FileSystemEntity {

  /**
   * Checks if [path] is a file.
   */
  static Future<bool> isFile(String path) 
      => fs.stat(path).then((stat) => stat.isFile);

  /**
   * Synchronously checks if [path] is a file.
   */
  static bool isFileSync(String path) 
      => fs.statSync(path).isFile;

  /**
   * Checks if [path] is a directory.
   */
  static Future<bool> isDirectory(String path) 
      => fs.stat(path).then((stat) => stat.isDirectory);

  /**
   * Synchronously checks if [path] is a directory.
   */
  static bool isDirectorySync(String path) 
      => fs.statSync(path).isDirectory;

  /**
   * Checks if [path] is a link.
   */
  static Future<bool> isLink(String path) 
      => fs.stat(path).then((stat) => stat.isSymbolicLink);  
  
  /**
   * Synchronously checks if [path] is a link.
   */
  static bool isLinkSync(String path) 
      => fs.statSync(path).isSymbolicLink;  

  /**
   * Removes the final path component of a path, using the platform's path separator to split the path.
   */
  static String parentOf(String path) => pathModule.dirname(path);


  final String path;


  FileSystemEntity(this.path);

  /// The absolute path to [this]
  String get absolutePath => fs.realPathSync(path);

  /// The name of this entity
  String get name => pathModule.basename(path);

  /// The directory containing this. If this is a root directory, returns [this].
  Directory get parent => new Directory(pathModule.dirname(path));

  /**
   * Checks whether the file system entity with this path exists. Returns a Future<bool> that completes with the result.
   */
  Future<bool> exists() => fs.exists(path);

  /**
   * Synchronously checks whether the file system entity with this path exists.
   */
  bool existsSync() => fs.existsSync(path);

  /**
   * Renames this file system entity. Returns a Future<FileSystemEntity> that completes with a 
   * [FileSystemEntity] instance for the renamed file system entity.
   */
  Future<FileSystemEntity> rename(String newPath) {
    return fs.rename(path, newPath).then((_) { 
      return fs.lstat(newPath)
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

  /**
   * Synchronously renames this file system entity. Returns a [FileSystemEntity]
   * instance for the renamed entity.
   */
  FileSystemEntity renameSync(String newPath) {
    fs.renameSync(path, newPath);
    
    var stat = fs.lstatSync(newPath);
    if (stat.isDirectory) {
      return new Directory(newPath);
    } else if (stat.isSymbolicLink) {
      return new Link(newPath);
    } else {
      return new File(newPath);
    }
  }

  /// Calls the operating system's stat() function on the [path] of this [FileSystemEntity].
  Future<fs.FileStat> stat() => fs.stat(path);

  /// Calls the operating system's lstat() function on the [path] of this [FileSystemEntity].
  Future<fs.FileStat> lstat() => fs.lstat(path);  

  /**
   * Synchronously calls the operating system's stat() function on the path of this [FileSystemEntity].
   */
  fs.FileStat statSync() => fs.statSync(path);

  /**
   * Synchronously calls the operating system's stat() function on the path of this [FileSystemEntity].
   */
  fs.FileStat lstatSync() => fs.lstatSync(path);  

  /**
   * Get the last-modified time of the entity. 
   *
   * Returns a Future<DateTime> that completes with a [DateTime] object for the modification date.
   */
  Future<DateTime> lastModified() {
    return fs.stat(path).then((stat) => stat.mtime);
  }

  /**
   * Get the last-modified time of the file.
   *
   * Throws a [FileSystemException] if the operation fails.
   */
  DateTime lastModifiedSync() => fs.statSync(path).mtime;

  Future<FileSystemEntity> _delete({bool recursive: false});


  /**
   * Deletes this [FileSystemEntity].
   *
   * If the [FileSystemEntity] is a directory, and if [recursive] is false,
   * the directory must be empty. Otherwise, if [recursive] is true, the
   * directory and all sub-directories and files in the directories are
   * deleted. Links are not followed when deleting recursively. Only the link
   * is deleted, not its target.
   *
   * If [recursive] is true, the [FileSystemEntity] is deleted even if the type
   * of the [FileSystemEntity] doesn't match the content of the file system.
   * This behavior allows [delete] to be used to unconditionally delete any file
   * system object.
   *
   * Returns a [:Future<FileSystemEntity>:] that completes with this
   * [FileSystemEntity] when the deletion is done. If the [FileSystemEntity]
   * cannot be deleted, the future completes with an exception.
   */
  Future<FileSystemEntity> delete({bool recursive: false}) {
    return _delete(recursive: recursive);
  }

}

/**
 * A reference to a file on the file system.
 */
class File extends FileSystemEntity {

  File(String path) 
      : super(path);

  /**
   * Returns a [File] instance whose path is the absolute path to [this].
   *
   * The absolute path is computed by prefixing a relative path with the current working directory, 
   * and returning an absolute path unchanged.
   */
  File get absolute => new File(fs.realPathSync(path));

  /**
   * Returns the extension of this file.
   */
  String get ext => pathModule.extname(path);

  /**
   * Create the file. Returns a [:Future<File>:] that completes with
   * the file when it has been created.
   *
   * If [recursive] is false, the default, the file is created only if
   * all directories in the path exist. If [recursive] is true, all
   * non-existing path components are created.
   *
   * Existing files are left untouched by [create]. Calling [create] on an
   * existing file might fail if there are restrictive permissions on
   * the file.
   *
   * Completes the future with a [FileSystemException] if the operation fails.
   */
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

  /**
   * Synchronously create the file. Existing files are left untouched
   * by [createSync]. Calling [createSync] on an existing file might fail
   * if there are restrictive permissions on the file.
   *
   * If [recursive] is false, the default, the file is created
   * only if all directories in the path exist.
   * If [recursive] is true, all non-existing path components are created.
   *
   * Throws a [FileSystemException] if the operation fails.
   */
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

  /**
   * Get the length of the file. Returns a [:Future<int>:] that
   * completes with the length in bytes.
   */
  Future<int> length() {
   return fs.stat(path).then((stat) => stat.size); 
  }

  /**
   * Synchronously get the length of the file.
   *
   * Throws a [FileSystemException] if the operation fails.
   */
  int lengthSync() => fs.statSync(path).size;

  /**
   * Create a new independent [Stream] for the contents of this file.
   *
   * If [start] is present, the file will be read from byte-offset [start].
   * Otherwise from the beginning (index 0).
   *
   * If [end] is present, only up to byte-index [end] will be read. Otherwise,
   * until end of file.
   *
   * In order to make sure that system resources are freed, the stream
   * must be read to completion or the subscription on the stream must
   * be cancelled.
   */
  Stream<List<int>> openRead([int start, int end]) {
    return fs.openRead(path, start: start, end: end);
  }

  /**
   * Create a new independent [Stream] for the contents of this file.
   *
   * If [start] is present, the file will be read from byte-offset [start].
   * Otherwise from the beginning (index 0).
   *
   * If [end] is present, only up to byte-index [end] will be read. Otherwise,
   * until end of file.
   *
   * In order to make sure that system resources are freed, the stream
   * must be read to completion or the subscription on the stream must
   * be cancelled.
   */
  Stream<String> openReadAsString([int start, int end]) {
    return fs.openReadAsString(path, start: start, end: end);
  }

 /**
  * Open a FileInputStream<List<int>> for this file.
  */
  fs.FileInputStream<List<int>> openReadSync([int start, int end]) {
    return fs.openReadSync(path, start: start, end: end);
  }

  /**
  * Open a FileInputStream<String> for this file.
  */
  fs.FileInputStream<String> openReadAsStringSync([int start, int end]) {
    return fs.openReadAsStringSync(path, start: start, end: end);
  }

  /**
  * Open a FileOutputStream<List<int>> for this file.
  */
  fs.FileOutputStream<List<int>> openWrite({String flags, int mode}) {
    return fs.openWrite(path, mode: mode, flags: flags);
  }

  /**
  * Open a FileOutputStream<String> for this file.
  */
  fs.FileOutputStream<String> openWriteAsString({String flags, int mode, String encoding: "utf8"}) {
    return fs.openWriteAsString(path, mode: mode, flags: flags, encoding: encoding);
  }

  /**
   * Read the entire file contents as a list of bytes. Returns a
   * [:Future<List<int>>:] that completes with the list of bytes that
   * is the contents of the file.
   */
  Future<List<int>> readAsBytes() {
    return fs.readFile(path);
  }

  /**
   * Synchronously read the entire file contents as a list of bytes.
   *
   * Throws a [FileSystemException] if the operation fails.
   */
  List<int> readAsBytesSync() => fs.readFileSync(path);

  /**
   * Read the entire file contents as a string using the given
   * encoding.
   *
   * Returns a [:Future<String>:] that completes with the string once
   * the file contents has been read.
   */
  Future<String> readAsString({String encoding: "utf8"}) {
    return fs.readFileAsString(path, encoding: encoding);
  }

  /**
   * Synchronously read the entire file contents as a string using the
   * given encoding.
   *
   * Throws a [FileSystemException] if the operation fails.
   */
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

  /**
   * Read the entire file contents as lines of text using the given
   * encoding.
   *
   * Returns a [:Future<List<String>>:] that completes with the lines
   * once the file contents has been read.
   */
  Future<List<String>> readAsLines({String encoding: "utf8"}) {
    return readAsString(encoding: encoding).then((data) {
      return _decodeLines(data);
    });
  }

  /**
   * Synchronously read the entire file contents as lines of text
   * using the given encoding.
   *
   * Throws a [FileSystemException] if the operation fails.
   */
  List<String> readAsLinesSync({String encoding: "utf8"}) {
    return _decodeLines(readAsStringSync(encoding: encoding));
  }

  /**
   * Write a list of bytes to a file.
   */
  Future<File> writeAsBytes(List<int> data, {String flags, int mode}) {
    return fs.writeFile(path, data, flags: flags, mode: mode).then((_) => this);
  }

  /**
   * Synchronously write a list of bytes to a file.
   *
   * Throws a [FileSystemException] if the operation fails.
   */
  void writeAsBytesSync(List<int> data, {String flags, int mode}) {
    fs.writeFileSync(path, data, flags: flags, mode: mode);
  }

  /**
   * Write a string to a file.
   */
  Future<File> writeAsString(String contents, 
              {String flags, int mode, String encoding: "utf8"}) {
    return fs.writeFileAsString(path, contents, 
        flags: flags, mode: mode, encoding: encoding).then((_) => this);
  }

  /**
   * Synchronously write a string to a file.
   *
   * Throws a [FileSystemException] if the operation fails.
   */
  void writeAsStringSync(String contents, 
              {String flags, int mode, String encoding: "utf8"}) {
    return fs.writeFileAsStringSync(path, contents, 
        flags: flags, mode: mode, encoding: encoding);
  }

  /**
   * Copy this file. Returns a [Future<File>] that completes with a [File] instance for the copied file.
   *
   * If newPath identifies an existing file, that file is replaced. If newPath identifies an 
   * existing directory, the operation fails and the future completes with an exception.
   */
  Future<File> copy(String newPath) {
    return new Future.sync(() {

      var completer = new Completer();
      var stream = fs.openRead(path);
      var writer = fs.openWrite(newPath);

      stream.listen((data) {
        writer.write(data);
      }, onError: (err) {
        writer.close();
        completer.completeError(err);
      }, onDone: () {
        writer.close();
        completer.complete(new File(newPath));
      });

      return completer.future;
    });
  }

  /**
   * Synchronously copy this file. Returns a [File] instance for the copied file.
   *
   * If newPath identifies an existing file, that file is replaced. If newPath identifies an 
   * existing directory, the operation fails and the future completes with an exception.
   */
  File copySync(String newPath) {

    const length = 1024 * 64;
    int fdr = null, fdw = null;
    
    try {
      var buffer = new fs.Buffer(length);
      fdr = fs.openSync(path, "r");
      fdw = fs.openSync(newPath, "w");

      int bytesRead = 1, pos = 0;
      while (bytesRead > 0) {
        bytesRead = fs.readSync(fdr, buffer, 0, length, pos);
        fs.writeSync(fdw, buffer, 0, bytesRead);
        pos += bytesRead;
      }
    } finally {
      if (fdr != null) {
        fs.closeSync(fdr);
      }
      if (fdw != null) {
        fs.closeSync(fdw);
      }
    }


    return new File(newPath);
  }

}

/**
 * [Link] objects are references to filesystem links.
 *
 */
class Link extends FileSystemEntity {
  
  Link(String path) 
      : super(path);


  /**
   * Creates a symbolic link. Returns a [:Future<Link>:] that completes with
   * the link when it has been created. If the link exists,
   * the future will complete with an error.
   *
   * If [recursive] is false, the default, the link is created
   * only if all directories in its path exist.
   * If [recursive] is true, all non-existing path
   * components are created. The directories in the path of [target] are
   * not affected, unless they are also in [path].
   *
   * On other platforms, the posix symlink() call is used to make a symbolic
   * link containing the string [target].  If [target] is a relative path,
   * it will be interpreted relative to the directory containing the link.
   */
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

  /**
   * Synchronously create the link. Calling [createSync] on an existing link
   * will throw an exception.
   *
   * If [recursive] is false, the default, the link is created only if all
   * directories in its path exist. If [recursive] is true, all
   * non-existing path components are created. The directories in
   * the path of [target] are not affected, unless they are also in [path].
   *
   * On other platforms, the posix symlink() call is used to make a symbolic
   * link containing the string [target].  If [target] is a relative path,
   * it will be interpreted relative to the directory containing the link.
   */
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

  /**
   * Gets the target of the link. Returns a future that completes with
   * the path to the target.
   *
   * If the link does not exist, or is not a link, the future completes with
   * a FileSystemException.
   */
  Future<String> target() => fs.readlink(path);
  
  /**
   * Synchronously gets the target of the link. Returns the path to the target.
   *
   * If the link does not exist, or is not a link, throws a FileSystemException.
   */
  String targetSync() => fs.readlinkSync(path);

  /**
   * Updates the link. Returns a [:Future<Link>:] that completes with the
   * link when it has been updated.  Calling [update] on a non-existing link
   * will complete its returned future with an exception.
   */
  Future<Link> update(String target) => fs.symlink(path, target).then((_) => this);

  /**
   * Synchronously updates the link. Calling [updateSync] on a non-existing link
   * will throw an exception.
   */
  void updateSync(String target) => fs.symlinkSync(path, target);
  
}

/**
 * A reference to a directory (or _folder_) on the file system.
 */
class Directory extends FileSystemEntity {
  
  Directory(String path) 
      : super(path);


  /**
   * Creates the directory with this name.
   *
   * If [recursive] is false, only the last directory in the path is
   * created. If [recursive] is true, all non-existing path components
   * are created. If the directory already exists nothing is done.
   *
   * Returns a [:Future<Directory>:] that completes with this
   * directory once it has been created. If the directory cannot be
   * created the future completes with an exception.
   */
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

  /**
   * Synchronously creates the directory with this name.
   *
   * If [recursive] is false, only the last directory in the path is
   * created. If [recursive] is true, all non-existing path components
   * are created. If the directory already exists nothing is done.
   *
   * If the directory cannot be created an exception is thrown.
   */
  void createSync({bool recursive: false}) {
    if (!existsSync()) {
      if (recursive) {
        parent.createSync(recursive: true);
      }
      fs.createDirSync(path);
    }
  }

  /**
   * Lists the sub-directories and files of this [Directory].
   * Optionally recurses into sub-directories.
   *
   * If [followLinks] is false, then any symbolic links found
   * are reported as [Link] objects, rather than as directories or files,
   * and are not recursed into.
   *
   * If [followLinks] is true, then working links are reported as
   * directories or files, depending on
   * their type, and links to directories are recursed into.
   * Broken links are reported as [Link] objects.
   * If a symbolic link makes a loop in the file system, then a recursive
   * listing will not follow a link twice in the
   * same recursive descent, but will report it as a [Link]
   * the second time it is seen.
   *
   * The result is a stream of [FileSystemEntity] objects
   * for the directories, files, and links.
   */
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

  /**
   * Lists the sub-directories and files of this [Directory].
   * Optionally recurses into sub-directories.
   *
   * If [followLinks] is false, then any symbolic links found
   * are reported as [Link] objects, rather than as directories or files,
   * and are not recursed into.
   *
   * If [followLinks] is true, then working links are reported as
   * directories or files, depending on
   * their type, and links to directories are recursed into.
   * Broken links are reported as [Link] objects.
   * If a link makes a loop in the file system, then a recursive
   * listing will not follow a link twice in the
   * same recursive descent, but will report it as a [Link]
   * the second time it is seen.
   *
   * Returns a [List] containing [FileSystemEntity] objects for the
   * directories, files, and links.
   */
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
