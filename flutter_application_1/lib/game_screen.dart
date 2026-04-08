import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GameScreen extends StatefulWidget {
  final String level;

  GameScreen({required this.level});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<List<int>> board = List.generate(9, (_) => List.filled(9, 0));
  List<List<int>> solution = List.generate(9, (_) => List.filled(9, 0));
  List<List<bool>> fixed = List.generate(9, (_) => List.filled(9, false));

  int selectedRow = -1;
  int selectedCol = -1;

  Timer? timer;
  int seconds = 0;

  @override
  void initState() {
    super.initState();
    generateGame();
    startTimer();
  }

  // ================= TIMER =================
  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() => seconds++);
    });
  }

  String formatTime() {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  // ================= GAME =================
  void generateGame() {
    List<List<int>> newBoard = generateFullBoard();
    solution = newBoard.map((row) => [...row]).toList();

    int removeCount;
    switch (widget.level) {
      case "easy":
        removeCount = 30;
        break;
      case "medium":
        removeCount = 40;
        break;
      case "hard":
        removeCount = 50;
        break;
      default:
        removeCount = 40;
    }

    Random rand = Random();
    for (int i = 0; i < removeCount; i++) {
      int r = rand.nextInt(9);
      int c = rand.nextInt(9);
      newBoard[r][c] = 0;
    }

    fixed = List.generate(
      9,
      (r) => List.generate(9, (c) => newBoard[r][c] != 0),
    );

    setState(() {
      board = newBoard;
      seconds = 0;
    });
  }

  List<List<int>> generateFullBoard() {
    List<List<int>> grid = List.generate(9, (_) => List.filled(9, 0));
    solve(grid);
    return grid;
  }

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
    for (int i = 0; i < 9; i++) {
      if (g[r][i] == num || g[i][c] == num) return false;
    }

    int sr = (r ~/ 3) * 3;
    int sc = (c ~/ 3) * 3;

    for (int i = sr; i < sr + 3; i++) {
      for (int j = sc; j < sc + 3; j++) {
        if (g[i][j] == num) return false;
      }
    }

    return true;
  }

  // ================= INPUT =================
  void selectCell(int r, int c) {
    setState(() {
      selectedRow = r;
      selectedCol = c;
    });
  }

  void inputNumber(int num) {
    if (selectedRow == -1) return;
    if (fixed[selectedRow][selectedCol]) return;

    setState(() {
      board[selectedRow][selectedCol] = num;
    });

    checkWin();
  }

  // ================= CHECK WIN =================
  void checkWin() {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] != solution[r][c]) return;
      }
    }

    timer?.cancel();
    saveHistory();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text("🎉 You Win!"),
        content: Text("Time: ${formatTime()}"),
        actions: [
          // HOME
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("Home"),
          ),

          // PLAY AGAIN
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              generateGame();
              startTimer();
            },
            child: Text("Play Again"),
          ),
        ],
      ),
    );
  }

  // ================= SAVE HISTORY =================
  void saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('history') ?? [];

    history.add(
      jsonEncode({
        "level": widget.level,
        "time": formatTime(),
        "date": DateTime.now().toString(),
      }),
    );

    prefs.setStringList('history', history);
  }

  // ================= COLOR =================
  Color getColor(int r, int c) {
    if (fixed[r][c]) return Colors.grey[300]!;
    if (board[r][c] == 0) return Colors.white;

    return board[r][c] == solution[r][c]
        ? Colors.green[200]!
        : Colors.red[200]!;
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sudoku (${widget.level})"),
        actions: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: Text(formatTime())),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: buildGrid()),
          buildControls(),
        ],
      ),
    );
  }

  Widget buildGrid() {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        itemCount: 81,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
        ),
        itemBuilder: (_, i) {
          int r = i ~/ 9;
          int c = i % 9;

          return GestureDetector(
            onTap: () => selectCell(r, c),
            child: Container(
              decoration: BoxDecoration(
                color: getColor(r, c),
                border: Border.all(width: 0.5),
              ),
              child: Center(
                child: Text(
                  board[r][c] == 0 ? "" : "${board[r][c]}",
                  style: TextStyle(
                    fontWeight: fixed[r][c]
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildControls() {
    return Wrap(
      children: List.generate(9, (i) {
        return ElevatedButton(
          onPressed: () => inputNumber(i + 1),
          child: Text("${i + 1}"),
        );
      }),
    );
  }
}
