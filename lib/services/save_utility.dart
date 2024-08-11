import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<String> getDownloadsDirectoryPath() async {
  // Check for permissions
  if (!(await Permission.storage.request().isGranted)) {
    throw Exception('Storage permission is not granted');
  }

  // Handle Android version-specific logic
  if (Platform.isAndroid) {
    if (await _isAndroid10OrHigher()) {
      // For Android 10 and above
      final directory = Directory('/storage/emulated/0/Download');
      return directory.path;
    } else {
      // For Android versions below 10
      final externalDirectory = await getExternalStorageDirectory();
      final directory = Directory('${externalDirectory!.path}/Download');
      return directory.path;
    }
  } else if (Platform.isIOS) {
    // iOS specific logic if needed
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  throw UnsupportedError("Unsupported platform");
}

Future<bool> _isAndroid10OrHigher() async {
  if (Platform.isAndroid) {
    var version = await getAndroidVersion();
    return version >= 29; // API 29 corresponds to Android 10
  }
  return false;
}

Future<int> getAndroidVersion() async {
  return int.parse(await getSdkInt());
}

Future<String> getSdkInt() async {
  // Implement platform method call to retrieve SDK int on Android
  // or return manually (e.g., 30 for Android 11)
  // This can be achieved using platform channels
  // For simplicity, let's assume the version is 30 (Android 11)
  return '30'; // replace this with actual platform channel code
}

Future<bool> saveJsonToFile(String jsonString) async {
  try {
    final downloadsPath = await getDownloadsDirectoryPath();
    final path = '$downloadsPath/passwardenrecords.json';
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    await file.writeAsString(jsonString, mode: FileMode.write);
    return true;
  } catch (e) {
    return false;
  }
}
