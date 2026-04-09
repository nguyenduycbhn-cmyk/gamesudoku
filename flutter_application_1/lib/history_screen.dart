import 'package:flutter/material.dart';
import 'history_model.dart';
import 'api_service.dart';

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

  Future<void> loadFromServer() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      final api = ApiService();
      final List<dynamic>? data = await api.fetchHistory();

      if (mounted) {
        setState(() {
          if (data != null) {
            history = data.map((e) => GameHistory.fromJson(e)).toList();
            // Sắp xếp lịch sử theo ngày giảm dần (mới nhất trước)
            history.sort((a, b) => b.date.compareTo(a.date));
          }
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi kết nối Server: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử từ Server"),
        elevation: 2,
        actions: [
          IconButton(
            onPressed: isLoading ? null : loadFromServer,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadFromServer,
              child: history.isEmpty
                  ? const Center(child: Text("Chưa có lịch sử trên server"))
                  : ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: history.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, i) {
                        final h = history[i];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: const Icon(
                              Icons.history,
                              color: Colors.blue,
                            ),
                          ),
                          title: Text(
                            "Cấp độ: ${h.level}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("Thời gian: ${h.time} giây"),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.grey,
                              ),
                              Text(h.date.toString().split(' ')[0]),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
