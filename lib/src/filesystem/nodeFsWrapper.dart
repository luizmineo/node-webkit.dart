import 'dart:js';

/**
*
*
*/
class NodeFsWrapper {

	static NodeFsWrapper _instance;

	JsObject _fs;

	factory NodeFsWrapper() {
		if(_instance == null) {
			_instance = new NodeFsWrapper._fromJsObject(context.callMethod("require", ["fs"]));
		}

		return _instance;
	}

	NodeFsWrapper._fromJsObject(this._fs);

	
}
