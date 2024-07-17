import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:password_warden/models/password_record.dart';
import 'package:password_warden/screens/home_page.dart';
import 'package:password_warden/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PasswordRecordAdapter());

  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
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
  final AuthService authService = AuthService();
  bool isAuthenticated = await authService.authenticate();

  runApp(MyApp(isAuthenticated: isAuthenticated));
}

class MyApp extends StatelessWidget {
  final bool isAuthenticated;

  const MyApp({Key? key, required this.isAuthenticated}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Warden',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: isAuthenticated ? HomePage() : AuthenticationFailedPage(),
    );
  }
}

class AuthenticationFailedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Authentication Failed')),
      body: Center(
          child: Text(
              'Authentication failed. Please restart the app to try again.')),
    );
  }
}
