import 'package:flutter/material.dart';

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
