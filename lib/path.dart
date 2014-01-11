/**
 * Collection of functions to handle file paths.
 *
 * This library is a wrapper to the [nodejs's path module](http://nodejs.org/api/path.html)
 * Errors thrown by nodejs are wrapped by the [PathException] class.
 * 
 */
library path;

import 'dart:js';

import 'package:node_webkit/nodejs_module_wrapper.dart';


final NodeObject _path = new NodeObject("path");

PathException _errorHandler(JsObject error) => new PathException(error['message']);

/**
 * Join a list of paths together, and normalize the result.
 *
 * See <http://nodejs.org/api/path.html#path_path_join_path1_path2> for more information.
 */
String join(List<String> paths) {
  return _path.callFunction("join", paths, errorHandler: _errorHandler);
}

/**
 * Resolves the given path to an absolute path.
 *
 * See <http://nodejs.org/api/path.html#path_path_resolve_from_to> for more information.
 */
String resolve(String to, {List<String> from}) {
  var args = [];
  if (from != null) {
    args.addAll(from);
  }
  return _path.callFunction("resolve", args..add(to), errorHandler: _errorHandler);
}

/**
 * Derives a relative path from two absolute paths
 *
 * See <http://nodejs.org/api/path.html#path_path_relative_from_to> for more information.
 */
String relative(String from, String to) {
  return _path.callFunction("relative", [from, to], errorHandler: _errorHandler);
}

/**
 * Normalize a string path, taking care of '..' and '.' parts.
 *
 * See <http://nodejs.org/api/path.html#path_path_normalize_p> for more information.
 */
String normalize(String path) {
  return _path.callFunction("normalize", [path], errorHandler: _errorHandler);
}

/**
 * Returns the directory name of a path.
 *
 * See <http://nodejs.org/api/path.html#path_path_dirname_p> for more information.
 */
String dirname(String path) {
  return _path.callFunction("dirname", [path], errorHandler: _errorHandler);
}

/**
 * Return the last portion of a path.
 *
 * See <http://nodejs.org/api/path.html#path_path_basename_p_ext> for more information.
 */
String basename(String path) {
  return _path.callFunction("basename", [path], errorHandler: _errorHandler);
}

/**
 * Returns the extension of the path.
 *
 * See <http://nodejs.org/api/path.html#path_path_extname_p> for more information.
 */
String extname(String path) {
  return _path.callFunction("extname", [path], errorHandler: _errorHandler);
}

/**
 * The platform-specific file separator. '\\' or '/'.
 */
String get sep {
  return _path["sep"];
}

/**
 * The platform-specific path delimiter, ; or ':'.
 */
String get delimiter {
  return _path["delimiter"];
}

/**
 * Wrapper for errors thrown by nodejs
 */
class PathException {

  final String message;

  PathException(this.message);

  String toString() => message;

}