library node_filesystem;

import 'dart:js';
import 'dart:async';
import 'dart:collection';
import 'dart:html' show File;

import 'package:node-webkit/nodejs_module_wrapper.dart';


final NodeObject _fs = new NodeObject("fs");

String getPath(File file) {
  return getNativeProperty(file, "path");
}

Function _createErrorHandler(path) 
    => (JsObject error) => new FileSystemException(error["message"], path);

Future<String> realPath(String path) {
  return _fs.callFunction("realpath", [path], async: true, errorHandler: _createErrorHandler(path));
}

String realPathSync(String path) {
  return _fs.callFunction("realpathSync", [path], errorHandler: _createErrorHandler(path));
}

Future<bool> exists(String path) {
  return _fs.callFunction("exists", [path], async: true);
}

bool existsSync(String path) {
  return _fs.callFunction("existsSync", [path]);
}

Future createFile(String path) {
  return _fs.callFunction("writeFile", [path, ""], async: true, errorHandler: _createErrorHandler(path));
}

void createFileSync(String path) {
  _fs.callFunction("writeFileSync", [path, ""], errorHandler: _createErrorHandler(path));
}

Future createDir(String path) {
  return _fs.callFunction("mkdir", [path], async: true, errorHandler: _createErrorHandler(path));
}

void createDirSync(String path) {
  _fs.callFunction("mkdirSync", [path], errorHandler: _createErrorHandler(path));
}

Future deleteFile(String path) {
  return _fs.callFunction("unlink", [path], async: true, errorHandler: _createErrorHandler(path));
}

void deleteFileSync(String path) {
  _fs.callFunction("unlinkSync", [path], errorHandler: _createErrorHandler(path));
}

Future deleteDir(String path) {
  return _fs.callFunction("rmdir", [path], async: true, errorHandler: _createErrorHandler(path));
}

void deleteDirSync(String path) {
  _fs.callFunction("rmdirSync", [path], errorHandler: _createErrorHandler(path));
}

Future link(String srcPath, String dstPath) {
  return _fs.callFunction("link", [srcPath, dstPath], async: true, errorHandler: _createErrorHandler(srcPath));
}

void linkSync(String srcPath, String dstPath) {
  _fs.callFunction("linkSync", [srcPath, dstPath], errorHandler: _createErrorHandler(srcPath));
}

Future symlink(String srcPath, String dstPath) {
  return _fs.callFunction("symlink", [srcPath, dstPath], async: true, errorHandler: _createErrorHandler(srcPath));
}

void symlinkSync(String srcPath, String dstPath) {
  _fs.callFunction("symlinkSync", [srcPath, dstPath], errorHandler: _createErrorHandler(srcPath));
}

Future<String> readlink(String path) {
  return _fs.callFunction("readlink", [path], async: true, errorHandler: _createErrorHandler(path));
}

String readlinkSync(String path) {
  return _fs.callFunction("readlinkSync", [path], errorHandler: _createErrorHandler(path));
}

Future rename(String oldPath, String newPath) {
  return _fs.callFunction("rename", [oldPath, newPath], async: true, errorHandler: _createErrorHandler(oldPath));
}

void renameSync(String oldPath, String newPath) {
  return _fs.callFunction("renameSync", [oldPath, newPath], errorHandler: _createErrorHandler(oldPath));
}

Future truncate(String path, int len) {
  return _fs.callFunction("truncate", [path, len], async: true, errorHandler: _createErrorHandler(path));
}

void truncateSync(String path, int len) {
  return _fs.callFunction("truncateSync", [path, len], errorHandler: _createErrorHandler(path));
}

Future chown(String path, int uid, int gid) {
  return _fs.callFunction("chown", [path, uid, gid], async: true, errorHandler: _createErrorHandler(path));
}

void chownSync(String path, int uid, int gid) {
  _fs.callFunction("chownSync", [path, uid, gid], errorHandler: _createErrorHandler(path));
}

