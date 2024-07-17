import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:password_warden/models/password_record.dart';

class AddRecordPage extends StatefulWidget {
  @override
  _AddRecordPageState createState() => _AddRecordPageState();
}

class _AddRecordPageState extends State<AddRecordPage> {
  final _formKey = GlobalKey<FormState>();
  late String _applicationName;
  late String _username;
  late String _password;
  Map<String, String> _additionalInfo = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Record'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Application Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an application name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _applicationName = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
                onSaved: (value) {
                  _username = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value!;
                },
              ),
              // Add additional key-value pairs here
              ..._additionalInfo.entries.map((entry) {
                return ListTile(
                  title: Text(entry.key),
                  subtitle: Text(entry.value),
                );
              }).toList(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addRecord,
                child: Text('Add Record'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addRecord() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newRecord = PasswordRecord(
        applicationName: _applicationName,
        username: _username,
        password: _password,
        additionalInfo: _additionalInfo,
      );
      Hive.box<PasswordRecord>('passwordRecords').add(newRecord);
      Navigator.of(context).pop();
    }
  }
}
