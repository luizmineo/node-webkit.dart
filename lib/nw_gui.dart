library nw_gui;

import 'dart:js';
import 'dart:html' as html;
import 'dart:async';
import 'dart:collection';

import 'package:node-webkit/nodejs_module_wrapper.dart';


final NodeObject _gui = new NodeObject("nw.gui");
final NodeObject _App = _gui.wrapProperty("App");
final NodeObject _Shell = _gui.wrapProperty("Shell");
final NodeObject _Window = _gui.wrapProperty("Window");
final NodeObject _Clipboard = _gui.wrapProperty("Clipboard");

final EventEmitter _appEventEmitter = new EventEmitter(_App);

const AppScope App = const AppScope();
const ShellScope Shell = const ShellScope();


class AppScope {

  const AppScope();

  List<String> get argv => _App['argv'];

  List<String> get fullArgv => _App['fullArgv'];

  String get dataPath => _App['dataPath'];

  JsObject get manifest => _App['manifest'];

  void clearCache() => _App.callFunction("clearCache", []);

  void closeAllWindows() => _App.callFunction("closeAllWindows", []);

  void quit() => _App.callFunction("quit", []);

  Stream<String> get onOpen => _appEventEmitter.getStream("open");

  Stream get onReopen => _appEventEmitter.getStream("reopen");

}

class ShellScope {

  const ShellScope();
 
  void openExternal(String uri) => _Shell.callFunction("openExternal", [uri]);

  void openItem(String filePath) => _Shell.callFunction("openItem", [filePath]);

  void showItemInFolder(String filePath) => _Shell.callFunction("showItemInFolder", [filePath]);

}

class Window {
  
  final NodeObject _window;
  EventEmitter _eventEmitter;

  Menu _menu;

  Window._fromNodeObject(this._window) {
    _eventEmitter = new EventEmitter(_window);
  }

  static Window _localInstance;
  static final Map<html.Window, Window> _instances = {};

  factory Window.get([html.Window window]) {
    if (window == null) {
      if (_localInstance == null) {
        _localInstance = new Window._fromNodeObject(
            _Window.callFunctionAndWrap("get", []));
      }
      return _localInstance;
    } else {
      var instance = _instances[window];
      if (instance == null) {
        instance = new Window._fromNodeObject(
            _Window.callFunctionAndWrap("get", [window]));
        _instances[window] = instance;
      }
      return instance;
    }
  }

  factory Window.open(String url, {String title, String icon, bool toolbar, 
                           bool frame, int width, int height, String position,
                           int minWidth, int minHeight, int maxWidth, int maxHeight,
                           bool newInstance, bool focus}) {

    var opts = {};
    if (title != null) {
      opts['title'] = title;
    }
    if (icon != null) {
      opts['icon'] = icon;
    }
    if (toolbar != null) {
      opts['toolbar'] = toolbar;
    }
    if (frame != null) {
      opts['frame'] = frame;
    }
    if (width != null) {
      opts['width'] = width;
    }
    if (height != null) {
      opts['height'] = height;
    }
    if (position != null) {
      opts['position'] = position;
    }
    if (minWidth != null) {
      opts['min_width'] = minWidth;
    }
    if (minHeight != null) {
      opts['min_height'] = minHeight;
    }
    if (maxWidth != null) {
      opts['max_width'] = maxWidth;
    }
    if (maxHeight != null) {
      opts['max_height'] = maxHeight;
    }
    if (newInstance != null) {
      opts['new-instance'] = newInstance;
    }
    if (focus != null) {
      opts['focus'] = focus;
    }

    return new Window._fromNodeObject(_Window.callFunctionAndWrap("open", [url, new JsObject.jsify(opts)]));
  }

  html.Window get window => _window["window"];

  num get x => _window["x"];

  set x(num x) => _window["x"] = x;

  num get y => _window["y"];

  set y(num y) => _window["y"] = y;

  num get width => _window["width"];

  set width(num width) => _window["width"] = width;

  num get height => _window["height"];

  set height(num height) => _window["height"] = height;

  String get title => _window["title"];

  set title(String title) => _window["title"] = title;

  bool get isFullscreen => _window["isFullscreen"];

  set isFullscreen(bool isFullscreen) => _window["isFullscreen"] = isFullscreen;

  bool get isKioskMode => _window["isKioskMode"];

  set isKioskMode(bool isKioskMode) => _window["isKioskMode"] = isKioskMode;

  num get zoomLevel => _window["zoomLevel"];

  set zoomLevel(num zoomLevel) => _window["zoomLevel"] = zoomLevel;

  Menu get menu => _menu;

  set menu(Menu menu) {
    _window["menu"] = menu._menu.nativeObject;
    _menu = menu;
  }

  void moveTo(num x, num y) => _window.callFunction("moveTo", [x, y]);

  void moveBy(num x, num y) => _window.callFunction("moveBy", [x, y]);  

  void resizeTo(num width, num height) => _window.callFunction("resizeTo", [width, height]);

