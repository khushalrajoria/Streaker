import 'package:flutter/material.dart';

import '../modals/streakmodel.dart';

class AddStreakScreen extends StatefulWidget {
  @override
  _AddStreakScreenState createState() => _AddStreakScreenState();
}

class _AddStreakScreenState extends State<AddStreakScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();

  void _addStreak() {
    if (_nameController.text.isNotEmpty && _daysController.text.isNotEmpty) {
      final streak = Streak(
        name: _nameController.text,
        currentCount: 0,
        totalDays: int.parse(_daysController.text),
        lastUpdated: DateTime.now().subtract(Duration(days: 1)), // Ensures today can be clicked
      );
      // Save streak to local database here.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Streak')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Streak Name'),
            ),
            TextField(
              controller: _daysController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Total Days'),
            ),
            ElevatedButton(
              onPressed: _addStreak,
              child: Text('Add Streak'),
            ),
          ],
        ),
      ),
    );
  }
}
