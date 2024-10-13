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
  Map<int, String> tempAdditionalInfo = {};
  int keyIndex = 0;
  bool _isPasswordVisible = false;

  final _applicationNameFocusNode = FocusNode();
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final Map<int, FocusNode> _additionalKeysFocusNodes = {};
  final Map<int, FocusNode> _additionalValuesFocusNodes = {};

  @override
  void dispose() {
    _applicationNameFocusNode.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    for (var keyFocusNode in _additionalKeysFocusNodes.values) {
      keyFocusNode.dispose();
    }
    for (var valueFocusNode in _additionalValuesFocusNodes.values) {
      valueFocusNode.dispose();
    }
    super.dispose();
  }

  void _saveRecord() {
    if (_formKey.currentState!.validate()) {
      Set<String> keysSet = {};
      for (var entry in tempAdditionalInfo.values) {
        String key = entry.split(':')[0];
        if (keysSet.contains(key)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Duplicate key found: $key')),
          );
          return;
        }
        keysSet.add(key);
      }

      Map<String, String> additionalInfo = {};
      for (var entry in tempAdditionalInfo.values) {
        List<String> keyValue = entry.split(':');
        additionalInfo[keyValue[0]] = keyValue[1];
      }
      _formKey.currentState!.save();
      final newRecord = PasswordRecord(
        applicationName: applicationName.trim(),
        username: username.trim(),
        password: password.trim(),
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
      tempAdditionalInfo[keyIndex] = ':';
      var keyFocusNode = FocusNode();
      _additionalKeysFocusNodes[keyIndex] = keyFocusNode;
      var valueFocusNode = FocusNode();
      _additionalValuesFocusNodes[keyIndex] = valueFocusNode;
      keyIndex++;
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
                        focusNode: _applicationNameFocusNode,
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
                        onSaved: (value) {
                          applicationName = value!;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an application name';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_usernameFocusNode);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        focusNode: _usernameFocusNode,
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
                              .requestFocus(_passwordFocusNode);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        focusNode: _passwordFocusNode,
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
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                        obscureText: !_isPasswordVisible,
                        onSaved: (value) => password = value!,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          if (_additionalKeysFocusNodes.isNotEmpty) {
                            FocusScope.of(context).requestFocus(
                                _additionalKeysFocusNodes.values.first);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...tempAdditionalInfo.entries.map((entry) {
                int index = entry.key;
                String key = entry.value.split(':')[0];
                String value = entry.value.split(':')[1];

                var keyFocusNode = _additionalKeysFocusNodes[index];
                var valueFocusNode = _additionalValuesFocusNodes[index];

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
                            initialValue: key,
                            focusNode: keyFocusNode,
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
                            onChanged: (keyValue) {
                              setState(() {
                                tempAdditionalInfo[index] =
                                    '${keyValue.trim()}:$value';
                              });
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a key';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(
                                  _additionalValuesFocusNodes[index]);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            initialValue: value,
                            focusNode: valueFocusNode,
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
                                tempAdditionalInfo[index] =
                                    '$key:${value.trim()}';
                              });
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a value';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) {
                              var keyValPairFound = false;
                              for (var entry
                                  in _additionalKeysFocusNodes.entries) {
                                if (entry.key == index) {
                                  keyValPairFound = true;
                                } else if (keyValPairFound) {
                                  FocusScope.of(context)
                                      .requestFocus(entry.value);
                                  break;
                                }
                              }
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () {
                          setState(() {
                            tempAdditionalInfo.remove(index);
                            _additionalKeysFocusNodes[index]!.dispose();
                            _additionalKeysFocusNodes.remove(index);
                            _additionalValuesFocusNodes[index]!.dispose();
                            _additionalValuesFocusNodes.remove(index);
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
