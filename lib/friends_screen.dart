import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'friends_service.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final service = FriendService();

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("Chưa đăng nhập")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Bạn bè")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("users").snapshots(),
        builder: (context, userSnap) {
          if (!userSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = userSnap.data!.docs
              .where((u) => u.id != currentUser.uid)
              .toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final u = users[index];
              final data = u.data() as Map<String, dynamic>;

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("friends")
                    .where("users", arrayContains: currentUser.uid)
                    .snapshots(),
                builder: (context, friendSnap) {
                  String status = "none";

                  if (friendSnap.hasData) {
                    for (var doc in friendSnap.data!.docs) {
                      final f = doc.data() as Map<String, dynamic>;
                      final usersInDoc = List<String>.from(f["users"]);
                      if (usersInDoc.contains(u.id)) {
                        status = f["status"] ?? "none";
                        break;
                      }
                    }
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: (data["isOnline"] ?? false)
                            ? Colors.green
                            : Colors.grey,
                      ),
                      title: Text(data["name"] ?? "No name"),
                      subtitle: Text(
                        data["status"] == "playing"
                            ? "🟡 Đang chơi"
                            : (data["isOnline"] ?? false)
                            ? "🟢 Online"
                            : "⚫ Offline",
                      ),
                      trailing: _buildButton(
                        context,
                        status,
                        service,
                        u.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildButton(
      BuildContext context,
      String status,
      FriendService service,
      String userId,
      ) {
    if (status == "accepted") {
      return const Text("Bạn bè",
          style: TextStyle(color: Colors.green));
    }

    if (status == "pending") {
      return const Text("Đã gửi",
          style: TextStyle(color: Colors.orange));
    }

    return ElevatedButton(
      onPressed: () async {
        await service.sendRequest(userId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đã gửi lời mời")),
          );
        }
      },
      child: const Text("Kết bạn"),
    );
  }
}
