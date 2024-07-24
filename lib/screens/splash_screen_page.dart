import 'package:flutter/material.dart';
import 'package:password_warden/screens/authentication_failed_page.dart';
import 'package:password_warden/screens/home_page.dart';
import 'package:password_warden/services/auth_service.dart';

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
              'assets/logo.png',
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
