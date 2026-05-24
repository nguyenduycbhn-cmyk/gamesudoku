import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

import 'friends_screen.dart';
import 'invite_screen.dart';
import 'search_friend_screen.dart';
import 'create_room.dart';
import 'join_room.dart';
import 'leaderboard_screen.dart';

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const LandingScreen(),
    );
  }
}

// ================= LANDING SCREEN =================

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.grid_on_rounded, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              "SUDOKU MASTER",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 50),
            _choiceBtn(
              context,
              "Chơi Offline",
              Icons.cloud_off_rounded,
              Colors.white,
              Colors.deepPurple.shade700,
                  () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen(isOffline: true)),
              ),
            ),
            const SizedBox(height: 20),
            _choiceBtn(
              context,
              "Chơi Online",
              Icons.language_rounded,
              Colors.deepPurple.shade700,
              Colors.white,
                  () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuthWrapper()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _choiceBtn(BuildContext context, String text, IconData icon, Color textColor, Color bgColor, VoidCallback onTap) {
    return SizedBox(
      width: 250,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: textColor),
        label: Text(
          text,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
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
        if (snap.hasData) return const HomeScreen(isOffline: false);
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sai tài khoản hoặc mật khẩu")),
        );
      }
    }
  }

  void resetPassword() async {
    if (email.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập email để đặt lại mật khẩu")),
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Link đặt lại mật khẩu đã được gửi vào email của bạn")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng nhập Online")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: email, decoration: const InputDecoration(labelText: "Email")),
              TextField(controller: pass, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: login, child: const Text("Login")),
              TextButton(
                onPressed: resetPassword,
                child: const Text("Quên mật khẩu?"),
              ),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: const Text("Chưa có tài khoản? Đăng ký"),
              )
            ],
          ),
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

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.user!.uid)
          .set({
        "name": name.text.trim(),
        "email": email.text.trim(),
        "isOnline": true,
        "status": "online",
        "created": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${e.toString()}")),
        );
      }
    }
  }

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

