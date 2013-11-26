import 'dart:js';
import 'dart:async';


/**
*
*
*/
class NodeFsWrapper {

  static NodeFsWrapper _instance;

  JsObject _fs;

  factory NodeFsWrapper() {
    if (_instance == null) {
        _instance = new NodeFsWrapper._fromJsObject(context.callMethod("require", ["fs"]));
    }

    return _instance;
  }

  NodeFsWrapper._fromJsObject(this._fs);

  Future<bool> exists(String path) {
    var comp = new Completer();

    _fs.callMethod("exists", [path, (exists) => comp.complete(exists)]);

    return comp.future;
  }
}
