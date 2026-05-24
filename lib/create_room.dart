import 'dart:math';
import 'package:flutter/material.dart';import 'package:cloud_firestore/cloud_firestore.dart';
import 'multiplayer_service.dart';
import 'multiplayer_screen.dart';

class CreateRoom extends StatefulWidget {
  final String userId;
  const CreateRoom({super.key, required this.userId});

  @override
  State<CreateRoom> createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  String? roomId;
  final service = MultiplayerService();
  bool isLoading = false;

  Future<void> createRoom() async {
    if (widget.userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi: Bạn chưa đăng nhập!")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final random = Random();
      String id = (random.nextInt(900000) + 100000).toString();

      final solution = service.generateSolvedBoard();
      final board = service.createPuzzle(solution);

      // ✅ Dùng hàm của Service để đảm bảo đồng bộ định dạng dữ liệu
      final boardData = service.convertBoard(board);
      final solutionData = service.convertBoard(solution);

      await FirebaseFirestore.instance.collection('rooms').doc(id).set({
        'hostId': widget.userId,
        'guestId': null,
        'status': 'waiting',
        'board': boardData,
        'solution': solutionData,
        'players': [widget.userId],
        'turn': widget.userId,
        'winner': '',
        'created': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          roomId = id;
          isLoading = false;
        });
      }
    } catch (e) {
      print("LỖI TẠO PHÒNG: $e");
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tạo phòng Sudoku")),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (roomId == null) ...[
                const Icon(Icons.add_to_home_screen_rounded, size: 100, color: Colors.deepPurple),
                const SizedBox(height: 20),
                const Text("Bấm nút dưới để lấy mã phòng", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 30),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                  onPressed: createRoom,
                  icon: const Icon(Icons.vpn_key),
                  label: const Text("TẠO MÃ PHÒNG 6 SỐ"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ] else ...[
                const Icon(Icons.celebration, color: Colors.orange, size: 80),
                const SizedBox(height: 20),
                const Text("Mã phòng của bạn là:", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.deepPurple.shade200, width: 2),
                  ),
                  child: SelectableText(
                    roomId!,
                    style: const TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                      letterSpacing: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text("Gửi mã này cho bạn bè nhé!", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    // Chuyển sang màn hình chơi
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MultiplayerScreen(roomId: roomId!),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 50),
                  ),
                  child: const Text("VÀO SẢNH ĐỢI"),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}