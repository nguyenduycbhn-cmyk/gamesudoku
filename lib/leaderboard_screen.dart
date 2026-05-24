import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String selectedLevel = "Dễ";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("BẢNG XẾP HẠNG", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Bộ lọc cấp độ
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ["Dễ", "Trung bình", "Khó"].map((level) {
                bool isSelected = selectedLevel == level;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? Colors.deepPurple : Colors.grey.shade200,
                        foregroundColor: isSelected ? Colors.white : Colors.black87,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: isSelected ? 4 : 0,
                      ),
                      onPressed: () => setState(() => selectedLevel = level),
                      child: Text(level, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const Divider(),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("history").snapshots(),
              builder: (context, snap) {
                if (snap.hasError) return Center(child: Text("Lỗi: ${snap.error}"));
                if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                final docs = snap.data?.docs ?? [];
                
                // 1. Lọc và kiểm tra dữ liệu hợp lệ
                final filtered = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data["level"] == selectedLevel && data["time"] != null;
                }).toList();
                
                // 2. Sắp xếp an toàn
                filtered.sort((a, b) {
                  final da = a.data() as Map<String, dynamic>;
                  final db = b.data() as Map<String, dynamic>;
                  final t1 = da["time"] is num ? da["time"] : 999999;
                  final t2 = db["time"] is num ? db["time"] : 999999;
                  return (t1 as num).compareTo(t2 as num);
                });

                if (filtered.isEmpty) {
                  return const Center(child: Text("Chưa có ai trong bảng xếp hạng này"));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, i) {
                    final data = filtered[i].data() as Map<String, dynamic>;
                    final name = data["name"] ?? "Ẩn danh";
                    final time = data["time"] ?? 0;

                    return Card(
                      elevation: i < 3 ? 4 : 1,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: i < 3 ? Colors.deepPurple.shade50 : Colors.white,
                      child: ListTile(
                        leading: _buildRankBadge(i),
                        title: Text(name, style: TextStyle(fontWeight: i < 3 ? FontWeight.bold : FontWeight.normal, fontSize: 17)),
                        subtitle: Text("Thời gian: ${time}s"),
                        trailing: Icon(Icons.emoji_events, color: _getRankColor(i), size: 24),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRankBadge(int index) {
    if (index == 0) return const Icon(Icons.emoji_events, color: Colors.amber, size: 35);
    if (index == 1) return const Icon(Icons.emoji_events, color: Colors.grey, size: 32);
    if (index == 2) return const Icon(Icons.emoji_events, color: Colors.orangeAccent, size: 30);
    return CircleAvatar(radius: 15, backgroundColor: Colors.grey.shade200, child: Text("${index + 1}", style: const TextStyle(fontSize: 12, color: Colors.black54)));
  }

  Color _getRankColor(int index) {
    if (index == 0) return Colors.amber;
    if (index == 1) return Colors.grey.shade400;
    if (index == 2) return Colors.orangeAccent;
    return Colors.transparent;
  }
}
