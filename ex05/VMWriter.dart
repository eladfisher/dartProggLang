import 'dart:io';

class VMWriter
{
  late File output;
  //constructor
  VMWriter(File output)
  {
    this.output=output;
  }

  void writePush(String segment,int index)
  {
    switch(segment){
      case "var":
        segment = "local";
        break;
      case "ARG":
        segment = "argument";
        break;
      case "constant":
        break;
      case "field":
        segment = "this";
        break;
      case "pointer":
        break;
      default:
        print("ERROR PUSH DOESNT FIT kind: $segment");
    }



    write("push $segment $index");
  }

  void writePop(String segment,int index)
  {
    switch(segment){
      case "var":
        segment = "local";
        break;
      case "ARG":
        segment = "argument";
        break;
      case "constant":
        break;
      case "temp":
        break;
      case "field":
        segment = "this";
        break;
      case "POINTER":
        segment = "pointer";
        break;
      default:
        print("ERROR POP DOESNT FIT kind: $segment");
    }

    write("pop $segment $index");
  }

  void writeArithmetic(String command)
  {
    switch (command){
      case"+":
        write("add");
        break;
      case"-":
        write("sub");
        break;
      case"*":
        write("call Math.multiply 2");
        break;
      case"/":
        write("call Math.divide 2");
        break;
      case"&":
      write("and");
      break;
      case"|":
        write("or");
        break;
      case"<":
        write("lt");
        break;
      case">":
        write("gt");
        break;
      case"=":
        write("eq");
        break;
      default:
        print("no operation found $command");
    }
  }

  void writeLable(String s)
  {
    write("label $s");
  }

  void writeGoto(String s)
  {
    write("goto $s");
  }
  void writeIf(String s)
  {
    write("if-goto $s");
  }
  writeCall(String name, int nArgs)
  {
    write("call $name $nArgs");
  }

  writeFunction(String name, int nLoacls)
  {
    write("function $name $nLoacls");
  }
  writeReturn()
  {
    write("return");
  }
  writeTerm(String s){
    switch(s){
      case"~":
        write("not");
        break;
      case"-":
        write("neg");
        break;
      case "true":
        write("push constant 0");
        write("not");
        break;
      case "false":
      case "null":
        write("push constant 0");
        break;
      case "this":
        writePush("pointer",0);

        break;

      default:

        print(s);

        int len = s.length;
        write("push constant  $len");
        write("call String.new");

        for(int i=0 ; i<len ; ++i)  {
          int temp = s.codeUnitAt(i);
          write("push constant $temp");
          write("call String.appendChar 2");
        }


    }
  }



  void write(String s)
  {
    output.writeAsStringSync( s+"\n", mode: FileMode.append);
  }
}