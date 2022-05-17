import 'dart:io';

import 'Tokenizer.dart';

class CompilationEngine {
  late File OUTfile;
  late File INfile;
  late Tokenizer tokenizer;
  int numTabs = 0;

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
    a=correct(a);
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

    numTabs++;

    String first = tokenizer.keyword();

    CompileKeyWord();
    //tokenizer.advance();

    if(tokenizer.tokenType()=="KEYWORD"){
      CompileKeyWord();
    }

    else {
      CompileIDENTIFIER();
    }
    //tokenizer.advance();

    CompileIDENTIFIER();
    //tokenizer.advance();

    while(tokenizer.symbol()==","){
      CompileSymbol();
      //tokenizer.advance();

      CompileIDENTIFIER();
      //tokenizer.advance();
    }

    CompileSymbol();
    //tokenizer.advance();

    numTabs--;

  }

  void CompileSubroutineDec() {

    numTabs++;

    CompileKeyWord();
    //tokenizer.advance();

    //(void|type)
    if(tokenizer.tokenType()=="KEYWORD"){
      CompileKeyWord();
      //tokenizer.advance();
    }
    else{

      if(tokenizer.tokenType()=="KEYWORD"){
        CompileKeyWord();
      }

      else {
        CompileIDENTIFIER();
      }
    }

    //subroutineName
    CompileIDENTIFIER();

    CompileSymbol();//(

    CompileParameterList();

    CompileSymbol();//)

    CompileSubroutineBody();
    numTabs--;

  }

  void CompileParameterList() {

    numTabs++;

    //check if there are params
    if(!(tokenizer.tokenType()=="SYMBOL"&&tokenizer.symbol()==")")) {

      //type
      if(tokenizer.tokenType()=="KEYWORD"){
        CompileKeyWord();
      }

      else {
        CompileIDENTIFIER();
      }

      CompileIDENTIFIER();

      while(tokenizer.symbol()==","){

        //type
        if(tokenizer.tokenType()=="KEYWORD"){
          CompileKeyWord();
        }

        else {
          CompileIDENTIFIER();
        }

        CompileIDENTIFIER();
      }
    }

    numTabs--;

  }

  void CompileSubroutineBody() {

    numTabs++;

    CompileSymbol();//{

    compileVarDecList();//VarDec*

    CompileStatements();//Statements

    CompileSymbol();//}

    numTabs--;

  }

  void CompileVarDec() {

    numTabs++;

    CompileKeyWord();//"var"

    //type
    if(tokenizer.tokenType()=="KEYWORD"){
      CompileKeyWord();
    }

    else {
      CompileIDENTIFIER();
    }

    //varName
    CompileIDENTIFIER();

    //"," varName)*
    while(tokenizer.symbol()==","){

      CompileIDENTIFIER();
    }

    CompileSymbol();

    numTabs--;
  }

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

  void compileClassVarDecList() {
    while(tokenizer.keyword() == "static" || tokenizer.keyword()=="field"){
      CompileClassVarDec();
    }
  }

  void compileSubroutineDecList(){
    while(tokenizer.keyword() == "int" || tokenizer.keyword()=="char"||tokenizer.keyword()=="boolean"){
      CompileSubroutineDec();
    }
  }

  void compileVarDecList() {

    while(tokenizer.keyword()=="var")
      {
        CompileVarDec();
      }

  }

}
