import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:password_warden/models/password_record.dart';
import 'package:password_warden/screens/home_page.dart';
import 'package:password_warden/services/auth_service.dart';

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

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3), () {});
    final AuthService authService = AuthService();
    bool isAuthenticated = await authService.authenticate();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => isAuthenticated
              ? const HomePage()
              : const AuthenticationFailedPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/logo.png', // Ensure you have the logo image in the assets directory
              height: 100.0,
            ),
            const SizedBox(height: 20.0),
            const Text(
              'PassWarden',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthenticationFailedPage extends StatelessWidget {
  const AuthenticationFailedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authentication Failed')),
      body: const Center(
          child: Text(
              'Authentication failed. Please restart the app to try again.')),
    );
  }
}
