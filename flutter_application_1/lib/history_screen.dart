import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'history_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<GameHistory> history = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadFromServer();
  }

  // Hàm gọi API từ Laravel
  Future<void> loadFromServer() async {
    setState(() {
      isLoading = true;
    });

    try {
      ApiService api = ApiService();
      // Gọi hàm lấy dữ liệu từ Server
      List<dynamic> data = await api.fetchHistory();

      setState(() {
        history = data.map((e) => GameHistory.fromJson(e)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Lỗi tải data: $e");

      // Hiển thị thông báo lỗi cho người dùng
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Không thể tải dữ liệu từ server")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Server History"),
        actions: [
          // Nút làm mới dữ liệu
          IconButton(
            onPressed: loadFromServer,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
          ? const Center(child: Text("No history on server"))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (_, i) {
                final h = history[i];
                return ListTile(
                  leading: const Icon(Icons.cloud_done, color: Colors.blue),
                  title: Text("Level: ${h.level}"),
                  subtitle: Text("Time: ${h.time}s"),
                  // Cắt chuỗi ngày tháng để hiển thị gọn hơn (YYYY-MM-DD)
                  trailing: Text(
                    h.date.toString().length > 10
                        ? h.date.toString().substring(0, 10)
                        : h.date.toString(),
                  ),
                );
              },
            ),
    );
  }
}
