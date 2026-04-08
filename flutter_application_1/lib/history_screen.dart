import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'history_model.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<GameHistory> history = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> data = prefs.getStringList('history') ?? [];

    setState(() {
      history = data
          .map((e) => GameHistory.fromJson(jsonDecode(e)))
          .toList()
          .reversed
          .toList();
    });
  }

  void clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('history');
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
        actions: [IconButton(onPressed: clear, icon: Icon(Icons.delete))],
      ),
      body: history.isEmpty
          ? Center(child: Text("No history"))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (_, i) {
                final h = history[i];
                return ListTile(
                  title: Text("Level: ${h.level}"),
                  subtitle: Text("Time: ${h.time}"),
                  trailing: Text(h.date.substring(0, 16)),
                );
              },
            ),
    );
  }
}
