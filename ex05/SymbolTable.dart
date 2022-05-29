

class SymbolTable{

  var classVars = new Map();
  var subRoutineVars = new Map();
  var field =0, static = 0, arg = 0, varIndex = 0;

  SymbolTable(){

  }

  void startSubroutine(){
    subRoutineVars = new Map();
    arg=0;
    varIndex=0;
  }

  void define(String name, String type, String kind){
    switch(kind){
      case "static":
        classVars[name] = [name,type,kind,static++];
        break;

      case "field":
        classVars[name] = [name,type,kind,field++];
        break;

      case "ARG":
        subRoutineVars[name] = [name,type,kind,arg++];
        break;

      case "var":
        subRoutineVars[name] = [name,type,kind,varIndex++];
        break;


      default:
        print("ERROR NAME DOESNT FIT kind: $kind type: $type name:$name");
        break;



    }

  }

  bool exist(String name){
    if(subRoutineVars.containsKey(name)||classVars.containsKey(name))
      return true;
    else
      return false;
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
      return subRoutineVars[kind][2];
    }

    return classVars[kind][2];
  }

  int indexOf(String name){
    if(subRoutineVars.containsKey(name)){
      return subRoutineVars[name][3];
    }

    return classVars[name][3];
  }

  String typeOf(String name){
    if(subRoutineVars.containsKey(name)){
      return subRoutineVars[name][1];
    }

    return classVars[name][1];
  }




}