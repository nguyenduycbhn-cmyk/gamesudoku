import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  final _db = FirebaseFirestore.instance;

  // Gửi lời mời kết bạn
  Future<void> sendRequest(String toUid) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final fromUid = user.uid;
    if (fromUid == toUid) return;

    // Kiểm tra xem đã tồn tại kết nối chưa
    final query = await _db.collection("friends")
        .where("users", arrayContains: fromUid)
        .get();
    
    for (var doc in query.docs) {
      List users = doc["users"];
      if (users.contains(toUid)) return; 
    }

    await _db.collection("friends").add({
      "users": [fromUid, toUid],
      "from": fromUid,
      "to": toUid,
      "status": "pending",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  // Chấp nhận bạn bè
  Future<void> accept(String docId) async {
    await _db.collection("friends").doc(docId).update({"status": "accepted"});
  }

  // Từ chối hoặc Xóa bạn
  Future<void> reject(String docId) async {
    await _db.collection("friends").doc(docId).delete();
  }

  // Lấy danh sách lời mời ĐẾN tôi
  Stream<QuerySnapshot> getIncomingRequests() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return _db.collection("friends")
        .where("to", isEqualTo: user.uid)
        .where("status", isEqualTo: "pending")
        .snapshots();
  }

  // Lấy danh sách bạn bè đã đồng ý
  Stream<QuerySnapshot> getFriends() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return _db.collection("friends")
        .where("users", arrayContains: user.uid)
        .where("status", isEqualTo: "accepted")
        .snapshots();
  }
}
