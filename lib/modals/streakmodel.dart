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
