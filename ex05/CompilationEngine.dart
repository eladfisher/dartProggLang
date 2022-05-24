import 'dart:io';

import 'SymbolTable.dart';
import 'Tokenizer.dart';
import 'VMWriter.dart';

class CompilationEngine {
  late File OUTfile;
  late File INfile;
  late int runNumber = 0 ;
  late Tokenizer tokenizer;
  int numTabs = 0;
  late SymbolTable symbolTable = new SymbolTable();
  late VMWriter vmWriter;

  CompilationEngine(File input, File output,File xmloutput) {
    OUTfile = xmloutput;
    INfile = input;
    tokenizer = new Tokenizer(INfile);
    vmWriter = new VMWriter(output);
  }

  void write(String s) {
    OUTfile.writeAsStringSync(getTAB(0) + s, mode: FileMode.append);
  }

  void CompileKeyWord() {
    write("<keyword> " + tokenizer.keyword() + " </keyword>\n");
    tokenizer.advance();
  }

  void CompileSymbol() {
    var a = tokenizer.symbol();
    a = correct(a);
    write("<symbol> " + a + " </symbol>\n");

    if(tokenizer.hasMoreTokens())
    {
      tokenizer.advance();
    }

  }

  void CompileSTRING_CONST() {
    write(
        "<stringConstant> " +
            tokenizer.stringVal() +
            " </stringConstant>\n");
    tokenizer.advance();
  }

  void CompileIDENTIFIER() {
    write(
        "<identifier> " +
            tokenizer.identifier() +
            " </identifier>\n");
    tokenizer.advance();
  }

  void CompileINT_CONST() {
    write(
        "<integerConstant> " +
            tokenizer.intVal().toString() +
            " </integerConstant>\n");
    tokenizer.advance();
  }

  void CompileStatements() {
    write("<statements>\n");
    numTabs++;
    while (tokenizer.tokenType() == "KEYWORD") {
      if (tokenizer.keyword() == "let") {
        CompileLet();
      } else if (tokenizer.keyword() == "do") {
        CompileDo();
      } else if (tokenizer.keyword() == "if") {
        CompileIf();
      } else if (tokenizer.keyword() == "while") {
        CompileWhile();
      } else if (tokenizer.keyword() == "return") {
        CompileReturn();
      }
    }

    numTabs--;
    write("</statements>\n");

  }

  String getTAB(int i) {
    return ("  " * (numTabs + i));
  }

  void CompileLet() {
    write("<letStatement>\n");
    numTabs++;
    //let varName([expression])?=expression;
    CompileKeyWord(); //let
    CompileIDENTIFIER();

    if (tokenizer.symbol() == "[") {
      CompileSymbol(); //[
      CompileExpression();
      CompileSymbol(); //]
    }
    CompileSymbol(); //=
    CompileExpression();
    CompileSymbol(); //;
    numTabs--;
    write("</letStatement>\n");
  }

  void CompileIf() {
    write("<ifStatement>\n");
    numTabs++;
    //if (exp){stat}(else{stat})?
    CompileKeyWord(); //if
    CompileSymbol(); //(
    CompileExpression();
    CompileSymbol(); //)
    CompileSymbol(); //{
    CompileStatements();
    CompileSymbol(); //}
    if (tokenizer.keyword() == "else") {
      CompileKeyWord(); //else
      CompileSymbol(); //{
      CompileStatements();
      CompileSymbol(); //}
    }
    numTabs--;
    write("</ifStatement>\n");
  }

  void CompileWhile() {
    write("<whileStatement>\n");
    numTabs++;
    //while (exp){stat}
    CompileKeyWord(); //while
    CompileSymbol(); //(
    CompileExpression();
    CompileSymbol(); //)
    CompileSymbol(); //{
    CompileStatements();
    CompileSymbol(); //}
    numTabs--;
    write("</whileStatement>\n");
  }

