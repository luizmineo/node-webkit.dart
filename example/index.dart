import 'package:node-webkit/filesystem.dart';

main() {
  
  var path1 = "/home/luiz/teste";
  var path2 = "/home/luiz/dev";

  File file = new File(path1);

  file.exists().then((exists) => print("$path1 exists? $exists"));

  File file2 = new File(path2);

  file2.exists().then((exists) => print("$path2 exists? $exists"));
  
}

