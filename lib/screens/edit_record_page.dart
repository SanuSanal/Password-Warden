import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:password_warden/models/password_record.dart';

class EditRecordPage extends StatefulWidget {
  final PasswordRecord record;

  EditRecordPage({required this.record});

  @override
  _EditRecordPageState createState() => _EditRecordPageState();
}

class _EditRecordPageState extends State<EditRecordPage> {
  final _formKey = GlobalKey<FormState>();
  late String applicationName;
  late String username;
  late String password;
  Map<String, String> additionalInfo = {};

  @override
  void initState() {
    super.initState();
    applicationName = widget.record.applicationName;
    username = widget.record.username;
    password = widget.record.password;
    additionalInfo = Map<String, String>.from(widget.record.additionalInfo);
  }

  void _saveRecord() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final updatedRecord = PasswordRecord(
        applicationName: applicationName,
        username: username,
        password: password,
        additionalInfo: additionalInfo,
      );
      Hive.box<PasswordRecord>('passwordRecords')
          .put(widget.record.key, updatedRecord);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Record updated')),
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
        title: Text('Edit Record'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: applicationName,
                decoration: InputDecoration(labelText: 'Application Name'),
                onSaved: (value) => applicationName = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an application name';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: username,
                decoration: InputDecoration(labelText: 'Username'),
                onSaved: (value) => username = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: password,
                decoration: InputDecoration(labelText: 'Password'),
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
                        decoration: InputDecoration(labelText: 'Key'),
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
                        decoration: InputDecoration(labelText: 'Value'),
                        onChanged: (value) {
                          setState(() {
                            additionalInfo[entry.key] = value;
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          additionalInfo.remove(entry.key);
                        });
                      },
                    ),
                  ],
                );
              }).toList(),
              ElevatedButton(
                onPressed: _addKeyValuePair,
                child: Text('Add Key-Value Pair'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveRecord,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
