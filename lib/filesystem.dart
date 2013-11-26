library filesystem;

import 'dart:async';

import 'src/filesystem/nodeFsWrapper.dart';


class File {
    
  final NodeFsWrapper _nodeFs;

  final String path;

  File(this.path) 
      : _nodeFs = new NodeFsWrapper();

  File._withNodeObj(this._nodeFs, this.path);


  Future<bool> exists() => _nodeFs.exists(path);


}
