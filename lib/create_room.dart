import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateRoom extends StatefulWidget {
  final String userId;
  const CreateRoom({super.key, required this.userId});

  @override
  State<CreateRoom> createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  String? roomId;

  Future<void> createRoom() async {
    final doc = await FirebaseFirestore.instance.collection('rooms').add({
      'hostId': widget.userId,
      'guestId': null,
      'status': 'waiting',

      'puzzle': ["1","2","3","4","5","6","7","8","0"],

      'players': {
        widget.userId: {
          'progress': 0,
          'time': 0,
        }
      }
    });

    setState(() {
      roomId = doc.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Room")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: createRoom,
              child: const Text("Tạo phòng"),
            ),

            if (roomId != null) ...[
              const SizedBox(height: 20),
              Text("Room ID: $roomId"),
              const Text("Share cho bạn bè để join"),
            ]
          ],
        ),
      ),
    );
  }
}