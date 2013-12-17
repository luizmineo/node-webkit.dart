library path;

import 'dart:js';

import 'package:node-webkit/nodejs_module_wrapper.dart';


final NodeObject _path = new NodeObject("path");

PathException _errorHandler(JsObject error) => new PathException(error['message']);


String join(List<String> paths) {
  return _path.callFunction("join", paths, errorHandler: _errorHandler);
}

String resolve(List<String> from, String to) {
  return _path.callFunction("resolve", from..add(to), errorHandler: _errorHandler);
}

String relative(String from, String to) {
  return _path.callFunction("relative", [from, to], errorHandler: _errorHandler);
}

String normalize(String path) {
  return _path.callFunction("normalize", [path], errorHandler: _errorHandler);
}

String dirname(String path) {
  return _path.callFunction("dirname", [path], errorHandler: _errorHandler);
}

String basename(String path) {
  return _path.callFunction("basename", [path], errorHandler: _errorHandler);
}

String extname(String path) {
  return _path.callFunction("extname", [path], errorHandler: _errorHandler);
}

String get sep {
  return _path["sep"];
}

String get delimiter {
  return _path["delimiter"];
}

class PathException {

  final String message;

  PathException(this.message);

  String toString() => message;

}