  void resizeBy(num width, num height) => _window.callFunction("resizeBheight", [width, height]);  

  void focus() => _window.callFunction("focus", []);

  void blur() => _window.callFunction("blur", []);

  void show([bool show = true]) => _window.callFunction("show", [show]);

  void hide() => _window.callFunction("hide", []);

  void close([bool force = true]) => _window.callFunction("close", [force]);

  void reload() => _window.callFunction("reload", []);

  void reloadIgnoringCache() => _window.callFunction("reloadIgnoringCache", []);

  void maximize() => _window.callFunction("maximize", []);

  void unmaximize() => _window.callFunction("unmaximize", []);

  void minimize() => _window.callFunction("minimize", []);

  void restore() => _window.callFunction("restore", []);

  void enterFullscreen() => _window.callFunction("enterFullscreen", []);

  void leaveFullscreen() => _window.callFunction("leaveFullscreen", []);

  void toggleFullscreen() => _window.callFunction("toggleFullscreen", []);

  void enterKioskMode() => _window.callFunction("enterKioskMode", []);

  void leaveKioskMode() => _window.callFunction("leaveKioskMode", []);

  void toggleKioskMode() => _window.callFunction("toggleKioskMode", []);

  Window showDevTools({String frameId, html.IFrameElement frameElement, bool headless}) {
    List args = [];

    if (frameElement != null) {
      args.add(frameElement);
    } else if (frameId != null) {
      args.add(frameId);
    }

    if (headless != null) {
      if (frameElement == null && frameId == null) {
        args.add("");
      }
      args.add(headless);
    }

    var newWindow = _window.callFunctionAndWrap("showDevTools", args);
    if (newWindow == null) {
      return null;
    }
    return new Window._fromNodeObject(newWindow);
  }

  void closeDevTools() => _window.callFunction("closeDevTools", []);

  bool isDevToolsOpen() => _window.callFunction("isDevToolsOpen", []);

  void setMaximumSize(num width, num height) => _window.callFunction("setMaximumSize", [width, height]);

  void setMinimumSize(num width, num height) => _window.callFunction("setMinimumSize", [width, height]);

  void setResizable(bool resizable) => _window.callFunction("setResizable", [resizable]);

  void setAlwaysOnTop(bool top) => _window.callFunction("setAlwaysOnTop", [top]);

  void setPosition(String position) => _window.callFunction("setPosition", [position]);

  void requestAttention(bool attention) => _window.callFunction("requestAttention", [attention]);

  Future<String> capturePage([String imageFormat]) 
      => _window.callFunction("capturePage", imageFormat != null ? [imageFormat] : [], async: true, callbackPos: 0);

  Stream<Window> get onClose => _eventEmitter.getStream("close", this);

  Stream<Window> get onClosed => _eventEmitter.getStream("closed", this);

  Stream<Window> get onLoading => _eventEmitter.getStream("loading", this);

  Stream<Window> get onLoaded => _eventEmitter.getStream("loaded", this);

  Stream<Window> get onFocus => _eventEmitter.getStream("focus", this);

  Stream<Window> get onBlur => _eventEmitter.getStream("blur", this);

  Stream<Window> get onMinimize => _eventEmitter.getStream("minimize", this);

  Stream<Window> get onRestore => _eventEmitter.getStream("restore", this);

  Stream<Window> get onMaximize => _eventEmitter.getStream("maximize", this);

  Stream<Window> get onUnmaximize => _eventEmitter.getStream("unmaximize", this);

  Stream<Window> get onEnterFullscreen => _eventEmitter.getStream("enter-fullscreen", this);

  Stream<num> get onZoom => _eventEmitter.getStream("zoom");

  Stream<String> get onCapturePageDone => _eventEmitter.getStream("capturepagedone");

  Stream<String> get onDevToolsOpened => _eventEmitter.getStream("devtools-opened");

  Stream<Window> get onDevToolsClosed => _eventEmitter.getStream("devtools-closed");
}

class Menu {
  
  final NodeObject _menu;
  final MenuItemList items = new MenuItemList._from([]);

  Menu._fromOpts(JsObject opts)
      : _menu = _gui.callConstructorAndWrap("Menu", opts != null ? [opts] : []);

  factory Menu({String type}) {
    var opts = null;
    if (type != null) {
      opts = new JsObject.jsify({"type": type});
    }

    return new Menu._fromOpts(opts);
  }

  void append(MenuItem item) {
    _menu.callFunction("append", [item._menuItem.nativeObject], unwrapArgs: true);
    items._internalList.add(item);
  }

  void insert(MenuItem item, int i) {
    _menu.callFunction("insert", [item._menuItem.nativeObject, i], unwrapArgs: true);
    items._internalList.insert(i, item);
  }

  void remove(MenuItem item) {
    _menu.callFunction("remove", [item._menuItem.nativeObject], unwrapArgs: true);
    items._internalList.remove(item);
  }

