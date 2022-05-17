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
    bool there_is=false;
    while(tokenizer.type=="KEYWORD")
      {
        if(tokenizer.content=="let")
          {
            CompileStatements_START(there_is);
            there_is=true;
            CompileLet();
            CompileStatements_FINISH();
          }
        else if(tokenizer.content=="do")
        {
          CompileStatements_START(there_is);
          there_is=true;
          CompileDo();
          CompileStatements_FINISH();
        }
        else if(tokenizer.content=="if")
        {
          CompileStatements_START(there_is);
          there_is=true;
          CompileIf();
          CompileStatements_FINISH();
        }
        else if(tokenizer.content=="while")
        {
          CompileStatements_START(there_is);
          there_is=true;
          CompileWhile();
          CompileStatements_FINISH();
        }
        else if(tokenizer.content=="return")
        {
          CompileStatements_START(there_is);
          there_is=true;
          CompileReturn();
          CompileStatements_FINISH();
        }

        else{
          if (there_is==true)
            {
              numTabs--;
              write(getTAB(0)+"</statements>\n");
            }
            return;}
      }
    if (there_is==true)
    {
      numTabs--;
      write(getTAB(0)+"</statements>\n");
    }
  }

  void CompileStatements_START(bool there_is)
  {
    if(there_is==false){
    write(getTAB(0)+"<statements>\n");
    numTabs++;}
    write(getTAB(0)+"<statement>\n");
    numTabs++;
  }

  void CompileStatements_FINISH()
  {
    numTabs--;
    write(getTAB(0)+"</statement>\n");
  }

  String getTAB(int i)
  {
    return(" "*(numTabs+i));
  }

  void CompileLet() {
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
  }

  void CompileIf() {
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
  }

  void CompileWhile() {
    //while (exp){stat}
    CompileKeyWord();//while
    CompileSymbol();//(
    CompileExpression();
    CompileSymbol();//)
    CompileSymbol();//{
    CompileStatements();
    CompileSymbol();//}
  }

  void CompileDo() {
    CompileKeyWord(); //do
    write("<subroutineCall>\n");
    numTabs++;
    //TODO subroutineCall
    numTabs--;
    write("</subroutineCall>\n");
    CompileSymbol();//;
  }

  void CompileReturn() {
    CompileKeyWord(); //return
    if (tokenizer.content!=";")
      {
        CompileExpression();
      }
    CompileSymbol();//;
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
