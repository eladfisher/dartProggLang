import 'package:dart_application_1/dart_application_1.dart'
    as dart_application_1;
import 'dart:io';

//C:\dartFiles
//C:\nand2tetris\projects\07\StackArithmetic\SimpleAdd
int runingNumber = 1;
String fileName = "";

main() async {
  String path = stdin.readLineSync()!;
  String outputFilePath =
      path + path.substring(path.lastIndexOf("\\")) + ".asm";

  File outputFile = File(outputFilePath);

  var temp = outputFile.path.lastIndexOf("\\");
  fileName = outputFile.path.substring(temp + 1, outputFile.path.length - 4);
  outputFile.writeAsStringSync("");

  // Get the system temp directory .
  var systemTempDir = Directory.systemTemp;

  final dir = Directory(path);
  final List<FileSystemEntity> entities = await dir.list().toList();

  //outputFile.writeAsStringSync(push("constant", "16"));
  for (var file in entities) {
    if (file.path.endsWith("Sys.vm")) {
      fileName = "Sys";
      String start = "";
      start += """//bootstrap
      @256
      D=A
      @SP
      M=D
      """+ func("Sys.init","0")+"""
      //start code here
      """;

      outputFile.writeAsStringSync(start, mode: FileMode.append);
    }
  }

  for (var file in entities) {
    if (!file.path.endsWith("vm")) {
      continue;
    }

    File inputFile = File(file.path);
    var lines = inputFile.readAsLinesSync();

    var temp = file.path.lastIndexOf("\\");
    fileName = file.path.substring(temp + 1, file.path.length - 3);

    for (var line in lines) {
      List<String> list = line.split(" ");
      String res = "";
      runingNumber++;

    if(list[0]=="return"){
      res = returnCommand();
    }


    if( list[0] == "function" ){
      res = function(list[1],list[2]);
    }

      if(list[0]=="if-goto") {
          res = ifGoto(list[1]);
      }

      if(list[0]=="call"){
        res = func(list[1],list[2]);
      }

      if(list[0]=="goto"){
        res = gotoCommand(list[1]);
      }

      if (list[0] == "label") {
        res = label(list[1]);
      }

      if (list[0] == "pop") {
        res = pop(list[1], list[2]);

        if (res == "") print("ERROR");
      }

      if (list[0] == "push") {
        res = push(list[1], list[2]);

        if (res == "") print("ERROR");
      }

      if (list[0] == "add") {
        res = add();
      }

      if (list[0] == "eq") {
        res = eq();
      }

      if (list[0] == "not") {
        res = not();
      }

      if (list[0] == "lt") {
        res = lt();
      }

      if (list[0] == "gt") {
        res = gt();
      }

      if (list[0] == "and") {
        res = and();
      }

      if (list[0] == "or") {
        res = or();
      }

      if (list[0] == "sub") {
        res = sub();
      }

      if (list[0] == "neg") {
        res = neg();
      }

      outputFile.writeAsStringSync(res, mode: FileMode.append);
    }
  }
}

String returnCommand() {
  String res = "//return\n";
  res+= returnFrame();
  res+= returnAdressSave();
  res+= returnValSave();
  res+= returnSpUpdate();
  res+= returnSegment("THAT");
  res+= returnSegment("THIS");
  res+= returnSegment("ARG");
  res+= returnSegment("LCL");
  res+= returnGoto();

  // String res = """
  // //func return
  // // FRAME = LCL
  // @LCL
  // D=M
  // // RET = * (FRAME-5)
  // // RAM[13] = (LOCAL - 5)
  // @5
  // A=D-A
  // D=M
  // @13
  // M=D
  // // * ARG = pop()
  // @SP
  // M=M-1
  // A=M
  // D=M
  // @ARG
  // A=M
  // M=D
  // // SP = ARG+1
  // @ARG
  // D=M
  // @SP
  // M=D+1
  // // THAT = *(FRAM-1)
  // @LCL
  // M=M-1
  // A=M
  // D=M
  // @THAT
  // M=D
  // // THIS = *(FRAM-2)
  // @LCL
  // M=M-1
  // A=M
  // D=M
  // @THIS
  // M=D
  // // ARG = *(FRAM-3)
  // @LCL
  // M=M-1
  // A=M
  // D=M
  // @ARG
  // M=D
  // // LCL = *(FRAM-4)
  // @LCL
  // M=M-1
  // A=M
  // D=M
  // @LCL
  // M=D
  // // goto RET
  // @13
  // A=M
  // 0; JMP
  // """;
  return res;
}

String returnGoto() {
  return """
   //goto RET
  @13
  A=M
  0; JMP
  """;
}

String returnSegment(String s) {
  return """
  // $s = *(FRAM-1)
  @LCL
  M=M-1
  A=M
  D=M
  @$s
  M=D
  """;
}

String returnSpUpdate() {
  return """
  // SP = ARG+1 
  @ARG
  D=M
  @SP
  M=D+1
  """;
}

String returnValSave() {
  return """
  // * ARG = pop()	
  @SP
  M=M-1
  A=M
  D=M
  @ARG
  A=M
  M=D
  """;
}

