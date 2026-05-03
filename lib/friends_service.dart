import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  final _db = FirebaseFirestore.instance;

  Future<void> sendRequest(String toUid) async {
    final fromUid = "CURRENT_USER"; // không dùng string này nữa

    final doc = _db.collection("friends").doc();

    await doc.set({
      "from": fromUid,
      "to": toUid,
      "status": "pending",
      "createdAt": DateTime.now(),
    });
  }

  Future<void> accept(String docId) async {
    await _db.collection("friends").doc(docId).update({
      "status": "accepted",
    });
  }

  Future<void> reject(String docId) async {
    await _db.collection("friends").doc(docId).delete();
  }
}