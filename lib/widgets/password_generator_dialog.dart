import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PasswordGeneratorDialog extends StatefulWidget {
  const PasswordGeneratorDialog({super.key});

  @override
  PasswordGeneratorDialogState createState() => PasswordGeneratorDialogState();
}

class PasswordGeneratorDialogState extends State<PasswordGeneratorDialog> {
  double _passwordLength = 12;
  bool _includeUpperCase = true;
  bool _includeLowerCase = true;
  bool _includeNumbers = true;
  bool _includeSpecialCharacters = true;
  String _generatedPassword = "";

  final _specialChars = '!@#\$%^&*()_+-=[]{},.?|';
  final _upperCaseLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  final _lowerCaseLetters = 'abcdefghijklmnopqrstuvwxyz';
  final _numbers = '0123456789';

  String _generatePassword() {
    String chars = "";
    List<String> mandatoryChars = [];

    if (_includeUpperCase) {
      chars += _upperCaseLetters;
      mandatoryChars
          .add(_upperCaseLetters[Random().nextInt(_upperCaseLetters.length)]);
    }
    if (_includeLowerCase) {
      chars += _lowerCaseLetters;
      mandatoryChars
          .add(_lowerCaseLetters[Random().nextInt(_lowerCaseLetters.length)]);
    }
    if (_includeNumbers) {
      chars += _numbers;
      mandatoryChars.add(_numbers[Random().nextInt(_numbers.length)]);
    }
    if (_includeSpecialCharacters) {
      chars += _specialChars;
      mandatoryChars.add(_specialChars[Random().nextInt(_specialChars.length)]);
    }

    if (chars.isEmpty) return "";

    int remainingLength = _passwordLength.toInt() - mandatoryChars.length;
    List<String> passwordChars = List.generate(
      remainingLength,
      (index) => chars[Random().nextInt(chars.length)],
    );

    passwordChars.addAll(mandatoryChars);

    passwordChars.shuffle();

    return passwordChars.join();
  }

  void _onPasswordOptionsChanged() {
    setState(() {
      _generatedPassword = _generatePassword();
    });
  }

  @override
  void initState() {
    super.initState();
    _onPasswordOptionsChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child:
                      const Icon(Icons.close, size: 20, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Generate Password',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Length: ${_passwordLength.toInt()}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Slider(
                    value: _passwordLength,
                    min: 6,
                    max: 32,
                    divisions: 26,
                    label: _passwordLength.toInt().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _passwordLength = value;
                        _onPasswordOptionsChanged();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildSwitchTile(
                  'Atleast one Upper Case Letter', _includeUpperCase, (value) {
                setState(() {
                  _includeUpperCase = value;
                  _onPasswordOptionsChanged();
                });
              }),
              _buildSwitchTile(
                  'Atleast one Lower Case Letter', _includeLowerCase, (value) {
                setState(() {
                  _includeLowerCase = value;
                  _onPasswordOptionsChanged();
                });
              }),
              _buildSwitchTile('Atleast one Number', _includeNumbers, (value) {
                setState(() {
                  _includeNumbers = value;
                  _onPasswordOptionsChanged();
                });
              }),
              _buildSwitchTile(
                  'Atleast one Special Character', _includeSpecialCharacters,
                  (value) {
                setState(() {
                  _includeSpecialCharacters = value;
                  _onPasswordOptionsChanged();
                });
              }),
              const SizedBox(height: 10),
              // Generated password display and copy button
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Generated Password',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(fontSize: 14),
                      ),
                      controller:
                          TextEditingController(text: _generatedPassword),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: _generatedPassword));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Password copied to clipboard')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.blue,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
    );
  }
}
