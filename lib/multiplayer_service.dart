import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MultiplayerService {
  final db = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser!;

  // ================= SUDOKU GENERATOR =================

  List<List<int>> generateSolvedBoard() {
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

    int br = (r ~/ 3) * 3;
    int bc = (c ~/ 3) * 3;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (g[br + i][bc + j] == n) return false;
      }
    }

    return true;
  }

  List<List<int>> createPuzzle(List<List<int>> solution) {
    List<List<int>> board =
    solution.map((row) => List<int>.from(row)).toList();

    int remove = 45; // độ khó

    Random rand = Random();
    while (remove > 0) {
      int r = rand.nextInt(9);
      int c = rand.nextInt(9);

      if (board[r][c] != 0) {
        board[r][c] = 0;
        remove--;
      }
    }

    return board;
  }

  // ================= CREATE ROOM =================

  Future<String> createRoom(String opponentUid) async {
    final solution = generateSolvedBoard();
    final board = createPuzzle(solution);

    final doc = await db.collection("rooms").add({
      "players": [user.uid, opponentUid],
      "board": board,
      "solution": solution,
      "turn": user.uid,
      "winner": "",
      "created": FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  // ================= REALTIME =================

  Stream<DocumentSnapshot> getRoom(String roomId) {
    return db.collection("rooms").doc(roomId).snapshots();
  }

  Future<void> updateBoard(String roomId, List<List<int>> board) async {
    await db.collection("rooms").doc(roomId).update({
      "board": board,
    });
  }

  Future<void> setWinner(String roomId) async {
    await db.collection("rooms").doc(roomId).update({
      "winner": user.uid,
    });
  }
}