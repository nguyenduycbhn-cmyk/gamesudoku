import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // 10.0.2.2 là địa chỉ IP để máy ảo Android hiểu là "localhost" của máy tính
  static const String baseUrl = "http://127.0.0.1:8000/api";

  // Hàm lấy lịch sử từ Laravel
  Future<List<dynamic>> fetchHistory() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/game/history'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = jsonDecode(response.body);
        // Trả về mảng dữ liệu nằm trong key 'data' của Laravel
        return result['data'] as List;
      } else {
        print("Lỗi server: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi kết nối: $e");
    }
    return [];
  }
}
