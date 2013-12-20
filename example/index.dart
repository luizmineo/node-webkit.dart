import 'dart:async';
import 'dart:convert';
import 'dart:html' hide File;

import 'package:node_webkit/nw_gui.dart' as gui;
import 'package:node_webkit/node_filesystem.dart' as fs;
import 'package:node_webkit/dart_filesystem.dart';

main() {

  //Menubar

  var windowMenu = new gui.Menu(type: "menubar");

  var submenu1 = new gui.Menu();
  var menu1 = new gui.MenuItem(label: "Menu 1", submenu: submenu1);

  submenu1.append(new gui.MenuItem(label: "Menu Item 1"));
  submenu1.append(new gui.MenuItem(label: "Menu Item 2"));
  submenu1.append(new gui.MenuItem(label: "Menu Item 3"));

  submenu1.items.forEach((item) {
    item.onClick.listen((event) => print("${item.label} selected!"));
  });

  windowMenu.append(menu1);

  new gui.Window.get().menu = windowMenu;

  //Context Menu

  var contextMenu = new gui.Menu();

  contextMenu.append(new gui.MenuItem(label: "Menu Item 1"));
  contextMenu.append(new gui.MenuItem(label: "Menu Item 2"));
  contextMenu.append(new gui.MenuItem(label: "Menu Item 3"));

  contextMenu.items.forEach((item) {
    item.onClick.listen((event) => print("context menu: ${item.label} selected!"));
  });

  //NOTE: this [window] instance comes from dart:html
  window.onContextMenu.listen((event) => contextMenu.popup(event.page.x, event.page.y));

  //Window

  querySelector("#btn_maximize").onClick.listen((event) => new gui.Window.get().maximize());
  querySelector("#btn_unmaximize").onClick.listen((event) => new gui.Window.get().unmaximize());
  querySelector("#btn_minimize").onClick.listen((event) => new gui.Window.get().minimize());
  querySelector("#btn_restore").onClick.listen((event) {
    new gui.Window.get().minimize();
    new Timer(const Duration(seconds: 2), () => new gui.Window.get().restore());
  });

  querySelector("#btn_fullscreen").onClick.listen((event) => new gui.Window.get().enterFullscreen());
  querySelector("#btn_leavefullscreen").onClick.listen((event) => new gui.Window.get().leaveFullscreen());

  querySelector("#btn_kiosk").onClick.listen((event) => new gui.Window.get().enterKioskMode());
  querySelector("#btn_leavekiosk").onClick.listen((event) => new gui.Window.get().leaveKioskMode());

  querySelector("#btn_copyclipboard").onClick.listen((event) {
    new gui.Clipboard.get().data = (querySelector("#clipboard") as TextAreaElement).value;
  });
  querySelector("#btn_pasteclipboard").onClick.listen((event) {
    (querySelector("#clipboard") as TextAreaElement).value = new gui.Clipboard.get().data;
  });

  querySelector("#commandline").text = "Command line args: ${gui.App.argv}";

  //node-filesystem
  var inputFileOrigin = querySelector("#input_file_origin1");
  inputFileOrigin.onChange.listen((event) {
    var filePath = fs.getPath(inputFileOrigin.files[0]);
    fs.readFileAsString(filePath).then((text) {
      (querySelector("#textarea_filecontent1") as TextAreaElement).value = text;
    });
  });

  var inputFileDestiny = querySelector("#input_file_destiny");
  var textElement = querySelector("#textarea_filecontent");
  querySelector("#btn_nodesavefile").onClick.listen((event) {
    if(inputFileDestiny.files.isEmpty) {
      return;
    }
    var filePath = fs.getPath(inputFileDestiny.files[0]);
    fs.writeFileAsString(filePath, textElement.value).then((_) => print("file $filePath saved"));
  });

  //dart-filesystem
  var dartInputFile = querySelector("#input_file_origin2");
  var dartTextElement = querySelector("#textarea_filecontent2");
  dartInputFile.onChange.listen((event) {
    var filePath = fs.getPath(dartInputFile.files[0]);
    dartTextElement.value = "";

    var file = new File(filePath);
    file.openReadAsString()
        .transform(new LineSplitter())
        .listen((line) {
          dartTextElement.value += "$line\n";
        },
        onDone: () => print("Finished reading file $filePath"),
        onError: (err) => print("Failed to read file $filePath: $err"));
  });


  var inputDir = querySelector("#input_file_dir");
  var textElementDir = querySelector("#textarea_dircontent");
  var checkboxRecursive = querySelector("#recursive");

  var buttonListDir = querySelector("#btn_listdir");
  var buttonPause = querySelector("#btn_pauselistdir");
  var buttonCancel = querySelector("#btn_cancellistdir");
  var buttonResume = querySelector("#btn_resumelistdir");

  var subscription;

  buttonListDir.onClick.listen((event) {
    if (inputDir.files.isEmpty) {
      return;
    }
    var dirPath = fs.getPath(inputDir.files[0]);
    textElementDir.value = "";
    
    Directory dir = new Directory(dirPath);
    subscription = dir.list(recursive: checkboxRecursive.checked)
      .listen((entity) {
          textElementDir.value += "${entity is File ? 'File' : 'Directory'}: ${entity.path}\n";
        }, 
        onError: (err) => print("Error received while listing $dirPath: $err"), 
        onDone: () {
          print("Finished listing $dirPath");
          buttonPause.disabled = true;
          buttonResume.disabled = true;
          buttonCancel.disabled = true;
          buttonListDir.disabled = false;
        }
      );

    buttonListDir.disabled = true;
    buttonPause.disabled = false;
    buttonCancel.disabled = false;
  });

  buttonPause.onClick.listen((event) {
    subscription.pause();
    buttonPause.disabled = true;
    buttonResume.disabled = false;
  });

  buttonCancel.onClick.listen((event) {
    subscription.cancel();
    buttonPause.disabled = true;
    buttonResume.disabled = true;
    buttonCancel.disabled = true;
    buttonListDir.disabled = false;
  });

  buttonResume.onClick.listen((event) {
    subscription.resume();
    buttonPause.disabled = false;
    buttonResume.disabled = true;
  });



  var inputFileFrom = querySelector("#input_file_copy_from");
  var inputFileTo = querySelector("#input_file_copy_to");
  var buttonCopy = querySelector("#btn_copy_file");
  var progress = querySelector("#copy_progress");

  buttonCopy.onClick.listen((event) {

    if (inputFileFrom.files.isEmpty || inputFileTo.files.isEmpty) {
      return;
    }

    File fileFrom = new File(fs.getPath(inputFileFrom.files[0]));
    File fileTo = new File(fs.getPath(inputFileTo.files[0]));

    var writer;
    try {
      writer = fileTo.openWrite();
    } catch (err) {
      print("Failed to open file ${fileTo.path}: $err");
      progress.text = "Failed to open file ${fileTo.path}: $err";
    }

    var reader;
    try {
      reader = fileFrom.openReadSync();
    } catch (err) {
      print("Failed to open file ${fileFrom.path}: $err");
      progress.text = "Failed to open file ${fileFrom.path}: $err";
    }

    progress.text = "Copying file...";

    reader.onReadable.listen((_) {
      var data;
      while ((data = reader.read(1024)) != null) {
        writer.write(data);
      }
    });
    reader.onEnd.listen((_) {
      writer.close();
      print("File ${fileFrom.path} copied to ${fileTo.path}");
      progress.text = "File ${fileFrom.path} copied to ${fileTo.path}";
    });
    reader.onError.listen((err) {
      print("Failed to copy file: $err");
      progress.text = "Failed to copy file: $err";
    });

  });

}

