import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/password_record.dart';
import 'screens/home_page.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(PasswordRecordAdapter());
  await Hive.openBox<PasswordRecord>('passwordRecords');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Warden',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
