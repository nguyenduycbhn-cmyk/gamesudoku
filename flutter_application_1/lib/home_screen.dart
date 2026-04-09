import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'history_screen.dart'; // Đảm bảo đã import màn hình lịch sử

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedLevel = "easy";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EEF5),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            const Text(
              "SUDOKU",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3A4A66),
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 25),

            // Hàng chọn cấp độ
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                levelButton("easy", "Easy", const Color(0xFF6FCF97)),
                const SizedBox(width: 10),
                levelButton("medium", "Medium", const Color(0xFFF2A65A)),
                const SizedBox(width: 10),
                levelButton("hard", "Hard", const Color(0xFFEB5757)),
              ],
            ),

            const SizedBox(height: 40),

            // Khối các nút chức năng chính
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  mainButton(
                    text: "New Game",
                    color: const Color(0xFF6FCF97),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              GameScreen(level: selectedLevel),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  mainButton(
                    text: "Continue",
                    color: const Color(0xFF6C9FD8),
                    onTap: () {
                      // Logic tiếp tục ván đấu cũ (nếu có)
                    },
                  ),
                  const SizedBox(height: 15),
                  // Nút xem lịch sử từ Server đã được bổ sung
                  mainButton(
                    text: "Lịch sử Server",
                    color: Colors.orangeAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Trang trí phía dưới
            Container(
              height: 120,
              decoration: const BoxDecoration(
                color: Color(0xFFD6E4F0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget cho nút chọn cấp độ
  Widget levelButton(String value, String text, Color color) {
    bool isSelected = selectedLevel == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLevel = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  // Widget dùng chung cho các nút lớn
  Widget mainButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
