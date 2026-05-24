import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String selectedLevel = "Dễ";

  Widget filterBtn(String text) {
    bool selected = selectedLevel == text;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: selected ? Colors.deepPurple : Colors.grey.shade200,
            foregroundColor: selected ? Colors.white : Colors.black87,
            elevation: selected ? 4 : 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => setState(() => selectedLevel = text),
          child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Bảng Xếp Hạng", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                filterBtn("Dễ"),
                filterBtn("Trung bình"),
                filterBtn("Khó"),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("history")
                  .orderBy("time")
                  .snapshots(),
              builder: (_, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snap.hasData || snap.data!.docs.isEmpty) {
                  return const Center(child: Text("Chưa có dữ liệu xếp hạng"));
                }

                final docs = snap.data!.docs;
                final filtered = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data["level"] == selectedLevel;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text("Chưa có ai chinh phục độ khó này!"));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (_, i) {
                    final data = filtered[i].data() as Map<String, dynamic>;
                    final name = data["name"] ?? "Anonymous";
                    final time = data["time"] ?? 0;

                    // Widget icon cho Top 3
                    Widget leading;
                    if (i == 0) {
                      leading = const Icon(Icons.emoji_events, color: Colors.amber, size: 30);
                    } else if (i == 1) {
                      leading = Icon(Icons.emoji_events, color: Colors.grey.shade400, size: 28);
                    } else if (i == 2) {
                      leading = const Icon(Icons.emoji_events, color: Colors.orangeAccent, size: 26);
                    } else {
                      leading = CircleAvatar(
                        backgroundColor: Colors.deepPurple.shade50,
                        radius: 15,
                        child: Text("${i + 1}", style: const TextStyle(fontSize: 12, color: Colors.deepPurple)),
                      );
                    }

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: leading,
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Cấp độ: $selectedLevel"),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${time}s",
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
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
}
