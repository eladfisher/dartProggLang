

import 'package:dart_application_1/dart_application_1.dart'
as dart_application_1;
import 'dart:io';

//C:\dartFiles
//C:\nand2tetris\projects\07\StackArithmetic\SimpleAdd
int runingNumber = 1;
String fileName = "";

main() async {
  String path = stdin.readLineSync()!;
  String outputFilePath = path + path.substring(path.lastIndexOf("\\")) +
      ".asm";

  File outputFile = File(outputFilePath);

  var temp = outputFile.path.lastIndexOf("\\");
  fileName=outputFile.path.substring(temp + 1, outputFile.path.length - 4);
  outputFile.writeAsStringSync("");

  // Get the system temp directory.
  var systemTempDir = Directory.systemTemp;

  final dir = Directory(path);
  final List<FileSystemEntity> entities = await dir.list().toList();

  //outputFile.writeAsStringSync(push("constant", "16"));

  for (var file in entities) {
    if (!file.path.endsWith("vm")) {
      continue;
    }

    File inputFile = File(file.path);
    var lines = inputFile.readAsLinesSync();



    for (var line in lines) {

      List<String> list = line.split(" ");
      String res ="";
      runingNumber++;




      if(list[0]=="pop") {
        res = pop( list[1], list[2]);

        if(res=="")
          print("ERROR");
      }

      if(list[0]=="push") {
        res = push( list[1], list[2]);

        if(res=="")
          print("ERROR");
      }

      if(list[0]=="add") {
        res = add();
      }

      if(list[0]=="eq") {
        res = eq();
      }

      if(list[0]=="not") {
        res=not();
      }

      if(list[0]=="lt") {
        res=lt();
      }

      if(list[0]=="gt") {
        res=gt();
      }

      if(list[0]=="and") {
        res=and();
      }

      if(list[0]=="or") {
        res=or();
      }

      if(list[0]=="sub") {
        res=sub();
      }


      if(list[0]=="neg") {
        res=neg();
      }





      outputFile.writeAsStringSync(res,mode:FileMode.append);




  }
}
}

String pop(String type, String val){
  String res ="";

  if(type == "static"){
    res = """
    //pop static $val
    @SP
    A=M-1
    D=M
    @$fileName.$val	      	
    M=D
    @SP
    M=M-1

    """;
  }

  if(type == "pointer"){

    if(val == "0"){
      res = """
      //pop pointer 0
      @SP  		// @0
      A=M-1
      D=M
      @THIS		// @3
      M=D
      @SP
      M=M-1

      """;
    }

    if(val == "1"){
      res = """
      //pop pointer 1
      @SP 	 	
      A=M-1
      D=M
      @THAT	
      M=D
      @SP
      M=M-1

    """;
    }

  }

  if(type == "temp"){
    runingNumber++;
    res = """
    // pop temp {index}
    @5
    D=A
    @$val
    D=D+A
    @addr_$runingNumber
    M=D
    @SP
    M=M-1
    A=M
    D=M
    @addr_$runingNumber
    A=M
    M=D
    """;
  }

  if(type == "this"){
    runingNumber++;
    res = """
    // pop this {index}
    @THIS
    D=M
    @$val
    D=D+A
    @addr_$runingNumber
    M=D
    @SP
    M=M-1
    A=M
    D=M
    @addr_$runingNumber
    A=M
    M=D
    """;
  }

  if(type == "that"){
    runingNumber++;
    res = """
    // pop that {index}
    @THAT
    D=M
    @$val
    D=D+A
    @addr_$runingNumber
    M=D
    @SP
    M=M-1
    A=M
    D=M
    @addr_$runingNumber
    A=M
    M=D
    """;
  }

  if(type == "local"){
    runingNumber++;
    res = """
    // pop LCL {index}
    @LCL
    D=M
    @$val
    D=D+A
    @addr_$runingNumber
    M=D
    @SP
    M=M-1
    A=M
    D=M
    @addr_$runingNumber
    A=M
    M=D
    """;
  }

  if(type == "argument"){
    runingNumber++;
    res = """
    // pop ARG {index}
    @ARG
    D=M
    @$val
    D=D+A
    @addr_$runingNumber
    M=D
    @SP
    M=M-1
    A=M
    D=M
    @addr_$runingNumber
    A=M
    M=D
    """;
  }

  return res;
}

