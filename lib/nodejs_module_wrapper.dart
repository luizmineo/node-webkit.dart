library nodejs_module_wrapper;

import 'dart:js';
import 'dart:async';



final JsObject _nodeJsModuleWrapper = context["NodeJsModuleWrapper"];

Object getNativeProperty(Object object, String propertyName) {
  return _nodeJsModuleWrapper.callMethod("getNativeProperty", [object, propertyName]);
}


class NodeObject {
  
  final JsObject nativeObject;

  EventEmitter _eventEmitter;

  NodeObject(String moduleName)
      : nativeObject = new JsObject(_nodeJsModuleWrapper["NodeModule"], [moduleName]);

  NodeObject.fromJsObj(JsObject obj)
      : nativeObject = obj;

  operator [](String propertyName) {
    return nativeObject.callMethod("getProperty", [propertyName]);
  }

  operator []=(String propertyName, Object value) {
    nativeObject.callMethod("setProperty", [propertyName, value]);
  }

  NodeObject wrapProperty(String propertyName) {
    var wrapper = _nodeJsModuleWrapper.callMethod("wrapProperty", [nativeObject, propertyName]);
    return new NodeObject.fromJsObj(wrapper);
  }

  NodeObject callFunctionAndWrap(String functionName, List args, {bool unwrapArgs: false}) {
    var wrapper = _nodeJsModuleWrapper.callMethod("callFunctionAndWrap", [nativeObject, functionName, new JsObject.jsify(args), unwrapArgs]);
    return new NodeObject.fromJsObj(wrapper);
  }

  NodeObject callConstructorAndWrap(String constructorName, List args, {bool unwrapArgs: false}) {
    var wrapper = _nodeJsModuleWrapper.callMethod("callConstructorAndWrap", [nativeObject, constructorName, new JsObject.jsify(args), unwrapArgs]);
    return new NodeObject.fromJsObj(wrapper);
  }

  dynamic callFunction(String functionName, List args, {bool async: false, 
        int callbackPos, bool unwrapArgs: false,
        Object errorHandler(JsObject error), Object valueHandler(List values)}) {

    if (async == null || !async) {
      try {
        return nativeObject.callMethod("callFunction", [functionName, new JsObject.jsify(args), unwrapArgs]);
      } catch (err) {
        if (errorHandler != null) {
          throw errorHandler(err);
        }
        throw err;
      }
    }

    return new Future.sync(() {
      var completer = new Completer();

      if (callbackPos == null) {
        args.add(new _Callback(completer, valueHandler, errorHandler));
      } else {
        args.insert(callbackPos, new _Callback(completer, valueHandler, errorHandler)); 
      }
      try {
        nativeObject.callMethod("callFunction", [functionName, new JsObject.jsify(args), unwrapArgs]);
      } catch (err) {
        if (errorHandler != null) {
          throw errorHandler(err);
        }
        throw err;
      }
      return completer.future;
    });

  }

  EventEmitter asEventEmitter() {
    if (_eventEmitter == null) {
      _eventEmitter = new EventEmitter(this);
    }
    return _eventEmitter;
  }

}

class EventEmitter {

  final NodeObject nodeObj;
  final Map<String, Stream> _cache = {};

  EventEmitter(this.nodeObj);

  Stream getStream(String eventType, [Object event]) {
    var stream = _cache[eventType];
    if (stream != null) {
      return stream;
    }

    var controller;

    var nativeController = _nodeJsModuleWrapper.callMethod("addListenerToWrapper", [nodeObj.nativeObject, eventType, ([value]) {
      if (event != null) {
        controller.add(event);
      } else {
        controller.add(value);
      }
    }]);

    onListen() {
      nativeController.callMethod("start");
    }

    onCancel() {
      nativeController.callMethod("stop");
    }

    controller = new StreamController.broadcast(onListen: onListen, onCancel: onCancel);
    _cache[eventType] = controller.stream;
    return controller.stream;
  }

  StreamController createStreamController({String dataEvent: "data", Object dataHandler(data), Object errorHandler(error)}) {
    var controller;

    var canceled = false;

    nodeObj.callFunction("on", ["end", () {
      controller.close();
    }]);

    nodeObj.callFunction("on", ["error", (error) {
      if (errorHandler != null) {
        controller.addError(errorHandler(error));
      }
      controller.addError(error);
    }]);

    onListen() {
      if (canceled) {
        return new EventEmitterException("Stream already closed");
      }
      nodeObj.callFunction("on", [dataEvent, (data) {
        if (dataHandler != null) {
          controller.add(dataHandler(data));
        } else {
          controller.add(data);
        }
      }]);
    }

    onPause() {
      nodeObj.callFunction("pause", []);
    }

    onResume() {
      nodeObj.callFunction("resume", []);
    }

    onCancel() {
      canceled = true;
      nodeObj.callFunction("destroy", []);
    }

    controller = new StreamController(onListen: onListen,
                            onPause: onPause,
                            onResume: onResume,
                            onCancel: onCancel);
    return controller;
  }

}

class EventEmitterException {
  
  final String message;

  EventEmitterException([String this.message]);

}


class _Callback {
  
  final _completer;
  final _valueHandler;
  final _errorHandler;

  _Callback(this._completer, this._valueHandler, this._errorHandler);

  call([obj1, obj2]) {
    var ret;
    var err;
    if (_errorHandler == null) {
      ret = obj1;
    } else {
      err = obj1;
      ret = obj2;
    }

    if (err != null) {
      _completer.completeError(_errorHandler(err));
      return;
    }

    if (ret != null) {
      if (_valueHandler != null) {
        try {
          _completer.complete(_valueHandler(ret));
        } catch (err) {
          if (_errorHandler != null) {
            _completer.completeError(_errorHandler(err));
          } else {
            _completer.completeError(err);   
          }
        }
      } else {
        _completer.complete(ret);
      }
    } else {
      _completer.complete();
    }
  }

  noSuchMethod(Invocation invocation) {
    if (_valueHandler == null) {
      throw new NoSuchMethodError(this, invocation.memberName, 
          invocation.positionalArguments, invocation.namedArguments);
    }

    _completer.complete(_valueHandler(invocation.positionalArguments));
  }

}
