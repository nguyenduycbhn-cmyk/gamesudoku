import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'friends_service.dart';

class SearchFriendScreen extends StatefulWidget {
  const SearchFriendScreen({super.key});

  @override
  State<SearchFriendScreen> createState() => _SearchFriendScreenState();
}

class _SearchFriendScreenState extends State<SearchFriendScreen> {
  final TextEditingController controller = TextEditingController();
  final FriendService service = FriendService();

  String keyword = "";

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(title: const Text("Tìm người lạ")),
      body: Column(
        children: [
          // 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Nhập tên người lạ...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  keyword = value.toLowerCase();
                });
              },
            ),
          ),

          // 📋 LIST USER
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("friends")
                  .where("users", arrayContains: currentUser.uid)
                  .snapshots(),
              builder: (context, friendSnap) {
                List<String> friendIds = [];
                if (friendSnap.hasData) {
                  for (var doc in friendSnap.data!.docs) {
                    final f = doc.data() as Map<String, dynamic>;
                    List<String> users = List<String>.from(f["users"]);
                    users.remove(currentUser.uid);
                    if (users.isNotEmpty) friendIds.add(users[0]);
                  }
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection("users").snapshots(),
                  builder: (context, userSnap) {
                    if (!userSnap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // 🔍 LỌC: 1. Không phải mình, 2. Chưa kết bạn, 3. Khớp từ khóa
                    final strangers = userSnap.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = (data["name"] ?? "").toString().toLowerCase();

                      return doc.id != currentUser.uid &&
                          !friendIds.contains(doc.id) &&
                          name.contains(keyword);
                    }).toList();

                    if (strangers.isEmpty) {
                      return const Center(child: Text("Không có người lạ nào mới"));
                    }

                    return ListView.builder(
                      itemCount: strangers.length,
                      itemBuilder: (context, index) {
                        final u = strangers[index];
                        final data = u.data() as Map<String, dynamic>;

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: (data["isOnline"] ?? false)
                                  ? Colors.green
                                  : Colors.grey,
                              child: Text(data["name"]?[0] ?? "?"),
                            ),
                            title: Text(data["name"] ?? "No name"),
                            subtitle: Text(
                              (data["isOnline"] ?? false) ? "Đang Online" : "Ngoại tuyến",
                            ),
                            trailing: ElevatedButton(
                              onPressed: () async {
                                await service.sendRequest(u.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Đã gửi lời mời kết bạn")),
                                  );
                                }
                              },
                              child: const Text("Kết bạn"),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
