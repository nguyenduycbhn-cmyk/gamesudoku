import 'package:flutter/material.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedLevel = "easy";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE9EEF5),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 40),

            Text(
              "SUDOKU",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3A4A66),
                letterSpacing: 2,
              ),
            ),

            SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                levelButton("easy", "Easy", Color(0xFF6FCF97)),
                SizedBox(width: 10),
                levelButton("medium", "Medium", Color(0xFFF2A65A)),
                SizedBox(width: 10),
                levelButton("hard", "Hard", Color(0xFFEB5757)),
              ],
            ),

            SizedBox(height: 40),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  mainButton(
                    text: "New Game",
                    color: Color(0xFF6FCF97),
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
                  SizedBox(height: 15),
                  mainButton(
                    text: "Continue",
                    color: Color(0xFF6C9FD8),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            Spacer(),

            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Color(0xFFD6E4F0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget levelButton(String value, String text, Color color) {
    bool isSelected = selectedLevel == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLevel = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text, style: TextStyle(color: Colors.white)),
      ),
    );
  }

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
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
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
