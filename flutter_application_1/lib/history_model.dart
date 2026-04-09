class GameHistory {
  final String level;
  final String time;
  final String date;

  GameHistory({required this.level, required this.time, required this.date});

  factory GameHistory.fromJson(Map<String, dynamic> json) {
    return GameHistory(
      level: json['level']?.toString() ?? 'Easy',
      time: json['time']?.toString() ?? '0',
      // Ưu tiên created_at từ Laravel, nếu không có dùng date
      date: json['created_at'] ?? json['date'] ?? '',
    );
  }
}
