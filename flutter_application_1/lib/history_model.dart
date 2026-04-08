class GameHistory {
  final String level;
  final String time;
  final String date;

  GameHistory({required this.level, required this.time, required this.date});

  factory GameHistory.fromJson(Map<String, dynamic> json) {
    return GameHistory(
      level: json['level'],
      time: json['time'],
      date: json['date'],
    );
  }
}
