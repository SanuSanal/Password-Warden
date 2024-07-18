import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:password_warden/models/password_record.dart';

class EditRecordPage extends StatefulWidget {
  final PasswordRecord record;

  const EditRecordPage({super.key, required this.record});

  @override
  EditRecordPageState createState() => EditRecordPageState();
}

class EditRecordPageState extends State<EditRecordPage> {
  final _formKey = GlobalKey<FormState>();
  late String applicationName;
  late String username;
  late String password;
  Map<String, String> additionalInfo = {};

  final _editApplicationNameFocusNode = FocusNode();
  final _editUsernameFocusNode = FocusNode();
  final _editPasswordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    applicationName = widget.record.applicationName;
    username = widget.record.username;
    password = widget.record.password;
    additionalInfo = Map<String, String>.from(widget.record.additionalInfo);
  }

  @override
  void dispose() {
    _editApplicationNameFocusNode.dispose();
    _editUsernameFocusNode.dispose();
    _editPasswordFocusNode.dispose();
    super.dispose();
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
        const SnackBar(content: Text('Record updated')),
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
        title: const Text('Edit Record'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: applicationName,
                focusNode: _editApplicationNameFocusNode,
                decoration:
                    const InputDecoration(labelText: 'Application Name'),
                onSaved: (value) => applicationName = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an application name';
                  }
                  return null;
                },
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_editUsernameFocusNode);
                },
              ),
              TextFormField(
                initialValue: username,
                focusNode: _editUsernameFocusNode,
                decoration: const InputDecoration(labelText: 'Username'),
                onSaved: (value) => username = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_editPasswordFocusNode);
                },
              ),
              TextFormField(
                initialValue: password,
                focusNode: _editPasswordFocusNode,
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
