import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDetailsPage extends StatelessWidget {
  const AppDetailsPage({super.key});

  void _launchURL() async {
    Uri url = Uri.parse('https://github.com/SanuSanal/Password-Warden');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Fluttertoast.showToast(
          msg: "Could not open repository",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Password Warden',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Purpose:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Password Warden is an application designed to securely store your application usernames and passwords.',
            ),
            const SizedBox(height: 20),
            const Text(
              'Description:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'With Password Warden, you can save and manage your credentials for various applications. It also allows you to store additional key-value pairs for each record. The app provides functionalities to search, edit, and delete records.',
            ),
            const SizedBox(height: 20),
            const Text(
              'Credits:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'This app was created by Sanal with the help of ChatGPT.',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _launchURL,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                  'GitHub Repository: https://github.com/SanuSanal/Password-Warden'),
            ),
          ],
        ),
      ),
    );
  }
}
