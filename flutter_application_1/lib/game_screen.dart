import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter_application_1/api_service.dart';

class GameScreen extends StatefulWidget {
  final String level;
  const GameScreen({super.key, required this.level});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<List<int>> board = List.generate(9, (_) => List.filled(9, 0));
  List<List<int>> solution = List.generate(9, (_) => List.filled(9, 0));
  List<List<bool>> fixed = List.generate(9, (_) => List.filled(9, false));

  int selectedRow = -1;
  int selectedCol = -1;
  int seconds = 0;
  Timer? timer;
  bool isWon = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    generateGame();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !isWon) setState(() => seconds++);
    });
  }

  void generateGame() {
    List<List<int>> grid = List.generate(9, (_) => List.filled(9, 0));
    solve(grid);
    solution = grid.map((row) => [...row]).toList();

    int removeCount = (widget.level == "easy")
        ? 20
        : (widget.level == "medium" ? 40 : 60);
    Random rand = Random();
    int count = 0;
    while (count < removeCount) {
      int r = rand.nextInt(9);
      int c = rand.nextInt(9);
      if (grid[r][c] != 0) {
        grid[r][c] = 0;
        count++;
      }
    }

    setState(() {
      board = grid;
      fixed = List.generate(9, (r) => List.generate(9, (c) => grid[r][c] != 0));
      seconds = 0;
      isWon = false;
    });
  }

  // Thuật toán kiểm tra hợp lệ và giải Sudoku
  bool solve(List<List<int>> grid) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (grid[r][c] == 0) {
          List<int> nums = List.generate(9, (i) => i + 1)..shuffle();
          for (int num in nums) {
            if (isValid(grid, r, c, num)) {
              grid[r][c] = num;
              if (solve(grid)) return true;
              grid[r][c] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  bool isValid(List<List<int>> g, int r, int c, int num) {
    for (int i = 0; i < 9; i++)
      if (g[r][i] == num || g[i][c] == num) return false;
    int sr = (r ~/ 3) * 3, sc = (c ~/ 3) * 3;
    for (int i = sr; i < sr + 3; i++) {
      for (int j = sc; j < sc + 3; j++) if (g[i][j] == num) return false;
    }
    return true;
  }

  void checkWin() async {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] != solution[r][c]) return;
      }
    }

    // Nếu thắng
    setState(() => isWon = true);
    timer?.cancel();

    bool saved = await _apiService.saveGameResult(
      difficulty: widget.level,
      timeSpent: seconds,
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Chúc mừng!"),
        content: Text(
          "Bạn đã thắng trong $seconds giây.\n${saved ? 'Đã lưu kết quả.' : 'Lỗi lưu server.'}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sudoku: ${widget.level.toUpperCase()}")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              "Thời gian: $seconds giây",
              style: const TextStyle(fontSize: 20),
            ),
          ),
          // Vẽ bảng Sudoku (Tối giản để bạn dễ tích hợp UI)
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
              ),
              itemCount: 81,
              itemBuilder: (context, index) {
                int r = index ~/ 9;
                int c = index % 9;
                return GestureDetector(
                  onTap: () => setState(() {
                    selectedRow = r;
                    selectedCol = c;
                  }),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      color: (selectedRow == r && selectedCol == c)
                          ? Colors.blue.shade100
                          : Colors.white,
                    ),
                    child: Center(
                      child: Text(
                        board[r][c] == 0 ? "" : "${board[r][c]}",
                        style: TextStyle(
                          fontWeight: fixed[r][c]
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: fixed[r][c] ? Colors.black : Colors.blue,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Bàn phím số
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ...List.generate(9, (i) => i + 1).map((n) {
                return ElevatedButton(
                  onPressed: () {
                    if (selectedRow != -1 && !fixed[selectedRow][selectedCol]) {
                      setState(() => board[selectedRow][selectedCol] = n);
                      checkWin();
                    }
                  },
                  child: Text("$n"),
                );
              }).toList(),
              ElevatedButton(
                onPressed: () {
                  if (selectedRow != -1 && !fixed[selectedRow][selectedCol]) {
                    setState(() => board[selectedRow][selectedCol] = 0);
                  }
                },
                child: const Text("Xóa"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Nút chơi lại
          ElevatedButton(
            onPressed: () {
              generateGame();
              startTimer();
            },
            child: const Text("Chơi lại"),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
