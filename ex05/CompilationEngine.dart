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
  String className="";
  String subroutineName="";
  String subroutineType="";

  CompilationEngine(File input, File output,File xmloutput) {
    OUTfile = xmloutput;
    INfile = input;
    xmloutput.writeAsStringSync("");
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

  //done
  void CompileStatements({constructor = false}) {
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
        CompileReturn(constructor : constructor);
      }
    }

    numTabs--;
    write("</statements>\n");

  }

  String getTAB(int i) {
    return ("  " * (numTabs + i));
  }

  //done!!
  void CompileLet() {
    write("<letStatement>\n");
    numTabs++;
    //let varName([expression])?=expression;
    CompileKeyWord(); //let
    String nameLeft=tokenizer.identifier();
    CompileIDENTIFIER();

    if (tokenizer.symbol() == "[") {
      CompileSymbol(); //[
      CompileExpression();
      CompileSymbol(); //]
    }
    CompileSymbol(); //=
    CompileExpression();
    CompileSymbol(); //;

    vmWriter.writePop(symbolTable.kindOf(nameLeft), symbolTable.indexOf(nameLeft));

    numTabs--;
    write("</letStatement>\n");
  }

  //done!!!
  void CompileIf() {
    write("<ifStatement>\n");
    numTabs++;
    //if (exp){stat}(else{stat})?
    CompileKeyWord(); //if
    CompileSymbol(); //(
    CompileExpression();
    CompileSymbol(); //)

    int l1=runNumber;
    runNumber++;

    // int l2=runNumber;
    // runNumber++;
    //
    // int l3 = runNumber;
    // runNumber++;

    //vmWriter.writeTerm("~");
    vmWriter.writeIf("IF_TRUE$l1");
    vmWriter.writeGoto("IF_FALSE$l1");
    vmWriter.writeLable("IF_TRUE$l1");

    CompileSymbol(); //{
    CompileStatements();
    CompileSymbol(); //}

    vmWriter.writeGoto("IF_END$l1");
    vmWriter.writeLable("IF_FALSE$l1");
    if (tokenizer.keyword() == "else") {
      CompileKeyWord(); //else
      CompileSymbol(); //{
      CompileStatements();
      CompileSymbol(); //}
    }
    vmWriter.writeLable("IF_END$l1");

    numTabs--;
    write("</ifStatement>\n");

  }

  //done
  void CompileWhile() {
    write("<whileStatement>\n");
    numTabs++;
    //while (exp){stat}
    CompileKeyWord(); //while
    var l1="WHILE_EXP$runNumber";
    //runNumber++;
    var l2="WHILE_END$runNumber";
    runNumber++;

    vmWriter.writeLable(l1);

    CompileSymbol(); //(
    CompileExpression();
    CompileSymbol(); //)
    vmWriter.writeTerm("~");
    vmWriter.writeIf(l2);
    CompileSymbol(); //{
    CompileStatements();
    CompileSymbol(); //}
    vmWriter.writeGoto(l1);
    vmWriter.writeLable(l2);
    numTabs--;
    write("</whileStatement>\n");
  }

  void CompileDo() {

    write("<doStatement>\n");
    numTabs++;
    CompileKeyWord(); //do
    String name1 = tokenizer.identifier();
    CompileIDENTIFIER();//subrutinenumae/class name/varname
    if(tokenizer.symbol()=="."){
      name1+=".";
      CompileSymbol();
      name1 += tokenizer.identifier();
      CompileIDENTIFIER();
    }
    CompileSymbol();//(
    var num = CompileExpressionList();
    CompileSymbol();//)
    CompileSymbol(); //;

    vmWriter.writeCall(name1, num);
    //TODO: fisher is dba!
    vmWriter.writePop("temp", 0);

    //TODO old compilee DO
    // write("<doStatement>\n");
    // numTabs++;
    // CompileKeyWord(); //do
    // CompileIDENTIFIER();//subrutinenumae/class name/varname
    // if(tokenizer.symbol()=="."){
    //   CompileSymbol();
    //   CompileIDENTIFIER();
    // }
    // CompileSymbol();//(
    // CompileExpressionList();
    // CompileSymbol();//)
    // CompileSymbol(); //;
    // numTabs--;
    // write("</doStatement>\n");
  }

  void CompileReturn({constructor = false}) {
    write("<returnStatement>\n");
    numTabs++;

    CompileKeyWord(); //return

    if (tokenizer.symbol() != ";") {
      CompileExpression();
    }

    else {
      if(constructor){
      vmWriter.write("push pointer 0");
    }

      else{//void method, there is ";" after the return
        vmWriter.writePush("constant", 0);
      }
    }
    vmWriter.writeReturn();
    CompileSymbol(); //;
    numTabs--;
    write("</returnStatement>\n");
  }

  void CompileClass() {
    write("<class>\n");
    numTabs++;


    CompileKeyWord();
    //tokenizer.advance();

    className = tokenizer.identifier();
    CompileIDENTIFIER();//className
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

  //done
  void CompileClassVarDec() {
    write("<classVarDec>\n");
    numTabs++;

    String kind = tokenizer.keyword();

    CompileKeyWord();//static|field
    //tokenizer.advance();
    String type;
    if (tokenizer.tokenType() == "KEYWORD") {
       type = tokenizer.keyword();
      CompileKeyWord();//type
    } else {
      type = tokenizer.identifier();
      CompileIDENTIFIER();//type
    }
    //tokenizer.advance();

    symbolTable.define(tokenizer.identifier(),type,kind);
    CompileIDENTIFIER();//name
    //tokenizer.advance();

    while (tokenizer.symbol() == ",") {
      CompileSymbol();//,
      //tokenizer.advance();

      symbolTable.define(tokenizer.identifier(),type,kind);

      CompileIDENTIFIER();//name
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

    symbolTable.startSubroutine();

    String subRoutineType = tokenizer.keyword();
    subroutineType = subRoutineType;
    CompileKeyWord();//(constructor|function|method)
    //tokenizer.advance();

    if(subRoutineType=="method"){
      symbolTable.define("this", className, "ARG");
    }
    
    //(void|type)
    String returnType = tokenizer.identifier();
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
    subroutineName = tokenizer.identifier();
    CompileIDENTIFIER();

    CompileSymbol(); //(

    CompileParameterList();
    
    //vmWriter.writeFunction("$className.$subroutineName", symbolTable.varCount("VAR"));

    CompileSymbol(); //)
    bool constructor = false;
//     if(subRoutineType=="constructor"){
//       int reqSize = symbolTable.varCount("ARG");
//       vmWriter.write("""
// push  $reqSize
// call Memory.alloc 1
// pop pointer 0
//       """);
//       constructor = true;
//     }



    CompileSubroutineBody(constructor:constructor);



    numTabs--;
    write("</subroutineDec>\n");
  }

  void CompileParameterList() {
    write("<parameterList>\n");
    numTabs++;

    String type;

    //check if there are params
    if (!(tokenizer.tokenType() == "SYMBOL" && tokenizer.symbol() == ")")) {
      //type
      type = tokenizer.identifier();
      if (tokenizer.tokenType() == "KEYWORD") {

        CompileKeyWord();
      } else {
        CompileIDENTIFIER();
      }
      String name = tokenizer.identifier();
      CompileIDENTIFIER();

      symbolTable.define(name, type, "ARG");

      while (tokenizer.symbol() == ",") {

        CompileSymbol();//,

        //type
        type = tokenizer.identifier();
        if (tokenizer.tokenType() == "KEYWORD") {
          CompileKeyWord();
        } else {
          CompileIDENTIFIER();
        }
        name = tokenizer.identifier();
        CompileIDENTIFIER();

        symbolTable.define(name, type, "ARG");
      }
    }

    numTabs--;
    write("</parameterList>\n");
  }

  void CompileSubroutineBody({constructor = false}) {
    write("<subroutineBody>\n");
    numTabs++;

    CompileSymbol(); //{

    compileVarDecList(); //VarDec*

    vmWriter.writeFunction("$className.$subroutineName", symbolTable.varCount("VAR"));

    if(subroutineName=="new"){

        int reqSize = symbolTable.varCount("ARG");
        vmWriter.write("""
push constant  $reqSize
call Memory.alloc 1
pop pointer 0""");
        constructor = true;
      }
    else if (subroutineType=="method"){
      vmWriter.writePush("ARG", 0);
      vmWriter.writePop('POINTER', 0);
    }


    //write the function signature after the vars have declares
    CompileStatements(constructor:constructor); //Statements

    CompileSymbol(); //}

    numTabs--;
    write("</subroutineBody>\n");
  }

  void CompileVarDec() {
    write("<varDec>\n");
    numTabs++;

    String kind = tokenizer.keyword();
    CompileKeyWord(); //"var"

    //type
    String type = tokenizer.identifier();
    if (tokenizer.tokenType() == "KEYWORD") {
      CompileKeyWord();
    } else {
      CompileIDENTIFIER();
    }

    //varName
    String name = tokenizer.identifier();
    CompileIDENTIFIER();

    symbolTable.define(name, type, kind);

    //"," varName)*
    while (tokenizer.symbol() == ",") {
      CompileSymbol();
      name = tokenizer.identifier();
      symbolTable.define(name, type, kind);
      CompileIDENTIFIER();
    }

    CompileSymbol();

    numTabs--;
    write("</varDec>\n");
  }

  void CompileExpression() {
    write("<expression>\n");
    numTabs++;



    """
    tk = self.tokenizer
        self.compile_term()

        while tk.curr_token in (
            '+', '-', '*', '/', '&', '|', '<', '>', '='
        ):
            op = tk.curr_token
            tk.advance()

            self.compile_term()
            if op in self.op_table:
                self.generator.write_arithmetic(self.op_table.get(op))
            elif op == '*':
                self.generator.write_call('Math.multiply', 2)
            elif op == '/':
                self.generator.write_call('Math.divide', 2)
            else:
                raise ValueError("{} not supported op.".format(op))
    """;

    String op = "+-*/&|<>=";
    String currnetOp;

    CompileTerm();//term

    //(op term)*

    while(op.contains(tokenizer.symbol())){//
      currnetOp=tokenizer.symbol();
      CompileSymbol();
      CompileTerm();

      vmWriter.writeArithmetic(currnetOp);
    }

    numTabs--;
    write("</expression>\n");


  }

  void CompileTerm() {

    write("<term>\n");
    numTabs++;

    String name1="",name2="";

    switch (tokenizer.tokenType()){
      case "INT_CONST"://integerConstant
        vmWriter.writePush("constant", tokenizer.intVal());
        CompileINT_CONST();
        break;

      case "STRING_CONST"://string constant
        vmWriter.writeTerm(tokenizer.identifier());
        CompileSTRING_CONST();
        break;
      case"KEYWORD"://keyword constant
        vmWriter.writeTerm(tokenizer.keyword());
        CompileKeyWord();
        break;
      case "IDENTIFIER"://varName|varName[Expression]|subroutineCall
        name1 = tokenizer.identifier();
        CompileIDENTIFIER();

        //TODO array compile
        if(tokenizer.symbol()=="["){//varName[Expression]
          CompileSymbol();//[
          CompileExpression();//Expression
          CompileSymbol();//]
        }

        else if(tokenizer.symbol()=="("||tokenizer.symbol()=="."){//subroutine call{
          if(tokenizer.symbol()=="."){
            CompileSymbol();
            name1 += "." + tokenizer.identifier();
            CompileIDENTIFIER();
          }
          CompileSymbol();//(
          int numArg = CompileExpressionList();
          CompileSymbol();//)

          //call the function
          vmWriter.writeCall(name1, numArg);
        }
        else{//varName
          vmWriter.writePush(symbolTable.kindOf(name1), symbolTable.indexOf(name1));
        }



        break;
      case "SYMBOL"://(Expression)|unary term
      //TODO expression compile
        if(tokenizer.symbol()=="("){//(Expression)
          CompileSymbol();//(
          CompileExpression();//expression
          CompileSymbol();//)
        }
        else{//unaryTerm
          String unary = tokenizer.symbol();
          CompileSymbol();//unary op
          CompileTerm();//term
          vmWriter.writeTerm(unary);
        }

        break;

    }

    numTabs--;
    write("</term>\n");

  }

  int CompileExpressionList() {
    int experessions = 0;
    write("<expressionList>\n");
    numTabs++;

    if(tokenizer.symbol()!=")")
    {
      CompileExpression();
      experessions++;
      while(tokenizer.symbol()==","){
        CompileSymbol();
        CompileExpression();
        experessions++;
      }


    }

    numTabs--;
    write("</expressionList>\n");
    return experessions;
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
