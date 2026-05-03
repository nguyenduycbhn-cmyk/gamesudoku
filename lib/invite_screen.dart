import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'game_room_screen.dart';

class InviteScreen extends StatelessWidget {
  const InviteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(title: const Text("Lời mời chơi")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("rooms")
            .where("guest", isEqualTo: user.uid)
            .where("status", isEqualTo: "playing")
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rooms = snap.data!.docs;

          if (rooms.isEmpty) {
            return const Center(
              child: Text("Không có lời mời nào"),
            );
          }

          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, i) {
              final roomId = rooms[i].id;
              final data = rooms[i].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const Icon(Icons.sports_esports),
                  title: const Text("Bạn được mời chơi Sudoku"),
                  subtitle: Text("Room: $roomId"),
                  trailing: ElevatedButton(
                    child: const Text("Vào chơi"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              GameRoomScreen(roomId: roomId),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}