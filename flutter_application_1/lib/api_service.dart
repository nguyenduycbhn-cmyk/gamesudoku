import 'dart:convert';
import "package:http/http.dart" as http;

class ApiService {
  // 10.0.2.2 cho máy ảo Android, localhost cho web/ios
  static const String baseUrl = "http://10.0.2.2:8000/api";

  // Lấy danh sách lịch sử
  Future<List<dynamic>> fetchHistory() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/game/history'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> result = jsonDecode(response.body);
        return result['data'] as List;
      }
    } catch (e) {
      print("Lỗi kết nối fetchHistory: $e");
    }
    return [];
  }

  // Lưu kết quả sau khi thắng
  Future<bool> saveGameResult({
    required String difficulty,
    required int timeSpent,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/game/history'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'level': difficulty, 'time': timeSpent}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Lỗi lưu kết quả: $e");
      return false;
    }
  }
}
