import 'dart:convert';
import 'dart:io';

import 'CompilationEngine.dart';
//C:\nand2tetris\projects\10\ArrayTest
//C:\nand2tetris\projects\10\ArrayTest
main(List<String> arguments) async {
  var FileInputPath =  arguments[0];

  // Get the system temp directory .
  var systemTempDir = Directory.systemTemp;
  var path = FileInputPath;

  final dir = Directory(FileInputPath);
  final List<FileSystemEntity> entities = await dir.list().toList();

  //outputFile.writeAsStringSync(push("constant", "16"));
  for (var file in entities) {
    if (file.path.endsWith("Sys.vm")) {

    }
  }

  for (var file in entities) {
    if (!file.path.endsWith(".jack")) {
      continue;
    }

    path = file.path;
    //print("compiling $path");

    String outputFileName = path.substring(path.lastIndexOf("\\"),path.lastIndexOf(".jack"));

    //print("file name = $outputFileName");


    var output = new File(FileInputPath + outputFileName+"US.xml");
    output.writeAsStringSync("");
    print(output.path);
    var input = new File(file.path);
    var engine = new CompilationEngine(input,output);
    engine.CompileClass();
  }







}
