import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'game_room_screen.dart';

class RoomService {
  final db = FirebaseFirestore.instance;

  // 🟢 TẠO PHÒNG
  Future<String> createRoom() async {
    final user = FirebaseAuth.instance.currentUser!;

    final doc = db.collection("rooms").doc();

    await doc.set({
      "host": user.uid,
      "guest": null,

      "board": List.generate(81, (_) => 0), // 👈 int thống nhất

      "turn": user.uid,
      "status": "waiting",

      "winner": "",
      "createdAt": FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  // 🎮 MỜI BẠN
  Future<void> inviteFriend(String roomId, String friendUid) async {
    await db.collection("rooms").doc(roomId).update({
      "guest": friendUid,
      "status": "playing",
    });
  }

  // 🚪 JOIN PHÒNG
  void joinRoom(BuildContext context, String roomId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameRoomScreen(roomId: roomId),
      ),
    );
  }

  // 🏆 SET WIN
  Future<void> setWin(String roomId, String uid) async {
    await db.collection("rooms").doc(roomId).update({
      "status": "finished",
      "winner": uid,
    });
  }

  // 🔁 CHANGE TURN
  Future<void> switchTurn(
      String roomId, String nextUid) async {
    await db.collection("rooms").doc(roomId).update({
      "turn": nextUid,
    });
  }
}