  void CompileDo() {
    write("<doStatement>\n");
    numTabs++;
    CompileKeyWord(); //do
    CompileIDENTIFIER();//subrutinenumae/class name/varname
    if(tokenizer.symbol()=="."){
      CompileSymbol();
      CompileIDENTIFIER();
    }
    CompileSymbol();//(
    CompileExpressionList();
    CompileSymbol();//)
    CompileSymbol(); //;
    numTabs--;
    write("</doStatement>\n");
  }

  void CompileReturn() {
    write("<returnStatement>\n");
    numTabs++;
    CompileKeyWord(); //return
    if (tokenizer.symbol() != ";") {
      CompileExpression();
    }
    CompileSymbol(); //;
    numTabs--;
    write("</returnStatement>\n");
  }

  void CompileClass() {



    CompileKeyWord();
    //tokenizer.advance();

    CompileIDENTIFIER();
    //tokenizer.advance();

    CompileSymbol();
    //tokenizer.advance();

    String type = tokenizer.tokenType();

    compileClassVarDecList();
    compileSubroutineDecList();

    CompileSymbol();

    numTabs--;
    write("</class>\n");
    //tokenizer.advance();

    // OUTfile.writeAsStringSync("<tokens>\n",mode: FileMode.append);
    // while (tokenizer.hasMoreTokens()) {
    //   String type = tokenizer.tokenType();
    //   switch (type) {
    //     case "KEYWORD":
    //       CompileKeyWord();
    //       break;
    //     case "SYMBOL":
    //       CompileSymbol();
    //       break;
    //     case "IDENTIFIER":
    //       CompileIDENTIFIER();
    //       break;
    //     case "INT_CONST":
    //       CompileINT_CONST();
    //       break;
    //     case "STRING_CONST":
    //       CompileSTRING_CONST();
    //       break;
    //   }
    //   tokenizer.advance();
    // }
    // OUTfile.writeAsStringSync("</tokens>",mode: FileMode.append);
  }

  void CompileClassVarDec() {
    //write("<classVarDec>\n");
    //numTabs++;

    String kind = tokenizer.keyword();

    CompileKeyWord();//static|field
    //tokenizer.advance();

    if (tokenizer.tokenType() == "KEYWORD") {
      String type = tokenizer.keyword();
      CompileKeyWord();//type
    } else {
      String type = tokenizer.identifier();
      CompileIDENTIFIER();//type
    }
    //tokenizer.advance();

//    symbolTable.define();
    CompileIDENTIFIER();
    //tokenizer.advance();

    while (tokenizer.symbol() == ",") {
      CompileSymbol();
      //tokenizer.advance();

      CompileIDENTIFIER();
      //tokenizer.advance();
    }

    CompileSymbol();
    //tokenizer.advance();

    numTabs--;
    write("</classVarDec>\n");
  }

  void CompileSubroutineDec() {
    write("<subroutineDec>\n");
    numTabs++;

    CompileKeyWord();
    //tokenizer.advance();

    //(void|type)
    if (tokenizer.tokenType() == "KEYWORD") {
      CompileKeyWord();
      //tokenizer.advance();
    } else {
      if (tokenizer.tokenType() == "KEYWORD") {
        CompileKeyWord();
      } else {
        CompileIDENTIFIER();
      }
    }

    //subroutineName
    CompileIDENTIFIER();

    CompileSymbol(); //(

    CompileParameterList();

    CompileSymbol(); //)

    CompileSubroutineBody();
    numTabs--;
    write("</subroutineDec>\n");
  }

  void CompileParameterList() {
    write("<parameterList>\n");
    numTabs++;

    //check if there are params
    if (!(tokenizer.tokenType() == "SYMBOL" && tokenizer.symbol() == ")")) {
      //type
      if (tokenizer.tokenType() == "KEYWORD") {
        CompileKeyWord();
      } else {
        CompileIDENTIFIER();
      }

      CompileIDENTIFIER();

      while (tokenizer.symbol() == ",") {

        CompileSymbol();//,

        //type
        if (tokenizer.tokenType() == "KEYWORD") {
          CompileKeyWord();
        } else {
          CompileIDENTIFIER();
        }

        CompileIDENTIFIER();
      }
    }

    numTabs--;
    write("</parameterList>\n");
  }

