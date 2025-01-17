import 'package:flutter/material.dart';
import 'package:streaker/screens/add_screen.dart';

import '../modals/streakmodel.dart';

class StreakListScreen extends StatefulWidget {
  @override
  _StreakListScreenState createState() => _StreakListScreenState();
}

class _StreakListScreenState extends State<StreakListScreen> {
  List<Streak> streaks = []; // Replace this with data from your local database.

  void _incrementStreak(Streak streak) {
    final now = DateTime.now();

    if (streak.lastUpdated.day != now.day ||
        streak.lastUpdated.month != now.month ||
        streak.lastUpdated.year != now.year) {
      setState(() {
        streak.increment();
        // Save updated streak to database here.
      });
    }
  }

  void _resetMissedStreaks() {
    final now = DateTime.now();
    for (var streak in streaks) {
      if (streak.lastUpdated.day != now.day ||
          streak.lastUpdated.month != now.month ||
          streak.lastUpdated.year != now.year) {
        setState(() {
          streak.reset();
          // Save reset streak to database here.
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Load streaks from the database here.
    // Check for missed streaks and reset.
    _resetMissedStreaks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Streaks')),
      body: ListView.builder(
        itemCount: streaks.length,
        itemBuilder: (context, index) {
          final streak = streaks[index];
          return Card(
            child: ListTile(
              title: Text(streak.name),
              subtitle: Text(
                  'Progress: ${streak.currentCount}/${streak.totalDays}'),
              trailing: ElevatedButton(
                onPressed: (streak.lastUpdated.day == DateTime.now().day)
                    ? null
                    : () => _incrementStreak(streak),
                child: Text('+'),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to AddStreakScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddStreakScreen()),
          ).then((value) {
            // Reload streaks after adding a new one.
            setState(() {
              // Fetch updated streaks from the database here.
            });
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
