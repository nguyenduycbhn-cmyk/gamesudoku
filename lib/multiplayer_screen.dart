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
    double screenWidth = MediaQuery.of(context).size.width;
    double boardSize = screenWidth - 20;

    return Scaffold(
      appBar: AppBar(
        title: Text("Phòng: ${widget.roomId}"),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: service.getRoom(widget.roomId),
        builder: (context, snap) {
          if (snap.hasError) {
            return const Center(child: Text("Lỗi kết nối"));
          }

          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data!.data() as Map<String, dynamic>?;

          if (data == null) {
            return const Center(child: Text("Phòng không tồn tại"));
          }

          // BOARD
          List<List<int>> board =
          service.revertBoard(data["board"]);

          List<List<int>> solution =
          service.revertBoard(data["solution"]);

          List players = data["players"] ?? [];

          String turn = data["turn"] ?? "";

          String winner = data["winner"] ?? "";

          String status = data["status"] ?? "";

          bool isMyTurn = turn == user.uid;

          bool isWaiting =
              status == "waiting" || players.length < 2;

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // WAITING
                  if (isWaiting)
                    Container(
                      width: double.infinity,
                      color: Colors.amber.shade100,
                      padding: const EdgeInsets.all(10),
                      child: const Text(
                        "⏳ Đang đợi đối thủ vào phòng...",
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // WINNER
                  if (winner != "")
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        winner == user.uid
                            ? "🎉 BẠN ĐÃ THẮNG!"
                            : "😢 ĐỐI THỦ ĐÃ THẮNG",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: winner == user.uid
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),

                  // TURN
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person,
                          color: isMyTurn
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isMyTurn
                              ? "👉 Lượt của bạn"
                              : "⏳ Chờ đối thủ đi...",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isMyTurn
                                ? Colors.blue
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // SUDOKU BOARD
                  Container(
                    width: boardSize,
                    height: boardSize,
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 3,
                      ),
                    ),
                    child: GridView.builder(
                      physics:
                      const NeverScrollableScrollPhysics(),
                      itemCount: 81,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 9,
                      ),
                      itemBuilder: (context, index) {
                        int r = index ~/ 9;
                        int c = index % 9;

                        bool isSelected =
                            r == selectedRow &&
                                c == selectedCol;

                        return GestureDetector(
                          onTap: () {
                            if (!isMyTurn ||
                                isWaiting ||
                                winner != "") {
                              return;
                            }

                            setState(() {
                              selectedRow = r;
                              selectedCol = c;
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue.shade100
                                  : Colors.white,
                              border: Border(
                                top: BorderSide(
                                  width:
                                  r % 3 == 0 ? 2 : 0.5,
                                  color: Colors.black,
                                ),
                                left: BorderSide(
                                  width:
                                  c % 3 == 0 ? 2 : 0.5,
                                  color: Colors.black,
                                ),
                                right: BorderSide(
                                  width:
                                  c == 8 ? 2 : 0.5,
                                  color: Colors.black,
                                ),
                                bottom: BorderSide(
                                  width:
                                  r == 8 ? 2 : 0.5,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            child: Text(
                              board[r][c] == 0
                                  ? ""
                                  : board[r][c]
                                  .toString(),
                              style: TextStyle(
                                fontSize: boardSize / 25,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // NUMBER PAD
                  if (isMyTurn &&
                      !isWaiting &&
                      winner == "")
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(
                          9,
                              (i) => SizedBox(
                            width: screenWidth / 6,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (selectedRow == -1) {
                                  return;
                                }

                                int value = i + 1;

                                board[selectedRow]
                                [selectedCol] = value;

                                await service.updateBoard(
                                  widget.roomId,
                                  board,
                                );

                                // CHECK WIN
                                bool isWin = true;

                                for (int r = 0;
                                r < 9;
                                r++) {
                                  for (int c = 0;
                                  c < 9;
                                  c++) {
                                    if (board[r][c] !=
                                        solution[r][c]) {
                                      isWin = false;
                                    }
                                  }
                                }

                                if (isWin) {
                                  await service.db
                                      .collection("rooms")
                                      .doc(widget.roomId)
                                      .update({
                                    "winner": user.uid
                                  });
                                } else {
                                  if (players.length >=
                                      2) {
                                    String next =
                                    players.first ==
                                        user.uid
                                        ? players[1]
                                        : players[0];

                                    await service.db
                                        .collection(
                                        "rooms")
                                        .doc(
                                        widget.roomId)
                                        .update({
                                      "turn": next
                                    });
                                  }
                                }

                                setState(() {
                                  selectedRow = -1;
                                  selectedCol = -1;
                                });
                              },
                              child: Text(
                                "${i + 1}",
                                style:
                                const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}