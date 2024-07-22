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
        applicationName: applicationName.trim(),
        username: username.trim(),
        password: password.trim(),
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: applicationName,
                        focusNode: _editApplicationNameFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Application Name',
                          labelStyle: const TextStyle(color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.teal),
                          ),
                        ),
                        onSaved: (value) => applicationName = value!,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an application name';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_editUsernameFocusNode);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: username,
                        focusNode: _editUsernameFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          labelStyle: const TextStyle(color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.teal),
                          ),
                        ),
                        onSaved: (value) => username = value!,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_editPasswordFocusNode);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: password,
                        focusNode: _editPasswordFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.teal),
                          ),
                        ),
                        obscureText: true,
                        onSaved: (value) => password = value!,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...additionalInfo.entries.map((entry) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            initialValue: entry.key,
                            decoration: InputDecoration(
                              labelText: 'Key',
                              labelStyle: const TextStyle(color: Colors.teal),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.teal),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                additionalInfo.remove(entry.key);
                                additionalInfo[value.trim()] = entry.value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a key';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            initialValue: entry.value,
                            decoration: InputDecoration(
                              labelText: 'Value',
                              labelStyle: const TextStyle(color: Colors.teal),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.teal),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                additionalInfo[entry.key] = value.trim();
                              });
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a value';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () {
                          setState(() {
                            additionalInfo.remove(entry.key);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }),
              ElevatedButton(
                onPressed: _addKeyValuePair,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Add Key-Value Pair'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveRecord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
