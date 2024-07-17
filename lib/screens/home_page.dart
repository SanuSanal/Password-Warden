import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:password_warden/models/password_record.dart';
import 'package:password_warden/screens/add_record_page.dart';
import 'package:password_warden/screens/edit_record_page.dart';
import 'package:password_warden/screens/app_details_page.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        int cmp = a.applicationName.compareTo(b.applicationName);
        if (cmp != 0) return cmp;
        return a.username.compareTo(b.username);
      });
    });
  }

  void showRecordDialog(BuildContext context, PasswordRecord record) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(record.applicationName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Username'),
                subtitle: Text(record.username),
                trailing: IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: record.username));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Username copied to clipboard')),
                    );
                  },
                ),
              ),
              ListTile(
                title: Text('Password'),
                subtitle: Text(record.password),
                trailing: IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: record.password));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Password copied to clipboard')),
                    );
                  },
                ),
              ),
              ...record.additionalInfo.entries.map((entry) {
                return ListTile(
                  title: Text(entry.key),
                  subtitle: Text(entry.value),
                  trailing: IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: entry.value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('${entry.key} value copied to clipboard')),
                      );
                    },
                  ),
                );
              }).toList(),
            ],
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
              child: Text('Edit'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
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
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete all records?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All records deleted')),
      );
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
            icon: Icon(Icons.delete),
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
        title: Text('Password Warden'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Delete All') {
                _deleteAllRecords();
              } else if (value == 'App Details') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppDetailsPage()),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'Delete All',
                child: Text('Delete All Records'),
              ),
              PopupMenuItem(
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
              decoration: InputDecoration(
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
            MaterialPageRoute(builder: (context) => AddRecordPage()),
          );
          _applyFilter(); // Refresh list after adding a new record
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
