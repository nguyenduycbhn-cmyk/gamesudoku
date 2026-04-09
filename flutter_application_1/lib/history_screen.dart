import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'dart:convert';
import 'history_model.dart';

class _HistoryScreenState extends State<HistoryScreen> {
  List<GameHistory> history = [];
  bool isLoading = false; // Biến trạng thái để hiện vòng xoay tải dữ liệu

  @override
  void initState() {
    super.initState();
    loadFromServer(); // Thay vì load() cũ
  }

  // Hàm này sẽ gọi API Laravel
  void load() async {
    setState(() {
      isLoading = true; // Hiện vòng xoay loading
    });

    try {
      ApiService api = ApiService();
      // Gọi hàm vừa thêm ở Bước 1
      List<dynamic> data = await api.fetchHistory();

      setState(() {
        history = data.map((e) => GameHistory.fromJson(e)).toList();
        isLoading = false; // Tắt vòng xoay
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Lỗi tải data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Server History"),
        actions: [
          // Nút làm mới dữ liệu từ Database
          IconButton(onPressed: loadFromServer, icon: Icon(Icons.refresh)),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            ) // Hiện vòng xoay khi đợi API
          : history.isEmpty
          ? Center(child: Text("No history on server"))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (_, i) {
                final h = history[i];
                return ListTile(
                  leading: Icon(Icons.cloud_done, color: Colors.blue),
                  title: Text("Level: ${h.level}"),
                  subtitle: Text("Time: ${h.time}s"),
                  trailing: Text(h.date.toString().substring(0, 10)),
                );
              },
            ),
    );
  }
}
