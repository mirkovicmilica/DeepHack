import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final leaderboard = [
      {"name": "Alice", "points": 45},
      {"name": "You", "points": 40},
      {"name": "Bob", "points": 30},
    ];
    return ListView(
      children:
          leaderboard
              .map(
                (entry) => ListTile(
                  title: Text(entry["name"]! as String),
                  trailing: Text("${entry["points"]} pts"),
                ),
              )
              .toList(),
    );
  }
}
