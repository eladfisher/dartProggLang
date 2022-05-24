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
    write("push $segment $index");
  }

  void writePop(String segment,int index)
  {
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
      case"~":
        write("not");
        break;
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
    write("if-goto $name $nArgs");
  }

  writeFunction(String name, int nLoacls)
  {
    write("function $name $nLoacls");
  }
  writeReturn()
  {
    write("return");
  }


  void write(String s)
  {
    output.writeAsStringSync( s+"\n", mode: FileMode.append);
  }
}