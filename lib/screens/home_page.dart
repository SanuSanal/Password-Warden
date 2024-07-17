import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:password_warden/models/password_record.dart';
import 'package:password_warden/screens/add_record_page.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Box<PasswordRecord> passwordBox;
  late List<PasswordRecord> records;

  @override
  void initState() {
    super.initState();
    passwordBox = Hive.box<PasswordRecord>('passwordRecords');
    records = passwordBox.values.toList();
    records.sort((a, b) {
      int cmp = a.applicationName.compareTo(b.applicationName);
      if (cmp != 0) return cmp;
      return a.username.compareTo(b.username);
    });
    // Listen to changes in the box
    passwordBox.watch().listen((event) {
      setState(() {
        records = passwordBox.values.toList();
        records.sort((a, b) {
          int cmp = a.applicationName.compareTo(b.applicationName);
          if (cmp != 0) return cmp;
          return a.username.compareTo(b.username);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Password Warden'),
      ),
      body: _buildListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRecordPage()),
          );
        },
        tooltip: 'Add Record',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildListView() {
    if (records.isEmpty) {
      return Center(
        child: Text('No records found'),
      );
    }

    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        PasswordRecord record = records[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            title: Text(record.applicationName),
            subtitle: Text(record.username),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _deleteRecord(record);
              },
            ),
            onTap: () {
              showRecordDialog(context, record);
            },
          ),
        );
      },
    );
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
                            content: Text('${entry.key} copied to clipboard')),
                      );
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _deleteRecord(PasswordRecord record) {
    passwordBox.delete(record.key);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Record deleted')),
    );
  }
}
