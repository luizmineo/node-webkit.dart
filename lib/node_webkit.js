
NodeJsModuleWrapper = (function() {

  function verifyAndUnwrapArgs(args) {
    for(var i = 0; i < args.length; i++) {
      if (args[i] instanceof NodeModule) {
        args[i] = args[i]._getInnerObject();
      } else if(args[i]._dart_wrapped_properties) {
        for(var j = 0; j < args[i]._dart_wrapped_properties.length; j++) {
          var property = args[i]._dart_wrapped_properties[j];
          if (args[i][property]) {
            args[i][property] = args[i][property]._getInnerObject();
          }
        }
      }
    }
  }

  var NodeModuleWrapper = {

    _getInnerObject: function() {
      try {
        this._module = require(this._moduleName);
        return this._module;
      } finally {
        this['_getInnerObject'] = function() {
          return this._module;
        };
      }
    },

    callFunction: function(functionName, args, unwrapArgs) {
      if (unwrapArgs) {
        verifyAndUnwrapArgs(args);
      }
      return this._getInnerObject()[functionName].apply(this._getInnerObject(), args);
    },

    callConstructor: function(constructorName, args, unwrapArgs) {
      if (unwrapArgs) {
        verifyAndUnwrapArgs(args);
      }
      var innerObj = this._getInnerObject();
      var constructor = new Function("constructor", "args",
        "return function " + constructorName + "() {constructor.apply(this, args);}"
        )(innerObj[constructorName], args);
      constructor.prototype = innerObj[constructorName].prototype;
      
      return new constructor();
    },

    getProperty: function(propertyName) {
      return this._getInnerObject()[propertyName];
    },

    setProperty: function(propertyName, value) {
      if (value instanceof NodeModule) {
        value = value._getInnerObject();
      }
      this._getInnerObject()[propertyName] = value;
    }

  };

  var EventListenerWrapper = {

    _handler: function(eventListener, value) {
      if (typeof value !== "undefined") {
        eventListener(value);
      } else {
        eventListener();
      }
    },

    start: function() {
      var listener = this.eventListener;
      var handler = this._handler;
      this._eventEmitter.on(this.eventName, function(value) {
        handler(listener, value);
      });
    },

    stop: function() {
      this._eventEmitter.removeListener(this.eventName, this._handler);
    }

  };

  function NodeModule(moduleName) {
    this._moduleName = moduleName;
    return this;
  }

  NodeModule.prototype = NodeModuleWrapper;

  function NodeModuleProperty() {
    this._getInnerObject = function() {
      return this._property;
    };

    return this;
  }

  NodeModuleProperty.prototype = NodeModuleWrapper;

  function EventListener(eventName, eventListener) {
    this.eventName = eventName;
    this.eventListener = eventListener;
    return this;
  }

  EventListener.prototype = EventListenerWrapper;

  function wrapProperty(wrapper, propertyName) {
    var obj = new NodeModuleProperty();
    obj._property = wrapper.getProperty(propertyName);
    return obj;
  }

  function callFunctionAndWrap(wrapper, functionName, args, unwrapArgs) {
    var value = wrapper.callFunction(functionName, args ? args : [], unwrapArgs);
    if (typeof value === "undefined" || value === null) {
      return null;
    }
    var obj = new NodeModuleProperty();
    obj._property = value;
    return obj;
  }

  function callConstructorAndWrap(wrapper, constructorName, args, unwrapArgs) {
    var value = wrapper.callConstructor(constructorName, args ? args : [], unwrapArgs);
    if (typeof value === "undefined" || value === null) {
      return null;
    }
    var obj = new NodeModuleProperty();
    obj._property = value;
    return obj;
  }

  function addListenerToWrapper(wrapper, eventName, eventListener) {
    var controller = new EventListener(eventName, eventListener);
    controller._eventEmitter = wrapper._getInnerObject();
    return controller;
  }

  function addListenerToEventEmitter(eventEmitter, eventName, eventListener) {
    var controller = new EventListener(eventEmitter, eventListener);
    controller._eventEmitter = wrapper._getInnerObject();
    return controller; 
  }

  function getNativeProperty(obj, propertyName) {
    return obj[propertyName];
  }

  //public API
  return {

    NodeModule: NodeModule,

    wrapProperty: wrapProperty,

    callFunctionAndWrap: callFunctionAndWrap,

    callConstructorAndWrap: callConstructorAndWrap,

    addListenerToWrapper: addListenerToWrapper,

    addListenerToEventEmitter: addListenerToEventEmitter,

    getNativeProperty: getNativeProperty

  };

})();