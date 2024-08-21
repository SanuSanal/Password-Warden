import 'dart:io';

Future<bool> saveJsonToFile(String jsonString) async {
  try {
    final directory = Directory('/storage/emulated/0/Download');
    final downloadsPath = directory.path;
    final path = '$downloadsPath/passwardenrecords.txt';
    final file = File(path);

    await file.writeAsString(jsonString, mode: FileMode.write);
    return true;
  } catch (e) {
    return false;
  }
}
