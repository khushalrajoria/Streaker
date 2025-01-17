import 'package:hive/hive.dart';

part 'streak.g.dart';

@HiveType(typeId: 0)
class Streak extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int currentCount;

  @HiveField(2)
  int totalDays;

  @HiveField(3)
  DateTime lastUpdated;

  Streak({
    required this.name,
    required this.currentCount,
    required this.totalDays,
    required this.lastUpdated,
  });

  void increment() {
    if (lastUpdated.day != DateTime.now().day) {
      currentCount++;
      lastUpdated = DateTime.now();
    }
  }

  void reset() {
    currentCount = 0;
  }
}