Future lchown(String path, int uid, int gid) {
  return _fs.callFunction("lchown", [path, uid, gid], async: true, errorHandler: _createErrorHandler(path));
}

void lchownSync(String path, int uid, int gid) {
  _fs.callFunction("lchown", [path, uid, gid], errorHandler: _createErrorHandler(path));
}

Future chmod(String path, int mode) {
  return _fs.callFunction("chmod", [path, mode], async: true, errorHandler: _createErrorHandler(path));
}

void chmodSync(String path, int mode) {
  _fs.callFunction("chmodSync", [path, mode], errorHandler: _createErrorHandler(path));
}

Future utimes(String path, DateTime atime, DateTime mtime) {
  return _fs.callFunction("utimes", [path, atime, mtime], async: true, errorHandler: _createErrorHandler(path));
}

void utimesSync(String path, DateTime atime, DateTime mtime) {
  _fs.callFunction("utimesSync", [path, atime, mtime], errorHandler: _createErrorHandler(path));
}

Future<List<String>> readDir(String path) {
  return _fs.callFunction("readdir", [path], async: true, 
      errorHandler: _createErrorHandler(path)).then((filenames) => new _JsObjectListWrapper<String>(filenames));
}

List<String> readDirSync(String path) {
  return new _JsObjectListWrapper<String>( _fs.callFunction("readdirSync", [path], errorHandler: _createErrorHandler(path)));
}

Future<FileStat> stat(String path) {
  return _fs.callFunction("stat", [path], async: true, errorHandler: _createErrorHandler(path)).
      then((jsObject) => new FileStat._fromStatJsObject(jsObject));
}

Future<FileStat> lstat(String path) {
  return _fs.callFunction("stat", [path], async: true, errorHandler: _createErrorHandler(path)).
      then((jsObject) => new FileStat._fromStatJsObject(jsObject));
}

FileStat statSync(String path) {
  return new FileStat._fromStatJsObject(_fs.callFunction("statSync", [path], errorHandler: _createErrorHandler(path)));
}

FileStat lstatSync(String path) {
  return new FileStat._fromStatJsObject(_fs.callFunction("lstatSync", [path], errorHandler: _createErrorHandler(path)));
}

Future<String> readFileAsString(String path, {String encoding: "utf8"}) {
  return _fs.callFunction("readFile", [path, new JsObject.jsify({"encoding": encoding})], async: true, errorHandler: _createErrorHandler(path));
}

String readFileAsStringSync(String path, {String encoding: "utf8"}) {
  return _fs.callFunction("readFileSync", [path, new JsObject.jsify({"encoding": encoding})], errorHandler: _createErrorHandler(path));
}

Future<List<int>> readFile(String path) {
  return _fs.callFunction("readFile", [path], async: true, errorHandler: _createErrorHandler(path))
      .then((data) => new _JsObjectListWrapper(data));
}

List<int> readFileSync(String path) {
  return new _JsObjectListWrapper(_fs.callFunction("readFileSync", [path], errorHandler: _createErrorHandler(path)));
}

Future writeFileAsString(String path, String data, {String flags, int mode, String encoding: "utf8"}) {
  return _fs.callFunction("writeFile", [path, data, 
      _createOptsObj(flags: flags, mode: mode, encoding: encoding)], async: true, errorHandler: _createErrorHandler(path));
}

void writeFileAsStringSync(String path, String data, {String flags, int mode, String encoding: "utf8"}) {
  _fs.callFunction("writeFileSync", [path, data, 
      _createOptsObj(flags: flags, mode: mode, encoding: encoding)], errorHandler: _createErrorHandler(path));
}

Future writeFile(String path, List<int> data, {String flags, int mode}) {
  return new Future.sync(() {
    var jsBuffer = new JsObject(context['Buffer'], [new JsObject.jsify(data)]);
    return _fs.callFunction("writeFile", [path, jsBuffer, 
      _createOptsObj(flags: flags, mode: mode)], async: true, errorHandler: _createErrorHandler(path));
  });
}

