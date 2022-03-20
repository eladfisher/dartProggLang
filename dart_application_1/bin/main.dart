import 'package:dart_application_1/dart_application_1.dart'
as dart_application_1;
import 'dart:io';

//C:\dartFiles


File? outputFileGlobal;

main() async {
  String path = stdin.readLineSync()!;
  String outputFilePath = path + path.substring(path.lastIndexOf("\\")) +
      ".asm";

  outputFileGlobal = File(outputFilePath);

  File outputFile = outputFileGlobal!;
  outputFile.writeAsStringSync("");

  // Get the system temp directory.
  var systemTempDir = Directory.systemTemp;

  final dir = Directory(path);
  final List<FileSystemEntity> entities = await dir.list().toList();

  double totalBuy = 0;
  double totalCell = 0;

  for (var file in entities) {
    if (!file.path.endsWith("vm")) {
      continue;
    }

    File inputFile = File(file.path);
    var lines = inputFile.readAsLinesSync();

    var temp = file.path.lastIndexOf("\\");
    outputFile.writeAsStringSync(
        file.path.substring(temp + 1, file.path.length - 3) + "\n",
        mode: FileMode.append);

    for (var line in lines) {

      List<String> list = line.split(" ");

      if (list[0]=="buy")
        {
          totalBuy+=HandleBuy( list[1],int.parse(list[2]) ,double.parse(list[3]));
        }
      else
        {
          totalCell+=HandleCell( list[1],int.parse(list[2]) ,double.parse(list[3]));
        }

    }
  }
  
  outputFile.writeAsStringSync("TOTAL BUY: $totalBuy\n TOTAL CELL: $totalCell",mode: FileMode.append);

  //var output =  File(outputFile).writeAsString("works");


}


double HandleBuy(String ProductName, int Amount, double Price)
{
  outputFileGlobal?.writeAsStringSync("### BUY $ProductName ###\n",mode: FileMode.append);
  double total = Amount * Price;
  outputFileGlobal?.writeAsStringSync(total.toString() + "\n",mode: FileMode.append);

  return total;
}

double HandleCell (String ProductName, int Amount, double Price)
{
  outputFileGlobal?.writeAsStringSync("\$\$\$ CELL $ProductName \$\$\$\n",mode: FileMode.append);
  double total = Amount * Price;
  outputFileGlobal?.writeAsStringSync(total.toString() + "\n",mode: FileMode.append);

  return total;
}
