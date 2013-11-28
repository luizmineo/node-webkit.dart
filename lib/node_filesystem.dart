library node_filesystem;

import 'dart:js';
import 'dart:async';
import 'dart:collection';


final JsObject _fs = context.callMethod("require", ["fs"]);

Future<String> realPath(String path) {
  return _callFsMethod("realpath", path, [path]);
}

String realPathSync(String path) {
  try {
    return _fs.callMethod("realpathSync", [path]);
  } catch (err) {
    throw new FileSystemException(err['message'], path);
  }
}

Future<bool> exists(String path) {
  return _callFsMethod("exists", path, [path], handleError: false);
}

Future createFile(String path) {
  return _callFsMethod("writeFile", path, [path, ""], hasReturn: false);
}

Future createDir(String path) {
  return _callFsMethod("mkdir", path, [path], hasReturn: false);
}

Future deleteFile(String path) {
  return _callFsMethod("unlink", path, [path], hasReturn: false);
}

void deleteFileSync(String path) {
  try {
    _fs.callMethod("unlink", [path]);
  } catch(error) {
    throw new FileSystemException(error['message'], path);   
  }
}

Future deleteDir(String path) {
  return _callFsMethod("rmdir", path, [path], hasReturn: false);
}

void deleteDirSync(String path) {
  try {
    _fs.callMethod("rmdir", [path]);
  } catch(error) {
    throw new FileSystemException(error['message'], path);   
  }
}

Future rename(String oldPath, String newPath) {
  return _callFsMethod("rename", oldPath, [oldPath, newPath], hasReturn: false);
}

Future<List<String>> readDir(String path) {
  return _callFsMethod("readdir", path, [path]).then((filenames) => new JsObjectListWrapper<String>(filenames));
}

List<String> readDirSync(String path) {
  try {
    return new JsObjectListWrapper<String>(_fs.callMethod("readdirSync", [path]));
  } catch (error) {
    throw new FileSystemException(error['message'], path);
  }
}

Future<FileStat> stat(String path) {
  return _callFsMethod("stat", path, [path]).
      then((jsObject) => new FileStat._fromStatJsObject(jsObject));
}

Future<FileStat> lstat(String path) {
  return _callFsMethod("lstat", path, [path]).
      then((jsObject) => new FileStat._fromStatJsObject(jsObject));
}

FileStat statSync(String path) {
  try {
    return new FileStat._fromStatJsObject(_fs.callMethod("statSync", [path]));
  } catch (err) {
    throw new FileSystemException(err['message'], path);
  }
}

FileStat lstatSync(String path) {
  try {
    return new FileStat._fromStatJsObject(_fs.callMethod("lstatSync", [path]));
  } catch (err) {
    throw new FileSystemException(err['message'], path);
  }
}

Future<String> readFileAsString(String path, {encoding: "utf8"}) {
  return _callFsMethod("readFile", path, [path, {"encoding": encoding}]);
}

Future<List<int>> readFile(String path) {
  return _callFsMethod("readFile", path, [path]);
}

Future writeFileAsString(String path, String data, {flags: "w", mode: 0666, encoding: "utf8"}) {
  return _callFsMethod("writeFile", path, [path, data, {"flags": flags, "mode": mode, "encoding": encoding}], hasReturn: false);
}

Future writeFile(String path, List<int> data, {flags: "w", mode: 0666}) {
  return new Future.sync(() {
    var jsBuffer = new JsObjectListWrapper<int>(new JsObject(context['Buffer'], [new JsObject.jsify(data)]));
    return _callFsMethod("writeFile", path, [path, jsBuffer, {"flags": flags, "mode": mode}], hasReturn: false);
  });
}

Stream<List<int>> openRead(String path, {flags: "r", mode: 0666, int start: null, int end: null}) {
  return _createReadStream(path, start: start, end: end, handler: (data) => new JsObjectListWrapper<int>(data));
}

Stream<String> openReadAsString(String path, {flags: "r", mode: 0666, int start: null, int end: null, String encoding: "utf8"}) {
  return _createReadStream(path, start: start, end: end, encoding: encoding);
}

FileOutputStream<List<int>> openWrite(String path, {flags: "w", mode: 0666, int start: null, int end: null}) {
  return _createWriteStream(path, flags: flags, mode: mode, start: start, end: end);
}

FileOutputStream<String> openWriteAsString(String path, {flags: "w", mode: 0666, int start: null, int end: null, String encoding: "utf8"}) {
  return _createWriteStream(path, flags: flags, mode: mode, start: start, end: end, encoding: encoding);
}


class JsObjectListWrapper<T> extends ListBase<T> {

  final JsObject _bf;

  JsObjectListWrapper(this._bf);

  get length => _bf["length"];

  set length(int length) => throw new UnsupportedError("This List is immutable");

  operator []= (int index, T value) => throw new UnsupportedError("This List is immutable");

  T operator [] (int index) => _bf[index];

}

class FileSystemException {

  final String message;
  final String path;

  FileSystemException(this.message, this.path);

  String toString() => "$message [$path]";

}

class FileStat {
  
  final JsObject _jsStat;

  FileStat._fromStatJsObject(this._jsStat);