  void CompileSubroutineBody() {
    write("<subroutineBody>\n");
    numTabs++;

    CompileSymbol(); //{

    compileVarDecList(); //VarDec*

    CompileStatements(); //Statements

    CompileSymbol(); //}

    numTabs--;
    write("</subroutineBody>\n");
  }

  void CompileVarDec() {
    write("<varDec>\n");
    numTabs++;

    CompileKeyWord(); //"var"

    //type
    if (tokenizer.tokenType() == "KEYWORD") {
      CompileKeyWord();
    } else {
      CompileIDENTIFIER();
    }

    //varName
    CompileIDENTIFIER();

    //"," varName)*
    while (tokenizer.symbol() == ",") {
      CompileSymbol();
      CompileIDENTIFIER();
    }

    CompileSymbol();

    numTabs--;
    write("</varDec>\n");
  }

  void CompileExpression() {
    write("<expression>\n");
    numTabs++;

    String op = "+-*/&|<>=";

    CompileTerm();//term

    //(op term)*
    while(op.contains(tokenizer.symbol())){
      CompileSymbol();
      CompileTerm();
    }

    numTabs--;
    write("</expression>\n");


  }

  void CompileTerm() {

    write("<term>\n");
    numTabs++;

    switch (tokenizer.tokenType()){
      case "INT_CONST"://integerConstant
        CompileINT_CONST();
        break;
      case "STRING_CONST"://string constant
        CompileSTRING_CONST();
        break;
      case"KEYWORD"://keyword constant
        CompileKeyWord();
        break;
      case "IDENTIFIER"://varName|varName[Expression]|subroutineCall
        CompileIDENTIFIER();
        if(tokenizer.symbol()=="["){//varName[Expression]
          CompileSymbol();//[
          CompileExpression();//Expression
          CompileSymbol();//]
        }

        else if(tokenizer.symbol()=="("||tokenizer.symbol()=="."){//subroutine call{
          if(tokenizer.symbol()=="."){
            CompileSymbol();
            CompileIDENTIFIER();
          }
          CompileSymbol();//(
          CompileExpressionList();
          CompileSymbol();//)
        }



        break;
      case "SYMBOL"://(Expression)|unary term
        if(tokenizer.symbol()=="("){//(Expression)
          CompileSymbol();//(
          CompileExpression();//expression
          CompileSymbol();//)
        }
        else{//unaryTerm
          CompileSymbol();//unary op
          CompileTerm();//term
        }

        break;

    }

    numTabs--;
    write("</term>\n");

  }

  void CompileExpressionList() {

    write("<expressionList>\n");
    numTabs++;

    if(tokenizer.symbol()!=")")
    {
      CompileExpression();

      while(tokenizer.symbol()==","){
        CompileSymbol();
        CompileExpression();
      }


    }

    numTabs--;
    write("</expressionList>\n");

  }

  String correct(String a) {
    if (a == "<") {
      a = "&lt;";
    } else if (a == ">") {
      a = "&gt;";
    } else if (a == "\"") {
      a = "&quet;";
    } else if (a == "&") {
      a = "&amp;";
    }
    return a;
  }

  void compileClassVarDecList() {
    while (tokenizer.keyword() == "static" || tokenizer.keyword() == "field") {
      CompileClassVarDec();
    }
  }

  void compileSubroutineDecList() {
    while (tokenizer.keyword() == "constructor" ||
        tokenizer.keyword() == "function" ||
        tokenizer.keyword() == "method") {
      CompileSubroutineDec();
    }
  }

  void compileVarDecList() {
    while (tokenizer.keyword() == "var") {
      CompileVarDec();
    }
  }
}
