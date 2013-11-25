library filesystem;

import 'src/filesystem/nodeFsWrapper.dart';


class File {
	
	final NodeFsWrapper _nodeFs;

	String path;

	File(this.path) : _nodeFs = new NodeFsWrapper();

	File._withNodeObj(this._nodeFs, this.path);



}
