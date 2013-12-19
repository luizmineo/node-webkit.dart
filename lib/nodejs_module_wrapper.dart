/**
 * Utility classes for wrapping nodejs modules.
 *
 * This library provides a way to properly wrap nodejs modules,
 * avoiding problems that can occur when objects coming from
 * the node's context, are accessed directly by Dart.
 *
 * For example, consider the following code:
 *
 *     import 'dart:js';
 *
 *     main() {
 *       ...
 *
 *       JsObject fs = context.callMethod("require", ["fs"]);
 *
 *       fs.callMethod("readFile", ["/home/user/file.txt", new JsObject.jsify({"encoding": "utf8"}), (err, [data]) {
 *         if (err != null) { 
 *           print(err['message']);
 *         } else {
 *           print(data);
 *         }
 *       }]);
 *
 *       ...
 *     }
 *
 * Compilling this code with dart2js and running it in node-webkit will produce
 * the expected result: the contents of the file will be printed in the console.
 * But, if you hit the refresh button, or call window.refresh(), the app crashs.
 *
 * It happens because when Dart access a JavaScript object, it creates a proxy,
 * and stores it in the object itself. Refreshing the page does not affect the
 * node context, only the webkit context. So, when Dart requires the fs module 
 * again, it tries to use the existing proxy in the fs object, wich was created 
 * in the previous webkit context, making the app crash. 
 *
 * Furthemore, this gets more complicated if your app has more than one window 
 * requiring the same module, wich means that one window will override the proxy
 * created in another. You can create windows with the 'new-instance' option
 * to avoid the problem, though this is not always possible (or desired).
 *
 * This library uses functions declared in the node_webkit.js file to
 * require objects from node's context, wich guarantees that proxies will
 * always reside in webkit context.
 *
 * Note: for more information about JavaScript contexts in node-webkit, 
 * please refer to 
 * <https://github.com/rogerwang/node-webkit/wiki/Differences-of-JavaScript-contexts>
 *
 * In addition, this library also helps to convert a JavaScript API to Dart,
 * properly proxying callbacks and eventEmitters to futures and streams.
 *
 * 
 */
library nodejs_module_wrapper;

import 'dart:js';
import 'dart:async';

final JsObject _nodeJsModuleWrapper = context["NodeJsModuleWrapper"];


Object getNativeProperty(Object object, String propertyName) {
  return _nodeJsModuleWrapper.callMethod("getNativeProperty", [object, propertyName]);
}


/**
 * A wrapper for nodejs's objects
 */
class NodeObject {
  
  final JsObject nativeObject;

  EventEmitter _eventEmitter;

  /**
   * Require a module from nodejs.
   */
  NodeObject(String moduleName)
      : nativeObject = new JsObject(_nodeJsModuleWrapper["NodeModule"], [moduleName]);

  /**
   * Wrap a JavaScript object
   */
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

  /**
   * Call a function of this object.
   *
   * If [async] is true, a generic callback will be added to the
   * arguments, and a Future object will be returned by this method. 
   * By default, the callback will expect only one argument, wich will 
   * be proxied to the Future object (if no value is passed to the callback,
   * the future object will receive null). 
   * 
   * If [errorHandler] is provided, then the callback will expect 
   * a error object and a value. If callback receives a error object, it is passed
   * to the [errorHandler], and the object returned is proxied to the Future.
   * The [errorHandler] function is also used to wrap exceptions, when [async]
   * is false.
   *
   * If the callback's signature is different than ([value]) and (err, [value]), a
   * [valueHandler] function can be provided. This function will receive all the
   * arguments received by the callback, and the returned value will be proxied
   * to the future object. It can also throw an error, that will be passed to
   * [errorHandler] (if provided), and proxied to the future object.
   *
   * If [callbackPos] is provided, then the callback will be inserted in that
   * specific position of the arguments list.
   *
   * Finally, if one of the arguments is a [NodeObject], then you must set
   * [unwrapArgs] to true.
   * 
   */
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

/**
 * Wrapper for EventEmitter objects.
 */
class EventEmitter {

  final NodeObject nodeObj;
  final Map<String, Stream> _cache = {};

  EventEmitter(this.nodeObj);

  /**
   * Returns a Stream for [eventType].
   *
   * If the [eventType] does not produce a value, 
   * a [event] object can be provided, wich will 
   * be passed to the stream every time the event is fired.
   *
   * Examples:
   *      Stream<int> stream = window.getStream("zoom");
   *      Stream<Window> stream = window.getStream("onMaximize", window);
   */
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

  /**
   * Wraps this [EventEmitter] in a [StreamController]
   */
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

    if (_valueHandler != null) {
      try {
        _completer.complete(_valueHandler(ret == null ? null : [ret]));
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
  }

  noSuchMethod(Invocation invocation) {
    if (_valueHandler == null) {
      throw new NoSuchMethodError(this, invocation.memberName, 
          invocation.positionalArguments, invocation.namedArguments);
    }

    _completer.complete(_valueHandler(invocation.positionalArguments));
  }

}
