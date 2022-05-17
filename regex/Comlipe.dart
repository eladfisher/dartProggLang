//import 'dart:html';
import 'dart:io';

import 'Tokenizer.dart';

class Compile {
  late File OUTfile;
  late File INfile;
  late Tokenizer tokenizer;
  int numTabs=0;
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
    write(getTAB(0)+"<keyword>" + tokenizer.keyword()+"</keyword>\n");
    tokenizer.advance();
  }

  void CompileSymbol() {
    var a= tokenizer.symbol();
    a=correct(a);
    write(getTAB(0)+"<symbol>" +a+"</symbol>\n");
    tokenizer.advance();
  }

  void CompileSTRING_CONST() {
    write(getTAB(0)+"<stringConstant>"+ tokenizer.stringVal() +"</stringConstant>\n");
    tokenizer.advance();

  }

  void CompileIDENTIFIER() {
    write(getTAB(0)+"<identifier>"+ tokenizer.identifier() +"</identifier>\n");
    tokenizer.advance();
  }

  void CompileINT_CONST() {
    write(getTAB(0)+"<intConstant>"+ tokenizer.intVal().toString() +"</intConstant>\n");
    tokenizer.advance();
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

  void CompileStatements() {
    write(getTAB(0) + "<statements>\n");
    numTabs++;
    while (tokenizer.type == "KEYWORD") {
      if (tokenizer.content == "let") {
        CompileLet();
      }
      else if (tokenizer.content == "do") {
        CompileDo();
      }
      else if (tokenizer.content == "if") {
        CompileIf();
      }
      else if (tokenizer.content == "while") {
        CompileWhile();
      }
      else if (tokenizer.content == "return") {
        CompileReturn();
      }

      else {
        numTabs--;
        write(getTAB(0) + "</statements>\n");
        return;
      }
      numTabs--;
      write(getTAB(0) + "</statements>\n");
    }
  }



  String getTAB(int i)
  {
    return(" "*(numTabs+i));
  }

  void CompileLet() {
    write(getTAB(0)+"<letStatement>\n");
    numTabs++;
    //let varName([expression])?=expression;
    CompileKeyWord();//let
    CompileSymbol();//(
    CompileExpression();
    CompileSymbol();//)

    if(tokenizer.content=="[")
      {
        CompileSymbol();//[
        CompileExpression();
        CompileSymbol();//]
      }
    CompileSymbol();//=
    CompileExpression();
    CompileSymbol();//;
    numTabs--;
    write(getTAB(0)+"</letStatement>\n");
  }

  void CompileIf() {
    write(getTAB(0)+"<ifStatement>\n");
    numTabs++;
    //if (exp){stat}(else{stat})?
    CompileKeyWord();//if
    CompileSymbol();//(
    CompileExpression();
    CompileSymbol();//)
    CompileSymbol();//{
    CompileStatements();
    CompileSymbol();//}
    if(tokenizer.content=="else")
      {
        CompileKeyWord();//else
        CompileSymbol();//{
        CompileStatements();
        CompileSymbol();//}
      }
    numTabs--;
    write(getTAB(0)+"</ifStatement>\n");
  }

  void CompileWhile() {
    write(getTAB(0)+"<whileStatement>\n");
    numTabs++;
    //while (exp){stat}
    CompileKeyWord();//while
    CompileSymbol();//(
    CompileExpression();
    CompileSymbol();//)
    CompileSymbol();//{
    CompileStatements();
    CompileSymbol();//}
    numTabs--;
    write(getTAB(0)+"</whileStatement>\n");
  }

  void CompileDo() {
    write(getTAB(0)+"<doStatement>\n");
    numTabs++;
    CompileKeyWord(); //do
    write("<subroutineCall>\n");
    numTabs++;
    //TODO subroutineCall
    numTabs--;
    write("</subroutineCall>\n");
    CompileSymbol();//;
    numTabs--;
    write(getTAB(0)+"</doStatement>\n");
  }

  void CompileReturn() {
    write(getTAB(0)+"<returnStatement>\n");
    numTabs++;
    CompileKeyWord(); //return
    if (tokenizer.content!=";")
      {
        CompileExpression();
      }
    CompileSymbol();//;
    numTabs--;
    write(getTAB(0)+"</returnStatement>\n");
  }

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