String returnAdressSave() {
  return """
  // RET = * (FRAME-5)
  // RAM[13] = (LOCAL - 5)
  @5
  A=D-A
  D=M
  @13
  M=D
  """;
}

String returnFrame() {
  return """
  // FRAME = LCL
  @LCL
  D=M
  """;
}

String function(String funcName, String numArgs) {

  String res = """
    ($funcName)//put the function $funcName
    """;
  for( int i=0; i<int.parse(numArgs);++i){
    res += """
    @SP //push 0 number $i
    A=M
    M=0
    """+SPInc()+"\n";
  }

  return res;
}

String func(String funcName, String numArgs) {
  String res = "//func call in vm\n";
  res += funcPush("$funcName.ReturnAddress_$runingNumber");
  res += funcPush("LCL");
  res += funcPush("ARG");
  res += funcPush("THIS");
  res += funcPush("THAT");
  res += updateARG(int.parse(numArgs));
  res += updateLCL();
  res += funcCall(funcName);

  // int newArgNumber = 5 + int.parse(numArgs);
  //
  // String res = """
  // //call $funcName
  // // push return-address
  // @$funcName.ReturnAddress$runingNumber
  // D=A
  // @SP
  // A=M
  // M=D
  // @SP
  // M=M+1
  // // push LCL
  // @LCL
  // D=M
  // @SP
  // A=M
  // M=D
  // @SP
  // M=M+1
  // // push ARG
  // @ARG
  // D=M
  // @SP
  // A=M
  // M=D
  // @SP
  // M=M+1
  // // push THIS
  // @THIS
  // D=M
  // @SP
  // A=M
  // M=D
  // @SP
  // M=M+1
  // // push THAT
  // @THAT
  // D=M
  // @SP
  // A=M
  // M=D
  // @SP
  // M=M+1
  // // ARG = SP-n-5
  // @SP
  // D=M
  // @$newArgNumber // = n-5
  // D=D-A
  // @ARG
  // M=D
  // // LCL = SP
  // @SP
  // D=M
  // @LCL
  // M=D
  // // goto $funcName
  // @$funcName
  // 0; JMP
  // // label return-address
  // ($funcName.ReturnAddress$runingNumber)
  //
  // """;
  return res;
}

String funcCall(String funcName) {
  return """
  // start function $fileName.$funcName
  @$funcName
  0; JMP
  // label return-address func $fileName.$funcName
  ($funcName.ReturnAddress_$runingNumber)
  """;
}

String updateLCL() {
  return """
  @SP//update - LCL = SP
  D=M
  @LCL
  M=D
  """;
}

String updateARG(int numArgs) {
  int temp = 5 + numArgs;//the new ARG from SP
  return """
  @SP//update ARG
  D=M
  @$temp//5 + n
  D=D-A
  @ARG
  M=D
  """;
}

String funcPush(String pushArgument) {
  return """
  @$pushArgument//push $pushArgument before func
  D=A
  @SP
  A=M
  M=D
  """+
  SPInc();



}

String SPInc() {
  return """
  @SP//sp increase
  M=M+1
  """;
}

String SPDecs(){
  return """
    @SP//desc SP
    M=M-1
  """;
}

String ifGoto(String dest) {
  return SPDecs()+
    """
    A=M			
    D=M
    @$fileName.$dest	
    D;JNE
  """;
}

String gotoCommand(String labelGoto) {
  return """
    @$fileName.$labelGoto//goto $labelGoto
    0;JMP
  """;
}

String label(String name) {
  return """
    ($fileName.$name)//label $name
  """;
}

String pop(String type, String val) {
  String res = "";

  if (type == "static") {
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

  if (type == "pointer") {
    if (val == "0") {
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

    if (val == "1") {
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

  if (type == "temp") {
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

  if (type == "this") {
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

  if (type == "that") {
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

  if (type == "local") {
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

  if (type == "argument") {
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

String push(String type, String val) {
  String res = "";

  if (type == "static") {
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

  if (type == "pointer") {
    if (val == "0") {
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

    if (val == "1") {
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

  if (type == "constant") {
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

  if (type == "local") {
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

  if (type == "argument") {
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

  if (type == "this") {
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

    if (type == "") {
      res = """
    
    """;
    }

    if (type == "") {
      res = """
    
    """;
    }

    return res;
  }

  if (type == "that") {
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

    if (type == "") {
      res = """
    
    """;
    }

    if (type == "") {
      res = """
    
    """;
    }

    return res;
  }

  if (type == "temp") {
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

    if (type == "") {
      res = """
    
    """;
    }

    if (type == "") {
      res = """
    
    """;
    }

    return res;
  }

  return res;
}

String add() {
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

String eq() {
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

String lt() {
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

String gt() {
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

String sub() {
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

String neg() {
  return """
  @SP
  A=M-1
  M=-M
  """;
}

String and() {
  return """
  @SP
  M=M-1
  A=M
  D=M
  A=A-1
  M=D&M
  """;
}

String or() {
  return """
  @SP
  M=M-1
  A=M
  D=M
  A=A-1
  M=D|M
  """;
}

String not() {
  return """
  @SP
  A=M-1
  M=!M
  """;
}