void writeFileSync(String path, List<int> data, {String flags, int mode}) {
  var jsBuffer = new JsObject(context['Buffer'], [new JsObject.jsify(data)]);
  _fs.callFunction("writeFileSync", [path, jsBuffer, 
      _createOptsObj(flags: flags, mode: mode)], errorHandler: _createErrorHandler(path));
}

Future appendFileAsString(String path, String data, {String flags, int mode, encoding: "utf8"}) {
  return _fs.callFunction("appendFile", [path, data, 
      _createOptsObj(flags: flags, mode: mode, encoding: encoding)], async: true, errorHandler: _createErrorHandler(path));
}

void appendFileAsStringSync(String path, String data, {String flags, int mode, encoding: "utf8"}) {
  _fs.callFunction("appendFileSync", [path, data, 
      _createOptsObj(flags: flags, mode: mode, encoding: encoding)], errorHandler: _createErrorHandler(path));
}

Future appendFile(String path, List<int> data, {String flags, int mode}) {
  return new Future.sync(() {
    var jsBuffer = new JsObject(context['Buffer'], [new JsObject.jsify(data)]);
    return _fs.callFunction("appendFile", [path, jsBuffer, 
      _createOptsObj(flags: flags, mode: mode)], async: true, errorHandler: _createErrorHandler(path));
  });
}

void appendFileSync(String path, List<int> data, {String flags, int mode}) {
  var jsBuffer = new JsObject(context['Buffer'], [new JsObject.jsify(data)]);
  _fs.callFunction("appendFileSync", [path, jsBuffer, 
      _createOptsObj(flags: flags, mode: mode)], errorHandler: _createErrorHandler(path));
}

Stream<List<int>> openRead(String path, {String flags, mode, int start, int end}) {
  return _createReadStream(path, start: start, end: end, handler: (data) => new _JsObjectListWrapper<int>(data));
}

Stream<String> openReadAsString(String path, {String flags, mode, int start, int end, String encoding: "utf8"}) {
  return _createReadStream(path, start: start, end: end, encoding: encoding);
}

FileInputStream<List<int>> openReadSync(String path, {String flags, mode, int start, int end}) {
  return _createFileInputStream(path, start: start, end: end, 
      handler: (data) => data != null ? new _JsObjectListWrapper<int>(data) : null);
}

FileInputStream<String> openReadSyncAsString(String path, {String flags, mode, int start, int end, String encoding: "utf8"}) {
  return _createFileInputStream(path, start: start, end: end, encoding: encoding);
}

FileOutputStream<List<int>> openWrite(String path, {String flags, int mode, int start, int end}) {
  return _createWriteStream(path, flags: flags, mode: mode, start: start, end: end, 
      dataHandler: (data) => new JsObject(context['Buffer'], [new JsObject.jsify(data)]));
}

FileOutputStream<String> openWriteAsString(String path, {String flags, int mode, int start, int end, String encoding: "utf8"}) {
  return _createWriteStream(path, flags: flags, mode: mode, start: start, end: end, encoding: encoding);
}


class _JsObjectListWrapper<T> extends ListBase<T> {

  final JsObject _bf;

  _JsObjectListWrapper(this._bf);

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

  bool get isFile => _jsStat.callMethod("isFile");

  bool get isDirectory => _jsStat.callMethod("isDirectory");

  bool get isBlockDevice => _jsStat.callMethod("isBlockDevice");

  bool get isCharacterDevice => _jsStat.callMethod("isCharacterDevice");

  bool get isSymbolicLink => _jsStat.callMethod("isSymbolicLink");

  bool get isFIFO => _jsStat.callMethod("isFIFO");

  bool get isSocket => _jsStat.callMethod("isSocket");

  DateTime get atime => new DateTime.fromMillisecondsSinceEpoch(_jsStat["atime"].callMethod("getTime"));

  DateTime get mtime => new DateTime.fromMillisecondsSinceEpoch(_jsStat["mtime"].callMethod("getTime"));

  DateTime get ctime => new DateTime.fromMillisecondsSinceEpoch(_jsStat["ctime"].callMethod("getTime"));

