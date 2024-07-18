import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:password_warden/models/password_record.dart';
import 'package:password_warden/screens/add_record_page.dart';
import 'package:password_warden/screens/edit_record_page.dart';
import 'package:password_warden/screens/app_details_page.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late Box<PasswordRecord> passwordBox;
  List<PasswordRecord> records = [];
  String filterText = '';

  @override
  void initState() {
    super.initState();
    passwordBox = Hive.box<PasswordRecord>('passwordRecords');
    _applyFilter();
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
        return AlertDialog(
          title: Text(record.applicationName),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditRecordPage(record: record)),
                ).then((value) => _applyFilter()); // Refresh list after editing
              },
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAllRecords() async {
    final confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete all records?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
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

  Widget _buildListView() {
    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return ListTile(
          title: Text(record.applicationName),
          subtitle: Text(record.username),
          onTap: () => showRecordDialog(context, record),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              passwordBox.delete(record.key);
              setState(() {
                _applyFilter();
              });
            },
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
              decoration: const InputDecoration(
                hintText: 'Search by Application Name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
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
            child: _buildListView(),
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
        child: const Icon(Icons.add),
      ),
    );
  }

  _toCamelCase(String input) {
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
}
