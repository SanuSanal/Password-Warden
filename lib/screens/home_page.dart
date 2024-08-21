import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:password_warden/models/password_record.dart';
import 'package:password_warden/screens/add_record_page.dart';
import 'package:password_warden/screens/edit_record_page.dart';
import 'package:password_warden/screens/app_details_page.dart';
import 'package:password_warden/screens/no_records_page.dart';
import 'package:flutter/services.dart';
import 'package:password_warden/services/save_utility.dart';
import 'package:password_warden/widgets/yes_no_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  late Box<PasswordRecord> passwordBox;
  List<PasswordRecord> records = [];
  String filterText = '';

  @override
  void initState() {
    super.initState();
    passwordBox = Hive.box<PasswordRecord>('passwordRecords');
    _applyFilter();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  void _applyFilter() {
    setState(() {
      records = passwordBox.values.toList();
      if (filterText.isNotEmpty) {
        records = records
            .where((record) => record.applicationName
                .toLowerCase()
                .contains(filterText.toLowerCase()))
            .toList();
      }
      records.sort((a, b) {
        int cmp = a.applicationName
            .toLowerCase()
            .compareTo(b.applicationName.toLowerCase());
        if (cmp != 0) return cmp;
        return a.username.toLowerCase().compareTo(b.username.toLowerCase());
      });
    });
  }

  void showRecordDialog(BuildContext context, PasswordRecord record) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.applicationName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Username'),
                  subtitle: Text(record.username),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: record.username));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Username copied to clipboard')),
                      );
                    },
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Password'),
                  subtitle: Text(record.password),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: record.password));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Password copied to clipboard')),
                      );
                    },
                  ),
                ),
                ...record.additionalInfo.entries.map((entry) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(entry.key),
                    subtitle: Text(entry.value),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: entry.value));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  '${_toCamelCase(entry.key)} copied to clipboard')),
                        );
                      },
                    ),
                  );
                }),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EditRecordPage(record: record)),
                        ).then((value) =>
                            _applyFilter()); // Refresh list after editing
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteAllRecords() async {
    final confirm = await showDialog(
      context: context,
      builder: (context) {
        return const YesNoDialog(
            title: 'Confirm Delete',
            content: 'Are you sure you want to delete all records?',
            okBtnText: 'Delete');
      },
    );

    if (confirm == true) {
      await passwordBox.clear();
      setState(() {
        _applyFilter();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All records deleted')),
        );
      }
    }
  }

  Future<void> _exportAllRecords() async {
    final confirm = await showDialog(
      context: context,
      builder: (context) {
        return const YesNoDialog(
            title: 'Confirm Export',
            content:
                'Are you sure you want to export all records to JSON file? \nAnyone can read from file.',
            okBtnText: 'Export');
      },
    );

    if (confirm == true) {
      var records = passwordBox.values.toList();

      List<Map<String, dynamic>> jsonList =
          records.map((item) => item.toJson()).toList();
      String jsonString = jsonEncode(jsonList);
      bool isSaved = await saveJsonToFile(jsonString);

      setState(() {
        _applyFilter();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: isSaved
                  ? const Text('Export successful')
                  : const Text('Export failed')),
        );
      }
    }
  }

  Future<void> _importRecordsFromFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null) {
      try {
        File file = File(result.files.single.path!);
        String contents = await file.readAsString();
        List<dynamic> jsonData = json.decode(contents);
        List<PasswordRecord> data = jsonData
            .map<PasswordRecord>((item) => PasswordRecord.fromJson(item))
            .toList();

        Map<String, dynamic> appNameToKeyMap = {};
        var keys = passwordBox.keys.toList();
        var values = passwordBox.values.toList();
        for (int i = 0; i < values.length; i++) {
          var passwordRecord = values[i];
          var key = keys[i];
          appNameToKeyMap[passwordRecord.applicationName] = key;
        }

        for (var element in data) {
          if (appNameToKeyMap.containsKey(element.applicationName)) {
            Hive.box<PasswordRecord>('passwordRecords')
                .put(appNameToKeyMap[element.applicationName], element);
          } else {
            Hive.box<PasswordRecord>('passwordRecords').add(element);
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Records imported')),
          );
        }
        setState(() {
          _applyFilter();
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Import Failed. Invalid format.')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Import cancelled')),
        );
      }
    }
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(record.applicationName),
            subtitle: Text(record.username),
            onTap: () => showRecordDialog(context, record),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                passwordBox.delete(record.key);
                setState(() {
                  _applyFilter();
                });
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Warden'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Delete All') {
                _deleteAllRecords();
              } else if (value == 'Export') {
                _exportAllRecords();
              } else if (value == 'Import') {
                _importRecordsFromFile();
              } else if (value == 'App Details') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AppDetailsPage()),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Delete All',
                child: Text('Delete All Records'),
              ),
              const PopupMenuItem(
                value: 'Export',
                child: Text('Export to JSON'),
              ),
              const PopupMenuItem(
                value: 'Import',
                child: Text('Import from JSON'),
              ),
              const PopupMenuItem(
                value: 'App Details',
                child: Text('App Details'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Application Name',
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.teal),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.teal),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            filterText = '';
                            _applyFilter();
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  filterText = value;
                  _applyFilter();
                });
              },
            ),
          ),
          Expanded(
            child: records.isEmpty ? const NoRecordsPage() : _buildListView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRecordPage()),
          );
          _applyFilter(); // Refresh list after adding a new record
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _toCamelCase(String input) {
    if (input.isEmpty) {
      return '';
    }

    // Split the input string by spaces or underscores
    List<String> words = input.split(RegExp(r'\s+|_'));

    // Capitalize the first word and join with the rest capitalized
    String camelCaseString = words.map((word) {
      if (word.isEmpty) {
        return '';
      }
      if (word.length == 1) {
        return word.toUpperCase(); // Handles single-character words like 'a'
      }
      return word.substring(0, 1).toUpperCase() +
          word.substring(1).toLowerCase();
    }).join(' ');

    return camelCaseString;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
