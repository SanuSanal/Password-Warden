import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDetailsPage extends StatelessWidget {
  void _launchURL() async {
    Uri url = Uri.parse('https://github.com/SanuSanal/Password-Warden');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Password Warden',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Purpose:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Password Warden is an application designed to securely store your application usernames and passwords.',
            ),
            SizedBox(height: 20),
            Text(
              'Description:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'With Password Warden, you can save and manage your credentials for various applications. It also allows you to store additional key-value pairs for each record. The app provides functionalities to search, edit, and delete records.',
            ),
            SizedBox(height: 20),
            Text(
              'Credits:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'This app was created by Sanal with the help of ChatGPT.',
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _launchURL,
              child: Text(
                'GitHub Repository',
                style: TextStyle(
                    color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
