import 'package:flutter/material.dart';

class NoRecordsPage extends StatelessWidget {
  const NoRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.error_outline,
            size: 80.0,
            color: Colors.grey,
          ),
          SizedBox(height: 20.0),
          Text(
            'No data available',
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
