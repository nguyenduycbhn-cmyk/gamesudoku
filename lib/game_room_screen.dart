import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GameRoomScreen extends StatefulWidget {
  final String roomId;
  const GameRoomScreen({super.key, required this.roomId});

  @override
  State<GameRoomScreen> createState() => _GameRoomScreenState();
}

class _GameRoomScreenState extends State<GameRoomScreen> {
  final db = FirebaseFirestore.instance;
  int selectedIndex = -1;

  // 🧠 CHECK WIN (đơn giản: hết ô trống)
  bool checkWin(List<int> board) {
    return !board.contains(0);
  }

  // 🎮 MOVE + WIN LOGIC
  void playMove(int index, int value) async {
    final user = FirebaseAuth.instance.currentUser!;
    final roomRef = db.collection("rooms").doc(widget.roomId);

    final room = await roomRef.get();
    if (!room.exists) return;
    
    final data = room.data() as Map<String, dynamic>;

    // ❌ nếu game kết thúc thì không chơi nữa
    if (data["status"] == "finished") return;

    // ❌ không đúng lượt
    if (data["turn"] != user.uid) return;

    List<int> board = List<int>.from(data["board"]);
    board[index] = value;

    bool win = checkWin(board);

    // 🔄 update move + đổi lượt
    await roomRef.update({
      "board": board,
      "turn": data["turn"] == data["host"]
          ? data["guest"]
          : data["host"],
    });

    // 🏆 nếu thắng
    if (win) {
      await roomRef.update({
        "status": "finished",
        "winner": user.uid,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(title: const Text("PvP Sudoku")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: db.collection("rooms").doc(widget.roomId).snapshots(),
        builder: (context, snap) {
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data!.data() as Map<String, dynamic>;
          final board = List<int>.from(data["board"]);
          final isMyTurn = data["turn"] == user.uid;

          return Column(
            children: [
              // 📊 STATUS
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  isMyTurn ? "Lượt của bạn" : "Đang chờ đối thủ...",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isMyTurn ? Colors.blue : Colors.grey,
                  ),
                ),
              ),

              // 🏆 WIN / LOSE UI
              if (data["status"] == "finished")
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.black,
                  child: Text(
                    data["winner"] == user.uid
                        ? "🏆 YOU WIN"
                        : "😢 YOU LOSE",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 10),

              // 🎮 GRID
              Container(
                padding: const EdgeInsets.all(2),
                color: Colors.black,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 9,
                  ),
                  itemCount: 81,
                  itemBuilder: (context, i) {
                    bool isSelected = selectedIndex == i;
                    return GestureDetector(
                      onTap: () {
                        if (data["status"] == "finished") return;
                        setState(() => selectedIndex = i);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(1),
                        color: isSelected ? Colors.blue.shade100 : Colors.white,
                        child: Center(
                          child: Text(
                            board[i] == 0 ? "" : board[i].toString(),
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const Spacer(),

              // ⌨️ BÀN PHÍM SỐ
              Padding(
                padding: const EdgeInsets.all(10),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: List.generate(9, (i) {
                    int val = i + 1;
                    return ElevatedButton(
                      onPressed: () {
                        if (selectedIndex != -1 && isMyTurn && data["status"] != "finished") {
                          playMove(selectedIndex, val);
                        }
                      },
                      child: Text("$val"),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
