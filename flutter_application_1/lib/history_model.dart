class GameHistory {
  final String level;
  final String time;
  final String date;

  GameHistory({required this.level, required this.time, required this.date});

 factory GameHistory.fromJson(Map<String, dynamic> json) {
  return GameHistory(
    // Ép kiểu về String trước, sau đó mới dùng int.tryParse để chuyển sang số
    level: json['difficulty']?.toString() ?? "Easy", 
    
    // Sửa lỗi int ở đây:
    time: int.tryParse(json['time_spent']?.toString() ?? '0') ?? 0, 
    
    date: json['created_at']?.toString() ?? "",
  );
}
