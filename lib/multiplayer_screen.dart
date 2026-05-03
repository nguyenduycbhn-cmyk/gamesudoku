import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'multiplayer_service.dart';

class MultiplayerScreen extends StatefulWidget {
  final String roomId;

  const MultiplayerScreen({super.key, required this.roomId});

  @override
  State<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends State<MultiplayerScreen> {
  final service = MultiplayerService();
  final user = FirebaseAuth.instance.currentUser!;

  int selectedRow = -1;
  int selectedCol = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sudoku Multiplayer"),
      ),
      body: StreamBuilder(
        stream: service.getRoom(widget.roomId),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data!.data() as Map<String, dynamic>;

          List players = data["players"];
          String turn = data["turn"];
          String winner = data["winner"];

          List<List<int>> board =
          (data["board"] as List)
              .map((e) => List<int>.from(e))
              .toList();

          bool isMyTurn = turn == user.uid;

          return Column(
            children: [

              // 🏆 WINNER
              if (winner != "")
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    winner == user.uid ? "🎉 Bạn thắng!" : "😢 Bạn thua",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

              // 🔄 TURN
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  isMyTurn ? "👉 Lượt của bạn" : "⏳ Đợi đối thủ",
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              // 🎮 BOARD
              Column(
                children: List.generate(9, (i) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(9, (j) {
                      bool selected = i == selectedRow && j == selectedCol;

                      return GestureDetector(
                        onTap: () {
                          if (!isMyTurn) return;

                          setState(() {
                            selectedRow = i;
                            selectedCol = j;
                          });
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.blue.shade200
                                : Colors.grey.shade200,
                            border: Border.all(color: Colors.black),
                          ),
                          child: Text(
                            board[i][j] == 0
                                ? ""
                                : board[i][j].toString(),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),

              const SizedBox(height: 10),

              // 🔢 INPUT NUMBER
              Wrap(
                children: List.generate(9, (i) {
                  return GestureDetector(
                    onTap: () async {
                      if (!isMyTurn) return;
                      if (selectedRow == -1) return;

                      board[selectedRow][selectedCol] = i + 1;

                      await service.updateBoard(widget.roomId, board);

                      // 🔄 đổi lượt
                      String next =
                      players.first == user.uid
                          ? players[1]
                          : players[0];

                      await service.db
                          .collection("rooms")
                          .doc(widget.roomId)
                          .update({"turn": next});
                    },
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text("${i + 1}"),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}