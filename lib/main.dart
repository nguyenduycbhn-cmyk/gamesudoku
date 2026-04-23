import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
    );
  }
}

// ================= AUTH =================

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snap.hasData) return const HomeScreen();
        return const LoginScreen();
      },
    );
  }
}

// ================= LOGIN =================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final email = TextEditingController();
  final pass = TextEditingController();

  void login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: pass.text.trim(),
      );
    } catch (e) {
      show("Sai tài khoản");
    }
  }

  void show(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng nhập")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: email, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: pass, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: const Text("Login")),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
              child: const Text("Đăng ký"),
            )
          ],
        ),
      ),
    );
  }
}

// ================= REGISTER =================

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterState();
}

class _RegisterState extends State<RegisterScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();

  void register() async {
    try {
      final user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: pass.text.trim(),
      );
      await user.user!.updateDisplayName(name.text.trim());
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      show("Lỗi đăng ký");
    }
  }

  void show(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng ký")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: "Tên")),
            TextField(controller: email, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: pass, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: register, child: const Text("Register")),
          ],
        ),
      ),
    );
  }
}

// ================= HOME =================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Widget hiển thị 3 nút chế độ trên cùng 1 hàng
  Widget modeBtn(BuildContext context, String text, int level, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withValues(alpha: 0.15), // Nền nhạt
            foregroundColor: color, // Màu chữ
            elevation: 0, // Bỏ đổ bóng cho giống thiết kế phẳng
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => GameScreen(level: level)),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // Widget custom cho các nút bên dưới
  Widget menuBtn({required IconData icon, required String text, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFF3EDF7), // Màu nền tím nhạt giống ảnh
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFE6E0E9), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF6750A4), size: 20), // Icon tím
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6750A4), // Chữ tím
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF7FF), // Màu nền app hơi ám hồng nhẹ
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sudoku Game",
          style: TextStyle(color: Color(0xFF6750A4), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF6750A4)),
            onPressed: () => FirebaseAuth.instance.signOut(),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // --- KHU VỰC CHỌN CHẾ ĐỘ ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EDF7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE6E0E9), width: 1.5),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.gamepad, color: Color(0xFF6750A4), size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Chọn chế độ",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6750A4),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      modeBtn(context, "Dễ", 40, Colors.green.shade700),
                      modeBtn(context, "Trung bình", 50, Colors.orange.shade700),
                      modeBtn(context, "Khó", 60, Colors.red.shade700),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // --- CÁC NÚT MENU CÒN LẠI ---
            menuBtn(
              icon: Icons.timer_outlined,
              text: "Thời gian",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tính năng đang phát triển")));
              },
            ),
            menuBtn(
              icon: Icons.emoji_events_outlined,
              text: "Bảng xếp hạng",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Leaderboard()),
              ),
            ),
            menuBtn(
              icon: Icons.history_edu,
              text: "Lịch sử",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tính năng đang phát triển")));
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ================= GAME =================

class GameScreen extends StatefulWidget {
  final int level; // số ô trống
  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameState();
}

class _GameState extends State<GameScreen> {
  List<List<int>> board = [];
  List<List<int>> solution = [];

  int row = -1, col = -1;
  int time = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    generate(); // Tạo game mới (phòng trường hợp không có save file)
    loadGame(); // 🔥 LOAD GAME KHI MỞ

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => time++);
      // Auto save mỗi 5 giây để tránh quá tải Firebase Write (vượt giới hạn miễn phí)
      if (time % 5 == 0) {
        saveGame();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // =========================
  // 💾 SAVE GAME
  // =========================
  Future<void> saveGame() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("game_states")
        .doc(user.uid)
        .set({
      "grid": board.map((r) => r.toList()).toList(), // Lưu bảng đang chơi
      "solution": solution.map((r) => r.toList()).toList(), // Lưu đáp án
      "time": time,
      "level": widget.level,
    });
  }

  // =========================
  // 📥 LOAD GAME
  // =========================
  Future<void> loadGame() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("game_states")
        .doc(user.uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;

    // Nếu game đang lưu có mức độ giống mức độ người chơi vừa chọn thì mới load
    if (data["level"] == widget.level) {
      setState(() {
        time = data["time"] ?? 0;
        List gridData = data["grid"];
        List solData = data["solution"];

        for (int i = 0; i < 9; i++) {
          board[i] = List<int>.from(gridData[i]);
          solution[i] = List<int>.from(solData[i]);
        }
      });
    }
  }

  void generate() {
    solution = generateSolved();
    board = solution.map((r) => [...r]).toList();

    final rand = Random();
    int remove = widget.level;

    while (remove > 0) {
      int r = rand.nextInt(9);
      int c = rand.nextInt(9);
      if (board[r][c] != 0) {
        board[r][c] = 0;
        remove--;
      }
    }
  }

  List<List<int>> generateSolved() {
    List<List<int>> grid = List.generate(9, (_) => List.filled(9, 0));

    bool solve(int r, int c) {
      if (r == 9) return true;
      int nr = c == 8 ? r + 1 : r;
      int nc = (c + 1) % 9;

      List nums = List.generate(9, (i) => i + 1)..shuffle();

      for (int n in nums) {
        if (isValid(grid, r, c, n)) {
          grid[r][c] = n;
          if (solve(nr, nc)) return true;
          grid[r][c] = 0;
        }
      }
      return false;
    }

    solve(0, 0);
    return grid;
  }

  bool isValid(List<List<int>> g, int r, int c, int n) {
    for (int i = 0; i < 9; i++) {
      if (g[r][i] == n || g[i][c] == n) return false;
    }
    int br = (r ~/ 3) * 3, bc = (c ~/ 3) * 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (g[br + i][bc + j] == n) return false;
      }
    }
    return true;
  }

  bool wrong(int r, int c) =>
      board[r][c] != 0 && board[r][c] != solution[r][c];

  void input(int n) {
    if (row == -1) return;
    setState(() => board[row][col] = n);
    saveGame(); // Lưu ngay khi người dùng điền số
  }

  void hint() {
    if (row == -1) return;
    setState(() => board[row][col] = solution[row][col]);
  }

  // =========================
  // ✅ CHECK WIN VÀ SAVE LEADERBOARD
  // =========================
  Future<void> submit() async {
    bool correct = true;

    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (board[i][j] != solution[i][j]) {
          correct = false;
        }
      }
    }

    if (correct) {
      timer?.cancel();

      final user = FirebaseAuth.instance.currentUser;

      // Lưu vào Leaderboard
      await FirebaseFirestore.instance.collection("history").add({
        "name": user?.displayName ?? "Anonymous",
        "time": time,
        "created": DateTime.now()
      });

      // 🧹 Xoá save khi thắng
      if (user != null) {
        await FirebaseFirestore.instance
            .collection("game_states")
            .doc(user.uid)
            .delete();
      }
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("🎉 Bạn đã thắng!"),
          content: Text("Thời gian: $time giây"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng Dialog
                Navigator.pop(context); // Quay về Home
              },
              child: const Text("OK"),
            )
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chưa đúng hoặc chưa điền đủ, thử lại!")),
      );
    }
  }

  // =========================
  // UI (GIỮ NGUYÊN GRID CỦA BẠN)
  // =========================
  Widget cell(int r, int c) {
    bool selected = r == row && c == col;

    return GestureDetector(
      onTap: () => setState(() {
        if (board[r][c] == 0 || wrong(r, c)) { // Cho phép sửa nếu ô trống hoặc bị sai
          row = r;
          col = c;
        }
      }),
      child: Container(
        margin: const EdgeInsets.all(1),
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? Colors.blue.shade100
              : wrong(r, c)
              ? Colors.red.shade200
              : Colors.white,
          border: Border.all(),
        ),
        child: Text(
          board[r][c] == 0 ? "" : board[r][c].toString(),
          style: TextStyle(
              fontSize: 18,
              fontWeight: wrong(r, c) || (board[r][c] != 0 && board[r][c] == solution[r][c] && !selected) ? FontWeight.normal : FontWeight.bold
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("⏱ $time s")),
      body: Column(
        children: [
          ...List.generate(9, (i) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(9, (j) => cell(i, j)),
          )),
          const SizedBox(height: 15),
          Wrap(
            children: List.generate(9, (i) => GestureDetector(
              onTap: () => input(i + 1),
              child: Container(
                margin: const EdgeInsets.all(5),
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(5)
                ),
                child: Text("${i + 1}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            )),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: hint, child: const Text("Hint")),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  onPressed: submit,
                  child: const Text("Check")
              ),
            ],
          )
        ],
      ),
    );
  }
}

// ================= LEADERBOARD =================

class Leaderboard extends StatelessWidget {
  const Leaderboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Leaderboard")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("history")
            .orderBy("time")
            .snapshots(),
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("Chưa có ai hoàn thành"));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i];
              return ListTile(
                leading: Text("#${i + 1}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                title: Text(d["name"] ?? "Anonymous"),
                trailing: Text("${d["time"]}s", style: const TextStyle(fontSize: 16, color: Colors.green)),
              );
            },
          );
        },
      ),
    );
  }
}