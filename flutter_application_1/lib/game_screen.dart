import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// 1. LỚP DỮ LIỆU LỊCH SỬ (Khắc phục lỗi GameHistory undefined)
class GameHistory {
  final String level;
  final String time;
  final String date;

  GameHistory({required this.level, required this.time, required this.date});

  factory GameHistory.fromJson(Map<String, dynamic> json) {
    return GameHistory(
      level: json['difficulty']?.toString() ?? "Easy",
      time: json['time_spent']?.toString() ?? "0",
      date: json['created_at']?.toString() ?? "",
    );
  }
}

// 2. LỚP DỊCH VỤ API (Khắc phục lỗi ApiService undefined)
class ApiService {
  Future<List<dynamic>> fetchHistory() async {
    // Giả lập gọi API, bạn sẽ thay bằng http.get thực tế sau
    return [];
  }

  Future<void> saveGameResult({
    required String difficulty,
    required int timeSpent,
  }) async {
    // Giả lập POST dữ liệu lên Laravel
    print("Saving to server: $difficulty - $timeSpent seconds");
  }
}

// 3. WIDGET MÀN HÌNH GAME (Khắc phục lỗi GameScreen isn't a type)
class GameScreen extends StatefulWidget {
  final String level;
  GameScreen({required this.level});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // --- KHAI BÁO CÁC BIẾN TRẠNG THÁI ---
  List<List<int>> board = List.generate(9, (_) => List.filled(9, 0));
  List<List<int>> solution = List.generate(9, (_) => List.filled(9, 0));
  List<List<bool>> fixed = List.generate(9, (_) => List.filled(9, false));

  int selectedRow = -1;
  int selectedCol = -1;
  int seconds = 0;
  Timer? timer;
  List<GameHistory> history = [];

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

  // --- CÁC HÀM LOGIC ---
  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (mounted) setState(() => seconds++);
    });
  }

  String formatTime() {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  // Khắc phục lỗi generateFullBoard undefined
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

  void generateGame() {
    List<List<int>> newBoard = generateFullBoard();
    solution = newBoard.map((row) => [...row]).toList();

    int removeCount;
    switch (widget.level.toLowerCase()) {
      case "easy":
        removeCount = 20;
        break;
      case "medium":
        removeCount = 40;
        break;
      case "hard":
        removeCount = 60;
        break;
      default:
        removeCount = 40;
    }

    Random rand = Random();
    int count = 0;
    while (count < removeCount) {
      int r = rand.nextInt(9);
      int c = rand.nextInt(9);
      if (newBoard[r][c] != 0) {
        newBoard[r][c] = 0;
        count++;
      }
    }

    setState(() {
      board = newBoard;
      fixed = List.generate(
        9,
        (r) => List.generate(9, (c) => newBoard[r][c] != 0),
      );
      seconds = 0;
    });
  }

  void selectCell(int r, int c) {
    setState(() {
      selectedRow = r;
      selectedCol = c;
    });
  }

  void inputNumber(int num) {
    if (selectedRow == -1 || fixed[selectedRow][selectedCol]) return;
    setState(() {
      board[selectedRow][selectedCol] = num;
    });
    // Thêm hàm checkWin() của bạn ở đây nếu cần
  }

  void saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> localHistory = prefs.getStringList('history') ?? [];
    localHistory.add(
      jsonEncode({
        "level": widget.level,
        "time": formatTime(),
        "date": DateTime.now().toString(),
      }),
    );
    await prefs.setStringList('history', localHistory);

    try {
      ApiService api = ApiService();
      await api.saveGameResult(difficulty: widget.level, timeSpent: seconds);
    } catch (e) {
      print("API Error: $e");
    }
  }

  // --- GIAO DIỆN (Khắc phục lỗi Missing State.build) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sudoku - ${widget.level}"),
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Text(formatTime()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
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
                      border: Border.all(width: 0.5),
                      color: (selectedRow == r && selectedCol == c)
                          ? Colors.blue[100]
                          : Colors.white,
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
          ),
          Wrap(
            children: List.generate(
              9,
              (i) => ElevatedButton(
                onPressed: () => inputNumber(i + 1),
                child: Text("${i + 1}"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