  int get dev => _jsStat["dev"];

  int get ino => _jsStat["ino"];

  int get mode => _jsStat["mode"];

  int get nlink => _jsStat["nlink"];

  int get uid => _jsStat["uid"];

  int get gid => _jsStat["gid"];

  int get rdev => _jsStat["rdev"];

  int get size => _jsStat["size"];

  int get blksize => _jsStat["blksize"];

  int get blocks => _jsStat["blocks"];

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
  final Function _dataHandler;

  FileOutputStream._fromJsObject(this._writer, [this._dataHandler]);

  void write(T data) {
    if (_dataHandler != null) {
      _writer.callMethod("write", [_dataHandler(data)]);
    } else {
      _writer.callMethod("write", [data]);
    }
  }

  void close() {
    _writer.callMethod("end");
  }
}

class FileInputStream<T> {

  final NodeObject _reader;
  final Function _errorHandler;
  final Function _dataHandler;

  FileInputStream._fromNodeObject(this._reader, this._errorHandler, [this._dataHandler]);

  Stream<FileInputStream> get onReadable
    => _reader.asEventEmitter().getStream("readable", this);

  Stream<FileInputStream> get onEnd
    => _reader.asEventEmitter().getStream("end", this);

  Stream<FileInputStream> get onClose
    => _reader.asEventEmitter().getStream("close", this);

  Stream<FileSystemException> get onError {
    return _reader.asEventEmitter().getStream("error").transform(
        new StreamTransformer<JsObject, FileSystemException>.fromHandlers(
            handleData: (JsObject value, EventSink<FileSystemException> sink) {
              sink.add(_errorHandler(value));
            }));
  }

  T read([int size]) {
    var data = _reader.callFunction("read", size != null ? [size] : [], errorHandler: _errorHandler);
    if (_dataHandler != null) {
      return _dataHandler(data);
    }
    return data;
  }

  void close() {
    _reader.callFunction("destroy", []);
  }

}
 
JsObject _createOptsObj({String flags, int mode, int start, int end, String encoding}) {
  var opts = {"encoding": encoding};
  if (flags != null) {
    opts["flags"] = flags;
  }
  if (mode != null) {
    opts["mode"] = mode;
  }
  if (start != null) {
    opts["start"] = start;
  }
  if (end != null) {
    opts["end"] = end;
  }
  return new JsObject.jsify(opts);
}

Stream _createReadStream(String path, {String flags, int mode, int start, int end, String encoding, Object handler(data)}) {

  var opts = _createOptsObj(flags: flags, mode: mode, start: start, end: end, encoding: encoding);
  var eventEmitter;

  try {
    eventEmitter = _fs.callFunctionAndWrap("createReadStream", [path, opts]).asEventEmitter();
  } catch (err) {
    throw new FileSystemException(err['message'], path);
  }

  return eventEmitter.createStreamController(dataHandler: handler, errorHandler: _createErrorHandler(path)).stream;
}

FileOutputStream _createWriteStream(String path, {String flags, int mode, int start, int end, String encoding, Object dataHandler(data)}) {

  var opts = _createOptsObj(flags: flags, mode: mode, start: start, end: end, encoding: encoding);
  
  try {
    return new FileOutputStream._fromJsObject(_fs.callFunction("createWriteStream", [path, opts]), dataHandler);
  } catch (err) {
    throw new FileSystemException(err['message'], path);   
  }
}

FileInputStream _createFileInputStream(String path, {String flags, int mode, int start, int end, String encoding, Object handler(data)}) {
  var opts = _createOptsObj(flags: flags, mode: mode, start: start, end: end, encoding: encoding);
  var nodeObj;

  try {
    nodeObj = _fs.callFunctionAndWrap("createReadStream", [path, opts]);
  } catch (err) {
    throw new FileSystemException(err['message'], path);
  }

  return new FileInputStream._fromNodeObject(nodeObj, _createErrorHandler(path), handler);
}


