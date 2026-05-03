import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JoinRoom extends StatefulWidget {
  final String userId;
  const JoinRoom({super.key, required this.userId});

  @override
  State<JoinRoom> createState() => _JoinRoomState();
}

class _JoinRoomState extends State<JoinRoom> {
  final TextEditingController controller = TextEditingController();

  Future<void> joinRoom() async {
    final roomId = controller.text.trim();

    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .update({
      'guestId': widget.userId,
      'status': 'playing',
      'players.${widget.userId}': {
        'progress': 0,
        'time': 0,
      }
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          roomId: roomId,
          userId: widget.userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Join Room")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Enter Room ID",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: joinRoom,
              child: const Text("Join"),
            ),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  final String roomId;
  final String userId;

  const GameScreen({
    super.key,
    required this.roomId,
    required this.userId,
  });

  Stream<DocumentSnapshot> listenRoom() {
    return FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Game")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: listenRoom(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final room = data.data() as Map<String, dynamic>;
          final players = room['players'];

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Room: $roomId"),
              const SizedBox(height: 20),

              Text("You: ${players[userId]['progress']}%"),
              const SizedBox(height: 10),

              Text("Opponent: ${getOpponent(players)['progress']}%"),
            ],
          );
        },
      ),
    );
  }

  Map<String, dynamic> getOpponent(Map players) {
    return players.entries
        .firstWhere((e) => e.key != userId)
        .value;
  }
}