String push(String type, String val){

  String res="";

  if(type == "static"){
    res = """
    //push static $val
    @$fileName.$val	
    D=M
    @SP
    A=M
    M=D
    @SP
    M=M+1

    """;

  }

  if(type == "pointer"){
    if(val == "0"){
      res = """
        //push pointer 0
        @THIS		
        D=M
        @SP
        A=M
        M=D
        @SP
        M=M+1
      """;
    }

    if(val == "1"){
      res = """
      //push pointer 1
      @THAT	
      D=M
      @SP
      A=M
      M=D
      @SP
      M=M+1

      """;
    }
  }

  if(type == "constant"){
   res = """
  // push constant $val
  @$val
  D=A
  @SP
  A=M
  M=D
  @SP
  M=M+1
  """;
  }

  if(type == "local"){
  res = """//push local 
  @$val		 
  D=A
  @LCL
  A=M+D
  D=M
  @SP
  A=M
  M=D
  @SP
  M=M+1""";
  }

  if(type == "argument") {
    res = """
    // push argument 
  @$val		 //=@SP
  D=A
  @ARG
  A=M+D
  D=M
  @SP
  A=M
  M=D
  @SP
  M=M+1
    """;
  }

  if(type == "this") {
    res = """
    @THIS//push this
                   D=M
                   @$val
                   D=D+A
                   A=D
                   D=M
                   @SP
                   A=M
                   M=D
                   @SP
                   M=M+1
    """;

  if(type == "") {
    res = """
    
    """;
  }

  if(type == "") {
    res = """
    
    """;
  }

  return res;
}

  if(type == "that") {
    res = """
    // push argument 
  @$val		 //=@SP
  D=A
  @THAT
  A=M+D
  D=M
  @SP
  A=M
  M=D
  @SP
  M=M+1
    """;

    if(type == "") {
      res = """
    
    """;
    }

    if(type == "") {
      res = """
    
    """;
    }

    return res;
  }

  if(type == "temp") {
    res = """
    // push temp $val
                   @5
                   D=A
                   @$val
                   D=D+A
                   A=D
                   D=M
                   @SP
                   A=M
                   M=D
                   @SP
                   M=M+1
    """;

    if(type == "") {
      res = """
    
    """;
    }

    if(type == "") {
      res = """
    
    """;
    }

    return res;
  }

  return res;
}

String add(){
  return """
  // add
  @SP
  A=M-1
  D=M
  A=A-1
  M=D+M
  @SP
  M=M-1
  """;
}

String eq(){

  runingNumber++;

  return """
  @SP
  A=M-1
  D=M
  A=A-1
  D=D-M
  @IF_TRUE$runingNumber
  D;JEQ
  D=0
  @SP
  A=M-1
  A=A-1
  M=D
  @IF_FALSE$runingNumber
  0;JMP
  (IF_TRUE$runingNumber) //label
  D=-1
  @SP
  A=M-1
  A=A-1
  M=D
  (IF_FALSE$runingNumber)
  @SP
  M=M-1
  """;
}

String lt(){
  runingNumber++;

  return """
  // lt
  @SP
  M=M-1
  A=M
  D=M
  A=A-1
  D=M-D
  @LT_$runingNumber
  D;JLT
  @SP
  A=M-1
  M=0
  @END_$runingNumber
  0;JMP
  (LT_$runingNumber)
  @SP
  A=M-1
  M=-1
  (END_$runingNumber)
  """;
}

String gt(){
  runingNumber++;

  return """
  // lt
  @SP
  M=M-1
  A=M
  D=M
  A=A-1
  D=M-D
  @LT_$runingNumber
  D;JGT
  @SP
  A=M-1
  M=0
  @END_$runingNumber
  0;JMP
  (LT_$runingNumber)
  @SP
  A=M-1
  M=-1
  (END_$runingNumber)
  """;
}

String sub(){
  return """
  // add
  @SP
  M=M-1
  A=M
  D=M
  A=A-1
  D=M-D
  M=D
  """;
}

String neg(){
  return """
  @SP
  A=M-1
  M=-M
  """;
}

String and(){
  return """
  @SP
  M=M-1
  A=M
  D=M
  A=A-1
  M=D&M
  """;
}

String or(){
  return """
  @SP
  M=M-1
  A=M
  D=M
  A=A-1
  M=D|M
  """;
}

String not(){
  return """
  @SP
  A=M-1
  M=!M
  """;
}

