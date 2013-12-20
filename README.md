Introduction
============

node-webkit.dart is a [Dart](http://www.dartlang.org/) package to build [node-webkit](https://github.com/rogerwang/node-webkit) apps.

To see how the node-webkit's API looks like in Dart, check out the sample application [here](https://github.com/luizmineo/node-webkit.dart/releases/tag/v0.0.1). Just download the **dart_examples.nw** archive, and open it with node-webkit. 

```
nw dart_examples.nw
```

Features
========

This package provides the following libraries:

- **nw_gui.dart**: A wrapper to the [nw_gui module](https://github.com/rogerwang/node-webkit/wiki/API-Overview-and-Notices)
- **path.dart**: A wrapper to the [path module](http://nodejs.org/api/path.html)
- **node_filesystem.dart**: A wrapper to the [fs module](http://nodejs.org/api/fs.html)
- **dart_filesystem.dart**: A complement to the node-filesystem library, wich provides the *FileSystemEntity*, *File*, *Directory* and *Link* classes, so you can access the filesystem just as you would do with **dart:io**
- **nodejs_module_wrapper.dart**: A helper library for wrapping nodejs's modules


Quick Start
===========

- Create a Dart package (you can follow the instructions [here](http://pub.dartlang.org/doc/))
- Add node-webkit.dart as a dependency

```
name: my_app
 dependencies:
   node_webkit: any
```
- Create a *package.json* file in *web* folder

```
{
  "name": "nw-demo",
  "main": "index.html"
}
```
- Create a *index.html* file in *web* folder

```html
<!DOCTYPE html>
<html>
  <head>
    <title>node-webkit.dart example</title>
  </head>
  
  <body>
    <script type="application/dart" src="index.dart"></script>
    <script src="packages/browser/interop.js"></script>
    <script src="packages/node-webkit/node_webkit.js"></script>
    <script src="packages/browser/dart.js"></script>

    <p id="msg"></p>
  </body>
</html>
```

- And finally, create a *index.dart* file in *web* folder

```dart

import 'dart:html';
import 'package:node_webkit/nw_gui.dart' as gui;

main() {
  querySelector("#msg").text = "Hello, ${getUsername()}!";
}

String getUsername() {
  return gui.App.argv.length > 0 ? gui.App.argv[0] : "Unknown";
}

```

- You can compile your app with *dart2js*

```
dart2js -o web/index.dart web/index.dart.js
nw web/ User
```
