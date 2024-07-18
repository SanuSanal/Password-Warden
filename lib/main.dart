import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:password_warden/models/password_record.dart';
import 'package:password_warden/screens/splash_screen_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PasswordRecordAdapter());

  const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  const String encryptionKey = 'encryptionKey';
  String? encryptedKey = await secureStorage.read(key: encryptionKey);

  if (encryptedKey == null) {
    final key = Hive.generateSecureKey();
    await secureStorage.write(key: encryptionKey, value: key.join(','));
    encryptedKey = key.join(',');
  }

  final encryptionKeyBytes =
      encryptedKey.split(',').map((e) => int.parse(e)).toList();

  await Hive.openBox<PasswordRecord>(
    'passwordRecords',
    encryptionCipher: HiveAesCipher(encryptionKeyBytes),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Warden',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}
