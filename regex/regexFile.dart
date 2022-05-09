


import 'dart:io';

main(List<String> arguments) {

  String path = arguments[0];

  String outputFilePath = path + path.substring(path.lastIndexOf("\\")) +
      ".asm";

  RegExp reg = new RegExp(r'^[a-zA-Z0-9]+$');

  var regRes = reg.allMatches(input);

  for(var s in regRes){
    print(s.toString());
  }

  print(regRes);
  
}