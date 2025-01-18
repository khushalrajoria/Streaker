import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Streak {
  String name;
  int currentCount;
  int totalDays;
  DateTime lastUpdated;

  Streak({
    required this.name,
    required this.currentCount,
    required this.totalDays,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'currentCount': currentCount,
      'totalDays': totalDays,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory Streak.fromMap(Map<String, dynamic> map) {
    return Streak(
      name: map['name'],
      currentCount: map['currentCount'],
      totalDays: map['totalDays'],
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }
}

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
    _resetMissedStreaks();
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
        if (streak.currentCount >= streak.totalDays) {
          streaks.remove(streak);
        }
      });
      _saveStreaks();
    }
  }

  void _resetMissedStreaks() {
    final now = DateTime.now();
    setState(() {
      for (var streak in streaks) {
        if (streak.lastUpdated.day != now.day ||
            streak.lastUpdated.month != now.month ||
            streak.lastUpdated.year != now.year) {
          streak.currentCount = 0;
        }
      }
    });
    _saveStreaks();
  }

  void _showAddStreakDialog() {
    final nameController = TextEditingController();
    final daysController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Add Streak',
            style: TextStyle(fontSize: 22, color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Streak Name',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              TextField(
                controller: daysController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total Days',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Khushal`s Streaks',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
  itemCount: streaks.length,
  itemBuilder: (context, index) {
    final streak = streaks[index];
    double progress = streak.totalDays == 0
        ? 0
        : streak.currentCount / streak.totalDays;

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Circular Progress Bar
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.blue,
                    strokeWidth: 6.0,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Streak Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    streak.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Progress: ${streak.currentCount}/${streak.totalDays}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Increment Button
            ElevatedButton(
              onPressed: (streak.lastUpdated.day == DateTime.now().day)
                  ? null
                  : () => _incrementStreak(streak),
              child: const Text(
                '+',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  },
),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 27, 247, 203),
        onPressed: () => _showAddStreakDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
