import 'dart:convert';
import 'dart:io';

class Tokenizer {
  late File file;
  late String content;
  late int index = 0;
  late String token;
  late String type;

  Tokenizer(File input) {
    file = input;
    init();
    advance();
    //return
  }

  bool hasMoreTokens() {
    return index < content.length;
  }

  void advance() {
    token = "";
    String symbols = "{}()[].,;+-*/&|<>=~";
    content = content.substring(index);
    index = 0;
    content = content.trim();

    if(content[index].contains(new RegExp(r"[A-Za-z_]"))){
      readId();
    }

    else if(content[index].contains(new RegExp(r"[0-9]"))){
      number();
    }

    else if(symbols.contains(content[index])){
      type = "SYMBOL";
      token = content[index];
      index++;
    }

    else if(content[index].contains("\"")){
      StringConst();
    }



  }

  String tokenType() {
    if (isKeyWord(token))
      return "KEYWORD";

    return type;
  }

  String keyword() {
    return token;
  }

  String symbol() {
    return token;
  }

  String identifier() {
    return token;
  }

  int intVal() {
    return int.parse(token);
  }

  String stringVal() {
    return token;
  }

  void init() {
    content = file.readAsStringSync();

    while (content.contains("/*")) {
      int first = content.indexOf("/*");
      int last = content.indexOf("*/");

      content = content.substring(0, first) + content.substring(last + 2);
    }

    LineSplitter ls = new LineSplitter();

    var lines = ls.convert(content);
    content = "";

    for (String line in lines) {
      line = line.split("//")[0];
      //print("new line: " + line);
      content += line;
    }


  }

  void readId() {
    type = "IDENTIFIER";
    while(content[index].contains(new RegExp(r"[A-Za-z0-9_]"))){
      token += content[index];
      index++;
    }

  }
  bool isKeyWord (String s)
  {
    String list="class method function constructor int boolean char void var static field let do if else while return true false null this";

    return list.split(" ").indexOf(s)!=-1;
  }

  void number() {
    type = "INT_CONST";
    while(content[index].contains(new RegExp(r"[0-9]"))){
      token += content[index];
      index++;
    }

  }

  void StringConst() {

    type = "STRING_CONST";
    token="";
    index++;

    while(!content[index].contains("\"")){
      token += content[index];
      index++;
    }
    index++;

  }
}


