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
