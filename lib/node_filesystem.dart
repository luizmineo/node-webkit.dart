/**
 * Utilities for handling filesystem operations.
 *
 * This library is a wrapper to the [nodejs fs module](http://nodejs.org/api/fs.html)
 */
library node_filesystem;

import 'dart:js';
import 'dart:async';
import 'dart:html' show File;

import 'package:node_webkit/nodejs_module_wrapper.dart';


final NodeObject _fs = new NodeObject("fs");

/**
 * Returns the full path of [File] objects that comes from DOM elements.
 */
String getPath(File file) {
  return getNativeProperty(file, "path");
}

Function _createErrorHandler(path) =>
    (JsObject error) => new FileSystemException(error["message"], path);

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_realpath_path_cache_callback>
 */
Future<String> realPath(String path) {
  return _fs.callFunction("realpath", [path], async: true, errorHandler: _createErrorHandler(path));
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_realpathsync_path_cache>
 */
String realPathSync(String path) {
  return _fs.callFunction("realpathSync", [path], errorHandler: _createErrorHandler(path));
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_exists_path_callback>
 */
Future<bool> exists(String path) {
  return _fs.callFunction("exists", [path], async: true);
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_existssync_path>
 */
bool existsSync(String path) {
  return _fs.callFunction("existsSync", [path]);
}

/**
 * Creates a empty new file.
 *
 * If the file already exists, it will be overwritten.
 * Returns a Future<String> that completes with the file [path], once the entire operation has complete,
 * or with a [FileSystemException], if the operation fails.
 */
Future<String> createFile(String path) {
  return _fs.callFunction("writeFile", [path, ""], async: true, 
      errorHandler: _createErrorHandler(path), valueHandler: (_) => path);
}

/**
 * Synchronous version of [createFile].
 *
 * Throws a [FileSystemException] if the operation fails.
 */
void createFileSync(String path) {
  _fs.callFunction("writeFileSync", [path, ""], errorHandler: _createErrorHandler(path));
}

/**
 * Creates a new directory.
 *
 * See <http://nodejs.org/api/fs.html#fs_fs_mkdir_path_mode_callback>
 *
 * Returns a Future<String> that completes with the directory [path], once the entire operation has completed,
 * or with a [FileSystemException], if the operation fails.
 */
Future<String> createDir(String path) {
  return _fs.callFunction("mkdir", [path], async: true, 
      errorHandler: _createErrorHandler(path), valueHandler: (_) => path);
}

/**
 * Synchronous version of [createDir].
 *
 * See <http://nodejs.org/api/fs.html#fs_fs_mkdirsync_path_mode>
 *
 * Throws a [FileSystemException] if the operation fails.
 */
void createDirSync(String path) {
  _fs.callFunction("mkdirSync", [path], errorHandler: _createErrorHandler(path));
}

/**
 * Deletes a file.
 *
 * See <http://nodejs.org/api/fs.html#fs_fs_unlink_path_callback>
 *
 * Returns a Future<String> that completes with the file [path], once the entire operation has completed,
 * or with a [FileSystemException], if the operation fails.
 */
Future<String> deleteFile(String path) {
  return _fs.callFunction("unlink", [path], async: true, 
      errorHandler: _createErrorHandler(path), valueHandler: (_) => path);
}

/**
 * Synchronous version of [deleteFile].
 *
 * See <http://nodejs.org/api/fs.html#fs_fs_unlinksync_path>
 *
 * Throws a [FileSystemException] if the operation fails.
 */
void deleteFileSync(String path) {
  _fs.callFunction("unlinkSync", [path], errorHandler: _createErrorHandler(path));
}

/**
 * Deletes a directory.
 *
 * See <http://nodejs.org/api/fs.html#fs_fs_rmdir_path_callback>
 *
 * Returns a Future<String> that completes with the directory [path], once the entire operation has completed,
 * or with a [FileSystemException], if the operation fails.
 */
Future<String> deleteDir(String path) {
  return _fs.callFunction("rmdir", [path], async: true, 
      errorHandler: _createErrorHandler(path), valueHandler: (_) => path);
}

/**
 * Synchronous version of [deleteDir].
 *
 * See <http://nodejs.org/api/fs.html#fs_fs_rmdirsync_path>
 *
 * Throws a [FileSystemException] if the operation fails.
 */
void deleteDirSync(String path) {
  _fs.callFunction("rmdirSync", [path], errorHandler: _createErrorHandler(path));
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_link_srcpath_dstpath_callback>
 *
 * Returns a Future<String> that completes with the link [path], once the entire operation has completed,
 * or with a [FileSystemException], if the operation fails.
 */
Future<String> link(String srcPath, String dstPath) {
  return _fs.callFunction("link", [srcPath, dstPath], async: true, 
      errorHandler: _createErrorHandler(srcPath), valueHandler: (_) => srcPath);
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_linksync_srcpath_dstpath>
 *
 * Throws a [FileSystemException] if the operation fails.
 */
void linkSync(String srcPath, String dstPath) {
  _fs.callFunction("linkSync", [srcPath, dstPath], errorHandler: _createErrorHandler(srcPath));
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_symlink_srcpath_dstpath_type_callback>
 *
 * Returns a Future<String> that completes with the link [path], once the entire operation has completed,
 * or with a [FileSystemException], if the operation fails.
 */
Future<String> symlink(String srcPath, String dstPath, [String type]) {
  var args = [srcPath, dstPath];
  if (type != null) {
    args.add(type);
  }
  return _fs.callFunction("symlink", args, async: true, 
      errorHandler: _createErrorHandler(srcPath), valueHandler: (_) => srcPath);
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_symlinksync_srcpath_dstpath_type>
 *
 * Throws a [FileSystemException] if the operation fails.
 */
void symlinkSync(String srcPath, String dstPath, [String type]) {
  var args = [srcPath, dstPath];
  if (type != null) {
    args.add(type);
  }
  _fs.callFunction("symlinkSync", args, errorHandler: _createErrorHandler(srcPath));
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_readlink_path_callback>
 */
Future<String> readlink(String path) {
  return _fs.callFunction("readlink", [path], async: true, errorHandler: _createErrorHandler(path));
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_readlinksync_path>
 *
 * Throws a [FileSystemException] if the operation fails.
 */
String readlinkSync(String path) {
  return _fs.callFunction("readlinkSync", [path], errorHandler: _createErrorHandler(path));
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_rename_oldpath_newpath_callback>
 *
 * Returns a Future<String> that completes with the new file [path], once the entire operation has completed,
 * or with a [FileSystemException], if the operation fails.
 */
Future<String> rename(String oldPath, String newPath) {
  return _fs.callFunction("rename", [oldPath, newPath], async: true, 
      errorHandler: _createErrorHandler(oldPath), valueHandler: (_) => newPath);
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_renamesync_oldpath_newpath>
 *
 * Throws a [FileSystemException] if the operation fails.
 */
void renameSync(String oldPath, String newPath) {
  return _fs.callFunction("renameSync", [oldPath, newPath], errorHandler: _createErrorHandler(oldPath));
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_truncate_path_len_callback>
 *
 * Returns a Future<String> that completes with the file [path], once the entire operation has completed,
 * or with a [FileSystemException], if the operation fails.
 */
Future<String> truncate(String path, int len) {
  return _fs.callFunction("truncate", [path, len], async: true, 
      errorHandler: _createErrorHandler(path), valueHandler: (_) => path);
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_truncatesync_path_len>
 *
 * Throws a [FileSystemException] if the operation fails.
 */
void truncateSync(String path, int len) {
  return _fs.callFunction("truncateSync", [path, len], errorHandler: _createErrorHandler(path));
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_chown_path_uid_gid_callback>
 *
 * Returns a Future<String> that completes with the file [path], once the entire operation has completed,
 * or with a [FileSystemException], if the operation fails.
 */
Future<String> chown(String path, int uid, int gid) {
  return _fs.callFunction("chown", [path, uid, gid], async: true, 
      errorHandler: _createErrorHandler(path), valueHandler: (_) => path);
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_chownsync_path_uid_gid>
 *
 * Throws a [FileSystemException] if the operation fails.
 */
void chownSync(String path, int uid, int gid) {
  _fs.callFunction("chownSync", [path, uid, gid], errorHandler: _createErrorHandler(path));
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_lchown_path_uid_gid_callback>
 *
 * Returns a Future<String> that completes with the file [path], once the entire operation has completed,
 * or with a [FileSystemException], if the operation fails.
 */
Future<String> lchown(String path, int uid, int gid) {
  return _fs.callFunction("lchown", [path, uid, gid], async: true, 
      errorHandler: _createErrorHandler(path), valueHandler: (_) => path);
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_lchownsync_path_uid_gid>
 *
 * Throws a [FileSystemException] if the operation fails.
 */
void lchownSync(String path, int uid, int gid) {
  _fs.callFunction("lchown", [path, uid, gid], errorHandler: _createErrorHandler(path));
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_chmod_path_mode_callback>
 *
 * Returns a Future<String> that completes with the file [path], once the entire operation has completed,
 * or with a [FileSystemException], if the operation fails.
 */
Future<String> chmod(String path, int mode) {
  return _fs.callFunction("chmod", [path, mode], async: true, 
      errorHandler: _createErrorHandler(path), valueHandler: (_) => path);
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_chmodsync_path_mode>
 *
 * Throws a [FileSystemException] if the operation fails.
 */
void chmodSync(String path, int mode) {
  _fs.callFunction("chmodSync", [path, mode], errorHandler: _createErrorHandler(path));
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_utimes_path_atime_mtime_callback>
 *
 * Returns a Future<String> that completes with the file [path], once the entire operation has completed,
 * or with a [FileSystemException], if the operation fails.
 */
Future<String> utimes(String path, DateTime atime, DateTime mtime) {
  return _fs.callFunction("utimes", [path, atime, mtime], async: true, 
      errorHandler: _createErrorHandler(path), valueHandler: (_) => path);
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_utimessync_path_atime_mtime>
 *
 * Throws a [FileSystemException] if the operation fails.
 */
void utimesSync(String path, DateTime atime, DateTime mtime) {
  _fs.callFunction("utimesSync", [path, atime, mtime], errorHandler: _createErrorHandler(path));
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_readdir_path_callback>
 *
 * Returns a Future<List<String>> that completes with the list of file names,
 * or with a [FileSystemException], if the operation fails.
 */
Future<List<String>> readDir(String path) {
  return _fs.callFunction("readdir", [path], async: true, 
      errorHandler: _createErrorHandler(path)).then((filenames) => new JsObjectListWrapper<String>(filenames));
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_readdirsync_path>
 *
 * Throws a [FileSystemException] if the operation fails.
 */
List<String> readDirSync(String path) {
  return new JsObjectListWrapper<String>( _fs.callFunction("readdirSync", [path], errorHandler: _createErrorHandler(path)));
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_stat_path_callback>
 *
 * Returns a Future<FileStat> that completes with the FileStat object,
 * or with a [FileSystemException], if the operation fails.
 */
Future<FileStat> stat(String path) {
  return _fs.callFunction("stat", [path], async: true, errorHandler: _createErrorHandler(path)).
      then((jsObject) => new FileStat._fromStatJsObject(jsObject));
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_lstat_path_callback>
 *
 * Returns a Future<FileStat> that completes with the FileStat object,
 * or with a [FileSystemException], if the operation fails.
 */
Future<FileStat> lstat(String path) {
  return _fs.callFunction("stat", [path], async: true, errorHandler: _createErrorHandler(path)).
      then((jsObject) => new FileStat._fromStatJsObject(jsObject));
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_statsync_path>
 *
 * Throws a [FileSystemException] if the operation fails.
 */
FileStat statSync(String path) {
  return new FileStat._fromStatJsObject(_fs.callFunction("statSync", [path], errorHandler: _createErrorHandler(path)));
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_lstatsync_path>
 *
 * Throws a [FileSystemException] if the operation fails.
 */
FileStat lstatSync(String path) {
  return new FileStat._fromStatJsObject(_fs.callFunction("lstatSync", [path], errorHandler: _createErrorHandler(path)));
}

/**
 * Read the contents of a file as a String.
 *
 * Returns a Future<String> that completes with the string once the file contents has been read,
 * or with a [FileSystemException], if the operation fails.
 */
Future<String> readFileAsString(String path, {String encoding: "utf8"}) {
  return _fs.callFunction("readFile", [path, new JsObject.jsify({"encoding": encoding})], async: true, errorHandler: _createErrorHandler(path));
}

/**
 * Returns the contents of a file as a String.
 *
 * Throws a [FileSystemException] if the operation fails.
 */
String readFileAsStringSync(String path, {String encoding: "utf8"}) {
  return _fs.callFunction("readFileSync", [path, new JsObject.jsify({"encoding": encoding})], errorHandler: _createErrorHandler(path));
}

/**
 * Read the contents of a file as a list of bytes.
 *
 * Returns a Future<List<int>> that completes with the list of bytes, once the file contents has been read,
 * or with a [FileSystemException], if the operation fails.
 */
Future<List<int>> readFile(String path) {
  return _fs.callFunction("readFile", [path], async: true, errorHandler: _createErrorHandler(path))
      .then((data) => new JsObjectListWrapper(data));
}

/**
 * Returns the contents of a file as a list of bytes.
 *
 * Throws a [FileSystemException] if the operation fails.
 */
List<int> readFileSync(String path) {
  return new JsObjectListWrapper(_fs.callFunction("readFileSync", [path], errorHandler: _createErrorHandler(path)));
}

/**
 * Write a String to a file.
 *
 * Returns a Future<String> that completes with the file [path], once the entire operation has completed,
 * or with a [FileSystemException], if the operation fails.
 */
Future<String> writeFileAsString(String path, String data, {String flags, int mode, String encoding: "utf8"}) {
  return _fs.callFunction("writeFile", [path, data, 
      _createOptsObj(flags: flags, mode: mode, encoding: encoding)], async: true, 
          errorHandler: _createErrorHandler(path), valueHandler: (_) => path);
}

/**
 * Write a String to a file.
 *
 * Throws a [FileSystemException] if the operation fails.
 */
void writeFileAsStringSync(String path, String data, {String flags, int mode, String encoding: "utf8"}) {
  _fs.callFunction("writeFileSync", [path, data, 
      _createOptsObj(flags: flags, mode: mode, encoding: encoding)], errorHandler: _createErrorHandler(path));
}

/**
 * Write a list of bytes to a file.
 *
 * Returns a Future<String> that completes with the file [path], once the entire operation has completed,
 * or with a [FileSystemException], if the operation fails.
 */
Future<String> writeFile(String path, List<int> data, {String flags, int mode}) {
  return new Future.sync(() {
    var jsBuffer = new Buffer.fromList(data);
    return _fs.callFunction("writeFile", [path, jsBuffer.jsObject, 
      _createOptsObj(flags: flags, mode: mode)], async: true, 
          errorHandler: _createErrorHandler(path), valueHandler: (_) => path);
  });
}

/**
 * Write a list of bytes to a file.
 *
 * Throws a [FileSystemException] if the operation fails.
 */
void writeFileSync(String path, List<int> data, {String flags, int mode}) {
  var jsBuffer = new Buffer.fromList(data);
  _fs.callFunction("writeFileSync", [path, jsBuffer.jsObject, 
      _createOptsObj(flags: flags, mode: mode)], errorHandler: _createErrorHandler(path));
}

/**
 * Append a String to a file.
 *
 * Returns a Future<String> that completes with the file [path], once the entire operation has completed,
 * or with a [FileSystemException], if the operation fails.
 */
Future<String> appendFileAsString(String path, String data, {String flags, int mode, encoding: "utf8"}) {
  return _fs.callFunction("appendFile", [path, data, 
      _createOptsObj(flags: flags, mode: mode, encoding: encoding)], async: true, 
          errorHandler: _createErrorHandler(path), valueHandler: (_) => path);
}

/**
 * Apeend a String to a file.
 *
 * Throws a [FileSystemException] if the operation fails.
 */
void appendFileAsStringSync(String path, String data, {String flags, int mode, encoding: "utf8"}) {
  _fs.callFunction("appendFileSync", [path, data, 
      _createOptsObj(flags: flags, mode: mode, encoding: encoding)], errorHandler: _createErrorHandler(path));
}

/**
 * Append a list of bytes to a file.
 *
 * Returns a Future<String> that completes with the file [path], once the entire operation has completed,
 * or with a [FileSystemException], if the operation fails.
 */
Future<String> appendFile(String path, List<int> data, {String flags, int mode}) {
  return new Future.sync(() {
    var jsBuffer = new Buffer.fromList(data);
    return _fs.callFunction("appendFile", [path, jsBuffer.jsObject, 
      _createOptsObj(flags: flags, mode: mode)], async: true, 
          errorHandler: _createErrorHandler(path), valueHandler: (_) => path);
  });
}

/**
 * Apeend a list of bytes to a file.
 *
 * Throws a [FileSystemException] if the operation fails.
 */
void appendFileSync(String path, List<int> data, {String flags, int mode}) {
  var jsBuffer = new Buffer.fromList(data);
  _fs.callFunction("appendFileSync", [path, jsBuffer.jsObject, 
      _createOptsObj(flags: flags, mode: mode)], errorHandler: _createErrorHandler(path));
}

/**
 * Asynchronous file open.
 *
 * See <http://nodejs.org/api/fs.html#fs_fs_open_path_flags_mode_callback>
 *
 * Returns a Future<int> that completes with the file descriptor, once the entire operation has completed,
 * or with a [FileSystemException], if the operation fails.
 */
Future<int> open(String path, String flags, [int mode]) {
  var args = [path, flags];
  if (mode != null) {
    args.add(mode);
  }
  return _fs.callFunction("open", args, async: true, 
      errorHandler: _createErrorHandler(path));
}

/**
 * Synchronous file open.
 *
 * See <http://nodejs.org/api/fs.html#fs_fs_opensync_path_flags_mode>
 *
 * Returns a file descriptor. Throws a [FileSystemException] if the operation fails.
 */
int openSync(String path, String flags, [int mode]) {
  var args = [path, flags];
  if (mode != null) {
    args.add(mode);
  }
  return _fs.callFunction("openSync", args,
      errorHandler: _createErrorHandler(path));
}

/**
 * Asynchronous close(2).
 *
 * See <http://nodejs.org/api/fs.html#fs_fs_close_fd_callback>
 *
 * Returns a Future<int> that completes with the closed file descriptor, once the entire operation has completed,
 * or with a [FileSystemException], if the operation fails.
 */
Future<int> close(int fd) {
  return _fs.callFunction("close", [fd], async: true, 
      errorHandler: _createErrorHandler("fd: $fd"), valueHandler: (_) => fd);
}

/**
 * Synchronous close(2).
 *
 * See <http://nodejs.org/api/fs.html#fs_fs_closesync_fd>
 *
 * Throws a [FileSystemException] if the operation fails.
 */
void closeSync(int fd) {
  _fs.callFunction("closeSync", [fd],
      errorHandler: _createErrorHandler("fd: $fd"));
} 

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_futimes_fd_atime_mtime_callback>
 *
 * Returns a Future<int> that completes with the file descriptor, once the entire operation has completed,
 * or with a [FileSystemException], if the operation fails.
 */
Future<int> futimes(int fd, DateTime atime, DateTime mtime) {
  return _fs.callFunction("futimes", [fd, atime, mtime], async: true, 
      errorHandler: _createErrorHandler("fd: $fd"), valueHandler: (_) => fd);
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_futimessync_fd_atime_mtime>
 *
 * Throws a [FileSystemException] if the operation fails.
 */
void futimesSync(int fd, DateTime atime, DateTime mtime) {
  _fs.callFunction("futimesSync", [fd, atime, mtime], errorHandler: _createErrorHandler("fd: $fd"));
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_fsync_fd_callback>
 *
 * Returns a Future<int> that completes with the file descriptor, once the entire operation has completed,
 * or with a [FileSystemException], if the operation fails.
 */
Future<int> fsync(int fd) {
  return _fs.callFunction("fsync", [fd], async: true, 
      errorHandler: _createErrorHandler("fd: $fd"), valueHandler: (_) => fd);
}

/**
 * See <http://nodejs.org/api/fs.html#fs_fs_fsyncsync_fd>
 *
 * Throws a [FileSystemException] if the operation fails.
 */
void fsyncSync(int fd) {
  _fs.callFunction("fsyncSync", [fd],
      errorHandler: _createErrorHandler("fd: $fd"));
}

/**
 *
 * Write [buffer] to the file specified by [fd].
 *
 * See <http://nodejs.org/api/fs.html#fs_fs_write_fd_buffer_offset_length_position_callback>
 *
 * Returns a Future<int> that completes with the number of bytes written, once the entire 
 * operation has completed, or with a [FileSystemException], if the operation fails.
 */
Future<int> write(int fd, Buffer buffer, int offset, int length, [int position]) {
  return _fs.callFunction("write", [fd, buffer.jsObject, offset, length, position], async: true, 
      errorHandler: _createErrorHandler("fd: $fd"), valueHandler: (values) {
        if (values[0] != null) {
          throw values[0];
        }
        return values[1];
      });
}

/**
 *
 * Write [buffer] to the file specified by [fd].
 *
 * See <http://nodejs.org/api/fs.html#fs_fs_write_fd_buffer_offset_length_position_callback>
 *
 * Returns the number of bytes written. Throws a [FileSystemException] if the operation fails.
 */
int writeSync(int fd, Buffer buffer, int offset, int length, [int position]) {
  return _fs.callFunction("writeSync", [fd, buffer.jsObject, offset, length, position],
      errorHandler: _createErrorHandler("fd: $fd"));
}

/**
 *
 * Read data from the file specified by [fd].
 *
 * See <http://nodejs.org/api/fs.html#fs_fs_read_fd_buffer_offset_length_position_callback>
 *
 * Returns a Future<int> that completes with the number of bytes read, once the entire 
 * operation has completed, or with a [FileSystemException], if the operation fails.
 */
Future<int> read(int fd, Buffer buffer, int offset, int length, [int position]) {
  return _fs.callFunction("read", [fd, buffer.jsObject, offset, length, position], async: true, 
      errorHandler: _createErrorHandler("fd: $fd"), valueHandler: (values) {
        if (values[0] != null) {
          throw values[0];
        }
        return values[1];
      });
}

/**
 *
 * Read data from the file specified by [fd].
 *
 * See <http://nodejs.org/api/fs.html#fs_fs_readsync_fd_buffer_offset_length_position>
 *
 * Returns the number of bytes read. Throws a [FileSystemException] if the operation fails.
 */
int readSync(int fd, Buffer buffer, int offset, int length, [int position]) {
  return _fs.callFunction("readSync", [fd, buffer.jsObject, offset, length, position],
      errorHandler: _createErrorHandler("fd: $fd"));
}

/**
 * Create a Stream<List<int>> to read the contents of a file.
 *
 * See <http://nodejs.org/api/fs.html#fs_fs_createreadstream_path_options>
 *
 * Returns a Stream that consumes the underlying ReadStream in flowing mode.
 */
Stream<List<int>> openRead(String path, {String flags, int mode, int start, int end}) {
  return _createReadStream(path, flags: flags, mode: mode, start: start, end: end, handler: (data) => new JsObjectListWrapper<int>(data));
}

/**
 * Create a Stream<String> to read the contents of a file.
 *
 * See <http://nodejs.org/api/fs.html#fs_fs_createreadstream_path_options>
 *
 * Returns a Stream that consumes the underlying ReadStream in flowing mode.
 */
Stream<String> openReadAsString(String path, {String flags, int mode, int start, int end, String encoding: "utf8"}) {
  return _createReadStream(path, flags: flags, mode: mode, start: start, end: end, encoding: encoding);
}

/**
 * Create a FileInputStream<List<int>> to read the contents of a file.
 *
 * See <http://nodejs.org/api/fs.html#fs_fs_createreadstream_path_options>
 *
 * Returns a [FileInputStream], that allows to consume the underlying ReadStream in non-flowing mode.
 */
FileInputStream<List<int>> openReadSync(String path, {String flags, int mode, int start, int end}) {
  return _createFileInputStream(path, flags: flags, mode: mode, start: start, end: end, 
      handler: (data) => data != null ? new JsObjectListWrapper<int>(data) : null);
}

/**
 * Create a FileInputStream<String> to read the contents of a file.
 *
 * See <http://nodejs.org/api/fs.html#fs_fs_createreadstream_path_options>
 *
 * Returns a [FileInputStream], that allows to consume the underlying ReadStream in non-flowing mode.
 */
FileInputStream<String> openReadAsStringSync(String path, {String flags, int mode, int start, int end, String encoding: "utf8"}) {
  return _createFileInputStream(path, flags: flags, start: start, end: end, mode: mode, encoding: encoding);
}

/**
 * Create a FileOutputStream<List<int>> to write bytes to a file.
 *
 * See <http://nodejs.org/api/fs.html#fs_fs_createwritestream_path_options>
 */
FileOutputStream<List<int>> openWrite(String path, {String flags, int mode, int start, int end}) {
  return _createWriteStream(path, flags: flags, mode: mode, start: start, end: end, 
      dataHandler: (data) => new JsObject(context['Buffer'], [new JsObject.jsify(data)]));
}

/**
 * Create a FileOutputStream<String> to write strings to a file.
 *
 * See <http://nodejs.org/api/fs.html#fs_fs_createwritestream_path_options>
 */
FileOutputStream<String> openWriteAsString(String path, {String flags, int mode, int start, int end, String encoding: "utf8"}) {
  return _createWriteStream(path, flags: flags, mode: mode, start: start, end: end, encoding: encoding);
}

/**
 * Wrapper for errors returned or thrown by nodejs
 */
class FileSystemException {

  final String message;
  final String path;

  FileSystemException(this.message, this.path);

  String toString() => "$message [$path]";

}

/**
 * Wrapper for Stats objects returned by nodejs
 *
 * See <http://nodejs.org/api/fs.html#fs_class_fs_stats>
 */
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

/**
 * Wrapper for WriteStream objects returned by nodejs
 *
 * See <http://nodejs.org/api/fs.html#fs_class_fs_writestream>
 */
class FileOutputStream<T> {
  
  final JsObject _writer;
  final Function _dataHandler;

  FileOutputStream._fromJsObject(this._writer, [this._dataHandler]);

  /**
   * Write data to stream
   */
  void write(T data) {
    if (_dataHandler != null) {
      _writer.callMethod("write", [_dataHandler(data)]);
    } else {
      _writer.callMethod("write", [data]);
    }
  }

  /**
   * Close the underlying stream.
   */
  void close() {
    _writer.callMethod("end");
  }
}

/**
 * Wrapper for ReadStream objects returned by nodejs
 *
 * See <http://nodejs.org/api/fs.html#fs_class_fs_readstream>
 *
 * This class is useful only if you need to consume a stream in non-flowing mode.
 */
class FileInputStream<T> {

  final NodeObject _reader;
  final Function _errorHandler;
  final Function _dataHandler;

  FileInputStream._fromNodeObject(this._reader, this._errorHandler, [this._dataHandler]);

  /// Stream of 'readable' events
  Stream<FileInputStream> get onReadable
    => _reader.asEventEmitter().getStream("readable", this);

  /// Stream of 'end' events
  Stream<FileInputStream> get onEnd
    => _reader.asEventEmitter().getStream("end", this);

  /// Stream of 'close' events
  Stream<FileInputStream> get onClose
    => _reader.asEventEmitter().getStream("close", this);

  /// Stream of 'error' events
  Stream<FileSystemException> get onError {
    return _reader.asEventEmitter().getStream("error").transform(
        new StreamTransformer<JsObject, FileSystemException>.fromHandlers(
            handleData: (JsObject value, EventSink<FileSystemException> sink) {
              sink.add(_errorHandler(value));
            }));
  }

  /**
   * Read data from stream
   */
  T read([int size]) {
    var data = _reader.callFunction("read", size != null ? [size] : [], errorHandler: _errorHandler);
    if (_dataHandler != null) {
      return _dataHandler(data);
    }
    return data;
  }

  /**
   * Close the underlying stream
   */
  void close() {
    _reader.callFunction("destroy", []);
  }

}

/**
 *
 * Simple wrapper for Buffer objects
 */
class Buffer {
  
  JsObject _buffer;

  Buffer(int length) {
    _buffer = new JsObject(context['Buffer'], [length]);
  }

  Buffer.fromList(List<int> data) {
    _buffer = new JsObject(context['Buffer'], [new JsObject.jsify(data)]);
  }

  get length => _buffer["length"];

  operator []= (int index, int value) => _buffer[index] = value;

  int operator [] (int index) => _buffer[index];

  get jsObject => _buffer;

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