  get isFile => _jsStat.callMethod("isFile");

  get isDirectory => _jsStat.callMethod("isDirectory");

  get isBlockDevice => _jsStat.callMethod("isBlockDevice");

  get isCharacterDevice => _jsStat.callMethod("isCharacterDevice");

  get isSymbolicLink => _jsStat.callMethod("isSymbolicLink");

  get isFIFO => _jsStat.callMethod("isFIFO");

  get isSocket => _jsStat.callMethod("isSocket");

  get atime => new DateTime.fromMillisecondsSinceEpoch(_jsStat["atime"].callMethod("getTime"));

  get mtime => new DateTime.fromMillisecondsSinceEpoch(_jsStat["mtime"].callMethod("getTime"));

  get ctime => new DateTime.fromMillisecondsSinceEpoch(_jsStat["ctime"].callMethod("getTime"));

  get dev => _jsStat["dev"];

  get ino => _jsStat["ino"];

  get mode => _jsStat["mode"];

  get nlink => _jsStat["nlink"];

  get uid => _jsStat["uid"];

  get gid => _jsStat["gid"];

  get rdev => _jsStat["rdev"];

  get size => _jsStat["size"];

  get blksize => _jsStat["blksize"];

  get blocks => _jsStat["blocks"];

  String toString() => '''
    isFile = $isFile
    isDirectory = $isDirectory
    isBlockDevice = $isBlockDevice
    isCharacterDevice = $isCharacterDevice
    isSymbolicLink = $isSymbolicLink
    isFIFO = $isFIFO
    isSocket = $isSocket
    atime = $atime
    mtime = $mtime
    ctime = $ctime
    dev = $dev
    ino = $ino
    mode = $mode
    nlink = $nlink
    uid = $uid
    gid = $gid
    rdev = $rdev
    size = $size
    blksize = $blksize
    blocks = $blocks
  ''';
}

class FileOutputStream<T> {
  
  final JsObject _writer;

  FileOutputStream._fromJsObject(this._writer);

  void write(T data) {
    _writer.callMethod("write", [data]);
  }

  void close() {
    _writer.callMethod("end");
  }
}


var count = 0;

Future _callFsMethod(String methodName, String path, List args, {hasReturn: true, handleError: true}) {
  return new Future.sync(() {
    var comp = new Completer();
    
    var id = count++;

    if (handleError) {
      if (hasReturn) {
        args.add((err, ret) {
          if (err != null) {
            comp.completeError(new FileSystemException(err['message'], path));
          } else {
            comp.complete(ret);
          }
        });
      } else {
        args.add((err) {
          if (err != null) {
            comp.completeError(new FileSystemException(err['message'], path));
          }
          comp.complete();
        });
      }
    } else {
      if (hasReturn) {
        args.add((ret) {
          if (ret != null) {
            comp.complete(ret);
          } else {
            comp.complete();
          }
        });
      } else {
        args.add(() {
          comp.complete();
        });
      }
    }

    _fs.callMethod(methodName, args);

    return comp.future;
  });
}

Stream _createReadStream(String path, {flags: "r", mode: 0666, int start: null, int end: null, encoding: null, Object handler(data)}) {

  var fd;
  var controller;

  var opts = {"flags": flags, "mode": mode, "autoClose": true};
  if (start != null) {
    opts['start'] = start;
  }
  if (end != null) {
    opts['end'] = end;
  }
  if (encoding != null) {
    opts['encoding'] = encoding;
  }

  var inputStream;

  try {
    inputStream = _fs.callMethod("createReadStream", [path, opts]);
    inputStream.callMethod("on", ["open", (newFd) {
      fd = newFd;
    }]);
    inputStream.callMethod("on", ["end", () {
      controller.close();
    }]);
    inputStream.callMethod("on", ["error", (err) {
      controller.addError(new FileSystemException(err['message'], path));
      controller.close();
    }]);
  } catch (err) {
    throw new FileSystemException(err['message'], path);
  }

  var onStart = () {
    inputStream.callMethod("on", ["data"], (data) {
      if(handler != null) {
        controller.add(handler(data));
      } else {
        controller.add(data);
      }
    });
  };

  var onPause = () {
    inputStream.callMethod("pause");
  };

  var onResume = () {
    inputStream.callMethod("resume");
  };

  var onCancel = () {
    inputStream.callMethod("pause");
    _fs.callMethod("closeSync", [fd]);
  };

  controller = new StreamController<List<int>>(
      onListen: onStart,
      onPause: onPause,
      onResume: onResume,
      onCancel: onCancel);

  return controller.stream;
}

FileOutputStream _createWriteStream(String path, {flags: "r", mode: 0666, int start: null, int end: null, encoding: null}) {

  var opts = {"flags": flags, "mode": mode};
  if (start != null) {
    opts['start'] = start;
  }
  if (end != null) {
    opts['end'] = end;
  }
  if (encoding != null) {
    opts['encoding'] = encoding;
  }
  
  try {
    return new FileOutputStream._fromJsObject(_fs.callMethod("createWriteStream", [path, opts]));
  } catch (err) {
    throw new FileSystemException(err['message'], path);   
  }
}


