import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔥 GỬI LỜI MỜI
  Future<void> sendRequest(String toUid) async {
    final fromUid = _auth.currentUser!.uid;

    if (fromUid == toUid) return; // ❌ không tự add mình

    // 🔍 check đã tồn tại chưa (2 chiều)
    final snapshot = await _db
        .collection('friends')
        .where("users", arrayContains: fromUid)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final users = List<String>.from(data['users']);

      if (users.contains(toUid)) {
        // 🔥 đã tồn tại → không gửi lại
        return;
      }
    }

    // ✅ tạo lời mời mới
    await _db.collection('friends').add({
      'from': fromUid,
      'to': toUid,
      'users': [fromUid, toUid],
      'status': 'pending',
      'created': FieldValue.serverTimestamp(),
    });
  }

  // ✅ CHẤP NHẬN
  Future<void> accept(String docId) async {
    await _db.collection('friends').doc(docId).update({
      'status': 'accepted',
    });
  }

  // ❌ TỪ CHỐI
  Future<void> reject(String docId) async {
    await _db.collection('friends').doc(docId).delete();
  }

  // 🔥 CHECK TRẠNG THÁI (dùng cho UI)
  Stream<String> getStatus(String otherUid) {
    final myUid = _auth.currentUser!.uid;

    return _db
        .collection('friends')
        .where("users", arrayContains: myUid)
        .snapshots()
        .map((snap) {
      for (var doc in snap.docs) {
        final data = doc.data();
        final users = List<String>.from(data['users']);

        if (users.contains(otherUid)) {
          return data['status'] ?? "none";
        }
      }

      return "none";
    });
  }
}