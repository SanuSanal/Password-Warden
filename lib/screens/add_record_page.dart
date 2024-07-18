import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:password_warden/models/password_record.dart';

class AddRecordPage extends StatefulWidget {
  const AddRecordPage({super.key});

  @override
  AddRecordPageState createState() => AddRecordPageState();
}

class AddRecordPageState extends State<AddRecordPage> {
  final _formKey = GlobalKey<FormState>();
  String applicationName = '';
  String username = '';
  String password = '';
  Map<String, String> additionalInfo = {};

  void _saveRecord() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newRecord = PasswordRecord(
        applicationName: applicationName,
        username: username,
        password: password,
        additionalInfo: additionalInfo,
      );
      Hive.box<PasswordRecord>('passwordRecords').add(newRecord);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record added')),
      );
    }
  }

  void _addKeyValuePair() {
    setState(() {
      additionalInfo[''] = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Record'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Application Name'),
                onSaved: (value) => applicationName = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an application name';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Username'),
                onSaved: (value) => username = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onSaved: (value) => password = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              ...additionalInfo.entries.map((entry) {
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: entry.key,
                        decoration: const InputDecoration(labelText: 'Key'),
                        onChanged: (value) {
                          setState(() {
                            additionalInfo.remove(entry.key);
                            additionalInfo[value] = entry.value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: entry.value,
                        decoration: const InputDecoration(labelText: 'Value'),
                        onChanged: (value) {
                          setState(() {
                            additionalInfo[entry.key] = value;
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          additionalInfo.remove(entry.key);
                        });
                      },
                    ),
                  ],
                );
              }),
              ElevatedButton(
                onPressed: _addKeyValuePair,
                child: const Text('Add Key-Value Pair'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveRecord,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
