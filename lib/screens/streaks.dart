import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modals/streak_model.dart';


class StreakScreen extends StatefulWidget {
  const StreakScreen({super.key});

  @override
  _StreakScreenState createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  List<Streak> streaks = [];

  @override
  void initState() {
    super.initState();
    _loadStreaks();
  }

  Future<void> _loadStreaks() async {
    final prefs = await SharedPreferences.getInstance();
    final streakData = prefs.getStringList('streaks') ?? [];
    setState(() {
      streaks = streakData
          .map((streakJson) => Streak.fromMap(json.decode(streakJson)))
          .toList();
    });
  }

  Future<void> _saveStreaks() async {
    final prefs = await SharedPreferences.getInstance();
    final streakData =
        streaks.map((streak) => json.encode(streak.toMap())).toList();
    await prefs.setStringList('streaks', streakData);
  }

  void _addStreak(String name, int totalDays) {
    final newStreak = Streak(
      name: name,
      currentCount: 0,
      totalDays: totalDays,
      lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
    );
    setState(() {
      streaks.add(newStreak);
    });
    _saveStreaks();
  }

  void _incrementStreak(Streak streak) {
    final now = DateTime.now();
    if (streak.lastUpdated.day != now.day ||
        streak.lastUpdated.month != now.month ||
        streak.lastUpdated.year != now.year) {
      setState(() {
        streak.currentCount++;
        streak.lastUpdated = now;
      });
      _saveStreaks();
    }
  }

  void _resetMissedStreaks() {
    final now = DateTime.now();
    for (var streak in streaks) {
      if (streak.lastUpdated.day != now.day ||
          streak.lastUpdated.month != now.month ||
          streak.lastUpdated.year != now.year) {
        setState(() {
          streak.currentCount = 0;
        });
      }
    }
    _saveStreaks();
  }

  @override
  Widget build(BuildContext context) {
    _resetMissedStreaks();

    return Scaffold(
      appBar: AppBar(title: const Text('Streaks')),
      body: ListView.builder(
        itemCount: streaks.length,
        itemBuilder: (context, index) {
          final streak = streaks[index];
          return Card(
            child: ListTile(
              title: Text(streak.name),
              subtitle:
                  Text('Progress: ${streak.currentCount}/${streak.totalDays}'),
              trailing: ElevatedButton(
                onPressed: (streak.lastUpdated.day == DateTime.now().day)
                    ? null
                    : () => _incrementStreak(streak),
                child: const Text('+'),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStreakDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddStreakDialog() {
    final nameController = TextEditingController();
    final daysController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Streak'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Streak Name'),
              ),
              TextField(
                controller: daysController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total Days'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text;
                final days = int.tryParse(daysController.text) ?? 0;
                if (name.isNotEmpty && days > 0) {
                  _addStreak(name, days);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
