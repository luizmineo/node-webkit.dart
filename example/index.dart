import 'package:node-webkit/node_filesystem.dart' as fs;
import 'package:node-webkit/dart_filesystem.dart';
//import 'dart:js';


main() {

  // context.callMethod("testDartJsInterop", [(obj) {
  //   print("obj is JsArray? ${obj is JsArray}");
  //   print("obj is JsObject? ${obj is JsObject}");
  // }]);
  
  var path1 = "/home/luiz/teste";
  var path2 = "/home/luiz/dev";

  var path3 = "/home/luiz/dev/test1/test2/test3";

  File file = new File(path1);

  print("File reference created!");

  file.exists().then((exists) => print("${file.name} => ${file.path} exists? $exists"));

  File file2 = new File(path2);

  file2.exists().then((exists) => print("${file2.name} => ${file2.path} exists? $exists"));

  file2.stat().then((fs.FileStat stat) => print(stat));

  // Directory dir = new Directory(path2);

  // dir.list(recursive: true).listen((entity) {
  //   /*print("${entity.path} => ${entity.name}");*/
  // }, onError: (error) => print("error: $error"), onDone: () => print("done!"));

  // dir.listSync().forEach((entity) {
  //   print("${entity.name} => ${entity.path}");
  // });

  /*dir.listSync(recursive: true).forEach((entity) {
    print("${entity.path} => ${entity.name}");
  });*/

  new Directory(path3).create(recursive: true).then((dir) => print("${dir.path} criado"));
}

