

class SymbolTable{

  var classVars = new Map();
  var subRoutineVars = new Map();
  var field =0, static = 0, arg = 0, varIndex = 0;

  SymbolTable(){

  }

  void startSubroutine(){
    subRoutineVars = new Map();
  }

  void define(String name, String type, String kind){
    switch(type){
      case "STATIC":
        classVars[name] = [name,type,kind,static++];
        break;

      case "FIELD":
        classVars[name] = [name,type,kind,field++];
        break;

      case "ARG":
        classVars[name] = [name,type,kind,arg++];
        break;

      case "VAR":
        classVars[name] = [name,type,kind,varIndex++];
        break;
    }
  }

  int varCount(String kind){

    switch (kind){
      case "STATIC":
        return static;

      case "FIELD":
        return field;

      case "ARG":
        return arg;

      case "VAR":
        return varIndex;
    }
    return -1;
  }

  String kindOf(String kind){

    if(subRoutineVars.containsKey(kind)){
      subRoutineVars[kind][2];
    }

    return classVars[kind][2];
  }

  int indexOf(String name){
    if(subRoutineVars.containsKey(name)){
      subRoutineVars[name][3];
    }

    return classVars[name][3];
  }




}