class HomeScreen extends StatefulWidget {
  final bool isOffline;
  const HomeScreen({super.key, required this.isOffline});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!widget.isOffline) setOnline();
  }

  @override
  void dispose() {
    if (!widget.isOffline) setOffline();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> setOnline() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
      "isOnline": true,
      "status": "online",
    });
  }

  Future<void> setOffline() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
      "isOnline": false,
      "status": "offline",
    });
  }

  Future<void> setPlaying() async {
    if (widget.isOffline) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
      "status": "playing",
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.isOffline) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (state == AppLifecycleState.resumed) {
      setOnline();
    } else {
      setOffline();
    }
  }

  void logout() {
    showDialog(
      context: context,
      builder: (context) {
        final navigator = Navigator.of(context);
        return AlertDialog(
          title: Text(widget.isOffline ? "Thoát" : "Đăng xuất"),
          content: Text(widget.isOffline ? "Bạn muốn quay lại màn hình chính?" : "Bạn có chắc chắn muốn thoát không?"),
          actions: [
            TextButton(onPressed: () => navigator.pop(), child: const Text("Hủy")),
            TextButton(
              onPressed: () async {
                navigator.pop(); // Đóng hộp thoại
                if (widget.isOffline) {
                  navigator.pop(); // Quay về LandingScreen
                } else {
                  await setOffline();
                  // Quay về LandingScreen TRƯỚC khi signOut để tránh lỗi mất context
                  navigator.pop(); 
                  await FirebaseAuth.instance.signOut();
                }
              },
              child: Text(widget.isOffline ? "Thoát" : "Đăng xuất", style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void changePassword() async {
    final TextEditingController newPassController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Đổi mật khẩu"),
        content: TextField(
          controller: newPassController,
          decoration: const InputDecoration(labelText: "Mật khẩu mới"),
          obscureText: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.currentUser!.updatePassword(newPassController.text.trim());
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Đổi mật khẩu thành công")),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Lỗi: ${e.toString()}")),
                  );
                }
              }
            },
            child: const Text("Cập nhật"),
          ),
        ],
      ),
    );
  }

  Widget menuBtn({required IconData icon, required String text, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 3)),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 12),
              Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget modeBtn(String text, int level, Color color, IconData icon) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: InkWell(
          onTap: () {
            setPlaying();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => GameScreen(level: level, isOffline: widget.isOffline)),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withOpacity(0.8), color], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                Icon(icon, color: Colors.white, size: 30),
                const SizedBox(height: 8),
                Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(widget.isOffline ? "Sudoku Offline" : "Sudoku Online", style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!widget.isOffline)
            IconButton(icon: const Icon(Icons.settings_outlined), onPressed: changePassword),
          IconButton(
            icon: Icon(widget.isOffline ? Icons.arrow_back_rounded : Icons.logout_rounded),
            onPressed: logout,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Chọn độ khó", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Row(
                children: [
                  modeBtn("Dễ", 40, Colors.green.shade400, Icons.sentiment_satisfied_alt),
                  modeBtn("Trung bình", 50, Colors.orange.shade400, Icons.sentiment_neutral),
                  modeBtn("Khó", 60, Colors.red.shade400, Icons.sentiment_very_dissatisfied),
                ],
              ),
              const SizedBox(height: 30),
              if (!widget.isOffline) ...[
                const Text("Chơi cùng bạn bè", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: menuBtn(
                        icon: Icons.add_box_outlined,
                        text: "Tạo phòng",
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreateRoom(userId: user?.uid ?? ""))),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: menuBtn(
                        icon: Icons.login_rounded,
                        text: "Vào phòng",
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JoinRoom(userId: user?.uid ?? ""))),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Khám phá", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                menuBtn(
                  icon: Icons.emoji_events_outlined,
                  text: "Bảng xếp hạng",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
                ),
                menuBtn(
                  icon: Icons.history_rounded,
                  text: "Lịch sử đấu",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                ),
                const Divider(height: 40),
                menuBtn(
                  icon: Icons.people_outline_rounded,
                  text: "Danh sách bạn bè",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FriendsScreen())),
                ),
                menuBtn(
                  icon: Icons.person_add_alt_1_outlined,
                  text: "Tìm kiếm người lạ",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchFriendScreen())),
                ),
                menuBtn(
                  icon: Icons.mail_outline_rounded,
                  text: "Lời mời kết bạn",
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InviteScreen())),
                ),
              ] else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Text("Bạn đang ở chế độ Offline.\nCác tính năng mạng đã được ẩn.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= HISTORY =================

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lịch sử chơi")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("history").orderBy("created", descending: true).snapshots(),
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("Chưa có lịch sử"));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(d["name"] ?? "Anonymous"),
                  subtitle: Text("Chế độ: ${d["level"] ?? "Không rõ"}"),
                  trailing: Text("${d["time"]}s", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ================= GAME =================

class GameScreen extends StatefulWidget {
  final int level;
  final bool isOffline;
  const GameScreen({super.key, required this.level, required this.isOffline});

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
    generate();
    _loadGame();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => time++);
        if (time % 5 == 0) _saveGame();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _saveGame() async {
    if (widget.isOffline) {
      final prefs = await SharedPreferences.getInstance();
      final gameData = {
        "grid": board,
        "solution": solution,
        "time": time,
        "level": widget.level,
      };
      await prefs.setString("offline_game_${widget.level}", jsonEncode(gameData));
    } else {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await FirebaseFirestore.instance.collection("game_states").doc(user.uid).set({
        "grid": board,
        "solution": solution,
        "time": time,
        "level": widget.level,
      });
    }
  }

  Future<void> _loadGame() async {
    Map<String, dynamic>? data;
    if (widget.isOffline) {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString("offline_game_${widget.level}");
      if (json != null) data = jsonDecode(json);
    } else {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final doc = await FirebaseFirestore.instance.collection("game_states").doc(user.uid).get();
      if (doc.exists) data = doc.data();
    }

    if (data != null && data["level"] == widget.level) {
      setState(() {
        time = data!["time"] ?? 0;
        board = (data["grid"] as List).map((r) => List<int>.from(r)).toList();
        solution = (data["solution"] as List).map((r) => List<int>.from(r)).toList();
      });
    }
  }

  void generate() {
    solution = generateSolved();
    board = solution.map((r) => [...r]).toList();
    final rand = Random();
    int remove = widget.level;
    while (remove > 0) {
      int r = rand.nextInt(9), c = rand.nextInt(9);
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
      int nr = c == 8 ? r + 1 : r, nc = (c + 1) % 9;
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
    for (int i = 0; i < 9; i++) if (g[r][i] == n || g[i][c] == n) return false;
    int br = (r ~/ 3) * 3, bc = (c ~/ 3) * 3;
    for (int i = 0; i < 3; i++) for (int j = 0; j < 3; j++) if (g[br + i][bc + j] == n) return false;
    return true;
  }

  bool wrong(int r, int c) => board[r][c] != 0 && board[r][c] != solution[r][c];

  void input(int n) {
    if (row == -1) return;
    setState(() => board[row][col] = n);
    _saveGame();
  }

  void hint() {
    if (row == -1) return;
    setState(() => board[row][col] = solution[row][col]);
  }

  Future<void> submit() async {
    bool correct = true;
    for (int i = 0; i < 9; i++) for (int j = 0; j < 9; j++) if (board[i][j] != solution[i][j]) correct = false;
    if (correct) {
      timer?.cancel();
      if (widget.isOffline) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove("offline_game_${widget.level}");
      } else {
        final user = FirebaseAuth.instance.currentUser;
        String levelText = widget.level == 40 ? "Dễ" : widget.level == 50 ? "Trung bình" : "Khó";
        await FirebaseFirestore.instance.collection("history").add({
          "name": user?.displayName ?? "Anonymous",
          "time": time,
          "level": levelText,
          "created": FieldValue.serverTimestamp(),
        });
        if (user != null) await FirebaseFirestore.instance.collection("game_states").doc(user.uid).delete();
      }
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text("🎉 Thắng!"),
            content: Text("Time: $time s"),
            actions: [TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text("OK"))],
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sai rồi!")));
    }
  }

  Widget cell(int r, int c) {
    bool selected = r == row && c == col;
    return GestureDetector(
      onTap: () => setState(() { row = r; col = c; }),
      child: Container(
        width: 40, height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.blue.shade100 : wrong(r, c) ? Colors.red.shade200 : Colors.white,
          border: Border(
            top: BorderSide(width: r % 3 == 0 ? 2 : 0.5),
            left: BorderSide(width: c % 3 == 0 ? 2 : 0.5),
            right: BorderSide(width: (c + 1) % 3 == 0 ? 2 : 0.5),
            bottom: BorderSide(width: (r + 1) % 3 == 0 ? 2 : 0.5),
          ),
        ),
        child: Text(board[r][c] == 0 ? "" : board[r][c].toString(), style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("⏱ $time s")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(2),
              color: Colors.black,
              child: Column(
                children: List.generate(9, (i) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(9, (j) => cell(i, j)),
                )),
              ),
            ),
            Wrap(
              children: List.generate(9, (i) => GestureDetector(
                onTap: () => input(i + 1),
                child: Container(
                  margin: const EdgeInsets.all(5),
                  width: 40, height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(5)),
                  child: Text("${i + 1}", style: const TextStyle(fontSize: 18)),
                ),
              )),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: hint, child: const Text("Hint")),
                const SizedBox(width: 20),
                ElevatedButton(onPressed: submit, child: const Text("Check")),
              ],
            )
          ],
        ),
      ),
    );
  }
}
