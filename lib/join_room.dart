import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'multiplayer_screen.dart';

class JoinRoom extends StatefulWidget {
  final String userId;
  const JoinRoom({super.key, required this.userId});

  @override
  State<JoinRoom> createState() => _JoinRoomState();
}

class _JoinRoomState extends State<JoinRoom> {
  final TextEditingController controller = TextEditingController();
  bool isLoading = false;

  Future<void> joinRoom() async {
    final roomId = controller.text.trim();
    if (roomId.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final roomDoc = await FirebaseFirestore.instance.collection('rooms').doc(roomId).get();
      
      if (!roomDoc.exists) {
        if (mounted) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mã phòng không tồn tại!")));
        }
        return;
      }

      // Thêm người chơi vào danh sách players và đổi trạng thái sang 'playing'
      await FirebaseFirestore.instance.collection('rooms').doc(roomId).update({
        'guestId': widget.userId,
        'status': 'playing',
        'players': FieldValue.arrayUnion([widget.userId]),
      });

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MultiplayerScreen(roomId: roomId)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vào phòng chơi")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.vpn_key_outlined, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Nhập mã phòng 6 số",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : joinRoom,
                child: isLoading ? const CircularProgressIndicator() : const Text("THAM GIA NGAY"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