  void removeAt(int i) {
    _menu.callFunction("removeAt", [i]);
    items._internalList.removeAt(i);
  }

  void popup(int x, int y) => _menu.callFunction("popup", [x, y]);
}

class MenuItemList extends ListBase<MenuItem> {
  
  final List<MenuItem> _internalList;

  MenuItemList._from(List<MenuItem> this._internalList);

  get length => _internalList.length;

  set length(int length) => throw new UnsupportedError("This List is a view, and can't be modified directly.");

  operator []= (int index, MenuItem value) => throw new UnsupportedError("This List is a view, and can't be modified directly.");

  MenuItem operator [] (int index) => _internalList[index];

}


class MenuItem {
  
  final NodeObject _menuItem;
  EventEmitter _eventEmitter;

  Menu _submenu;

  MenuItem._fromOpts(JsObject opts, [Menu this._submenu])
      : _menuItem = _gui.callConstructorAndWrap("MenuItem", opts != null ? [opts] : [], unwrapArgs: true) {
    _eventEmitter = new EventEmitter(_menuItem);
  }


  factory MenuItem({String type, String label, String icon, String tooltip, bool checked, bool enabled,
                    Menu submenu, void onclick(html.Event event)}) {

    var opts = {"_dart_wrapped_properties": ["submenu"]};
    if (type != null) {
      opts['type'] = type;
    }
    if (label != null) {
      opts['label'] = label;
    }
    if (icon != null) {
      opts['icon'] = icon;
    }
    if (tooltip != null) {
      opts['tooltip'] = tooltip;
    }
    if (checked != null) {
      opts['checked'] = checked;
    }
    if (enabled != null) {
      opts['enabled'] = enabled;
    }
    if (submenu != null) {
      opts['submenu'] = submenu._menu.nativeObject;
    }
    if (onclick != null) {
      opts['click'] = onclick;
    }
    
    return new MenuItem._fromOpts(new JsObject.jsify(opts), submenu);
  }

  String get type => _menuItem["type"];

  set type(String type) => _menuItem["type"] = type;

  String get label => _menuItem["label"];

  set label(String label) => _menuItem["label"] = label;

  String get icon => _menuItem["icon"];

  set icon(String icon) => _menuItem["icon"] = icon;

  String get tooltip => _menuItem["tooltip"];

  set tooltip(String tooltip) => _menuItem["tooltip"] = tooltip;

  bool get checked => _menuItem["checked"];

  set checked(bool checked) => _menuItem["checked"] = checked;

  bool get enabled => _menuItem["enabled"];

  set enabled(bool enabled) => _menuItem["enabled"] = enabled;

  Menu get submenu => _submenu;

  set submenu(Menu value) {
    _menuItem["submenu"] = value._menu.nativeObject;
    _submenu = value;
  }

  Stream<html.Event> get onClick => _eventEmitter.getStream("click");

}

class Clipboard {
  
  static Clipboard _instance;

  final NodeObject _clipboard;

  Clipboard._fromNodeObject(NodeObject this._clipboard);

  factory Clipboard.get() {
    if (_instance != null) {
      return _instance;
    }

    _instance = new Clipboard._fromNodeObject(_Clipboard.callFunctionAndWrap("get", []));
    return _instance;
  }

  String get data => _clipboard.callFunction("get", []);

  set data(String data) => _clipboard.callFunction("set", [data]);

  void clear() => _clipboard.callFunction("clear", []);
}

class Tray {
  
  final NodeObject _tray;
  EventEmitter _eventEmitter;

  Menu _menu;

  Tray._fromOpts(JsObject opts, [Menu this._menu])
      : _tray = _gui.callConstructorAndWrap("Tray", opts != null ? [opts] : [], unwrapArgs: true) {
    _eventEmitter = new EventEmitter(_tray);
  }

  factory Tray({String title, String tooltip, String icon, Menu menu}) {
    var opts = {"_dart_wrapped_properties": ["menu"]};
    if (title != null) {
      opts['title'] = title;
    }
    if (tooltip != null) {
      opts['tooltip'] = tooltip;
    }
    if (icon != null) {
      opts['icon'] = icon;
    }
    if (menu != null) {
      opts['menu'] = menu._menu.nativeObject;
    }

    return new Tray._fromOpts(new JsObject.jsify(opts), menu);
  }

  String get title => _tray["title"];

  set title(String title) => _tray["title"] = title;

  String get tooltip => _tray["tooltip"];

  set tooltip(String tooltip) => _tray["tooltip"] = tooltip;

  String get icon => _tray["icon"];

  set icon(String icon) => _tray["icon"] = icon;

  String get alticon => _tray["alticon"];

  set alticon(String alticon) => _tray["alticon"] = alticon;

  Menu get menu => _menu;

  set menu(Menu menu) {
    _tray["menu"] = menu._menu.nativeObject;
    _menu = menu;
  }

  void remove() => _tray.callFunction("remove", []);

  Stream<Tray> get onClick => _eventEmitter.getStream("click", this);
}




