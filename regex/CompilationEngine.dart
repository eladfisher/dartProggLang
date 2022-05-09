import 'dart:io';

import 'Tokenizer.dart';

class CompilationEngine {
  late File OUTfile;
  late File INfile;
  late Tokenizer tokenizer;

  CompilationEngine(File input, File output) {
    OUTfile = output;
    INfile = input;
    tokenizer = new Tokenizer(INfile);
  }

  void write(String s)
  {
    OUTfile.writeAsStringSync(s,mode: FileMode.append);
  }


  void CompileKeyWord() {
    write("<keyword>" + tokenizer.keyword()+"</keyword>\n");
  }

  void CompileSymbol() {
    var a= tokenizer.symbol();
    correct(a);
    write("<symbol>" +a+"</symbol>\n");
  }

  void CompileSTRING_CONST() {
    write("<stringConstant>"+ tokenizer.stringVal() +"</stringConstant>\n");
  }

  void CompileIDENTIFIER() {
    write("<identifier>"+ tokenizer.identifier() +"</identifier>\n");
  }

  void CompileINT_CONST() {
    write("<intConstant>"+ tokenizer.intVal().toString() +"</intConstant>\n");
  }


  void CompileClass() {
    OUTfile.writeAsStringSync("<tokens>\n",mode: FileMode.append);
    while (tokenizer.hasMoreTokens()) {
      String type = tokenizer.tokenType();
      switch (type) {
        case "KEYWORD":
          CompileKeyWord();
          break;
        case "SYMBOL":
          CompileSymbol();
          break;
        case "IDENTIFIER":
          CompileIDENTIFIER();
          break;
        case "INT_CONST":
          CompileINT_CONST();
          break;
        case "STRING_CONST":
          CompileSTRING_CONST();
          break;
      }
      tokenizer.advance();
    }
    OUTfile.writeAsStringSync("</tokens>",mode: FileMode.append);
  }

  void CompileClassVarDec() {}

  void CompileSubroutineDec() {}

  void CompileParameterList() {}

  void CompileSubroutineBody() {}

  void CompileVarDec() {}

  void CompileStatements() {}

  void CompileLet() {}

  void CompileIf() {}

  void CompileWhile() {}

  void CompileDo() {}

  void CompileReturn() {}

  void CompileExpression() {}

  void CompileTerm() {}

  void CompileExpressionList() {}



  String correct(String a)
  {
    if (a=="<")
    {
      a="&lt;";
    }
    else if (a==">")
    {
      a="&gt;";
    }
    else if (a=="\"")
    {
      a="&quet;";
    }
    else if (a=="\$")
    {
      a="&amp;";
    }
    return a;
  }

}
