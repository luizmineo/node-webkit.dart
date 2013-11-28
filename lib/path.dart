library path;

import 'dart:js';


final JsObject _path = context.callMethod("require", ["path"]);


String join(List<String> paths) {
  try {
    return _path.callMethod("join", paths);
  } catch (err) {
    throw new PathException(err['message']);
  }
}

String resolve(List<String> from, String to) {
  try {
    from.add(to);
    return _path.callMethod("resolve", from);
  } catch (err) {
    throw new PathException(err['message']);
  }
}

String relative(String from, String to) {
  try {
    return _path.callMethod("relative", [from, to]);
  } catch (err) {
    throw new PathException(err['message']);
  }
}

String normalize(String path) {
  try {
    return _path.callMethod("normalize", [path]);
  } catch (err) {
    throw new PathException(err['message']);
  }
}

String dirname(String path) {
  try {
    return _path.callMethod("dirname", [path]);
  } catch (err) {
    throw new PathException(err['message']);
  }
}

String basename(String path) {
  try {
    return _path.callMethod("basename", [path]);
  } catch (err) {
    throw new PathException(err['message']);
  }
}

String extname(String path) {
  try {
    return _path.callMethod("extname", [path]);
  } catch (err) {
    throw new PathException(err['message']);
  }
}

String sep() {
  return _path['sep'];
}

String delimiter() {
  return _path['delimiter'];
}

class PathException {

  final String message;

  PathException(this.message);

  String toString() => message;

}
